//
//  filesystemTests.m
//  malamute
//
//  Created by Quique Lores & Yvan Scher on 11/5/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "ViewController.h"

@interface filesystemTests : XCTestCase{

    UIApplication* app;
    ViewController* viewController;
    MCPeerID* testPeer;
    NSData* testFile;
    NSString* testFilePath;
}
@end

/*** - A NOTE ON TESTS ***/
/* 
they need to be implementation independent as much as possible,
they shouldn't rely on the stuff inside of the function inside 
test, they should objective test whether or not hte function 
has done its job.In otherwords if we're supposed to write
to a file then we check if that file contains what we
want, it should not rely on specific variables that 
may cahnge (within reason), implementations change,
tests shouldn't.
*/
@implementation filesystemTests

#pragma mark - Setup Tests

- (void)setUp {
    [super setUp];
    app = [UIApplication sharedApplication];
    viewController = [[ViewController alloc] init];
    [viewController viewDidLoad];
    [viewController.fileSystem forceDeleteAllItemsInDocuments];
    [viewController.fileSystem.sharedDocs removeAllObjects];
    [viewController.fileSystem.privateDocs removeAllObjects];
    testPeer = [[MCPeerID alloc] initWithDisplayName:@"testPeerID"];
    
    NSString* testFile1Name = @"testfile1.txt";
    testFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: testFile1Name];
    testFile = [[NSFileManager defaultManager] contentsAtPath:testFilePath];
   
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [viewController viewDidDisappear:YES];
    app = nil;
    viewController = nil;
    testPeer = nil;
    testFilePath = nil;
    testFile = nil;
    [viewController.fileSystem forceDeleteAllItemsInDocuments];
}

#pragma mark - Test FileSystem Basics

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}
-(void) testTestFilePath{
    XCTAssertNotNil(testFilePath, @"Test File path should not be nil");
}
-(void) testTestFile{
    XCTAssertNotNil(testFile, @"Test File should not be nil");
}
-(void) testDocumentsDirectory{
    XCTAssertNotNil(viewController.fileSystem.documentsDirectory, @"File system should not be nil");
}
-(void) testSharedDocuments{
    XCTAssertNotNil(viewController.fileSystem.sharedDocs, @"Filesystem shared documents array should not be nil");
}
-(void) testPrivateDocuments{
    XCTAssertNotNil(viewController.fileSystem.privateDocs, @"Filesystem private documents array should not be nil");
}
-(void)testCreateNewDir{
    XCTAssertTrue([viewController.fileSystem createNewDir:@"private"]);
    XCTAssertTrue([viewController.fileSystem createNewDir:@"shared"]);
}


#pragma mark - Test Our FileSystem Abstractions / Their interactions with FileSystem

-(void)testSharedDocsCount{
    NSInteger count = [viewController.fileSystem.sharedDocs count];
    XCTAssertTrue((count == 0), @"Shared Docs should be null in the beginning");
}
-(void)testPrivateDocsCount{
    NSInteger count = [viewController.fileSystem.privateDocs count];
    XCTAssertTrue((count == 0), @"Private Docs should be null in the beginning");
}
-(void)testSavingDocs{
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile123.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    [viewController.fileSystem saveFileToDocumentsDir:(File*)viewController.fileSystem.sharedDocs[0]];
    XCTAssertTrue(viewController.fileSystem.sharedDocs[0] == viewController.fileSystem.privateDocs[0], @"Document should be on both shared and private docs after saving it");
}
-(void)testInValidUrl{
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile123.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    [viewController.fileSystem saveFileToDocumentsDir:(File*)viewController.fileSystem.sharedDocs[0]];
    XCTAssertTrue([viewController.fileSystem isValidPath:testFilePath]== false, @"File path should be invalid after saving it");
}
-(void)testValidUrl{
    NSString* validPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"123456890abcdefghijklmno.txt.pdf"];
    XCTAssertTrue([viewController.fileSystem isValidPath:validPath]== true, @"File path should be invalid after saving it");
}

/*-(void) testDeleteDocs{
 [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile1.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
 [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile2.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
 [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile3.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
 XCTAssertTrue(([viewController.fileSystem.sharedDocs count] > 0), @"Docs should not be empty after receiving some files.");
 [viewController.fileSystem deleteAllDocumdentsFromSandbox];
 XCTAssertTrue(([viewController.fileSystem.sharedDocs count] == 0), @"Delete should delete all docs");
 }*/


