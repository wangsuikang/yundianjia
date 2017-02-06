//
//  LoginViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-05.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "LoginViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"
#import "User.h"
#import "Tool.h"
#import "WXLoginDelegate.h"

// Controlers
#import "MyShopListViewController.h"
#import "PopGestureRecognizerController.h"
#import "RegisterViewController.h"
//#import "LXMThirdLoginManager.h"
//#import "LXMThirdLoginResult.h"

// Views
#import "LoginTextField.h"
#import "UIButtonForBarButton.h"
#import "LoginButton.h"

// Categories
#import "NSObject+NullToString.h"

typedef NS_ENUM(NSInteger, LoginField) {
    LoginPhone = 201,
    LoginVerifyCode,
    LoginPassword,
    LoginName
};

@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, WXLoginDelegate>

@property (nonatomic, strong) UIView *accountInputView;
@property (nonatomic, strong) UIView *veryfyInputView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIButton *weixinButton;
@property (nonatomic, strong) UIButton *accountButton;
@property (nonatomic, strong) UIButton *veryfyButton;
@property (nonatomic, strong) UIButton *verifyCodeButton;
@property (nonatomic, strong) UIButton *dismissButton;

@property (nonatomic, strong) LoginTextField *nameText;
@property (nonatomic, strong) LoginTextField *phoneText;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *verifyCode;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int verifyCodeCount;
@property (nonatomic, strong) MBProgressHUD *hud;

/// 选中登录方式的下滑线
@property (nonatomic, copy) UIView *line;

/**
 微信登陆
 */
/// 点击回调第一步获取到的参数 code 用来获取access_token   openid
@property (nonatomic, copy) NSString *wxCode;

/// 第二步  根据code获取下面参数
/// 点击微信登陆回调获取的参数--acces_token
@property (nonatomic, copy) NSString *access_token;
/// 点击微信登陆回调获取的参数--openid
@property (nonatomic, copy) NSString *openid;
/// 点击微信登陆回调获取到的字典 这是第二步获取到的字典信息（里面包含了access_token  和 openid）
@property (nonatomic, strong) NSDictionary *tokenOpenidDict;

/// 第三步  根据上面的两个参数获取用户基本信息
@property (nonatomic, strong) NSDictionary *userInfoDict;
/// 微信登陆用户名称
@property (nonatomic, copy) NSString *nickName;
/// 微信登陆用户的图片URL路劲
@property (nonatomic, copy) NSString *wxHeadImgString;


@end

@implementation LoginViewController

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
        naviTitle.text = @"登录您的云店家";
        
        self.navigationItem.titleView = naviTitle;
        
        _username = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactPhone"]);
        _password = @"";
        _phone = @""; // kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactPhone"]);
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

    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    self.view.backgroundColor = kBackgroundColor;
    
//    self.tabBarController.tabBar.hidden = YES;
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.hidden = YES;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        
        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
    
