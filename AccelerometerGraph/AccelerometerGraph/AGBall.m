//
//  AGBall.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 03/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGBall_private.h"
#import "AGGraphData.h"

@interface AGBall ()
@property (nonatomic, readwrite, assign) AGBallID identifer;
@property (nonatomic, readwrite, strong) AGGraphData *xGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *normGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *xRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *rotationNormGraphData;

@end

@implementation AGBall

- (instancetype)initWithIdentifier:(AGBallID)identifier ipAddress:(NSData *)ipAddress
{
    self = [self init];
    if (self) {
        self.identifer = identifier;
        self.ipAddress = ipAddress;
        self.xGraphData = [[AGGraphData alloc] init];
        self.xGraphData.valueCountLimit = 1000;
        self.yGraphData = [[AGGraphData alloc] init];
        self.yGraphData.valueCountLimit = 1000;
        self.zGraphData = [[AGGraphData alloc] init];
        self.zGraphData.valueCountLimit = 1000;
        self.normGraphData = [[AGGraphData alloc] init];
        self.normGraphData.valueCountLimit = 1000;
        self.xRotationGraphData = [[AGGraphData alloc] init];
        self.xRotationGraphData.valueCountLimit = 1000;
        self.yRotationGraphData = [[AGGraphData alloc] init];
        self.yRotationGraphData.valueCountLimit = 1000;
        self.zRotationGraphData = [[AGGraphData alloc] init];
        self.zRotationGraphData.valueCountLimit = 1000;
        self.rotationNormGraphData = [[AGGraphData alloc] init];
        self.rotationNormGraphData.valueCountLimit = 1000;
    }
    return self;
}

- (void)receiveData:(NSData *)data
{
    if (data.length == sizeof(AGBallID) + (sizeof(VALUE_TYPE) * NUMBER_OF_VALUE)) {
        VALUE_TYPE *values;
        const char *buffer = data.bytes + sizeof(AGBallID);
        
        values = (VALUE_TYPE *)buffer;
        [self.xGraphData addValue:values[0]];
        [self.yGraphData addValue:values[1]];
        [self.zGraphData addValue:values[2]];
        [self.xRotationGraphData addValue:values[3]];
        [self.yRotationGraphData addValue:values[4]];
        [self.zRotationGraphData addValue:values[5]];
        [self.normGraphData addValue:sqrtf((values[0] * values[0]) + (values[1] * values[1]) + (values[2] * values[2]))];
        [self.rotationNormGraphData addValue:sqrtf((values[3] * values[3]) + (values[4] * values[4]) + (values[5] * values[5]))];
    }
}

@end
