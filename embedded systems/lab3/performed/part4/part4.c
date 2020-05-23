#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#define ZERO    0x3F;
#define ONE     0b10000110;
#define TWO     0b01011011;
#define THREE   0b01001111;
#define FOUR    0b01100110;
#define FIVE    0b01101101;
#define SIX     0b01111100;
#define SEVEN   0b10000111;
#define EIGHT   0b01111111;
#define NINE    0b01100111;

volatile sig_atomic_t stop;
void catchSIGINT(int signum){
    stop = 1;
}

int encoded_hex(int x)
{
    switch (x)
    {
    case 0:     return ZERO;
    case 1:     return ONE;
    case 2:     return TWO;
    case 3:     return THREE;
    case 4:     return FOUR;
    case 5:     return FIVE;
    case 6:     return SIX;
    case 7:     return SEVEN;
    case 8:     return EIGHT;
    case 9:     return NINE;
    default:    return ZERO;
    }
}

int main(int argc, char *argv[])
{
    int HEX_FD, LEDR_FD, SW_FD, KEY_FD;
    char HEX_buffer[13], LEDR_buffer[5], SW_buffer[5], KEY_buffer[2];
    HEX_buffer[12] = '\0';
    LEDR_buffer[4] = '\0';
    SW_buffer[4]   = '\0';
    KEY_buffer[1]  = '\0';

    if ((HEX_FD = open("/dev/HEX", O_WRONLY)) == -1)
	{
		printf("Error opening /dev/HEX: %s\n", strerror(errno));
		return -1;
	}
    if ((LEDR_FD = open("/dev/LEDR", O_WRONLY)) == -1)
	{
		printf("Error opening /dev/LEDR: %s\n", strerror(errno));
		return -1;
	}
    if ((SW_FD = open("/dev/SW", O_RDONLY)) == -1)
	{
		printf("Error opening /dev/SW: %s\n", strerror(errno));
		return -1;
	}
    if ((KEY_FD = open("/dev/KEY", O_RDONLY)) == -1)
	{
		printf("Error opening /dev/KEY: %s\n", strerror(errno));
		return -1;
	}

    signal(SIGINT, catchSIGINT);

    int count = 0;

    while(!stop)
    {
        read (KEY_FD, KEY_buffer, 1);
        if (KEY_buffer[0] != '0')
        {
            read(SW_FD, SW_buffer, 4);
            write(LEDR_FD, SW_buffer, 4);
            int local_count = 0;
            sscanf(SW_buffer, "%X", &local_count);
            count += local_count;

            int unit = encoded_hex(count % 10);
            int ten = encoded_hex((count % 100) / 10);
            int hundred = encoded_hex((count % 1000) / 100);
            int thousand = encoded_hex((count % 10000) / 1000);
            int ten_thou = encoded_hex((count % 100000) / 10000);
            int hund_thoud = encoded_hex((count % 1000000) / 100000);

            sprintf(&(HEX_buffer[0]), "%X", hund_thoud);
            sprintf(&(HEX_buffer[2]), "%X", ten_thou);
            sprintf(&(HEX_buffer[4]), "%X", thousand);
            sprintf(&(HEX_buffer[6]), "%X", hundred);
            sprintf(&(HEX_buffer[8]), "%X", ten);
            sprintf(&(HEX_buffer[10]), "%X", unit);

            write(HEX_FD, HEX_buffer, 12);

            printf("%s\n",HEX_buffer);
            printf("%d\n",count);
        }

        sleep(1);
    }

    close(HEX_FD);
    close(LEDR_FD);
    close(SW_FD);
    close(KEY_FD);

    return 0;

}