//    if ([_veryfyInputView isHidden]) {
//        double delayInSeconds = 0.5;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [_nameText becomeFirstResponder];
//        });
//    } else {
//        double delayInSeconds = 0.5;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [_phoneText becomeFirstResponder];
//        });
//    }
    //    [TalkingData trackPageBegin:@"进入登录页面"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSArray *list=self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.hidden = YES;
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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
//    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [close setTitle:@"取消" forState:UIControlStateNormal];
//    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [close setBackgroundColor:kClearColor];
//    close.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
//    close.titleLabel.textAlignment = NSTextAlignmentCenter;
//    close.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
//    [close addTarget:self action:@selector(returnView) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:close];
//    
//    self.navigationItem.leftBarButtonItem = closeItem;
//    
//    UIButton *goToRegister = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [goToRegister setTitle:@"注册" forState:UIControlStateNormal];
//    [goToRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [goToRegister setBackgroundColor:kClearColor];
//    goToRegister.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
//    goToRegister.titleLabel.textAlignment = NSTextAlignmentCenter;
//    goToRegister.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
//    [goToRegister addTarget:self action:@selector(goToRegister) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *goToPayItem = [[UIBarButtonItem alloc] initWithCustomView:goToRegister];
//    goToPayItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.rightBarButtonItem = goToPayItem;
//    
//    CGFloat space = (kScreenWidth - 210) / 6;
//    for (int i = 0; i < 3; i++) {
//        LoginButton *button = [[LoginButton alloc] initWithFrame:CGRectMake(space + i * (70 + 2 * space), kScreenHeight - 30 - 70, 70, 70)];
//        
////        button.backgroundColor = [UIColor redColor];
//        [button setTitleColor:kNaviTitleColor forState:UIControlStateSelected];
//        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        button.titleLabel.font = kMidFont;
//        [button addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchDown];
//        button.tag = i;
//        button.titleLabel.textAlignment = NSTextAlignmentCenter;
//        
//        if (i == 0) {
//            button.selected = YES;
//            
//            [button setImage:[UIImage imageNamed:@"admin_login_code_unselected"] forState:UIControlStateNormal];
//            [button setTitle:@"密码登录" forState:UIControlStateNormal];
//            
//            _veryfyButton = button;
//        } else if (i == 1) {
//            button.selected = NO;
//            
//            [button setImage:[UIImage imageNamed:@"admin_login_weixin_unselected"] forState:UIControlStateNormal];
//            [button setTitle:@"微信登录" forState:UIControlStateNormal];
//            
//            _accountButton = button;
//        } else {
//            button.selected = NO;
//            
//            [button setImage:[UIImage imageNamed:@"admin_login_message_unselected"] forState:UIControlStateNormal];
//            [button setTitle:@"验证码登录" forState:UIControlStateNormal];
//        }
//        
//        [self.view addSubview:button];
//    }
//    
//    _accountInputView = [[UIView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight + 40, kScreenWidth, 110)];
//    _accountInputView.hidden = YES;
//    [self.view addSubview:_accountInputView];
//    
//    _nameText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, 40) leftViewImage:@"login_account"];
//    _nameText.delegate = self;
//    _nameText.tag = LoginName;
//    _nameText.placeholder = @"请输入用户名";
//    //    _nameText.keyboardType = UIKeyboardTypeNumberPad;
//    _nameText.text = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactPhone"]);
//    [_nameText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
//    
//    [_accountInputView addSubview:_nameText];
//    
//    LoginTextField *passText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 60, kScreenWidth - 20, 40) leftViewImage:@"login_password"];
//    passText.secureTextEntry = YES;
//    passText.delegate = self;
//    passText.tag = LoginPassword;
//    passText.placeholder = @"请输入密码";
//    passText.text = @"";
//    [passText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
//    
//    [_accountInputView addSubview:passText];
//    
//    _veryfyInputView = [[UIView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight + 40, kScreenWidth, 110)];
//    [self.view addSubview:_veryfyInputView];
//    
//    _phoneText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, 40) leftViewImage:@"login_phone"];
//    _phoneText.delegate = self;
//    _phoneText.tag = LoginPhone;
//    _phoneText.placeholder = @"请输入手机号";
//    _phoneText.keyboardType = UIKeyboardTypeNumberPad;
//    _phoneText.text = @""; // kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactPhone"]);
//    [_phoneText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
//    [_phoneText setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    
//    [_veryfyInputView addSubview:_phoneText];
//    
//    CGFloat width = (kScreenWidth - 20) / 2 - 10;
//    
//    LoginTextField *verifyCodeText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 60, width, 40)
//                                                             leftViewImage:@"login_verify"];
//    verifyCodeText.delegate = self;
//    verifyCodeText.tag = LoginVerifyCode;
//    verifyCodeText.placeholder = @"请输入验证码";
//    verifyCodeText.text = @"";
//    verifyCodeText.keyboardType = UIKeyboardTypeNumberPad;
//    [verifyCodeText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
//    
//    [_veryfyInputView addSubview:verifyCodeText];
//    
//    _verifyCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - width - 10, 60, width, 40)];
//    _verifyCodeButton.layer.cornerRadius = 6;
//    _verifyCodeButton.layer.masksToBounds = YES;
//    _verifyCodeButton.layer.borderWidth = 1;
//    _verifyCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    [_verifyCodeButton setTitle:@"验证码" forState:UIControlStateNormal];
//    [_verifyCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_verifyCodeButton addTarget:self action:@selector(getVerifyCodeForLogin:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_veryfyInputView addSubview:_verifyCodeButton];
//    
//    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 276) / 2, kCustomNaviHeight + 180, 276, 56)];
//    loginButton.tag = 10010;
//    [loginButton setImage:[UIImage imageNamed:@"admin_certain"] forState:UIControlStateNormal];
//    [loginButton addTarget:self action:@selector(commitLogin:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:loginButton];
//    
//    AppDelegate *appDelegate = kAppDelegate;
//    appDelegate.wxLoginDelegate = self;
//    
//    if ([WXApi isWXAppInstalled]) {
//    EnterButton *WeiXinLoginButton = [[EnterButton alloc] initWithFrame:CGRectMake((kScreenWidth - 276) / 2, CGRectGetMaxY(loginButton.frame) + 20, 276, 56)];
//    [WeiXinLoginButton addTarget:self action:@selector(WeiXinLogin:) forControlEvents:UIControlEventTouchUpInside];
//    [WeiXinLoginButton setImage:[UIImage imageNamed:@"weixin_certain"] forState:UIControlStateNormal];
//    WeiXinLoginButton.tag = 10020;
//    
//    [self.view addSubview:WeiXinLoginButton];
//    }
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShowForLoginNumberPad)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    // 添加单击手势
//    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
//    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
//    singleTapGestureRecognizer.delegate = self;
//    
//    [self.view addGestureRecognizer:singleTapGestureRecognizer];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, kScreenHeight + 64)];
    backgroundView.image = [UIImage imageNamed:@"admin_login_background_new"];
    
    [self.view addSubview:backgroundView];
    
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [close setTitle:@"取消" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [close setBackgroundColor:kClearColor];
    close.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    close.titleLabel.textAlignment = NSTextAlignmentCenter;
    close.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [close addTarget:self action:@selector(returnView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:close];
    
    self.navigationItem.leftBarButtonItem = closeItem;
    
//    UIButton *goToRegister = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [goToRegister setTitle:@"注册" forState:UIControlStateNormal];
//    [goToRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [goToRegister setBackgroundColor:kClearColor];
//    goToRegister.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
//    goToRegister.titleLabel.textAlignment = NSTextAlignmentCenter;
//    goToRegister.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
//    [goToRegister addTarget:self action:@selector(goToRegister) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *goToPayItem = [[UIBarButtonItem alloc] initWithCustomView:goToRegister];
//    goToPayItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.rightBarButtonItem = goToPayItem;
    
    CGFloat space = (kScreenWidth - 210) / 6;
    for (int i = 0; i < 3; i++) {
        LoginButton *button = [[LoginButton alloc] initWithFrame:CGRectMake(space + i * (70 + 2 * space), kScreenHeight - 30 - 70, 70, 70)];
        
        //        button.backgroundColor = [UIColor redColor];
//        [button setTitleColor:kNaviTitleColor forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = kMidFont;
        [button addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchDown];
        button.tag = i;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (i == 0) {
            button.selected = YES;
            
            [button setImage:[UIImage imageNamed:@"admin_login_message_unselected"] forState:UIControlStateNormal];
            [button setTitle:@"验证码登录" forState:UIControlStateNormal];
            
            _veryfyButton = button;
            
            _line = [[UIView alloc] initWithFrame:CGRectMake(button.frame.origin.x, CGRectGetMaxY(button.frame) + 5, button.frame.size.width, 1)];
            _line.backgroundColor = [UIColor whiteColor];
            
            [self.view addSubview:_line];
        } else if (i == 1) {
            
            button.selected = NO;
            
            [button setImage:[UIImage imageNamed:@"admin_login_weixin_unselected"] forState:UIControlStateNormal];
            [button setTitle:@"微信登录" forState:UIControlStateNormal];
            button.hidden = YES;
            _weixinButton = button;
            if ([WXApi isWXAppInstalled]) {
                button.hidden = NO;
            }
        } else {
            button.selected = NO;
            
            [button setImage:[UIImage imageNamed:@"admin_login_code_unselected"] forState:UIControlStateNormal];
            [button setTitle:@"密码登录" forState:UIControlStateNormal];
            
            _accountButton = button;
        }
        
        [self.view addSubview:button];
    }
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(120, 84, kScreenWidth - 240, kScreenWidth - 240)];
    
    if (kScreenWidth == 414) {
        icon.frame = CGRectMake((kScreenWidth - 120) / 2, 84, 120, 120);
    }
    
    if (!kIsiPhone) {
        icon.frame = CGRectMake((kScreenWidth - 150) / 2, 84, 150, 150);
    }
    icon.image = [UIImage imageNamed:@"admin_login_companyicon"];
    
    [self.view addSubview:icon];
    
    _accountInputView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame) + 40, kScreenWidth, 95)];
    
    if (kScreenHeight == 480)
    {
        _accountInputView.frame = CGRectMake(0, CGRectGetMaxY(icon.frame) + 20, kScreenWidth, 95);
    }
    _accountInputView.hidden = YES;
    [self.view addSubview:_accountInputView];
