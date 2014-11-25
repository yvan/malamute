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
    NSArray* documents = [[NSFileManager defaultManager] URLsForDirectory:
                         NSDocumentDirectory inDomains:NSUserDomainMask];
    _documentsDirectory = [[documents objectAtIndex:0] absoluteString];
    NSError* error;
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"filesystem" ofType:@"json"];
    NSData* filesystemdata = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"Error: %@",error);
    NSLog(@"File Contents: %@",JSONDict);
    [self makeDummyFiles];
    //[self saveFileSystemToJSON];
    [self populateArraysWithFileSystem];
    // YO COMMENT THIS PUNK ASS METHOD OUT OF PRODUCTION VERSION
    return self;
}

/* - tests to see if a path is valid - */
-(BOOL) isValidPath:(NSString*) path{
    return !([[NSFileManager defaultManager] fileExistsAtPath:path]);
}

//prints all the files in privatedocs then shareddocs
-(void) printAllFiles{
    for(int i = 0; i < [_privateDocs count]; i++){
        NSLog(@"Private Doc %i:%@",i, _privateDocs[i]);
    }
    for(int i = 0; i < [_sharedDocs count]; i++){
        NSLog(@"Shared Doc %i:%@",i, _sharedDocs[i]);
    }
}

#pragma mark - File Manipulation Methods

/* - gets all the files in teh documents directory - */
-(NSMutableArray *)getAllDocDirFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSMutableArray *allFiles = (NSMutableArray*) [fileManager contentsOfDirectoryAtPath:_documentsDirectory error:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    return allFiles;
}

/* - deletes...all documents from sandbox? what? - */
-(void) deleteAllDocumentsFromSandbox{
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    for(int i = 0; i <[_privateDocs count]; i++){
        NSURL* docUrl = [((File*)_privateDocs[i]) url];
        [fileManager removeItemAtURL:docUrl error:&error ];
    }
    if(error){
        NSLog(@"ERROR DELETING ALL FILES %@", [error localizedDescription]);
    }
    _privateDocs = [self getAllDocDirFiles];
}

-(void) saveFilesToDocumentsDir:(NSArray*) files {
    for(int i = 0; i < [files count]; i++){
        File* fileToSave = (File*)[files objectAtIndex:i];
        [self saveFileToDocumentsDir:fileToSave];
    }
}

-(void) saveFileToDocumentsDir:(File*)file{
    
    //move file from file's path to documents folder path, update file
    //add to private documents array
    NSString *destinationPath = [_documentsDirectory stringByAppendingPathComponent:file.name];
    int suffix = 1;
    while(![self isValidPath:destinationPath]){
        //prompt user to rename the file
        destinationPath = [_documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%i%@", suffix, file.name]];
        suffix++;
    }
    
    NSError *errorCopy;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    
    [fileManager copyItemAtURL:file.url toURL:destinationURL error:&errorCopy];
    if (errorCopy) {
        NSLog(@"Error Copying the file %@", errorCopy);
    }
    file.url = destinationURL;
    [_privateDocs addObject:file];
}

/* - reads the filesystem.json file and populated our sharedDocs
 - and privateDocs with the app's filesystem on app load
 - */
-(void) populateArraysWithFileSystem{
    
    NSError* error;
    NSInteger iteration = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"filesystem" ofType:@"json"];
    NSData* filesystemdata = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* JSONDict = [NSJSONSerialization JSONObjectWithData:filesystemdata options:0 error:&error];
    
    for(NSString* index in JSONDict){ //only iterates throug private and shared now, but can scale later
        if(![index isEqual:@"timestamp"]){
            
            NSDictionary* fileGroup = [JSONDict objectForKey:index];
            
            for(NSString* fileName in fileGroup){
                NSDictionary* individualFile = [fileGroup objectForKey:fileName];
                NSString* name = [individualFile objectForKey:@"name"];
                NSURL* url = [[NSURL alloc]initWithString:[individualFile objectForKey:@"url"]];
                NSDate* created = [formatter dateFromString:[individualFile objectForKey:@"created"]];
                BOOL isDirectory = [individualFile objectForKey:@"isDirectory"];
                File* file = [[File alloc] initWithName:name andURL:url andDate:created andDirectoryFlag:isDirectory];
                //in the future well need and object that stores each potential diretory as it's own key
                //here well jsut say that on the first iteration well do private and second shared diretories
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
    
    //atomically write to filesystem.json to wipe the file.
    NSError *error;
    NSString* wipeFileSystem = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"filesystem" ofType:@"json"];
    [wipeFileSystem writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];//wipes the file system
    
    NSMutableDictionary *theFileSystem = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *privateDocs = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sharedDocs = [[NSMutableDictionary alloc] init];
    //non atomically write to filesystem to keep tacking on json objects
    for(File* file in _privateDocs){
        //isDirectory = @0 because we're not supporting direcotry creation yet.
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.name,@"name", [file.url absoluteString],@"url",[formatter stringFromDate:file.dateCreated],@"created",@"0",@"isDirectory", nil];
        [privateDocs setValue:fileDict forKey:file.name];
    }
    [theFileSystem setValue:privateDocs forKey:@"_privateDocs"]; //load in the privateDocs
    
    for(File* file in _sharedDocs){
        NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:file.name,@"name", [file.url absoluteString],@"url",[formatter stringFromDate:file.dateCreated],@"created",@"0",@"isDirectory", nil];
        [sharedDocs setValue:fileDict forKey:file.name];
    }
    [theFileSystem setValue:sharedDocs forKey:@"_sharedDocs"]; //load in the sharedDocs
    [theFileSystem setValue:[formatter stringFromDate:[NSDate date]] forKey:@"timestamp"];//put timestamp in our file.
    
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:theFileSystem options:0 error:nil];
    [JSONdata writeToFile:filePath atomically:YES];
}

