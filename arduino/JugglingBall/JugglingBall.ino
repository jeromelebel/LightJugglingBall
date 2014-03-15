#include "AverageVector.h"
#include "RGBLed.h"
#include "MMA8452Accelerometer.h"
#include "EEPROMControler.h"
#include <EEPROM.h>

#define PRINT_COLOR_INFO 0
#define PRINT_ALL_VALUES 1
#define AVERAGE_FORCE_TIME 50
#define AVERAGE_PRINT_TIME 100

RGBLed led1(2, 3, 4);
RGBLed led2(7, 6, 5);
MMA8452Accelerometer *accelerometer;

int availableMemory()
{
  int size = 2048; // Use 2048 with ATmega328
  byte *buf;

  while ((buf = (byte *) malloc(--size)) == NULL);
  free(buf);

  return size;
}

void setup()
{
    Serial.begin(115200);
    
    led1.setup();
    led2.setup();
    
    accelerometer = new MMA8452Accelerometer(MMA8452AddressD, MMA8452ScaleRange8g, MMA8452DataRate800Hz);

    if (accelerometer && accelerometer->init()) {
        Serial.println("MMA8452A found");
        led1.setColor(0, 1, 0);
        led2.setColor(0, 0, 1);
        delay(100);
        led1.setColor(0, 0, 1);
        led2.setColor(0, 1, 0);
        delay(100);
        led1.setColor(0, 1, 0);
        led2.setColor(0, 0, 1);
        delay(100);
        led1.setColor(0, 0, 1);
        led2.setColor(0, 1, 0);
        delay(100);
        
        led1.setColor(0, 0, 0);
        led2.setColor(0, 0, 0);
        
    } else {
        Serial.println("no accelerometer found");
        led1.setColor(1, 0, 0);
        led2.setColor(1, 0, 0);
        while (1);
    }
}

void printAccel(float *accelG)
{
    for (int i=0; i<3; i++) {
        Serial.print(accelG[i]);
        Serial.print("\t\t");
    }
    Serial.println();
}

typedef enum {
    LEDStateOff,
    LEDStateWillOn,
    LEDStateOn,
    LEDStateWillOff,
} LEDState;

AverageVector averageVector(AVERAGE_FORCE_TIME);
AverageVector printAverageVector(AVERAGE_PRINT_TIME);
AverageVector throwingAverageVector(-1);
unsigned long int catchTime = 0;

LEDState ledState = LEDStateOff;

void loop()
{  
    short accelCount[3] = { 0, 0, 0 };  // Stores the 12-bit signed value
    float accelG[3] = { 0, 0, 0 };  // Stores the real accel value in g's
    unsigned long currentTime = millis();

    if (accelerometer) {
        accelerometer->readRawData(accelCount);  // Read the x/y/z adc values
        accelerometer->convertRawDataIntoAccelData(accelCount, accelG);
    }
    
    averageVector.addCurrentValue(accelG);
    if ((ledState == LEDStateOff) && (currentTime - catchTime > 50)) {
        throwingAverageVector.addCurrentValue(accelG);
    }
    if (averageVector.isTimeOut(currentTime)) {
        if (ledState == LEDStateOff && ((averageVector.previousAverageVectorNorm() - averageVector.averageVectorNorm() > 3 && averageVector.averageVectorNorm() < 0.75) || (averageVector.previousAverageVectorNorm() < 0.75 && averageVector.averageVectorNorm() < 0.75))) {
            ledState = LEDStateOn;
            if (throwingAverageVector.averageVectorNorm() > 2.0) {
                led1.setColor(1, 0, 0);
                led2.setColor(1, 0, 0);
            } else {
                led1.setColor(1, 1, 1);
                led2.setColor(1, 1, 1);
            }
            if (PRINT_COLOR_INFO) {
                Serial.print(currentTime - catchTime);
                Serial.print(" ");
                Serial.print(throwingAverageVector.valueCount());
                Serial.print(" ");
                Serial.println(throwingAverageVector.averageVectorNorm());
            }
        } else if (ledState == LEDStateOn && (averageVector.averageVectorNorm() > 0.8)) {
            led1.setColor(0, 0, 0);
            led2.setColor(0, 0, 0);
            ledState = LEDStateOff;
            throwingAverageVector.resetAverageVector(-1);
            catchTime = currentTime;
        }
        averageVector.resetAverageVector(currentTime);
    }
    if (PRINT_ALL_VALUES) {
        printAverageVector.addCurrentValue(accelG);
        if (printAverageVector.isTimeOut(currentTime)) {
            Serial.print(printAverageVector.averageValueAtDimension(0));
            Serial.print(" ");
            Serial.print(printAverageVector.averageValueAtDimension(1));
            Serial.print(" ");
            Serial.print(printAverageVector.averageValueAtDimension(2));
            Serial.print(" ");
            Serial.println(printAverageVector.valueCount());
            printAverageVector.resetAverageVector(currentTime);
        }
    }
}
