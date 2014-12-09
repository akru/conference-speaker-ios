//
//  VoiceSocketProcessing.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 24.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "VoiceSocketProcessing.h"
#import "Novocaine.h"

@implementation VoiceSocketProcessing
{
    Novocaine         *audio;
    GCDAsyncUdpSocket *asyncSocket;
    NSString *_host;
    UInt32    _port;
}

- (instancetype)initWithHost:(NSString *)host andPort:(UInt32)port
{
    self = [super init];
    if (self) {
        asyncSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                    delegateQueue:dispatch_get_main_queue()];
        _host = host;
        _port = port;
        
        audio = [Novocaine audioManager];
        AudioStreamBasicDescription f = [audio inputFormat];
        NSLog(@"Format: c: %i w:%i sr: %f fs: %i", f.mChannelsPerFrame, f.mBitsPerChannel, f.mSampleRate, f.mBytesPerFrame);
        [audio setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
            short monoLength = numFrames / numChannels / 2;
            SInt16 *buf = calloc(monoLength, sizeof(SInt16));
            SInt16 *buf_p = buf;
            short step = numChannels == 1 ? 2 : 4; // Dummy resampler & deInterleave
            for (short i = 0; i < monoLength; ++i) {
                *buf_p++ = (data[step*i] * 30000);
            }
            // Send data
            [self->asyncSocket sendData: [[NSData alloc] initWithBytes:buf
                                                                length:monoLength*sizeof(SInt16)]
                                 toHost:_host
                                   port:_port
                            withTimeout:-1
                                    tag:0];
            free(buf);
        }];
    }
    return self;
}

- (void)start
{
    [audio play];
}

- (void)terminate
{
    [audio pause];
    [asyncSocket close];
}

- (void)socket:(GCDAsyncUdpSocket *)sock didWriteDataWithTag:(long)tag
{
//    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

@end
