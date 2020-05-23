#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <asm/io.h>
#include "../address_map_arm.h"
#include "../interrupt_ID.h"

void * LW_virtual; // Lightweight bridge base address
volatile int *LEDR_ptr, *KEY_ptr, *HEX0_ptr; // virtual addresses
int count = 0;

int ZERO =  0x3F;
int ONE =   0b000000110;
int TWO =   0b001011011;
int THREE = 0b001001111;
int FOUR =  0b001100110;
int FIVE =  0b001101101;
int SIX =   0b001111100;
int SEVEN = 0b000000111;
int EIGHT = 0b001111111;
int NINE =  0b001100111;

irq_handler_t irq_handler(int irq, void *dev_id, struct pt_regs *regs)
{
    //*LEDR_ptr = *LEDR_ptr + 1;
    if(*LEDR_ptr < 0x209)
    {
        count += 1;
        *LEDR_ptr = *LEDR_ptr + 1;
    }
    else
    {
        count = 0;
        *LEDR_ptr = 0x200;
    }

    switch((count%10))
    {           
        case 1:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + ONE;
            break;

        case 2:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + TWO;
            break;

        case 3:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + THREE;
            break;

        case 4:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + FOUR;
            break;

        case 5:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + FIVE;
            break;

        case 6:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + SIX;
            break;

        case 7:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + SEVEN;
            break;

        case 8:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + EIGHT;
            break;

        case 9:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + NINE;
            break;

        default:
            *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + ZERO;
    }
    
    //printf_s("current count: %d\n",count);

    // Clear the Edgecapture register (clears current interrupt)
    *(KEY_ptr + 3) = 0xF;
    return (irq_handler_t) IRQ_HANDLED;
}

static int __init initialize_pushbutton_handler(void)
{
    int value;
    // generate a virtual address for the FPGA lightweight bridge
    LW_virtual = ioremap_nocache (LW_BRIDGE_BASE, LW_BRIDGE_SPAN);
    LEDR_ptr = LW_virtual + LEDR_BASE; // virtual address for LEDR port
    *LEDR_ptr = 0x200; // turn on the leftmost light

    KEY_ptr = LW_virtual + KEY_BASE; // virtual address for KEY port
    *(KEY_ptr + 3) = 0xF; // Clear the Edgecapture register
    *(KEY_ptr + 2) = 0xF; // Enable IRQ generation for the 4 buttons

    HEX0_ptr = LW_virtual + HEX3_HEX0_BASE;
    *HEX0_ptr = (0x3F << 24) + (0x3F << 16) + (0x3F << 8) + 0x3F;

    printk (KERN_ERR "\e[2J");
    printk (KERN_ERR "\e[H");

    // Register the interrupt handler.
    value = request_irq (KEYS_IRQ, (irq_handler_t) irq_handler, IRQF_SHARED, "pushbutton_irq_handler", (void *) (irq_handler));
    return value;
}

static void __exit cleanup_pushbutton_handler(void)
{
    //iounmap (LW_virtual);
    *LEDR_ptr = 0; // Turn off LEDs and de-register irq handler
    *HEX0_ptr = 0;
    *KEY_ptr = 0;
    free_irq (KEYS_IRQ, (void*) irq_handler);
}

module_init(initialize_pushbutton_handler);
module_exit(cleanup_pushbutton_handler);