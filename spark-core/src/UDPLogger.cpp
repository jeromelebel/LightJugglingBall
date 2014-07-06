#include "UDPLogger.h"

#define NO_IDENTIFIER 0xFF
#define LISTEN_PORT 1975
#define TALK_TO_PORT 1974

typedef struct {
    LOGGER_IDENTIFIER identifier;
    int16_t values[6];
} LOGGER_PACKET;

UDPLogger::UDPLogger(void)
{
    this->identifier = NO_IDENTIFIER;
    this->lastIdentifierRequest = millis();
}

void UDPLogger::begin(void)
{
    uint32_t localIP = Network.localIP();
    IPAddress addressToTalkTo(localIP | ~Network.subnetMask());
    
    udp.begin(LISTEN_PORT);
    udp.beginPacket(addressToTalkTo, TALK_TO_PORT);
    Serial.println(addressToTalkTo[0]);
    Serial.println(addressToTalkTo[1]);
    Serial.println(addressToTalkTo[2]);
    Serial.println(addressToTalkTo[3]);
}

void UDPLogger::loopWithValues(int16_t xAccel, int16_t yAccel, int16_t zAccel, int16_t xGyro, int16_t yGyro, int16_t zGyro)
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
    } else {
        LOGGER_PACKET packet = { this->identifier, xAccel, yAccel, zAccel, xGyro, yGyro, zGyro };
        udp.write((const uint8_t *)&packet, sizeof(packet));
    }
}