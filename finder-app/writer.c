/*

Write a C application “writer” (finder-app/writer.c)  which can be used as an alternative to the “writer.sh” test script created in assignment1 and using File IO as described in LSP chapter 2.  See the Assignment 1 requirements for the writer.sh test script and these additional instructions:

One difference from the write.sh instructions in Assignment 1:  You do not need to make your "writer" utility create directories which do not exist.  You can assume the directory is created by the caller.

Setup syslog logging for your utility using the LOG_USER facility.

Use the syslog capability to write a message “Writing <string> to <file>” where <string> is the text string written to file (second argument) and <file> is the file created by the script.  This should be written with LOG_DEBUG level.

Use the syslog capability to log any unexpected errors with LOG_ERR level.

*/

/*

1. Accepts the following arguments: the first argument is a full path to a file (including filename) on the filesystem, referred to below as writefile; the second argument is a text string which will be written within this file, referred to below as writestr
2. Exits with value 1 error and print statements if any of the arguments above were not specified
3. Creates a new file with name and path writefile with content writestr, overwriting any existing file. Exits with value 1 and error print statement if the file could not be created.
    Example:
        writer.sh /tmp/aesd/assignment1/sample.txt ios
    Creates file:
        /tmp/aesd/assignment1/sample.txt
                With content:
                ios

4. Setup syslog logging for your utility using the LOG_USER facility.
5. Use the syslog capability to write a message “Writing <string> to <file>” where <string> is the text string written to file (second argument) and <file> is the file created by the script.  This should be written with LOG_DEBUG level.
6. Use the syslog capability to log any unexpected errors with LOG_ERR level.

*/
#include <stdio.h>
#include <syslog.h>
#include <stdbool.h>

int main(int argc, char **argv) {
    openlog("writer_log", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_USER);

    if(argc != 3) {
        // Exits with value 1 error and print statements if any of the arguments above were not specified
        printf("You have entered too less arguments: %d. Expected 2 arguments.\n", argc);
        syslog(LOG_ERR, "You have entered too less arguments: %d. Expected 2 arguments.\n", argc);
        return 1;
    }


    char *writefile = argv[1];
    char *writestr = argv[2];


    if((writefile == NULL || writestr == NULL)) {
        printf("Invalid arguments.\n");
        syslog(LOG_ERR, "Invalid arguments.\n");
        return 1;
    }

    // Create a file
    FILE *fptr = fopen(writefile, "w");

    if(fptr == NULL) {
        printf("Cannot create file.\n");
        syslog(LOG_ERR, "Cannot create file.\n");
        return 1;
    }

    // Write some text to the file
    if(fptr != NULL && fprintf(fptr, writestr) == -1) {
        printf("Cannot write to file.\n");
        syslog(LOG_ERR, "Cannot write to file.\n");
        return 1;
    }

    // Close the file
    if((fptr != NULL && fclose(fptr) == -1)) {
        printf("Cannot close file.\n");
        syslog(LOG_ERR, "Cannot close file.\n");
        return 1;
    }

    printf("Writing %s to %s\n", writestr, writefile);
    syslog(LOG_DEBUG, "Writing %s to %s\n", writestr, writefile);

    closelog();

    return 0;
}