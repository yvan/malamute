//
//  File.h
//  malamute
//
//  Created by Quique Lores & Yvan Scher on 11/11/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject

@property (nonatomic) BOOL isDirectory;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSString* sender;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSDate* dateCreated;

-(instancetype)initWithName:(NSString*) name andURL:(NSURL*)url andDate:(NSDate*)date andDirectoryFlag:(BOOL)isDirectory;
@end
