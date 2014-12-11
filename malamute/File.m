//
//  File.m
//  malamute
//
//  Created by Quique Lores & Yvan Scher on 11/11/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import "File.h"

@implementation File

/* - inits a File object with a name and url path - */
-(instancetype)initWithName:(NSString*) name andURL:(NSURL*)url andDate:(NSDate*)date andDirectoryFlag:(BOOL)isDirectory{
    
    _name = [[NSString alloc] initWithString:name];
    _url = url;
    _dateCreated = date;
    _isDirectory = isDirectory;
    return self;
}

@end