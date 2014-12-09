//
//  VoiceSocketProcessing.h
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 24.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@interface VoiceSocketProcessing : NSObject
- (instancetype) initWithHost: (NSString*) host andPort: (UInt32) port;
- (void)start;
- (void)terminate;
@end
