//
//  AdvertiserWrapper.h
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol AdvertiserWrapperDelegate <NSObject>

-(void) acceptInvitationFromPeer:(MCPeerID *)foreignPeerID
               invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler;

@end

@interface AdvertiserWrapper : NSObject <MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, readonly) MCNearbyServiceAdvertiser *autoadvertiser;
@property (nonatomic, readonly) BOOL advertising;
@property (nonatomic) id <AdvertiserWrapperDelegate> advertiserDelegate;

-(instancetype) startAdvertising:(MCPeerID *) myPeerId;
-(void) stopAdvertising;
-(void) restartAdvertising;

@end
