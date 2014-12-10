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

/* - didn't use NSRange bec. it's non obvious 
   - NOTE: this function will totally break
   - on files with more than one extension
   - it needs to be updated for that.
   - */
-(UIImageView *) assignIconForFileType:(NSString *) filename isSelected:(BOOL)selected isAddFileIcon:(BOOL)isAddFileIcon{
    
    NSString *fileExtension = [_fileSystem getFileExtension:filename];

    UIImageView *iconViewForCell;
    UIImage *image;
    fileExtension = [fileExtension lowercaseString];
    if(selected){
        if(isAddFileIcon){image = [UIImage imageNamed:@"addfile-sel.png"];}
        else{image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-sel.png", fileExtension]];}
    }else{
        if(isAddFileIcon){image = [UIImage imageNamed:@"addfile.png"];}
        else{image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", fileExtension]];}
    }
    iconViewForCell = [[UIImageView alloc] initWithImage:image];
    return iconViewForCell;
}

#pragma mark - IBActions

/* - select Send buttons include the blanket button and the move button 
   - the delete button has it's own method called clickedDeleteButton
   - */
-(IBAction) clickedSelectSendButton:(id)sender{
    
    if(_privateOrShared == SHARED){// - we are in shared folder - //
        
        if(sender == _selectBlanketButton){
            [_selectSendButton setTitle:@"Move to Private" forState:UIControlStateNormal];
            _selectEnabled = YES;
            [_selectSendButton setHidden:NO];
            [_selectSendButton setEnabled:YES];
            [_selectDeleteButton setHidden:NO];
            [_selectDeleteButton setEnabled:YES];
            [_selectBlanketButton setHidden:YES];
            [_selectBlanketButton setEnabled:NO];
            _collectionOfFiles.allowsMultipleSelection = YES;
        }else{
            // - theoretically this next part transfers files into my photo library as soon as i bring them
            // - locally into my 'private' directory, ik it's inefficient, deal with it or fix it - //
            // - there may be naming conflicts here - //
            for(int i = 0; i < [_selectedFiles count]; i++){
                NSString *fileExtension = [_fileSystem getFileExtension:((File *)[_selectedFiles objectAtIndex:i]).name];
                fileExtension = [fileExtension lowercaseString];
                if ([fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpg"]) {
                    NSURL *imageURL = ((File *)[_selectedFiles objectAtIndex:i]).url;
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self savePictureToPhotoLibrary:image];
                }
            }
            // - If we're in the shared folder we just move the docs to the private directory which is our - //
            // - documents folder - //
            [_fileSystem saveFilesToDocumentsDir:_selectedFiles];
            [_selectedFiles removeAllObjects];
            [_selectSendButton setHidden:YES];
            [_selectSendButton setEnabled:NO];
            [_selectDeleteButton setHidden:YES];
            [_selectDeleteButton setEnabled:NO];
            [_selectBlanketButton setHidden:NO];
            [_selectBlanketButton setEnabled:YES];
            _selectEnabled = NO;
            // - deselects all the items we just performed an operation on nice n' fancy - //
            for (int i=0; i < [_fileSystem.sharedDocs count]; i++) {
                [_collectionOfFiles deselectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
    }else{// - we are IN the private folder - //
        
        if(sender == _selectBlanketButton){
            [_selectSendButton setTitle:@"Move to Shared" forState:UIControlStateNormal];
            _selectEnabled = YES;
            [_selectSendButton setHidden:NO];
            [_selectSendButton setEnabled:YES];
            [_selectDeleteButton setHidden:NO];
            [_selectDeleteButton setEnabled:YES];
            [_selectBlanketButton setHidden:YES];
            [_selectBlanketButton setEnabled:NO];
            _collectionOfFiles.allowsMultipleSelection = YES;
        }else{
            // - if we're in the pricate folder we don't move our documents anaywhere we put them - //
            // - in our shared docs array, and then we "send" them, which will put them in our - //
            // - recipients /tmp folder on their phone - //
            [_sessionWrapper sendFiles:_selectedFiles toPeers:_sessionWrapper.session.connectedPeers];
            [_fileSystem.sharedDocs addObjectsFromArray:_selectedFiles];
            //[_fileSystem.filesIHaveShared addObjectsFromArray:_selectedFiles];
            [_selectedFiles removeAllObjects];
            [_selectSendButton setHidden:YES];
            [_selectSendButton setEnabled:NO];
            [_selectDeleteButton setHidden:YES];
            [_selectDeleteButton setEnabled:NO];
            [_selectBlanketButton setHidden:NO];
            [_selectBlanketButton setEnabled:YES];
            _selectEnabled = NO;
            // - deselects all the items we just performed an operation on nice n' fancy - //
            for (int i=0; i < [_fileSystem.privateDocs count]; i++) {
                [_collectionOfFiles deselectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
    }
}

-(IBAction) clickedSelectDirectoryButton:(id)sender{
    
    if(sender == _selectDirectoryModeShared){ // - selectDirectoryMode Clicked - //
        
        [_selectDirectoryModeShared setTitle:@"Shared" forState:UIControlStateNormal];
        [_selectSendButton setTitle:@"Move to Private" forState:UIControlStateNormal]; // not necessary but improves the look of the title change.
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:135.0/255.0
                                                                 green:9.0/255.0
                                                                 blue:22.0/255.0
                                                                 alpha:1.0]];
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:214.0/255.0
                                                                  green:9.0/255.0
                                                                  blue:22.0/255.0
                                                                  alpha:1.0]];
        _selectEnabled = NO;
        _privateOrShared = SHARED;
        [_collectionOfFiles reloadData];
        [_selectedFiles removeAllObjects];
        [_selectSendButton setHidden:YES];
        [_selectSendButton setEnabled:NO];
        [_selectDeleteButton setHidden:YES];
        [_selectDeleteButton setEnabled:NO];
        [_selectBlanketButton setHidden:NO];
        [_selectBlanketButton setEnabled:YES];
    }
    if(sender == _selectDirectoryModePrivate){
        
        // - redundant but improves the look of transition on title change for this button. - //
        [_selectDirectoryModePrivate setTitle:@"Private" forState:UIControlStateNormal];
        [_selectSendButton setTitle:@"Move to Shared" forState:UIControlStateNormal];
        
        [_selectDirectoryModePrivate setBackgroundColor: [UIColor colorWithRed:135.0/255.0
                                                                  green:9.0/255.0
                                                                  blue:22.0/255.0
                                                                  alpha:1.0]];
        [_selectDirectoryModeShared setBackgroundColor: [UIColor colorWithRed:214.0/255.0
                                                                 green:9.0/255.0
                                                                 blue:22.0/255.0
                                                                 alpha:1.0]];
        _selectEnabled = NO;
        _privateOrShared = PRIVATE;
        [_collectionOfFiles reloadData];
        [_selectedFiles removeAllObjects];
        [_selectSendButton setHidden:YES];
        [_selectSendButton setEnabled:NO];
        [_selectDeleteButton setHidden:YES];
        [_selectDeleteButton setEnabled:NO];
        [_selectBlanketButton setHidden:NO];
        [_selectBlanketButton setEnabled:YES];
    }
}

-(IBAction) clickedDeleteButton:(id)sender{
    
    [_fileSystem deleteFilesFromApp:_selectedFiles];
    
    [_selectedFiles removeAllObjects];
    [_collectionOfFiles reloadData];
    _selectEnabled = NO;
    
    [_selectSendButton setHidden:YES];
    [_selectSendButton setEnabled:NO];
    [_selectDeleteButton setHidden:YES];
    [_selectDeleteButton setEnabled:NO];
    [_selectBlanketButton setHidden:NO];
    [_selectBlanketButton setEnabled:YES];
    
    [_fileSystem saveFileSystemToJSON]; 
}

#pragma mark - Special Effects Functions

-(void)connectionStatusLabelFade{
    
    _connectionStatusLabel.text = @"";
}

#pragma mark - Photo Library Utility

-(void) summonPhotoLibrary {
    
    UIImagePickerController* libraryPicker = [[UIImagePickerController alloc] init];
    [libraryPicker setDelegate:self];
    libraryPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;// - or UIImagePickerControllerSourceTypePhotoLibrary - //
    [self presentViewController:libraryPicker animated:YES completion:^(void){}];
}

/* - Wrapper just in case we want to add pre save functionality later. - */
-(void) savePictureToPhotoLibrary:(UIImage *)image {
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

#pragma mark - UIImagePickerControllerDelegate

-(void) imagePickerController:(UIImagePickerController *)libraryPicker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString* fileInfo = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString]; // - UIImagePickerControllerMediaType not used - //
    NSString *uniqueFileCode = [fileInfo substringWithRange:NSMakeRange(36, 36)];
    NSString *fileExtension = [fileInfo substringWithRange:NSMakeRange(77,3)];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString  *path = [_fileSystem.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",uniqueFileCode,fileExtension]];

    // - as far as I know these are the only two image representations supported from the iOS photo library - //
    if([fileExtension isEqualToString:@"JPG"]){
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES];

    }else if([fileExtension isEqualToString:@"PNG"]){
     
        [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    }
    
    if(_privateOrShared == PRIVATE){
        [_fileSystem createNewFile:[NSString stringWithFormat:@"%@.%@",uniqueFileCode,fileExtension]
                           withURL:[NSURL URLWithString:[_fileSystem.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",uniqueFileCode,fileExtension]]]
                       inDirectory:_fileSystem.privateDocs];
    }
    else{
        File* newfile = [_fileSystem createNewFile:[NSString stringWithFormat:@"%@.%@",uniqueFileCode,fileExtension]
                           withURL:[NSURL URLWithString:[_fileSystem.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",uniqueFileCode,fileExtension]]]
                       inDirectory:_fileSystem.sharedDocs];
        NSArray* fileArr = [[NSArray alloc] initWithObjects:newfile, nil];
        
        //[_fileSystem.filesIHaveShared addObject:newfile];
        [_sessionWrapper sendFiles:fileArr toPeers:_sessionWrapper.session.connectedPeers];
    }
    
    [self dismissViewControllerAnimated:libraryPicker completion:^(void){}];
    [_fileSystem saveFileSystemToJSON];
    
    // - for some reason we need to do this in dispatch, thesis is that somehow IO operations, and reloadData isn't working properly during these, putting it inside dispatch makes it thread safe.

    dispatch_async(dispatch_get_main_queue(), ^{[_collectionOfFiles reloadData];});
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)libraryPicker{
    [self dismissViewControllerAnimated:libraryPicker completion:^(void){}];
    [_collectionOfFiles reloadData];
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // - +1 is for the last cell which acts as a button to load in pictures, but also make new files. - //
    return _privateOrShared == PRIVATE ? [_fileSystem.privateDocs count]+1:[_fileSystem.sharedDocs count]+1;
}

-(FileCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder"
                                                                             forIndexPath:indexPath];
    
    // - set the appropriate seleted iamge (red in-filled image) for a selected cell - //
    // - set the appropriate non-selected image (non red filled in) for non-selected cell - //
    if(_privateOrShared == PRIVATE){
        if(indexPath.row == [_fileSystem.privateDocs count]){
            FileCollectionViewCell *addFileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addFile"
                forIndexPath:indexPath];
            addFileCell.backgroundView = [self assignIconForFileType:nil isSelected:0 isAddFileIcon:1];
            //addFileCell.selectedBackgroundView = [self assignIconForFileType:nil isSelected:1 isAddFileIcon:1];
            return addFileCell;
        }
        cell.backgroundView = [self assignIconForFileType:((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name isSelected:0 isAddFileIcon:0];
        cell.selectedBackgroundView = [self assignIconForFileType:((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name isSelected:1 isAddFileIcon:0];
        cell.cellLabel.text = ((File *)[_fileSystem.privateDocs objectAtIndex:indexPath.row]).name;
    }else{
        if(indexPath.row == [_fileSystem.sharedDocs count]){
            FileCollectionViewCell *addFileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addFile"
                forIndexPath:indexPath];
            addFileCell.backgroundView = [self assignIconForFileType:nil isSelected:0 isAddFileIcon:1];
            //addFileCell.selectedBackgroundView = [self assignIconForFileType:nil isSelected:1 isAddFileIcon:1];
            return addFileCell;
        }
        cell.backgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name isSelected:0 isAddFileIcon:0];
        cell.selectedBackgroundView = [self assignIconForFileType:((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name isSelected:1 isAddFileIcon:0];
        cell.cellLabel.text = ((File *)[_fileSystem.sharedDocs objectAtIndex:indexPath.row]).name;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger fileCount = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs count]:[_fileSystem.sharedDocs count];
    
    if(indexPath.row == fileCount){// - user clicked on Add File - //
        [self summonPhotoLibrary];
    }else{ // - User clicked on an actual file icon - //
        if(_selectEnabled){
            _selectedFile = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs objectAtIndex:indexPath.row]:[_fileSystem.sharedDocs objectAtIndex:indexPath.row];
            [_selectedFiles addObject:_selectedFile];
        }else{
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger fileCount = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs count]:[_fileSystem.sharedDocs count];

    if(indexPath.row == fileCount){// - user clicked on Add File - //
        [self summonPhotoLibrary];
    }else{ // - User clicked on an actual file icon - //
        if (_selectEnabled) {
            _selectedFile = _privateOrShared == PRIVATE ? [_fileSystem.privateDocs objectAtIndex:indexPath.row]:[_fileSystem.sharedDocs objectAtIndex:indexPath.row];
            [_selectedFiles removeObject:_selectedFile];
        }
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
   
    NSLog(@"%s FINISHED RECIVEING RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, resourceName, peerID);

    if (error) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    
    // - create a new file object for the received resource - //
    File* newFile = [[File alloc] init];
    newFile.name =resourceName;
    newFile.sender = peerID.displayName;
    newFile.dateCreated = [NSDate date];
    newFile.url = localURL;
    newFile.isDirectory = false;
    [_fileSystem.sharedDocs addObject:newFile];// - add the resource to sharedDocs once it's received. - //
    [_collectionOfFiles reloadData]; // - reload our collectionview with new file reps. - //
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [_collectionOfFiles reloadData];
                       
                   });
}

-(void) didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
    NSLog(@"%s STARTED RECIVEING RESOURCE: %@, FROM PEER: %@", __PRETTY_FUNCTION__, resourceName, peerID);
}

#pragma mark - BrowserWrapperDelegate

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID{
    
     NSLog(@"%s INVITED FOREIGN PEER: %@", __PRETTY_FUNCTION__, foreignPeerID);
    // - This is intended to send files in each session participant's shared directory
    // - to new users joining the session, uncommented this would work as is, but
    // - we felt like there were other complications we didn't really have time
    // - to deal with, spotty connection will trigger massive file sending and we
    // - don't have a perfect solution for this as is.
    //[_sessionWrapper sendFiles:_fileSystem.filesIHaveShared toPeers:[[NSArray alloc] initWithObjects:foreignPeerID, nil]];
    _connectionStatusLabel.text = [NSString stringWithFormat:@"Invited: %@", foreignPeerID.displayName];
    [_browserWrapper.autobrowser invitePeer:foreignPeerID toSession:_sessionWrapper.session withContext:nil timeout:5.0];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectionStatusLabelFade) userInfo:nil repeats:NO];
}

-(void) alertToLostPeer:(MCPeerID *)lostForeignPeerID{
    
    _connectionStatusLabel.text = [NSString stringWithFormat:@"Lost Connection to: %@", lostForeignPeerID.displayName];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectionStatusLabelFade) userInfo:nil repeats:NO];
}

#pragma mark - AdvertiserWrapperDelegate

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID
               invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    invitationHandler(YES, _sessionWrapper.session);
    //
    //[_sessionWrapper sendFiles:_fileSystem.filesIHaveShared toPeers:[[NSArray alloc] initWithObjects:foreignPeerID, nil]];
    _connectionStatusLabel.text = [NSString stringWithFormat:@"Connected to: %@", foreignPeerID.displayName];
    NSLog(@"%s INVITATION FROM PEER %@ ACCEPTED", __PRETTY_FUNCTION__, foreignPeerID);
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectionStatusLabelFade) userInfo:nil repeats:NO];
    // - took out a call to stopAdvertisingPeer here - //
}

#pragma mark - viewDidLoad and didReceiveMemoryWarning 

/* - IMPLEMENT DELEGATE METHODS FROM EACH WRAPPER'S PROTOCOL HERE - */
- (void)viewDidLoad {

    [super viewDidLoad];
    _privateOrShared = SHARED;                      // - start us off in the shared directory - //
    _fileSystem = [[FileSystem alloc] init];        // - create the filesystem and other objs - //
    _selectedFiles = [[NSMutableArray alloc] init]; // - we used to know which files to  move - //
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _fileSystem.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
    [_collectionOfFiles setDelegate:self];
    [_collectionOfFiles setDataSource:self];
    
    //set button styling
    [_selectSendButton setHidden:YES];
    [_selectSendButton setEnabled:NO];
    [_selectDeleteButton setHidden:YES];
    [_selectDeleteButton setEnabled:NO];
    [_selectBlanketButton setHidden:NO];
    [_selectBlanketButton setEnabled:YES];
    [[_selectSendButton layer] setBorderWidth:0.5f];
    [[_selectDeleteButton layer] setBorderWidth:0.5f];
    [[_selectBlanketButton layer] setBorderWidth:0.5f];
    [[_selectDirectoryModeShared layer] setBorderWidth:0.5f];
    [[_selectDirectoryModePrivate layer] setBorderWidth:0.5f];
    [[_selectSendButton layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectDeleteButton layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectBlanketButton layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectDirectoryModeShared layer] setBorderColor:[UIColor blackColor].CGColor];
    [[_selectDirectoryModePrivate layer] setBorderColor:[UIColor blackColor].CGColor];

    // - init session, advertiser, and browser wrapper in that order - //
    _sessionWrapper = [[SessionWrapper alloc] initSessionWithName:@"yvancomputer"];
    _advertiserWrapper = [[AdvertiserWrapper alloc] startAdvertising:_sessionWrapper.myPeerID];
    _browserWrapper = [[BrowserWrapper alloc] startBrowsing:_sessionWrapper.myPeerID];
    _sessionWrapper.sessionDelegate = self;
    _advertiserWrapper.advertiserDelegate = self;
    _browserWrapper.browserDelegate = self;
    
    // - DO NOT USE registerClass when we have made a ptototype cell on the storyboard. - //
    //[_collectionOfFiles registerClass:[FileCollectionViewCell class] forCellWithReuseIdentifier:@"fileOrFolder"];
    
    [_collectionOfFiles reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
