//
//  AGBall.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 03/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGBall_private.h"
#import "AGGraphData.h"
#import "AGBallManager.h"

@interface AGBall ()
@property (nonatomic, readwrite, assign) BALL_IDENTIFIER identifer;
@property (nonatomic, readwrite, strong) AGGraphData *xGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *normGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *xRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *rotationNormGraphData;
@property (nonatomic, readwrite, assign) TIMESTAMP_TYPE lastTimeStamp;

@end

#define DATA_LENGTH 500

typedef struct {
    BALL_IDENTIFIER identifier;
    TIMESTAMP_TYPE timeStamp;
    VALUE_TYPE values[NUMBER_OF_VALUE];
} DataType;

@implementation AGBall

- (instancetype)initWithIdentifier:(BALL_IDENTIFIER)identifier ipAddress:(NSData *)ipAddress
{
    self = [self init];
    if (self) {
        self.identifer = identifier;
        self.ipAddress = ipAddress;
        self.xGraphData = [[AGGraphData alloc] init];
        self.xGraphData.valueCountLimit = DATA_LENGTH;
        self.yGraphData = [[AGGraphData alloc] init];
        self.yGraphData.valueCountLimit = DATA_LENGTH;
        self.zGraphData = [[AGGraphData alloc] init];
        self.zGraphData.valueCountLimit = DATA_LENGTH;
        self.normGraphData = [[AGGraphData alloc] init];
        self.normGraphData.valueCountLimit = DATA_LENGTH;
        self.xRotationGraphData = [[AGGraphData alloc] init];
        self.xRotationGraphData.valueCountLimit = DATA_LENGTH;
        self.yRotationGraphData = [[AGGraphData alloc] init];
        self.yRotationGraphData.valueCountLimit = DATA_LENGTH;
        self.zRotationGraphData = [[AGGraphData alloc] init];
        self.zRotationGraphData.valueCountLimit = DATA_LENGTH;
        self.rotationNormGraphData = [[AGGraphData alloc] init];
        self.rotationNormGraphData.valueCountLimit = DATA_LENGTH;
    }
    return self;
}

- (void)receiveData:(NSData *)data
{
    if (data.length == sizeof(DataType)) {
        DataType *buffer = (DataType *)data.bytes;
        float normData;
        
        if (buffer->timeStamp != self.lastTimeStamp + 1) {
            NSLog(@"value missed %d", buffer->timeStamp - self.lastTimeStamp);
            self.lastTimeStamp = buffer->timeStamp;
        } else {
            self.lastTimeStamp++;
        }
        [self.xGraphData addValue:buffer->values[0]];
        [self.yGraphData addValue:buffer->values[1]];
        [self.zGraphData addValue:buffer->values[2]];
        [self.xRotationGraphData addValue:buffer->values[3]];
        [self.yRotationGraphData addValue:buffer->values[4]];
        [self.zRotationGraphData addValue:buffer->values[5]];
        normData = sqrtf((buffer->values[0] * buffer->values[0]) + (buffer->values[1] * buffer->values[1]) + (buffer->values[2] * buffer->values[2]));
        [self.normGraphData addValue:normData];
        [self.rotationNormGraphData addValue:sqrtf((buffer->values[3] * buffer->values[3]) + (buffer->values[4] * buffer->values[4]) + (buffer->values[5] * buffer->values[5]))];
    } else {
        NSLog(@"wrong size");
    }
}

@end