//    _accountInputView.backgroundColor = [UIColor redColor];
    
    UIImageView *nameView = [[UIImageView alloc] initWithFrame:CGRectMake(space, 0, kScreenWidth - 2 * space, 40)];
    nameView.image = [UIImage imageNamed:@"admin_login_textFeild_back"];
    nameView.layer.masksToBounds = YES;
    nameView.layer.cornerRadius = 20;
    nameView.userInteractionEnabled = YES;
    
    [_accountInputView addSubview:nameView];
    
    _nameText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 5, nameView.frame.size.width - 20, nameView.frame.size.height - 10) leftViewImage:@"login_account"];
    _nameText.delegate = self;
    _nameText.tag = LoginName;
    _nameText.placeholder = @"请输入用户名";
    //    _nameText.keyboardType = UIKeyboardTypeNumberPad;
    _nameText.text = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactPhone"]);
    [_nameText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    
    [nameView addSubview:_nameText];
    
    UIImageView *passView = [[UIImageView alloc] initWithFrame:CGRectMake(space, CGRectGetMaxY(nameView.frame) + 15, kScreenWidth - 2 * space, 40)];
    passView.image = [UIImage imageNamed:@"admin_login_textFeild_back"];
    passView.layer.masksToBounds = YES;
    passView.layer.cornerRadius = 20;
    passView.userInteractionEnabled = YES;
    
    [_accountInputView addSubview:passView];
    
    LoginTextField *passText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 5, nameView.frame.size.width - 20, nameView.frame.size.height - 10) leftViewImage:@"login_password"];
    passText.secureTextEntry = YES;
    passText.delegate = self;
    passText.tag = LoginPassword;
    passText.placeholder = @"请输入密码";
    passText.text = @"";
    [passText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    
    [passView addSubview:passText];
    
    UIButton *passLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(space, CGRectGetMaxY(_accountInputView.frame) + 20, kScreenWidth - 2 * space, 40)];
    passLoginButton.tag = 10010;
    passLoginButton.backgroundColor = [UIColor whiteColor];
    passLoginButton.layer.masksToBounds = YES;
    passLoginButton.layer.cornerRadius = 20;
//    [passLoginButton setBackgroundImage:[UIImage imageNamed:@"admin_login_button_back"] forState:UIControlStateNormal];
    [passLoginButton addTarget:self action:@selector(commitLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:passLoginButton];
    
    UILabel *passLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, passLoginButton.frame.size.width, passLoginButton.frame.size.height)];
    passLoginLabel.text = @"登录";
    passLoginLabel.textColor = kOrangeColor;
    passLoginLabel.font = kFont;
    passLoginLabel.textAlignment= NSTextAlignmentCenter;
    
    [passLoginButton addSubview:passLoginLabel];
    
    UIButton *goToRegister = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2, CGRectGetMaxY(passLoginButton.frame) + 20, 100, 20)];
    [goToRegister setTitle:@"创建新的用户" forState:UIControlStateNormal];
    [goToRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goToRegister.titleLabel.font = kMidFont;
    goToRegister.titleLabel.textAlignment = NSTextAlignmentCenter;
    [goToRegister addTarget:self action:@selector(goToRegister) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:goToRegister];
    
    UIImageView *leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(space, CGRectGetMaxY(passLoginButton.frame) + 20 + 9, kScreenWidth / 2 - goToRegister.frame.size.width / 2 - space, 2)];
    leftLine.image = [UIImage imageNamed:@"left_line"];
    
    [self.view addSubview:leftLine];
    
    UIImageView *rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goToRegister.frame), CGRectGetMaxY(passLoginButton.frame) + 20 + 9, kScreenWidth / 2 - goToRegister.frame.size.width / 2 - space, 2)];
    rightLine.image = [UIImage imageNamed:@"right_line"];
    
    [self.view addSubview:rightLine];
    
    _veryfyInputView = [[UIView alloc] initWithFrame:_accountInputView.frame];
    
    if (kScreenHeight == 480)
    {
        _accountInputView.frame = CGRectMake(0, CGRectGetMaxY(icon.frame) + 20, kScreenWidth, 95);
    }
    [self.view addSubview:_veryfyInputView];
    
    UIImageView *phoneView = [[UIImageView alloc] initWithFrame:CGRectMake(space, 0, kScreenWidth - 2 * space, 40)];
    phoneView.image = [UIImage imageNamed:@"admin_login_textFeild_back"];
    phoneView.layer.masksToBounds = YES;
    phoneView.layer.cornerRadius = 20;
    phoneView.userInteractionEnabled = YES;
    
    [_veryfyInputView addSubview:phoneView];
    
    _phoneText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 5, phoneView.frame.size.width - 20, phoneView.frame.size.height - 10) leftViewImage:@"login_phone"];
    _phoneText.delegate = self;
    _phoneText.tag = LoginPhone;
    _phoneText.placeholder = @"请输入手机号";
    _phoneText.keyboardType = UIKeyboardTypeNumberPad;
    _phoneText.text = @""; // kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"lastContactPhone"]);
    [_phoneText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    [_phoneText setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [phoneView addSubview:_phoneText];
    
    CGFloat width = (kScreenWidth - space * 2) / 2 - space;
    
    UIImageView *verifyCodeView = [[UIImageView alloc] initWithFrame:CGRectMake(space, 55, width + space * 2, 40)];
    verifyCodeView.image = [UIImage imageNamed:@"admin_login_textFeild_back"];
    verifyCodeView.layer.masksToBounds = YES;
    verifyCodeView.layer.cornerRadius = 20;
    verifyCodeView.userInteractionEnabled = YES;
    
    [_veryfyInputView addSubview:verifyCodeView];
    
    LoginTextField *verifyCodeText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, 5, verifyCodeView.frame.size.width - 20, verifyCodeView.frame.size.height - 10) leftViewImage:@"login_verify"];
    verifyCodeText.delegate = self;
    verifyCodeText.tag = LoginVerifyCode;
    verifyCodeText.placeholder = @"请输入验证码";
    verifyCodeText.text = @"";
    verifyCodeText.keyboardType = UIKeyboardTypeNumberPad;
    [verifyCodeText addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    
    [verifyCodeView addSubview:verifyCodeText];
    
    _verifyCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - width - space + 10, 55, width - 10, 40)];
    _verifyCodeButton.layer.cornerRadius = 6;
    _verifyCodeButton.layer.masksToBounds = YES;
    _verifyCodeButton.layer.borderWidth = 1;
    _verifyCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_verifyCodeButton setTitle:@"验证码" forState:UIControlStateNormal];
    [_verifyCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_verifyCodeButton addTarget:self action:@selector(getVerifyCodeForLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [_veryfyInputView addSubview:_verifyCodeButton];
    
//
//    AppDelegate *appDelegate = kAppDelegate;
//    appDelegate.wxLoginDelegate = self;
//    
//    if ([WXApi isWXAppInstalled]) {
//        EnterButton *WeiXinLoginButton = [[EnterButton alloc] initWithFrame:CGRectMake((kScreenWidth - 276) / 2, CGRectGetMaxY(loginButton.frame) + 20, 276, 56)];
//        [WeiXinLoginButton addTarget:self action:@selector(WeiXinLogin:) forControlEvents:UIControlEventTouchUpInside];
//        [WeiXinLoginButton setImage:[UIImage imageNamed:@"weixin_certain"] forState:UIControlStateNormal];
//        WeiXinLoginButton.tag = 10020;
//        
//        [self.view addSubview:WeiXinLoginButton];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowForLoginNumberPad)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // 添加单击手势
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WXLoginDelegate -

- (void)showLoginResult:(WXLoginResult)result SendauthResp:(SendAuthResp *)resp message:(NSString *)message
{
    YunLog(@"调用登陆 登陆、来来来来来来");
    self.wxCode = resp.code;
    YunLog(@"self.wxCode = %@", resp.code);
    
    switch (result) {
        case WXLoginResultSuccess:
        {
//            [self getAccess_token];
//            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
//            operationQueue.maxConcurrentOperationCount = 1;  // 设置最大并发数
//            NSBlockOperation *getAccessOperation = [NSBlockOperation blockOperationWithBlock:^{
                [self getAccess_token];
//            }];
            
//            NSBlockOperation *getUserInfoOperation = [NSBlockOperation blockOperationWithBlock:^{
//                [self getUserInfo];
//            }];
//            
//            // 设置依赖关系
//            [getUserInfoOperation addDependency:getAccessOperation];
//            
//            [operationQueue addOperation:getAccessOperation];
//            [operationQueue addOperation:getUserInfoOperation];
            
            break;
        }
        case WXLoginResultFailure:
        {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"用户取消登录" delay:1.5];
            break;
        }

        default:
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:resp.errStr delay:1.5];
            break;
    }
}

