class EEPROMControler
{
    unsigned char *_buffer;
    unsigned short _usedBufferSize;
    
    void _readToEeprom(void);
    void _writeToEeprom(void);
    
public:
    EEPROMControler();
    unsigned char init(void);
    
    void flush(void);
    void writeUChar(unsigned short address, unsigned char value);
    void writeChar(unsigned short address, char value);
    void writeUShort(unsigned short address, unsigned short value);
    void writeShort(unsigned short address, short value);
    void writeULong(unsigned short address, unsigned long value);
    void writeLong(unsigned short address, long value);
    void writeFloat(unsigned short address, float value);
    void writeBuffer(unsigned short address, unsigned short length, void *buffer);

    unsigned char readUChar(unsigned short address);
    char readChar(unsigned short address);
    unsigned short readUShort(unsigned short address);
    short readShort(unsigned short address);
    unsigned long readULong(unsigned short address);
    long readLong(unsigned short address);
    float readFloat(unsigned short address);
    void readBuffer(unsigned short address, unsigned short length, void *buffer);
};
