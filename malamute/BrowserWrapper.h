//
//  BrowserWrapper.h
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol BrowserWrapperDelegate <NSObject>

-(void) inviteFoundPeer:(MCPeerID *)foreignPeerID;

@end

@interface BrowserWrapper : NSObject <MCNearbyServiceBrowserDelegate>

@property (nonatomic, readonly) MCNearbyServiceBrowser *autobrowser;
@property (nonatomic, readonly) BOOL browsing;
@property (nonatomic) id <BrowserWrapperDelegate> browserDelegate;

-(instancetype) startBrowsing:(MCPeerID *)myPeerId;
-(void) stopBrowsing;
-(void) restartBrowsing;

@end
