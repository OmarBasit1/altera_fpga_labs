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

static ssize_t device_read_KEY (struct file *, char *, size_t, loff_t *);

#define DEVICE_NAME_KEY "KEY"
static dev_t dev_no_KEY = 0;
static struct cdev *KEY_cdev = NULL;
static struct class *KEY_class = NULL;

static struct file_operations fops_KEY = {
	.owner = THIS_MODULE,
	.read = device_read_KEY,
	.open = device_open,
	.release = device_release
};


static ssize_t device_read_SW (struct file *, char *, size_t, loff_t *);

#define DEVICE_NAME_SW "SW"
static dev_t dev_no_SW = 0;
static struct cdev *SW_cdev = NULL;
static struct class *SW_class = NULL;

static struct file_operations fops_SW = {
	.owner = THIS_MODULE,
	.read = device_read_SW,
	.open = device_open,
	.release = device_release
};

void * LW_virtual;
volatile int *KEY_ptr, *SW_ptr; 

static int __init init_drivers(void)
{
    int err = 0;

    LW_virtual = ioremap_nocache (LW_BRIDGE_BASE, LW_BRIDGE_SPAN);
    KEY_ptr = LW_virtual + KEY_BASE;
    SW_ptr  = LW_virtual + SW_BASE;

    printk("KEY_ptr: %d\n",KEY_ptr);
    printk("SW_ptr: %d\n",SW_ptr);

    if ((err = alloc_chrdev_region (&dev_no_KEY, 0, 1, DEVICE_NAME_KEY)) < 0) {
		printk (KERN_ERR "KEY: alloc_chrdev_region() failed with return value %d\n", err);
		return err;
	}
    if ((err = alloc_chrdev_region (&dev_no_SW, 0, 1, DEVICE_NAME_SW)) < 0) {
		printk (KERN_ERR "SW: alloc_chrdev_region() failed with return value %d\n", err);
		return err;
    }


    KEY_cdev = cdev_alloc (); 
	KEY_cdev->ops = &fops_KEY; 
	KEY_cdev->owner = THIS_MODULE;

    SW_cdev = cdev_alloc (); 
	SW_cdev->ops = &fops_SW; 
	SW_cdev->owner = THIS_MODULE;
	

    if ((err = cdev_add (KEY_cdev, dev_no_KEY, 1)) < 0) {
		printk (KERN_ERR "KEY: cdev_add() failed with return value %d\n", err);
		return err;
	}
    if ((err = cdev_add (SW_cdev, dev_no_SW, 1)) < 0) {
		printk (KERN_ERR "SW: cdev_add() failed with return value %d\n", err);
		return err;
	}

    KEY_class = class_create (THIS_MODULE, DEVICE_NAME_KEY);
	device_create (KEY_class, NULL, dev_no_KEY, NULL, DEVICE_NAME_KEY );

    SW_class = class_create (THIS_MODULE, DEVICE_NAME_SW);
	device_create (SW_class, NULL, dev_no_SW, NULL, DEVICE_NAME_SW );

    return 0;
}

static void __exit exit_drivers(void)
{
    device_destroy (KEY_class, dev_no_KEY);
    cdev_del (KEY_cdev);
	class_destroy (KEY_class);
	unregister_chrdev_region (dev_no_KEY, 1);

    device_destroy (SW_class, dev_no_SW);
    cdev_del (SW_cdev);
	class_destroy (SW_class);
	unregister_chrdev_region (dev_no_SW, 1);
}

static int device_open(struct inode *inode, struct file *file)
{
	return SUCCESS;
}

static int device_release(struct inode *inode, struct file *file)
{
	return 0;
}

static ssize_t device_read_KEY(struct file *filp, char *buffer, size_t length, loff_t *offset)
{
    printk("offset = %d\n",*offset);

    char to_send[1];
    int num = *(KEY_ptr + 3);
    sprintf(to_send, "%X",num);
    if (copy_to_user (buffer, to_send, 1) != 0)
        printk (KERN_ERR "Error: copy_to_user unsuccessful (KEY)");

    *(KEY_ptr + 3) = 0xF;

    *offset = 1;
    if (*offset > 1)
        return 0;
    else
        return 1;
}

static ssize_t device_read_SW(struct file *filp, char *buffer, size_t length, loff_t *offset)
{
	printk("offset = %d\n",*offset);

    char to_send[3];
    sprintf(to_send, "%X",*SW_ptr);

    if (copy_to_user (buffer, to_send, 3) != 0)
        printk (KERN_ERR "Error: copy_to_user unsuccessful (SW)");

    *offset = 1;
    if (*offset > 1)
        return 0;
    else
        return 3;
}


MODULE_LICENSE("GPL");
module_init (init_drivers);
module_exit (exit_drivers);