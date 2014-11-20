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
    NSLog(@"%@", fileExtension);
    UIImageView *iconViewForCell;
    if(selected){
        iconViewForCell = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-sel.png", fileExtension]]];
    }else{
        iconViewForCell = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", fileExtension]]];
    }
    return iconViewForCell;
}

#pragma mark - IBActions

-(IBAction) clickedSelectSendButton:(id)sender{ //shared
    NSLog(@"blah1");
    if(_privateOrShared){//_privateOrShared folder = 1 for shared, and 0 for private
        NSLog(@"blahshared");
        if(_buttonState == 0){
            [_selectSendButton setTitle:@"Move to Private" forState:UIControlStateNormal];
            _buttonState = 1;
            _selectEnabled = YES;
            _collectionOfFiles.allowsMultipleSelection = YES;
        }
        else{
            [_fileSystem moveFiles:_selectedFiles from:_fileSystem.sharedDocs to:_fileSystem.privateDocs withInfo:_privateOrShared];
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
            [_fileSystem moveFiles:_selectedFiles from:_fileSystem.privateDocs to:_fileSystem.sharedDocs withInfo:_privateOrShared];
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
        _privateOrShared = 1;
        _buttonState = 0;
        _selectEnabled = NO;
        [_collectionOfFiles reloadData];
        NSLog(@"switch to shared");
    }
    if(sender == _selectDirectoryModePrivate){
        [_selectSendButton setTitle:@"Select Files" forState:UIControlStateNormal];
        
        [_selectDirectoryModePrivate setTitle:@"Private" forState:UIControlStateNormal];
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:135.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0]];
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:214.0/255.0 green:9.0/255.0 blue:22.0/255.0 alpha:1.0]];
        _privateOrShared = 0;
        _buttonState = 0;
        _selectEnabled = NO;
        [_collectionOfFiles reloadData];
        NSLog(@"switch to private");
    }
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _privateOrShared == 0 ? [_fileSystem.privateDocs count]:[_fileSystem.sharedDocs count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder" forIndexPath:indexPath];
    
    //set the appropriate seleted iamge image (red in-filled image)
    if(_privateOrShared == 0){
        cell.backgroundView = [self assignIconForFileType:((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name withBool:0];
        cell.selectedBackgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name withBool:1];
    }else{
        cell.backgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name withBool:0];
        cell.selectedBackgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name withBool:1];
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
        
        File *fileSelected = [[File alloc] init];
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder" forIndexPath:indexPath];
        _selectedFile = _privateOrShared == 0 ? [_fileSystem.privateDocs objectAtIndex:indexPath.row]:[_fileSystem.sharedDocs objectAtIndex:indexPath.row];
        [_selectedFiles addObject:_selectedFile];
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
    fileIconSize.height = 50;
    fileIconSize.width = 50;
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
    
   /* NSString *destinationPath = [_documentsDirectory stringByAppendingPathComponent:resourceName];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *errorCopy;
    
    [fileManager copyItemAtURL:localURL toURL:destinationURL error:&errorCopy];
    if (errorCopy) {
        NSLog(@"Error Copying the file %@", errorCopy);
    }
    
    [_arrFiles removeAllObjects];
    _arrFiles = nil;
    _arrFiles = [[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];*/
    
    //reload files
    //similar to [_tblFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    _privateOrShared = 1; //start us off in the shared directory
    //Init document directory of file system
    _fileSystem = [[FileSystem alloc] init];
    _selectedFiles = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _fileSystem.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    [_collectionOfFiles setDelegate:self];
    [_collectionOfFiles setDataSource:self];
    [_collectionOfFiles reloadData];
    
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
    [_collectionOfFiles registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"fileOrFolder"];
    [_collectionOfFiles reloadData];
    //Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
