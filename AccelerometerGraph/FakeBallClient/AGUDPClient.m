//
//  AGUDPClient.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 10/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGUDPClient.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <arpa/inet.h>

@interface AGUDPClient ()
@property (nonatomic, readwrite, strong) id<AGUDPClientDelegate> delegate;
@property (nonatomic, readwrite, assign) NSUInteger port;
@property (nonatomic, readwrite, strong) NSString *hostName;
@property (nonatomic, readwrite, assign) int socket;

@end

@implementation AGUDPClient
{
    struct sockaddr_in _servaddr;
}

- (id)initWithHostName:(NSString *)hostName port:(NSUInteger)port delegate:(id<AGUDPClientDelegate>)delegate;
{
    self = [self init];
    if (self) {
        self.hostName = hostName;
        self.port = port;
        self.delegate = delegate;
    }
    return self;
}

- (void)setupSocket
{
    self.socket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    
    if (self.socket < 0) {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(udpClient:hostResolveError:)] ) {
            AGUDPClient *keepSelfRetain = self;
            
            [keepSelfRetain.delegate udpClient:self hostResolveError:error];
        }
    } else {
        bzero(&_servaddr, sizeof(_servaddr));
        _servaddr.sin_family = AF_INET;
        _servaddr.sin_addr.s_addr = inet_addr(self.hostName.UTF8String);
        _servaddr.sin_port = htons(self.port);
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(udpClientDidResolveHost:)] ) {
            AGUDPClient *keepSelfRetain = self;
            
            [keepSelfRetain.delegate udpClientDidResolveHost:self];
        }
    }
}

- (BOOL)sendData:(NSData *)data error:(NSError **)error
// Called by both -sendData: and the server echoing code to send data
// via the socket.  addr is nil in the client case, whereupon the
// data is automatically sent to the hostAddress by virtue of the fact
// that the socket is connected to that address.
{
    int                     err;
    ssize_t                 bytesWritten;
    
    NSParameterAssert(data != nil);
    NSAssert(self.socket >= 0, @"no socket");
    
    bytesWritten = sendto(self.socket, [data bytes], [data length], 0, (struct sockaddr *)&_servaddr, sizeof(_servaddr));
    if (bytesWritten < 0) {
        err = errno;
    } else  if (bytesWritten == 0) {
        err = EPIPE;
    } else {
        // We ignore any short writes, which shouldn't happen for UDP anyway.
        assert( (NSUInteger) bytesWritten == [data length] );
        err = 0;
    }
    
    if (err != 0 && error) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
    }
    return err == 0;
}

@end
