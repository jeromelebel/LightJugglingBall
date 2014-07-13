#include "UDPLogger.h"

#define LISTEN_PORT 1975

UDPLogger::UDPLogger(void)
{
    this->identifier = BallIdentifierMax;
    this->lastIdentifierRequest = millis();
    this->_skipNumber = 10;
}

void UDPLogger::begin(void)
{
    uint32_t localIP = Network.localIP();
    this->addressToTalkTo = IPAddress(localIP | ~Network.subnetMask());
    
    udp.begin(LISTEN_PORT);
}

void UDPLogger::loopWithValues(int16_t xAccel, int16_t yAccel, int16_t zAccel, int16_t xGyro, int16_t yGyro, int16_t zGyro)
{
    if (this->identifier == BallIdentifierMax) {
        if (millis() - this->lastIdentifierRequest > 1000) {
            Serial.println("ping");
            udp.beginPacket(this->addressToTalkTo, ServerPort);
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
        static int skipValues = 0;
        
        skipValues++;
        if (skipValues > this->_skipNumber) {
            static uint16_t timestamp = 0;
            
            BallPacket packet = { this->identifier, timestamp++, xAccel, yAccel, zAccel, xGyro, yGyro, zGyro };
            udp.beginPacket(this->addressToTalkTo, ServerPort);
            udp.write((const uint8_t *)&packet, sizeof(packet));
            udp.endPacket();
            skipValues = 0;
        }
    }
}
