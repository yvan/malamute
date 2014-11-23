//
//  ViewController.m
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

static BOOL const PRIVATE = 0;
static BOOL const SHARED = 1;

#pragma mark - FileUtility

//didn't use NSRange bec. it's non obvious
-(UIImageView *) assignIconForFileType:(NSString *) filename withBool:(BOOL)selected{
    
    NSInteger finalDot = 0;
    NSString *fileExtension = @"";
    
    for (NSInteger index=0; index<filename.length;index++){
        if([filename characterAtIndex:index] == '.'){
            finalDot = index;
        }
        if(index == filename.length-1){
            
            fileExtension = [filename substringFromIndex:finalDot+1];
        }
        if(finalDot == 0){
            
            fileExtension = @"directory";
        }
    }

    UIImageView *iconViewForCell;
    if(selected){
        CGSize newSize = CGSizeMake(50.0, 50.0);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-sel.png", fileExtension]];
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        iconViewForCell = [[UIImageView alloc] initWithImage:newImage];
    }else{
        CGSize newSize = CGSizeMake(50.0, 50.0);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", fileExtension]];
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        iconViewForCell = [[UIImageView alloc] initWithImage:newImage];
    }
    iconViewForCell.frame = CGRectMake(iconViewForCell.frame.origin.x, iconViewForCell.frame.origin.y, 10, 10);
    //iconViewForCell.contentMode = UIViewContentModeCenter;
    iconViewForCell.clipsToBounds = YES;
    return iconViewForCell;
}

#pragma mark - IBActions

-(IBAction) clickedSelectSendButton:(id)sender{ //shared
    NSLog(@"blah1");
    if(_privateOrShared == SHARED){//we are in shared folder
        NSLog(@"blahshared");
        if(_buttonState == 0){
            [_selectSendButton setTitle:@"Move to Private" forState:UIControlStateNormal];
            _buttonState = 1;
            _selectEnabled = YES;
            _collectionOfFiles.allowsMultipleSelection = YES;
        }
        else{
           // [_fileSystem moveFiles:_selectedFiles from:_fileSystem.sharedDocs to:_fileSystem.privateDocs withInfo:_privateOrShared];
            [_fileSystem saveDocumentsToSandbox:_selectedFiles];
            [_selectedFiles removeAllObjects];
            [_selectSendButton setTitle:@"Sent! Select More files..." forState:UIControlStateNormal];
            _buttonState = 0;
            _selectEnabled = NO;
        }
    }else{//we are IN the private folder
        NSLog(@"blahprivate");
        if(_buttonState == 0){
            [_selectSendButton setTitle:@"Move to Shared" forState:UIControlStateNormal];
            _buttonState = 1;
            _selectEnabled = YES;
            _collectionOfFiles.allowsMultipleSelection = YES;
        }
        else{
            //[_fileSystem moveFiles:_selectedFiles from:_fileSystem.privateDocs to:_fileSystem.sharedDocs withInfo:_privateOrShared];
            [_sessionWrapper sendFiles:_selectedFiles toPeers:_sessionWrapper.connectedPeerIDs];
            [_fileSystem.sharedDocs addObjectsFromArray:_selectedFiles];
            [_selectedFiles removeAllObjects];
            [_selectSendButton setTitle:@"Sent! Select More files..." forState:UIControlStateNormal];
            _buttonState = 0;
            _selectEnabled = NO;
        }
    }
}

-(IBAction) clickedSelectDirectoryButton:(id)sender{
    
    if(sender == _selectDirectoryModeShared){ //selectDirectoryMode Clicked
        
        [_selectSendButton setTitle:@"Select Files" forState:UIControlStateNormal];
        [_selectDirectoryModeShared setTitle:@"Shared" forState:UIControlStateNormal];
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:135.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0]];
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0]];
        _privateOrShared = SHARED;
        _buttonState = 0;
        _selectEnabled = NO;
        [_selectedFiles removeAllObjects];
        [_collectionOfFiles reloadData];
        NSLog(@"switch to shared");
    }
    if(sender == _selectDirectoryModePrivate){
        [_selectSendButton setTitle:@"Select Files" forState:UIControlStateNormal];
        
        [_selectDirectoryModePrivate setTitle:@"Private" forState:UIControlStateNormal];
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:135.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0]];
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0]];
        _privateOrShared = PRIVATE;
        _buttonState = 0;
        _selectEnabled = NO;
        [_selectedFiles removeAllObjects];
        [_collectionOfFiles reloadData];
        NSLog(@"switch to private");
    }
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _privateOrShared == PRIVATE ? [_fileSystem.privateDocs count]:[_fileSystem.sharedDocs count];
}

