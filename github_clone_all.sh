#!/bin/bash

script_path=$(dirname $0)
script_name=$(basename $0)

print_usage_and_exit_with_error() {
  echo $'\nUsage:' >&2
  echo $"  $script_name user={user_name}" >&2
  echo $"  $script_name org={org_name}" >&2
  echo $'\nWhere {user_name} and {org_name} should be substituted with GitHub' \
    'user name or organization name respectively' >&2
  exit 1
}


if [[ $# -ne 1 ]]; then
  print_usage_and_exit_with_error
fi

if [[ ! ($1 =~ ^user\=.+ || $1 =~ ^org\=.+) ]]; then
  print_usage_and_exit_with_error
fi


if [[ $1 =~ ^user\=(.+) ]]; then
  user_or_org_name=${BASH_REMATCH[1]}
  github_uri="https://api.github.com/users/$user_or_org_name/repos"
  echo "Using uri '$github_uri' to clone all repositories for user" \
    "'$user_or_org_name'"
elif [[ $1 =~ ^org\=(.+) ]]; then
  user_or_org_name=${BASH_REMATCH[1]}
  github_uri="https://api.github.com/orgs/$user_or_org_name/repos"
  echo "Using uri '$github_uri' to clone all repositories for organization" \
    "'$user_or_org_name'"
else
  echo "Input arguments validation logic failed and usupported arguments were" \
    "accepted. Script needs to be fixed" >&2
  exit 1
fi

json_response=$(curl -s $github_uri)

if [[ $json_response =~ '"message": "Not Found"' ]]; then
  echo "Invalid GitHub user name or organization name" >&2
  exit 1
fi

repositories_folder=$user_or_org_name
if [[ ! (-d $repositories_folder) ]]; then
  echo "Creating directory './$repositories_folder' for repositories from" \
    "'$user_or_org_name'"
  mkdir "./$repositories_folder"
fi

echo "Changing current working directory to './$repositories_folder'"
cd "./$repositories_folder"

echo $json_response | python $script_path/github_clone_all_from_json.py
