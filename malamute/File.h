//
//  File.h
//  malamute
//
//  Created by Quique Lores on 11/11/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSString* sender;
@property (nonatomic, strong) NSDate* dateCreated;

@end
