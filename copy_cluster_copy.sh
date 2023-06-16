#!/bin/bash

# check if the user provided correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 [SOURCE] [DESTINATION]"
    exit 1
fi

# set the arguments to variables
SOURCE=$1
DESTINATION=$2

# check if the transfer is local to cluster or cluster to local
if [[ "$DESTINATION" == *":"* ]]; then #local to cluster

    # create an md5sum of the directory on the local machine
    LOCAL_MD5=$(find $SOURCE -type f -exec md5sum {} \; | sort -k 2 | md5sum)

    SERVER="${DESTINATION%%:*}"
    SERVER_DESTINATION=$(echo "$DESTINATION" | sed 's/.*://')
    
    # transfer the directory to the server using scp
    scp -r $SOURCE $DESTINATION

    # create an md5sum of the directory on the server
    SERVER_MD5=$(ssh $SERVER "cd $SERVER_DESTINATION && find $SOURCE -type f -exec md5sum {} \; | sort -k 2 | md5sum")
    
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
    
    # transfer the directory to the server using scp
    scp -r $SOURCE $DESTINATION
    
    # create an md5sum of the directory on the server
    SERVER_MD5=$(ssh $SERVER "cd "$(dirname "$SERVER_SOURCE")" && find "$(basename "$SERVER_SOURCE")" -type f -exec md5sum {} \; | sort -k 2 | md5sum")
    
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
fi

