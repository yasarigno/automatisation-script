#!/bin/bash

# Define color codes using tput
bold=$(tput bold)
reset=$(tput sgr0)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)

current_folder=$(pwd)

# Check if the correct number of positional arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: bash $0 <folder_name> <folder_location>"
    echo "Example: bash $0 \"Project Name\" \$pwd "
    exit 1
fi

# Check if GitHub authentication is already done
if ! gh auth status > /dev/null 2>&1; then
    echo "${bold}${red}Error: Not logged in to GitHub. Please run 'gh auth login' to authenticate.${reset}"
    exit 1
fi

# Get the folder name from the command line argument
folder_name=$1
folder_location=$2

# Get the authenticated GitHub username
github_username=$(gh auth status | grep 'Logged in to github.com account' | awk '{print $7}')

# Replace space by _ to name the repository
repo_name=$(echo "$folder_name" | tr ' ' '-')
repo_link="https://github.com/$github_username/$repo_name.git"

# Prompt the user for the description
read -p "${bold}Enter the description for the GitHub repository: " repo_description
echo

# Create a repository
echo "Creating the GitHub repository..."
gh repo create $repo_name --private --gitignore=Python --license="MIT" --description="$repo_description" 

# Check if the repository creation was successful
if [ $? -ne 0 ]; then
    echo "${bold}${red}Error: Failed to create GitHub repository '$repo_name'.${reset}"
    exit 1
fi

echo "The link of the repository:"
echo
echo $repo_link
echo

# cd into the folder
cd "$folder_location/$folder_name/" || exit

echo "The local path of the project:"
echo
echo $(pwd)

# git pull
git init
git pull $repo_link main

# git push
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin $repo_link
git push -u origin main

# Add tags (topics)
gh repo edit $repo_link --add-topic="python","mlops" 
# don't put spaces between commas

echo "${bold}${green}GitHub repository '$repo_name' created and local files pushed successfully.${reset}"