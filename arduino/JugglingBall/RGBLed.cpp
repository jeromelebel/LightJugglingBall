#include "RGBLed.h"
#include <Arduino.h>

RGBLed::RGBLed(unsigned int redPin, unsigned int greenPin, unsigned int bluePin)
{
    _ledPins[0] = redPin;
    _ledPins[1] = greenPin;
    _ledPins[2] = bluePin;
    _ledValues[0] = 0;
    _ledValues[1] = 0;
    _ledValues[2] = 0;
    _ledStateHistory[0] = 0;
    _ledStateHistory[1] = 0;
    _ledStateHistory[2] = 0;
}

void RGBLed::setup(void)
{
    pinMode(_ledPins[0], OUTPUT);
    pinMode(_ledPins[1], OUTPUT);
    pinMode(_ledPins[2], OUTPUT);
}

void RGBLed::setColor(float red, float green, float blue)
{
    _colors[0] = red;
    _colors[1] = green;
    _colors[2] = blue;
    
    /* Now we'll calculate the accleration value into actual g's */
    for (int i=0; i<3; i++) {
        float value;
        char newState;
        
        value = _colors[i];
        if (value < 0) {
            value = 0;
        } else if (value > 1) {
            value = 1;
        }
        value = value * RGBLedStateNumber;
        if ((int)(value + 0.5) >= (int)(value + 1.0)) {
            value = (int)(value + 1);
        } else {
            value = (int)(value);
        }
        
        if (value < 0) value = 0;
        if (value > RGBLedStateNumber) value = RGBLedStateNumber;
        
        if (value > _ledValues[i]) {
            newState = 1;
        } else if (value < _ledValues[i]) {
            newState = 0;
        } else {
            newState = (_ledStateHistory[i] >= (1 << (RGBLedStateNumber - 1)))?1:0;
        }
        if (_ledStateHistory[i] >= (1 << (RGBLedStateNumber - 1))) {
            _ledValues[i]--;
        }
        _ledValues[i] += newState;
        _ledStateHistory[i] = ((_ledStateHistory[i] << 1) + newState) & RGBLedMaxValue;
        digitalWrite(_ledPins[i], newState?255:0);
    }
}

float *RGBLed::color(void)
{
    return _colors;
}

