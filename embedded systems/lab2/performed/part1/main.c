#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include "../address_map_arm.h"

/* Prototypes for functions used to access physical memory addresses */
int open_physical (int);
void * map_physical (int, unsigned int, unsigned int);
void close_physical (int);
int unmap_physical (void *, unsigned int);

int i = 0b00000100;
int n = 0b01010100;
int t = 0b01111000;
int e = 0b01111001;
int l = 0b00111000; 
int space = 0;
int S = 0b01101101; 
int o = 0b01011100; 
int C = 0b00111001; 
int F = 0b01110001; 
int P = 0b01110011; 
int G = 0b01111101; 
int A = 0b01110111;

int main(void)
{
    int fd = -1; // used to open /dev/mem
    void *LW_virtual; // physical addresses for light-weight bridge

    // Create virtual memory access to the FPGA light-weight bridge
    if ((fd = open_physical (fd)) == -1)
        return (-1);
    if (!(LW_virtual = map_physical (fd, LW_BRIDGE_BASE, LW_BRIDGE_SPAN)))
        return (-1);
    
    volatile int* HEX0_3  = (int*) (LW_virtual+HEX3_HEX0_BASE);
    volatile int* HEX4_5  = (int*) (LW_virtual + HEX5_HEX4_BASE);
    volatile int* KEY  = (int*) (LW_virtual + KEY_BASE);
    *(KEY+3) = 0xF;
    *(KEY+2) = 0xF;

    int array_string[] = {i,n,t,e,l,space,S,o,C,space,F,P,G,A,space};
    int position = 0;
    int enable = 1;
    printf("start\n");

    while(1)
    {
        if(*(KEY+3) > 0)
        {
            enable = !enable;
            *(KEY+3) = 0xF;
            printf("key pressed, enable: %d\n", enable);
        }

        if (enable)
        {
            *HEX4_5 = (array_string[position]<<8) + array_string[(position+1)%15];
            *HEX0_3 = (array_string[(position+2)%15]<<24) + (array_string[(position+3)%15]<<16) + (array_string[(position+4)%15]<<8) + array_string[(position+5)%15];
            position = (position+1) % 15;   
            sleep(1);
        }
    }

    unmap_physical (LW_virtual, LW_BRIDGE_SPAN);
    close_physical (fd);
    return 0;
}


int open_physical (int fd)
{
    if (fd == -1) // check if already open
    if ((fd = open( "/dev/mem", (O_RDWR | O_SYNC))) == -1)
    {
        printf ("ERROR: could not open \"/dev/mem\"...\n");
        return (-1);
    }
    return fd;
}

void close_physical (int fd)
{
    close (fd);
}

void* map_physical(int fd, unsigned int base, unsigned int span)
{
    void *virtual_base;
    // Get a mapping from physical addresses to virtual addresses
    virtual_base = mmap (NULL, span, (PROT_READ | PROT_WRITE), MAP_SHARED,
    fd, base);
    if (virtual_base == MAP_FAILED)
    {
        printf ("ERROR: mmap() failed...\n");
        close (fd);
        return (NULL);
    }
    return virtual_base;
}

int unmap_physical(void * virtual_base, unsigned int span)
{
    if (munmap (virtual_base, span) != 0)
    {
        printf ("ERROR: munmap() failed...\n");
        return (-1);
    }
    return 0;
}