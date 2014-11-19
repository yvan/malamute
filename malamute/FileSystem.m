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

-(id) init{
    self = [super init];
    _sharedDocs = [[NSMutableArray alloc] init];
    _privateDocs = [[NSMutableArray alloc] init];
    _documentsDirectory = [[NSString alloc] init];
    return self;
}

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

-(void) printAllFiles{
    for(int i = 0; i < [_privateDocs count]; i++){
        NSLog(@"%@", _privateDocs[i]);
    }
}

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


-(BOOL) isValidPath:(NSString*) path{
    return !([[NSFileManager defaultManager] fileExistsAtPath:path]);
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
    
    //Get App data directory
    NSArray* directories = [[NSFileManager defaultManager]URLsForDirectory:NSApplicationSupportDirectory
inDomains:NSUserDomainMask];
    
    if([directories count] > 0){
        // Build a path to ~/Library/Application Support/<bundle_ID>/Data
        // where <bundleID> is the actual bundle ID of the application.
        NSURL* appSupportDir = (NSURL*)[directories objectAtIndex:0];
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        // Perform the copy asynchronously.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // It's good habit to alloc/init the file manager for move/copy operations,
            // just in case you decide to add a delegate later.
            NSFileManager* fm = [[NSFileManager alloc] init];
            NSError* error;
            
            for(File* file in selectedFiles){
                
                [firstDirectory removeObject:file]; //remove each file from the original directory array
                [secondDirectory addObject:file]; //put each file in the new directory array
                
                // Copy the data to ~/Library/Application Support/<bundle_ID>/Data.backup
                NSURL* copyingFromDirectory = [[appSupportDir URLByAppendingPathComponent:appBundleID] URLByAppendingPathComponent: file.name];
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
                    if(finalDot == 0){
                        
                        fileExtension = @"directory";
                    }
                }
                
                if(privateOrShared){
                    copyingToDirectory = [copyingFromDirectory  URLByAppendingPathExtension:fileExtension];
                }else{
                    copyingToDirectory = [copyingFromDirectory  URLByAppendingPathExtension:fileExtension];
                }
                
                if (![fm copyItemAtURL:copyingFromDirectory  toURL:copyingToDirectory error:&error]) {
                    
                    NSLog(@"copy error!");
                }
            }
        });
    }
    
    for(File* file in selectedFiles){
        
        NSURL* appSupportDir = (NSURL*)[directories objectAtIndex:0];
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSURL* isValidPath = [[appSupportDir URLByAppendingPathComponent:appBundleID] URLByAppendingPathComponent: file.name];
        
        if(![self isValidPath:[isValidPath absoluteString]]){
            
            return NO;
        }//all files sucessfully path transferred is never triggers.
    }
    return YES;
}

@end
