#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include "../address_map_arm.h"


#define SUCCESS 0

static int device_open (struct inode *, struct file *);
static int device_release (struct inode *, struct file *);

static ssize_t device_write_LEDR (struct file *filp, char *buffer, size_t length, loff_t *offset);

#define DEVICE_NAME_LEDR "LEDR"
static dev_t dev_no_LEDR = 0;
static struct cdev *LEDR_cdev = NULL;
static struct class *LEDR_class = NULL;

static struct file_operations fops_LEDR = {
	.owner = THIS_MODULE,
	.write = device_write_LEDR,
	.open = device_open,
	.release = device_release
};


static ssize_t device_write_HEX (struct file *filp, char *buffer, size_t length, loff_t *offset);

#define DEVICE_NAME_HEX "HEX"
static dev_t dev_no_HEX = 0;
static struct cdev *HEX_cdev = NULL;
static struct class *HEX_class = NULL;

static struct file_operations fops_HEX = {
	.owner = THIS_MODULE,
	.write = device_write_HEX,
	.open = device_open,
	.release = device_release
};

void * LW_virtual;
volatile int *LEDR_ptr, *HEX0_ptr, *HEX4_ptr; 

static int __init init_drivers(void)
{
    int err = 0;

    LW_virtual = ioremap_nocache (LW_BRIDGE_BASE, LW_BRIDGE_SPAN);
    LEDR_ptr = LW_virtual + LEDR_BASE;
    HEX0_ptr = LW_virtual + HEX3_HEX0_BASE;
    HEX4_ptr = LW_virtual + HEX5_HEX4_BASE;


    if ((err = alloc_chrdev_region (&dev_no_LEDR, 0, 1, DEVICE_NAME_LEDR)) < 0) {
		printk (KERN_ERR "LEDR: alloc_chrdev_region() failed with return value %d\n", err);
		return err;
	}
    if ((err = alloc_chrdev_region (&dev_no_HEX, 0, 1, DEVICE_NAME_HEX)) < 0) {
		printk (KERN_ERR "HEX: alloc_chrdev_region() failed with return value %d\n", err);
		return err;
    }


    LEDR_cdev = cdev_alloc (); 
	LEDR_cdev->ops = &fops_LEDR; 
	LEDR_cdev->owner = THIS_MODULE;

    HEX_cdev = cdev_alloc (); 
	HEX_cdev->ops = &fops_HEX; 
	HEX_cdev->owner = THIS_MODULE;
	

    if ((err = cdev_add (LEDR_cdev, dev_no_LEDR, 1)) < 0) {
		printk (KERN_ERR "LEDR: cdev_add() failed with return value %d\n", err);
		return err;
	}
    if ((err = cdev_add (HEX_cdev, dev_no_HEX, 1)) < 0) {
		printk (KERN_ERR "HEX: cdev_add() failed with return value %d\n", err);
		return err;
	}

    LEDR_class = class_create (THIS_MODULE, DEVICE_NAME_LEDR);
	device_create (LEDR_class, NULL, dev_no_LEDR, NULL, DEVICE_NAME_LEDR );

    HEX_class = class_create (THIS_MODULE, DEVICE_NAME_HEX);
	device_create (HEX_class, NULL, dev_no_HEX, NULL, DEVICE_NAME_HEX );

    return 0;
}

static void __exit exit_drivers(void)
{
    device_destroy (LEDR_class, dev_no_LEDR);
    cdev_del (LEDR_cdev);
	class_destroy (LEDR_class);
	unregister_chrdev_region (dev_no_LEDR, 1);

    device_destroy (HEX_class, dev_no_HEX);
    cdev_del (HEX_cdev);
	class_destroy (HEX_class);
	unregister_chrdev_region (dev_no_HEX, 1);
}

static int device_open(struct inode *inode, struct file *file)
{
	return SUCCESS;
}

static int device_release(struct inode *inode, struct file *file)
{
	return 0;
}

static ssize_t device_write_LEDR(struct file *filp, char *buffer, size_t length, loff_t *offset)
{
    char data[4];
    int led_data;

	if (copy_from_user (data, buffer, 3) != 0)
		printk (KERN_ERR "Error: copy_from_user unsuccessful");

    data[3] = '\0';
    sscanf(data, "%d", &led_data);

    *LEDR_ptr = led_data;
	return 10;
}

static ssize_t device_write_HEX(struct file *filp, char *buffer, size_t length, loff_t *offset)
{
	char data_whole[12];
    char data_lower[9];
    char data_higher[5];

    int hex_data_l = 0;
    int hex_data_h = 0;

	if (copy_from_user (data_whole, buffer, 12) != 0)
		printk (KERN_ERR "Error: copy_from_user unsuccessful");

    int i;
    for (i = 0; i < 12; i++)
    {
        if(i < 8)
            data_lower[i] = data_whole[i];
        else
            data_higher[i-8] = data_whole[i];
    }
    data_lower[8] = '\0';
    data_higher[4] = '\0';

    sscanf(data_lower, "%d", &hex_data_l);
    sscanf(data_higher, "%d", &hex_data_h);

    *HEX0_ptr = hex_data_l;
    *HEX4_ptr = hex_data_h;

	return 12;
}


MODULE_LICENSE("GPL");
module_init (init_drivers);
module_exit (exit_drivers);