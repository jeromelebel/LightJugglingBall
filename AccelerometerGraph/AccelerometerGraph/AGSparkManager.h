//
//  AGSparkManager.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGSparkDevice;

@interface AGSparkManager : NSObject

@property (nonatomic, readonly, strong) NSDictionary *sparkConfig;
@property (nonatomic, readonly, strong) NSString *accessToken;
@property (nonatomic, readonly, strong) NSMutableDictionary *deviceList;

+ (instancetype)sharedInstance;
- (void)fetchListWithCallback:(void (^)(AGSparkManager *sparkManager, NSError *error, NSDictionary *list))callback;
- (AGSparkDevice *)deviceWithIdentifier:(NSString *)identifier;

@end
