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

@interface ViewController : UIViewController <SessionWrapperDelegate, BrowserWrapperDelegate, AdvertiserWrapperDelegate>


@property (nonatomic) SessionWrapper *sessionWrapper;
@property (nonatomic) BrowserWrapper *browserWrapper;
@property (nonatomic) AdvertiserWrapper *advertiserWrapper;

@end

