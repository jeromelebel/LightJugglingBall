
class MPU6050
{
public:
    typedef enum {
        Address0 = 0x68,
        Address1 = 0x69,
    } Address;
    typedef struct {
        int16_t xAccel;
        int16_t yAccel;
        int16_t zAccel;
        int16_t temperature;
        int16_t xGyro;
        int16_t yGyro;
        int16_t zGyro;
    } Values;
    
    MPU6050(Address address = Address0);

    uint8_t read(int start, uint8_t *buffer, size_t size);
    uint8_t write(int start, const uint8_t *pData, size_t size);
    uint8_t readWho(uint8_t *error);
    uint8_t getAddress(void) { return _address; };

    uint8_t readSleepBit(uint8_t *error);
    void writeSleepBit(int8_t sleepBit, uint8_t *error);
    
    // 2, 4, 8 or 16
    void writeAccelFullScaleRange(uint8_t fullScaleRange, uint8_t *error);
    uint8_t readAccelFullScaleRange(uint8_t *error);
    
    void readValues(Values *values, uint8_t *error);
private:
    Address _address;
    
    void writeRegister(uint8_t reg, uint8_t data, uint8_t *error);
    uint8_t readRegister(uint8_t reg, uint8_t *error);
};
