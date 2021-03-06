//
//  BrowserWrapper.m
//  malamute
//
//  Created by Yvan Scher & Enrique Lores on 10/31/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import "BrowserWrapper.h"

@interface BrowserWrapper()

@property (nonatomic) MCNearbyServiceBrowser *autobrowser;
@property (nonatomic) BOOL browsing;

@end

@implementation BrowserWrapper

#pragma mark - Getters/Setters/Initializers/Destroyers

/* - Starts browsing for other/forgeign peers - */
-(instancetype) startBrowsing:(MCPeerID *)myPeerID{
    
    NSLog(@"%s STARTED BROWSING WITH MY PEERID: %@", __PRETTY_FUNCTION__, myPeerID);
    
    _autobrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:myPeerID serviceType:@"malamute"];
    _autobrowser.delegate = self;
    [_autobrowser startBrowsingForPeers];
    _browsing = YES;
    return self;
}

/* - stop browsing for peers with an initated autobrowser - */
-(void) stopBrowsing{
    
    [_autobrowser stopBrowsingForPeers];
    _browsing = NO;
}

/* - retstart browsing for peers with out initiated autobrowser - */
-(void) restartBrowsing{
    
    [_autobrowser startBrowsingForPeers];
    _browsing = YES;
}

#pragma mark - MCBrowserDelegate

/* - triggered automatically when our brower object "autobrowser" find a foreign peer - */
-(void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)foreignPeerID withDiscoveryInfo:(NSDictionary *)info{
    
    NSLog(@"%s FOUND PEER WITH PEERID: %@", __PRETTY_FUNCTION__, foreignPeerID);
    
    [_browserDelegate inviteFoundPeer:foreignPeerID];
}

/* - triggered automatically when our brower object "autobrowser" find a foreign peer - */
-(void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)foreignPeerID {
    
    NSLog(@"%s LOST PEER: %@", __PRETTY_FUNCTION__, foreignPeerID);
    
    [_browserDelegate alertToLostPeer:foreignPeerID];
}
/* - triggers if there was an error in initially searching for peers - */
-(void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    
    NSLog(@"%s %@",__PRETTY_FUNCTION__, error);
}

@end
