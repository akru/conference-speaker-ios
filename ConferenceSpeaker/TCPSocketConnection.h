//
//  TCPSocketConnection.h
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 20.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface TCPSocketConnection : NSObject
{
    GCDAsyncSocket *asyncSocket;
}

+ (TCPSocketConnection *)sharedModel;

@end
