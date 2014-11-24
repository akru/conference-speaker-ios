//
//  VoiceSocketProcessing.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 24.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "VoiceSocketProcessing.h"

@implementation VoiceSocketProcessing
{
    GCDAsyncSocket *voiceAsyncSocket;
}


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
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
    NSLog(@"read");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    
}

- (void)openVoiceTCPSocket: (NSDictionary *)voiceSocketDictionary
{
    dispatch_queue_t globalQueue = dispatch_get_main_queue();
    
    voiceAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue: globalQueue];
    NSString *host = voiceSocketDictionary[kHostKey];
    uint16_t port = [voiceSocketDictionary[kPortKey] integerValue];
    
    
    NSError *error = nil;
    if (![voiceAsyncSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
}

- (void)sendVoice
{
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo",
                               nil];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPathComponents:pathComponents]];
    [voiceAsyncSocket writeData:data withTimeout:10 tag:1];
}
@end
