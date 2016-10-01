#!/bin/bash

script_name=$(basename $0)

print_usage_and_exit_with_error() {
  echo $'\nUsage:' >&2
  echo $"  $script_name repo={user_or_org_name}/{repo_name}" >&2
  echo $"  $script_name {user_or_org_name}/{repo_name}" >&2
  echo $'\nWhere {user_or_org_name} and {repo_name} should be substituted' \
    'with GitHub user name or organization name and repository name' \
    'respectively' >&2
  exit 1
}


if [[ $# -ne 1 ]]; then
  print_usage_and_exit_with_error
fi

if [[ ! ($1 =~ ^(repo\=){0,1}(.+)\/(.+)) ]]; then
  print_usage_and_exit_with_error
fi

user_or_org_name=${BASH_REMATCH[2]}
repo_name=${BASH_REMATCH[3]}
repositories_folder=$user_or_org_name
github_uri="https://api.github.com/repos/$user_or_org_name/$repo_name"
echo "Using uri '$github_uri' to verify if repository '$repo_name' for user" \
  "or organization '$user_or_org_name' exists"

json_response=$(curl -s $github_uri) 

if [[ $json_response =~ '"message": "Not Found"' ]]; then
  echo "Invalid GitHub user name, organization name and/or repository name" >&2
  exit 1
fi


if [[ ! (-d $repositories_folder) ]]; then
  echo "Creating directory './$repositories_folder' for repositories from" \
    "'$user_or_org_name'"
  mkdir "./$repositories_folder"
fi

echo "Changing current working directory to './$repositories_folder'"
cd "./$repositories_folder"

if [[ -d $repo_name ]]; then
  echo "Repository '$repo_name' already exists"
  exit 1
fi

echo "About to clone '$repo_name' from '$user_or_org_name'"
git clone git@github.com:$user_or_org_name/$repo_name.git
