//
//  SessionWrapper.m
//  malamute
//
//  Created by Yvan Scher on 10/31/14.
//  Copyright (c) 2014 Yvan Scher. All rights reserved.
//

#import "SessionWrapper.h"

static NSString* const ServiceName = @"malamute";

@interface SessionWrapper()

@property (nonatomic) MCSession *session;
@property (nonatomic) MCPeerID *myPeerID;
@property (nonatomic) NSMutableArray *connectedPeerIDs;

@end

@implementation SessionWrapper


#pragma mark - Getters/Setters/Initializers/Destroyers

//Returns local user's peerID
-(MCPeerID*) getMyPeerId{
    
    return _myPeerID;
}

//Returns our app name in "service name" terms
//important for browsing/advertising on dif. services
-(NSString*) getServiceName{
    
    return ServiceName;
}

//Returns number of peers in peer array
-(NSUInteger) numberConnectedPeers{
    
    return _connectedPeerIDs.count;
}

//destroys a session
-(void) destroySession{
    
    [_session disconnect];
}

//initializes a sesssion (called from ViewController.m)
//advertising/browsing are done in respective helpers
-(instancetype) initSessionWithName: (NSString *)name{
    
    _connectedPeerIDs = [NSMutableArray new];
    _myPeerID = [[MCPeerID alloc] initWithDisplayName:name];
    _session = [[MCSession alloc] initWithPeer: _myPeerID];
    _session.delegate = self;
    return self;
}

//get peer at index
-(MCPeerID *) getPeerAtIndex:(NSUInteger)index{
    
    if(index >= _connectedPeerIDs.count) return nil;
    return _connectedPeerIDs[index];
}

//takes an array of files and an array of peerIds and sends
//all of those files to those peer ids.
-(void)sendFiles:(NSArray *)Files toPeers:(NSArray *)peerIDs{
    
    
    /* Insert Code that does NSFilemanager here*/
    /* Possibly will need a loop to loop through all files in array*/
    /* [_session sendData:Files toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error]; */
}

#pragma mark - MCSessionDelegate

//REMOTE PEER HAS ALTERED ITS STATE SOMEHOW
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
    
}

// STARTED RECEIVING RESOURCE FROM REMOTE PEER
-(void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)foreignPeerID withProgress:(NSProgress *)progress{
    
    [_sessionDelegate didStartReceivingResource:session resourceName:resourceName fromPeer:foreignPeerID withProgress:progress];
}

//DID FINISH RECEIVEING RESOURCE FROM PEER
-(void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)foreignPeerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    [_sessionDelegate didFinishReceivingResource:session resourceName:resourceName fromPeer:foreignPeerID atURL:localURL withError:error];
}

//DID RECEIVE STREAM FROM PEER
-(void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

// RECEIVED DATA FROM REMOTE PEER
-(void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
}

//I should probably figure out what this method actually does...not in the docs...THANKS OBAMA
-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)cert fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certHandler {
    
    certHandler(YES);
}

@end
