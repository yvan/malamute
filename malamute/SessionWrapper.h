//
//  SessionWrapper.h
//  malamute
//
//  Created by Yvan Scher & Enrique Lores on 10/31/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol SessionWrapperDelegate <NSObject>

-(void) didFinishReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error;

-(void)didStartReceivingResource:(MCSession *)session resourceName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress;

-(void)didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;

@end

@interface SessionWrapper : NSObject <MCSessionDelegate>{
    
}

@property (nonatomic) MCSession *session;
@property (nonatomic, readonly) MCPeerID *myPeerID;
@property (nonatomic) id <SessionWrapperDelegate> sessionDelegate;

-(void) destroySession;
-(MCPeerID*) getMyPeerId;
-(NSString*) getServiceName;
-(NSUInteger) numberConnectedPeers;
-(MCPeerID *) getPeerAtIndex:(NSUInteger)index;
-(instancetype) initSessionWithName: (NSString *)name;
-(void) sendFiles:(NSArray *)Files toPeers:(NSArray *)peerIDs;
-(void) sendAcknowledgementOfReceiptToPeer:(MCPeerID *) foreignPeerID;
-(void) sendHeader:(NSString *)header toPeer:(MCPeerID *) foreignPeerID;

@end
