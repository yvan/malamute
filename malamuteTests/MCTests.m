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

@interface MCTests : XCTestCase {
    UIApplication* app;
    ViewController* viewController;
    MCPeerID* testPeer;
}
@end

@implementation MCTests

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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