/* - method will be useful in the future when we want to supprot diretory manipulation/creation
   - and want to move stuff between arbitrary directories.
   - */
-(BOOL)moveFiles:(NSMutableArray*)selectedFiles from:(NSMutableArray*)firstDirectory to:(NSMutableArray*)secondDirectory withInfo:(BOOL)privateOrShared{

    //Get documents directory
    NSArray* directories = [[NSFileManager defaultManager]
                            URLsForDirectory:NSDocumentDirectory
                            inDomains:NSUserDomainMask];
    
    if([directories count] > 0){
        
        NSURL* appSupportDir = (NSURL*)[directories objectAtIndex:0];
        NSString* privateSharedDirectoryExten;
        if(privateOrShared){privateSharedDirectoryExten = @"private";}   //later on changed to the name created by user
        else{privateSharedDirectoryExten = @"shared";}                   //later on changed to the name created by user
        
        // Perform the copy asynchronously.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError* error;
            NSFileManager* fm = [NSFileManager defaultManager];
            
            for(File* file in selectedFiles){
                
                [secondDirectory addObject:file];   //put each file in the new directory array
                [firstDirectory removeObject:file]; //remove each file from the original directory array
                NSURL* copyingFromDirectory = [[appSupportDir URLByAppendingPathComponent:privateSharedDirectoryExten]
                                                        URLByAppendingPathComponent: file.name];
                NSInteger finalDot = 0;
                NSURL* copyingToDirectory;
                NSString *fileExtension = @"";
                
                for (NSInteger index=0; index<file.name.length;index++){
                    if([file.name characterAtIndex:index] == '.'){finalDot = index;}
                    if(index == file.name.length-1){fileExtension = [file.name substringFromIndex:finalDot+1];}
                    /*if(finalDot == 0){ //uncomment in the future if we allow the user to make directories
                        
                        fileExtension = @"directory";
                    }*/
                }
                copyingToDirectory = [copyingFromDirectory  URLByAppendingPathExtension:fileExtension];
                
                //MOVE TO THE NEW DIRECTORY (does a copy and deletes the old one)
                if (![fm moveItemAtURL:copyingFromDirectory  toURL:copyingToDirectory error:&error]) {
                    
                   NSLog(@"%@",error);
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
    
    NSArray* documents = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *private = [[documents objectAtIndex:0] absoluteString];
    NSString *shared = [[[documents objectAtIndex:0] absoluteString] stringByAppendingString:@"tmp/"];
    NSString *testfile1 = [private stringByAppendingPathComponent:@"testfile1.txt"];
    
    File *testfileobj1 = [[File alloc] initWithName:@"testfile1.txt"
                                       andURL:[NSURL URLWithString:testfile1]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_privateDocs addObject:testfileobj1];
    NSString *testfile2 = [private stringByAppendingString:@"testfile2.txt"];
    File *testfileobj2 = [[File alloc] initWithName:@"testfile2.txt"
                                       andURL:[NSURL URLWithString:testfile2]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_privateDocs addObject:testfileobj2];
    NSString *testfile3 = [shared stringByAppendingString:@"testfile3.txt"];
    File *testfileobj3 = [[File alloc] initWithName:@"testfile3.txt"
                                       andURL:[NSURL URLWithString:testfile3]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_sharedDocs addObject:testfileobj3];
    NSString *testfile4 = [shared stringByAppendingString:@"testfile4.txt"];
    File *testfileobj4 = [[File alloc] initWithName:@"testfile4.txt"
                                       andURL:[NSURL URLWithString:testfile4]
                                       andDate:[NSDate date]
                                       andDirectoryFlag:0];
    [_sharedDocs addObject:testfileobj4];
    
    NSError *writeError = nil;
    NSString *string = @"text-test";
    [string writeToFile:testfile1 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    [string writeToFile:testfile2 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    [string writeToFile:testfile3 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    [string writeToFile:testfile4 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
}

@end
