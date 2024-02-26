#!/bin/bash

# This script creates a new user on the local system.
# You must apply a username as an argument to the script.
# Optionally, you can also provide a comment for the account as an argument.
# A password will be automatically generated for the account.
# The username, password, and host for the account will be displayed.

# Make sure the script is run with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
    echo "Please run with sudo or as root." >&2
    exit 1
fi

# If the user doesn't supply at least one argument, then give them help.
if [[ "${#}" -lt 1 ]]
then
    echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
    echo "Create an account on the local system with the name of USER_NAME and a commends field of COMMEND." >&2
    exit 1
fi

# The first parameter is the username.
USER_NAME="${1}"

# The rest of the parameters are comments for the account.
shift
COMMENT="${@}"

#Generate a password.
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# Check if the user already exists.
if id "${USER_NAME}" &>/dev/null; then
    echo "User ${USER_NAME} already exists." >&2
    exit 1
fi

#Create a user with the password.
useradd -c "${COMMENT}" -m "${USER_NAME}" 2>&1

# Check to see if the useradd command succeeded.
# We don't want to tell the user that an account was created when it was not.
if [[ "${?}" -ne 0 ]]
then
    echo "The account could not be created." >&2
    exit 1
fi

# Set the password.
echo "${USER_NAME}:${PASSWORD}" | chpasswd &> /dev/null

# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
    echo "The password could not be set." >&2
    exit 1
fi

# Force password change on first login.
passwd -e "${USER_NAME}" &> /dev/null

# Display the username, password, and the host where the user was created.
echo 'username:'
echo "${USER_NAME}"
echo
echo 'password:'
echo "${PASSWORD}"
echo
echo 'host:'
echo "${HOSTNAME}"
exit 0
