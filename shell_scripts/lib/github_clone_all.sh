#!/bin/sh

script_path=$(dirname $0)
script_name=$(basename $0)
script_run_path=${PWD}

print_usage_and_exit_with_error() {
  echo $'\nUsage:' >&2
  echo $"  $script_name user={user_name}" >&2
  echo $"  $script_name org={org_name}" >&2
  echo $"  $script_name user_and_org={user_and_org_name}" >&2
  echo $"  $script_name {user_and_org_name}" >&2
  echo $'\nWhere:' >&2
  echo $'  {user_name} - GitHub user name' >&2
  echo $'  {org_name} - GitHub organization name' >&2
  echo $'  {user_and_org_name} - GitHub user and organization name.' \
    'Repositories for both account types will be cloned' >&2

  exit 1
}

python3_command_exists() {
  command -v python3 >/dev/null 2>&1;
}

create_repositories_dir_if_not_created() {
  if [[ ${PWD} == "$script_run_path/$user_or_org_name" ]]; then
    return
  fi

  repositories_folder=$user_or_org_name
  if [[ ! (-d $repositories_folder) ]]; then
    echo "Creating directory './$repositories_folder' for repositories from" \
      "'$user_or_org_name'"
    mkdir "./$repositories_folder"
  fi

  echo "Changing current working directory to './$repositories_folder'"
  cd "./$repositories_folder"
}

clone_repositories() {
  json_response=$(curl -s $github_uri)

  if [[ $json_response =~ '"message": "Not Found"' ]]; then
    echo "Invalid GitHub user name or organization name" >&2
    return
  fi

  create_repositories_dir_if_not_created

  echo $json_response | python3 $script_path/github_clone_all_from_json.py
}


if [[ $# -ne 1 ]]; then
  print_usage_and_exit_with_error
fi

if [[ ! ($1 =~ ^(user\=|org\=|user_and_org\=){0,1}(.+)) ]]; then
  print_usage_and_exit_with_error
fi

if ! python3_command_exists; then
  echo "python3 required, but not found. Aborting." >&2
  exit 1
fi

user_or_org_prefix=${BASH_REMATCH[1]}
user_or_org_name=${BASH_REMATCH[2]}

if [[ $user_or_org_prefix == '' || $user_or_org_prefix == 'user_and_org=' ]]; then
  echo "About to clone for both user and organization with name" \
    "'$user_or_org_name'" \
    $'\n'
fi

# Clone for user when either 'user=', 'user_and_org=' or nothing (empty
# string) was passed as a command line parameter prefix. This condition is
# equivalent to situation where 'org=' was not passed as a command line
# parameter prefix
if [[ $user_or_org_prefix != 'org=' ]]; then
  github_uri="https://api.github.com/users/$user_or_org_name/repos"
  echo "Using uri '$github_uri' to clone all repositories for user" \
    "'$user_or_org_name'"

  clone_repositories
fi

# Similar situation as above. Clone for organization in three remaining cases
# when 'user=' was not passed in command line parameter
if [[ $user_or_org_prefix != 'user=' ]]; then
  github_uri="https://api.github.com/orgs/$user_or_org_name/repos"
  echo "Using uri '$github_uri' to clone all repositories for" \
    "organization '$user_or_org_name'"

  clone_repositories
fi
