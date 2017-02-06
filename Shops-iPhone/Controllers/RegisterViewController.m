//
//  RegisterViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-21.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "RegisterViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"

// Controlers
#import "SaleAccedeViewController.h"

// Views
#import "LoginTextField.h"

// Controllers
#import "WebViewController.h"

// Libraries
#import "AFNetworking.h"
#import "UnderLineLabel.h"

typedef NS_ENUM(NSInteger, RegisterTextField) {
    RegisterPhone = 201,
    RegisterPassword,
    RegisterVerifyCode
};

@interface RegisterViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *verifyCode;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int verifyCodeCount;

@property (nonatomic, strong) UIButton *verifyCodeButton;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation RegisterViewController


#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = [UIColor whiteColor];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"注册云账号";
        
        self.navigationItem.titleView = naviTitle;
        
        _phone = @"";
        _password = @"";
        _verifyCode = @"";
        
        _verifyCodeCount = 61;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resetVerifyCode) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return self;
}


#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = kBackgroundColor;
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
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
    //    [TalkingData trackPageEnd:@"离开注册页面"];
    
    [super viewWillDisappear:animated];
    
    NSArray *list=self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.alpha = 1.0;
            }];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    self.view.backgroundColor = kBackgroundColor;
//    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, kScreenHeight + 64)];
//    backgroundView.image = [UIImage imageNamed:@"admin_login_background_new"];
//    
//    [self.view addSubview:backgroundView];
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(0, 0, 25, 25);
//    [button setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
//    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    backItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.leftBarButtonItem = backItem;
//    
//    for (int i = 0; i < 3; i++) {
//        LoginTextField *textField = [[LoginTextField alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 10 + i * 50, kScreenWidth - 20, 40)];
//        textField.delegate = self;
//        textField.text = @"";
//        [textField addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
//        
//        if (i == 2) {
//            CGFloat width = (kScreenWidth - 20) / 2 - 10;
//            textField.placeholder = @"请输入验证码";
//            textField.frame = CGRectMake(10, kCustomNaviHeight + 10 + i * 50, width, 40);
//            textField.keyboardType = UIKeyboardTypeNumberPad;
//            textField.tag = RegisterVerifyCode;
//            textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_verify"]];
//        } else if (i == 1) {
//            textField.secureTextEntry = YES;
//            textField.placeholder = @"请输入6-16位密码";
//            textField.tag = RegisterPassword;
//            textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_password"]];
//        } else if (i == 0) {
//            textField.placeholder = @"请输入手机号";
//            textField.keyboardType = UIKeyboardTypeNumberPad;
//            textField.tag = RegisterPhone;
//            textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_phone"]];
//            
//            double delayInSeconds = 0.5;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [textField becomeFirstResponder];
//            });
//        }
//        
//        [self.view addSubview:textField];
//    }
//    
//    CGFloat width = (kScreenWidth - 20) / 2 - 10;
//    
//    _verifyCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - width - 10, kCustomNaviHeight + 110, width, 40)];
//    _verifyCodeButton.layer.cornerRadius = 6;
//    _verifyCodeButton.layer.masksToBounds = YES;
//    _verifyCodeButton.layer.borderWidth = 1;
//    _verifyCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    [_verifyCodeButton setTitle:@"验证码" forState:UIControlStateNormal];
//    [_verifyCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_verifyCodeButton addTarget:self action:@selector(getVerifyCodeForRegister:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:_verifyCodeButton];
//    
//
//    
////    UnderLineLabel *registerSuf = [[UnderLineLabel alloc] initWithFrame:CGRectMake(95, kCustomNaviHeight + 160, 150, 30)];
////    registerSuf.backgroundColor = kClearColor;
////    registerSuf.textColor = [UIColor orangeColor];
////    registerSuf.shouldUnderline = NO;
////    registerSuf.text = @"云店家平台服务协议";
////    registerSuf.font = kNormalBoldFont;
////    [registerSuf addTarget:self action:@selector(openServiceProtocol)];
////    
////    [self.view addSubview:registerSuf];
//    
//    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 90) / 2, kCustomNaviHeight + 220, 90, 50)];
//    registerButton.layer.cornerRadius = 6;
//    registerButton.layer.masksToBounds = YES;
//    [registerButton setImage:[UIImage imageNamed:@"register_commit"] forState:UIControlStateNormal];
//    
//    [registerButton addTarget:self action:@selector(commitRegister:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:registerButton];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, kScreenHeight + 64)];
    backgroundView.image = [UIImage imageNamed:@"admin_login_background_new"];
    
    [self.view addSubview:backgroundView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(120, 84, kScreenWidth - 240, kScreenWidth - 240)];
    
    if (kScreenWidth == 414) {
        icon.frame = CGRectMake((kScreenWidth - 120) / 2, 84, 120, 120);
    }
    
    if (!kIsiPhone) {
        icon.frame = CGRectMake((kScreenWidth - 150) / 2, 84, 150, 150);
    }
    icon.image = [UIImage imageNamed:@"admin_login_companyicon"];
    
    [self.view addSubview:icon];
    
    for (int i = 0; i < 3; i++) {
        LoginTextField *textField = [[LoginTextField alloc] initWithFrame:CGRectMake(20, kCustomNaviHeight + 20 + icon.frame.size.height + 20 + i * 50, kScreenWidth - 40, 30)];
        textField.delegate = self;
        textField.text = @"";
        [textField setLine];
        [textField addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
        
        if (i == 2) {
            CGFloat width = (kScreenWidth - 40) / 2 - 20;
            textField.placeholder = @"请输入验证码";
            textField.frame = CGRectMake(20, kCustomNaviHeight + 20 + icon.frame.size.height + 20 + i * 50, width + 20, 30);
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.tag = RegisterVerifyCode;
            textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_verify"]];
        } else if (i == 1) {
            textField.secureTextEntry = YES;
            textField.placeholder = @"请输入6-16位密码";
            textField.tag = RegisterPassword;
            textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_password"]];
        } else if (i == 0) {
            textField.placeholder = @"请输入手机号";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.tag = RegisterPhone;
            textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_phone"]];
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [textField becomeFirstResponder];
            });
        }
        
        [self.view addSubview:textField];
    }
    
    CGFloat width = (kScreenWidth - 40) / 2 - 20;
    
    _verifyCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - width - 20, kCustomNaviHeight + 20 + icon.frame.size.height + 10 + 2 * 50, width, 40)];
    _verifyCodeButton.layer.cornerRadius = 6;
    _verifyCodeButton.layer.masksToBounds = YES;
    _verifyCodeButton.layer.borderWidth = 1;
    _verifyCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_verifyCodeButton setTitle:@"验证码" forState:UIControlStateNormal];
    [_verifyCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_verifyCodeButton addTarget:self action:@selector(getVerifyCodeForRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_verifyCodeButton];
    
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_verifyCodeButton.frame) + 20, kScreenWidth - 2 * 20, 40)];
    registerButton.tag = 10010;
    registerButton.backgroundColor = [UIColor whiteColor];
    registerButton.layer.masksToBounds = YES;
    registerButton.layer.cornerRadius = 20;
    //    [passLoginButton setBackgroundImage:[UIImage imageNamed:@"admin_login_button_back"] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(commitRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registerButton];
    
    UILabel *registerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, registerButton.frame.size.width, registerButton.frame.size.height)];
    registerLabel.text = @"创建账号";
    registerLabel.textColor = kOrangeColor;
    registerLabel.font = kFont;
    registerLabel.textAlignment= NSTextAlignmentCenter;
    
    [registerButton addSubview:registerLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self doneEditing];
    
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldWithText:(UITextField *)textField
{
    switch (textField.tag) {
        case RegisterPhone:
            _phone = textField.text;
            break;
            
        case RegisterPassword:
            _password = textField.text;
            break;
            
        case RegisterVerifyCode:
            _verifyCode = textField.text;
            break;
            
        default:
            break;
    }
}

