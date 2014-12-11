//
//  FileSystem.m
//  malamute
//
//  Created by Quique Lores on 11/11/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "FileSystem.h"
#import "File.h"

@implementation FileSystem

#pragma mark - Setup and Whole FileSystem Methods

/* - creates the file system - */
-(id) init{
    self = [super init];
    _sharedDocs = [[NSMutableArray alloc] init];
    _privateDocs = [[NSMutableArray alloc] init];
    _documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    if([self fileSystemExists]){
        [self populateArraysWithFileSystem];
    }
    
    // COMMENT THE NEXT TWO LINES METHOD OUT OF PRODUCTION VERSION
    //[self makeDummyFiles];
    //[self saveFileSystemToJSON];
    
    return self;
}

/* - tests to see if a path is valid - */
-(BOOL) isValidPath:(NSString*) path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

/* - prints all the files in privatedocs then shareddocs - */
-(void) printAllFiles{
    for(int i = 0; i < [_privateDocs count]; i++){
        NSLog(@"Private Doc %i:%@",i, _privateDocs[i]);
    }
    for(int i = 0; i < [_sharedDocs count]; i++){
        NSLog(@"Shared Doc %i:%@",i, _sharedDocs[i]);
    }
}

#pragma mark - File Manipulation Methods

/* - different from deleteAllDocumentsFromSandbox above because
   - it finds paths for garbage that isn't referenced 
   - anymore and gets rid of it the method above 
   - deletes ONLY referenced content.
   - */
-(void) forceDeleteAllItemsInDocuments{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:_documentsDirectory error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [_documentsDirectory stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                NSLog(@"%s DELETE ALL ITEMS IN DOCS ERROR: %@", __PRETTY_FUNCTION__, error);
            }
        }
    } else {
        NSLog(@"%s COULD NOT DELETE ALL ITEMS FROM: %@", __PRETTY_FUNCTION__, directoryContents);
    }
}
/* Saves a bunch of Files to the Documents directory, updating the Files' URLs */
-(void) saveFilesToDocumentsDir:(NSArray*) files {

    for(int i = 0; i < [files count]; i++){

        File* fileToSave = (File*)[files objectAtIndex:i];
        [self saveFileToDocumentsDir:fileToSave];
    }
}
/* Saves a single File to the Documents directory, updating the File's URL */
-(void) saveFileToDocumentsDir:(File*)file{

    // - move file from file's path to documents folder path, update file - //
    // - add to private documents array - //
    NSString *destinationPath = [_documentsDirectory stringByAppendingPathComponent:file.name];
    int suffix = 1;
    while([self isValidPath:destinationPath]){

        //prompt user to rename the file
        destinationPath = [_documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%i%@", suffix, file.name]];
        suffix++;
    }
    NSError *errorCopy;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    [fileManager copyItemAtURL:file.url toURL:destinationURL error:&errorCopy];
    if (errorCopy) {NSLog(@"Error Copying the file %@", errorCopy);}
    file.url = destinationURL;
    [_privateDocs addObject:file];
}

-(File*) createNewFile:(NSString *) fileName withURL:(NSURL *) url inDirectory:(NSMutableArray *) arrayName{
    
    File* newFile = [[File alloc] initWithName:fileName andURL:url andDate:[NSDate date] andDirectoryFlag:0];
    [arrayName addObject:newFile];
    return newFile;
}

/* - Delete a bunch of files from the sandbox, private and shared arrays -*/
-(void) deleteFilesFromApp:(NSArray*)files{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *deleteError;

    
    for(int i = 0 ; i < [files count] ; i++){
        File* fileToDelete = (File*)[files objectAtIndex:i];
        [_privateDocs removeObjectIdenticalTo:fileToDelete];
        [_sharedDocs removeObjectIdenticalTo:fileToDelete];
        
        NSString *filePath = [_documentsDirectory stringByAppendingPathComponent:fileToDelete.name];
        [fileManager removeItemAtPath:filePath error:&deleteError];
        if(deleteError){
            NSLog(@"%s %@", __PRETTY_FUNCTION__, [deleteError description]);
        }
    }
}


/* - code stolen from 'assignIconForFileType' in ViewController.h, found myself using the code a lot
   - NOTE: this function will totally break
   - on files with more than one extension
   - it needs to be updated for that.
   - */
-(NSString *) getFileExtension:(NSString *)filename{
    
    //code stolen from
    NSInteger finalDot = 0;
    NSString *fileExtension = @"";
    
    for (NSInteger index=0; index<filename.length;index++){
        if([filename characterAtIndex:index] == '.'){finalDot = index;}
        if(index == filename.length-1){fileExtension = [filename substringFromIndex:finalDot+1];}
        //if(finalDot == 0){fileExtension = @"directory";} //uncomment in future when we allow user to make directories
    }
    return fileExtension;
}

#pragma mark - Filsystem State Methods

/* checks if we have a backup of the file system */
-(BOOL) fileSystemExists{
    NSString *fileSystemPath = [_documentsDirectory stringByAppendingPathComponent:@"filesystem.json"];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:fileSystemPath];
}

