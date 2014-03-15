#ifndef Accelerometer_h
#define Accelerometer_h

class Accelerometer
{
public:
    virtual unsigned char init() = 0;
    virtual void readRawData(short *rawVector) = 0;
    virtual void convertRawDataIntoAccelData(short *rawVector, float *vector) = 0;
    virtual void readAccelData(float *vector);
};

#endif //Accelerometer_h
