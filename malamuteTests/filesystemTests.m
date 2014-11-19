//
//  filesystemTests.m
//  malamute
//
//  Created by Quique Lores on 11/5/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
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

@implementation filesystemTests

- (void)setUp {
    [super setUp];
    app = [UIApplication sharedApplication];
    viewController = [[ViewController alloc] init];
    [viewController viewDidLoad];
    //[viewController.fileSystem deleteAllDocumdentsFromSandbox];
    testPeer = [[MCPeerID alloc] initWithDisplayName:@"testPeerID"];
    
    NSString* testFile1Name = @"testfile1.txt";
    NSString* testFile2Name = @"testfile2.txt";
    
    //copy testFile from supporting files folder
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
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
    [viewController deleteAllDocumdentsFromSandbox];
}

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

-(void)testReceivingResource{
    int count = [viewController.fileSystem.sharedDocs count];
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile123.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    XCTAssertTrue((count +1 ==[viewController.fileSystem.sharedDocs count]), @"Receiving a document should increase the shared doc count by 1");
}

-(void)testSharedDocsCount{
    int count = [viewController.fileSystem.sharedDocs count];
    XCTAssertTrue((count == 0), @"Shared Docs should be null in the beginning");
}
-(void)testPrivateDocsCount{
    int count = [viewController.fileSystem.privateDocs count];
    XCTAssertTrue((count == 0), @"Private Docs should be null in the beginning");
}
-(void)testSavingDocs{
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile123.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    [viewController.fileSystem saveDocumentToSandbox:(File*)viewController.fileSystem.sharedDocs[0]];
    NSMutableArray* files = [viewController.fileSystem getAllDocDirFiles];
    XCTAssertTrue(viewController.fileSystem.sharedDocs[0] == viewController.fileSystem.privateDocs[0], @"Document should be on both shared and private docs after saving it");
    
}
-(void)testInValidUrl{
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile123.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    [viewController.fileSystem saveDocumentToSandbox:(File*)viewController.fileSystem.sharedDocs[0]];
    XCTAssertTrue([viewController.fileSystem isValidPath:testFilePath]== false, @"File path should be invalid after saving it");
}
-(void)testValidUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* validPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"123456890abcdefghijklmno.txt.pdf"];
    XCTAssertTrue([viewController.fileSystem isValidPath:validPath]== true, @"File path should be invalid after saving it");
}

-(void)testMoveSelectedFiles{
    
    NSMutableArray* selectedFiles = [[NSMutableArray alloc]init];
    NSMutableArray* privateDirectory = [[NSMutableArray alloc]init];
    NSMutableArray* sharedDirectory = [[NSMutableArray alloc]init];
    File* testfile1 = [[File alloc] init];
    File* testfile2 = [[File alloc] init];
    File* testfile3 = [[File alloc] init];
    
    testfile1.name = @"testfile1.txt";
    testfile1.url = (NSURL *)[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: testfile1.name];
    testfile1.dateCreated = [NSDate date];
    testfile2.name = @"testfile2.txt";
    testfile2.url = (NSURL *)[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: testfile2.name];
    testfile2.dateCreated = [NSDate date];
    testfile3.name = @"testfile3.txt";
    testfile3.url = (NSURL *)[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: testfile3.name];
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


-(void)testCreateNewDir{
    XCTAssertTrue([viewController.fileSystem createNewDir:@"private"]);
    XCTAssertTrue([viewController.fileSystem createNewDir:@"shared"]);
}

/*-(void) testDeleteDocs{
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile1.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile2.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile3.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    XCTAssertTrue(([viewController.fileSystem.sharedDocs count] > 0), @"Docs should not be empty after receiving some files.");
    [viewController.fileSystem deleteAllDocumdentsFromSandbox];
    XCTAssertTrue(([viewController.fileSystem.sharedDocs count] == 0), @"Delete should delete all docs");
}*/

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
