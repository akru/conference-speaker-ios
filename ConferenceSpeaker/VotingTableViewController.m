//
//  ServerTableViewController.m
//  ConferenceSpeaker
//
//  Created by Елена on 18.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.
//

#import "VotingTableViewController.h"
#import "MEDynamicTransition.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ServerDataProcessing.h"

@interface VotingTableViewController ()
{
    ServerDataProcessing *serverDataProcessing;
    NSInteger countRows;
    NSDictionary *votingDictionary;
}
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic, strong) NSArray *votingItems;
@end

@implementation VotingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"conf_background"]]];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.delegate = self;
    
    serverDataProcessing = [ServerDataProcessing sharedModel];
    
    
    votingDictionary = [serverDataProcessing voteDictionary];
    if ([[votingDictionary objectForKey:kModeKey] isEqualToString: @"simple"])
    {
        _votingItems = [NSArray arrayWithObjects:@"ДА", @"НЕТ", nil] ;
        
    }
    else
    {
        _votingItems = [votingDictionary objectForKey: kAnswersKey];
        
    }
    countRows = [_votingItems count]+2;
    NSLog(@"%@", _votingItems);

    
//    _serverItems = @[@"Server 1", @"Server 2", @"Server 3", @"Server 4"];
    

    [self menuSettings];

    

    // Uncomment the following line to preserve selection between presentations.
//    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return countRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ServerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = [votingDictionary objectForKey:kQuestionKey];
        cell.textLabel.textColor  = [UIColor colorWithRed:24.0/255.0 green:48.0/255.0 blue:68.0/255.0 alpha:1];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.userInteractionEnabled = NO;
        
    }
    else if (indexPath.row >0 && indexPath.row < countRows-1) {
        
        cell.textLabel.text = _votingItems[indexPath.row - 1];
//        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield_bg"]];
        cell.userInteractionEnabled = YES;
    }
    else if (indexPath.row == countRows-1)
    {
        cell.textLabel.text = @"ПРОГОЛОСОВАТЬ";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        imgView.image = [UIImage imageNamed:@"button_bg"];
        
        cell.backgroundView = imgView;
        cell.userInteractionEnabled = NO;
    }
    
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *answer;
    if ([[votingDictionary objectForKey:kModeKey] isEqualToString: @"simple"])
    {
        if (indexPath.row == 1) {
            answer = @"true";
        }
        else
            answer = @"false";
        
    }
    else
    {
        answer = [NSString stringWithFormat:@"%ld", (long)indexPath.row ];
    }
    [serverDataProcessing votingRequest:answer];
}


- (IBAction)menuButtonTapped:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)menuSettings
{
    if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
        MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
        if (!self.dynamicTransitionPanGesture) {
            self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
        }
        
        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.navigationController.view addGestureRecognizer:self.dynamicTransitionPanGesture];
    } else {
        [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
}



@end
