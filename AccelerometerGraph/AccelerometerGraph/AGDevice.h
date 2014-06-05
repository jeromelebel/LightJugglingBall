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
    IOBluetoothDevice *_device;
    IOBluetoothRFCOMMChannel *_rfcommChannel;
    id<AGDeviceDelegate> _delegate;
    BOOL _connected;
}

@property (nonatomic, readwrite, assign) id<AGDeviceDelegate> delegate;
@property (nonatomic, readonly, assign, getter = isConnected) BOOL connected;

- (void)connectWithDeviceID:(NSString *)deviceID;

- (BOOL)writeData:(const void *)bytes length:(NSUInteger)length;

@end
