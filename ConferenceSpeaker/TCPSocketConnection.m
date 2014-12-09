//
//  TCPSocketConnection.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "TCPSocketConnection.h"
#import "ServerDataProcessing.h"

#define ENABLE_BACKGROUNDING  0

@implementation TCPSocketConnection
{
    GCDAsyncSocket *connectSocket;
}

+ (TCPSocketConnection *)sharedModel
{
    static dispatch_once_t once;
    static TCPSocketConnection *sharedModel = nil;
    dispatch_once(&once, ^{
        sharedModel = [[self alloc]init];
    });
    return sharedModel;
}

-(instancetype)initWithConnectTo:(NSString*)host andPort:(UInt32)port
{
    self = [super init];
    if (self)
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
        
        NSError *error = nil;
        if (![asyncSocket connectToHost:host onPort:port error:&error])
        {
            NSLog(@"Error connecting: %@", error);
        }
    }
    return self;
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
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
}

- (void)writeData: (NSData *)jsonData
{
    [connectSocket writeData:jsonData withTimeout: 100 tag:1];
    [connectSocket readDataWithTimeout: 100 tag:2];
}

- (void)tcpSocketRead
{
    [asyncSocket readDataWithTimeout: 10 tag:2];
}



- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);

}


@end
