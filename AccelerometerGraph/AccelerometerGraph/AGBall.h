//
//  AGBall_private.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 03/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommunicationStruct.h"

@class AGGraphData;

@interface AGBall : NSObject
@property (nonatomic, readonly, strong) NSData *ipAddress;
@property (nonatomic, readonly, assign) BALL_IDENTIFIER identifer;
@property (nonatomic, readonly, strong) AGGraphData *xGraphData;
@property (nonatomic, readonly, strong) AGGraphData *yGraphData;
@property (nonatomic, readonly, strong) AGGraphData *zGraphData;
@property (nonatomic, readonly, strong) AGGraphData *normGraphData;
@property (nonatomic, readonly, strong) AGGraphData *xRotationGraphData;
@property (nonatomic, readonly, strong) AGGraphData *yRotationGraphData;
@property (nonatomic, readonly, strong) AGGraphData *zRotationGraphData;
@property (nonatomic, readonly, strong) AGGraphData *rotationNormGraphData;

- (instancetype)initWithIdentifier:(BALL_IDENTIFIER)identifier ipAddress:(NSData *)ipAddress;

@end
