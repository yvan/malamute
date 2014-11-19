//
//  File.m
//  malamute
//
//  Created by Quique Lores on 11/11/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "File.h"

@implementation File

//inits a File object with a name and url path
-(instancetype)initWithName:(NSString*) name andURL:(NSURL*)url{
    
    _name = [[NSString alloc] initWithString:name];
    _url = url;
    return self;
}

@end