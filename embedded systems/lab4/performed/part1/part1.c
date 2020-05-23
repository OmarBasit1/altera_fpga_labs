#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include "../address_map_arm.h"
#include "../interrupt_ID.h"
#include <linux/interrupt.h>

#define SUCCESS 0

static int device_open (struct inode *, struct file *);
static int device_release (struct inode *, struct file *);
static ssize_t device_read (struct file *filp, char *buffer, size_t length, loff_t *offset);
static ssize_t device_write (struct file *filp, char *buffer, size_t length, loff_t *offset);

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.write = device_write,
    .read = device_read,
	.open = device_open,
	.release = device_release
};

#define DEVICE_NAME "STOPWATCH"
static dev_t dev_no = 0;
static struct cdev *stopwatch_cdev = NULL;
static struct class *stopwatch_class = NULL;

void * LW_virtual;
int * timer0;

int DD , SS, MM;

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

    return (irq_handler_t) IRQ_HANDLED;
}

static int __init init_drivers(void)
{
    int err = 0;
    LW_virtual = ioremap_nocache (LW_BRIDGE_BASE, LW_BRIDGE_SPAN);
    timer0 = LW_virtual + TIMER0_BASE;

    if ((err = alloc_chrdev_region (&dev_no, 0, 1, DEVICE_NAME)) < 0) {
		printk (KERN_ERR "stopwatch: alloc_chrdev_region() failed with return value %d\n", err);
		return err;
	}

    stopwatch_cdev = cdev_alloc (); 
	stopwatch_cdev->ops = &fops; 
	stopwatch_cdev->owner = THIS_MODULE;

    if ((err = cdev_add (stopwatch_cdev, dev_no, 1)) < 0) {
		printk (KERN_ERR "stopwatch: cdev_add() failed with return value %d\n", err);
		return err;
	}

    stopwatch_class = class_create (THIS_MODULE, DEVICE_NAME);
	device_create (stopwatch_class, NULL, dev_no, NULL, DEVICE_NAME );

    return 0;
}

static void __exit exit_drivers(void)
{
    device_destroy (stopwatch_class, dev_no);
    cdev_del(stopwatch_cdev);
    class_destroy(stopwatch_class);
    unregister_chrdev_region(dev_no, 1);
}

static int device_open(struct inode *inode, struct file *file)
{
    DD = 59;
    SS = 59;
    MM = 59;

    *(timer0 + 2) = 0x4240;      //count to 1M to get interrupts 
    *(timer0 + 3) = 0xF;         //at 1/100 secs at 100MHz clock

    *(timer0) = 0;              //clear status register

    *(timer0 + 1) = 1 << 1;                     //make timer run continuously
    *(timer0 + 1) = *(timer0 + 1) | 1 << 0;     //start timer interrupt upon overflow
    *(timer0 + 1) = *(timer0 + 1) | 1 << 2;     //start timer
    
    request_irq (TIMER0_IRQ, (irq_handler_t) irq_handler_timer, IRQF_SHARED, "timer_irq_handler", (void *) (irq_handler_timer));

	return SUCCESS;
}

static int device_release(struct inode *inode, struct file *file)
{
    *(timer0 + 1) =  1 << 3 ;           //stop timer

    free_irq (TIMER0_IRQ, (void*) irq_handler_timer);

	return 0;
}

static ssize_t device_write(struct file *filp, char *buffer, size_t length, loff_t *offset)
{
    return 0;
}

static ssize_t device_read (struct file *filp, char *buffer, size_t length, loff_t *offset)
{
    char to_send[10];
    to_send[9] = '\0';

    char DD_char[2], SS_char[2], MM_char[2];

    sprintf(DD_char, "%d", DD);
    sprintf(SS_char, "%d", SS);
    sprintf(MM_char, "%d", MM);

    if (strlen(MM_char) == 2)
    {
        to_send[0] = MM_char[0];
        to_send[1] = MM_char[1];
        
    }
    else
    {
        to_send[0] = '0';
        to_send[1] = MM_char[0];
        
    }
    to_send[2] = ':';

    if (strlen(SS_char) == 2)
    {
        to_send[3] = SS_char[0];
        to_send[4] = SS_char[1];
        
    }
    else
    {
        to_send[3] = '0';
        to_send[4] = SS_char[0];
        
    }
    to_send[5] = ':';

    if (strlen(DD_char) == 2)
    {
        to_send[6] = DD_char[0];
        to_send[7] = DD_char[1];
        
    }
    else
    {
        to_send[6] = '0';
        to_send[7] = DD_char[0];
        
    }
    to_send[8] = ':';

    if (copy_to_user(buffer, to_send, 9) != 0)
    {
        printk (KERN_ERR "Error: copy_to_user unsuccessful");
        return -1;
    }

    return 10;
}

MODULE_LICENSE("GPL");
module_init (init_drivers);
module_exit (exit_drivers);