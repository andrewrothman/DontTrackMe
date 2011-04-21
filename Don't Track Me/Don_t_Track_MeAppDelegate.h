//
//  Don_t_Track_MeAppDelegate.h
//  Don't Track Me
//
//  Created by AndyRoth on 4/20/11.
//  Copyright 2011 AndyRothTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataHelper.h"

@interface Don_t_Track_MeAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    IBOutlet NSButton *scrambleBTN;
    IBOutlet NSTextField *statusLBL;
    IBOutlet NSProgressIndicator *progIndi;
    NSMutableArray *filePaths;
    int locationFilesFound;
}

@property (assign) IBOutlet NSWindow *window;

- (int)searchForDB;
- (IBAction)scramble:(id)sender;

@end
