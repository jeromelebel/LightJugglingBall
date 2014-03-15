
#define RGBLedStateNumber 8
#define RGBLedMaxValue ((1 << RGBLedStateNumber) - 1)

class RGBLed
{
    int _ledPins[3];
    unsigned int _ledValues[3];
    unsigned int _ledStateHistory[3];
    float _colors[3];
    
public:
    RGBLed(unsigned int redPin, unsigned int greenPin, unsigned int bluePin);
    void setup(void);
    void setColor(float red, float green, float blue);
    float *color(void);
};

