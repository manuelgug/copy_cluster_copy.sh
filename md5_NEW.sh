#!/bin/bash

# check if the user provided correct number of arguments
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 DIR LOCAL_DESTINATION [SERVER_DESTINATION]" #user@server://path NEEDS TO BE TESTED ON CLUSTER!!
    exit 1
fi

# set the arguments to variables
DIR=$1
LOCAL_DESTINATION=$2
if [ "$#" -eq 3 ]; then
    SERVER_DESTINATION=$3
fi

# create an md5sum of the directory on the local machine
LOCAL_MD5=$(find $DIR -type f -exec md5sum {} \; | sort -k 2 | md5sum)

#echo "$LOCAL_MD5"

# check if the server LOCAL_DESTINATION is provided
if [ "$#" -eq 3 ]; then
    # transfer the directory to the server using scp
    scp -r $DIR $SERVER_DESTINATION

    # create an md5sum of the directory on the server
    SERVER_MD5=$(ssh $SERVER_DESTINATION "find $DIR -type f -exec md5sum {} \; | sort -k 2 | md5sum")
    
    #echo "$SERVER_MD5"

    # compare the two md5sums and print the appropriate message
    if [ "$LOCAL_MD5" == "$SERVER_MD5" ]; then
        echo -e "\nDIRECTORY \"${DIR}\" COPIED SUCCESSFULLY.\n"
    else
        echo -e "\nFAILED. TRY AGAIN.\n"
    fi
else
    # copy the directory to the LOCAL_DESTINATION
    cp -r $DIR $LOCAL_DESTINATION

    # create an md5sum of the directory at the LOCAL_DESTINATION
    cd $LOCAL_DESTINATION
    LOCAL_DESTINATION_MD5=$(find $DIR -type f -exec md5sum {} \; | sort -k 2 | md5sum)
    
    #echo "$LOCAL_DESTINATION_MD5"

    # compare the two md5sums and print the appropriate message
    if [ "$LOCAL_MD5" == "$LOCAL_DESTINATION_MD5" ]; then
        echo -e "\nDIRECTORY \"${DIR}\" COPIED SUCCESSFULLY.\n"
    else
        echo -e "\nFAILED. TRY AGAIN.\n"
    fi
fi
