#include "audio.h"


void generate_sine(int duration_ms, double freq, int volume, int *wave)
{
    if (volume > MAX_VOLUME)
        volume = MAX_VOLUME;

    int i;
    for (i = 0; i < ((int) duration_ms*SAMPLING_RATE/1000); i++)
        wave[i] = volume * sin((float) (PI2 * freq * i) / (float) (SAMPLING_RATE) );
}

