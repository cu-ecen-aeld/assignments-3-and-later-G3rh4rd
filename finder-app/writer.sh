#!/bin/bash

# Write a shell script finder-app/writer.sh as described below
# Accepts the following arguments: the first argument is a full path to a file (including filename) on the filesystem, referred to below as writefile; the second argument is a text string which will be written within this file, referred to below as writestr
# Exits with value 1 error and print statements if any of the arguments above were not specified
# Creates a new file with name and path writefile with content writestr, overwriting any existing file and creating the path if it doesn’t exist. Exits with value 1 and error print statement if the file could not be created.
# Example:
#        writer.sh /tmp/aesd/assignment1/sample.txt ios
# Creates file:
#     /tmp/aesd/assignment1/sample.txt
#             With content:
#             ios


# Exits with value 1 error and print statements if any of the arguments above were not specified
if [ -z $1 ] || [ -z $2 ]
then
    echo "first or second arg is empty"
    exit 1
fi

dir_name=$(dirname "$1")
file_name=$(basename "$2")


# Creates a new file with name and path writefile with content writestr, overwriting any existing file and creating the path if it doesn’t exist. 
create_code=$(mkdir -p $dir_name && touch $1)

# Exits with value 1 and error print statement if the file could not be created.
if [[ $create_code -ne 0 ]]
then
    echo "file could not be created"
    exit 1
fi

echo $2 > $1

exit 0