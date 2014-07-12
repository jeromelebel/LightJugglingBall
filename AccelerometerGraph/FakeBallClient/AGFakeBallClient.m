//
//  AGFakeBallClient.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 10/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGFakeBallClient.h"
#import "AGUDPClient.h"
#import "CommunicationStruct.h"

@interface AGFakeBallClient () <AGUDPClientDelegate>
@property (nonatomic, readwrite, strong) AGUDPClient *udpClient;
@end

@implementation AGFakeBallClient

- (id)init
{
    self = [super init];
    if (self) {
        self.udpClient = [[AGUDPClient alloc] initWithHostName:@"192.168.174.101" port:ServerPort delegate:self];
    }
    return self;
}

- (void)sendData
{
    BallPacket packet = { 0, 0, 0, 0, 0, 0, 0, 0 };
    
    while (YES) {
        @autoreleasepool {
            NSData *data;
            
            data = [[NSData alloc] initWithBytes:&packet length:sizeof(packet)];
            [self.udpClient sendData:data error:nil];
            data = nil;
            usleep(100);
        }
    }
}

- (void)udpClient:(AGUDPClient *)client hostResolveError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)udpClientDidResolveHost:(AGUDPClient *)client
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self performSelector:@selector(sendData) withObject:nil afterDelay:0];
}

@end
