#!/bin/bash

# Write a shell script finder-app/finder.sh as described below:
# Accepts the following runtime arguments: the first argument is a path to a directory on the filesystem, referred to below as filesdir; the second argument is a text string which will be searched within these files, referred to below as searchstr
# Exits with return value 1 error and print statements if any of the parameters above were not specified
# Exits with return value 1 error and print statements if filesdir does not represent a directory on the filesystem
# Prints a message "The number of files are X and the number of matching lines are Y" where X is the number of files in the directory and all subdirectories and Y is the number of matching lines found in respective files, where a matching line refers to a line which contains searchstr (and may also contain additional content).
# Example invocation:
#        finder.sh /tmp/aesd/assignment1 linux

# Exits with return value 1 error and print statements if any of the parameters above were not specified
if [ -z $1 ] || [ -z $2 ]
then
    echo "first or second arg is empty"
    exit 1
fi

# Exits with return value 1 error and print statements if filesdir does not represent a directory on the filesystem
if [ ! -d $1 ]
then
  echo "$1 does not exist."
  exit 1
fi

num_files=$(grep $2 -r -c $1 | wc -l)
num_lines=$(grep $2 -r $1 | wc -l)


echo "The number of files are $num_files and the number of matching lines are $num_lines"

exit 0
