//
//  AGAppDelegate.h
//  AccelerometerGraph
//
//  Created by Jérôme Lebel on 19/06/12.
//  Copyright (c) 2012 Fotonauts. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AGDevice.h"

@class AGGraphData;
@class AGGraphView;

@interface AGAppDelegate : NSObject <NSApplicationDelegate, AGDeviceDelegate>
{
    IBOutlet NSWindow *_window;
    IBOutlet AGGraphView *_graphView;
    IBOutlet NSTextField *_label;
    IBOutlet NSButton *_recordButton;
    IBOutlet NSButton *_displayAxisButton;
    
    AGDevice *_device;
    AGGraphData *_xGraphData;
    AGGraphData *_yGraphData;
    AGGraphData *_zGraphData;
    AGGraphData *_xRotationGraphData;
    AGGraphData *_yRotationGraphData;
    AGGraphData *_zRotationGraphData;
    AGGraphData *_normGraphData;
    
    NSMutableString *_buffer;
    BOOL _recording;
    NSMutableData *_recodingData;
}

- (IBAction)recordButtonAction:(id)sender;
- (IBAction)displayAxisButtonAction:(id)sender;

@end
