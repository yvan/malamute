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
    
    _autoadvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:myPeerId discoveryInfo:nil serviceType:@"AirDoc"];
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

-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)foreignPeerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler{
    
    [_advertiserDelegate acceptInvitationFromPeer:foreignPeerID invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler];
}

-(void) advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    
    NSLog(@"%s %@",__PRETTY_FUNCTION__, error);
}

@end
