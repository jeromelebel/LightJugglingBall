//
//  AGSparkDevice.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 20/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGSparkDevice.h"
#import "AGSparkDevice_private.h"
#import "AGSparkManager_private.h"

@interface AGSparkDevice ()
@property (nonatomic, readwrite, strong) AGSparkManager *sparkManager;
@property (nonatomic, readwrite, strong) NSString *identifer;
@property (nonatomic, readwrite, strong) NSDictionary *info;

@end

@implementation AGSparkDevice

- (instancetype)initWithIdentifier:(NSString *)identifier sparkManager:(AGSparkManager *)sparkManager
{
    self = [self init];
    if (self) {
        self.identifer = identifier;
        self.sparkManager = sparkManager;
    }
    return self;
}

- (void)refreshWithCallback:(void (^)(AGSparkDevice *device, NSError *error))callback
{
    [self.sparkManager connectionWithURL:[self.sparkManager urlWithCommand:[@"/devices/" stringByAppendingString:self.identifer] arguments:@{ @"access_token": self.sparkManager.accessToken }] callback:^(NSURLConnection *connection, NSError *error, NSDictionary *connectionInfo) {
        NSURLResponse *response = connectionInfo[@"response"];
        
        if (error) {
            callback(self, error);
        } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpReponse = (NSHTTPURLResponse *)response;
            
            if (httpReponse.statusCode == 200) {
                NSError *error = nil;
                id info;
                
                info = [NSJSONSerialization JSONObjectWithData:connectionInfo[@"data"] options:0 error:&error];
                if (error) {
                    callback(self, error);
                } else {
                    self.info = info;
                    callback(self, nil);
                }
            } else {
                callback(self, nil);
            }
        } else {
            callback(self, nil);
        }
    }];
}

@end