-(void)getAccess_token
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeiXinAppID,kWeiXinAppKey,_wxCode];
    YunLog(@"get accessURL = %@", url);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                _tokenOpenidDict = [NSDictionary dictionary];
                _tokenOpenidDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                YunLog(@"获取token openid  = %@", _tokenOpenidDict);
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                
                //                self.access_token.text = [dic objectForKey:@"access_token"];
                //                self.openid.text = [dic objectForKey:@"openid"];
                _access_token = [_tokenOpenidDict objectForKey:@"access_token"];
                _openid = [_tokenOpenidDict objectForKey:@"openid"];
                
//                if (_access_token.length > 0 && _openid.length > 0) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getAccessOpenid" object:self];
//                }
                
                [self getUserInfo];
            }
        });
    });
}

-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token,self.openid];
    YunLog(@"get UserInfoURl = %@", url);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                _userInfoDict = [NSDictionary dictionary];
                _userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                YunLog(@"获取userInfo = %@", _userInfoDict);
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                
                //                self.nickname.text = [dic objectForKey:@"nickname"];
                //                self.wxHeadImg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"headimgurl"]]]];
                _nickName = [_userInfoDict objectForKey:@"nickname"];
                _wxHeadImgString = [_userInfoDict objectForKey:@"headimgurl"];
                
                // 跳转到再次登陆页面
                [self nextCommitLoginTokeDict:_tokenOpenidDict UserInfo:_userInfoDict];
                
                // 参数获取完毕, 这里调用公司的接口，进行参数获取，判断是否符合规格
//                [self WeiXinLoginTokeDict:_tokenOpenidDict UserInfo:_userInfoDict];
            }
        });
        
    });
}

/**
 *  点击微信登陆成功返回之后跳转到继续点击确认页面
 *
 *  @param tokenDict    获取到的access字典信息
 *  @param userInfoDict 获取到的userInfo信息
 */
- (void)nextCommitLoginTokeDict:(NSDictionary *)tokenDict UserInfo:(NSDictionary *)userInfoDict
{
    [self.view endEditing:YES];
    /// 背景View
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    _bgView.backgroundColor = kWhiteColor;
    
    [self.view addSubview:_bgView];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_bgView.bounds];
//    imageView.image = [UIImage imageNamed:@"admin_login_background"];
//    
//    [_bgView addSubview:imageView];
    
    /// 添加直线
