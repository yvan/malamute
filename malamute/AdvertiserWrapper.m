//
//  AdvertiserWrapper.m
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "AdvertiserWrapper.h"

@interface AdvertiserWrapper ()

@property (nonatomic) MCNearbyServiceAdvertiser *autoadvertiser;
@property (nonatomic) BOOL advertising;

@end

@implementation AdvertiserWrapper

#pragma mark - Getters/Setters/Initializers/Destroyers

/* - external use, starts the advertising and returns the AdvertiserHelper object - */
-(instancetype) startAdvertising:(MCPeerID *) myPeerId{
    
    NSLog(@"%s STARTED ADVERTISING WITH MY PEERID: %@", __PRETTY_FUNCTION__, myPeerId);
    
    _autoadvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerId discoveryInfo:nil serviceType:@"malamute"];
    _autoadvertiser.delegate = self;
    [_autoadvertiser startAdvertisingPeer];
    _advertising = YES;
    return self;
}

/* - stops advertising the peer by shutting down peer's advertiser - */
-(void) stopAdvertising{
    
    [_autoadvertiser stopAdvertisingPeer];
    _advertising = NO;
}

/* - restarts advertising the peer by restarting peer's advertiser - */
-(void) restartAdvertising{
    
    [_autoadvertiser startAdvertisingPeer];
    _advertising = YES;
}

#pragma mark - MCAdvertiserDelegate

/* - triggers automatically when we get an invitiation from a foreign peer, calls a delegate method in ViewController.m - */
-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)foreignPeerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    NSLog(@"%s RECIEVED INVITATION FROM PEER WITH PEERID: %@", __PRETTY_FUNCTION__, foreignPeerID);
    
    [_advertiserDelegate acceptInvitationFromPeer:foreignPeerID invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler];
}

/* - triggers automatically when we failed to start advertising in the first place, does not call a delegate method in ViewController.m - */
-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    
    NSLog(@"%s %@",__PRETTY_FUNCTION__, error);
}

@end
