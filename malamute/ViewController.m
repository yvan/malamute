//
//  ViewController.m
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


//-(NSArray *)getAllDocDirFiles;


@end

@implementation ViewController


//didn't use NSRange bec. it's non obvious
-(UIImageView *) assignIconForFileType:(NSString *) filename{
    
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
    UIImageView *iconViewForCell = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", fileExtension]]];
    return iconViewForCell;
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //**Need to determine whether or not we're in Shared Folder or Documents Folder**//
    //so add an entry for privateDocs, for now just do sharedDocs
    return [_fileSystem.sharedDocs count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder" forIndexPath:indexPath];
    
    cell.backgroundView = [self assignIconForFileType:@"sample_file1.txt"];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txt-sel.png"]];
    //instead of just one file here there has to be a method/algorithm that identifies each cell
    
    return cell;
}

/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_selectEnabled){
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fileOrFolder" forIndexPath:indexPath];
        //**Need to determine whether or not we're in Shared Folder or Documents Folder**//
        //so add an entry for privateDocs, for now just do sharedDocs
        _selectedFile = [_fileSystem.sharedDocs objectAtIndex:indexPath.row];
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
        [_selectedFiles addObject:_selectedFile];
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
    
    //Init document directory of file system
    _fileSystem = [[FileSystem alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _fileSystem.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];

    //init session, adversiter, and browser wrapper
    _sessionWrapper = [[SessionWrapper alloc] initSessionWithName:@"yvan"];
    _advertiserWrapper = [[AdvertiserWrapper alloc] startAdvertising:_sessionWrapper.myPeerID];
    _browserWrapper = [[BrowserWrapper alloc] startBrowsing:_sessionWrapper.myPeerID];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
