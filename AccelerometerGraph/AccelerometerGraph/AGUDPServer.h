//
//  AGUDPServer.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 21/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGUDPServerDelegate;

@interface AGUDPServer : NSObject

@property (nonatomic, readonly, assign)  NSUInteger port;
@property (nonatomic, readwrite, weak) id<AGUDPServerDelegate> delegate;

- (instancetype)initWithPort:(NSUInteger)port;
- (void)startServer;
- (void)stop;

@end

@protocol AGUDPServerDelegate <NSObject>

@optional
- (NSData *)server:(AGUDPServer *)server didReceiveData:(NSData *)data fromAddress:(NSData *)addr;
// Called after successfully receiving data.  On a server object this data will
// automatically be echoed back to the sender.
//
// assert(echo != nil);
// assert(data != nil);
// assert(addr != nil);

- (void)server:(AGUDPServer *)server didReceiveError:(NSError *)error;
// Called after a failure to receive data.
//
// assert(echo != nil);
// assert(error != nil);

- (void)server:(AGUDPServer *)server didStartWithAddress:(NSData *)address;
// Called after the object has successfully started up.  On the client addresses
// is the list of addresses associated with the host name passed to
// -startConnectedToHostName:port:.  On the server, this is the local address
// to which the server is bound.
//
// assert(echo != nil);
// assert(address != nil);

- (void)server:(AGUDPServer *)server didStopWithError:(NSError *)error;
// Called after the object stops spontaneously (that is, after some sort of failure,
// but now after a call to -stop).
//
// assert(echo != nil);
// assert(error != nil);


- (void)echo:(AGUDPServer *)echo didSendData:(NSData *)data toAddress:(NSData *)addr;
// Called after successfully sending data.  On the server side this is typically
// the result of an echo.
//
// assert(echo != nil);
// assert(data != nil);
// assert(addr != nil);

- (void)echo:(AGUDPServer *)echo didFailToSendData:(NSData *)data toAddress:(NSData *)addr error:(NSError *)error;
// Called after a failure to send data.
//
// assert(echo != nil);
// assert(data != nil);
// assert(addr != nil);
// assert(error != nil);

@end