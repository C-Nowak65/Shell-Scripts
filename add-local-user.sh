#!/bin/bash

#This script is used to create a user with a username (login), the users name, and an initial password. This will then create the user and display the  username, password, and hostname.

# Make sure the script is being executed with superuser privileges. If is not it should exit with a code of 1.
if [[ "${UID}" != "0" ]]
then
    echo "This script must be run with superuser priveleges!"
    exit 1
fi

# Get the username (login)
read -p "Enter username to create: " USERNAME

# Get the real name (contents for the description field)
read -p "Enter the name of the user or application that is going to use this account: " CONTENT

# Get the password
read -p "Enter password: " PASSWORD

#Create the user with the password
useradd -c "$CONTENT" -m $USERNAME

# Check to see if the useradd command succeeded
if [[ "${?}" -eq 0 ]]
then

# Set the password
    echo "$USERNAME:$PASSWORD" | chpasswd


    

    echo
    echo "User: ${USERNAME}"
    echo "Name: ${CONTENT}"
    echo "Password: ${PASSWORD}"
    echo "Hostname: $(hostname)"

    # Set the shell prompt for the new user
    su - $USERNAME -c 'echo "PS1=\"\u@\h:\w\$ \"" >> ~/.bashrc'
   
else
    echo "Failed to create User ${USERNAME}."
fi

passwd -e "$USERNAME"

