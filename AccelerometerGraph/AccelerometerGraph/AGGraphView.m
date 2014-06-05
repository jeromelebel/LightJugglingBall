//
//  AGGraphView.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import "AGGraphView.h"
#import "AGGraphData.h"

#define X_VALUE_TO_PIXEL(x, maxIndex, viewWidth) (ceilf((CGFloat)((maxIndex) - 1 - (x)) / (CGFloat)((maxIndex) - 1) * (viewWidth)) + 0.5)
#define Y_VALUE_TO_PIXEL(y, minValue, maxValue, viewHeight) (ceilf((CGFloat)((y) - (minValue)) / (CGFloat)((maxValue) - (minValue)) * (viewHeight)) + 0.5)
#define PIXEL_TO_VALUE_X(pixel, viewWidth, maxIndex) (((viewWidth) - (pixel)) * ((maxIndex) - 1) / (viewWidth))
#define PIXEL_TO_VALUE_Y(pixel, viewHeight, minValue, maxValue) (((pixel) / (viewHeight) * ((maxValue) - (minValue))) + (minValue))

#define GRAPH_KEY @"graph"
#define COLOR_KEY @"color"
#define MIN_KEY @"min"
#define MAX_KEY @"max"

@interface AGGraphView ()

@property (nonatomic, readwrite, assign) BOOL hasSelection;
@property (nonatomic, readwrite, assign) CGRect selectedZone;
@property (nonatomic, readwrite, assign) NSRange selectedIndexes;
@property (nonatomic, readwrite, assign) float selectedMaxValue;
@property (nonatomic, readwrite, assign) float selectedMinValue;

@property (nonatomic, readwrite, strong) NSMutableArray *graphs;
@property (nonatomic, readwrite, assign) NSUInteger indexCount;

@end

@implementation AGGraphView

