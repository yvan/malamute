//
//  FileSystem.h
//  malamute
//
//  Created by Quique Lores & Yvan Scher on 11/11/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"

@interface FileSystem : NSObject

@property (nonatomic, strong) NSMutableArray* sharedDocs;
@property (nonatomic, strong) NSMutableArray* privateDocs;
@property (nonatomic, strong) NSMutableArray* filesIHaveShared;
@property (nonatomic, strong) NSString* documentsDirectory;

/* Creating */
-(File*) createNewFile:(NSString *) fileName withURL:(NSURL*) url inDirectory:(NSMutableArray *) arrayName;
-(BOOL) createNewDir:(NSString*)dirname;


/* Deleting */
-(void) deleteFilesFromApp:(NSArray*)files;
-(void) deleteSingleFileFromApp:(NSInteger)fileIndex fromDirectory:(NSMutableArray *) arrayToDeleteFrom;
-(void) forceDeleteAllItemsInDocuments;

/* Saving */
-(void) saveFileToDocumentsDir:(File*)file;
-(void) saveFilesToDocumentsDir:(NSArray*) files;

/* File System Backup */
-(void) saveFileSystemToJSON;
-(void) populateArraysWithFileSystem;

/* Testing */
-(void) printAllFiles;
-(void) makeDummyFiles;

/* Miscellaneous */
-(BOOL) isValidPath:(NSString*) path;
-(NSString *) getFileExtension:(NSString *)filename;
-(BOOL)moveFiles:(NSMutableArray*)selectedFiles from:(NSMutableArray*)firstDirectory to:(NSMutableArray*)secondDirectory withInfo:(BOOL)privateOrShared;


@end