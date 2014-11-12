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
    XCTAssertNotNil(viewController.fileSystem, @"File system should not be nil");
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