/* - reads the filesystem.json file and populated our sharedDocs
   - and privateDocs with the app's filesystem on app load
   - */
-(void) populateArraysWithFileSystem{
    
    NSError* error;
    NSInteger iteration = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString *filePath = [_documentsDirectory stringByAppendingPathComponent:@"filesystem.json"];
    NSData* filesystemdata = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
    
    for(NSString* index in JSONDict){ // - only iterates throug private and shared now, but can scale later - //
        if(![index isEqual:@"timestamp"]){
            
            NSDictionary* fileGroup = [JSONDict objectForKey:index];
            
            for(NSString* fileName in fileGroup){
                NSDictionary* individualFile = [fileGroup objectForKey:fileName];
                NSString* name = [individualFile objectForKey:@"name"];
                NSURL* url = [[NSURL alloc]initWithString:[individualFile objectForKey:@"url"]];
                NSDate* created = [formatter dateFromString:[individualFile objectForKey:@"created"]];
                BOOL isDirectory = [individualFile objectForKey:@"isDirectory"];
                File* file = [[File alloc] initWithName:name andURL:url andDate:created andDirectoryFlag:isDirectory];
                // - in the future well need and object that stores each potential diretory as it's own key - //
                // - here well jsut say that on the first iteration well do private and second shared diretories - //
                if(iteration == 1){
                    [_sharedDocs addObject:file];
                }else{
                    [_privateDocs addObject:file];
                }
            }
            iteration++;
        }
    }
}

/* - called everytime we exit the app or everytime the app crashes
   - we will use it to populate the filesystem again on app load
   - */
-(void) saveFileSystemToJSON{
    
    // - atomically write to filesystem.json to wipe the file. - //
    NSError *error;
    NSString* wipeFileSystem = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString *filePath = [_documentsDirectory stringByAppendingPathComponent:@"filesystem.json"];
    [wipeFileSystem writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];//wipes the file system
    
    NSMutableDictionary *theFileSystem = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *privateDocs = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sharedDocs = [[NSMutableDictionary alloc] init];
    // - non atomically write to filesystem to keep tacking on json objects - //
    for(File* file in _privateDocs){
        // - isDirectory = 0 because we're not supporting direcotry creation yet. - //
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.name,@"name", [file.url absoluteString],@"url",[formatter stringFromDate:file.dateCreated],@"created",@"0",@"isDirectory", nil];
        [privateDocs setValue:fileDict forKey:file.name];
    }
    [theFileSystem setValue:privateDocs forKey:@"_privateDocs"]; //load in the privateDocs
    
    for(File* file in _sharedDocs){
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.name,@"name", [file.url absoluteString],@"url",[formatter stringFromDate:file.dateCreated],@"created",@"0",@"isDirectory", nil];
        [sharedDocs setValue:fileDict forKey:file.name];
    }
    [theFileSystem setValue:sharedDocs forKey:@"_sharedDocs"]; // - load in the sharedDocs - //
    [theFileSystem setValue:[formatter stringFromDate:[NSDate date]] forKey:@"timestamp"];// - put timestamp in our file. - //
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:theFileSystem options:0 error:nil];
    [JSONdata writeToFile:filePath atomically:YES];
}

#pragma mark - moveFiles and createNewDir future use file manipulation

/* - method will be useful in the future when we want to supprot diretory manipulation/creation
   - and want to move stuff between arbitrary directories.
   - */
