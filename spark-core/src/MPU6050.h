
class MPU6050
{
public:
  uint8_t read(int start, uint8_t *buffer, size_t size);
  uint8_t write(int start, const uint8_t *pData, size_t size);
  uint8_t readWho(uint8_t *error);
  
private:
  int write_reg(int reg, uint8_t data);
};
