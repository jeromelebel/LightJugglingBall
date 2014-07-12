//
//  AGUDPClient.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 10/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGUDPClientDelegate;

@interface AGUDPClient : NSObject
@property (nonatomic, readonly, strong) id<AGUDPClientDelegate> delegate;
@property (nonatomic, readonly, assign) NSUInteger port;
@property (nonatomic, readonly, strong) NSString *hostName;
@property (nonatomic, readonly, assign, getter=isReady) BOOL ready;

- (id)initWithHostName:(NSString *)hostName port:(NSUInteger)port delegate:(id<AGUDPClientDelegate>)delegate;
- (BOOL)sendData:(NSData *)data error:(NSError **)error;


@end

@protocol AGUDPClientDelegate <NSObject>
- (void)udpClient:(AGUDPClient *)client hostResolveError:(NSError *)error;
- (void)udpClientDidResolveHost:(AGUDPClient *)client;
@end
