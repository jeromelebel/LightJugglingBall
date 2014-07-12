#include "application.h"

class UDPLogger
{
protected:
    UDP udp;
    LOGGER_IDENTIFIER identifier;
    unsigned long lastIdentifierRequest;
    IPAddress addressToTalkTo;
    unsigned int _skipNumber;
    
public:
    UDPLogger();
    
    void begin(void);
    void loopWithValues(int16_t xAccel, int16_t yAccel, int16_t zAccel, int16_t xGyro, int16_t yGyro, int16_t zGyro);
    void setSkipValues(unsigned int value) { this->_skipNumber = value; };
    unsigned int skipValues(void) { return this->_skipNumber; };
};
