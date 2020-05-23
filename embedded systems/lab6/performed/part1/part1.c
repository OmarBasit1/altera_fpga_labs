#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#define video_BYTES 8 // number of characters to read from /dev/video

int screen_x, screen_y;

int main(int argc, char *argv[])
{
    int video_FD; // file descriptor
    char buffer[video_BYTES]; // buffer for data read from /dev/video
    char command[64]; // buffer for commands written to /dev/video
    int x, y;

    // Open the character device driver
    if ((video_FD = open("/dev/video", O_RDWR)) == -1)
    {
        printf("Error opening /dev/video: %s\n", strerror(errno));
        return -1;
    }

    // Set screen_x and screen_y by reading from the driver
    if (read(video_FD, buffer, video_BYTES) > 0)
    {
        sscanf(buffer, "%d %d", &x, &y);
    }
    else
    {
        close (video_FD);
        return -1;
    }
 
    // Use pixel commands to color some pixels on the screen
    int i,j;

    for(i=0; i<x; i++)
    {
        for (j=0; j<y; j++)
        {
            sprintf(command, "pixel %d,%d 0xaaaa", i, j);
            write(video_FD, command, strlen(command));
        }
    }

    close (video_FD);
    return 0;
}