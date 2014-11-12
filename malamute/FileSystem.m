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
    NSMutableArray *allFiles = [fileManager contentsOfDirectoryAtPath:_documentsDirectory error:&error];
    
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
        NSString* docsPath = [((File*)_privateDocs[i]) url];
        [fileManager removeItemAtPath:[_documentsDirectory stringByAppendingPathComponent:docsPath] error:&error];
    }
    if(error){
        NSLog(@"ERROR DELETING ALL FILES %@", [error localizedDescription]);
    }
    _privateDocs = [self getAllDocDirFiles];
}


-(BOOL) isValidPath:(NSString*) path{
    return nil;
}

-(void) saveDocumentToSandbox:(File*)document{
    //move file from file's path to documents folder path, update file
    //add to private documents array
    
    NSString *destinationPath = [_documentsDirectory stringByAppendingPathComponent:document.name];
    while(![self isValidPath:destinationPath]){
        //prompt user to rename the file
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



@end
