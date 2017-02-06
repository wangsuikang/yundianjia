//
//  AdminLoginViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/5.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminHomeViewController.h"

// Commones
#import "LibraryHeadersForCommonController.h"

// Controlers
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "SaleAccedeViewController.h"
#import "PopGestureRecognizerController.h"
#import "RegisterViewController.h"
#import "WaitAuditingViewController.h"
#import "MyShopListViewController.h"
#import "MerchantsSettledViewController.h"

#define kBackWidth 100

@interface AdminHomeViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSArray *applyShops;

@end

@implementation AdminHomeViewController

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = kBackgroundColor;
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];
    
//    [self.navigationController setNavigationBarHidden:YES];
    
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
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO];

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

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    _applyShops = [NSArray array];
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    if (_isBuyEnter) {
//        button.frame = CGRectZero;
//    } else {
//        button.frame = CGRectMake(0, 0, 40, 40);
//        [button setImage:[UIImage imageNamed:@"sale_back"] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    backItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.leftBarButtonItem = backItem;
//    
//    // 背景视图
//    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    backgroundView.image = [UIImage imageNamed:@"admin_home_background"];
//    
//    [self.view addSubview:backgroundView];
//    
//    CGFloat space = kScreenHeight > 480 ? 80 : 60;
//    
//    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(space, space, kScreenWidth - space * 2, 0.75 * (kScreenWidth - space * 2))];
//    iconImage.image = [UIImage imageNamed:@"admin_login_icon"];
//    
//    [self.view addSubview:iconImage];
//    
//    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    registerButton.frame = CGRectMake(40, kScreenHeight / 2 + 30, kScreenWidth - 40 * 2, 0.2 * (kScreenWidth - 40 * 2));
//    [registerButton setImage:[UIImage imageNamed:@"admin_register"] forState:UIControlStateNormal];
//    [registerButton addTarget:self action:@selector(goToRegister) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:registerButton];
//    
//    UILabel *registerLabel = [[UILabel alloc] initWithFrame:registerButton.frame];
//    registerLabel.text = @"入驻";
//    registerLabel.font = [UIFont systemFontOfSize:25];
//    registerLabel.textAlignment = NSTextAlignmentCenter;
//    registerLabel.textColor = [UIColor whiteColor];
//    
//    [self.view addSubview:registerLabel];
//    
//    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    loginButton.frame = CGRectMake(40, CGRectGetMaxY(registerLabel.frame) + 20, kScreenWidth - 40 * 2, 0.2 * (kScreenWidth - 40 * 2));
//    [loginButton setImage:[UIImage imageNamed:@"admin_login"] forState:UIControlStateNormal];
//    [loginButton addTarget:self action:@selector(goToLogin) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:loginButton];
//    
//    UILabel *loginLabel = [[UILabel alloc] initWithFrame:loginButton.frame];
//    loginLabel.text = @"登录";
//    loginLabel.font = [UIFont systemFontOfSize:25];
//    loginLabel.textAlignment = NSTextAlignmentCenter;
//    loginLabel.textColor = [UIColor whiteColor];
//    
//    [self.view addSubview:loginLabel];
//    
//    [self getData];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _applyShops = [NSArray array];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_isBuyEnter) {
        button.frame = CGRectZero;
    } else {
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    // 背景视图
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    backgroundView.image = [UIImage imageNamed:@"admin_login_background_new"];
    
    [self.view addSubview:backgroundView];
        
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(120, 84, kScreenWidth - 240, kScreenWidth - 240)];
    
    if (kScreenWidth == 414) {
        icon.frame = CGRectMake((kScreenWidth - 120) / 2, 84, 120, 120);
    }
    
    if (!kIsiPhone) {
        icon.frame = CGRectMake((kScreenWidth - 150) / 2, 84, 150, 150);
    }
    icon.image = [UIImage imageNamed:@"admin_login_companyicon"];
    
    [self.view addSubview:icon];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(20, kScreenHeight / 2, kScreenWidth - 2 * 20, 40)];
    registerButton.backgroundColor = kOrangeColor;
    registerButton.layer.masksToBounds = YES;
    registerButton.layer.cornerRadius = 20;
    [registerButton addTarget:self action:@selector(goToRegister) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registerButton];
    
    UILabel *registerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, registerButton.frame.size.width, registerButton.frame.size.height)];
    registerLabel.text = @"入驻";
    registerLabel.textColor = [UIColor whiteColor];
    registerLabel.font = kFont;
    registerLabel.textAlignment= NSTextAlignmentCenter;
    
    [registerButton addSubview:registerLabel];

    
    UILabel *chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2, CGRectGetMaxY(registerButton.frame) + 30, 100, 20)];
    chooseLabel.text = @"or";
    chooseLabel.font = kFont;
    chooseLabel.textColor = [UIColor whiteColor];
    chooseLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:chooseLabel];
    
    UIImageView *leftLine = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(registerButton.frame) + 30 + 9, kScreenWidth / 2 - chooseLabel.frame.size.width / 2 - 20, 2)];
    leftLine.image = [UIImage imageNamed:@"left_line"];
    
    [self.view addSubview:leftLine];
    
    UIImageView *rightLine = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(chooseLabel.frame), CGRectGetMaxY(registerButton.frame) + 30 + 9, kScreenWidth / 2 - chooseLabel.frame.size.width / 2 - 20, 2)];
    rightLine.image = [UIImage imageNamed:@"right_line"];
    
    [self.view addSubview:rightLine];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(chooseLabel.frame) + 30, kScreenWidth - 2 * 20, 40)];
    loginButton.backgroundColor = [UIColor whiteColor];
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 20;
    [loginButton addTarget:self action:@selector(goToLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    
    UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loginButton.frame.size.width, loginButton.frame.size.height)];
    loginLabel.text = @"登录";
    loginLabel.textColor = kOrangeColor;
    loginLabel.font = kFont;
    loginLabel.textAlignment= NSTextAlignmentCenter;
    
    [loginButton addSubview:loginLabel];
    
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Btn Click -

