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

/* - didn't use NSRange bec. it's non obvious - */
-(UIImageView *) assignIconForFileType:(NSString *) filename withBool:(BOOL)selected{
    
    NSInteger finalDot = 0;
    NSString *fileExtension = @"";
    
    for (NSInteger index=0; index<filename.length;index++){
        if([filename characterAtIndex:index] == '.'){finalDot = index;}
        if(index == filename.length-1){fileExtension = [filename substringFromIndex:finalDot+1];}
        //if(finalDot == 0){fileExtension = @"directory";} //uncomment in future when we allow user to make directories
    }

    UIImageView *iconViewForCell;
    UIImage *image;
    if(selected){
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-sel.png", fileExtension]];
        
    }else{
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", fileExtension]];
    }
    iconViewForCell = [[UIImageView alloc] initWithImage:image];
    return iconViewForCell;
}

#pragma mark - IBActions

-(IBAction) clickedSelectSendButton:(id)sender{
    
    if(_privateOrShared == SHARED){//we are in shared folder
        
        if(_buttonState == 0){
            [_selectSendButton setTitle:@"Move to Private" forState:UIControlStateNormal];
            _buttonState = 1;
            _selectEnabled = YES;
            _collectionOfFiles.allowsMultipleSelection = YES;
        }else{
            //If we're in the shared folder we just move the docs to the private directory which is our documents folder
            [_fileSystem saveFilesToDocumentsDir:_selectedFiles];
            [_selectedFiles removeAllObjects];
            [_selectSendButton setTitle:@"Sent! Select More files..." forState:UIControlStateNormal];
            _buttonState = 0;
            _selectEnabled = NO;
        }
    }else{//we are IN the private folder
        
        if(_buttonState == 0){
            [_selectSendButton setTitle:@"Move to Shared" forState:UIControlStateNormal];
            _buttonState = 1;
            _selectEnabled = YES;
            _collectionOfFiles.allowsMultipleSelection = YES;
        }else{
            //if we're in the pricate folder we don't move our documents anaywhere we put them
            //in our shared docs array, and then we "send" them, which will put them in our
            //recipients /tmp folder on their phone
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
        
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:135.0/255.0
                                                                 green:9.0/255.0
                                                                 blue:22.0/255.0
                                                                 alpha:1.0]];
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:214.0/255.0
                                                                  green:9.0/255.0
                                                                  blue:22.0/255.0
                                                                  alpha:1.0]];
        _buttonState = 0;
        _selectEnabled = NO;
        _privateOrShared = SHARED;
        [_collectionOfFiles reloadData];
        [_selectedFiles removeAllObjects];
        NSLog(@"switch to shared");
    }
    if(sender == _selectDirectoryModePrivate){
        
        [_selectSendButton setTitle:@"Select Files" forState:UIControlStateNormal];
        [_selectDirectoryModePrivate setTitle:@"Private" forState:UIControlStateNormal];
        
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:135.0/255.0
                                                                  green:9.0/255.0
                                                                  blue:22.0/255.0
                                                                  alpha:1.0]];
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:214.0/255.0
                                                                 green:9.0/255.0
                                                                 blue:22.0/255.0
                                                                 alpha:1.0]];
        _buttonState = 0;
        _selectEnabled = NO;
        _privateOrShared = PRIVATE;
        [_collectionOfFiles reloadData];
        [_selectedFiles removeAllObjects];
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
    
    FileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder"
                                                   forIndexPath:indexPath];
    
    //set the appropriate seleted iamge (red in-filled image) for a selected cell
    //set the appropriate non-selected image (non red filled in) for non-selected cell
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

/* - -(UICollectionReusableView *)co2llectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 } - */

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_selectEnabled){
        _selectedFile = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs objectAtIndex:indexPath.row]:[_fileSystem.sharedDocs objectAtIndex:indexPath.row];
        [_selectedFiles addObject:_selectedFile];
    }else{
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectEnabled) {
        _selectedFile = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs objectAtIndex:indexPath.row]:[_fileSystem.sharedDocs objectAtIndex:indexPath.row];
        [_selectedFiles removeObject:_selectedFile];
    }
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
    
    //create a new file object for the received resource
    File* newFile = [[File alloc] init];
    newFile.name =resourceName;
    newFile.sender = peerID.displayName;
    newFile.dateCreated = [NSDate date];
    newFile.url = localURL;

    [_fileSystem.sharedDocs addObject:newFile]; //add the resource to sharedDocs once it's received.
    [_collectionOfFiles reloadData];            //reload our collectionview with new file reps.
}

-(void) didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID{
    
    [_browserWrapper.autobrowser invitePeer:foreignPeerID toSession:_sessionWrapper.session withContext:nil timeout:5.0];
}

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID
               invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    invitationHandler(YES, _sessionWrapper.session);
    //took out a call to stopAdvertisingPeer here
}

#pragma mark - viewDidLoad and didReceiveMemoryWarning 

/* - IMPLEMENT DELEGATE METHODS FROM EACH WRAPPER'S PROTOCOL HERE - */
- (void)viewDidLoad {

    [super viewDidLoad];
    _privateOrShared = SHARED;                      // start us off in the shared directory
    _fileSystem = [[FileSystem alloc] init];        // create the filesystem and other objs
    _selectedFiles = [[NSMutableArray alloc] init]; // we used to know which files to  move
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _fileSystem.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    [_collectionOfFiles setDelegate:self];
    [_collectionOfFiles setDataSource:self];
    
    //set borders on buttons
    [[_selectSendButton layer] setBorderWidth:0.5f];
    [[_selectDirectoryModeShared layer] setBorderWidth:0.5f];
    [[_selectDirectoryModePrivate layer] setBorderWidth:0.5f];
    [[_selectSendButton layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectDirectoryModeShared layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectDirectoryModePrivate layer] setBorderColor:[UIColor blackColor].CGColor];

    //Init session, advertiser, and browser wrapper in that order
    _sessionWrapper = [[SessionWrapper alloc] initSessionWithName:@"yvan"];
    _advertiserWrapper = [[AdvertiserWrapper alloc] startAdvertising:_sessionWrapper.myPeerID];
    _browserWrapper = [[BrowserWrapper alloc] startBrowsing:_sessionWrapper.myPeerID];
    
    //DO NOT USE registerClass when we have made a ptototype cell on the storyboard.
    //[_collectionOfFiles registerClass:[FileCollectionViewCell class] forCellWithReuseIdentifier:@"fileOrFolder"];
    
    [_collectionOfFiles reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
