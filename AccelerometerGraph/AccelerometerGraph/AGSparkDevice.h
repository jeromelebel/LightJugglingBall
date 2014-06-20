//
//  AGSparkDevice.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 20/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AGSparkManager;

@interface AGSparkDevice : NSObject
@property (nonatomic, readonly, strong) AGSparkManager *sparkManager;
@property (nonatomic, readonly, strong) NSString *identifer;
@property (nonatomic, readonly, strong) NSDictionary *info;

- (instancetype)initWithIdentifier:(NSString *)identifier sparkManager:(AGSparkManager *)sparkManager;
- (void)refreshWithCallback:(void (^)(AGSparkDevice *device, NSError *error))callback;

@end
