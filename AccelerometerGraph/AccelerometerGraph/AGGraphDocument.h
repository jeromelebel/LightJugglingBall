//
//  AGGraphDocument.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 23/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGGraphData;
@class AGGraphView;

@interface AGGraphDocument : NSDocument
{
}

+ (void)updateLabel:(NSTextField *)label graphView:(AGGraphView *)graphView graphData:(AGGraphData *)graphData;

@end
