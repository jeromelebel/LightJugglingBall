#include "application.h"
#include "MPU6050.h"
#include "Adafruit_NeoPixel.h"
#include <math.h>

#define PIXEL_COUNT  16
#define LED_MODULO 4

Adafruit_NeoPixel strip1 = Adafruit_NeoPixel(PIXEL_COUNT, D2, WS2812B);
Adafruit_NeoPixel strip2 = Adafruit_NeoPixel(PIXEL_COUNT, D3, WS2812B);
MPU6050 mpu = MPU6050(MPU6050::Address0);

static bool ballTurnedOn = false;

uint32_t Wheel(byte WheelPos);

void rainbow(uint8_t modulo, uint8_t wait);
void ball(void);

void blinkLED(unsigned int count, unsigned int mydelay)
{
    int led = D7;
    
    pinMode(led, OUTPUT);
    while (count > 0) {
        digitalWrite(led, HIGH);
        delay(mydelay);               // Wait for 1000mS = 1 second
        digitalWrite(led, LOW); 
        delay(mydelay);               // Wait for 1 second in off mode
        count--;
    }
}

void setup()
{
    uint8_t error, c;
    
    Serial.begin(115200);
    Serial.println("started!");
    strip1.begin();
    strip1.show();
    blinkLED(4, 250);
    
    Wire.begin();
    Serial.println("prout");
    c = mpu.readWho(&error);
    Serial.print("WHO_AM_I : ");
    Serial.print(c,HEX);
    Serial.print(", error = ");
    Serial.println(error,DEC);

    c = mpu.readSleepBit(&error);
    Serial.print("PWR_MGMT_1 : ");
    Serial.print(c,HEX);
    Serial.print(", error = ");
    Serial.println(error,DEC);
    
    mpu.writeAccelFullScaleRange(16, NULL);

    mpu.writeSleepBit(0, &error);
    Serial.print("PWR_MGMT_1 write : error = ");
    Serial.println(error,DEC);
}

void setBallLight(uint32_t color)
{
    uint8_t i;

    for(i = 0; i < PIXEL_COUNT; i++) {
        if (i % LED_MODULO == 0) {
            strip1.setPixelColor(i, color);
            strip2.setPixelColor(i, color);
        } else {
            strip1.setPixelColor(i, 0);
            strip2.setPixelColor(i, 0);
        }
    }
    strip1.show();
    strip2.show();
}

void loop()
{
    MPU6050::Values values;
    float norme;

    mpu.readValues(&values, NULL);
    norme = sqrtf((float)values.xAccel * (float)values.xAccel + (float)values.yAccel * (float)values.yAccel + (float)values.zAccel * (float)values.zAccel) / 32767.0 * 16.0;
    Serial.println(norme);
    if (norme < 0.6 && !ballTurnedOn) {
        ballTurnedOn = true;
        setBallLight(0xFFFFFF);
    } else if (norme > 0.6 && ballTurnedOn) {
        ballTurnedOn = false;
        setBallLight(0x000000);
    }
}

void ball(void)
{
    static double speed = 5;
    static double friction = 0.01;
    static double position = 0;
    
    double pi = 3.14159;
    MPU6050::Values values;
    double forceAngle = 00;
    double forceNorme = 0;
    uint8_t ii, count, led;
    Serial.print("position ");
    Serial.println(position);
    mpu.readValues(&values, NULL);
    Serial.print("x accel ");
    Serial.print(values.xAccel);
    Serial.print(" y accel ");
    Serial.println(values.yAccel);
    values.yAccel = -values.yAccel;
    if (values.xAccel == 0) {
        if (values.yAccel < 0) {
            forceAngle = -90;
        } else {
            forceAngle = 90;
        }
    } else {
        forceAngle = atan((double)values.yAccel / (double)values.xAccel) * 180 / pi;
        if (values.xAccel < 0) {
            forceAngle -= 180;
        }
    }
    forceNorme = sqrt(values.yAccel * values.yAccel + values.xAccel * values.xAccel);
    forceNorme = forceNorme / 50000.0;
    Serial.print("angle ");
    Serial.print(forceAngle);
    Serial.print(" diff angle ");
    Serial.print(position - forceAngle);
    Serial.print(" force ");
    Serial.println(sin((position - forceAngle) * pi / 180.0) * forceNorme);
    speed -= sin((position - forceAngle) * pi / 180.0) * forceNorme;
    if (speed > 0 && speed > friction) {
        speed -= friction;
    } else if (speed < 0 && -speed > friction) {
        speed += friction;
    } else {
        speed = 0;
    }
    position += speed;
    while (position > 360) {
        position -= 360;
    }
    while (position < 0) {
        position += 360;
    }
    count = strip1.numPixels();
    led = position * count / 360.0;
    for (ii = 0; ii < count; ii++) {
        if (led == ii) {
            strip1.setPixelColor(ii, 0x0f0f0f);
        } else {
            strip1.setPixelColor(ii, 0);
        }
    }
    Serial.print("position ");
    Serial.print(position);
    Serial.print(" speed ");
    Serial.print(speed);
    Serial.print(" led ");
    Serial.println(led);
    strip1.show();
}

void rainbow(uint8_t modulo, uint8_t wait)
{
  uint16_t i, j;

  for(j=0; j<256; j++) {
    for(i=0; i<strip1.numPixels(); i++) {
      if (i % modulo == 0) {
        strip1.setPixelColor(i, Wheel((i+j) & 255));
      } else {
        strip1.setPixelColor(i, 0);
      }
    }
    strip1.show();
    delay(wait);
  }
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
   return strip1.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if(WheelPos < 170) {
   WheelPos -= 85;
   return strip1.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170;
   return strip1.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}