- (void)getVerifyCodeForRegister:(UIButton *)sender
{
    NSString *regexString = @"(^1(3[5-9]|47|5[012789]|8[23478])\\d{8}$|134[0-8]\\d{7}$)|(^18[019]\\d{8}$|1349\\d{7}$)|(^1(3[0-2]|45|5[56]|8[56]|7[0-9])\\d{8}$)|(^1[35]3\\d{8}$)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    
    NSTextCheckingResult *result = [regex firstMatchInString:_phone options:0 range:NSMakeRange(0, [_phone length])];
    
    if (!result) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请输入正确的手机号" delay:1.0];
    } else {
        sender.enabled = NO;
        sender.backgroundColor = COLOR(196, 196, 196, 1);
        sender.backgroundColor = COLOR(147, 147, 147, 1);
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        NSString *verifyURL = [Tool buildRequestURLHost:kRequestHost
                                             APIVersion:kAPIVersion1
                                             requestURL:kCreatePhoneCodeURL
                                                 params:nil];
        
        AppDelegate *appDelegate = kAppDelegate;
        
        NSDictionary *params = @{@"phone"                   :   kNullToString(_phone),
                                 @"phone_code_type"         :   @"sign_up",
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager PUT:verifyURL
          parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"get verify code responseObject = %@", responseObject);
                 
                 NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
                 if ([code isEqualToString:kSuccessCode]) {
                     [_hud addSuccessString:@"验证码已成功发送" delay:2.0];
                     
                     [_timer setFireDate:[NSDate distantPast]];
                 } else {
                     [_hud addErrorString:@"系统繁忙,请稍后再试" delay:2.0];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 YunLog(@"get verify code error = %@", error);
                 
                 sender.enabled = YES;
                 sender.backgroundColor = COLOR(147, 147, 147, 1);
                 
                 [_hud addErrorString:@"系统异常,请稍后再试" delay:2.0];
             }];
    }
}

