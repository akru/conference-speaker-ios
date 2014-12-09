//
//  VotingViewController.m
//  ConferenceSpeaker
//
//  Created by Елена on 18.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "ServerViewController.h"
#import "MEDynamicTransition.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ServerDataProcessing.h"

@interface ServerViewController ()
{
    NSArray *_pickerData;
}

@end

@implementation ServerViewController

- (void)navButtonSetup {
    UIImage *buttonImage = [UIImage imageNamed:@"back_button"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 132, 40);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
}

- (void)saveSelectedServer {
    NSUInteger selectedRow = [self.picker selectedRowInComponent:0] ;
    NSString *selectedServer = [_pickerData objectAtIndex:selectedRow];
    
    [[[NSUserDefaults alloc] initWithSuiteName:@"ConferenceSpeaker"]
        setObject:selectedServer
           forKey:kSelectedServerKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ServerDataProcessing *serverDataProcessing = [ServerDataProcessing sharedModel];
    
    _pickerData = [[serverDataProcessing serverNameArray] mutableCopy];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    // Do any additional setup after loading the view.
    [self navButtonSetup];
}

- (void)back {
    [self saveSelectedServer];
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (IBAction)menuButtonTapped:(id)sender
{
    [self saveSelectedServer];
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}



@end
