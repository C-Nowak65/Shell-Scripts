#!/bin/bash

# This script allows the disabling, deleting, and archiving of a local user.

#Variables
ARCHIVE_DIR="/ARCHIVE_DIR"

#  # Display the usage and exit.

usage() {
    echo "Usage: ${0} [-dra] USER" >&2
    echo "Disable a local linux account." >&2
    echo "  -d Deletes accounts instead of disabling them." >&2
    echo "  -r Removes the home directory associated with the account(s)." >&2
    echo "  -a Creates an archive of the home directory associated with the accounts." >&2
    exit 1
}

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
    echo "Please run with sudo or as root." >&2
    exit 1
fi

# Parse the options.
while getopts dra OPTION
do
    case ${OPTION} in
        d) DELETE_USER='true' ;;
        r) REMOVE_OPTION='true' ;;
        a) ARCHIVE='true' ;;
        ?) usage ;;
    esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

# If the user doesn't supply at least one argument, give them help.
if [[ "${#}" -lt 1 ]]
then
    usage
fi

# Loop through all the usernames supplied as arguments.
for USER in "${@}"
do
    echo "Processing User: ${USER}" 
    
    # Retrieve and check the UID of the current USER in the loop.
    USER_ID=$(id -u "$USER" 2>/dev/null)

    # Skip processing if the user does not exist or an error occurred.
    if [[ $? -ne 0 ]]
    then
        echo "User ${USER} does not exist. Skipping."
        continue
    fi

    # Make sure the UID of the user is at least 1000.
    if [[ "$USER_ID" -lt 1000 ]]
    then
        echo "${USER} has a UID of ${USER_ID} and cannot be modified." >&2
        continue
    fi

    # Create an archive if requested to do so.
    if [[ "${ARCHIVE}" = 'true' ]]
    then
        if [[ ! -d "$ARCHIVE_DIR" ]]
        then
            echo "Archive directory ${ARCHIVE_DIR} does not exist. Creating it now."
            mkdir -p "$ARCHIVE_DIR"
            chmod 700 "$ARCHIVE_DIR"
            
            if [[ $? -eq 0 ]]
            then
                echo "${ARCHIVE_DIR} archive directory was created successfully."
            else
                echo "Failed to create ${ARCHIVE_DIR} archive directory. Please check your permissions." >&2
                exit 1
            fi

        else
            echo "Archive directory exists. Proceeding with archiving..."
        fi
        

# Make sure the ARCHIVE_DIR directory exists.

# Archive the user's home directory and move it into the ARCHIVE_DIR

# Delete the user.

# Check to see if the userdel command succeeded.

# We don't want to tell the user that an account was deleted when it hasn't been.

# Check to see if the chage command succeeded.

# We don't want to tell the user that an account was disabled when it hasn't been.
