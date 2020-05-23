#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include "../address_map_arm.h"
#include "../interrupt_ID.h"

void * LW_virtual; // Lightweight bridge base address
int* timer0, *hex3_0, *hex5_4, *keys, *switches;

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
int start = 0;

int DD = 59, SS = 59, MM = 59;

irq_handler_t irq_handler_timer(int irq, void *dev_id, struct pt_regs *regs)
{
    *(timer0) = 0;

    if ((MM == 0) & (SS == 0) & (DD == 0))
    {
        //do nothing
    }    
    else
    {
        DD--;
        if (DD == 0)
        {
            SS--;
            if(SS == 0)
            {   
                MM--;
                if (MM == 0)
                {
                    DD = 99;
                    SS = 59;
                }
                if (MM < 0)
                {
                    DD = 0; 
                    SS = 0;
                    MM = 0; 
                }

                
            }
            else if (SS < 0)
                SS = 59;
        }
        else if(DD < 0)
            DD = 99;
        
    }

    *hex3_0 = (encoded_hex(SS/10) << 24) + (encoded_hex(SS%10) << 16) + (encoded_hex(DD/10) << 8) + (encoded_hex(DD%10));
    *hex5_4 = (encoded_hex(MM/10) << 8) + (encoded_hex(MM%10));

    return (irq_handler_t) IRQ_HANDLED;
}

irq_handler_t irq_handler_keys(int irq, int *dev_id, struct pt_regs *regs)
{
    if(*(keys + 3) == 1)
    {
        if (start)
            stop_timer();
        else
            start_timer();
    }
    else if (*(keys + 3) == 2)
    {
        if ((*switches) > 99)
            DD = 99;
        else
            DD = *switches;
        
    }
    else if (*(keys + 3) == 4)
    {
        if ((*switches) > 59)
            SS = 59;
        else
            SS = *switches;
    }
    else if (*(keys + 3) == 8)
    {
        if ((*switches) > 59)
            MM = 59;
        else
            MM = *switches;
    }
    
    *(keys + 3) = 0xF;
    return (irq_handler_t) IRQ_HANDLED;
}

static int __init initialize_timer_handler(void)
{
    int value0,value1;
    // generate a virtual address for the FPGA lightweight bridge
    LW_virtual = ioremap_nocache (LW_BRIDGE_BASE, LW_BRIDGE_SPAN);

    timer0 = LW_virtual + TIMER0_BASE;
    hex3_0 = LW_virtual + HEX3_HEX0_BASE;
    hex5_4 = LW_virtual + HEX5_HEX4_BASE;
    keys   = LW_virtual + KEY_BASE;
    switches = LW_virtual + SW_BASE;

    *(keys + 2) = 0xF;
    *(keys + 3) = 0xF;
    setup_my_timer();

    value0 = request_irq (TIMER0_IRQ, (irq_handler_t) irq_handler_timer, IRQF_SHARED, "timer_irq_handler", (void *) (irq_handler_timer));
    value1 = request_irq (KEY_IRQ, (irq_handler_t) irq_handler_keys, IRQF_SHARED, "keys_irq_handler", (void *) (irq_handler_keys));

    //*hex5_4 = encoded_hex(*timer0);
    //*hex3_0 = encoded_hex(*(timer0+1));

    return (value1 << 8) + (value0);
}

static void __exit cleanup_timer_handler(void)
{
    stop_timer();
    *hex5_4 = (encoded_hex(0) << 8) + encoded_hex(0);
    *hex3_0 = (encoded_hex(0) << 24) + (encoded_hex(0) << 16) + (encoded_hex(0) << 8) + encoded_hex(0);
    free_irq (TIMER0_IRQ, (void*) irq_handler_timer);
    free_irq (KEY_IRQ, (void*) irq_handler_keys);
}

void start_timer(void)
{
    *(timer0 + 1) = 1 << 1;                     //make timer run continuously
    *(timer0 + 1) = *(timer0 + 1) | 1 << 0;     //start timer interrupt upon overflow
    *(timer0 + 1) = *(timer0 + 1) | 1 << 2;
    start = 1;
}

void stop_timer(void)
{
    *(timer0 + 1) =  1 << 3 ;
    start = 0;
}

void setup_my_timer(void)
{
    *(timer0 + 2) = 0x4240;      //count to 1M to get interrupts at 1/100 secs at 100MHz clock
    *(timer0 + 3) = 0xF;

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