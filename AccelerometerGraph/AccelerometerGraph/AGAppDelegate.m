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
#import "AGBallManager.h"
#import "AGBall.h"

#define BluetoothDeviceID @"00:06:66:45:B5:B1"

@interface AGAppDelegate ()
@property (nonatomic, readwrite, strong) AGBallManager *ballManager;
@property (nonatomic, readwrite, strong) AGGraphData *xGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *xRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *yRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *zRotationGraphData;
@property (nonatomic, readwrite, strong) AGGraphData *normGraphData;
@property (nonatomic, readwrite, assign) BOOL recording;
@property (nonatomic, readwrite, strong) NSMutableData *recodingData;

@end

@interface AGAppDelegate (AGBallManagerDelegate) <AGBallManagerDelegate>

@end

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
    [self.xGraphData addValue:value];
    [self performSelector:@selector(_createFakeValues) withObject:nil afterDelay:1];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.ballManager = [[AGBallManager alloc] init];
    self.ballManager.delegate = self;
    
    self.displayAxisButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"displayAllAxis"]?NSOnState:NSOffState;
    
    self.xGraphData = [[AGGraphData alloc] init];
    self.xGraphData.valueCountLimit = 1000;
//    [self.graphView addGraphData:self.xGraphData withColor:[NSColor redColor]];
//    self.yGraphData = [[AGGraphData alloc] init];
//    self.yGraphData.valueCountLimit = 1000;
//    self.zGraphData = [[AGGraphData alloc] init];
//    self.zGraphData.valueCountLimit = 1000;
//    self.xRotationGraphData = [[AGGraphData alloc] init];
//    self.xRotationGraphData.valueCountLimit = 1000;
//    self.yRotationGraphData = [[AGGraphData alloc] init];
//    self.yRotationGraphData.valueCountLimit = 1000;
//    self.zRotationGraphData = [[AGGraphData alloc] init];
//    self.zRotationGraphData.valueCountLimit = 1000;
//    self.normGraphData = [[AGGraphData alloc] init];
//    self.normGraphData.valueCountLimit = 1000;
//    if (self.displayAxisButton.state == NSOnState) {
//        [self.graphView addGraphData:self.xGraphData withColor:[NSColor redColor]];
//        [self.graphView addGraphData:self.yGraphData withColor:[NSColor greenColor]];
//        [self.graphView addGraphData:self.zGraphData withColor:[NSColor blueColor]];
//    }
//    [self.graphView addGraphData:self.xRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor redColor]];
//    [self.graphView addGraphData:self.yRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor blueColor]];
//    [self.graphView addGraphData:self.zRotationGraphData withMinValue:[NSNumber numberWithFloat:-180] maxValue:[NSNumber numberWithFloat:180] color:[NSColor greenColor]];
//    [self.graphView addGraphData:self.normGraphData withColor:[NSColor blackColor]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(graphViewSelectionDidChangeNotification:) name:SELECTION_DID_CHANGE_GRAPH_VIEW object:self.graphView];
    [self _createFakeValues];
}

- (IBAction)recordButtonAction:(id)sender
{
    self.recording = !self.recording;
    self.recordButton.title = self.recording?@"Stop":@"Record";
    if (self.recording) {
        self.recodingData = [[NSMutableData alloc] init];
    } else {
        AGGraphDocument *document;
        NSError *error = nil;
        
        document = [[AGGraphDocument alloc] initWithType:@"AccelerometerGraph" error:&error];
        if (error) NSLog(@"error document %@", error);
        [document readFromData:self.recodingData ofType:@"AccelerometerGraph" error:&error];
        if (error) NSLog(@"error document %@", error);
        [document makeWindowControllers];
        [document showWindows];
    }
}

- (IBAction)displayAxisButtonAction:(id)sender
{
    if (self.displayAxisButton.state == NSOnState) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"displayAllAxis"];
        [self.graphView addGraphData:self.xGraphData withColor:[NSColor redColor]];
        [self.graphView addGraphData:self.yGraphData withColor:[NSColor greenColor]];
        [self.graphView addGraphData:self.zGraphData withColor:[NSColor blueColor]];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"displayAllAxis"];
        [self.graphView removeGraphData:self.xGraphData];
        [self.graphView removeGraphData:self.yGraphData];
        [self.graphView removeGraphData:self.zGraphData];
    }
}

- (void)graphViewSelectionDidChangeNotification:(NSNotification *)notification
{
    [AGGraphDocument updateLabel:self.label graphView:self.graphView graphData:self.normGraphData];
}

@end

@implementation AGAppDelegate (AGBallManagerDelegate)

- (void)ballManager:(AGBallManager *)ballManager addBall:(AGBall *)ball
{
//    [self.graphView addGraphData:ball.xGraphData withColor:[NSColor redColor]];
//    [self.graphView addGraphData:ball.yGraphData withColor:[NSColor greenColor]];
    [self.graphView addGraphData:ball.normGraphData withColor:[NSColor blueColor]];
    if ((1)) {
        [self.graphView addGraphData:ball.rotationNormGraphData withColor:[NSColor greenColor]];
    } else {
        [self.graphView addGraphData:ball.xRotationGraphData withColor:[NSColor greenColor]];
        [self.graphView addGraphData:ball.yRotationGraphData withColor:[NSColor redColor]];
        [self.graphView addGraphData:ball.zRotationGraphData withColor:[NSColor purpleColor]];
    }
}

- (void)ballManager:(AGBallManager *)ballManager removeBall:(AGBall *)ball
{
    [self.graphView removeGraphData:ball.normGraphData];
    [self.graphView removeGraphData:ball.xRotationGraphData];
    [self.graphView removeGraphData:ball.yRotationGraphData];
    [self.graphView removeGraphData:ball.zRotationGraphData];
}

@end