//    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kLineHeight)];
//    topLineView.backgroundColor = [UIColor lightGrayColor];
//    
//    [_bgView addSubview:topLineView];
//    
//    // 添加标题
//    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
//    topLabel.text = @"选择登陆方式";
//    topLabel.font = kNormalFont;
//    topLabel.textAlignment = NSTextAlignmentCenter;
//    
//    [_bgView addSubview:topLabel];
    
    CGFloat buttonWidth = (kScreenWidth - 80 - 20) / 2;
    CGFloat buttonY;
    if (kScreenWidth > 320) {
        buttonY = (kScreenHeight - buttonWidth) / 2;
    } else {
        buttonY = (kScreenHeight - buttonWidth) / 3;
    }
    
    /// 提示语
    UILabel *midLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonY - 50, kScreenWidth, 20)];
    midLabel.text = @"您可以选择两种登录方式";
    midLabel.font = kMidFont;
    midLabel.textColor = kBlackColor;
    midLabel.textAlignment = NSTextAlignmentCenter;
    
    [_bgView addSubview:midLabel];
    
    // 添加两个按钮
    EnterButton *leftButtonLogin = [[EnterButton alloc] initWithFrame:CGRectMake(40, buttonY, buttonWidth, buttonWidth)];
    [leftButtonLogin setImage:[UIImage imageNamed:@"wxLeftLogin"] forState:UIControlStateNormal];
    [leftButtonLogin addTarget:self action:@selector(wxLeftLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bgView addSubview:leftButtonLogin];
    
    EnterButton *rightButtonLogin = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftButtonLogin.frame) + 20, buttonY, buttonWidth, buttonWidth)];
    [rightButtonLogin setImage:[UIImage imageNamed:@"wxRightLogin"] forState:UIControlStateNormal];
    [rightButtonLogin addTarget:self action:@selector(wxRightLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bgView addSubview:rightButtonLogin];
}


/// 左右登陆选择点击方法
- (void)wxLeftLogin:(EnterButton *)sender
{
    YunLog(@"微信直接登陆");
    [self WeiXinLoginTokeDict:_tokenOpenidDict UserInfo:_userInfoDict index:1];
}

- (void)wxRightLogin:(EnterButton *)sender
{
    YunLog(@"微信绑定登陆");
    [self createRightButtonClickUI];
//    [self WeiXinLoginTokeDict:_tokenOpenidDict UserInfo:_userInfoDict index:2];

}

- (void)createRightButtonClickUI
{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth, kNavTabBarHeight, kScreenWidth, kScreenHeight - kNavTabBarHeight)];
    rightView.backgroundColor = kWhiteColor;
    rightView.tag = 100001;
    
    [self.view addSubview:rightView];
    
    // 添加lineView
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 48)];
    topLabel.text = @"登录方式";
    topLabel.font = kNormalFont;
    topLabel.textColor = [UIColor lightGrayColor];
    topLabel.textAlignment = NSTextAlignmentCenter;
    
    [rightView addSubview:topLabel];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLabel.frame), kScreenWidth, kLineHeight)];
    topLineView.backgroundColor = [UIColor lightGrayColor];
    
    [rightView addSubview:topLineView];
    
    CGFloat labelY = CGRectGetMaxY(topLineView.frame) + 20;
    // 添加账号
    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, labelY, 40, 15)];
    accountLabel.text = @"账号";
    accountLabel.textAlignment = NSTextAlignmentLeft;
    accountLabel.font = kSmallFont;
    accountLabel.textColor = kBlackColor;
    
    [rightView addSubview:accountLabel];
    
    // 提示输入框
    UITextField *accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(accountLabel.frame), kScreenWidth - 40, 20)];
    accountTextField.placeholder = @"请输入账号";
    accountTextField.font = kMidFont;
    accountTextField.textColor = kBlackColor;
    accountTextField.tag = 100002;
    accountTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    [rightView addSubview:accountTextField];
    
    // 添加accountLineView
    UIView *accountLineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(accountTextField.frame) + 5, kScreenWidth - 40, kLineHeight)];
    accountLineView.backgroundColor = kBlackColor;
    
    [rightView addSubview:accountLineView];
    
    // 添加密码
    UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(accountLineView.frame) + 5, 40, 15)];
    pwdLabel.text = @"密码";
    pwdLabel.textAlignment = NSTextAlignmentLeft;
    pwdLabel.font = kSmallFont;
    pwdLabel.textColor = kBlackColor;
    
    [rightView addSubview:pwdLabel];
    
    // 密码输入框
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(pwdLabel.frame), kScreenWidth - 40, 20)];
    pwdTextField.placeholder = @"请输入密码";
    pwdTextField.font = kMidFont;
    pwdTextField.textColor = kBlackColor;
    pwdTextField.secureTextEntry = YES;
    pwdTextField.tag = 100003;
    pwdTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    [rightView addSubview:pwdTextField];
    
    // 添加pwdLineView
    UIView *pwdLineView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(pwdTextField.frame) + 5, kScreenWidth - 40, kLineHeight)];
    pwdLineView.backgroundColor = kBlackColor;
    
    [rightView addSubview:pwdLineView];
    
    // 添加下面的两个按钮
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(rightView.frame) - 48 - kNavTabBarHeight, kScreenWidth, kLineHeight)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    [rightView addSubview:lineView];
    
    
    CGFloat backButtonWidth = (kScreenWidth - 100) / 2;
    // 添加返回按钮
    EnterButton *backButton = [[EnterButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(lineView.frame) + 9, backButtonWidth, 30)];
    backButton.layer.masksToBounds = YES;
    backButton.layer.cornerRadius = 5;
    backButton.layer.borderColor = kOrangeColor.CGColor;
    backButton.layer.borderWidth = 1.0;
    
    backButton.titleLabel.font = kMidFont;
    [backButton setTitle:@"返回选择" forState:UIControlStateNormal];
    [backButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(leftBcakButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightView addSubview:backButton];
    
    // 添加登陆按钮
    EnterButton *selecedtLogin = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backButton.frame) + 20, CGRectGetMaxY(lineView.frame) + 9, backButtonWidth, 30)];
    selecedtLogin.layer.masksToBounds = YES;
    selecedtLogin.layer.cornerRadius = 2.5;
    selecedtLogin.backgroundColor = kOrangeColor;
    
    selecedtLogin.titleLabel.font = kMidFont;
    [selecedtLogin setTitle:@"绑定登录" forState:UIControlStateNormal];
    [selecedtLogin setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [selecedtLogin addTarget:self action:@selector(rightBackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightView addSubview:selecedtLogin];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = rightView.frame;
        
        frame.origin.x = 0;
        
        rightView.frame = frame;
    }];
    
}

// 返回按钮和绑定登录按钮点击事件
- (void)leftBcakButtonClick:(EnterButton *)sender
{
    UIView *rightView = (UIView *)[self.view viewWithTag:100001];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = rightView.frame;
        
        frame.origin.x = kScreenWidth;
        
        rightView.frame = frame;
        
    } completion:^(BOOL finished) {
        [rightView removeFromSuperview];
    }];
}

