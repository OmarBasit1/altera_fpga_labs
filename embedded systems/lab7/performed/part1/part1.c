#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "../address_map_arm.h"


#define ADXL345_ADDRESS              (0x53)
#define ADXL345_REG_DEVID            (0x00)
#define ADXL345_REG_THRESH_TAP       (0x1D) // 1
#define ADXL345_REG_OFSX             (0x1E)
#define ADXL345_REG_OFSY             (0x1F)
#define ADXL345_REG_OFSZ             (0x20)
#define ADXL345_REG_DUR              (0x21) // 2
#define ADXL345_REG_LATENT           (0x22) // 3
#define ADXL345_REG_WINDOW           (0x23) // 4
#define ADXL345_REG_THRESH_ACT       (0x24) // 5
#define ADXL345_REG_THRESH_INACT     (0x25) // 6
#define ADXL345_REG_TIME_INACT       (0x26) // 7
#define ADXL345_REG_ACT_INACT_CTL    (0x27)
#define ADXL345_REG_THRESH_FF        (0x28) // 8
#define ADXL345_REG_TIME_FF          (0x29) // 9
#define ADXL345_REG_TAP_AXES         (0x2A)
#define ADXL345_REG_ACT_TAP_STATUS   (0x2B)
#define ADXL345_REG_BW_RATE          (0x2C)
#define ADXL345_REG_POWER_CTL        (0x2D)
#define ADXL345_REG_INT_ENABLE       (0x2E)
#define ADXL345_REG_INT_MAP          (0x2F)
#define ADXL345_REG_INT_SOURCE       (0x30) // A
#define ADXL345_REG_DATA_FORMAT      (0x31)
#define ADXL345_REG_DATAX0           (0x32)
#define ADXL345_REG_DATAX1           (0x33)
#define ADXL345_REG_DATAY0           (0x34)
#define ADXL345_REG_DATAY1           (0x35)
#define ADXL345_REG_DATAZ0           (0x36)
#define ADXL345_REG_DATAZ1           (0x37)
#define ADXL345_REG_FIFO_CTL         (0x38)
#define ADXL345_REG_FIFO_STATUS      (0x39)
#define ADXL345_FULL_RESOLUTION      (0x08)
#define ADXL345_STANDBY              (0x00)
#define ADXL345_MEASURE              (0x08)

typedef enum
{
    ADXL345_DATARATE_3200HZ    = 0b1111,
    ADXL345_DATARATE_1600HZ    = 0b1110,
    ADXL345_DATARATE_800HZ     = 0b1101,
    ADXL345_DATARATE_400HZ     = 0b1100,
    ADXL345_DATARATE_200HZ     = 0b1011,
    ADXL345_DATARATE_100HZ     = 0b1010,
    ADXL345_DATARATE_50HZ      = 0b1001,
    ADXL345_DATARATE_25HZ      = 0b1000,
    ADXL345_DATARATE_12_5HZ    = 0b0111,
    ADXL345_DATARATE_6_25HZ    = 0b0110,
    ADXL345_DATARATE_3_13HZ    = 0b0101,
    ADXL345_DATARATE_1_56HZ    = 0b0100,
    ADXL345_DATARATE_0_78HZ    = 0b0011,
    ADXL345_DATARATE_0_39HZ    = 0b0010,
    ADXL345_DATARATE_0_20HZ    = 0b0001,
    ADXL345_DATARATE_0_10HZ    = 0b0000
} adxl345_dataRate_t;

typedef enum
{
    ADXL345_INT2 = 0b01,
    ADXL345_INT1 = 0b00
} adxl345_int_t;

typedef enum
{
    ADXL345_DATA_READY         = 0b10000000,
    ADXL345_SINGLE_TAP         = 0b01000000,
    ADXL345_DOUBLE_TAP         = 0b00100000,
    ADXL345_ACTIVITY           = 0b00010000,
    ADXL345_INACTIVITY         = 0b00001000,
    ADXL345_FREE_FALL          = 0b00000100,
    ADXL345_WATERMARK          = 0b00000010,
    ADXL345_OVERRUN            = 0b00000001
} adxl345_activity_t;

typedef enum
{
    ADXL345_RANGE_16G          = 0b11,
    ADXL345_RANGE_8G           = 0b10,
    ADXL345_RANGE_4G           = 0b01,
    ADXL345_RANGE_2G           = 0b00
} adxl345_range_t;

///////////////////////////////////////////////////////////////////////////////////////////////////////////

void *I2C0_virtual;
void *SYSMGR_virtual;

volatile int *I2C0_ENABLE_virtual;
volatile int *I2C0_ENABLE_STATUS_virtual;
volatile int *I2C0_CON_virtual;
volatile int *I2C0_TAR_virtual;
volatile int *I2C0_FS_SCL_HCNT_virtual;
volatile int *I2C0_FS_SCL_LCNT_virtual;
volatile int *I2C0_DATA_CMD_virtual;
volatile int *I2C0_RXFLR_virtual;

