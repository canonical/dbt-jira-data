#/bin/sh

# Function to check if a secret is not in a list
not_in_list() {
	local search="$1"
	local array=("$2")
	shift
	for item in $array; do
		if [[ "$item" == "$search" ]]; then
			return 1 # Found
		fi
	done
	return 0 # Not found
}
