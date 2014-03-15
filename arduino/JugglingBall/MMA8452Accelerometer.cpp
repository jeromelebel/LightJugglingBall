#include "MMA8452Accelerometer.h"
#include "i2c.h"
#include <Arduino.h>

MMA8452Accelerometer::MMA8452Accelerometer(MMA8452Address address, MMA8452ScaleRange fullScaleRange, MMA8452DataRate dataRate)
{
    _address = address;
    _fullScaleRange = fullScaleRange;
    _dataRate = dataRate;
}

unsigned char MMA8452Accelerometer::init()
{
    unsigned char result = false;
    unsigned char c;
    
    /* Read the WHO_AM_I register, this is a good test of communication */
    c = this->readRegister(0x0D);  // Read WHO_AM_I register
    if (c == 0x2A) {
        this->setStandbyMode();  // Must be in standby to change registers
        
        /* Set up the full scale range to 2, 4, or 8g. */
        if ((_fullScaleRange == MMA8452ScaleRange2g) || (_fullScaleRange == MMA8452ScaleRange4g) || (_fullScaleRange == MMA8452ScaleRange8g)) {
            this->writeRegister(0x0E, _fullScaleRange >> 2);
        } else {
            this->writeRegister(0x0E, 0);
        }
        
        /* Setup the 3 data rate bits, from 0 to 7 */
        this->writeRegister(0x2A, this->readRegister(0x2A) & ~(0x38));
        if (_dataRate <= MMA8452DataRate1Hz) {
            this->writeRegister(0x2A, this->readRegister(0x2A) | (_dataRate << 3));
        }
        
        /* Set up portrait/landscap registers - 4 steps:
         1. Enable P/L
         2. Set the back/front angle trigger points (z-lock)
         3. Set the threshold/hysteresis angle
         4. Set the debouce rate
        // For more info check out this app note: http://cache.freescale.com/files/sensors/doc/app_note/AN4068.pdf */
        this->writeRegister(0x11, 0x40);  // 1. Enable P/L
        this->writeRegister(0x13, 0x44);  // 2. 29deg z-lock (don't think this register is actually writable)
        this->writeRegister(0x14, 0x84);  // 3. 45deg thresh, 14deg hyst (don't think this register is writable either)
        this->writeRegister(0x12, 0x50);  // 4. debounce counter at 100ms (at 800 hz)
        
        /* Set up single and double tap - 5 steps:
         1. Set up single and/or double tap detection on each axis individually.
         2. Set the threshold - minimum required acceleration to cause a tap.
         3. Set the time limit - the maximum time that a tap can be above the threshold
         4. Set the pulse latency - the minimum required time between one pulse and the next
         5. Set the second pulse window - maximum allowed time between end of latency and start of second pulse
         for more info check out this app note: http://cache.freescale.com/files/sensors/doc/app_note/AN4072.pdf */
        this->writeRegister(0x21, 0x7F);  // 1. enable single/double taps on all axes
        // this->writeRegister(0x21, 0x55);  // 1. single taps only on all axes
        // this->writeRegister(0x21, 0x6A);  // 1. double taps only on all axes
        this->writeRegister(0x23, 0x20);  // 2. x thresh at 2g, multiply the value by 0.0625g/LSB to get the threshold
        this->writeRegister(0x24, 0x20);  // 2. y thresh at 2g, multiply the value by 0.0625g/LSB to get the threshold
        this->writeRegister(0x25, 0x08);  // 2. z thresh at .5g, multiply the value by 0.0625g/LSB to get the threshold
        this->writeRegister(0x26, 0x30);  // 3. 30ms time limit at 800Hz odr, this is very dependent on data rate, see the app note
        this->writeRegister(0x27, 0xA0);  // 4. 200ms (at 800Hz odr) between taps min, this also depends on the data rate
        this->writeRegister(0x28, 0xFF);  // 5. 318ms (max value) between taps max
        
        /* Set up interrupt 1 and 2 */
        this->writeRegister(0x2C, 0x02);  // Active high, push-pull interrupts
        this->writeRegister(0x2D, 0x19);  // DRDY, P/L and tap ints enabled
        this->writeRegister(0x2E, 0x01);  // DRDY on INT1, P/L and taps on INT2
        
        this->setActiveMode();  // Set to active to start reading
        result = true;
    }
    return result;
}

