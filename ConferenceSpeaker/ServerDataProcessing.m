//
//  ServerDataProcessing.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "ServerDataProcessing.h"
#import "TCPSocketConnection.h"
#import "VoiceSocketProcessing.h"

#define REGISTRARTION 1
#define OPEN_CHANNEL  2
#define CLOSE_CHANNEL 3
#define VOTING        4

@implementation ServerDataProcessing
{
    BOOL registreredUser;
    NSDictionary *voiceSocketDictionary;
}

+ (ServerDataProcessing *)sharedModel
{
    static dispatch_once_t once;
    static ServerDataProcessing *sharedModel = nil;
    dispatch_once(&once, ^{
        sharedModel = [[self alloc]init];
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
    }
    return self;
}

- (void)udpServerData:(NSData *)message
{
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:message options:kNilOptions error:&error];
    
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


- (BOOL)sendRegistationInfo
{
    NSDictionary *registrationDictionary = @{kRegKey: kRequestKey, kUserKey: [[NSUserDefaults standardUserDefaults] objectForKey:@"UserData"]};
    NSLog(@"%@", registrationDictionary);

//    NSError *error = nil;
//    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:registrationDictionary options:NSJSONWritingPrettyPrinted error:&error];
    
//    TCPSocketConnection *tcpSocket = [TCPSocketConnection sharedModel];
    
    [self setupTCPSocket];
    
    
    return YES;
}




-(void)setupTCPSocket
{
    dispatch_queue_t mainQueue =  dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSString *selectedServer = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedServerKey];
    NSDictionary *serverInfo;
    for (NSInteger i=0; i < [serverUUIDArray count]; i++)
    {
        if ([[serverInfoArray objectAtIndex:i][kNameKey] isEqualToString: selectedServer])
        {
            serverInfo = [serverInfoArray objectAtIndex:i];
        }
    }
    
//    NSDictionary *serverInfo = [serverInfoArray objectAtIndex: [serverUUIDArray indexOfObject: selectedServer]];
    
    NSString *host = serverInfo[kAddressKey];// @"192.168.0.104";
    uint16_t port = [serverInfo[kPortKey] integerValue];//35001;
    
    
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
    
    
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);

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
    
    NSError *error = nil;
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (tag == REGISTRARTION) {
        if ([dictionary objectForKey:kErrorKey]) {

            [[NSNotificationCenter defaultCenter] postNotificationName: @"ConnectionStatus" object:nil userInfo:@{kRequestKey: kRegKey ,kErrorKey:[dictionary objectForKey:kErrorKey]}];
        }
        else
        {
            registreredUser = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"ConnectionStatus" object:nil userInfo:dictionary];
        }
    }
    else if (tag == OPEN_CHANNEL)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"ConnectionStatus" object:nil userInfo:dictionary];
        
        if ([dictionary objectForKey:kErrorKey])
        {
            //!!
        }
        else
        {
//            voiceSocketDictionary = [dictionary objectForKey:kChannelKey];
//            VoiceSocketProcessing *voiceSocket = [[VoiceSocketProcessing alloc]init];
//            [voiceSocket openVoiceTCPSocket: voiceSocketDictionary];
//            [self openVoiceTCPSocket];
        }
    }
    

    
    NSLog(@"HTTP Response:\n%@", httpResponse);
    
}

- (void)registrationRequest
{
    NSError *error;
    NSArray *objects=[[NSArray alloc]initWithObjects:@"registration", [[NSUserDefaults standardUserDefaults]objectForKey:kUserDataKey],nil];
    NSArray *keys=[[NSArray alloc]initWithObjects:@"request", @"user", nil];
    NSDictionary *dict=[NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSLog(@"%@",dict);
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    
    
    [asyncSocket writeData:jsonData withTimeout: 10 tag: REGISTRARTION];
    [asyncSocket readDataWithTimeout: 10 tag: REGISTRARTION];
}


- (void)openChannelRequest
{
    NSError *error = nil;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:@{kRequestKey: @"channel_open"} options:NSJSONWritingPrettyPrinted error:&error];
    [asyncSocket writeData:jsonData withTimeout:100 tag:OPEN_CHANNEL];
    [asyncSocket readDataWithTimeout:200 tag:OPEN_CHANNEL];
}

- (void)closeChannelRequest
{
    NSError *error = nil;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:@{kRequestKey: @"channel_close"} options:NSJSONWritingPrettyPrinted error:&error];
    [asyncSocket writeData:jsonData withTimeout:10 tag:CLOSE_CHANNEL];
//    [asyncSocket readDataWithTimeout:200 tag:CLOSE_CHANNEL];
}

- (void)votingRequest: (NSString *)answer
{
    NSError *error = nil;
    NSLog(@"%@", @{kRequestKey: kVoteKey, kUUIDKey: [votingDictionary objectForKey:kUUIDKey], kAnswerKey: answer});
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:@{kRequestKey: kVoteKey, kUUIDKey: [votingDictionary objectForKey:kUUIDKey], kAnswerKey: answer} options:NSJSONWritingPrettyPrinted error:&error];
    [asyncSocket writeData:jsonData withTimeout:10 tag:VOTING];
    [asyncSocket readDataWithTimeout:20 tag:VOTING];
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    
}


//- (void)openVoiceTCPSocket
//{
//    dispatch_queue_t globalQueue = dispatch_get_main_queue(); //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); //dispatch_get_main_queue();
//    
//    voiceAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:globalQueue];
//    
//    NSString *host = voiceSocketDictionary[kHostKey];
//    uint16_t port = [voiceSocketDictionary[kPortKey] integerValue];
//    
//    
//    NSError *error = nil;
//    if (![voiceAsyncSocket connectToHost:host onPort:port error:&error])
//    {
//        NSLog(@"Error connecting: %@", error);
//    }
//    
//    
//}




@end
