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
-(void) alertToLostPeer:(MCPeerID *)lostForeignPeerID;

@end

@interface BrowserWrapper : NSObject <MCNearbyServiceBrowserDelegate>

@property (nonatomic, readonly) BOOL browsing;
@property (nonatomic) id <BrowserWrapperDelegate> browserDelegate;
@property (nonatomic, readonly) MCNearbyServiceBrowser *autobrowser;

-(void) stopBrowsing;
-(void) restartBrowsing;
-(instancetype) startBrowsing:(MCPeerID *)myPeerId;

@end
