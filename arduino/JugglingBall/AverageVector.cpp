#include "AverageVector.h"
#include <Arduino.h>

AverageVector::AverageVector(unsigned long int maxTime)
{
    _maxTime = maxTime;
    _vector[0] = 0;
    _vector[1] = 0;
    _vector[2] = 0;
    _lastTime = 0;
    _count = 0;
}

void AverageVector::addCurrentValue(float *value)
{
    _vector[0] += value[0];
    _vector[1] += value[1];
    _vector[2] += value[2];
    _count++;
}

char AverageVector::isTimeOut(unsigned long int currentTime)
{
    return currentTime - _lastTime > _maxTime;
}

float AverageVector::averageVectorNorm(void)
{
    return sqrt((_vector[0] * _vector[0] / (float)(_count * _count)) + (_vector[1] * _vector[1] / (float)(_count * _count)) + (_vector[2] * _vector[2] / (float)(_count * _count)));
}

float AverageVector::previousAverageVectorNorm(void)
{
    return sqrt((_previousVector[0] * _previousVector[0] / (float)(_previousCount * _previousCount)) + (_previousVector[1] * _previousVector[1] / (float)(_previousCount * _previousCount)) + (_previousVector[2] * _previousVector[2] / (float)(_previousCount * _previousCount)));
}

float AverageVector::averageValueAtDimension(int index)
{
    return _vector[index] / _count;
}

void AverageVector::resetAverageVector(unsigned long int currentTime)
{
    _previousVector[0] = _vector[0];
    _previousVector[1] = _vector[1];
    _previousVector[2] = _vector[2];
    _previousCount = _count;
    _vector[0] = 0;
    _vector[1] = 0;
    _vector[2] = 0;
    _count = 0;
    _lastTime = currentTime;
}

unsigned long int AverageVector::valueCount(void)
{
    return _count;
}
