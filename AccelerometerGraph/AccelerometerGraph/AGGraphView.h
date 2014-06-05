//
//  AGGraphView.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AGGraphData;

#define SELECTION_DID_CHANGE_GRAPH_VIEW @"selection_did_change_graph_view"

@interface AGGraphView : NSView
{
    NSMutableArray *_graphs;
    NSUInteger _xUnitInterval;
    NSUInteger _yUnitInterval;
    NSUInteger _indexCount;
    
    BOOL _hasSelection;
    CGRect _selectedZone;
    NSRange _selectedIndexes;
    float _selectedMaxValue;
    float _selectedMinValue;
}

@property (nonatomic, readwrite, assign) NSUInteger xUnitInterval;
@property (nonatomic, readwrite, assign) NSUInteger yUnitInterval;

@property (nonatomic, readonly, assign) BOOL hasSelection;
@property (nonatomic, readonly, assign) CGRect selectedZone;
@property (nonatomic, readonly, assign) NSRange selectedIndexes;
@property (nonatomic, readonly, assign) float selectedMaxValue;
@property (nonatomic, readonly, assign) float selectedMinValue;

- (void)addGraphData:(AGGraphData *)graphData withColor:(NSColor *)color;
- (void)addGraphData:(AGGraphData *)graphData withMinValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue color:(NSColor *)color;
- (void)removeGraphData:(AGGraphData *)graphData;

@end
