//      This library provides the high-level functions needed to use the I2C
//	serial interface supported by the hardware of several AVR processors.

// functions


#define sbi(var, mask)   ((var) |= (unsigned char)(1 << mask))
#define cbi(var, mask)   ((var) &= (unsigned char)~(1 << mask))

#define WRITE_sda() DDRC = DDRC | 0b00010000 //SDA must be output when writing
#define READ_sda()  DDRC = DDRC & 0b11101111 //SDA must be input when reading - don't forget the resistor on SDA!!

//! Initialize I2C (TWI) interface
void i2cInit(void);

//! Set the I2C transaction bitrate (in KHz)
void i2cSetBitrate(unsigned short bitrateKHz);

// Low-level I2C transaction commands 
//! Send an I2C start condition in Master mode
void i2cSendStart(void);
//! Send an I2C stop condition in Master mode
void i2cSendStop(void);
//! Wait for current I2C operation to complete
void i2cWaitForComplete(void);
//! Send an (address|R/W) combination or a data byte over I2C
void i2cSendByte(unsigned char data);
//! Receive a data byte over I2C  
// ackFlag = true if recevied data should be ACK'ed
// ackFlag = false if recevied data should be NACK'ed
void i2cReceiveByte(unsigned char ackFlag);
//! Pick up the data that was received with i2cReceiveByte()
unsigned char i2cGetReceivedByte(void);
//! Get current I2c bus status from TWSR
unsigned char i2cGetStatus(void);
void delay_ms(unsigned short x);

// high-level I2C transaction commands

//! send I2C data to a device on the bus (non-interrupt based)
unsigned char i2cMasterSendNI(unsigned char deviceAddr, unsigned char length, unsigned char* data);
//! receive I2C data from a device on the bus (non-interrupt based)
unsigned char i2cMasterReceiveNI(unsigned char deviceAddr, unsigned char length, unsigned char *data);
