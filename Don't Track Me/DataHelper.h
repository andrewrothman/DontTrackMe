//
//  DataHelper.h
//  Don't Track Me
//
//  Created by AndyRoth on 4/20/11.
//  Copyright 2011 AndyRothTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DataHelper : NSObject {
    
}

+ (BOOL)deleteLocationDB:(NSString*)locationDBPath;
+ (NSDictionary*)getFileListForPath:(NSString*)path;

@end
