//
//  FileSystem.h
//  malamute
//
//  Created by Quique Lores on 11/11/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface FileSystem : NSObject

@property (nonatomic, strong) NSMutableArray* sharedDocs;
@property (nonatomic, strong) NSMutableArray* privateDocs;
@property (nonatomic, strong) NSMutableArray* filesIHaveShared;
@property (nonatomic, strong) NSString* documentsDirectory;

-(void) printAllFiles;
-(void) makeDummyFiles;
-(void) saveFileSystemToJSON;
-(BOOL) isValidPath:(NSString*) path;
-(void) populateArraysWithFileSystem;
-(NSMutableArray *) getAllDocDirFiles;
-(void) deleteAllDocumentsFromSandbox;
-(BOOL) createNewDir:(NSString*)dirname;
-(void) saveFileToDocumentsDir:(File*)file;
-(void) saveFilesToDocumentsDir:(NSArray*) files;
-(NSString *) getFileExtension:(NSString *)filename;
-(void) deleteSingleFileFromApp:(NSInteger)fileIndex fromDirectory:(NSMutableArray *) arrayToDeleteFrom;
-(File*) createNewFile:(NSString *) fileName withURL:(NSURL*) url inDirectory:(NSMutableArray *) arrayName;
-(BOOL) moveFiles:(NSMutableArray*)selectedFiles from:(NSMutableArray*)firstDirectory to:(NSMutableArray*)secondDirectory withInfo:(BOOL)privateOrShared;

@end