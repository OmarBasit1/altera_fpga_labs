#include "../address_map_arm.h"
#include "audio.h"
#include "physical.h"
#include <stdint.h>
#include <stdio.h>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

volatile int *AUDIO_CONTROL;
volatile int *AUDIO_FIFO_SPACE;
volatile int *AUDIO_LEFTDATA;
volatile int *AUDIO_RIGHTDATA;

void *LW_BRIDGE_ptr;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void init_audio();
void audio_clear_write_fifo();
void audio_write_left(int);
void audio_write_right(int);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char *argv[])
{
    int SIZE = (int) 1000*8000/1000;

    int fd = -1;
    if ((fd = open_physical(fd)) == -1)
        return -1;
    if (!(LW_BRIDGE_ptr = map_physical(fd, LW_BRIDGE_BASE, LW_BRIDGE_SPAN)))
        return -1;

    AUDIO_CONTROL       = (int *) (LW_BRIDGE_ptr + AUDIO_BASE);
    AUDIO_FIFO_SPACE    = (int *) (AUDIO_CONTROL + FIFOSPACE);
    AUDIO_LEFTDATA      = (int *) (AUDIO_CONTROL + LDATA);
    AUDIO_RIGHTDATA     = (int *) (AUDIO_CONTROL + RDATA);

    int buffer[SIZE], temp[SIZE]; 

    int i;
    for (i = 0; i < SIZE; i++)
        buffer[i] = 0;

    if (argv[0][0] == '1')
    {
        generate_sine(1000, 261.626, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][1] == '1')
    {
        generate_sine(1000, 277.183, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][2] == '1')
    {
        generate_sine(1000, 293.665, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][3] == '1')
    {
        generate_sine(1000, 311.127, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][4] == '1')
    {
        generate_sine(1000, 329.628, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][5] == '1')
    {
        generate_sine(1000, 349.228, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][6] == '1')
    {
        generate_sine(1000, 369.994, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][7] == '1')
    {
        generate_sine(1000, 391.995, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][8] == '1')
    {
        generate_sine(1000, 415.305, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][9] == '1')
    {
        generate_sine(1000, 440.000, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][10] == '1')
    {
        generate_sine(1000, 466.164, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][11] == '1')
    {
        generate_sine(1000, 493.883, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }
    if(argv[0][12] == '1')
    {
        generate_sine(1000, 523.251, 0x7FFFFFF, temp);
        add_two_sine(buffer, temp, 1000);
    }

    init_audio();

    for (i = 0; i < SIZE; i++)
    {
        audio_write_left(buffer[i]);
        audio_write_right(buffer[i]);
    }

    close_physical(fd);
    unmap_physical(LW_BRIDGE_ptr, LW_BRIDGE_SPAN);
    return 0;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void init_audio()
{
    *AUDIO_CONTROL =    (0 << 0) |      //RE
                        (0 << 1);       //CE

    audio_clear_write_fifo();
    
}

void audio_clear_write_fifo()
{
    *AUDIO_CONTROL = (*AUDIO_CONTROL) | (1 << 3);

    *AUDIO_CONTROL = (*AUDIO_CONTROL) & (!(0 << 3));
}

void audio_write_left(int left)
{
    uint8_t empty_spaces_left = 0;

    do 
    {
        empty_spaces_left = ((*AUDIO_FIFO_SPACE) >> 24);
    } while (empty_spaces_left == 0);

    *AUDIO_LEFTDATA = left;
}

void audio_write_right(int right)
{
    uint8_t empty_spaces_right = 0;

    do 
    {
        empty_spaces_right = ((*AUDIO_FIFO_SPACE) >> 16);
    } while (empty_spaces_right == 0);

    *AUDIO_RIGHTDATA = right;
}

