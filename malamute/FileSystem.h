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
@property (nonatomic, strong) NSString* documentsDirectory;

-(NSArray *)getAllDocDirFiles;
-(void) deleteAllDocumdentsFromSandbox;
-(BOOL) isValidPath:(NSString*) path;
-(void) saveDocumentToSandbox:(File*)document;

@end