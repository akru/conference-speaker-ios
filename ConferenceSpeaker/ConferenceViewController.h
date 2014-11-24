//
//  ConferenceViewController.h
//  ConferenceSpeaker
//
//  Created by Елена on 18.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "Reachability.h"
#import "GCDAsyncUdpSocket.h"
#import <AVFoundation/AVFoundation.h>

@interface ConferenceViewController : UIViewController <ECSlidingViewControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    Reachability *reachability;
    IBOutlet UILabel *statusLabel;
    GCDAsyncUdpSocket *udpSocket;
    
    IBOutlet UIImageView *wifiImageView;
    IBOutlet UIImageView *statusConnectImageView;
    IBOutlet UIButton *handButton;
    
    
}
- (IBAction)menuButtonTapped:(id)sender;
- (IBAction)handButtonTapped:(id)sender;


@end
