//
//  ViewController.h
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileSystem.h"
#import "SessionWrapper.h"
#import "BrowserWrapper.h"
#import "AdvertiserWrapper.h"
#import "FileCollectionViewCell.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SessionWrapperDelegate, BrowserWrapperDelegate, AdvertiserWrapperDelegate>

@property (nonatomic, strong) IBOutlet UIButton *selectSendButton;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionOfFiles;
@property (nonatomic, strong) IBOutlet UIButton *selectDirectoryModeShared;
@property (nonatomic, strong) IBOutlet UIButton *selectDirectoryModePrivate;

@property (nonatomic) SessionWrapper *sessionWrapper;
@property (nonatomic) BrowserWrapper *browserWrapper;
@property (nonatomic) AdvertiserWrapper *advertiserWrapper;

@property (nonatomic) BOOL selectEnabled;
@property (nonatomic) BOOL privateOrShared;           /* - 0 for private directory, 1 for shared - */
@property (nonatomic) NSInteger buttonState;          /* - 0 is original "Select" 1 is "Move to.." - */
@property (nonatomic, strong) FileSystem *fileSystem; /* - our abstract representation of the filsystem - */
@property (nonatomic) NSMutableArray *selectedFiles;
@property (nonatomic, strong) NSString *selectedFile;



-(IBAction) clickedSelectSendButton:(id)sender;
-(IBAction) clickedSelectDirectoryButton:(id)sender;

@end

