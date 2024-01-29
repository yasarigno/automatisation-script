#!/bin/bash

# Define color codes using tput
bold=$(tput bold)
reset=$(tput sgr0)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
red=$(tput setaf 1)

# Define the file to store notes
#NOTES_FILE="/notes.txt"

# Check if the notes.txt file exists, if not, create it
if [ ! -f "$NOTES_FILE" ]; then
    echo "${red}ERROR: notes.txt doesn't exist. ${reset}"
    exit 0
fi

# Display usage instructions
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --add      Add a new note"
    echo "  -v, --view     View all notes"
    echo "  -h, --help     Display this help message"
}

# Add a new note
add_note() {
    # nano $NOTES_FILE
    echo "$@" >> "$NOTES_FILE"
    echo "Note added successfully."
}

# View all notes
view_notes() {
    if [ -s "$NOTES_FILE" ]; then
        echo 
        cat "$NOTES_FILE"
    else
        echo "You have no notes yet."
    fi
}

# Main script logic
case "$1" in
    -a|--add)
        shift
        add_note "$@"
        ;;
    -v|--view)
        view_notes
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Invalid option. Use -h or --help for usage instructions."
        exit 1
        ;;
esac

exit 0

# To add a note: ./notes.sh -a "Your note here"
# To view all notes: ./notes.sh -v
# To get help: ./notes.sh -h