- (void)commitRegister:(UIButton *)sender
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    YunLog(@"phone = %@, password = %@, verifyCode = %@", _phone, _password, _verifyCode);
    
    NSString *regexString = @"(^1(3[5-9]|47|5[012789]|8[23478])\\d{8}$|134[0-8]\\d{7}$)|(^18[019]\\d{8}$|1349\\d{7}$)|(^1(3[0-2]|45|5[56]|8[56]|7[0-9])\\d{8}$)|(^1[35]3\\d{8}$)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    
    NSTextCheckingResult *result = [regex firstMatchInString:_phone options:0 range:NSMakeRange(0, [_phone length])];
    
    if (!result) {
        [_hud addErrorString:@"请输入正确的手机号" delay:1.0];
        
        return;
    }
    
    if ([_password isEqualToString:@""]) {
        [_hud addErrorString:@"请输入6-16位密码" delay:1.0];
        
        return;
    } else if ([_password length] < 6) {
        [_hud addErrorString:@"请输入6-16位密码" delay:1.0];
        
        return;
    } else if ([_verifyCode isEqualToString:@""]) {
        [_hud addErrorString:@"请输入验证码" delay:1.0];
        
        return;
    }
    
    sender.enabled = NO;
    
    _hud.labelText = @"注册...";
    
    NSString *loginURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kSignUpURL params:nil];
    
    YunLog(@"loginURL = %@", loginURL);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"phone"                   :   kNullToString(_phone),
                             @"password"                :   kNullToString(_password),
                             @"phone_code"              :   kNullToString(_verifyCode),
                             @"phone_code_type"         :   @"sign_up",
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:loginURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"register responseObject = %@", responseObject);
              
              NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
              if ([code isEqualToString:kSuccessCode]) {
                  AppDelegate *appDelegate = kAppDelegate;
                  
                  NSDictionary *userDic = [[responseObject objectForKey:@"data"] objectForKey:@"user"];
                  
                  appDelegate.user.username = [userDic objectForKey:@"name"];
                  appDelegate.user.password = _password;
                  appDelegate.user.phone = [userDic objectForKey:@"phone"];
                  appDelegate.user.userType = [[userDic objectForKey:@"user_type"] integerValue];
                  appDelegate.user.userSessionKey = [userDic objectForKey:@"user_session_key"];
                  appDelegate.user.display_name = [userDic objectForKey:@"display_name"];
                  appDelegate.login = YES;
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  
                  [defaults setObject:kNullToString([userDic objectForKey:@"name"]) forKey:@"username"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"user_session_key"]) forKey:@"user_session_key"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"name"]) forKey:@"lastContactPhone"];
                  [defaults setObject:kNullToString([[userDic objectForKey:@"user_type"] stringValue]) forKey:@"userType"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"display_name"]) forKey:@"display_name"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"birthday"]) forKey:@"birthday"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"nickname"]) forKey:@"nickname"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"phone"]) forKey:@"phone"];
                  
                  [defaults synchronize];
                  
                  _phone = @"";
                  _password = @"";
                  _verifyCode = @"";
                  
                  [_hud addSuccessString:@"注册成功" delay:2.0];
                  
                  [self returnView];
                  
              } else {
                  NSString *message = [[responseObject objectForKey:@"status"] objectForKey:@"message"];
                  YunLog(@"register error message = %@", message);
                  
                  if ([message isEqual:[NSNull null]] || [message isEqualToString:@""]) {
                      [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
                  } else {
                      [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
                  }
                  
                  sender.enabled = YES;
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              YunLog(@"register error = %@", error);
              
              [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
              sender.enabled = YES;
          }
     ];
}

- (void)returnView
{
    [self doneEditing];
    
    if (_hud) [_hud hide:NO];
    if (_isSaleChoose == YES) {
        SaleAccedeViewController *saleVC = [[SaleAccedeViewController alloc] init];
        
        [self.navigationController presentViewController:saleVC animated:YES completion:nil];
    } else {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)openServiceProtocol
{
    WebViewController *web = [[WebViewController alloc] init];
    web.hidesBottomBarWhenPushed = YES;
    web.naviTitle = @"服务协议";
    web.url = kClauseURL;
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)resetVerifyCode
{
    if (_verifyCodeCount == 1) {
        [_timer setFireDate:[NSDate distantFuture]];
        
        _verifyCodeButton.enabled = YES;
        _verifyCodeButton.backgroundColor = kBackgroundColor;
        [_verifyCodeButton setTitleColor:COLOR(147, 147, 147, 1) forState:UIControlStateNormal];
        [_verifyCodeButton setTitle:@"验证码" forState:UIControlStateNormal];
        
        _verifyCodeCount = 61;
    } else {
        _verifyCodeCount -= 1;
        
        [_verifyCodeButton setTitle:[NSString stringWithFormat:@"验证码 %u", _verifyCodeCount] forState:UIControlStateNormal];
    }
}

- (void)keyboardWillShowForRegisterNumberPad
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // 找到键盘view
        UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        
        UIView *keyboard;
        
        for (int i = 0; i < [tempWindow.subviews count]; i++){
            keyboard = [tempWindow.subviews objectAtIndex:i];
            
            // 找到键盘view并加入“Done”按钮
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] || [[keyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
                CGFloat marginTop = keyboard.frame.origin.y - 30;
                
                if (kDeviceOSVersion < 7.0) {
                    marginTop -= 64;
                }
                
                if (!_dismissButton) {
                    _dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, marginTop, kScreenWidth, 30)];
                    _dismissButton.backgroundColor = [UIColor whiteColor];
                    [_dismissButton addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [self.view addSubview:_dismissButton];
                    
                    CALayer *topLine = [CALayer layer];
                    topLine.backgroundColor = COLOR(232, 232, 232, 1).CGColor;
                    topLine.frame = CGRectMake(0, 0, kScreenWidth, 1);
                    
                    [_dismissButton.layer addSublayer:topLine];
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _dismissButton.frame.size.width, _dismissButton.frame.size.height)];
                    imageView.image = [UIImage imageNamed:@"down_arrow"];
                    imageView.contentMode = UIViewContentModeCenter;
                    
                    [_dismissButton addSubview:imageView];
                } else {
                    _dismissButton.hidden = NO;
                    _dismissButton.frame = CGRectMake(0, marginTop, kScreenWidth, 30);
                }
                
                //                if ([keyboard viewWithTag:100]) {
                //                    return;
                //                } else {
                //                    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
                //                    doneButton.tag = 100;
                //                    doneButton.adjustsImageWhenHighlighted = NO;
                //
                //                    if (kDeviceOSVersion >= 7.0) {
                //                        doneButton.frame = CGRectMake(0, 163, 104, 53);
                //                        doneButton.backgroundColor = COLOR(187, 190, 195, 1);
                //                        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
                //                        [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                //                    } else {
                //                        doneButton.frame = CGRectMake(0, 163, 104, 53);
                //                        [doneButton setImage:[UIImage imageNamed:@"doneup"] forState:UIControlStateNormal];
                //                        [doneButton setImage:[UIImage imageNamed:@"donedown"] forState:UIControlStateHighlighted];
                //                    }
                //
                //                    [doneButton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
                //
                //                    [keyboard addSubview:doneButton];
                //                }
                
                break;
            }
        }
    });
}

