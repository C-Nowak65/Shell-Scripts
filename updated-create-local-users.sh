#!/bin/bash

# A script that creates user accounts, sets passwords, and handles errors if the user creation fails.
# Checks whether the script is being executed with superuser privileges.
# Verifies at least one argument (username) is provided. If not, it displays usage instructions and exits.
# Assigns the first argument to the USERNAME variable and collects any additional arguments as COMMENT.
# Generates a random password for the user.
# Creates the user account with the specified comment.
# If the user account creation is successful, it sets the generated password for the user.
# If setting the password is successful, it displays user information, including the username, comment, generated password, and hostname.
# It forces the user to change the password on the first login.
# If the user account creation fails, it displays an error message.

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" != "0" ]]
then
    echo "This script must be run with superuser privileges."
    exit 1
fi

# If the user does not supply at least one argument, then give them help.
if [[ $# -lt 1 ]]
then
    echo "Usage: $0 username1 [username2, username3 ...]"
    echo "Creates user accounts for the given usernames."
    exit 1
fi

# The first parameter is the user name.
USERNAME="$1"
shift

# The rest of the parameters are for the account comments.
COMMENT="$@"

# Generate a password.
PASSWORD=$(date +%s%N | sha256sum | head -c 12)

# Create the users with the password.
useradd -c "$COMMENT" -m "$USERNAME"

# Check to see if the useradd command succeeded.
if [[ "${?}" -eq 0 ]]
then

# Set the password.
    echo "$USERNAME:$PASSWORD" | chpasswd

# Check yo see if the passwd command succeeded.
    if [[ "${?}" -eq 0 ]]
    then

# Display the username, password, and the host where the user was created.
        echo
        echo "User: ${USERNAME}"
        echo "Comment: ${COMMENT}"
        echo "Password: ${PASSWORD}"
        echo "Hostname: $(hostname)"

        # Force password on first login.
        passwd -e "$USERNAME"
    fi
elif [[ "${?}" -eq 1 ]]
then
    echo "Failed to create user."

fi
