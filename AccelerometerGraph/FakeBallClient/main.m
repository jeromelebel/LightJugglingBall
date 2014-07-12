//
//  main.m
//  FakeBallClient
//
//  Created by Jérôme Lebel on 10/07/2014.
//  Copyright (c) 2014 Fotonauts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGFakeBallClient.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        AGFakeBallClient *ball;
        
        ball = [[AGFakeBallClient alloc] init];
        CFRunLoopRun();
    }
    return 0;
}
