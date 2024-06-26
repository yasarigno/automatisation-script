#!/bin/bash

# Define color codes using tput
bold=$(tput bold)
reset=$(tput sgr0)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)

# Ask for the folder location
read -p "${bold}Enter the path where you want to create the Makefile (press Enter for the current directory): ${reset}" file_location
file_location="${file_location:-$(pwd)}"

# Get the parent directory
parent_dir="${file_location%/}/"

# Check if the folder already exists
if [ -f "Makefile" ]; then
    echo -e "${red}Error: Makefile already exists in $parent_dir.${reset}"
    exit 1
fi

# Create Makefile
make_file="Makefile"

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

# Check if the folder already exists
if [ -f "Makefile" ]; then
    echo -e "${green}Makefile is created in $parent_dir.${reset}"
else
    echo -e "${red}Couldn't create Makefile.${reset}"
fi