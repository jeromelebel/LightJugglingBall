//
//  AGSparkManager_private.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 20/06/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import "AGSparkManager.h"

@interface AGSparkManager ()

- (NSURLConnection *)connectionWithURL:(NSURL *)url callback:(void (^)(NSURLConnection *connection, NSError *error, NSDictionary *info))callback;
- (NSURL *)urlWithCommand:(NSString *)command arguments:(NSDictionary *)argument;

@end