- (void)backClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GetData -

- (void)getData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    NSDictionary *params = @{@"terminal_session_key"        :       kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"            :       kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *applyURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kApplyShopsURL params:params];
    
    YunLog(@"applyURL = %@", applyURL);
    
    [manager GET:applyURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"%@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            _applyShops = [[responseObject objectForKey:@"data"] objectForKey:@"apply_shops"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        
        [_hud addErrorString:@"入驻申请出现异常" delay:2.0];
    }];
}

#pragma mark - Private Functions -

- (void)goToRegister
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSString *status = [[_applyShops firstObject] objectForKey:@"status"];
    
    if ((appDelegate.isLogin || _isBuyEnter == YES) && status.length > 0)
    {
        if ([status isEqualToString:@"3"]) {
            for (id so in appDelegate.window.subviews) {
                [so removeFromSuperview];
            }
            
            MyShopListViewController *shopVC = [[MyShopListViewController alloc] init];
            
            PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:shopVC] ;
            
            appDelegate.window.rootViewController = popNC;
            [appDelegate.window makeKeyAndVisible];
        } else {
            WaitAuditingViewController *waitVC = [[WaitAuditingViewController alloc] init];
            waitVC.status = status;
            
            [self.navigationController pushViewController:waitVC animated:YES];
        }
    }  else if (appDelegate.isLogin || _isBuyEnter == YES) {
        
//        SaleAccedeViewController *saleVc = [[SaleAccedeViewController alloc] init];
//        saleVc.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:saleVc animated:YES];
        
        MerchantsSettledViewController *merchantsSettled = [[MerchantsSettledViewController alloc] init];
        merchantsSettled.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:merchantsSettled animated:YES];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"要先登录或注册云店家用户" delay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:loginVC animated:YES];
        });
    }
}

- (void)goToLogin
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    loginVC.isEnterShops = YES;
    
    [self.navigationController pushViewController:loginVC animated:YES];
}


@end