- (id)init
{
    if (self = [super init]) {
        self.graphs = [[NSMutableArray alloc] init];
        self.xUnitInterval = 100;
        self.yUnitInterval = 1;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        self.graphs = [[NSMutableArray alloc] init];
        self.xUnitInterval = 100;
        self.yUnitInterval = 1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.graphs = [[NSMutableArray alloc] init];
        self.xUnitInterval = 100;
        self.yUnitInterval = 1;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NewValueAGGraphDataNotification object:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    float maxValue = 0, minValue = 0;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    NSBezierPath*    aPath;
    
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.bounds];
    if (self.hasSelection) {
        CGRect selection;
        
        [[NSColor selectedTextBackgroundColor] set];
        selection = self.selectedZone;
        selection.origin.y = 0;
        selection.size.height = viewHeight;
        if (selection.size.width == 0) {
            selection.size.width = 1;
        } else if (selection.size.width < 0) {
            selection.origin.x = self.selectedZone.origin.x + self.selectedZone.size.width;
            selection.size.width = -self.selectedZone.size.width;
        }
        [NSBezierPath fillRect:selection];
    }
    self.indexCount = 0;
    for (NSDictionary *graphInfo in self.graphs) {
        AGGraphData *graphData = [graphInfo objectForKey:GRAPH_KEY];
        
        if (![graphInfo objectForKey:MAX_KEY] && maxValue < graphData.maxValue) maxValue = graphData.maxValue;
        if (![graphInfo objectForKey:MIN_KEY] && minValue > graphData.minValue) minValue = graphData.minValue;
        if (self.indexCount < graphData.valueCount) self.indexCount = graphData.valueCount;
    }
    if (maxValue == minValue) {
        minValue -= 2;
        maxValue += 2;
    } else {
        if (maxValue < 0) maxValue = 0;
        if (minValue > 0) minValue = 0;
    }
    aPath = [NSBezierPath bezierPath];
    [[NSColor colorWithDeviceRed:0.75 green:0.75 blue:0.75 alpha:1.0] set];
    for (float index = ceilf(minValue); index <= floorf(maxValue); index += self.yUnitInterval) {
        if (index != 0) {
            [aPath moveToPoint:CGPointMake(0, Y_VALUE_TO_PIXEL(index, minValue, maxValue, viewHeight))];
            [aPath lineToPoint:CGPointMake(viewWidth, Y_VALUE_TO_PIXEL(index, minValue, maxValue, viewHeight))];
        }
        [aPath stroke];
    }
    aPath = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    for (NSUInteger index = 0; index < self.indexCount; index += self.xUnitInterval) {
        [aPath moveToPoint:CGPointMake(X_VALUE_TO_PIXEL(index, self.indexCount, viewWidth), Y_VALUE_TO_PIXEL(0, minValue, maxValue, viewHeight) + 2.0)];
        [aPath lineToPoint:CGPointMake(X_VALUE_TO_PIXEL(index, self.indexCount, viewWidth), Y_VALUE_TO_PIXEL(0, minValue, maxValue, viewHeight) - 2.0)];
        [aPath stroke];
    }
    aPath = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    [aPath moveToPoint:CGPointMake(0, Y_VALUE_TO_PIXEL(0, minValue, maxValue, viewHeight))];
    [aPath lineToPoint:CGPointMake(viewWidth, Y_VALUE_TO_PIXEL(0, minValue, maxValue, viewHeight))];
    [aPath stroke];
    for (NSDictionary *graphInfo in self.graphs) {
        NSUInteger index;
        NSColor *color;
        AGGraphData *graphData;
        float currentMinValue = minValue, currentMaxValue = maxValue;
        
        if ([graphInfo objectForKey:MIN_KEY]) {
            currentMinValue = [[graphInfo objectForKey:MIN_KEY] floatValue];
        }
        if ([graphInfo objectForKey:MAX_KEY]) {
            currentMaxValue = [[graphInfo objectForKey:MAX_KEY] floatValue];
        }
        aPath = [NSBezierPath bezierPath];
        color = [graphInfo objectForKey:COLOR_KEY];
        graphData = [graphInfo objectForKey:GRAPH_KEY];
        if (color) {
            [color set];
        } else {
            [[NSColor blackColor] set];
        }
        for (index = 0; index < graphData.valueCount; index++) {
            float value = [graphData valueAtIndex:index];
            CGPoint point;
            
            point = CGPointMake(X_VALUE_TO_PIXEL(index, self.indexCount, viewWidth), Y_VALUE_TO_PIXEL(value, currentMinValue, currentMaxValue, viewHeight));
            if (index == 0) {
                [aPath moveToPoint:point];
             } else {
                 [aPath lineToPoint:point];
             }
        }
        [aPath stroke];
    }
}

- (NSUInteger)graphInfoIndexOfGraphData:(AGGraphData *)graphData
{
    NSUInteger index = 0;
    
    for (NSDictionary *graphInfo in self.graphs) {
        if ([graphInfo objectForKey:GRAPH_KEY] == graphData) {
            break;
        }
        index++;
    }
    return index == self.graphs.count?NSNotFound:index;
}

- (void)addGraphData:(AGGraphData *)graphData withMinValue:(NSNumber *)minValue maxValue:(NSNumber *)maxValue color:(NSColor *)color
{
    NSInteger index;
    NSMutableDictionary *graphInfo;
    
    NSAssert(graphData != nil, @"need to set a graph data");
    graphInfo = [[NSMutableDictionary alloc] init];
    [graphInfo setObject:graphData forKey:GRAPH_KEY];
    if (color) [graphInfo setObject:color forKey:COLOR_KEY];
    if (minValue) [graphInfo setObject:minValue forKey:MIN_KEY];
    if (maxValue) [graphInfo setObject:maxValue forKey:MAX_KEY];
    index = [self graphInfoIndexOfGraphData:graphData];
    if (index == NSNotFound) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newValueAGGraphDataNotification:) name:NewValueAGGraphDataNotification object:graphData];
        [self.graphs addObject:graphInfo];
    } else {
        [self.graphs replaceObjectAtIndex:index withObject:graphInfo];
    }
    [self setNeedsDisplay:YES];
}

- (void)addGraphData:(AGGraphData *)graphData withColor:(NSColor *)color
{
    [self addGraphData:graphData withMinValue:nil maxValue:nil color:color];
}

