//
//  AGGraphDocument.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 23/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import "AGGraphDocument.h"
#import "AGGraphData.h"
#import "AGGraphView.h"

#define PI 3.14159265

static float my_atanf(float sinValue, float cosValue, float norm)
{
    float result;
    
    if (cosValue != 0) {
        result = atanf(sinValue / cosValue);
        if (sinValue < 0 && cosValue < 0) {
            result -= PI;
        } else if (sinValue * cosValue < 0) {
            result += PI;
        }
    } else if (sinValue > 0) {
        result = PI / 2.0;
    } else {
        result = -PI / 2.0;
    }
    result = result / PI * 180.0;
    return result;
}

@interface AGGraphDocument ()
@property (nonatomic, readwrite, strong) AGGraphData *xGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *xRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *normGraphData;
@property (nonatomic, readwrite, strong) NSData *data;

@property (nonatomic, readwrite, strong) NSTextField *label;
@property (nonatomic, readwrite, strong) AGGraphView *graphView;

@end

@implementation AGGraphDocument

+ (BOOL)parseBuffer:(NSMutableString *)buffer xGraphData:(AGGraphData *)xGraphData yGraphData:(AGGraphData *)yGraphData zGraphData:(AGGraphData *)zGraphData xRotationGraphData:(AGGraphData *)xRotationGraphData yRotationGraphData:(AGGraphData *)yRotationGraphData zRotationGraphData:(AGGraphData *)zRotationGraphData normGraphData:(AGGraphData *)normGraphData
{
    BOOL result = NO;
    
    if (buffer.length > 0) {
        NSRange range;
        
        while (YES) {
            NSString *line;
            NSArray *split;
            
            range = [buffer lineRangeForRange:NSMakeRange(0, 0)];
            if (range.length == buffer.length) {
                break;
            }
            line = [buffer substringWithRange:range];
            [buffer deleteCharactersInRange:range];
            split = [line componentsSeparatedByString:@" "];
            if (split.count == 3 || split.count == 4) {
                static float x = 0, y = 0, z = 0;
                static int count = 0;
                
                x += [[split objectAtIndex:0] floatValue];
                y += [[split objectAtIndex:1] floatValue];
                z += [[split objectAtIndex:2] floatValue];
                count++;
                if (count == 1) {
                    float xRotation, yRotation, zRotation, norm;
                    
                    x = x / (float)count;
                    y = y / (float)count;
                    z = z / (float)count;
                    norm = sqrtf((x * x) + (y * y) + (z * z));
                    [xGraphData addValue:x];
                    [yGraphData addValue:y];
                    [zGraphData addValue:z];
                    xRotation = my_atanf(y, z, norm);
                    yRotation = my_atanf(z, x, norm);
                    zRotation = my_atanf(x, y, norm);
                    [xRotationGraphData addValue:xRotation];
                    [yRotationGraphData addValue:yRotation];
                    [zRotationGraphData addValue:zRotation];
                    [normGraphData addValue:norm];
                    NSLog(@"norm %f rx %f ry %f rz %f (x %f y %f z %f)", norm, xRotation, yRotation, zRotation, x, y, z);
                    x = 0;
                    y = 0;
                    z = 0;
                    count = 0;
                }
                result = YES;
            }
        }
    }
    return result;
}

+ (void)updateLabel:(NSTextField *)label graphView:(AGGraphView *)graphView graphData:(AGGraphData *)graphData
{
    NSString *selection = @"";
    
    if (graphView.hasSelection) {
        NSUInteger ii, count;
        float sum = 0;
        
        count = graphView.selectedIndexes.location + graphView.selectedIndexes.length;
        if (count > graphData.valueCount) {
            count = graphData.valueCount;
        }
        for (ii = graphView.selectedIndexes.location; ii < count; ii++) {
            sum += [graphData valueAtIndex:ii];
        }
        selection = [NSString stringWithFormat:@" (min: %f, max: %f, duration %ld, sum %f)", graphView.selectedMinValue, graphView.selectedMaxValue, (unsigned long)graphView.selectedIndexes.length, sum];
    }
    [label setStringValue:[NSString stringWithFormat:@"min: %f max: %f%@", graphData.minValue, graphData.maxValue, selection]];
}

- (id)init
{
    self = [super init];
    if (self) {
        _xGraphData = [[AGGraphData alloc] initWithName:@"x"];
        _yGraphData = [[AGGraphData alloc] initWithName:@"y"];
        _zGraphData = [[AGGraphData alloc] initWithName:@"z"];
        _xRotationGraphData = [[AGGraphData alloc] initWithName:@"horizontal"];
        _yRotationGraphData = [[AGGraphData alloc] initWithName:@"vertical"];
        _zRotationGraphData = [[AGGraphData alloc] initWithName:@"vertical"];
        _normGraphData = [[AGGraphData alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SELECTION_DID_CHANGE_GRAPH_VIEW object:_graphView];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"AGGraphDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
//    [_graphView addGraphData:_xRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor redColor]];
//    [_graphView addGraphData:_yRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor blueColor]];
//    [_graphView addGraphData:_zRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor greenColor]];
    [_graphView addGraphData:_normGraphData withColor:nil];
    [[self class] updateLabel:_label graphView:_graphView graphData:_normGraphData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(graphViewSelectionDidChangeNotification:) name:SELECTION_DID_CHANGE_GRAPH_VIEW object:_graphView];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSError *error = nil;
    NSData *result = nil;
    
    if ([typeName isEqualToString:@"AccelerometerGraph"]) {
        result = _data;
    } else {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return result;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSError *error = nil;
    
    if ([typeName isEqualToString:@"AccelerometerGraph"]) {
        NSMutableString *string;
        
        string = [[NSMutableString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        [[self class] parseBuffer:string xGraphData:_xGraphData yGraphData:_yGraphData zGraphData:_zGraphData xRotationGraphData:_xRotationGraphData yRotationGraphData:_yRotationGraphData zRotationGraphData:_zRotationGraphData normGraphData:_normGraphData];
        self.data = data;
        [[self class] updateLabel:_label graphView:_graphView graphData:_normGraphData];
    } else {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    if (outError) {
        *outError = error;
    }
    return YES;
}

- (void)graphViewSelectionDidChangeNotification:(NSNotification *)notification
{
    [[self class] updateLabel:_label graphView:_graphView graphData:_normGraphData];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
