//
//  VoiceSocketProcessing.h
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 24.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface VoiceSocketProcessing : NSObject


- (void)openVoiceTCPSocket: (NSDictionary *)voiceSocketDictionary;
- (void)sendVoice;
@end
