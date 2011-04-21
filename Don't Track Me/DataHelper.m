//
//  DataHelper.m
//  Don't Track Me
//
//  Created by AndyRoth on 4/20/11.
//  Copyright 2011 AndyRothTech. All rights reserved.
//

#import "DataHelper.h"

static NSNumber* getint(uint8_t* data, size_t* offset, size_t intsize);
static NSString* getstring(uint8_t* data, size_t* offset);
static NSDictionary* process_mbdb_file(NSString* filename);
static NSDictionary* process_mbdx_file(NSString* filename);

@implementation DataHelper
+ (BOOL)deleteLocationDB:(NSString*)locationDBPath {
    //Open database.
    FMDatabase* database = [FMDatabase databaseWithPath:locationDBPath];
    [database setLogsErrors: YES];
    BOOL openWorked = [database open];
    if (!openWorked) {
        return NO;
    }
    //Delete database entries.
    [database executeUpdate:@"DELETE FROM CellLocation WHERE '1' = '1'"];
    [database executeUpdate:@"DELETE FROM WifiLocation WHERE '1' = '1'"];
    //Add 10 empty entry to pass validation. Set the altitude to i.
    for (int i = 0; i<9;i++) {
        //[database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%d, 0, 0, \"0\", 0, 0, \"0\", \"0\", \"0\", 0, \"0\", \"0\", \"0\")", i]];
    }
    //(mcc, mnc, lac, ci, "timestamp", "latitude", "longitude", "horizontalaccuracy", altitude, "verticalaccuracy", "speed", "course", confidence).
    NSString *mcc = @"0";
    NSString *mnc = @"0";
    NSString *lac = @"0";
    NSString *ci = @"0";
    NSString *timestamp = @"0";
    NSString *latitude = @"-1000000";
    NSString *longitude = @"-100000";
    NSString *horizontalAccuracy = @"-1";
    NSString *altitude = @"0";
    NSString *verticalAccuracy = @"-1";
    NSString *speed = @"-1";
    NSString *course = @"-1";
    NSString *confidence = @"0";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"403786537.118018";
    mcc = @"10";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"503786537.118018";
    mcc = @"20";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"603786537.118018";
    mcc = @"30";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"703786537.118018";
    mcc = @"40";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"803786537.118018";
    mcc = @"50";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"903786537.118018";
    mcc = @"60";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"1003786537.118018";
    mcc = @"70";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    timestamp = @"1103786537.118018";
    mcc = @"80";
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO CellLocation VALUES (%@, %@, %@, %@, \"%@\", \"%@\", \"%@\", \"%@\", %@, \"%@\", \"%@\", \"%@\", %@)", mcc, mnc, lac, ci, timestamp, latitude, longitude, horizontalAccuracy, altitude, verticalAccuracy, speed, course, confidence]];
    //Close database.
    [database close];
    return YES;
}
+ (NSDictionary*) getFileListForPath:(NSString*)path {
    NSDictionary* mbdb = process_mbdb_file([path stringByAppendingPathComponent:@"Manifest.mbdb"]);
    NSDictionary* mbdx = process_mbdx_file([path stringByAppendingPathComponent:@"Manifest.mbdx"]);
    
    if ((mbdb==nil)||(mbdx==nil)) {
        return nil;
    }
    
    for (NSNumber* offset in mbdb) {
        NSMutableDictionary* fileinfo = [mbdb objectForKey:offset];
        NSString* fileID = [mbdx objectForKey:offset];
        if (fileID==nil) {
            fileID = @"<nofileID>";
        }
        [fileinfo setObject: fileID forKey:@"fileID"];
    }
    
    return mbdb;
}

@end

// Adapted from Python at
// http://stackoverflow.com/questions/3085153/how-to-parse-the-manifest-mbdb-file-in-an-ios-4-0-itunes-backup

NSNumber* getint(uint8_t* data, size_t* offset, size_t intsize){
    // Retrieve an integer (big-endian) and new offset from the current offset
    int value = 0;
    while (intsize > 0) {
        value = (value<<8) + data[*offset];
        *offset = *offset + 1;
        intsize = intsize - 1;
    }
    
    return [NSNumber numberWithInteger: value];
}

NSString* getstring(uint8_t* data, size_t* offset) {
    // Retrieve a string and new offset from the current offset into the data
    if ((data[*offset]==0xFF) && (data[*offset+1]==0xFF)) {
        // Blank string
        char* value = malloc(2);
        strcpy(value, "");
        *offset += 2;
        NSString* result = [[NSString alloc] initWithUTF8String:value];
        //    NSLog(@"result=<blank>", result);
        return result;
    }
    
    int length = [getint(data, offset, 2) integerValue];
    size_t start = *offset;
    char* value = malloc(length+1);
    strncpy(value, (data+start), length);
    value[length] = 0;
    
    *offset += length;
    
    NSString* result = [[NSString alloc] initWithUTF8String:value];
    if (result==nil) {
        result = @"<null>";
    }
    //  NSLog(@"result=%@", result);
    return result;
}