- (void)rightBackButtonClick:(EnterButton *)sender
{
    UIView *rightView = (UIView *)[self.view viewWithTag:100001];
    
    UITextField *accountTextField = (UITextField *)[rightView viewWithTag:100002];
    UITextField *pwdTextField = (UITextField *)[rightView viewWithTag:100003];
    
    if (accountTextField.text.length > 0 && pwdTextField.text.length > 0) {
        [self WeiXinLoginTokeDict:_tokenOpenidDict UserInfo:_userInfoDict index:2];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"账号密码不能为空" delay:1.5];
        
        return;
    }
}
/**
 *  微信登陆
 *
 *  @param tokenDict    获取到的access
 *  @param userInfoDict 获取到的用户信息
 *  @param index        1代表直接使用微信登陆  2代表绑定微信号登陆
 */
- (void)WeiXinLoginTokeDict:(NSDictionary *)tokenDict UserInfo:(NSDictionary *)userInfoDict index:(NSInteger)index
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    YunLog(@"获取token openid  = %@", tokenDict);
    
    YunLog(@"获取userInfo = %@", userInfoDict);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud.labelText = @"登录...";
    
    NSString *loginURL;
    NSDictionary *params = [NSDictionary dictionary];
    if (index == 1) {
        loginURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kThirdPartyLoginURL params:nil];
        
        params = @{@"provider"           :         kNullToString(@"weixin"),
                   @"uid"                :         kNullToString([userInfoDict safeObjectForKey:@"unionid"])};
    }
    
    if (index == 2) {
        UIView *rightView = (UIView *)[self.view viewWithTag:100001];
        
        UITextField *accountTextField = (UITextField *)[rightView viewWithTag:100002];
        UITextField *pwdTextField = (UITextField *)[rightView viewWithTag:100003];
        
        loginURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kSignInURL params:nil];
        
        params = @{@"login"           :           kNullToString(accountTextField.text),
                   @"password"        :           kNullToString(pwdTextField.text),
                   @"provider"        :           kNullToString(@"weixin"),
                   @"uid"             :           kNullToString([userInfoDict safeObjectForKey:@"unionid"])};
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:loginURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"login responseObject = %@", responseObject);
              
              NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
              if ([code isEqualToString:kSuccessCode]) {
                  
                  NSDictionary *userDic = [[responseObject objectForKey:@"data"] objectForKey:@"user"];
                  appDelegate.user.username = [userDic safeObjectForKey:@"name"];
//                  appDelegate.user.password = _password;
                  appDelegate.user.display_name = [userDic safeObjectForKey:@"display_name"];

                  NSString *userType = [userDic safeObjectForKey:@"user_type"];
                  if (userType.length > 0) {
                      appDelegate.user.userType = [[userDic safeObjectForKey:@"user_type"] integerValue];
                      
                  } else {
                      appDelegate.user.userType = 1;
                      
                  }
                  
                  appDelegate.user.userSessionKey = [userDic safeObjectForKey:@"user_session_key"];
                  appDelegate.user.birthday = [userDic safeObjectForKey:@"birthday"];
                  appDelegate.user.nickname = [userDic safeObjectForKey:@"nick_name"];
                  appDelegate.user.phone = [userDic safeObjectForKey:@"phone"];
                  appDelegate.login = YES;
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  
                  [defaults setObject:[userInfoDict safeObjectForKey:@"nickname"] forKey:@"username"];
                  [defaults setObject:[userDic safeObjectForKey:@"user_session_key"] forKey:@"user_session_key"];
                  [defaults setObject:[userInfoDict safeObjectForKey:@"nickname"] forKey:@"lastContactPhone"];
                  [defaults setObject:appDelegate.user.display_name forKey:@"display_name"];
                  [defaults setObject:[NSString stringWithFormat:@"%ld", (long)appDelegate.user.userType] forKey:@"userType"];
                  [defaults setObject:kNullToString([userDic safeObjectForKey:@"birthday"]) forKey:@"birthday"];
                  [defaults setObject:kNullToString([userDic safeObjectForKey:@"nickname"]) forKey:@"nickname"];
                  [defaults setObject:kNullToString([userDic safeObjectForKey:@"phone"]) forKey:@"phone"];
                  
                  [defaults synchronize];
                  
                  _username = @"";
                  _password = @"";
                  _phone = @"";
                  _verifyCode = @"";
                  
                  [_hud addSuccessString:@"登录成功" delay:1.0];
                  
                  if (_isReturnView == YES && appDelegate.user.userType == 1)
                  {
                      [self returnView];
                  }
                  else
                  {
                      if (appDelegate.user.userType == 2 || appDelegate.user.userType == 3) {
                          [self doneEditing];
                          
                          [self getMyShopsData];
                      }
                      
                      if (appDelegate.user.userType == 1) {
                          AppDelegate *appDelegate = kAppDelegate;
                          
                          _hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
                          _hud.labelText = @"正在努力跳转...";
                          
                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              [_hud hide:YES];
                              
                              appDelegate.indexTab = [[IndexTabViewController alloc] init];
                              
                              appDelegate.window.rootViewController = appDelegate.indexTab;
                              [appDelegate.window makeKeyAndVisible];
                          });
                      }
                  }
              } else {
                  [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"]
                                 delay:1.0];
//                  sender.enabled = YES;
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              YunLog(@"login error = %@", error);
              
              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
              
//              sender.enabled = YES;
          }
     ];

}


#pragma mark - UIGestureRecognizer Click - 

- (void)singleTap:(UIGestureRecognizer *)ges
{
    [self.view endEditing:YES];
}

#pragma mark - Private Functions -

- (void)goToRegister
{
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    registerVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)getVerifyCodeForLogin:(UIButton *)sender
{
    NSString *regexString = @"(^1(3[5-9]|47|5[012789]|8[23478])\\d{8}$|134[0-8]\\d{7}$)|(^18[019]\\d{8}$|1349\\d{7}$)|(^1(3[0-2]|45|5[56]|8[56])\\d{8}$)|(^1[35]3\\d{8}$)";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    
    NSTextCheckingResult *result = [regex firstMatchInString:_phone options:0 range:NSMakeRange(0, [_phone length])];
    
    if (!result) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请输入正确手机号" delay:2.0];
        
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        sender.enabled = NO;
        //        sender.backgroundColor = COLOR(196, 196, 196, 1);
        sender.backgroundColor = COLOR(147, 147, 147, 1);
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        NSString *verifyCodeURL = [Tool buildRequestURLHost:kRequestHost
                                                 APIVersion:kAPIVersion1
                                                 requestURL:kCreatePhoneCodeURL
                                                     params:nil];
        
        YunLog(@"verifyCodeURL = %@", verifyCodeURL);
        
        AppDelegate *appDelegate = kAppDelegate;
        
        NSDictionary *params = @{@"phone"                   :   _phone,
                                 @"phone_code_type"         :   @"sign_in",
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager PUT:verifyCodeURL
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
                 [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                 
                 sender.enabled = YES;
                 sender.backgroundColor = COLOR(147, 147, 147, 1);
                 
                 YunLog(@"get verify code error = %@", error);
             }];
    }
}