-(FileCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder" forIndexPath:indexPath];
    //set the appropriate seleted iamge image (red in-filled image)
    if(_privateOrShared == PRIVATE){
        cell.backgroundView = [self assignIconForFileType:((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name withBool:0];
        cell.selectedBackgroundView = [self assignIconForFileType:((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name withBool:1];
        cell.cellLabel.text = ((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name;

    }else{
        cell.backgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name withBool:0];
        cell.selectedBackgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name withBool:1];
        cell.cellLabel.text = ((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name;
    }
    return cell;
}

/*- (UICollectionReusableView *)co2llectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_selectEnabled){
        FileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder" forIndexPath:indexPath];
        _selectedFile = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs objectAtIndex:indexPath.row]:[_fileSystem.sharedDocs objectAtIndex:indexPath.row];
        [_selectedFiles addObject:_selectedFile];
        cell.cellLabel.text = @"derp2";
        NSLog(@"touched");
    }
    else{
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (_selectEnabled) {
        //**Need to determine whether or not we're in Shared Folder or Documents Folder**//
        //so add an entry for privateDocs, for now just do sharedDocs
        _selectedFile = [_fileSystem.sharedDocs objectAtIndex:indexPath.row];
        [_selectedFiles removeObject:_selectedFile];
    }
    NSLog(@"untouched");
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize fileIconSize;
    fileIconSize.height = 72;
    fileIconSize.width = 72;
    return fileIconSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


#pragma mark - SessionWrapperDelegate

-(void) didFinishReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{

    if (error) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    
    File* newFile = [[File alloc] init];
    newFile.name =resourceName;
    newFile.sender = peerID.displayName;
    newFile.dateCreated = [NSDate date];
    newFile.url = localURL;
    
    [_fileSystem.sharedDocs addObject:newFile];
    //reload uicollection view
    [_collectionOfFiles reloadData];
}

-(void) didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID{
    
}

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID
               invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
}

/*** IMPLEMENT DELEGATE METHODS FROM EACH WRAPPER'S PROTOCOL HERE ***/

- (void)viewDidLoad {

    [super viewDidLoad];
    _privateOrShared = SHARED; //start us off in the shared directory
    //Init document directory of file system
    _fileSystem = [[FileSystem alloc] init];
    _selectedFiles = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _fileSystem.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    [_collectionOfFiles setDelegate:self];
    [_collectionOfFiles setDataSource:self];
    
    //set borders on buttons
    [[_selectDirectoryModePrivate layer] setBorderWidth:0.5f];
    [[_selectDirectoryModePrivate layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectDirectoryModeShared layer] setBorderWidth:0.5f];
    [[_selectDirectoryModeShared layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectSendButton layer] setBorderWidth:0.5f];
    [[_selectSendButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    //Init session, adversiter, and browser wrapper
    _sessionWrapper = [[SessionWrapper alloc] initSessionWithName:@"yvan"];
    _advertiserWrapper = [[AdvertiserWrapper alloc] startAdvertising:_sessionWrapper.myPeerID];
    _browserWrapper = [[BrowserWrapper alloc] startBrowsing:_sessionWrapper.myPeerID];
    
    //DO NOT USE registerClass when we have made a ptototype cell on the storyboard.
    //[_collectionOfFiles registerClass:[FileCollectionViewCell class] forCellWithReuseIdentifier:@"fileOrFolder"];
    
    [_collectionOfFiles reloadData];
    //Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
