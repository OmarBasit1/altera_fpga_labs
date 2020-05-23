#include <math.h>

#ifndef AUDIO_H_
#define AUDIO_H_

#define PI 3.14159265
#define PI2 6.28318531
#define SAMPLING_RATE 8000
#define MAX_VOLUME 0x7fffffff

// Audio Core Registers
#define FIFOSPACE 1
#define LDATA 2
#define RDATA 3


void generate_sine(int duration_ms, double freq, int volume, int *wave);
void add_two_sine(int *wave1, int *wave2, int duration_ms);

#endif /*AUDIO_H_*/
