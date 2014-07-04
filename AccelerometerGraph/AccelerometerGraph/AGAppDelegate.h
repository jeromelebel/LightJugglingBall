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

@interface AGAppDelegate : NSObject <NSApplicationDelegate>
{
}
@property (nonatomic, readwrite, weak) IBOutlet NSWindow *window;
@property (nonatomic, readwrite, weak) IBOutlet AGGraphView *graphView;
@property (nonatomic, readwrite, weak) IBOutlet NSTextField *label;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *recordButton;
@property (nonatomic, readwrite, weak) IBOutlet NSButton *displayAxisButton;
@property (nonatomic, readonly, assign) BOOL recording;

- (IBAction)recordButtonAction:(id)sender;
- (IBAction)displayAxisButtonAction:(id)sender;

@end
