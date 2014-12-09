//
//  ConferenceViewController.h
//  ConferenceSpeaker
//
//  Created by Елена on 18.11.14.
//  Copyright (c) 2014 Elena Alekseenko. All rights reserved.


#import "ConferenceViewController.h"
#import "UDPSocketConnection.h"
#import "ServerDataProcessing.h"

#import "UIViewController+ECSlidingViewController.h"
#import "MEDynamicTransition.h"
#import "METransitions.h"
#import "MEZoomAnimationController.h"

#import "VoiceSocketProcessing.h"

typedef NS_ENUM (NSUInteger, StatusType) {
    kRegisteredStatus,
    kOpenSessionStatus,
    kRequestSessionStatus
};


@interface ConferenceViewController ()
{
    MEZoomAnimationController *_zoomAnimationController;
    ServerDataProcessing      *serverDataProcessing;
    VoiceSocketProcessing     *voiceProcessing;
    StatusType                 currentStatus;
}
@property (nonatomic, strong) METransitions *transitions;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation ConferenceViewController

#pragma mark - UIViewController
- (void)navButtonSetup {
    UIImage *buttonImage = [UIImage imageNamed:@"back_button"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 132, 40);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [udpSocket close];
    [self setupSocket];
    
    serverDataProcessing = [ServerDataProcessing sharedModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    handButton.userInteractionEnabled = NO;
    
    
    self.transitions.dynamicTransition.slidingViewController = self.slidingViewController;
    
    _zoomAnimationController = [[MEZoomAnimationController alloc] init];
    self.slidingViewController.delegate =  _zoomAnimationController;
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGestureTapping | ECSlidingViewControllerAnchoredGesturePanning;
    self.slidingViewController.customAnchoredGestures = @[];
    [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [self navButtonSetup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInterfaceWithConnectionStatus:)
                                                 name:@"ConnectionStatus"
                                               object:nil];
}

- (void)back {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkWiFiConnection];
//    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
}

#pragma mark - Properties


- (UIPanGestureRecognizer *)dynamicTransitionPanGesture
{
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}


- (IBAction)menuButtonTapped:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

#pragma mark - Reachability