-(BOOL)moveFiles:(NSMutableArray*)selectedFiles from:(NSMutableArray*)firstDirectory to:(NSMutableArray*)secondDirectory withInfo:(BOOL)privateOrShared{

    // - Get documents directory - //
    NSArray* directories = [[NSFileManager defaultManager]
                            URLsForDirectory:NSDocumentDirectory
                            inDomains:NSUserDomainMask];
    
    if([directories count] > 0){
        
        NSURL* appSupportDir = (NSURL*)[directories objectAtIndex:0];
        NSString* privateSharedDirectoryExten;
        if(privateOrShared){privateSharedDirectoryExten = @"private";}   // - later on changed to the name created by user - //
        else{privateSharedDirectoryExten = @"shared";}                   // - later on changed to the name created by user - //
        
        // - Perform the copy asynchronously, might want to get rid of this asynchonaity - //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError* error;
            NSFileManager* fm = [NSFileManager defaultManager];
            
            for(File* file in selectedFiles){
                
                [secondDirectory addObject:file];   // - put each file in the new directory array - //
                [firstDirectory removeObject:file]; // - remove each file from the original directory array -//
                NSURL* copyingFromDirectory = [[appSupportDir URLByAppendingPathComponent:privateSharedDirectoryExten]
                                                        URLByAppendingPathComponent: file.name];
                NSURL* copyingToDirectory = [copyingFromDirectory  URLByAppendingPathExtension:[self getFileExtension:file.name]];
                
                // - MOVE TO THE NEW DIRECTORY (does a copy and deletes the old one) - //
                if (![fm moveItemAtURL:copyingFromDirectory  toURL:copyingToDirectory error:&error]) {
                    
                   NSLog(@"%s MOVE ITEM ERROR: %@", __PRETTY_FUNCTION__, error);
                }
            }
        });
    }
    
    for(File* file in selectedFiles){
        
        NSURL* appSupportDir = (NSURL*)[directories objectAtIndex:0];
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSURL* pathToCheck = [[appSupportDir URLByAppendingPathComponent:appBundleID]
                                             URLByAppendingPathComponent: file.name];
        //all files sucessfully path transferred is never triggers.
        if(![self isValidPath:[pathToCheck absoluteString]]){return NO;}
    }
    return YES;
}

/* - creates a new directory in the documents folder of our app,
   - useful in the future when directory support added
   - just call when user tries to make a directory
   - */
-(BOOL) createNewDir:(NSString*) dirname{
    
    //setup
    NSError* error;
    NSURL* urlForNew = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* documents = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    //for each
    
    if([documents count] > 0){
        urlForNew = [[documents objectAtIndex:0] URLByAppendingPathComponent:dirname];
        if (![self isValidPath:[urlForNew absoluteString]] && ![fm createDirectoryAtURL:urlForNew withIntermediateDirectories:YES attributes:nil error:&error]){
            return NO;
        }
    }
    return YES;
}

/* - makes a set of dummy files for us to test useability - */
-(void) makeDummyFiles{
    
    NSString *private = _documentsDirectory;
    //NSString *shared = [_documentsDirectory stringByAppendingString:@"tmp/"];
    NSString *testfile1 = [private stringByAppendingPathComponent:@"testfile1.txt"];
    
    File *testfileobj1 = [[File alloc] initWithName:@"testfile1.txt"
                                       andURL:[NSURL URLWithString:testfile1]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_privateDocs addObject:testfileobj1];
    NSString *testfile2 = [private stringByAppendingPathComponent:@"testfile2.txt"];
    File *testfileobj2 = [[File alloc] initWithName:@"testfile2.txt"
                                       andURL:[NSURL URLWithString:testfile2]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_privateDocs addObject:testfileobj2];
    NSString *testfile3 = [private stringByAppendingPathComponent:@"testfile3.txt"];
    File *testfileobj3 = [[File alloc] initWithName:@"testfile3.txt"
                                       andURL:[NSURL URLWithString:testfile3]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_privateDocs addObject:testfileobj3];
    NSString *testfile4 = [private stringByAppendingPathComponent:@"testfile4.txt"];
    File *testfileobj4 = [[File alloc] initWithName:@"testfile4.txt"
                                       andURL:[NSURL URLWithString:testfile4]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_privateDocs addObject:testfileobj4];
    
    NSError *writeError = nil;
    NSString *string = @"text-test";
    [string writeToFile:testfile1 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    [string writeToFile:testfile2 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    [string writeToFile:testfile3 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    [string writeToFile:testfile4 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
}

@end
