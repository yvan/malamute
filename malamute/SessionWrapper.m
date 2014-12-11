//
//  SessionWrapper.m
//  malamute
//
//  Created by Yvan Scher & Enrique Lores on 10/31/14.
//  Copyright (c) 2014 Yvan Scher & Enrique Lores. All rights reserved.
//

#import "SessionWrapper.h"
#import "File.h"

static NSString* const ServiceName = @"malamute";

@interface SessionWrapper()

@property (nonatomic) MCPeerID *myPeerID;

@end

@implementation SessionWrapper


#pragma mark - Getters/Setters/Initializers/Destroyers

/* - Returns local user's peerID - */
-(MCPeerID*) getMyPeerId{
    
    return _myPeerID;
}

/* - Returns our app name in "service name" terms
   - important for browsing/advertising on dif. services
   - */
-(NSString*) getServiceName{
    
    return ServiceName;
}

/* - Returns number of peers in peer array - */
-(NSUInteger) numberConnectedPeers{
    
    return _session.connectedPeers.count;
}

/* - destroys a session - */
-(void) destroySession{
    
    [_session disconnect];
}

/* - initializes a sesssion (called from ViewController.m)
   - advertising/browsing are done in respective helpers
   - */
-(instancetype) initSessionWithName: (NSString *)name{
    
     NSLog(@"%s STARTED SESSION WITH NAME: %@", __PRETTY_FUNCTION__, name);
    
    _myPeerID = [[MCPeerID alloc] initWithDisplayName:name];
    _session = [[MCSession alloc] initWithPeer: _myPeerID];
    _session.delegate = self;
    return self;
}

/* - get peer at index - */
-(MCPeerID *) getPeerAtIndex:(NSUInteger)index{
    
    if(index >= _session.connectedPeers.count) return nil;
    return _session.connectedPeers[index];
}

#pragma mark - sendFiles specialized method to send resources
/* - takes an array of files and an array of peerIds and sends
   - all of those files to those peer ids, remake into
   - asynchonous function w/ dispatch???
   - */
-(void)sendFiles:(NSArray *)Files toPeers:(NSArray *)peerIDs{
    
    NSLog(@"%s SENDING FILES", __PRETTY_FUNCTION__);
    // - this way of formulating the URL is slightly different from filename.url's way of formulating the URL and apparently - //
    // - for sending resources the .url field's way on the File object does not work. We need the code below - //
    NSURL *docDirURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    
    for(int i = 0; i < [Files count]; i++){
        File* fileToSend = [Files objectAtIndex:i];
        NSURL *urlToSend = [docDirURL URLByAppendingPathComponent:fileToSend.name];
        NSLog(@"%s SENDING FILE AT URL: %@", __PRETTY_FUNCTION__, urlToSend);
        for(int j =0; j < [peerIDs count]; j++){
            MCPeerID* idToSend = [peerIDs objectAtIndex:j];
            [_session sendResourceAtURL:urlToSend withName:fileToSend.name toPeer: idToSend withCompletionHandler:^(NSError *error) {
                if(error){NSLog(@"%@",[error localizedDescription]);}
            }];
        }
    }
}

#pragma mark - MCSessionDelegate

/* - REMOTE PEER HAS ALTERED ITS STATE SOMEHOW - */
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
}

/* - STARTED RECEIVING RESOURCE FROM REMOTE PEER - */
-(void) session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)foreignPeerID withProgress:(NSProgress *)progress{
    
    [_sessionDelegate didStartReceivingResource:session resourceName:resourceName fromPeer:foreignPeerID withProgress:progress];
}

/* - DID FINISH RECEIVEING RESOURCE FROM PEER - */
-(void) session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)foreignPeerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    [_sessionDelegate didFinishReceivingResource:session resourceName:resourceName fromPeer:foreignPeerID atURL:localURL withError:error];
}

/* - DID RECEIVE STREAM FROM PEER - */
-(void) session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

/* - RECEIVED DATA FROM REMOTE PEER - */
-(void) session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    
}

/* - I should probably figure out what this method actually does...not in the docs...THANKS OBAMA - */
-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)cert fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certHandler {
    
    certHandler(YES);
}

@end