- (void)changeView:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        _line.frame = CGRectMake(sender.frame.origin.x, CGRectGetMaxY(sender.frame) + 5, sender.frame.size.width, 1);
    }];
    
    if (sender.tag == 0) {
        _accountInputView.hidden = YES;
        _veryfyInputView.hidden = NO;
        
        _veryfyButton.selected = YES;
        //        _veryfyButton.backgroundColor = COLOR(147, 147, 147, 1);
        //        [_veryfyButton setTitleColor:COLOR(147, 147, 147, 1) forState:UIControlStateNormal];
        
        _accountButton.selected = NO;
        _weixinButton.selected = NO;
        //        _accountButton.backgroundColor = kBackgroundColor;
        //        [_accountButton setTitleColor:kNaviTitleColor forState:UIControlStateNormal];
        
//        for (id so in _accountInputView.subviews) {
//            if ([so isKindOfClass:[LoginTextField class]]) {
//                UITextField *textField = (UITextField *)so;
////                [textField becomeFirstResponder];
//                
//                break;
//            }
//        }
    } else if (sender.tag == 1) {
        AppDelegate *appDelegate = kAppDelegate;
        appDelegate.wxLoginDelegate = self;
        
        [self WeiXinLogin:nil];
        
        _veryfyButton.selected = NO;
        _accountButton.selected = NO;
        _weixinButton.selected = YES;
    } else {
        _accountInputView.hidden = NO;
        _veryfyInputView.hidden = YES;
        
        _veryfyButton.selected = NO;
        //        _veryfyButton.backgroundColor = COLOR(245, 245, 245, 1);
        //        [_veryfyButton setTitleColor:kNaviTitleColor forState:UIControlStateNormal];
        
        _accountButton.selected = YES;
        _weixinButton.selected = NO;

        //        _accountButton.backgroundColor = COLOR(147, 147, 147, 1);
        //        [_accountButton setTitleColor:COLOR(147, 147, 147, 1) forState:UIControlStateNormal];
        
//        for (id so in _veryfyInputView.subviews) {
//            if ([so isKindOfClass:[LoginTextField class]]) {
//                UITextField *textField = (UITextField *)so;
////                [textField becomeFirstResponder];
//                
//                break;
//            }
//        }
    }
}

- (void)returnView
{
    [self doneEditing];
    
    if (_hud) [_hud hide:NO];
    
    if (_isBuyEnter == YES && _isCartNewEnter == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isCartNew"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
       [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (_isBuyEnter == YES) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)pushToShop
{
    AppDelegate *appDelegate = kAppDelegate;
    
    MyShopListViewController *myShopVc = [[MyShopListViewController alloc] init];
    
    PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:myShopVc];
    
    appDelegate.window.rootViewController = popNC;
    [appDelegate.window makeKeyAndVisible];
}

//- (void)handleWeiXinButtonTapped:(id)sender {
//    if (![LXMThirdLoginManager isAppInstalled:LXMThirdLoginTypeWeChat]) {
//        //一般来说这个是用来判断这个第三方登录的按钮是否应该显示出来的
//        NSLog(@"没有安装腾讯微信客户端");
//        return;
//    }
//    
//    [LXMThirdLoginManager sharedManager].shouldRequestUserInfo = YES;
//    [[LXMThirdLoginManager sharedManager] requestLoginWithThirdType:LXMThirdLoginTypeWeChat completeBlock:^(LXMThirdLoginResult *thirdLoginResult) {
//        if (thirdLoginResult && thirdLoginResult.thirdLoginState == 0) {
//            NSLog(@"thirdLoginResult is %@", thirdLoginResult);
//            NSLog(@"登陆成功了得哦 0000");
//        } else {
//            
//        }
//    }];
//}

- (void)WeiXinLogin:(EnterButton *)sender
{
    YunLog(@"微信登陆按钮被点击");
//    if ([WXApi isWXAppInstalled]) {

        [self sendAutoRequest];
        
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:@"未安装微信客户端，去下载？"
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"现在下载", nil];
//        [alert show];
//    }
}

- (void)sendAutoRequest
{
    AppDelegate *appDelegate = kAppDelegate;
    appDelegate.shareType = LoginToWeiXin;
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = kWeiXinAppID;
    
    [WXApi sendReq:req];
}

