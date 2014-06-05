//
//  AGDevice.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 20/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import "AGDevice.h"

@interface AGDevice()
@property (nonatomic, readwrite, assign, getter = isConnected) BOOL connected;
@property (nonatomic, readwrite, strong) IOBluetoothDevice *device;
@property (nonatomic, readwrite, strong) IOBluetoothRFCOMMChannel *rfcommChannel;


- (void)_closeRFCommChannel;
- (void)_openRFCommChannel;
- (void)_openRFCommChannelWithDelay;
@end

@implementation AGDevice

@synthesize delegate = _delegate, connected = _connected;

- (void)dealloc
{
    [self _closeRFCommChannel];
}

- (void)_closeRFCommChannel
{
    [self.rfcommChannel closeChannel];
    self.rfcommChannel = nil;
}

- (void)_openRFCommChannel
{
    BluetoothRFCOMMChannelID channelID = 255;
    IOReturn error;
    IOBluetoothSDPServiceRecord *deviceSDPService;
    
    [self _closeRFCommChannel];
    deviceSDPService = [self.device getServiceRecordForUUID:[IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort]];
    error = [deviceSDPService getRFCOMMChannelID:&channelID];
    if (error == kIOReturnSuccess) {
        IOBluetoothRFCOMMChannel *channel;
        
        error = [self.device openRFCOMMChannelAsync:&channel withChannelID:channelID delegate:self];
        self.rfcommChannel = channel;
    }
    if (error == kIOReturnSuccess) {
        self.rfcommChannel = nil;
    } else {
        [self _openRFCommChannelWithDelay];
    }
}

- (void)_openRFCommChannelWithDelay
{
    [self performSelector:@selector(_openRFCommChannel) withObject:nil afterDelay:2];
}

- (void)connectWithDeviceID:(NSString *)deviceID
{
    BluetoothDeviceAddress bluetoothDevice;
    IOReturn error;
    
    error = IOBluetoothNSStringToDeviceAddress(deviceID, &bluetoothDevice);
    if (error == kIOReturnSuccess) {
        self.device = [IOBluetoothDevice deviceWithAddress:&bluetoothDevice];
        NSLog(@"device found %p, is connected %@, connected %d", self.device, self.device.isConnected?@"YES":@"NO", error);
        [self _openRFCommChannel];
    }
}

NSDate *date;

- (BOOL)writeData:(const void *)bytes length:(NSUInteger)length
{
    date = NSDate.date;
    return [_rfcommChannel writeSync:(void *)bytes length:length] == kIOReturnSuccess;
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
    if (dataPointer != NULL && dataLength > 0) {
        NSString *buffer;
        
        buffer = [[NSString alloc] initWithBytesNoCopy:dataPointer length:dataLength encoding:NSUTF8StringEncoding freeWhenDone:NO];
        if (buffer) [_delegate device:self receivedBuffer:buffer];
    }
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    if(error == kIOReturnSuccess) {
        [_rfcommChannel setSerialParameters:115200 dataBits:8 parity:kBluetoothRFCOMMParityTypeNoParity stopBits:1];
        self.connected = YES;
    } else {
        [self _openRFCommChannelWithDelay];
    }
}

- (void)rfcommChannelControlSignalsChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    self.connected = NO;
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self _openRFCommChannelWithDelay];
}

- (void)rfcommChannelFlowControlChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)rfcommChannelWriteComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel refcon:(void*)refcon status:(IOReturn)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


- (void)rfcommChannelQueueSpaceAvailable:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
