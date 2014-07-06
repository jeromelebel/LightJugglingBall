#include "application.h"

typedef unsigned char LOGGER_IDENTIFIER;

class UDPLogger
{
protected:
    UDP udp;
    LOGGER_IDENTIFIER identifier;
    unsigned long lastIdentifierRequest;
    
public:
    UDPLogger();
    
    void begin(void);
    void loopWithValues(int16_t xAccel, int16_t yAccel, int16_t zAccel, int16_t xGyro, int16_t yGyro, int16_t zGyro);
};
