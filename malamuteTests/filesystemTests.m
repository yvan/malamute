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
}
@end

@implementation filesystemTests

- (void)setUp {
    [super setUp];
    app = [UIApplication sharedApplication];
    viewController = [[ViewController alloc] init];
    [viewController viewDidLoad];
    testPeer = [[MCPeerID alloc] initWithDisplayName:@"testPeerID"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    app = nil;
    viewController = nil;
    testPeer = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

/*-(void)testReceivingResource{
    [viewController didFinishReceivingResource:viewController.sessionWrapper.session resourceName:@"Something.jpeg" fromPeer:testPeer atURL:[[NSURL alloc] initFileURLWithPath:@"malamute/docs/test/" isDirectory:YES ] withError:nil];
    XCTAssert(YES, @"I don't know");
}*/

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