NSDictionary* process_mbdb_file(NSString* filename) {
    NSMutableDictionary* mbdb = [NSMutableDictionary dictionary]; // Map offset of info in this file => file info
    NSData* fileData = [NSData dataWithContentsOfFile: filename];
    size_t dataLength = [fileData length];
    uint8_t* data = (uint8_t*)[fileData bytes];
    
    if (data==NULL) {
        NSLog(@"No MBDB file found at '%@'", filename);
        return nil;
    }
    
    if ((data[0]!='m')||
        (data[1]!='b')||
        (data[2]!='d')||
        (data[3]!='b')) {
        fprintf(stderr, "Bad header found for mbdb file");
        return mbdb;
    }
    size_t offset = 4;
    offset = offset + 2; // value x05 x00, not sure what this is
    while (offset < dataLength) {
        NSMutableDictionary* fileinfo = [NSMutableDictionary dictionary];
        [fileinfo setObject: [NSNumber numberWithInteger: offset] forKey:@"start_offset"];
        [fileinfo setObject:getstring(data, &offset) forKey:@"domain"]; 
        [fileinfo setObject:getstring(data, &offset) forKey:@"filename"];
        [fileinfo setObject:getstring(data, &offset) forKey:@"linktarget"];
        [fileinfo setObject:getstring(data, &offset) forKey:@"datahash"];
        [fileinfo setObject:getstring(data, &offset) forKey:@"unknown1"]; 
        [fileinfo setObject:getint(data, &offset, 2) forKey:@"mode"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"unknown2"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"unknown3"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"userid"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"groupid"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"mtime"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"atime"];
        [fileinfo setObject:getint(data, &offset, 4) forKey:@"ctime"];
        [fileinfo setObject:getint(data, &offset, 8) forKey:@"filelen"];
        [fileinfo setObject:getint(data, &offset, 1) forKey:@"flag"];
        [fileinfo setObject:getint(data, &offset, 1) forKey:@"numprops"];
        
        NSMutableDictionary* properties = [NSMutableDictionary dictionary];
        const int numProps = [[fileinfo objectForKey:@"numprops"] integerValue];
        for (int ii=0; ii<numProps; ii++) {
            NSString* propname = getstring(data, &offset);
            NSString* propval = getstring(data, &offset);
            [properties setObject: propval forKey:propname];
        }
        [fileinfo setObject:properties forKey:@"properties"];
        
        [mbdb setObject: fileinfo forKey:[fileinfo objectForKey:@"start_offset"]];
    }
    
    return mbdb;
}

NSDictionary* process_mbdx_file(NSString* filename) {
    
    NSMutableDictionary* mbdx = [NSMutableDictionary dictionary]; // Map offset of info in the MBDB file => fileID string
    NSData* fileData = [NSData dataWithContentsOfFile: filename];
    size_t dataLength = [fileData length];
    uint8_t* data = (uint8_t*)[fileData bytes];
    
    if (data==NULL) {
        NSLog(@"No MBDX file found at '%@'", filename);
        return nil;
    }
    
    if ((data[0]!='m')||
        (data[1]!='b')||
        (data[2]!='d')||
        (data[3]!='x')) {
        fprintf(stderr, "Bad header found for mbdx file");
        return mbdx;
    }
    size_t offset = 4;
    offset = offset + 2; // value 0x02 0x00, not sure what this is
    
    char* hexArray = "0123456789abcdef";
    
    NSNumber* filecount = getint(data, &offset, 4); // 4-byte count of records 
    while (offset < dataLength) {
        // 26 byte record, made up of ...
        char* fileID_string = malloc(41);
        for (int i=0; i<20; i+=1) {
            uint8_t v = data[offset+i];
            uint8_t l = (v&0x0f);
            uint8_t h = (v&0xf0)>>4;
            fileID_string[(i*2)+0] = hexArray[h];
            fileID_string[(i*2)+1] = hexArray[l];
        }
        fileID_string[40] = 0;
        
        NSString* fileID_nsString = [[NSString alloc] initWithUTF8String:fileID_string];
        
        offset = offset + 20;
        NSNumber* mbdb_offset = getint(data, &offset, 4); // 4-byte offset field
        mbdb_offset = [NSNumber numberWithInteger: ([mbdb_offset integerValue] + 6)]; // Add 6 to get past prolog
        NSNumber* mode = getint(data, &offset, 2); // 2-byte mode field
        [mbdx setObject:fileID_nsString forKey: mbdb_offset];
    }
    
    return mbdx;
}
@end
