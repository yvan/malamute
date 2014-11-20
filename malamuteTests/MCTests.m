//
//  MCTests.m
//  malamute
//
//  Created by Quique Lores on 11/7/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "ViewController.h"
#import "File.h"

@interface MCTests : XCTestCase {
    UIApplication* app;
    ViewController* viewController;
    MCPeerID* testPeer;
    NSData* testFile;
    NSString* testFilePath;
    File* testFileFile;
}
@end

@implementation MCTests

- (void)setUp {
    [super setUp];
    app = [UIApplication sharedApplication];
    viewController = [[ViewController alloc] init];
    [viewController viewDidLoad];
    testPeer = [[MCPeerID alloc] initWithDisplayName:@"testPeerID"];
    
    NSString* testFile1Name = @"testfile1.txt";
    NSString* testFile2Name = @"testfile2.txt";
    
    
    //copy testFile from supporting files folder
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    testFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: testFile1Name];
    
    testFile = [[NSFileManager defaultManager] contentsAtPath:testFilePath];
    
    testFileFile = [[File alloc] init];
    testFileFile.name = @"testfile1.txt";
    testFileFile.url = [NSURL fileURLWithPath:testFilePath];
    testFileFile.sender = viewController.sessionWrapper.myPeerID.displayName;
    testFileFile.dateCreated = [NSDate date];
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
    [viewController.fileSystem deleteAllDocumentsFromSandbox];

}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

-(void) testSetUp {
    XCTAssertNotNil(app);
    XCTAssertNotNil(viewController);
    XCTAssertNotNil(testPeer);
}
-(void) testSessionInit {
    XCTAssertNotNil(viewController.sessionWrapper, @"ViewController should have a session wrapper");
    XCTAssertNotNil(viewController.sessionWrapper.session, @"Dession Wrapper should have a session");
}
-(void) testAdvertiserInit {
    XCTAssertNotNil(viewController.advertiserWrapper, @"View controller should have an advertiserwrapper");
}

-(void) testBrowserInit {
    XCTAssertNotNil(viewController.browserWrapper, @"View controller should have a browser wrapper");
}

-(void)testReceivingResource{
    int count = [viewController.fileSystem.sharedDocs count];
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"testfile123.txt" fromPeer:testPeer atURL:[NSURL fileURLWithPath:testFilePath] withError:nil];
    XCTAssertTrue((count +1 ==[viewController.fileSystem.sharedDocs count]), @"Receiving a document should increase the shared doc count by 1");
}
-(void) testSendResource{
    NSArray* files = [[NSArray alloc] initWithObjects:testFileFile, nil];
    NSArray* peers = [[NSArray alloc] initWithObjects:testPeer, nil];
    [viewController.sessionWrapper sendFiles:files toPeers: peers];
    XCTAssertTrue(true);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
