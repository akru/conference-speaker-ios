//
//  UserDataViewController.m
//
//  Created by Elena Alekseenko on 18.11.14.
//

#import "UserDataViewController.h"
#import "MEDynamicTransition.h"
#import "UIViewController+ECSlidingViewController.h"
#import "ServerDataProcessing.h"

@interface UserDataViewController ()
{
    NSUserDefaults *defs;
}
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@end

@implementation UserDataViewController

- (void)navButtonSetup {
    UIImage *buttonImage = [UIImage imageNamed:@"back_button"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 132, 40);
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
}

- (void)loadSettings {
    NSDictionary *userData = [defs valueForKey:kUserDataKey];
    if (userData)
    {
        [nameTextField setText:[userData objectForKey:kNameKey]];
        [companyTextField setText:[userData objectForKey:kCompanyKey]];
        [rankTextFiled setText:[userData objectForKey:kTitleKey]];
        NSLog(@"UserData loaded: %@", userData);
    }
}

- (void)saveSettings {
    //create dictionary of user data
    NSString *name = [nameTextField.text length]?nameTextField.text:kUnknownKey;
    NSString *company = [companyTextField.text length]?companyTextField.text:kUnknownKey;
    NSString *rank = [rankTextFiled.text length]?rankTextFiled.text:kUnknownKey;
    
    NSDictionary *userDictionary = @{kNameKey : name,
                                     kCompanyKey : company,
                                     kTitleKey : rank};
    NSLog(@"UserData saved %@", userDictionary);
    
    [defs setObject:userDictionary forKey:kUserDataKey];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    [self loadSettings];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *placeholderColor = [UIColor whiteColor];
    
    nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:nameTextField.placeholder attributes:@{NSForegroundColorAttributeName: placeholderColor,  NSFontAttributeName : nameTextField.font}];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [nameTextField setLeftViewMode:UITextFieldViewModeAlways];
    [nameTextField setLeftView:spacerView];
//
    companyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:companyTextField.placeholder attributes:@{NSForegroundColorAttributeName: placeholderColor,  NSFontAttributeName : companyTextField.font}];
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [companyTextField setLeftViewMode:UITextFieldViewModeAlways];
    [companyTextField setLeftView:spacerView2];
//
    rankTextFiled.attributedPlaceholder = [[NSAttributedString alloc] initWithString:rankTextFiled.placeholder attributes:@{NSForegroundColorAttributeName: placeholderColor,  NSFontAttributeName : rankTextFiled.font}];
    UIView *spacerView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [rankTextFiled setLeftViewMode:UITextFieldViewModeAlways];
    [rankTextFiled setLeftView:spacerView3];
    
    defs = [[ServerDataProcessing sharedModel] settings];
    [self navButtonSetup];
    [self loadSettings];
}

- (void)back {
    [self saveSettings];
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
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
    [self saveSettings];
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

//- (void) drawPlaceholderInRect:(CGRect)rect {
//    [[UIColor blueColor] setFill];
//    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:16]];
//}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end