- (BOOL)checkWiFiConnection
{
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
//    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    [self updateInterfaceWithReachability:reachability];
    return YES;
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability: (Reachability *)currentReachability
{
//    NetworkStatus netStatus = [reachability currentReachabilityStatus];
//    NSString* statusString = @"";
    
//    if((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWiFi))
//    {
        [self updateInterfaceWithConnectionStatus:nil];
        
//    }
//    else
//    {
//        statusString = NSLocalizedString(@"ПОДКЛЮЧИТЕСЬ К\n WI-FI", @"Text field text for access is not available");
//        wifiImageView.image = [UIImage imageNamed:@"inactive_wifi"];
//        statusConnectImageView.image = [UIImage imageNamed:@"inactive_connection"];
//        handButton.userInteractionEnabled = NO;
//        statusLabel.text = statusString;
//        
//    }
    
}


- (void)updateInterfaceWithConnectionStatus:(NSNotification *) notification
{
    NSUserDefaults *userDef = [serverDataProcessing settings];
    NSString* statusString  = @"";
    
    
    if (notification) {
        NSDictionary *nDictionary = notification.userInfo;
        
        if ([[nDictionary objectForKey:kResultKey] isEqualToString:kErrorKey]) {
            if ([[nDictionary objectForKey: kRequestKey]  isEqualToString:@"channel_open"])
            {
                statusString = [NSString stringWithFormat:@"ИЗВИНИТЕ, ВАШ \n ЗАПРОС ОТКЛОНЕН!"];
                handButton.imageView.image = [UIImage imageNamed:@"inactive_hand"];
                currentStatus = kRegisteredStatus;
                statusLabel.text = statusString;
            }
            return;
        }
        
        if ([[nDictionary objectForKey: kRequestKey]  isEqualToString:kRegKey])
        {
            statusString = [NSString stringWithFormat:@"ПОДКЛЮЧЕН К СЕРВЕРУ \n %@", [userDef objectForKey: kSelectedServerKey]];
            handButton.userInteractionEnabled = YES;
            currentStatus = kRegisteredStatus;
            
        }
        else if ([[nDictionary objectForKey: kRequestKey]  isEqualToString:@"channel_open"])
        {
            
            statusString = [NSString stringWithFormat:@"МИКРОФОН ВАШ"];
            handButton.userInteractionEnabled = YES;
            handButton.imageView.image = [UIImage imageNamed:@"close_connect_btn"];
            wifiImageView.image = [UIImage imageNamed:@"active_micro"];
            currentStatus = kOpenSessionStatus;
//            [self initRecord];
//            [self startRecord];
            NSDictionary *channel = [nDictionary objectForKey:kChannelKey];
            NSString       *host  = [channel objectForKey:kHostKey];
            NSString       *port = [channel objectForKey:kPortKey];
            voiceProcessing = [[VoiceSocketProcessing alloc]
                                    initWithHost:host
                                    andPort:[port integerValue]];
            [voiceProcessing start];
        }
    }
    else
    {
        //init settings
        NSArray *serversArray = [serverDataProcessing serverNameArray];
        
        if ([serversArray count] == 1) {
            [userDef setObject:[serversArray objectAtIndex:0] forKey:kSelectedServerKey];
        }

        if ([userDef objectForKey:kUserDataKey] && [userDef objectForKey:kSelectedServerKey])
        {
            statusString = @"ПОДКЛЮЧЕНИЕ К СЕРВЕРУ";
            wifiImageView.image = [UIImage imageNamed:@"inactive_micro"];
            //send reqistrartion request
            [serverDataProcessing connect];
            [serverDataProcessing registrationRequest];

        }
        else if ([userDef objectForKey:kSelectedServerKey])
        {
            statusString = @"ЗАПОЛНИТЕ ДАННЫЕ О СЕБЕ";
            wifiImageView.image = [UIImage imageNamed:@"active_wifi"];
        }
        else if ([userDef objectForKey:kUserDataKey])
        {
            statusString = @"ВЫБЕРИТЕ СЕРВЕР";
            wifiImageView.image = [UIImage imageNamed:@"active_wifi"];
        }
        else
        {
            statusString = @"ЗАПОЛНИТЕ ДАННЫЕ О СЕБЕ \n И ВЫБЕРИТЕ СЕРВЕР";
            wifiImageView.image = [UIImage imageNamed:@"active_wifi"];
        }
        
    }
    statusLabel.text = statusString;
    
}


- (void)handButtonTapped:(id)sender
{
    switch (currentStatus) {
        case kRegisteredStatus:
            statusLabel.text = @"ОЖИДАНИЕ ПОДТВЕРЖДЕНИЯ";
            handButton.imageView.image = [UIImage imageNamed:@"active_hand"];
            [serverDataProcessing openChannelRequest];
            break;
        case kOpenSessionStatus:
            [voiceProcessing terminate];
            currentStatus = kRegisteredStatus;
        case kRequestSessionStatus:
            statusLabel.text = @"ПОДКЛЮЧЕН К СЕРВЕРУ";
            handButton.imageView.image = [UIImage imageNamed:@"inactive_hand"];
            [serverDataProcessing closeChannelRequest];
            break;
        default:
            break;
    }
}



- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ConnectionStatus"
                                                  object:nil];
    [udpSocket close];
    
}


/*UDP SOCKET*/

- (void)setupSocket
{
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    
    NSError *error = nil;
    
    if (![udpSocket bindToPort:UDP_PORT error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"Ready");
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (msg)
    {
        //!! может в фоне? - там немного и так пойдет
        [serverDataProcessing udpServerData:data];
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
    }
}

#pragma mark - show Voting alert
- (void) showVotingAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Новое голосование"
                                                    message: @"Перейдите в раздел меню: Голосование"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
