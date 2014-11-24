//
//  ServerDataProcessing.h
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol ServerConnection <NSObject>



@end


@interface ServerDataProcessing : NSObject
{
    NSMutableArray *serverUUIDArray;
    NSMutableArray *serverInfoArray;
    NSDictionary *votingDictionary;
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *voiceAsyncSocket;
    NSMutableArray *voteUUIDArray;
}


+ (ServerDataProcessing *)sharedModel;
- (void)udpServerData:(NSData *)message;
- (NSArray *)serverNameArray;
- (BOOL)serversAvalibility;
- (BOOL)votingAvability;
- (void)closeChannelRequest;
- (void)openChannelRequest;
- (NSDictionary *)voteDictionary;
- (void)votingRequest: (NSString *)answer;
- (void)setupTCPSocket;
- (void)registrationRequest;

@property BOOL serversAvalibility;
@property BOOL votingAvability;
//@property (weak) NSDictionary *votingDictionary;
@end
