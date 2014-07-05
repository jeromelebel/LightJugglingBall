#include "UDPLogger.h"

#define NO_IDENTIFIER 0xFF
#define LISTEN_PORT 1975
#define TALK_TO_PORT 1974

UDPLogger::UDPLogger(void)
{
    this->identifier = NO_IDENTIFIER;
    this->lastIdentifierRequest = millis();
}

void UDPLogger::begin(void)
{
    IPAddress addressToTalkTo(((uint32_t)Network.localIP()) | ~Network.subnetMask());
    
    udp.begin(LISTEN_PORT);
    udp.beginPacket(addressToTalkTo, TALK_TO_PORT);
    Serial.println(addressToTalkTo[0]);
    Serial.println(addressToTalkTo[1]);
    Serial.println(addressToTalkTo[2]);
    Serial.println(addressToTalkTo[3]);
}

void UDPLogger::loop(void)
{
    if (this->identifier == NO_IDENTIFIER) {
        if (millis() - this->lastIdentifierRequest > 1000) {
            Serial.println("ping");
            udp.write(&this->identifier, sizeof(this->identifier));
            this->lastIdentifierRequest = millis();
        }
        if (udp.parsePacket() > 0) {
            Serial.println("recevied: ");
            udp.read(&this->identifier, sizeof(this->identifier));
            Serial.println(this->identifier);
        }
    }
}