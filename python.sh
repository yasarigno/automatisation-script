#!/bin/bash

# Define color codes using tput
bold=$(tput bold)
reset=$(tput sgr0)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)

# Ask for the folder location
read -p "${bold}Enter the path where you want to create the folder (press Enter for the current directory): ${reset}" folder_location
folder_location="${folder_location:-$(pwd)}"

# Ask for the folder name
read -p "${bold}Enter the name of the folder: ${reset}" folder_name
echo

# Get the parent directory
parent_dir="${folder_location%/}/"

# Check if the folder already exists
if [ -d "$parent_dir/$folder_name" ]; then
    echo -e "${red}Error: Folder '$folder_name' already exists in $parent_dir.${reset}"
    exit 1
fi

# Create the new folder
new_folder="$parent_dir/$folder_name"
mkdir "$new_folder"

# Check if the folder creation was successful
if [ $? -ne 0 ]; then 
	# ici $? veut dire "ça va?". Si "true" ça donne 0.
    echo "${red}Error: Failed to create folder '$folder_name' in $parent_dir.${reset}"
    exit 1
fi

# Create folders for the project
mkdir "$new_folder/src"
touch "$new_folder/src/__init__.py"
mkdir "$new_folder/docs"
touch "$new_folder/docs/conf.py"
mkdir "$new_folder/content"
touch "$new_folder/content/README.md"

# Create README.md file
readme_file="$new_folder/README.md"
cat <<EOF > "$readme_file"
# $folder_name

## Overview

<div align="center">
<img src="./content/overview.png" alt="overview" height=400px/>
</div>

## Requirements

To use the scripts, these need to be installed:
- pip3
- pylint
- gh (github cli)
- git

## Setup

You can either use Makefile 

\`\`\`bash
make venv
make install
make lint
make clean
\`\`\`

(Note that \`\`make clean\`\` removes the virtual environment.)

or do the following:

To set up a virtual environment and install dependencies, run the following commands:

1. Create a virtual environment

\`\`\`bash
python3 -m venv ./venv
source ./venv/bin/activate
\`\`\`

2. Install the dependencies

\`\`\`bash
pip install --no-cache-dir -r requirements.txt
\`\`\`

Note: You can delete the unnecessary folders via

\`\`\`bash
rm -rf 
\`\`\`

<div style="text-align:center; margin-top: 40px;">

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/frattini)

</div>

EOF

# Create main.py file
main_file="$new_folder/main.py"
cat <<EOF > "$main_file"
# Import libraries


EOF

# Create main.py file
make_file="$new_folder/Makefile"
cat << 'EOF' > "$make_file"
# Makefile

VENV_NAME := venv
PYTHON := python3
VENV := $(VENV_NAME)/bin

venv:
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VENV_NAME)
	@echo "Virtual environment created in $(VENV_NAME)."
	@echo
	@echo "ATTENTION: Activate the virtual environment using:"
	@echo
	@echo "source ./$(VENV)/activate"
	@echo

install:
	@pip3 install --upgrade pip
	@pip3 install -r requirements.txt

black:
	@black .

lint: 
	@pylint --disable=R,C *

clean:
	@echo "ATTENTION: Don't forget to deactivate the virtual environment."
	@echo "Cleaning up..."
	@rm -rf $(VENV_NAME)
	@echo "Cleanup complete."

create-dockerfile:
	@if [ -e "Dockerfile" ]; then \
	    echo "Dockerfile already exists. Aborting."; \
	else \
	    echo "Creating Dockerfile..."; \
	    echo "# Use an official Python runtime as a parent image" > Dockerfile; \
	    echo "FROM python:3.8-slim" >> Dockerfile; \
	    echo "" >> Dockerfile; \
	    echo "# Set the working directory to /app" >> Dockerfile; \
	    echo "WORKDIR /app" >> Dockerfile; \
	    echo "" >> Dockerfile; \
	    echo "# Copy the current directory contents into the container at /app" >> Dockerfile; \
	    echo "COPY . /app" >> Dockerfile; \
	    echo "" >> Dockerfile; \
	    echo "# Install any needed packages specified in requirements.txt" >> Dockerfile; \
	    echo "RUN pip install --no-cache-dir -r requirements.txt" >> Dockerfile; \
	    echo "" >> Dockerfile; \
	    echo "# Make port 80 available to the world outside this container" >> Dockerfile; \
	    echo "EXPOSE 80" >> Dockerfile; \
	    echo "" >> Dockerfile; \
	    echo "# Run main.py when the container launches" >> Dockerfile; \
	    echo "CMD [\"python\", \"main.py\"]" >> Dockerfile; \
	    echo "Dockerfile created successfully."; \
	fi
EOF

# Create requirements file
touch "$new_folder/requirements.txt"

# Create Dockerfile
docker_file="$new_folder/Dockerfile"
cat << 'EOF' > "$docker_file"
# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Run main.py when the container launches
CMD ["python", "main.py"]

EOF

# Done
echo "${green}Folder '$folder_name' created successfully in $parent_dir.${reset}"
echo

# Ask for the creation of a repo
read -p "${bold}Do you want to create the GitHub repo? (y/n): " answer

if [ "$answer" = "y" ]; then
    # Run the create_github_repo.sh script
    bash github.sh "$folder_name" "$folder_location"
    echo "Creating a GitHub repo..."
else
    echo "${bold}GitHub repository creation aborted.${reset}"
fi