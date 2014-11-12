//
//  ViewController.h
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionWrapper.h"
#import "BrowserWrapper.h"
#import "AdvertiserWrapper.h"
#import "FileSystem.h"

@interface ViewController : UIViewController <SessionWrapperDelegate, BrowserWrapperDelegate, AdvertiserWrapperDelegate>


@property (nonatomic) SessionWrapper *sessionWrapper;
@property (nonatomic) BrowserWrapper *browserWrapper;
@property (nonatomic) AdvertiserWrapper *advertiserWrapper;

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSMutableArray *arrFiles;
@property (nonatomic, strong) FileSystem *fileSystem;


-(NSMutableArray *)getAllDocDirFiles;
-(void) deleteAllDocumdentsFromSandbox;



@end

