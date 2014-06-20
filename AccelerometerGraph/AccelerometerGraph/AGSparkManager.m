//
//  AGSparkManager.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGSparkManager.h"
#import "AGSparkDevice.h"
#import "AGSparkDevice_private.h"

static AGSparkManager *_sharedInstance;

#define SPARK_SERVER @"api.spark.io"
#define SPARK_CONFIG_PATH @"~/.spark/spark.config.json"
#define SPARK_SCHEME @"https"

@interface AGSparkManager ()
@property (nonatomic, readwrite, strong) NSDictionary *sparkConfig;
@property (nonatomic, readwrite, strong) NSMutableArray *connectionInfo;
@property (nonatomic, readwrite, strong) NSMutableDictionary *deviceList;

@end

@interface AGSparkManager (NSURLConnectionDataDelegate) <NSURLConnectionDataDelegate>

@end

@implementation AGSparkManager

+ (instancetype)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSData *data;
        
        data = [NSData dataWithContentsOfFile:SPARK_CONFIG_PATH.stringByStandardizingPath];
        if (data) self.sparkConfig = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.connectionInfo = [NSMutableArray array];
    }
    return self;
}

- (NSString *)accessToken
{
    return self.sparkConfig[@"access_token"];
}

- (NSURL *)urlWithCommand:(NSString *)command arguments:(NSDictionary *)argument
{
    NSMutableString *argumentString = [NSMutableString string];
    NSString *slashBeforeCommand = @"";
    
    NSParameterAssert(command.length > 0);
    if (argument) {
        for (NSString *key in argument) {
            if (argumentString.length == 0) {
                [argumentString appendString:@"?"];
            } else {
                [argumentString appendString:@"&"];
            }
            [argumentString appendFormat:@"%@=%@", key, argument[key]];
        }
    }
    if ([command characterAtIndex:0] != '/') {
        slashBeforeCommand = @"/";
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/v1%@%@%@", SPARK_SCHEME, SPARK_SERVER, slashBeforeCommand, command, argumentString]];
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url
{
    NSMutableURLRequest *result;
    
    result = [[NSMutableURLRequest alloc] initWithURL:url];
    return result;
}

- (NSURLConnection *)connectionWithURL:(NSURL *)url callback:(void (^)(NSURLConnection *connection, NSError *error, NSDictionary *info))callback
{
    NSURLConnection *result;
    NSMutableURLRequest *request;
    
    request = [self requestWithURL:url];
    result = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.connectionInfo addObject:@{ @"connection": result, @"callback": [callback copy] }.mutableCopy];
    [result start];
    
    return result;
}

- (void)fetchListWithCallback:(void (^)(AGSparkManager *sparkManager, NSError *error, NSDictionary *list))callback
{
    NSURLConnection *connection;
    
    connection = [self connectionWithURL:[self urlWithCommand:@"devices" arguments:@{ @"access_token": self.accessToken }] callback:^(NSURLConnection *connection, NSError *error, NSDictionary *info) {
        NSURLResponse *response = info[@"response"];
        
        if (error) {
            callback(self, error, nil);
        } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
            
            if (httpReponse.statusCode == 200) {
                NSError *error = nil;
                id deviceList;
                
                deviceList = [NSJSONSerialization JSONObjectWithData:info[@"data"] options:0 error:&error];
                if (error) {
                    callback(self, error, nil);
                } else {
                    self.deviceList = [NSMutableDictionary dictionary];
                    for (NSDictionary *deviceInfo in deviceList) {
                        self.deviceList[deviceInfo[@"id"]] = deviceInfo;
                    }
                    callback(self, nil, self.deviceList);
                }
            } else {
                callback(self, nil, nil);
            }
        } else {
            callback(self, nil, nil);
        }
    }];
}

- (NSMutableDictionary *)connectionInfoForConnection:(NSURLConnection *)connection
{
    NSMutableDictionary *result = nil;
    
    for (NSMutableDictionary *connectionInfo in self.connectionInfo) {
        if (connectionInfo[@"connection"] == connection) {
            result = connectionInfo;
            break;
        }
    }
    return result;
}

- (AGSparkDevice *)deviceWithIdentifier:(NSString *)identifier
{
    return [[AGSparkDevice alloc] initWithIdentifier:identifier sparkManager:self];
}

@end

@implementation AGSparkManager (NSURLConnectionDataDelegate)

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
    
    if (connectionInfo) {
        if (connectionInfo[@"callback"]) {
            ((void (^)(NSURLConnection *connection, NSError *error, NSDictionary *info))connectionInfo[@"callback"])(connection, error, connectionInfo);
        }
        [self.connectionInfo removeObject:connectionInfo];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
    
    if (connectionInfo) {
        if (connectionInfo[@"callback"]) {
            ((void (^)(NSURLConnection *connection, NSError *error, NSDictionary *info))connectionInfo[@"callback"])(connection, nil, connectionInfo);
        }
        [self.connectionInfo removeObject:connectionInfo];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
    
    if (connectionInfo) {
        connectionInfo[@"response"] = response;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedData
{
    NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
    
    if (connectionInfo) {
        NSMutableData *connectionData;
        
        connectionData = connectionInfo[@"data"];
        if (!connectionData) {
            connectionData = [NSMutableData data];
            connectionInfo[@"data"] = connectionData;
        }
        [connectionData appendData:receivedData];
    }
}

@end
