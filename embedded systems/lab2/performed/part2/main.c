#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include "../address_map_arm.h"
#include "../interrupt_ID.h"

void * LW_virtual; // Lightweight bridge base address
int* timer0, *hex3_0, *hex5_4;

#define ZERO 0x3F;
#define ONE 0b000000110;
#define TWO 0b001011011;
#define THREE 0b001001111;
#define FOUR 0b001100110;
#define FIVE 0b001101101;
#define SIX 0b001111100;
#define SEVEN 0b000000111;
#define EIGHT 0b001111111;
#define NINE 0b001100111;

void start_timer(void);
void stop_timer(void);
void setup_my_timer(void);
int encoded_hex(int x);

uint8_t DD_U = 0, DD_T = 0, SS_U = 0, SS_T = 0, MM_U = 0, MM_T = 0;

irq_handler_t irq_handler(int irq, void *dev_id, struct pt_regs *regs)
{
    *(timer0) = 0;
    DD_U = (DD_U + 1) % 10;
    *hex3_0 = ((*hex3_0) & ((0xFFFFFF << 8) + encoded_hex(DD_U))) | encoded_hex(DD_U);
    
    if(DD_U == 0)
    {
        DD_T = (DD_T + 1) % 10;
        *hex3_0 = ((*hex3_0) & ((0xFFFF << 16) + (encoded_hex(DD_T) << 8) + (0xFF))) | (encoded_hex(DD_T) << 8);
    }

    if(DD_T == 0 & DD_U == 0)
    {
        SS_U = (SS_U + 1) % 10;
        *hex3_0 = ((*hex3_0) & ((0xFF << 24) + (encoded_hex(SS_U) << 16) + (0xFFFF))) | (encoded_hex(SS_U) << 16);
    }

    if(SS_U == 0 & DD_T == 0 & DD_U == 0)
    {
        SS_T = (SS_T + 1) % 6;
        *hex3_0 = ((*hex3_0) &  + (encoded_hex(SS_T) << 24) + (0xFFFFFF)) | (encoded_hex(SS_T) << 24);
    }

    if(SS_T == 0 & SS_U == 0 & DD_T == 0 & DD_U == 0)
    {
        MM_U = (MM_U + 1) % 10;
        *hex5_4 = ((*hex5_4) & ((0xFF << 8) + encoded_hex(MM_U))) | encoded_hex(MM_U);
    }

    if(MM_U == 0 & SS_T == 0 & SS_U == 0 & DD_T == 0 & DD_U == 0)
    {
        MM_T = (MM_T + 1) % 6;
        *hex5_4 = ((*hex5_4) & ((encoded_hex(MM_T) << 8) + (0xFF))) | (encoded_hex(MM_T) << 8);
    }

    return (irq_handler_t) IRQ_HANDLED;
}

static int __init initialize_timer_handler(void)
{
    int value;
    // generate a virtual address for the FPGA lightweight bridge
    LW_virtual = ioremap_nocache (LW_BRIDGE_BASE, LW_BRIDGE_SPAN);

    timer0 = LW_virtual + TIMER0_BASE;
    hex3_0 = LW_virtual + HEX3_HEX0_BASE;
    hex5_4 = LW_virtual + HEX5_HEX4_BASE;

    setup_my_timer();

    value = request_irq (TIMER0_IRQ, (irq_handler_t) irq_handler, IRQF_SHARED, "timer_irq_handler", (void *) (irq_handler));

    //*hex5_4 = encoded_hex(*timer0);
    //*hex3_0 = encoded_hex(*(timer0+1));

    return value;
}

static void __exit cleanup_timer_handler(void)
{
    stop_timer();
    //*hex5_4 = (encoded_hex(0) << 8) + encoded_hex(0);
    //*hex3_0 = (encoded_hex(0) << 24) + (encoded_hex(0) << 16) + (encoded_hex(0) << 8) + encoded_hex(0);
    free_irq (TIMER0_IRQ, (void*) irq_handler);
}

void start_timer(void)
{
    *(timer0 + 1) = *(timer0 + 1) | 1 << 2;
}

void stop_timer(void)
{
    *(timer0 + 1) = 1 << 3;
}

void setup_my_timer(void)
{
    *(timer0 + 2) = 0x4240;      //count to 1M to get interrupts at 1/100 secs at 100MHz clock
    *(timer0 + 3) = 0xF;

    *(timer0 + 1) = 1 << 1;     //make timer run continuously
    *(timer0 + 1) = *(timer0 + 1) | 1 << 0;     //start timer interrupt upon overflow

    *(timer0) = 0;

    start_timer();
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

module_init(initialize_timer_handler);
module_exit(cleanup_timer_handler);