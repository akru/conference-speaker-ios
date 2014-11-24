//
//  UDPSocketConnection.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "UDPSocketConnection.h"

#define UDP_PORT 35000

@implementation UDPSocketConnection

+ (UDPSocketConnection *)sharedModel
{
    static dispatch_once_t once;
    static UDPSocketConnection *sharedModel = nil;
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
        [self setupSocket];
    }
    return self;
    
}

- (void)setupSocket
{
    // Setup our socket.
    // The socket will invoke our delegate methods using the usual delegate paradigm.
    // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
    //
    // Now we can configure the delegate dispatch queues however we want.
    // We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
    // Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
    //
    // The best approach for your application will depend upon convenience, requirements and performance.
    //
    // For this simple example, we're just going to use the main thread.
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    NSError *error = nil;
    
    if (![udpSocket bindToPort:UDP_PORT error:&error])
    {
        
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
     NSLog(@"Ready");
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (msg)
    {
        NSLog(@"RECV: %@", msg);
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
    }
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
