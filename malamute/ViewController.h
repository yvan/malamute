//
//  ViewController.h
//  malamute
//
//  Created by Yvan Scher & Enrique Lores on 10/31/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileSystem.h"
#import "SessionWrapper.h"
#import "BrowserWrapper.h"
#import "FileAddingCell.h"
#import "AdvertiserWrapper.h"
#import "FileCollectionViewCell.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, SessionWrapperDelegate, BrowserWrapperDelegate, AdvertiserWrapperDelegate>

@property (nonatomic, strong) IBOutlet UIButton *selectSendButton;
@property (nonatomic, strong) IBOutlet UIButton *selectDeleteButton;
@property (nonatomic, strong) IBOutlet UIButton *getPhotoFromLibary;
@property (nonatomic, strong) IBOutlet UIButton *selectBlanketButton;
@property (nonatomic, strong) IBOutlet UILabel *connectionStatusLabel;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionOfFiles;
@property (nonatomic, strong) IBOutlet UIButton *selectDirectoryModeShared;
@property (nonatomic, strong) IBOutlet UIButton *selectDirectoryModePrivate;

@property (nonatomic) SessionWrapper *sessionWrapper;
@property (nonatomic) BrowserWrapper *browserWrapper;
@property (nonatomic) AdvertiserWrapper *advertiserWrapper;

@property (nonatomic) BOOL selectEnabled;
@property (nonatomic) BOOL privateOrShared;           /* - 0 for private directory, 1 for shared - */
@property (nonatomic, strong) FileSystem *fileSystem; /* - our abstract representation of the filsystem - */
@property (nonatomic) NSMutableArray *selectedFiles;
@property (nonatomic, strong) NSString *selectedFile;

-(void) summonPhotoLibrary;
-(void) savePictureToPhotoLibrary:(UIImage *)image;

-(IBAction) clickedDeleteButton:(id)sender;
-(IBAction) clickedSelectSendButton:(id)sender;
-(IBAction) clickedSelectDirectoryButton:(id)sender;

@end

