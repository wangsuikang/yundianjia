//
//  UpdatePasswordViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-12-10.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "UpdatePasswordViewController.h"

//class
#import "LoginTextField.h"
#import "Tool.h"
#import "AppDelegate.h"

//Common
#import "AFNetworking.h"
#import "LibraryHeadersForCommonController.h"

@interface UpdatePasswordViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) UIButton *update;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation UpdatePasswordViewController


#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = [UIColor whiteColor];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"密码管理";
        
        self.navigationItem.titleView = naviTitle;
        
        _password = @"";
    }
    return self;
}


#pragma mark - UIView Functions -

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.alpha = 0.0;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        
        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *list=self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.alpha = 1.0;
            }];
        }
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, kScreenHeight + 64)];
    backgroundView.image = [UIImage imageNamed:@"admin_login_background"];
    
    [self.view addSubview:backgroundView];
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, kCustomNaviHeight + 10, kScreenWidth - 24, 16)];
    inputLabel.backgroundColor = kClearColor;
    inputLabel.font = kNormalFont;
    inputLabel.text = @"新的登录密码";
    inputLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:inputLabel];
    
    LoginTextField *inputText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 36, kScreenWidth - 20, 30) leftViewImage:@"login_password"];
    inputText.placeholder = @"请输入6-16位新密码";
    inputText.secureTextEntry = YES;
    inputText.delegate = self;
    inputText.text = @"";
    inputText.layer.borderColor = [UIColor orangeColor].CGColor;
//    inputText.layer.borderWidth = 1;
    inputText.layer.cornerRadius = 6;
    inputText.layer.masksToBounds = YES;
//    [inputText.placeholder drawInRect:nil withAttributes:@{NSFontAttributeName:kNormalFont, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [inputText addTarget:self action:@selector(textWithInput:) forControlEvents:UIControlEventEditingChanged];
    [inputText setLine];
    
    [self.view addSubview:inputText];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [inputText becomeFirstResponder];
    });
    
    _update = [[UIButton alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 96, kScreenWidth - 20, 40)];
    _update.layer.cornerRadius = 6;
    _update.layer.masksToBounds = YES;
    _update.backgroundColor = [UIColor orangeColor];
    [_update setTitle:@"修改密码" forState:UIControlStateNormal];
    [_update setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_update addTarget:self action:@selector(updatePassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_update];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textWithInput:(UITextField *)textField
{
    _password = textField.text;
}

- (void)updatePassword:(UIButton *)sender
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if ([_password length] < 6) {
        [_hud addErrorString:@"请输入6-16位新密码" delay:5.0];
        
        return;
    }
    
    sender.enabled = NO;
    sender.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
    
    NSString *updateURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kUpdatePasswordURL params:nil];
    
    YunLog(@"update password url = %@", updateURL);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"password"                :   kNullToString(_password),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    YunLog(@"update password params = %@", params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager PUT:updateURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"update password responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode])
        {
            [_hud addSuccessString:@"密码已修改" delay:2.0];
            
            [self backToPrev];
        }
        else if ([code isEqualToString:kUserSessionKeyInvalidCode])
        {
            [Tool resetUser];
            
            [self backToPrev];
        }
        else
        {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
            
            sender.enabled = YES;
            sender.backgroundColor = [UIColor orangeColor];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"update password error = %@", error);
        
        [_hud addErrorString:@"网络繁忙，请稍后再试" delay:2.0];
        
        sender.enabled = YES;
        sender.backgroundColor = [UIColor orangeColor];
    }];
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updatePassword:_update];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    
    NSString *aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([aString length] > 16)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"密码最长为16位" delay:2.0];
        
        return NO;
    }
    return YES;
}

@end
