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
    if (data.length == sizeof(AGBallID) + (sizeof(float) * 6)) {
        float *value;
        const char *buffer = data.bytes + sizeof(AGBallID);
        
        value = (float *)buffer;
        [self.xGraphData addValue:value[0]];
        [self.yGraphData addValue:value[1]];
        [self.zGraphData addValue:value[2]];
        [self.xRotationGraphData addValue:value[3]];
        [self.yRotationGraphData addValue:value[4]];
        [self.zRotationGraphData addValue:value[5]];
        [self.normGraphData addValue:sqrtf((value[0] * value[0]) + (value[1] * value[1]) + (value[2] * value[2]))];
        [self.rotationNormGraphData addValue:sqrtf((value[3] * value[3]) + (value[4] * value[4]) + (value[5] * value[5]))];
    }
}

@end