- (void)commitLogin:(UIButton *)sender
{
    YunLog(@"username = %@, password = %@, phone = %@, verifyCode = %@", _username, _password, _phone, _verifyCode);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if (_accountButton.isSelected) {
        if ([_username isEqualToString:@""]) {
            [_hud addErrorString:@"请输入用户名" delay:1.0];
            
            return;
        } else if ([_password isEqualToString:@""]) {
            [_hud addErrorString:@"请输入密码" delay:5.0];
            
            return;
        }
    } else {
        if ([_phone isEqualToString:@""]) {
            [_hud addErrorString:@"请输入手机号" delay:1.0];
            
            return;
        } else if (_phone.length > 0 && _phone.length != 11) {
            [_hud addErrorString:@"请输入正确手机号" delay:1.0];
            
            return;
        } else if ([_verifyCode isEqualToString:@""]) {
            [_hud addErrorString:@"请输入验证码" delay:1.0];
            
            return;
        }
    }
    
    _hud.labelText = @"登录...";
    
    NSString *loginURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kSignInURL params:nil];
    
    YunLog(@"loginURL = %@", loginURL);
    
    NSDictionary *params;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSString *login = @"";
    
    if (_accountButton.isSelected) {
        
        @try {
            login = _username;
            
            params = @{@"login"                 :   _username,
                       @"password"              :   _password,
                       @"phone_code_type"       :   @"sign_in",
                       @"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey),
                       @"source"                :   @"1"};
        }
        @catch (NSException *exception) {
            YunLog(@"commit login params exception = %@", exception);
            
            params = @{};
        }
        @finally {
            
        }
        
    } else {
        
        @try {
            login = _phone;
            
            params = @{@"login"                 :   _phone,
                       @"phone_code"            :   _verifyCode,
                       @"phone_code_type"       :   @"sign_in",
                       @"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey)};
        }
        @catch (NSException *exception) {
            YunLog(@"commit login params exception = %@", exception);
            
            params = @{};
        }
        @finally {
            
        }
    }
    
    YunLog(@"login params = %@", params);
    
    sender.enabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:loginURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"login responseObject = %@", responseObject);
              
              NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
              if ([code isEqualToString:kSuccessCode]) {
                  AppDelegate *appDelegate = kAppDelegate;
                  
                  NSDictionary *userDic = [[responseObject objectForKey:@"data"] objectForKey:@"user"];
                  appDelegate.user.username = login;
                  appDelegate.user.password = _password;
                  appDelegate.user.display_name = [userDic objectForKey:@"display_name"];
                  appDelegate.user.userType = [[userDic objectForKey:@"user_type"] integerValue];
                  appDelegate.user.userSessionKey = [userDic objectForKey:@"user_session_key"];
                  appDelegate.user.birthday = [userDic objectForKey:@"birthday"];
                  appDelegate.user.nickname = [userDic objectForKey:@"nick_name"];
                  appDelegate.user.phone = [userDic objectForKey:@"phone"];
                  appDelegate.login = YES;
                  
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  
                  [defaults setObject:login forKey:@"username"];
                  [defaults setObject:[userDic objectForKey:@"user_session_key"] forKey:@"user_session_key"];
                  [defaults setObject:login forKey:@"lastContactPhone"];
                  [defaults setObject:appDelegate.user.display_name forKey:@"display_name"];
                  [defaults setObject:[[userDic objectForKey:@"user_type"] stringValue] forKey:@"userType"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"birthday"]) forKey:@"birthday"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"nickname"]) forKey:@"nickname"];
                  [defaults setObject:kNullToString([userDic objectForKey:@"phone"]) forKey:@"phone"];
                  
                  [defaults synchronize];
                  
                  _username = @"";
                  _password = @"";
                  _phone = @"";
                  _verifyCode = @"";
                  
                  [_hud addSuccessString:@"登录成功" delay:1.0];
                  
                  if (_isReturnView == YES && appDelegate.user.userType == 1) {
                      [self returnView];
                  } else {
                      if (appDelegate.user.userType == 2 || appDelegate.user.userType == 3) {
                          [self doneEditing];

                          [self getMyShopsData];
                      }
                      
                      if (appDelegate.user.userType == 1) {
                          AppDelegate *appDelegate = kAppDelegate;
                          
                          _hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
                          _hud.labelText = @"正在努力跳转...";
                          
                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                              [_hud hide:YES];
                              
                              appDelegate.indexTab = [[IndexTabViewController alloc] init];
                              
                              appDelegate.window.rootViewController = appDelegate.indexTab;
                              [appDelegate.window makeKeyAndVisible];
                          });
                      }
                  }
              } else {
                  [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"]
                                 delay:1.0];
                  sender.enabled = YES;
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              YunLog(@"login error = %@", error);
              
              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
              
              sender.enabled = YES;
          }
     ];
}

- (void)getMyShopsData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.shops.count <= 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"获取商铺列表...";
        
        NSDictionary *params = @{@"user_session_key":kNullToString(appDelegate.user.userSessionKey)};
        
        NSString *myShopsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShopAdminShopsURL params:params];
        
        YunLog(@"myShopsURL = %@", myShopsURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:myShopsURL
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"my shop responseObject = %@", responseObject);
                 
                 [_hud hide:YES];
                 
                 NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
                 
                 if ([code isEqualToString:kSuccessCode]) {
                     appDelegate.user.shops = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"shop_list"]);
                     
                     [self pushToShop];
                 } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                     [Tool resetUser];
                     
                 } else {
                     [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                    delay:2.0];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 YunLog(@"my shop error = %@", error);
                 
                 if (![operation isCancelled]) {
                     [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                 }
             }];
    } else {
        [self pushToShop];
    }
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
        
        [_verifyCodeButton setTitle:[NSString stringWithFormat:@"验证码 %d", _verifyCodeCount] forState:UIControlStateNormal];
    }
}

- (void)textFieldWithText:(UITextField *)textField
{
    switch (textField.tag) {
        case LoginName:
            _username = textField.text;
            break;
            
        case LoginPassword:
            _password = textField.text;
            break;
            
        case LoginPhone:
            _phone = textField.text;
            break;
            
        case LoginVerifyCode:
            _verifyCode = textField.text;
            break;
            
        default:
            break;
    }
}

- (void)keyboardWillShowForLoginNumberPad
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // 找到键盘view
        UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        
        UIView *keyboard;
        
        for (int i = 0; i < [tempWindow.subviews count]; i++){
            keyboard = [tempWindow.subviews objectAtIndex:i];
            
            YunLog(@"[keyboard description] = %@", [keyboard description]);
            YunLog(@"keyboard.frame = %@", NSStringFromCGRect(keyboard.frame));
            
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
                    [UIView animateWithDuration:0.1
                                     animations:^{
                                         _dismissButton.hidden = NO;
                                         _dismissButton.frame = CGRectMake(0, marginTop, kScreenWidth, 30);
                                     }];
                }
                
                break;
            }
        }
    });
}

- (void)keyboardWillRemoveForLoginNumberPad
{
    _dismissButton.hidden = YES;
}

- (void)doneEditing
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self keyboardWillRemoveForLoginNumberPad];
    
    _nameText.delegate = nil;
    _phoneText.delegate = nil;
}

- (void)dismissKeyboard:(UIButton *)sender
{
    [self doneEditing];
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self keyboardWillShowForLoginNumberPad];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == LoginPassword) {
        textField.secureTextEntry = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self doneEditing];
    
    [self commitLogin:(UIButton *)[self.view viewWithTag:10010]];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    
    NSString *aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == LoginVerifyCode) {
        if ([aString length] > 4) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"验证码为4位数字" delay:1.0];
            
            return NO;
        }
    }
    
    return YES;
}

@end
