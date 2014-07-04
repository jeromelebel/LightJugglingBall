//
//  AGBall.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 03/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGBall.h"

@interface AGBall ()
@property (nonatomic, readwrite, strong) NSData *ipAddress;

- (void)receiveData:(NSData *)data;

@end
