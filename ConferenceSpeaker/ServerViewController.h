//
//  VotingViewController.h
//  ConferenceSpeaker
//
//  Created by Елена on 18.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>


@property (weak, nonatomic) IBOutlet UIPickerView *picker;

- (IBAction)menuButtonTapped:(id)sender;


@end
