#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include "../address_map_arm.h"

// Declare global variables needed to use the pixel buffer
void *LW_virtual; // used to access FPGA light-weight bridge
volatile int * pixel_ctrl_ptr; // virtual address of pixel buffer controller
volatile char * pixel_buffer; // used for virtual address of pixel buffer
int resolution_x, resolution_y; // VGA screen size

// Declare variables and prototypes needed for a character device driver
#define DEVICE_NAME "video"
static char video_msg[9];
static char video_command[50];

static int device_open (struct inode *, struct file *);
static int device_release (struct inode *, struct file *);
static ssize_t device_read (struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);

static dev_t dev_no = 0;
static struct cdev *chardev_cdev = NULL;
static struct class *chardev_class = NULL;

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.read = device_read,
	.write = device_write,
	.open = device_open,
	.release = device_release
};

void get_screen_specs(volatile int * pixel_ctrl_ptr);
void clear_screen(void);
void plot_pixel(int x, int y, short int color);
void parse_command(void);

/* Code to initialize the video driver */
static int __init start_video(void)
{
    // initialize the dev_t, cdev, and class data structures
    int err = 0;

	/* Get a device number. Get one minor number (0) */
	if ((err = alloc_chrdev_region (&dev_no, 0, 1, DEVICE_NAME)) < 0) {
		printk (KERN_ERR "chardev: alloc_chrdev_region() failed with return value %d\n", err);
		return err;
	}

    chardev_cdev = cdev_alloc (); 
	chardev_cdev->ops = &fops; 
	chardev_cdev->owner = THIS_MODULE;

    if ((err = cdev_add (chardev_cdev, dev_no, 1)) < 0) {
		printk (KERN_ERR "chardev: cdev_add() failed with return value %d\n", err);
		return err;
	}

    chardev_class = class_create (THIS_MODULE, DEVICE_NAME);
	device_create (chardev_class, NULL, dev_no, NULL, DEVICE_NAME );

    // generate a virtual address for the FPGA lightweight bridge
    LW_virtual = ioremap_nocache (0xFF200000, 0x00005000);
    if (LW_virtual == 0)
    printk (KERN_ERR "Error: ioremap_nocache returned NULL\n");

    // Create virtual memory access to the pixel buffer controller
    pixel_ctrl_ptr = (unsigned int *) (LW_virtual + 0x00003020);
    get_screen_specs (pixel_ctrl_ptr); // determine X, Y screen size

    // Create virtual memory access to the pixel buffer
    pixel_buffer =  (unsigned int *) ioremap_nocache (0xC8000000, 0x0003FFFF);
    if (pixel_buffer == 0)
        printk (KERN_ERR "Error: ioremap_nocache returned NULL\n");

    printk("pixel_buffer: %p\n",pixel_buffer);

    /* Erase the pixel buffer */
    clear_screen ( );
    return 0;
}

void get_screen_specs(volatile int * pixel_ctrl_ptr)
{
    int resolution = *(pixel_ctrl_ptr+2);
    resolution_x = resolution & 0x0000FFFF;
    resolution_y = (resolution & 0xFFFF0000) >> 16;
    sprintf(video_msg, "%d %d\n", resolution_x, resolution_y);
}
void clear_screen(void)
{
    int i=0,j=0;
    int local =0;
    for (j = 0; j < (resolution_y); j++)
    {
        for (i = 0; i < (resolution_x); i++)
        {
            local = (i<<1)+(j<<10);
            *(pixel_buffer+local) = 0;
        }
    }
}

void plot_pixel(int x, int y, short int color)
{
    //printk("x, y, color: %d, %d, %x\n", x, y, color);

    *(pixel_buffer + (x << 1) + (y << 10)) = color;
}

static void __exit stop_video(void)
{
    /* unmap the physical-to-virtual mappings */
    iounmap (LW_virtual);
    iounmap ((void *) pixel_buffer);

    /* Remove the device from the kernel */
    device_destroy (chardev_class, dev_no);
    cdev_del (chardev_cdev);
	class_destroy (chardev_class);
	unregister_chrdev_region (dev_no, 1);

}

static int device_open(struct inode *inode, struct file *file)
{
    return 0;
}

static int device_release(struct inode *inode, struct file *file)
{
    return 0;
}

static ssize_t device_read(struct file *filp, char *buffer, size_t length, loff_t *offset)
{
    size_t bytes;
	bytes = strlen (video_msg) - (*offset);	// how many bytes not yet sent?
	bytes = bytes > length ? length : bytes;	// too much to send all at once?
	
	if (bytes)
		if (copy_to_user (buffer, &video_msg[*offset], bytes) != 0)
			printk (KERN_ERR "Error: copy_to_user unsuccessful");
	*offset = bytes;	// keep track of number of bytes sent to the user
	return bytes;
}

static ssize_t device_write(struct file *filp, const char *buffer, size_t length, loff_t *offset)
{
    size_t bytes;
	bytes = length;

	if (bytes > 50 - 1)	// can copy all at once, or not?
		bytes = 50 - 1;
	if (copy_from_user (video_command, buffer, bytes) != 0)
		printk (KERN_ERR "Error: copy_from_user unsuccessful");
	video_command[bytes] = '\0';	// NULL terminate
	// Note: we do NOT update *offset; we just copy the data into video_command*/

    parse_command();

	return bytes;
}

void parse_command(void)
{
    printk("%s\n",video_command);

    if ((video_command[0] == 'c') & (video_command[1] == 'l') & (video_command[2] == 'e') & (video_command[3] == 'a') & (video_command[4] == 'r'))
    {
        //printk("clear command\n");
        clear_screen();
    }
    else if ((video_command[0] == 'p') & (video_command[1] == 'i') & (video_command[2] == 'x') & (video_command[3] == 'e') & (video_command[4] == 'l'))
    {
        //printk("pixel command\n");

        int x, y;
        short int color;

        char values[15];
        memcpy(values, &video_command[6], strlen(video_command) - 6);

        int i;
        for(i = 0; values[i] != '\0'; i++)
        {
            if(values[i] == ',')
            {
                values[i] = ' ';
            }  
        }

        sscanf(values, "%d %d %x", &x, &y, &color);

        plot_pixel(x, y, color);
    }
    else
    {
        //printk("invalid command!!!\n");
    }
    
}

MODULE_LICENSE("GPL");
module_init (start_video);
module_exit (stop_video);