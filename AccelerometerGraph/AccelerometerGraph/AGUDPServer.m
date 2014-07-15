//
//  AGUDPServer.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 21/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGUDPServer.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>

@interface AGUDPServer ()
@property (nonatomic, readwrite, assign) NSUInteger port;
@property (nonatomic, readwrite, assign) CFSocketRef cfSocket;
@end

static void SocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

@implementation AGUDPServer

- (instancetype)initWithPort:(NSUInteger)port
{
    self = [self init];
    if (self) {
        assert( (port > 0) && (port < 65536) );
        self.port = port;
    }
    return self;
}

- (void)readData
// Called by the CFSocket read callback to actually read and process data
// from the socket.
{
    int                     err;
    int                     sock;
    struct sockaddr_storage addr;
    socklen_t               addrLen;
    uint8_t                 buffer[65536];
    ssize_t                 bytesRead;
    
    sock = CFSocketGetNative(self.cfSocket);
    assert(sock >= 0);
    
    addrLen = sizeof(addr);
    bytesRead = recvfrom(sock, buffer, sizeof(buffer), 0, (struct sockaddr *) &addr, &addrLen);
    if (bytesRead < 0) {
        err = errno;
    } else if (bytesRead == 0) {
        err = EPIPE;
    } else {
        NSData *    dataObj;
        NSData *    addrObj;
        
        err = 0;
        
        dataObj = [NSData dataWithBytes:buffer length:(NSUInteger) bytesRead];
        assert(dataObj != nil);
        addrObj = [NSData dataWithBytes:&addr  length:addrLen  ];
        assert(addrObj != nil);
        
        // Tell the delegate about the data.
        
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(server:didReceiveData:fromAddress:)] ) {
            NSData *answer;
            
            answer = [self.delegate server:self didReceiveData:dataObj fromAddress:addrObj];
            if (answer) {
                [self sendData:answer toAddress:addrObj];
            }
        }
    }
    
    // If we got an error, tell the delegate.
    
    if (err != 0) {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(server:didReceiveError:)] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate server:self didReceiveError:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
            });
        }
    }
}

- (void)_serverThread
{
    CFRunLoopSourceRef      source;
    
    // The socket will now take care of cleaning up our file descriptor.
    
    assert(CFSocketGetSocketFlags(self.cfSocket) & kCFSocketCloseOnInvalidate);
    
    source = CFSocketCreateRunLoopSource(NULL, self.cfSocket, 0);
    assert(source != NULL);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    while (YES) {
        CFRunLoopRun();
        NSLog(@"prout");
    }
}

- (BOOL)setupSocketWithError:(NSError **)errorPtr
// Sets up the CFSocket in either client or server mode.  In client mode,
// address contains the address that the socket should be connected to.
// The address contains zero port number, so the port parameter is used instead.
// In server mode, address is nil and the socket is bound to the wildcard
// address on the specified port.
{
    const CFSocketContext   context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    struct sockaddr_in a = {0, AF_INET, htons(self.port), INADDR_ANY};
    CFDataRef d1 = CFDataCreate(NULL, (UInt8 *)&a, sizeof(struct sockaddr_in));
    CFSocketSignature signature = {PF_INET, SOCK_DGRAM, IPPROTO_UDP, d1};
    self.cfSocket = CFSocketCreateWithSocketSignature(NULL, &signature, kCFSocketReadCallBack, SocketReadCallback, &context);
    CFRelease(d1);
    
    if (self.cfSocket) {
        [NSThread detachNewThreadSelector:@selector(_serverThread) toTarget:self withObject:nil];
        if (errorPtr) *errorPtr = NULL;
    } else {
        if (errorPtr) *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
    }
    return self.cfSocket != NULL;
}

- (void)startServer
// See comment in header.
{
    BOOL        success;
    NSError *   error;
    
    // Create a fully configured socket.
    
    success = [self setupSocketWithError:&error];
    
    // If we can create the socket, we're good to go.  Otherwise, we report an error
    // to the delegate.
    
    if (success) {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(server:didStartWithAddress:)] ) {
            CFDataRef   localAddress;
            
            localAddress = CFSocketCopyAddress(self.cfSocket);
            assert(localAddress != NULL);
            
            [self.delegate server:self didStartWithAddress:(__bridge NSData *) localAddress];
            
            CFRelease(localAddress);
        }
    } else {
        [self stopWithError:error];
    }
}

- (void)stop
// See comment in header.
{
    if (self.cfSocket != NULL) {
        CFSocketInvalidate(self.cfSocket);
        CFRelease(self.cfSocket);
        self.cfSocket = NULL;
    }
}

- (void)sendData:(NSData *)data toAddress:(NSData *)addr
// Called by both -sendData: and the server echoing code to send data
// via the socket.  addr is nil in the client case, whereupon the
// data is automatically sent to the hostAddress by virtue of the fact
// that the socket is connected to that address.
{
    int                     err;
    int                     sock;
    ssize_t                 bytesWritten;
    const struct sockaddr * addrPtr;
    socklen_t               addrLen;
    
    assert(data != nil);
    assert(addr != nil);
    assert( (addr == nil) || ([addr length] <= sizeof(struct sockaddr_storage)) );
    
    sock = CFSocketGetNative(self->_cfSocket);
    assert(sock >= 0);
    
    addrPtr = [addr bytes];
    addrLen = (socklen_t) [addr length];
    
    bytesWritten = sendto(sock, [data bytes], [data length], 0, addrPtr, addrLen);
    if (bytesWritten < 0) {
        err = errno;
    } else  if (bytesWritten == 0) {
        err = EPIPE;
    } else {
        // We ignore any short writes, which shouldn't happen for UDP anyway.
        assert( (NSUInteger) bytesWritten == [data length] );
        err = 0;
    }
    
    if (err == 0) {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(echo:didSendData:toAddress:)] ) {
            [self.delegate echo:self didSendData:data toAddress:addr];
        }
    } else {
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(echo:didFailToSendData:toAddress:error:)] ) {
            [self.delegate echo:self didFailToSendData:data toAddress:addr error:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
        }
    }
}

- (void)stopWithError:(NSError *)error
// Stops the object, reporting the supplied error to the delegate.
{
    assert(error != nil);
    [self stop];
    if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(server:didStopWithError:)] ) {
        // The following line ensures that we don't get deallocated until the next time around the
        // run loop.  This is important if our delegate holds the last reference to us and
        // this callback causes it to release that reference.  At that point our object (self) gets
        // deallocated, which causes problems if any of the routines that called us reference self.
        // We prevent this problem by performing a no-op method on ourself, which keeps self alive
        // until the perform occurs.
        [self performSelector:@selector(noop) withObject:nil afterDelay:0.0];
        [self.delegate server:self didStopWithError:error];
    }
}

@end


static void SocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
// This C routine is called by CFSocket when there's data waiting on our
// UDP socket.  It just redirects the call to Objective-C code.
{
    AGUDPServer *       obj;
    
    obj = (__bridge AGUDPServer *) info;
    assert([obj isKindOfClass:[AGUDPServer class]]);
    
#pragma unused(s)
    assert(s == obj.cfSocket);
#pragma unused(type)
    assert(type == kCFSocketReadCallBack);
#pragma unused(address)
    assert(address == nil);
#pragma unused(data)
    assert(data == nil);
    
    [obj readData];
}
