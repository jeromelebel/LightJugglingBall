//
//  AGAppDelegate.m
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGGraphData.h"
#import "AGGraphView.h"
#import "AGDevice.h"
#import "AGGraphDocument.h"
#import "AGSparkManager.h"
#import "AGSparkDevice.h"
//#import "AccelerometerGraph-Swift.h"

#define BluetoothDeviceID @"00:06:66:45:B5:B1"

@implementation AGAppDelegate

- (void)_createFakeValues
{
    static float value = 0;
    static float diff = 0.1;
    
    value += diff;
//    NSLog(@"diff %f (value >= 10.0 && diff > 0) %@ (value <= -10.0 && diff < 0) %@", diff, (value >= 10.0 && diff > 0)?@"YES":@"NO", (value <= -10.0 && diff < 0)?@"YES":@"NO");
    if ((value >= 10.0 && diff > 0) || (value <= -10.0 && diff < 0)) {
        diff = -diff;
    }
//    NSLog(@"value %f, diff %f", value, diff);
    if (!_device.isConnected) {
        [self device:nil receivedBuffer:[NSString stringWithFormat:@"%f %f %f 0\n", value, value, value]];
        [self performSelector:@selector(_createFakeValues) withObject:nil afterDelay:0.1];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _displayAxisButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"displayAllAxis"]?NSOnState:NSOffState;
    
    _buffer = [[NSMutableString alloc] init];
    _xGraphData = [[AGGraphData alloc] init];
    _xGraphData.valueCountLimit = 1000;
    _yGraphData = [[AGGraphData alloc] init];
    _yGraphData.valueCountLimit = 1000;
    _zGraphData = [[AGGraphData alloc] init];
    _zGraphData.valueCountLimit = 1000;
    _xRotationGraphData = [[AGGraphData alloc] init];
    _xRotationGraphData.valueCountLimit = 1000;
    _yRotationGraphData = [[AGGraphData alloc] init];
    _yRotationGraphData.valueCountLimit = 1000;
    _zRotationGraphData = [[AGGraphData alloc] init];
    _zRotationGraphData.valueCountLimit = 1000;
    _normGraphData = [[AGGraphData alloc] init];
    _normGraphData.valueCountLimit = 1000;
    if (_displayAxisButton.state == NSOnState) {
        [_graphView addGraphData:_xGraphData withColor:[NSColor redColor]];
        [_graphView addGraphData:_yGraphData withColor:[NSColor greenColor]];
        [_graphView addGraphData:_zGraphData withColor:[NSColor blueColor]];
    }
    [_graphView addGraphData:_xRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor redColor]];
    [_graphView addGraphData:_yRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor blueColor]];
    [_graphView addGraphData:_zRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor greenColor]];
    [_graphView addGraphData:_normGraphData withColor:[NSColor blackColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(graphViewSelectionDidChangeNotification:) name:SELECTION_DID_CHANGE_GRAPH_VIEW object:_graphView];
    
    _device = [[AGDevice alloc] init];
    _device.delegate = self;
    [_device connectWithDeviceID:BluetoothDeviceID];
    
//    [self _createFakeValues];
}

- (void)device:(id)device receivedBuffer:(NSString *)buffer
{
    [_buffer appendString:buffer];
    if (_buffer.length > 0) {
        if ([AGGraphDocument parseBuffer:_buffer xGraphData:_xGraphData yGraphData:_yGraphData zGraphData:_zGraphData xRotationGraphData:_xRotationGraphData yRotationGraphData:_yRotationGraphData zRotationGraphData:_zRotationGraphData normGraphData:_normGraphData]) {
            [AGGraphDocument updateLabel:_label graphView:_graphView graphData:_normGraphData];
        }
    }
    if (_recodingData) {
        [_recodingData appendBytes:[buffer UTF8String] length:strlen([buffer UTF8String])];
    }
}

- (IBAction)recordButtonAction:(id)sender
{
    _recording = !_recording;
    _recordButton.title = _recording?@"Stop":@"Record";
    if (_recording) {
        _recodingData = [[NSMutableData alloc] init];
    } else {
        AGGraphDocument *document;
        NSError *error = nil;
        
        document = [[AGGraphDocument alloc] initWithType:@"AccelerometerGraph" error:&error];
        if (error) NSLog(@"error document %@", error);
        [document readFromData:_recodingData ofType:@"AccelerometerGraph" error:&error];
        if (error) NSLog(@"error document %@", error);
        [document makeWindowControllers];
        [document showWindows];
//        [document release];
    }
}

- (IBAction)displayAxisButtonAction:(id)sender
{
    if (_displayAxisButton.state == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"displayAllAxis"];
        [_graphView addGraphData:_xGraphData withColor:[NSColor redColor]];
        [_graphView addGraphData:_yGraphData withColor:[NSColor greenColor]];
        [_graphView addGraphData:_zGraphData withColor:[NSColor blueColor]];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"displayAllAxis"];
        [_graphView removeGraphData:_xGraphData];
        [_graphView removeGraphData:_yGraphData];
        [_graphView removeGraphData:_zGraphData];
    }
}

- (void)graphViewSelectionDidChangeNotification:(NSNotification *)notification
{
    [AGGraphDocument updateLabel:_label graphView:_graphView graphData:_normGraphData];
}

@end
