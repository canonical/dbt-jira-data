#!/bin/bash
# Integrate with vault and fetch relevant credentials, saving them wherever
# needed (${HOME}/.local/share/juju, ${HOME}/.envrc). This is meant to be run
# inside the LXC deployment container created by `setup-lxc-container.sh`.

# This file is heavy on secret manipulation. DO NOT use -x here.
set +x
set -eu

# vault_auth authenticates with Vault and sets the VAULT_TOKEN env var.
function vault_auth() {
    export VAULT_TOKEN=$(vault write -f -field=token auth/approle/login role_id=${VAULT_APPROLE_ROLE_ID} secret_id=${VAULT_APPROLE_SECRET_ID})
}

# load_juju_controller_config loads the Juju controller config from Vault.
function load_juju_controller_config() {
  vault read -field=controller_config secret/prodstack6/juju/common/controllers/"${JUJU_CONTROLLER}" | base64 -d - > "${HOME}/.local/share/juju/controllers.yaml"
  export no_proxy="$(cat "${HOME}/.local/share/juju/controllers.yaml" | yq ".controllers.${JUJU_CONTROLLER}.api-endpoints[]" | xargs printf "%s,")${no_proxy:-}"
}

# load_juju_account_config loads the Juju account config from Vault.
function load_juju_account_config() {
    USERNAME=$(vault read -field=username "${VAULT_SECRET_PATH_ROLE}"/juju) || return
    PASSWORD=$(vault read -field=password "${VAULT_SECRET_PATH_ROLE}"/juju) || return
    # Watch out for tabs vs spaces when editing the below. First character in each line is a tab
    # which is ignored by the heredoc, to prevent script indentation affecting the written file.
    cat <<- EOF > "${HOME}/.local/share/juju/accounts.yaml"
	controllers:
	    ${JUJU_CONTROLLER?}:
	        user: ${USERNAME}
	        password: ${PASSWORD}
	EOF
}

# load_aws_secrets loads the S3 bucket secrets for Terraform.
function load_aws_secrets() {
  export AWS_ACCESS_KEY_ID=$(vault read -field=access_key "${VAULT_SECRET_PATH_ROLE}/s3") || return
  export AWS_SECRET_ACCESS_KEY=$(vault read -field=secret_key "${VAULT_SECRET_PATH_ROLE}/s3") || return
}

# Remove any existing Juju config and re-create the dir.
rm -rf ${HOME}/.local/share/juju/*
mkdir -p ${HOME}/.local/share/juju

vault_auth
load_juju_controller_config
load_juju_account_config
load_aws_secrets

echo "
export no_proxy=$no_proxy
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export VAULT_ADDR=${VAULT_ADDR}
export VAULT_APPROLE_ROLE_ID=${VAULT_APPROLE_ROLE_ID}
export VAULT_APPROLE_SECRET_ID=${VAULT_APPROLE_SECRET_ID}
export VAULT_SECRET_PATH_ROLE=${VAULT_SECRET_PATH_ROLE}
export VAULT_TOKEN=${VAULT_TOKEN}
" > ${HOME}/.envrc
