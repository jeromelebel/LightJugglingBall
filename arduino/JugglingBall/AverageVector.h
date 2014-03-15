class AverageVector
{
    float _previousVector[3];
    unsigned long int _previousCount;
    float _vector[3];
    unsigned long int _lastTime;
    unsigned long int _count;
    unsigned long int _maxTime;
    
public:
    AverageVector(unsigned long int maxTime);

    void addCurrentValue(float *value);
    float averageValueAtDimension(int index);
    float averageVectorNorm(void);
    float previousAverageVectorNorm(void);
    unsigned long int valueCount(void);
    void resetAverageVector(unsigned long int currentTime);
    char isTimeOut(unsigned long int currentTime);
};
