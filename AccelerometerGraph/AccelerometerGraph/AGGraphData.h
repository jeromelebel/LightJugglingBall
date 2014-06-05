//
//  AGGraphData.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NewValueAGGraphDataNotification @"NewValueAGGraphDataNotification"

@interface AGGraphData : NSObject
{
    float *_buffer;
    float _maxValue;
    float _minValue;
    NSUInteger _bufferSize;
    NSUInteger _valueCursor;
    NSUInteger _valueCountLimit;
    NSUInteger _valueCount;
    
    NSString *_name;
}

@property (nonatomic, readwrite, assign) NSUInteger valueCountLimit;
@property (nonatomic, readonly, assign) NSUInteger valueCount;
@property (nonatomic, readonly, assign) float minValue;
@property (nonatomic, readonly, assign) float maxValue;
@property (nonatomic, readwrite, retain) NSString *name;

- (id)initWithName:(NSString *)name;
- (void)addValue:(float)value;
- (float)valueAtIndex:(NSUInteger)index;

@end