-(void)testMoveSelectedFiles{
    
    NSMutableArray* selectedFiles = [[NSMutableArray alloc]init];
    NSMutableArray* privateDirectory = [[NSMutableArray alloc]init];
    NSMutableArray* sharedDirectory = [[NSMutableArray alloc]init];
    File* testfile1 = [[File alloc] init];
    File* testfile2 = [[File alloc] init];
    File* testfile3 = [[File alloc] init];
    
    NSArray* documents = [[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *private = [[[documents objectAtIndex:0] absoluteString] stringByAppendingString:@"private/"];
    NSString *shared = [[[documents objectAtIndex:0] absoluteString] stringByAppendingString:@"shared/"];
    
    testfile1.name = @"testfile1.txt";
    testfile1.url = (NSURL *)[private stringByAppendingPathComponent: testfile1.name];
    testfile1.dateCreated = [NSDate date];
    testfile2.name = @"testfile2.txt";
    testfile2.url = (NSURL *)[private stringByAppendingPathComponent: testfile2.name];
    testfile2.dateCreated = [NSDate date];
    testfile3.name = @"testfile3.txt";
    testfile3.url = (NSURL *)[shared stringByAppendingPathComponent: testfile3.name];
    testfile3.dateCreated = [NSDate date];
    [privateDirectory addObject:testfile1];
    [privateDirectory addObject:testfile2];
    [sharedDirectory addObject:testfile3];
    [selectedFiles addObject:testfile1];
    [selectedFiles addObject:testfile2];
    [viewController.fileSystem createNewDir:@"private"];
    [viewController.fileSystem createNewDir:@"shared"];
    XCTAssertTrue([viewController.fileSystem moveFiles:selectedFiles from:privateDirectory to:sharedDirectory withInfo:YES]);
}

-(void)testpopulateArraysWithFileSystem{
    
    [viewController.fileSystem populateArraysWithFileSystem];
    NSLog(@"Shared: %@",viewController.fileSystem.sharedDocs);
    NSLog(@"Private: %@",viewController.fileSystem.privateDocs);
    XCTAssertTrue(viewController.fileSystem.sharedDocs != nil);
    XCTAssertTrue(viewController.fileSystem.privateDocs != nil);
}

-(void)testSaveFileSystemToJSON{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];

    //test new timestamp against this a timstamp created right now, if they match,
    //then we pass the test
    NSDate* nowTimestamp = [NSDate date];
    
    //create Dummy files and put them through the motions.
    File* file1 = [[File alloc] initWithName:@"malamute-test1.txt" andURL:[[NSURL alloc]initWithString:@"blah"] andDate:[NSDate date] andDirectoryFlag:0];
    File* file2 = [[File alloc] initWithName:@"malamute-test1.txt" andURL:[[NSURL alloc]initWithString:@"blah"] andDate:[NSDate date] andDirectoryFlag:0];
    [viewController.fileSystem.sharedDocs addObject:file1];
    [viewController.fileSystem.privateDocs addObject:file2];
    [viewController.fileSystem saveFileSystemToJSON]; //write the new data
    //get the new timestamp
    NSString *filePathDummy = [viewController.fileSystem.documentsDirectory stringByAppendingPathComponent:@"filesystem.json"];
    NSData* filesystemdataDummy = [NSData dataWithContentsOfFile:filePathDummy];
    NSDictionary* DictStamp = [NSJSONSerialization JSONObjectWithData:filesystemdataDummy options:0 error:nil];
    NSDate* newTimestamp = [formatter dateFromString:[DictStamp valueForKey:@"timestamp"]];

    /*if the new one is greater than the old one then well assume that
    //the data was written successfully to the file anew
    //This will print out two NSDate objects that APPEAR exactly the same
    //but the isEqual method detects subseconds on NSDate objects that we
    //do not see here printing them out. It's why they don't appear equal.
    //since we created nowTimestamp several microseconds before newTimeStamp
    //the NSDate objects are not equal. if the write fails, then timsstamp
    //read from our file should be MUCH older than nowTimestamp. Is there
    //a way to print out the NSDate with greater precision????*/
    NSLog(@"TIMESTAMP: %@", nowTimestamp);
    NSLog(@"NEWTIMESTAMP: %@", newTimestamp);
    XCTAssertTrue(![nowTimestamp isEqual:newTimestamp]);
    
}

#pragma mark - MISC

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
