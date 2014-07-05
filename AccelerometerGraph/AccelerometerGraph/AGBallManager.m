//
//  AGBallManager.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 03/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGBallManager.h"
#import "AGUDPServer.h"
#import "AGBall.h"
#import "AGBall_private.h"

@interface AGBallManager ()
@property (nonatomic, readwrite, strong) AGUDPServer *managerServer;
@property (nonatomic, readwrite, strong) AGUDPServer *dataServer;
@property (nonatomic, readwrite, strong) NSMutableArray *balls;
@property (nonatomic, readwrite, assign) AGBallID firstBallID;

@end

@interface AGBallManager (AGUDPServerDelegate) <AGUDPServerDelegate>
@end

@implementation AGBallManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.managerServer = [[AGUDPServer alloc] initWithPort:1974];
        self.managerServer.delegate = self;
        [self.managerServer startServer];
        self.dataServer = [[AGUDPServer alloc] initWithPort:1975];
        self.dataServer.delegate = self;
        [self.dataServer startServer];
        self.balls = [[NSMutableArray alloc] init];
    }
    return self;
}

- (AGBall *)ballForAddress:(NSData *)data
{
    for (AGBall *ball in self.balls) {
        if ([ball.ipAddress isEqualToData:data]) {
            return ball;
        }
    }
    return nil;
}

- (AGBall *)ballForIdentifier:(AGBallID)ballID
{
    for (AGBall *ball in self.balls) {
        if (ball.identifer == ballID) {
            return ball;
        }
    }
    return nil;
}

- (void)removeBall:(AGBall *)ball
{
    [self.balls removeObject:ball];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGBallManager_RemoveBall object:self userInfo:@{ @"ball": ball }];
    [self.delegate ballManager:self removeBall:ball];
}

- (void)addBall:(AGBall *)ball
{
    [self.balls addObject:ball];
    [[NSNotificationCenter defaultCenter] postNotificationName:AGBallManager_AddBall object:self userInfo:@{ @"ball": ball }];
    [self.delegate ballManager:self addBall:ball];
}

- (AGBallID)nextBallID
{
    AGBallID result = 0;
    
    while (YES) {
        if (![self ballForIdentifier:self.firstBallID]) {
            result = self.firstBallID;
            self.firstBallID++;
            break;
        }
        self.firstBallID++;
        if (self.firstBallID == AGBallID_MAX) {
            self.firstBallID = 0;
        }
    }
    return result;
}

- (NSData *)server:(AGUDPServer *)server didReceiveData:(NSData *)data fromAddress:(NSData *)addr
{
    AGBallID *ballID = nil;
    AGBall *ball = nil;
    
    if (server == self.managerServer) {
        if (data.length != sizeof(AGBallID)) {
            NSLog(@"wrong size");
        } else {
            AGBall *ballFromID, *ballFromIP;
            
            ballID = *(AGBallID *)data.bytes;
            ballFromIP = [self ballForAddress:data];
            ballFromID = [self ballForIdentifier:ballID];
            if (ballFromIP && !ballFromID) {
                [self removeBall:ballFromIP];
                ballFromIP = nil;
            }
            if (!ballFromIP && ballFromID) {
                ballFromID.ipAddress = data;
                ballFromIP = ballFromID;
                ball = ballFromID;
            }
            if (!ball) {
                ballID = [self nextBallID];
                ball = [[AGBall alloc] initWithIdentifier:ballID ipAddress:data];
                [self addBall:ball];
                
                return [NSData dataWithBytes:&ballID length:sizeof(ballID)];
            }
        }
    } else if (server == self.dataServer) {
        if (data.length > sizeof(AGBallID)) {
            NSLog(@"wrong data size");
        } else {
            ballID = (AGBallID *)data.bytes;
            ball = [self ballForIdentifier:ballID];
            if (ball) {
                [ball receiveData:data];
            }
        }
        
    }
    return nil;
}

@end
