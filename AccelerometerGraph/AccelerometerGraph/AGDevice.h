//
//  AGDevice.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 20/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOBluetooth/IOBluetooth.h"

@class AGDevice;

@protocol AGDeviceDelegate<NSObject>
- (void)device:(AGDevice *)device receivedBuffer:(NSString *)buffer;
@end

@interface AGDevice : NSObject
{
}

@property (nonatomic, readwrite, weak) id<AGDeviceDelegate> delegate;
@property (nonatomic, readonly, assign, getter = isConnected) BOOL connected;

- (void)connectWithDeviceID:(NSString *)deviceID;

- (BOOL)writeData:(const void *)bytes length:(NSUInteger)length;

@end
