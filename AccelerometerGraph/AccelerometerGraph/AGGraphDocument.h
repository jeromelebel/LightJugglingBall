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

+ (BOOL)parseBuffer:(NSMutableString *)buffer xGraphData:(AGGraphData *)xGraphData yGraphData:(AGGraphData *)yGraphData zGraphData:(AGGraphData *)zGraphData xRotationGraphData:(AGGraphData *)xRotationGraphData yRotationGraphData:(AGGraphData *)yRotationGraphData zRotationGraphData:(AGGraphData *)zRotationGraphData normGraphData:(AGGraphData *)normGraphData;
+ (void)updateLabel:(NSTextField *)label graphView:(AGGraphView *)graphView graphData:(AGGraphData *)graphData;

@end
