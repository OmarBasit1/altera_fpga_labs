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

int main()
{
    int SIZE = (int) 300*8000/1000;

    int fd = -1;
    if ((fd = open_physical(fd)) == -1)
        return -1;
    if (!(LW_BRIDGE_ptr = map_physical(fd, LW_BRIDGE_BASE, LW_BRIDGE_SPAN)))
        return -1;

    AUDIO_CONTROL       = (int *) (LW_BRIDGE_ptr + AUDIO_BASE);
    AUDIO_FIFO_SPACE    = (int *) (AUDIO_CONTROL + FIFOSPACE);
    AUDIO_LEFTDATA      = (int *) (AUDIO_CONTROL + LDATA);
    AUDIO_RIGHTDATA     = (int *) (AUDIO_CONTROL + RDATA);

    int lowC[SIZE], highC[SIZE],
        lowD[SIZE], highD[SIZE],
        E[SIZE],
        lowF[SIZE], highF[SIZE],
        lowG[SIZE], highG[SIZE],
        lowA[SIZE], highA[SIZE],
        B[SIZE],
        C[SIZE];

    generate_sine(300, 261.626, 0x7FFFFFF, lowC);
    generate_sine(300, 277.183, 0x7FFFFFF, highC);
    generate_sine(300, 293.665, 0x7FFFFFF, lowD);
    generate_sine(300, 311.127, 0x7FFFFFF, highD);
    generate_sine(300, 329.628, 0x7FFFFFF, E);
    generate_sine(300, 349.228, 0x7FFFFFF, lowF);
    generate_sine(300, 369.994, 0x7FFFFFF, highF);
    generate_sine(300, 391.995, 0x7FFFFFF, lowG);
    generate_sine(300, 415.305, 0x7FFFFFF, highG);
    generate_sine(300, 440.000, 0x7FFFFFF, lowA);
    generate_sine(300, 466.164, 0x7FFFFFF, highA);
    generate_sine(300, 493.883, 0x7FFFFFF, B);
    generate_sine(300, 523.251, 0x7FFFFFF, C);

    init_audio();

    int i;
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(lowC[i]);
        audio_write_right(lowC[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(highC[i]);
        audio_write_right(highC[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(lowD[i]);
        audio_write_right(lowD[i]);
    }    
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(highD[i]);
        audio_write_right(highD[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(E[i]);
        audio_write_right(E[i]);
    }    
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(lowF[i]);
        audio_write_right(lowF[i]);
    }    
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(highF[i]);
        audio_write_right(highF[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(lowG[i]);
        audio_write_right(lowG[i]);
    }    
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(highG[i]);
        audio_write_right(highG[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(lowA[i]);
        audio_write_right(lowA[i]);
    }    
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(highA[i]);
        audio_write_right(highA[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(B[i]);
        audio_write_right(B[i]);
    }
    for (i = 0; i < 2400; i++)
    {
        audio_write_left(C[i]);
        audio_write_right(C[i]);
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