- (void)removeGraphData:(AGGraphData *)graphData
{
    NSInteger index;
    
    index = [self graphInfoIndexOfGraphData:graphData];
    if (index != NSNotFound) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NewValueAGGraphDataNotification object:graphData];
        [self.graphs removeObjectAtIndex:index];
        [self setNeedsDisplay:YES];
    }
}

- (void)newValueAGGraphDataNotification:(NSNotification *)notification
{
    [self setNeedsDisplay:YES];
}

- (void)_updateSelection
{
    BOOL firstGraph = YES;
    NSUInteger firstIndex, secondIndex;
    
    firstIndex = PIXEL_TO_VALUE_X(_selectedZone.origin.x, self.bounds.size.width, self.indexCount);
    secondIndex = PIXEL_TO_VALUE_X(_selectedZone.origin.x + self.selectedZone.size.width, self.bounds.size.width, self.indexCount);
    if (firstIndex < secondIndex) {
        self.selectedIndexes = NSMakeRange(firstIndex, secondIndex - firstIndex);
    } else {
        self.selectedIndexes = NSMakeRange(secondIndex, firstIndex - secondIndex);
    }
    if (self.selectedIndexes.length == 0) self.selectedIndexes = NSMakeRange(self.selectedIndexes.location, 1);
    for (NSDictionary *graphInfo in self.graphs) {
        AGGraphData *graphData = [graphInfo objectForKey:GRAPH_KEY];
        
        if (graphData.valueCount > self.selectedIndexes.location) {
            NSUInteger ii;
            NSUInteger maxIndex;
            
            if (firstGraph) {
                self.selectedMaxValue = [graphData valueAtIndex:self.selectedIndexes.location];
                self.selectedMinValue = [graphData valueAtIndex:self.selectedIndexes.location];
                firstGraph = YES;
            }
            maxIndex = self.selectedIndexes.location + self.selectedIndexes.length;
            if (maxIndex > graphData.valueCount) {
                maxIndex = graphData.valueCount;
            }
            for (ii = self.selectedIndexes.location; ii < maxIndex; ii++) {
                float value;
                
                value = [graphData valueAtIndex:ii];
                if (value > self.selectedMaxValue) self.selectedMaxValue = value;
                if (value < self.selectedMinValue) self.selectedMinValue = value;
            }
        }
    }
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTION_DID_CHANGE_GRAPH_VIEW object:self];
}

- (void)_startSelectionAtPoint:(CGPoint)point
{
    self.hasSelection = YES;
    self.selectedZone = CGRectMake(point.x, point.y, 0, 0);
    self.selectedIndexes = NSMakeRange(PIXEL_TO_VALUE_X(point.x, self.bounds.size.width, self.indexCount), 0);
    
    [self _updateSelection];
}

- (void)_updateSelectionWithPoint:(CGPoint)point
{
    self.selectedZone = CGRectMake(self.selectedZone.origin.x, self.selectedZone.origin.y, point.x - self.selectedZone.origin.x, point.y - self.selectedZone.origin.y);

    [self _updateSelection];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint             location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSEvent*            event = NULL;
    NSWindow            *targetWindow = [self window];
    CGRect              bounds = self.bounds;
    
    if (location.x > bounds.origin.x + bounds.size.width) {
        location.x = bounds.origin.x + bounds.size.width;
    } else if (location.x < bounds.origin.x) {
        location.x = bounds.origin.x;
    }
    [self _startSelectionAtPoint:location];
    while (self.hasSelection) {
        event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
                                          untilDate:[NSDate distantFuture]
                                             inMode:NSEventTrackingRunLoopMode
                                            dequeue:YES];
        if(!event)
            continue;
        location = [self convertPoint:[event locationInWindow] fromView:nil];
        if (location.x > bounds.origin.x + bounds.size.width) {
            location.x = bounds.origin.x + bounds.size.width;
        } else if (location.x < bounds.origin.x) {
            location.x = bounds.origin.x;
        }
        switch ([event type]) {
            case NSLeftMouseDragged:
                [self _updateSelectionWithPoint:location];
                break;
                
            case NSLeftMouseUp:
                self.hasSelection = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SELECTION_DID_CHANGE_GRAPH_VIEW object:self];
                [self setNeedsDisplay:YES];
                break;
                
            default:
                break;
        }
    }
}

@end
