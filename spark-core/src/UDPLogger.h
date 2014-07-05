#include "application.h"

class UDPLogger
{
protected:
    UDP udp;
    unsigned char identifier;
    unsigned long lastIdentifierRequest;
    
public:
    UDPLogger();
    
    void begin(void);
    void loop(void);
};
