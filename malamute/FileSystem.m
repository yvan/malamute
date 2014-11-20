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
//creates the file system
-(id) init{
    self = [super init];
    _sharedDocs = [[NSMutableArray alloc] init];
    _privateDocs = [[NSMutableArray alloc] init];
    NSArray* documents = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    _documentsDirectory = [[documents objectAtIndex:0] absoluteString];

    [self createNewDir:@"private"];
    [self createNewDir:@"shared"];
    [self makeDummyFiles]; //comment out in prodution version
    return self;
}

//tests to see if a path is valid
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

//gets all the files in teh documents directory
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

//deletes...all documents from sandbox? what?
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

-(void) saveDocumentsToSandbox:(NSArray*) documents {
    for(int i = 0; i < [documents count]; i++){
        File* fileToSave = (File*)[documents objectAtIndex:i];
        [self saveDocumentToSandbox:fileToSave];
    }
}

-(void) saveDocumentToSandbox:(File*)document{
    
    //move file from file's path to documents folder path, update file
    //add to private documents array
    NSString *destinationPath = [_documentsDirectory stringByAppendingPathComponent:document.name];
    int suffix = 1;
    while(![self isValidPath:destinationPath]){
        //prompt user to rename the file
        destinationPath = [_documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%i%@", suffix, document.name]];
        suffix++;
    }
    
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *errorCopy;
    
    [fileManager copyItemAtURL:document.url toURL:destinationURL error:&errorCopy];
    if (errorCopy) {
        NSLog(@"Error Copying the file %@", errorCopy);
    }
    document.url = destinationURL;
    [_privateDocs addObject:document];
}

-(BOOL)moveFiles:(NSMutableArray*)selectedFiles from:(NSMutableArray*)firstDirectory to:(NSMutableArray*)secondDirectory withInfo:(BOOL)privateOrShared{

    //Get documents directory
    NSArray* directories = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory
inDomains:NSUserDomainMask];
    
    if([directories count] > 0){
        // Build a path to ~/Library/Application Support/<bundle_ID>/Data
        // where <bundleID> is the actual bundle ID of the application.
        NSURL* appSupportDir = (NSURL*)[directories objectAtIndex:0];
        NSString* privateSharedDirectoryExten;
        if(privateOrShared){
            privateSharedDirectoryExten = @"private";
        }else{
            
            privateSharedDirectoryExten = @"shared";
        }
        
        // Perform the copy asynchronously.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // It's good habit to alloc/init the file manager for move/copy operations,
            // just in case you decide to add a delegate later.
            NSFileManager* fm = [NSFileManager defaultManager];
            NSError* error;
            
            for(File* file in selectedFiles){
                
                [firstDirectory removeObject:file]; //remove each file from the original directory array
                [secondDirectory addObject:file]; //put each file in the new directory array
                
                // Copy the data to ~/Library/Application Support/<bundle_ID>/Data.backup
                NSURL* copyingFromDirectory = [[appSupportDir URLByAppendingPathComponent:privateSharedDirectoryExten] URLByAppendingPathComponent: file.name];
                NSURL* copyingToDirectory;
                
                NSInteger finalDot = 0;
                NSString *fileExtension = @"";
                
                for (NSInteger index=0; index<file.name.length;index++){
                    if([file.name characterAtIndex:index] == '.'){
                        finalDot = index;
                    }
                    if(index == file.name.length-1){
                        
                        fileExtension = [file.name substringFromIndex:finalDot+1];
                    }
                    /*if(finalDot == 0){ //uncomment in the future if we allow the user to make directories
                        
                        fileExtension = @"directory";
                    }*/
                }
                
                NSLog(fileExtension); // just a debug to make sure things look right
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
        NSURL* pathToCheck = [[appSupportDir URLByAppendingPathComponent:appBundleID] URLByAppendingPathComponent: file.name];
        NSLog(@"%@",pathToCheck);
        if(![self isValidPath:[pathToCheck absoluteString]]){
            
            return NO;
        }//all files sucessfully path transferred is never triggers.
    }
    return YES;
}

//creates a new directory in the documents folder of our app
//if a directory with that name does not already exist
//for this iteration of malamute for iOS it is only called once
//in filesystem setup and run
-(BOOL) createNewDir:(NSString*) dirname{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* urlForNew = nil;
    NSError* error;
    //get all the url paths in teh documents directory
    NSArray* documents = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    
    if([documents count] > 0){
        urlForNew = [[documents objectAtIndex:0] URLByAppendingPathComponent:dirname];
        NSLog(@"%@", urlForNew);
        if (![self isValidPath:[urlForNew absoluteString]] && ![fm createDirectoryAtURL:urlForNew withIntermediateDirectories:YES attributes:nil error:&error]){
            NSLog(@"problem making new directory");
            return NO;
        }
    }
    return YES;
}

//makes a set of dummy files for us to test useability
-(void) makeDummyFiles{
    
    NSArray* documents = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *private = [[[documents objectAtIndex:0] absoluteString] stringByAppendingString:@"private/"];
    NSLog(private);
    NSString *shared = [[[documents objectAtIndex:0] absoluteString] stringByAppendingString:@"shared/"];
    NSString *testfile1 = [private stringByAppendingPathComponent:@"testfile1.txt"];
    File *testfileobj1 = [[File alloc] initWithName:@"testfile1.txt" andURL:[NSURL URLWithString:testfile1]];
    [_privateDocs addObject:testfileobj1];
    NSString *testfile2 = [private stringByAppendingString:@"testfile2.txt"];
    File *testfileobj2 = [[File alloc] initWithName:@"testfile2.txt" andURL:[NSURL URLWithString:testfile2]];
    [_privateDocs addObject:testfileobj2];
    NSString *testfile3 = [shared stringByAppendingString:@"testfile3.txt"];
    File *testfileobj3 = [[File alloc] initWithName:@"testfile3.txt" andURL:[NSURL URLWithString:testfile3]];
    [_sharedDocs addObject:testfileobj3];
    NSString *testfile4 = [shared stringByAppendingString:@"testfile4.txt"];
    File *testfileobj4 = [[File alloc] initWithName:@"testfile4.txt" andURL:[NSURL URLWithString:testfile4]];
    [_sharedDocs addObject:testfileobj4];
    NSString *string = @"text-test";
    NSError *writeError = nil;
    [string writeToFile:testfile1 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    NSLog(@"First: %@", writeError.localizedFailureReason);
    NSLog(@"First: %@", testfileobj1.url);
    [string writeToFile:testfile2 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    NSLog(@"Second: %@", writeError.localizedFailureReason);
    NSLog(@"First: %@", testfileobj2.url);
    [string writeToFile:testfile3 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    NSLog(@"Third: %@", writeError.localizedFailureReason);
    NSLog(@"First: %@", testfileobj3.url);
    [string writeToFile:testfile4 atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    NSLog(@"Fourth: %@", writeError.localizedFailureReason);
    NSLog(@"First: %@", testfileobj4.url);
}

@end
