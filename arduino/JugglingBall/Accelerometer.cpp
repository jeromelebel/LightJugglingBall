#include "Accelerometer.h"

void Accelerometer::readAccelData(float *vector)
{
    short rawData[3];
    
    this->readRawData(rawData);
    this->convertRawDataIntoAccelData(rawData, vector);
}
