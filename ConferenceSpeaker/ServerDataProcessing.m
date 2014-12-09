//
//  ServerDataProcessing.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "ServerDataProcessing.h"
#import "CommunicationModel.h"

#define REGISTRARTION 1
#define OPEN_CHANNEL  2
#define CLOSE_CHANNEL 3
#define VOTING        4

#define TIMEOUT       -1

@implementation ServerDataProcessing
{
    BOOL            registreredUser;
    GCDAsyncSocket *asyncSocket;
    NSUserDefaults *userDef;
}

+ (ServerDataProcessing *)sharedModel
{
    static dispatch_once_t once;
    static ServerDataProcessing *sharedModel = nil;
    dispatch_once(&once, ^{
        sharedModel = [[self alloc] init];
    });
    return sharedModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        serverUUIDArray = [NSMutableArray array];
        serverInfoArray = [NSMutableArray array];
        voteUUIDArray = [NSMutableArray array];
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                 delegateQueue:dispatch_get_main_queue()];
        userDef = [[NSUserDefaults alloc] initWithSuiteName:@"ConferenceSpeaker"];
    }
    return self;
}

- (void)udpServerData:(NSData *)message
{
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:message
                                                               options:kNilOptions
                                                                 error:&error];
    
    NSString *uuid = [dictionary objectForKey:kUUIDKey];
    NSDictionary *info = [dictionary objectForKey:kInfoKey];
    
    //!!check
    BOOL oldServerUuid = [serverUUIDArray containsObject: uuid];
    if (!oldServerUuid) {
        [serverUUIDArray addObject:uuid];
        [serverInfoArray addObject:info];
        _serversAvalibility = YES;
    }
    
    if ([dictionary objectForKey:kVoteKey]&&registreredUser)
    {
        NSString *voteUuid = [[dictionary objectForKey:kVoteKey] objectForKey:kUUIDKey];
        BOOL oldVoteUuid = [voteUUIDArray containsObject: voteUuid];
        if (!oldVoteUuid) {
            [voteUUIDArray addObject:voteUuid];
            _votingAvability = YES;
            votingDictionary = [dictionary objectForKey:kVoteKey];
            NSLog(@"votingDictionary %@", votingDictionary);
        }
    }
}

- (NSDictionary *)serverInfo: (NSString *)serverName
{
    for (NSInteger i=0; [serverInfoArray count]; i++)
    {
        NSString *server = [[serverInfoArray objectAtIndex:i] objectForKey:kNameKey];
        if ([server isEqualToString:serverName])
        {
            return [serverInfoArray objectAtIndex:i];
        }
    }
    return nil;
}

- (NSUserDefaults *)settings
{
    return userDef;
}

- (NSArray *)serverNameArray
{
    NSMutableArray *serverArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<[serverInfoArray count]; i++)
    {
        [serverArray addObject:[[serverInfoArray objectAtIndex:i] objectForKey:kNameKey]];
    }    
    return serverArray;
}

- (NSDictionary *)voteDictionary
{
    return votingDictionary;
}

//- (BOOL)votingAvability
//{
//    if ([votingDictionary objectForKey:kQuestionKey]) {
//        return YES;
//    }
//    else
//        return NO;
//}

-(void)connect
{
    NSString *selectedServer = [userDef objectForKey:kSelectedServerKey];
    NSDictionary *serverInfo = nil;
    for (NSInteger i=0; i < [serverUUIDArray count]; i++)
    {
        if ([[serverInfoArray objectAtIndex:i][kNameKey] isEqualToString: selectedServer])
        {
            serverInfo = [serverInfoArray objectAtIndex:i];
        }
    }
    if (!serverInfo)
        return;
    
    NSString *host = serverInfo[kAddressKey];// @"192.168.0.104";
    uint16_t port = [serverInfo[kPortKey] integerValue];//35001;
    
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
}

