//
//  ProgramViewController.m
//  ConferenceSpeaker
//
//  Created by Elena Alekseenko on 23.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "ProgramViewController.h"
#import "MEDynamicTransition.h"
#import "UIViewController+ECSlidingViewController.h"
@interface ProgramViewController ()

@end

@implementation ProgramViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *buttonImage = [UIImage imageNamed:@"back_button"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 132, 40);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)back {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

@end
