//
//  AGBallManager.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 03/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGBall;

#define AGBallManager_AddBall @"AGBallManager_AddBall"
#define AGBallManager_RemoveBall @"AGBallManager_RemoveBall"

@protocol AGBallManagerDelegate;

@interface AGBallManager : NSObject
@property (nonatomic, readwrite, weak) id<AGBallManagerDelegate> delegate;

@end

@protocol AGBallManagerDelegate <NSObject>
- (void)ballManager:(AGBallManager *)ballManager addBall:(AGBall *)ball;
- (void)ballManager:(AGBallManager *)ballManager removeBall:(AGBall *)ball;

@end