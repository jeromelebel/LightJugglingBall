#include "UDPLogger.h"

#define NO_IDENTIFIER 0xFFFF
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
    this->addressToTalkTo = IPAddress(localIP | ~Network.subnetMask());
    
    udp.begin(LISTEN_PORT);
    Serial.println(this->addressToTalkTo[0]);
    Serial.println(this->addressToTalkTo[1]);
    Serial.println(this->addressToTalkTo[2]);
    Serial.println(this->addressToTalkTo[3]);
}

void UDPLogger::loopWithValues(int16_t xAccel, int16_t yAccel, int16_t zAccel, int16_t xGyro, int16_t yGyro, int16_t zGyro)
{
    if (this->identifier == NO_IDENTIFIER) {
        if (millis() - this->lastIdentifierRequest > 1000) {
            Serial.println("ping");
            udp.beginPacket(this->addressToTalkTo, TALK_TO_PORT);
            udp.write((unsigned char*)&this->identifier, sizeof(this->identifier));
            udp.endPacket();
            this->lastIdentifierRequest = millis();
        }
        if (udp.parsePacket() > 0) {
            Serial.println("recevied: ");
            udp.read((unsigned char*)&this->identifier, sizeof(this->identifier));
            Serial.println(this->identifier);
        }
    } else {
        xAccel = 0;
        yAccel = 0x0F;
        zAccel = 0xF0;
        xGyro = 0x00FF;
        yGyro = 0xFF00;
        zGyro = 0xFFFF;
        LOGGER_PACKET packet = { this->identifier, xAccel, yAccel, zAccel, xGyro, yGyro, zGyro };
        udp.beginPacket(this->addressToTalkTo, TALK_TO_PORT);
        udp.write((const uint8_t *)&packet, sizeof(packet));
        udp.endPacket();
    }
}