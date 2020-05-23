#include "audio.h"

//  receives an int array in which the sinusoid is to be stored
//  array length should be atleast duration_in_secs * SAMPLING_RATE
void generate_sine(int duration_ms, double freq, int volume, int *wave)
{
    if (volume > MAX_VOLUME)
        volume = MAX_VOLUME;

    int i;
    for (i = 0; i < ((int) duration_ms*SAMPLING_RATE/1000); i++)
        wave[i] = volume * sin((float) (PI2 * freq * i) / (float) (SAMPLING_RATE) );
}


//  recieves 2 sine waves that are added and returned in the first array.
//  array lengths should be atleast duration_in_secs * SAMPLING_RATE.
//  clipping is done if max value exceeds the MAX_VOLUME
void add_two_sine(int *wave1, int *wave2, int duration_ms)
{
    int temp;

    int i;
    for (i = 0; i < ((int) duration_ms*SAMPLING_RATE/1000); i++)
    {
        temp = wave1[i] + wave2[i];

        if ((wave1[i] > 0) && (wave2[i] > 0) && (temp < 0))
            wave1[i] = 0x7fffffff;
        else if ((wave1[i] < 0) && (wave2[i] < 0) && (temp > 0))
            wave1[i] = 0x80000000;
        else
            wave1[i] = temp;
        
    }
}