////////////////////////////////////////////////////////////////////////////////////////////////////////////

int open_physical (int fd);
void close_physical (int fd);
void* map_physical(int fd, unsigned int base, unsigned int span);
int unmap_physical(void * virtual_base, unsigned int span);

void Pinmux_Config();

void I2C0_Init();

void ADXL345_REG_READ(uint8_t address, uint8_t *value);
void ADXL345_REG_WRITE(uint8_t address, uint8_t value);
void ADXL345_REG_MULTI_READ(uint8_t address, uint8_t values[], uint8_t len);
void ADXL345_Init();
void ADXL345_XYZ_Read(int16_t szData16[3]);
bool ADXL345_IsDataReady();

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(void)
{
    int fd = -1;
    if ((fd = open_physical(fd)) == -1)
        return (-1);
    if (!(I2C0_virtual = map_physical(fd, I2C0_BASE, I2C0_SPAN)))
        return (-1);
    if (!(SYSMGR_virtual = map_physical(fd, SYSMGR_BASE, SYSMGR_SPAN)))
        return (-1);

    I2C0_ENABLE_virtual         = (int *) I2C0_virtual + I2C0_ENABLE;
    I2C0_ENABLE_STATUS_virtual  = (int *) I2C0_virtual + I2C0_ENABLE_STATUS;
    I2C0_CON_virtual            = (int *) I2C0_virtual + I2C0_CON;
    I2C0_TAR_virtual            = (int *) I2C0_virtual + I2C0_TAR;
    I2C0_FS_SCL_HCNT_virtual    = (int *) I2C0_virtual + I2C0_FS_SCL_HCNT;
    I2C0_FS_SCL_LCNT_virtual    = (int *) I2C0_virtual + I2C0_FS_SCL_LCNT;
    I2C0_DATA_CMD_virtual       = (int *) I2C0_virtual + I2C0_DATA_CMD;
    I2C0_RXFLR_virtual          = (int *) I2C0_virtual + I2C0_RXFLR;

    uint8_t devid;
    int16_t mg_per_lsb = 4;
    int16_t XYZ[3];

    // Configure Pin Muxing
    Pinmux_Config();

    // Initialize I2C0 Controller
    I2C0_Init();

    // 0xE5 is read from DEVID(0x00) if I2C is functioning correctly
    ADXL345_REG_READ(0x00, &devid);

    // Correct Device ID
    if (devid == 0xE5)
    {
        // Initialize accelerometer chip
        ADXL345_Init();

        while(1)
        {
            if (ADXL345_IsDataReady())
            {
                ADXL345_XYZ_Read(XYZ);
                printf("X=%d mg, Y=%d mg, Z=%d mg\n", XYZ[0]*mg_per_lsb, XYZ[1]*mg_per_lsb, XYZ[2]*mg_per_lsb);
            }
        }
    } 
    else 
    {
        printf("Incorrect device ID\n");
    }

    return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int open_physical (int fd)
{
    if (fd == -1) // check if already open
    {
        if ((fd = open( "/dev/mem", (O_RDWR | O_SYNC))) == -1)
        {
            printf ("ERROR: could not open \"/dev/mem\"...\n");
            return (-1);
        }
    }
    return fd;
}

void close_physical (int fd)
{
    close(fd);
}

void* map_physical(int fd, unsigned int base, unsigned int span)
{
    void *virtual_base;
    // Get a mapping from physical addresses to virtual addresses
    virtual_base = mmap (NULL, span, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, base);
    if (virtual_base == MAP_FAILED)
    {
        printf ("ERROR: mmap() failed...\n");
        close (fd);
        return (NULL);
    }
    return virtual_base;
}

int unmap_physical(void * virtual_base, unsigned int span)
{
    if (munmap (virtual_base, span) != 0)
    {
        printf ("ERROR: munmap() failed...\n");
        return (-1);
    }
    return 0;
}

void Pinmux_Config()
{
    volatile int *I2C0USEFPGA = (int *) SYSMGR_virtual + SYSMGR_I2C0USEFPGA;
    volatile int *GENERALIO7 = (int *) SYSMGR_virtual + SYSMGR_GENERALIO7;
    volatile int *GENERALIO8 = (int *) SYSMGR_virtual + SYSMGR_GENERALIO8;

    *I2C0USEFPGA = 0;
    *GENERALIO7 = 1;
    *GENERALIO8 = 1;
}

void I2C0_Init()
{
    *I2C0_ENABLE_virtual = 2;       // Abort any ongoing transmits and disable I2C0

    while(((*I2C0_ENABLE_STATUS_virtual)&0x1) == 1);    // Wait until I2C0 is disabled

    // Configure the config reg with the desired setting (act as
    // a master, use 7bit addressing, fast mode (400kb/s)).
    *I2C0_CON_virtual = 0x65;

    // Set target address (disable special commands, use 7bit addressing
    *I2C0_TAR_virtual = 0x53;

    // Set SCL high/low counts (Assuming default 100MHZ clock input toI2C0 Controller).
    // The minimum SCL high period is 0.6us, and the minimum SCL lowperiod is 1.3us,
    // However, the combined period must be 2.5us or greater, so add 0.3usto each.
    *I2C0_FS_SCL_HCNT_virtual = 60 + 30; // 0.6us + 0.3us
    *I2C0_FS_SCL_LCNT_virtual = 130 + 30; // 1.3us + 0.3us

    // Enable the controller
    *I2C0_ENABLE_virtual = 1;

    while(((*I2C0_ENABLE_STATUS_virtual)&0x1) == 0);    // Wait until I2C0 is enabled
}

// Read value from internal register at address
void ADXL345_REG_READ(uint8_t address, uint8_t *value)
{
    // Send reg address (+0x400 to send START signal)
    *I2C0_DATA_CMD_virtual = address + 0x400;

    // Send read signal
    *I2C0_DATA_CMD_virtual = 0x100;

    // Read the response (first wait until RX buffer contains data)
    while (*I2C0_RXFLR_virtual == 0);
    *value = *I2C0_DATA_CMD_virtual;
}

// Write value from internal register at address
void ADXL345_REG_WRITE(uint8_t address, uint8_t value)
{
    // Send reg address (+0x400 to send START signal)
    *I2C0_DATA_CMD_virtual = address + 0x400;

    // Send read signal
    *I2C0_DATA_CMD_virtual = value;
}

// Read multiple consecutive internal registers
void ADXL345_REG_MULTI_READ(uint8_t address, uint8_t values[], uint8_t len)
{
    // Send reg address (+0x400 to send START signal)
    *I2C0_DATA_CMD_virtual = address + 0x400;

    // Send read signal len times
    int i;
    for (i=0; i<len; i++)
        *I2C0_DATA_CMD_virtual = 0x100;

    // Read the bytes
    int nth_byte=0;
    while (len)
    {
        if ((*I2C0_RXFLR_virtual) > 0)
        {
            values[nth_byte] = *I2C0_DATA_CMD_virtual;
            nth_byte++;
            len--;
        }
    }
}

// Initialize the ADXL345 chip
void ADXL345_Init()
{
    // +- 16g range, full resolution
    ADXL345_REG_WRITE(ADXL345_REG_DATA_FORMAT, ADXL345_RANGE_16G | ADXL345_FULL_RESOLUTION);

    // Output Data Rate: 200Hz
    ADXL345_REG_WRITE(ADXL345_REG_BW_RATE, ADXL345_DATARATE_12_5HZ);

    // The DATA_READY bit is not reliable. It is updated at a much higher rate than the Data Rate
    // Use the Activity and Inactivity interrupts as indicators for new data.
    ADXL345_REG_WRITE(ADXL345_REG_THRESH_ACT, 0x04); //activity threshold
    ADXL345_REG_WRITE(ADXL345_REG_THRESH_INACT, 0x02); //inactivity threshold
    ADXL345_REG_WRITE(ADXL345_REG_TIME_INACT, 0x02); //time for inactivity
    ADXL345_REG_WRITE(ADXL345_REG_ACT_INACT_CTL, 0xFF); //Enables AC coupling for thresholds
    ADXL345_REG_WRITE(ADXL345_REG_INT_ENABLE, ADXL345_ACTIVITY | ADXL345_INACTIVITY ); //enable interrupts

    // stop measure
    ADXL345_REG_WRITE(ADXL345_REG_POWER_CTL, ADXL345_STANDBY);

    // start measure
    ADXL345_REG_WRITE(ADXL345_REG_POWER_CTL, ADXL345_MEASURE);
}

// Read acceleration data of all three axes
void ADXL345_XYZ_Read(int16_t szData16[3])
{
    uint8_t szData8[6];
    ADXL345_REG_MULTI_READ(0x32, (uint8_t *)&szData8, sizeof(szData8));

    szData16[0] = (szData8[1] << 8) | szData8[0];
    szData16[1] = (szData8[3] << 8) | szData8[2];
    szData16[2] = (szData8[5] << 8) | szData8[4];
}

// Return true if there is new data
bool ADXL345_IsDataReady()
{
    bool bReady = false;
    uint8_t data8;

    ADXL345_REG_READ(ADXL345_REG_INT_SOURCE,&data8);
    if (data8 & ADXL345_ACTIVITY)
        bReady = true;

    return bReady;
}