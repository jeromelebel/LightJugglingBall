#include "Accelerometer.h"

typedef enum {
    MMA8452AddressD = 0x1D,
    MMA8452AddressC = 0x1C
} MMA8452Address;

typedef enum {
    MMA8452ScaleRange2g = 2,
    MMA8452ScaleRange4g = 4,
    MMA8452ScaleRange8g = 8,
} MMA8452ScaleRange;

typedef enum {
    MMA8452DataRate800Hz = 0,
    MMA8452DataRate400Hz = 1,
    MMA8452DataRate200Hz = 2,
    MMA8452DataRate100Hz = 3,
    MMA8452DataRate50Hz = 4,
    MMA8452DataRate12Hz = 5,
    MMA8452DataRate6Hz = 6,
    MMA8452DataRate1Hz = 7,
} MMA8452DataRate;

class MMA8452Accelerometer : public Accelerometer
{
    MMA8452Address _address;
    MMA8452ScaleRange _fullScaleRange;
    MMA8452DataRate _dataRate;
    
    void setStandbyMode(void);
    void setActiveMode(void);
    void readRegisters(unsigned char address, int i, unsigned char * dest);
    unsigned char readRegister(unsigned char address);
    void writeRegister(unsigned char address, unsigned char data);
    
public:
    MMA8452Accelerometer(MMA8452Address address, MMA8452ScaleRange fullScaleRange, MMA8452DataRate dataRate);
    unsigned char init();
    void readRawData(short *rawVector);
    void convertRawDataIntoAccelData(short *rawVector, float *vector);
};
