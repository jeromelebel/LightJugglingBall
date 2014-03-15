#include "EEPROMControler.h"
#include <Arduino.h>
#include <avr/eeprom.h>

#define BUFFER_SIZE 1024
#define BUFFER_OFFSET 1


EEPROMControler::EEPROMControler(void)
{
    _buffer = NULL;
    _usedBufferSize = 0;
}

void EEPROMControler::_readToEeprom(void)
{
    unsigned short ii;
    
    for (ii = 0; ii < BUFFER_SIZE; ii++) {
    	_buffer[ii] = eeprom_read_byte((unsigned char *) ii);
    }
}

void EEPROMControler::_writeToEeprom(void)
{
    unsigned short ii;
    
    // first write 1 to show it's dirty
    _buffer[0] = 1;
    for (ii = 0; ii < _usedBufferSize; ii++) {
    	eeprom_write_byte((unsigned char *) ii, _buffer[ii]);
    }
    // then write 0 to show that we are finished
    eeprom_write_byte(0, 0);
}

unsigned char EEPROMControler::init(void)
{
    _buffer = (unsigned char *)malloc(BUFFER_SIZE);
    this->_readToEeprom();
    
    return _buffer[0];
}

void EEPROMControler::flush(void)
{
    this->_writeToEeprom();
}

void EEPROMControler::writeUChar(unsigned short address, unsigned char value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeChar(unsigned short address, char value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeUShort(unsigned short address, unsigned short value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeShort(unsigned short address, short value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeULong(unsigned short address, unsigned long value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeLong(unsigned short address, long value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeFloat(unsigned short address, float value)
{
    this->writeBuffer(address, sizeof(value), &value);
}

void EEPROMControler::writeBuffer(unsigned short address, unsigned short length, void *buffer)
{
    memcpy(_buffer + address + BUFFER_OFFSET, buffer, length);
}

unsigned char EEPROMControler::readUChar(unsigned short address)
{
    unsigned char value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

char EEPROMControler::readChar(unsigned short address)
{
    char value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

unsigned short EEPROMControler::readUShort(unsigned short address)
{
    unsigned short value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

short EEPROMControler::readShort(unsigned short address)
{
    short value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

unsigned long EEPROMControler::readULong(unsigned short address)
{
    unsigned long value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

long EEPROMControler::readLong(unsigned short address)
{
    long value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

float EEPROMControler::readFloat(unsigned short address)
{
    float value;
    
    this->readBuffer(address, sizeof(value), &value);
    return value;
}

void EEPROMControler::readBuffer(unsigned short address, unsigned short length, void *buffer)
{
    memcpy(buffer, _buffer + address + BUFFER_OFFSET, length);
}
