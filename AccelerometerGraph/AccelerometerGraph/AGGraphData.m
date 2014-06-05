//
//  AGGraphData.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import "AGGraphData.h"

@implementation AGGraphData

- (id)initWithName:(NSString *)name
{
    if (self = [self init]) {
        self.name = name;
    }
    return self;
}

- (float)valueAtIndex:(NSUInteger)index
{
    NSAssert(index < _valueCount, @"index too high %lu %lu", index, _valueCount);
    index = _valueCount - 1 - index;
    index += _valueCursor;
    if (index >= _valueCount) {
        index -= _valueCount;
    }
    return _buffer[index];
}

- (void)_computeMinAndMaxValues
{
    _maxValue = _buffer[0];
    _minValue = _buffer[0];
    for (NSUInteger index = 0; index < _valueCount; index++) {
        if (_maxValue < _buffer[index]) _maxValue = _buffer[index];
        if (_minValue > _buffer[index]) _minValue = _buffer[index];
    }
}

- (void)setBufferSize:(NSUInteger)newBufferSize
{
    float *newBuffer;
    NSUInteger firstChunkCount, secondChunkCount;
    
    if (_valueCountLimit > 0 && _valueCountLimit < newBufferSize) {
        newBufferSize = _valueCountLimit;
    }
    newBuffer = malloc(newBufferSize * sizeof(*_buffer));
    firstChunkCount = _valueCount - _valueCursor;
    secondChunkCount = _valueCursor;
    if (newBufferSize > firstChunkCount) {
        memcpy(newBuffer, _buffer + _valueCursor, firstChunkCount * sizeof(*_buffer));
        if (newBufferSize > firstChunkCount + secondChunkCount) {
            memcpy(newBuffer + firstChunkCount, _buffer, secondChunkCount * sizeof(*_buffer));
        } else {
            memcpy(newBuffer + firstChunkCount, _buffer, (newBufferSize - firstChunkCount) * sizeof(*_buffer));
        }
    } else {
        memcpy(newBuffer, _buffer + _valueCursor, newBufferSize * sizeof(*_buffer));
    }
    free(_buffer);
    _buffer = newBuffer;
    _bufferSize = newBufferSize;
    if (_valueCount >= _bufferSize) {
        _valueCount = _bufferSize;
        _valueCursor = 0;
        [self _computeMinAndMaxValues];
        [[NSNotificationCenter defaultCenter] postNotificationName:NewValueAGGraphDataNotification object:self];
    } else {
        _valueCursor = _valueCount;
    }
}

- (void)_test
{
    if (!(_valueCount <= _bufferSize)) {
        NSLog(@"1");
    }
    NSAssert(_valueCount <= _bufferSize, @"too much value count valueCount %ld bufferSize %ld", _valueCount, _bufferSize);
    if (!(_valueCount == _bufferSize || _valueCursor == _valueCount)) {
        NSLog(@"2");
    }
    NSAssert(_valueCount == _bufferSize || _valueCursor == _valueCount, @"cursor should be set to 0, valueCursor %ld valueCount %ld bufferSize %ld", _valueCursor, _valueCount, _bufferSize);
    if (!(_valueCursor <= _bufferSize)) {
        NSLog(@"3");
    }
    NSAssert(_valueCursor <= _bufferSize, @"cursor too far cursor %ld buffer size %ld", _valueCursor, _bufferSize);
    if (!(_valueCursor <= _valueCount)) {
        NSLog(@"4");
    }
    NSAssert(_valueCursor <= _valueCount, @"too much value, cursor %ld count %ld", _valueCursor, _valueCount);
}

- (void)addValue:(float)newValue
{
    float oldValue;
    BOOL hasOldValue = NO;
    
    [self _test];
    if (_maxValue < newValue) _maxValue = newValue;
    if (_minValue > newValue) _minValue = newValue;
    
    if (_valueCountLimit > 0 && _valueCount == _valueCountLimit) {
        hasOldValue = YES;
        oldValue = _buffer[_valueCursor];
    } else if (_bufferSize == _valueCount) {
        NSUInteger newBufferSize;
        
        newBufferSize = _bufferSize * 1.5;
        if (_valueCountLimit > 0 && newBufferSize > _valueCountLimit) {
            newBufferSize = _valueCountLimit;
        } else if (newBufferSize == 0) {
            newBufferSize = 5;
        }
        [self setBufferSize:newBufferSize];
    }
    _buffer[_valueCursor] = newValue;
    _valueCursor++;
    if (_valueCursor == _valueCount + 1) {
        _valueCount++;
    }
    if (_valueCursor == _bufferSize) {
        _valueCursor = 0;
    }
    [self _test];
    
    if (hasOldValue
        && ((oldValue == _maxValue && newValue != oldValue) 
            || (oldValue == _minValue && newValue != oldValue))) {
            [self _computeMinAndMaxValues];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NewValueAGGraphDataNotification object:self];
}

@end
