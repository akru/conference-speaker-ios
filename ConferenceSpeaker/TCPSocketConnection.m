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



-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupTCPSocket];
    }
    return self;
    
}
-(void)setupTCPSocket
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSString *host = @"192.168.0.104";
    uint16_t port = 35001;
    
    
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
    

}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    connectSocket = sock;
    //	DDLogInfo(@"localHost :%@ port:%hu", [sock localHost], [sock localPort]);
    


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
    

//    NSError *error;
//    NSDictionary *setUser = [NSDictionary
//                             dictionaryWithObjectsAndKeys:@"name",@"name",
//                             @"company",@"company",
//                             @"myTitle",@"title",
//                             nil];
//    NSArray *objects=[[NSArray alloc]initWithObjects:@"registration", setUser,nil];
//    NSArray *keys=[[NSArray alloc]initWithObjects:@"request", @"user", nil];
//    NSDictionary *dict=[NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    NSLog(@"%@",dict);
//    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    
//    
//    
//    [sock writeData:jsonData withTimeout: 10 tag:1];
//    [sock readDataWithTimeout: 10 tag:2];

    
}

//- (void)socketDidSecure:(GCDAsyncSocket *)sock
//{
//    DDLogInfo(@"socketDidSecure:%p", sock);
//    self.viewController.label.text = @"Connected + Secure";
    
//    NSString *requestStr = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\n\r\n", HOST];
//    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    [sock writeData:requestData withTimeout:-1 tag:0];
//    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
//}


- (void)writeData: (NSData *)jsonData
{
    [connectSocket writeData:jsonData withTimeout: 100 tag:1];
    [connectSocket readDataWithTimeout: 100 tag:2];
}

- (void)tcpSocketRead
{
    [asyncSocket readDataWithTimeout: 10 tag:2];
}



- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"HTTP Response:\n%@", httpResponse);
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);

}


@end
