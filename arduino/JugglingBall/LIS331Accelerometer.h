#include "Accelerometer.h"

typedef enum {
    LIS331FirstAddress = 0x18,
    LIS331SecondAddress = 0x19
} LIS331Address;

typedef enum {
    LIS331ScaleRange2g = 2,
    LIS331ScaleRange4g = 4,
    LIS331ScaleRange8g = 8,
} LIS331ScaleRange;

typedef enum {
    LIS331DataRate800Hz = 0,
    LIS331DataRate400Hz = 1,
    LIS331DataRate200Hz = 2,
    LIS331DataRate100Hz = 3,
    LIS331DataRate50Hz = 4,
    LIS331DataRate12Hz = 5,
    LIS331DataRate6Hz = 6,
    LIS331DataRate1Hz = 7,
} LIS331DataRate;

class LIS331Accelerometer : public Accelerometer
{
    LIS331Address _address;
    LIS331ScaleRange _fullScaleRange;
    LIS331DataRate _dataRate;
    
    void setStandbyMode(void);
    void setActiveMode(void);
    void readRegisters(unsigned char address, int i, unsigned char * dest);
    unsigned char readRegister(unsigned char address);
    void writeRegister(unsigned char address, unsigned char data);
    
public:
    LIS331Accelerometer(LIS331Address address, LIS331ScaleRange fullScaleRange, LIS331DataRate dataRate);
    unsigned char init();
    void readRawData(short *rawVector);
    void convertRawDataIntoAccelData(short *rawVector, float *vector);
};
