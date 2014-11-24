//
//  UDPSocketConnection.h
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@interface UDPSocketConnection : NSObject
{
    long tag;
    GCDAsyncUdpSocket *udpSocket;
}

+ (UDPSocketConnection *)sharedModel;

@end
