#!/bin/bash

# Define global variables
ARCHIVE_DIR="/ARCHIVE_DIR"

# Display usage and exit
usage() {
    echo "Usage: ${0} [-dra] USER" >&2
    echo "-d Deletes accounts instead of disabling them."
    echo "-r Removes the home directory associated with the account(s)."
    echo "-a Creates an archive of the home directory associated with the accounts."
    exit 1
}

# Ensure the script is executed with superuser privileges
if [[ "${UID}" -ne 0 ]]; then
    echo "Please run with sudo or as root." >&2
    exit 1
fi

# Parse options
while getopts dra OPTION; do
    case ${OPTION} in
        d) DELETE_USER='true'; ACTION_REQUESTED='true' ;;
        r) REMOVE_OPTION='true'; ACTION_REQUESTED='true' ;;
        a) ARCHIVE='true'; ACTION_REQUESTED='true' ;;
        ?) usage ;;
    esac
done

shift "$(( OPTIND - 1 ))"

# Display usage if no user is provided
if [[ "${#}" -lt 1 ]]; then
    usage
fi

# Process users
for USER in "${@}"; do
    echo "Processing User: ${USER}"
    
    # Retrieve and check the UID
    USER_ID=$(id -u "$USER" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "User ${USER} does not exist. Skipping."
        continue
    fi

    if [[ "$USER_ID" -lt 1000 ]]; then
        echo "${USER} has a UID of ${USER_ID} and cannot be modified." >&2
        continue
    fi

    # Handle archiving
    if [[ "${ARCHIVE}" = 'true' ]]; then
        if [[ ! -d "$ARCHIVE_DIR" ]]; then
            echo "Archive directory ${ARCHIVE_DIR} does not exist. Creating it now."
            mkdir -p "$ARCHIVE_DIR"
            chmod 700 "$ARCHIVE_DIR"
        
            if [[ $? -eq 0 ]]; then
                echo "${ARCHIVE_DIR} archive directory was created successfully."
            else
                echo "Failed to create ${ARCHIVE_DIR}. Please check your permissions." >&2
                continue
            fi
        else
            echo "Archive directory exists. Proceeding with archiving..."
        fi
    
        # Define the archive file name
        ARCHIVE_FILE="${ARCHIVE_DIR}/${USER}-$(date +%Y%m%d-%H%M%S).tar.gz"
        # Define the user's home directory
        HOME_DIR="/home/${USER}"
    
        if [[ -d "$HOME_DIR" ]]; then
            # Use tar command to archive the home directory
            tar -czf "$ARCHIVE_FILE" "$HOME_DIR" &> /dev/null
            if [[ $? -eq 0 ]]; then
                echo "Successfully archived ${USER}'s home directory to ${ARCHIVE_FILE}."
            else
                echo "Failed to archive ${USER}'s home directory." >&2
                continue
            fi
        else
            echo "Home directory for ${USER} does not exist. Skipping." >&2
        fi
    fi


    # Handle deletion
    if [[ "${DELETE_USER}" = 'true' ]]; then
        OPTION=''
        if [[ "${REMOVE_OPTION}" = 'true' ]]; then
            OPTION='-r'
        fi
        if userdel ${OPTION} "${USER}"; then
            echo "Successfully deleted ${USER}."
        else
            echo "Failed to delete ${USER}." >&2
            continue
        fi
    fi

    # Default action: Disable the account if no other action was requested
    if [[ "${ACTION_REQUESTED}" != 'true' ]]; then
        if chage --expiredate 0 "${USER}"; then
            echo "Successfully disabled ${USER}."
        else
            echo "Failed to disable ${USER}. Please check if the user exists and you have the correct permissions." >&2
        fi
    fi
done
