//
//  Don_t_Track_MeAppDelegate.m
//  Don't Track Me
//
//  Created by AndyRoth on 4/20/11.
//  Copyright 2011 AndyRothTech. All rights reserved.
//

#import "Don_t_Track_MeAppDelegate.h"

@implementation Don_t_Track_MeAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //Do not allow user to change window size.
    [window setShowsResizeIndicator:NO];
    
    //Allocate array.
    filePaths = [[NSMutableArray alloc] init];
    
    //Resize window.
    NSInteger sizeDifference = -25;
    [window setFrame:NSMakeRect([window frame].origin.x, [window frame].origin.y - sizeDifference, [window frame].size.width, [window frame].size.height + sizeDifference) display:YES animate:YES];
    
    //Search for consolidated databases. Set the label to the amount of databases found.
    [self performSelectorInBackground:@selector(searchForDBs) withObject:nil];
    if (filesFound == 1) {
        [statusLBL setStringValue:@"1 location file found."];
    }
    else {
        [statusLBL setStringValue:[NSString stringWithFormat:@"%d location files found.", filesFound]];
    }
}
- (IBAction)scramble:(id)sender {
    //Animate progress indicator.
    [progIndi startAnimation:nil];
    //Resize window.
    NSInteger sizeDifference = 25;
    [self performSelectorInBackground:@selector(doScramble) withObject:nil];
    [window setFrame:NSMakeRect([window frame].origin.x, [window frame].origin.y - sizeDifference, [window frame].size.width, [window frame].size.height + sizeDifference) display:YES animate:YES];
    //Set text.
    [statusLBL setStringValue:@"Scrambling data..."];
}
- (void)doScramble {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    //Run scrambling code.
    for (NSString *tempPath in filePaths) {
        if (![DataHelper deleteLocationDB:tempPath]) {
            NSAlert *errorAlert = [NSAlert alertWithMessageText:@"Error." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"There was an error scrambling location data."];
            [errorAlert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }
        [self performSelectorOnMainThread:@selector(doneScrambling) withObject:nil waitUntilDone:NO];
    }
    [pool release];
}
- (void)doneScrambling {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    //Stop progress indicator animation.
    [progIndi stopAnimation:nil];
    //Resize window.
    NSInteger sizeDifference = -25;
    [window setFrame:NSMakeRect([window frame].origin.x, [window frame].origin.y - sizeDifference, [window frame].size.width, [window frame].size.height + sizeDifference) display:YES animate:YES];
    //Set text.
    [statusLBL setStringValue:@"Done."];
    [pool release];
}
- (void)searchForDBs {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString* backupPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/MobileSync/Backup/"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray* backupContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:backupPath error:nil];    
    NSMutableArray* fileInfoList = [NSMutableArray array];
    for (NSString *childName in backupContents) {
        NSString* childPath = [backupPath stringByAppendingPathComponent:childName];
        
        NSString *plistFile = [childPath   stringByAppendingPathComponent:@"Info.plist"];
        
        NSError* error;
        NSDictionary *childInfo = [fm attributesOfItemAtPath:childPath error:&error];
        
        NSDate* modificationDate = [childInfo objectForKey:@"NSFileModificationDate"];    
        
        NSDictionary* fileInfo = [NSDictionary dictionaryWithObjectsAndKeys: 
                                  childPath, @"fileName", 
                                  modificationDate, @"modificationDate", 
                                  plistFile, @"plistFile", 
                                  nil];
        [fileInfoList addObject:fileInfo];
        
    }
    
    NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:NO] autorelease];
    [fileInfoList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    BOOL loadWorked = NO;
    for (NSDictionary* fileInfo in fileInfoList) {
        @try {
            NSString* newestFolder = [fileInfo objectForKey:@"fileName"];
            NSString* plistFile = [fileInfo objectForKey:@"plistFile"];
            
            NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistFile];
            if (plist==nil) {
                NSLog(@"No plist file found at '%@'", plistFile);
                continue;
            }
            NSString* deviceName = [plist objectForKey:@"Device Name"];
            NSLog(@"file = %@, device = %@", plistFile, deviceName);  
            
            NSDictionary* mbdb = [DataHelper getFileListForPath: newestFolder];
            if (mbdb==nil) {
                NSLog(@"No MBDB file found at '%@'", newestFolder);
                continue;
            }
            
            NSString* wantedFileName = @"Library/Caches/locationd/consolidated.db";
            NSString* dbFileName = nil;
            for (NSNumber* offset in mbdb) {
                NSDictionary* fileInfo = [mbdb objectForKey:offset];
                NSString* fileName = [fileInfo objectForKey:@"filename"];
                if ([wantedFileName compare:fileName]==NSOrderedSame) {
                    dbFileName = [fileInfo objectForKey:@"fileID"];
                }
            }
            
            if (dbFileName==nil) {
                NSLog(@"No consolidated.db file found in '%@'", newestFolder);
                continue;
            }
            
            [filePaths addObject:[newestFolder stringByAppendingPathComponent:dbFileName]];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", [exception reason]);
        }
    }
    
    if (!loadWorked) {
        NSLog(@"Error!");
    }
    
    [scrambleBTN setEnabled:YES];
    filesFound = [[NSString stringWithFormat:@"%d", [filePaths count]] intValue];
    [pool release];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication {
    return YES;
}
@end