void MMA8452Accelerometer::readRawData(short *destination)
{
    unsigned char rawData[6];  // x/y/z accel register data stored here
    
    this->readRegisters(0x01, 6, &rawData[0]);  // Read the six raw data registers into data array
    
    /* loop to calculate 12-bit ADC and g value for each axis */
    for (int i=0; i<6; i+=2) {
        destination[i/2] = ((rawData[i] << 8) | rawData[i+1]) >> 4;  // Turn the MSB and LSB into a 12-bit value
        if (rawData[i] > 0x7F) {
            // If the number is negative, we have to make it so manually (no 12-bit data type)
            destination[i/2] = ~destination[i/2] + 1;
            destination[i/2] *= -1;  // Transform into negative 2's complement #
        }
    }
}

void MMA8452Accelerometer::convertRawDataIntoAccelData(short *rawVector, float *vector)
{
    int ii;
    
    for (int ii = 0; ii < 3; ii++) {
        vector[ii] = (float)rawVector[ii] / ((1<<12)/(2 * _fullScaleRange));  // get actual g value, this depends on scale being set
    }
}

/* Sets the MMA8452 to standby mode.
   It must be in standby to change most register settings */
void MMA8452Accelerometer::setStandbyMode(void)
{
    unsigned char c = this->readRegister(0x2A);
    this->writeRegister(0x2A, c & ~(0x01));
}

/* Sets the MMA8452 to active mode.
   Needs to be in this mode to output data */
void MMA8452Accelerometer::setActiveMode(void)
{
    unsigned char c = this->readRegister(0x2A);
    this->writeRegister(0x2A, c | 0x01);
}

/* Read i registers sequentially, starting at address 
   into the dest unsigned char arra */
void MMA8452Accelerometer::readRegisters(unsigned char address, int i, unsigned char * dest)
{
    i2cSendStart();
    i2cWaitForComplete();
    
    i2cSendByte((_address<<1));	// write 0xB4
    i2cWaitForComplete();
    
    i2cSendByte(address);	// write register address
    i2cWaitForComplete();
    
    i2cSendStart();
    i2cSendByte((_address<<1)|0x01);	// write 0xB5
    i2cWaitForComplete();
    for (int j=0; j<i; j++) {
        i2cReceiveByte(-1);
        i2cWaitForComplete();
        dest[j] = i2cGetReceivedByte();	// Get MSB result
    }
    i2cWaitForComplete();
    i2cSendStop();
    
    cbi(TWCR, TWEN);	// Disable TWI
    sbi(TWCR, TWEN);	// Enable TWI
}

/* read a single unsigned char from address and return it as a byte */
unsigned char MMA8452Accelerometer::readRegister(unsigned char address)
{
    unsigned char data;
    byte x = address;
    
    i2cSendStart();
    i2cWaitForComplete();
    
    i2cSendByte((_address<<1));	// write 0xB4
    i2cWaitForComplete();
    
    i2cSendByte(address);	// write register address
    i2cWaitForComplete();
    
    i2cSendStart();
    
    i2cSendByte((_address<<1)|0x01);	// write 0xB5
    i2cWaitForComplete();
    i2cReceiveByte(-1);
    i2cWaitForComplete();
    
    data = i2cGetReceivedByte();	// Get MSB result
    i2cWaitForComplete();
    i2cSendStop();
    
    cbi(TWCR, TWEN);	// Disable TWI
    sbi(TWCR, TWEN);	// Enable TWI
    
    return data;
}

/* Writes a single unsigned char (data) into address */
void MMA8452Accelerometer::writeRegister(unsigned char address, unsigned char data)
{
    i2cSendStart();
    i2cWaitForComplete();
    
    i2cSendByte((_address<<1));// write 0xB4
    i2cWaitForComplete();
    
    i2cSendByte(address);	// write register address
    i2cWaitForComplete();
    
    i2cSendByte(data);
    i2cWaitForComplete();
    
    i2cSendStop();
}

