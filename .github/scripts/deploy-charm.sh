#!/bin/bash
# Deploys the workflow using Juju.
#
# Parameters (environment variables):
# - DOCKER_REGISTRY - The url of the docker registry to pull the image from.
# - APP_VERSION - The version of the application being deployed.
# - WORKFLOW_NAME - The name of the workflow being deployed.
#
# Secrets:
# Credentials for accessing Vault on PS6:
# - VAULT_APPROLE_ROLE_ID
# - VAULT_APPROLE_SECRET_ID

echo "Sourcing .envrc"
source $HOME/.envrc

# Run juju status command and store the output in a variable.
juju_status_output=$(juju status)

# Define the application name to check.
application_name="${WORKFLOW_NAME}-worker"

echo "Creating registry file"
cat <<- EOF > "$HOME/registryconfig.yaml"
registrypath: $DOCKER_REGISTRY/dbt-workflow:$APP_VERSION
EOF

echo "Check if the application name exists in the output"
# Check if the application name exists in the output.
if echo "$juju_status_output" | grep -qi "$application_name"; then
    echo "Application '$application_name' already exists, refreshing."
    juju refresh $application_name --resource temporal-worker-image=$HOME/registryconfig.yaml
    # Application should either become active blocked if it is missing configuration.
    juju wait-for application $application_name --query='status == "active" || status == "blocked"' --timeout=2m
else
    echo "Application '$application_name' does not exist, deploying."
    juju deploy temporal-worker-k8s --channel edge --resource temporal-worker-image=$HOME/registryconfig.yaml $application_name
    # Application should either become active blocked if it is missing configuration.
    juju wait-for application $application_name --query='status == "active" || status == "blocked"' --timeout=2m
fi
