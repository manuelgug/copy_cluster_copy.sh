#!/bin/bash

# check if the user provided the correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [SOURCE] [DESTINATION]"
    exit 1
fi

# set the arguments to variables
SOURCE=$1
DESTINATION=$2

# Prompt the user for the password
read -s -p "Enter password: " PASSWORD
echo

# Create the askpass script
ASKPASS_SCRIPT=$(mktemp)
cat <<EOF > "$ASKPASS_SCRIPT"
#!/bin/bash
echo "$PASSWORD"
EOF
chmod +x "$ASKPASS_SCRIPT"

# Set the SSH_ASKPASS environment variable to the askpass script
export SSH_ASKPASS="$ASKPASS_SCRIPT"

# Disable strict host key checking for ssh
export SSH_OPTIONS="-o StrictHostKeyChecking=no"

# check if the transfer is local to cluster or cluster to local
if [[ "$DESTINATION" == *":"* ]]; then #local to cluster

    # create an md5sum of the directory on the local machine
    LOCAL_MD5=$(find "$SOURCE" -type f -exec md5sum {} \; | sort -k 2 | md5sum)

    SERVER="${DESTINATION%%:*}"
    SERVER_DESTINATION=$(echo "$DESTINATION" | sed 's/.*://')
    
    # transfer the directory to the server using scp
    SSH_ASKPASS="$ASKPASS_SCRIPT" setsid scp $SSH_OPTIONS -r "$SOURCE" "$DESTINATION" < /dev/null

    # create an md5sum of the directory on the server
    SERVER_MD5=$(SSH_ASKPASS="$ASKPASS_SCRIPT" setsid ssh $SSH_OPTIONS -A "$SERVER" "cd '$SERVER_DESTINATION' && find '$SOURCE' -type f -exec md5sum {} \; | sort -k 2 | md5sum")
    
    echo -e "\nLocal (source) MD5 is $LOCAL_MD5"
    echo -e "Cluster (destination) MD5 is $SERVER_MD5"

    # compare the two md5sums and print the appropriate message
    if [ "$LOCAL_MD5" == "$SERVER_MD5" ]; then
        echo -e "\nDIRECTORY \"${SOURCE}\" COPIED SUCCESSFULLY.\n"
    else
        echo -e "\nFAILED. TRY AGAIN.\n"
    fi
else #cluster to local
    
    SERVER="${SOURCE%%:*}"
    SERVER_SOURCE=$(echo "$SOURCE" | sed 's/.*://')
    
    # transfer the directory from the server using scp
    SSH_ASKPASS="$ASKPASS_SCRIPT" setsid scp $SSH_OPTIONS -r "$SOURCE" "$DESTINATION" < /dev/null
    
    # create an md5sum of the directory on the server
    SERVER_MD5=$(SSH_ASKPASS="$ASKPASS_SCRIPT" setsid ssh $SSH_OPTIONS -A "$SERVER" "cd \$(dirname \"$SERVER_SOURCE\") && find \$(basename \"$SERVER_SOURCE\") -type f -exec md5sum {} \; | sort -k 2 | md5sum")
    
    # create an md5sum of the directory on the local machine
    LOCAL_MD5=$(find "$(basename "$SERVER_SOURCE")" -type f -exec md5sum {} \; | sort -k 2 | md5sum)
    
    echo -e "\nCluster (source) MD5 is $SERVER_MD5"
    echo -e "Local (destination) MD5 is $LOCAL_MD5"
    
    # compare the two md5sums and print the appropriate message
    if [ "$LOCAL_MD5" == "$SERVER_MD5" ]; then
        echo -e "\nDIRECTORY \"${SOURCE}\" COPIED SUCCESSFULLY.\n"
    else
        echo -e "\nFAILED. TRY AGAIN.\n"
    fi

rm -f "$ASKPASS_SCRIPT"

fi


