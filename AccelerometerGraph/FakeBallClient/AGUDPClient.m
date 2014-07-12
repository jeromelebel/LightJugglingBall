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

@interface AGUDPClient ()
@property (nonatomic, readwrite, strong) id<AGUDPClientDelegate> delegate;
@property (nonatomic, readwrite, assign) NSUInteger port;
@property (nonatomic, readwrite, strong) NSString *hostName;
@property (nonatomic, readwrite, assign, getter=isReady) BOOL ready;
@property (nonatomic, readwrite, assign) CFHostRef cfHost;
@property (nonatomic, readwrite, strong) NSData *addressData;
@property (nonatomic, readwrite, assign) int socket;

- (void)hostResolutionError:(CFStreamError)streamError;
- (void)hostResolutionDone;

@end

static void HostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
// This C routine is called by CFHost when the host resolution is complete.
// It just redirects the call to the appropriate Objective-C method.
{
    AGUDPClient *    obj;
    
    obj = (__bridge AGUDPClient *) info;
    assert([obj isKindOfClass:[AGUDPClient class]]);
    
#pragma unused(theHost)
    assert(theHost == obj.cfHost);
#pragma unused(typeInfo)
    assert(typeInfo == kCFHostAddresses);
    
    if ( (error != NULL) && (error->domain != 0) ) {
        [obj hostResolutionError:*error];
    } else {
        [obj hostResolutionDone];
    }
}

@implementation AGUDPClient

+ (int)setupSocketConnectedToAddress:(NSData *)address port:(NSUInteger)port error:(NSError **)errorPtr
// Sets up the CFSocket in either client or server mode.  In client mode,
// address contains the address that the socket should be connected to.
// The address contains zero port number, so the port parameter is used instead.
// In server mode, address is nil and the socket is bound to the wildcard
// address on the specified port.
{
    int                     err;
    int                     sock;
    
    NSParameterAssert(address != nil);
    NSParameterAssert(address.length <= sizeof(struct sockaddr_storage));
    NSParameterAssert(port < 65536);
    
    // Create the UDP socket itself.
    
    err = 0;
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        err = errno;
    }
    
    // Bind or connect the socket, depending on whether we're in server or client mode.
    
    if (err == 0) {
        struct sockaddr_in      addr;
        
        memset(&addr, 0, sizeof(addr));
        // Client mode.  Set up the address on the caller-supplied address and port
        // number.
        if ([address length] > sizeof(addr)) {
            assert(NO);         // very weird
            [address getBytes:&addr length:sizeof(addr)];
        } else {
            [address getBytes:&addr length:[address length]];
        }
        assert(addr.sin_family == AF_INET);
        addr.sin_port = htons(port);
//        err = connect(sock, (const struct sockaddr *) &addr, sizeof(addr));
//        if (err < 0) {
//            err = errno;
//        }
    }
    
    if (err != 0 && (errorPtr != NULL) ) {
        *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
    }
    
    return sock;
}

- (id)initWithHostName:(NSString *)hostName port:(NSUInteger)port delegate:(id<AGUDPClientDelegate>)delegate;
{
    self = [self init];
    if (self) {
        self.hostName = hostName;
        self.port = port;
        self.delegate = delegate;
        [self _resolveHostName];
    }
    return self;
}

- (void)dealloc
{
    if (self.cfHost) CFRelease(self.cfHost);
}

- (void)_resolveHostName
{
    Boolean             success;
    CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFStreamError       streamError;
    
    assert(self.cfHost == NULL);
    
    self.cfHost = CFHostCreateWithName(NULL, (__bridge CFStringRef) self.hostName);
    assert(self.cfHost != NULL);
    
    CFHostSetClient(self.cfHost, HostResolveCallback, &context);
    
    CFHostScheduleWithRunLoop(self.cfHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    success = CFHostStartInfoResolution(self.cfHost, kCFHostAddresses, &streamError);
    if (!success) {
        [self hostResolutionError:streamError];
    }
}

- (void)hostResolutionError:(CFStreamError)streamError
// Stops the object, reporting the supplied error to the delegate.
{
    NSDictionary *  userInfo;
    NSError *       error;
    
    if (streamError.domain == kCFStreamErrorDomainNetDB) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInteger:streamError.error], kCFGetAddrInfoFailureKey,
                    nil
                    ];
    } else {
        userInfo = nil;
    }
    error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorUnknown userInfo:userInfo];
    assert(error != nil);
    if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(udpClient:hostResolveError:)] ) {
        AGUDPClient *keepSelfRetain = self;
        
        [keepSelfRetain.delegate udpClient:self hostResolveError:error];
    }
}

- (void)hostResolutionDone
{
    Boolean hasBeenResolved;
    NSArray *addresses;
    
    addresses = (__bridge NSArray *)CFHostGetAddressing(self.cfHost, &hasBeenResolved);
    for (NSData *address in addresses) {
        NSError *error = nil;
        
        self.socket = [self.class setupSocketConnectedToAddress:address port:self.port error:&error];
        if (error == nil && self.socket >= 0) {
            self.addressData = address;
            if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(udpClientDidResolveHost:)] ) {
                AGUDPClient *keepSelfRetain = self;
                
                [keepSelfRetain.delegate udpClientDidResolveHost:self];
            }
            break;
        }
    }
    if (self.addressData == nil) {
        NSError *error;
        
        error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorHostNotFound userInfo:nil];
        if ( (self.delegate != nil) && [self.delegate respondsToSelector:@selector(udpClient:hostResolveError:)] ) {
            AGUDPClient *keepSelfRetain = self;
            
            [keepSelfRetain.delegate udpClient:self hostResolveError:error];
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
    const struct sockaddr * addrPtr;
    socklen_t               addrLen;
    
    NSParameterAssert(data != nil);
    NSAssert(self.socket >= 0, @"no socket");
    
    addrPtr = self.addressData.bytes;
    addrLen = (socklen_t) self.addressData.length;
    
    bytesWritten = sendto(self.socket, [data bytes], [data length], 0, addrPtr, addrLen);
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
