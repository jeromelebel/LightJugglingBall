#include "application.h"
// This #include statement was automatically added by the Spark IDE.
#include "MPU6050.h"

// This #include statement was automatically added by the Spark IDE.
#include "NeoPixel.h"

Adafruit_NeoPixel strip = Adafruit_NeoPixel(16, D2, WS2812B);

uint32_t Wheel(byte WheelPos);

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

void setup_() {
    strip.begin();
    strip.show();
    blinkLED(2, 250);
    Serial.begin(115200);
    Serial.println("started!");
}

void loop_() {
    Serial.println("ok");
    //rainbow(20);
}


void rainbow(uint8_t wait) {
  uint16_t i, j;

  for(j=0; j<256; j++) {
    for(i=0; i<strip.numPixels(); i++) {
      if (i % 8 == 0) {
        strip.setPixelColor(i, Wheel((i+j) & 255));
      } else {
        strip.setPixelColor(i, 0);
      }
    }
    strip.show();
    delay(wait);
  }
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
   return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if(WheelPos < 170) {
   WheelPos -= 85;
   return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170;
   return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}