- (void)keyboardWillRemoveForRegisterNumberPad
{
    _dismissButton.hidden = YES;
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        // 找到键盘view
    //        UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    //
    //        UIView *keyboard;
    //
    //        for (int i = 0; i < [tempWindow.subviews count]; i++){
    //            keyboard = [tempWindow.subviews objectAtIndex:i];
    //
    //            // 找到键盘view并加入“Done”按钮
    //            if([[keyboard description] hasPrefix:@"<UIKeyboard"] || [[keyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
    //                if ([keyboard viewWithTag:100]) {
    //                    UIView *view = [keyboard viewWithTag:100];
    //
    //                    [view removeFromSuperview];
    //                    view = nil;
    //                }
    //
    //                break;
    //            }
    //        }
    //    });
}

- (void)doneEditing
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self keyboardWillRemoveForRegisterNumberPad];
}

- (void)dismissKeyboard:(UIButton *)sender
{
    [self doneEditing];
}


#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self keyboardWillShowForRegisterNumberPad];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self doneEditing];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    
    NSString *aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == RegisterVerifyCode) {
        if ([aString length] > 4) {
            [self.view endEditing:YES];
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"验证码为4位数字" delay:1.0];
            
            return NO;
        }
    } else if (textField.tag == RegisterPassword) {
        if ([aString length] > 16) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"密码最长为16位" delay:1.0];
            
            return NO;
        }
    } else if (textField.tag == RegisterPhone) {
        if ([aString length] > 11) {            
            return NO;
        }
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