- (void)registrationRequest
{
    RegistrationRequest *req = [[RegistrationRequest alloc] init];
    req.request = @"registration";
    req.user = [userDef objectForKey:kUserDataKey];
    NSData *jsonData = [[req toJSONString] dataUsingEncoding:NSUTF8StringEncoding];

    [asyncSocket readDataWithTimeout:TIMEOUT tag:REGISTRARTION];
    [asyncSocket writeData:jsonData withTimeout:TIMEOUT tag:REGISTRARTION];
}


- (void)openChannelRequest
{
    NSError *error = nil;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:@{kRequestKey: @"channel_open"}
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
    
    [asyncSocket readDataWithTimeout:TIMEOUT tag:OPEN_CHANNEL];
    [asyncSocket writeData:jsonData withTimeout:TIMEOUT tag:OPEN_CHANNEL];
}

- (void)closeChannelRequest
{
    NSError *error = nil;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:@{kRequestKey: @"channel_close"} options:NSJSONWritingPrettyPrinted error:&error];
    
    [asyncSocket readDataWithTimeout:TIMEOUT tag:CLOSE_CHANNEL];
    [asyncSocket writeData:jsonData withTimeout:TIMEOUT tag:CLOSE_CHANNEL];
}

- (void)votingRequest:(NSString *)answer
{
    NSString *jsonString;
    int answerInt = [answer integerValue];
    NSLog(@"Answer: %i", answerInt);
    if ([[votingDictionary objectForKey:kModeKey] isEqualToString: kSimpleMode]) {
        VoteSimpleRequest *req = [[VoteSimpleRequest alloc] init];
        req.request = kVoteKey;
        req.uuid = [votingDictionary objectForKey:kUUIDKey];
        req.answer = answerInt != 0;
        jsonString = [req toJSONString];
    } else {
        VoteCustomRequest *req = [[VoteCustomRequest alloc] init];
        req.request = kVoteKey;
        req.uuid = [votingDictionary objectForKey:kUUIDKey];
        req.answer = answerInt - 1;
        jsonString = [req toJSONString];
    }
    
    [asyncSocket readDataWithTimeout:TIMEOUT tag:VOTING];
    [asyncSocket writeData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
               withTimeout:TIMEOUT
                       tag:VOTING];
}

#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu flag: %@", sock, host, port, [sock isConnected] ? @"Y" : @"N");
    NSLog(@"localHost :%@ port:%hu", [sock localHost], [sock localPort]);
    {
        // Connected to normal server (HTTP)
        
#if ENABLE_BACKGROUNDING && !TARGET_IPHONE_SIMULATOR
        {
            // Backgrounding doesn't seem to be supported on the simulator yet
            
            [sock performBlock:^{
                if ([sock enableBackgroundingOnSocket])
                    DDLogInfo(@"Enabled backgrounding on socket");
                else
                    DDLogWarn(@"Enabling backgrounding failed!");
            }];
        }
#endif
    }
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    // Parsing
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                          options:kNilOptions
                                                            error:&error];
    if ([json objectForKey:kErrorKey]) {
        switch (tag) {
            case VOTING:
                [[[UIAlertView alloc] initWithTitle:@"ГОЛОСОВАНИЕ"
                                            message:[json objectForKey:@"description"]
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
                break;
                
            default:
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: @"ConnectionStatus"
                                                            object:nil
                                                          userInfo:@{kRequestKey: kRegKey, kErrorKey:[json objectForKey:kErrorKey]}];
        NSLog(@"Error: %@", [json objectForKey:@"description"]);
        
    } else {
        switch (tag) {
            case REGISTRARTION:
                registreredUser = YES;
                break;
            case VOTING:
                [[[UIAlertView alloc] initWithTitle:@"ГОЛОСОВАНИЕ"
                                            message:@"Ваш голос принят!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil] show];
                break;
            default:
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName: @"ConnectionStatus"
                                                            object:nil
                                                          userInfo:json];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    registreredUser = false;
}

@end
