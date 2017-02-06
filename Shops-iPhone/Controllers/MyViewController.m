//
//  MyViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "MyViewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"

// Views
#import "SplitLineView.h"
#import "RoundButton.h"
#import "UIButtonForBarButton.h"

// Controllers
#import "AddressListViewController.h"
#import "LoginViewController.h"
#import "OrderListViewController.h"
#import "UpdatePasswordViewController.h"
#import "FavoriteListViewController.h"
#import "AdminOrderListViewController.h"
#import "MyShopListViewController.h"
#import "MyShopViewController.h"
#import "PickPictureViewController.h"

@interface MyViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *salerView;
@property (nonatomic, strong) UILabel *guideLabel;
@property (nonatomic, strong) UIView *myShop;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"个人中心";
        
        self.navigationItem.titleView = naviTitle;
        
        self.tabBarItem.image = [[UIImage imageNamed:@"my_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"my_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem.title = @"个人中心";
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *count = [[CartManager defaultCart] productCount];
    UIViewController *cartVC = [self.tabBarController.viewControllers objectAtIndex:1];
    
    if ([count isEqualToString:@"0"]) {
        cartVC.tabBarItem.badgeValue = nil;
    } else {
        cartVC.tabBarItem.badgeValue = count;
    }
    
    [self changeUserStatus];
    
//    [TalkingData trackPageBegin:@"进入我的页面"];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [TalkingData trackPageEnd:@"离开我的页面"];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    YunLog(@"%f", kScreenWidth);
    YunLog(@"%f", kScreenHeight);
    
    self.view.backgroundColor = kBackgroundColor;
    
//    UIButtonForBarButton *button = [[UIButtonForBarButton alloc] initWithTitle:@"" wordLength:@"2"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button setBackgroundColor:kClearColor];
    button.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;

    AppDelegate *appDelegate = kAppDelegate;

    if (appDelegate.isLogin) {
        [button setTitle:@"退出" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button setTitle:@"登录" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:button];
    rightBar.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = rightBar;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48)];
    _scrollView.backgroundColor = kClearColor;
    _scrollView.contentSize = CGSizeMake(kScreenWidth, 0);
    _scrollView.scrollEnabled = NO;
    _scrollView.delegate = self;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:_scrollView];
    
    UILabel *account = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 40, 40)];
    
    account.backgroundColor = kClearColor;
    account.font = kNormalFont;
    account.textColor = [UIColor lightGrayColor];
    account.text = @"账户";
    
    [_scrollView addSubview:account];
    
    _username = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 40)];
    _username.backgroundColor = kClearColor;
    _username.font = kNormalFont;
    _username.textColor = [UIColor orangeColor];
    _username.text = kNullToString(appDelegate.user.display_name);
    
    [_scrollView addSubview:_username];
    
    SplitLineView *line = [[SplitLineView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 1)];
    
    [_scrollView addSubview:line];
    
    int height = 41;
    
    float itemWidth = kScreenWidth / 4;
    
    NSArray *accountNameArray = @[@"地址管理", @"我的收藏", @"修改密码"];
    NSArray *accountImageArray = @[@"address_manage_rd", @"my_favorite_rd", @"password_manage_rd"];
    
    for (int i = 0; i < accountNameArray.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i % 4 * itemWidth, height + i / 4 * itemWidth, itemWidth, itemWidth)];
        button.tag = i;
        
        if (!kIsiPhone) [button addBorderWithDirection:(AddBorderDirectionBottom | AddBorderDirectionRight)];
        
        [button addTarget:self action:@selector(pushToAccount:) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:button];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - 50) / 2, (itemWidth - 50 - 5 - 14) / 2, 50, 50)];
        imageView.image = [UIImage imageNamed:accountImageArray[i]];
        
        [button addSubview:imageView];
        
        UILabel *orderName = [[UILabel alloc] initWithFrame:CGRectMake(0, (itemWidth - 50 - 5 - 14) / 2 + 50 + 5, itemWidth, 14)];
        orderName.backgroundColor = kClearColor;
        orderName.font = [UIFont fontWithName:kFontFamily size:14];
        orderName.textAlignment = NSTextAlignmentCenter;
        orderName.textColor = [UIColor grayColor];
        orderName.text = accountNameArray[i];
        
        [button addSubview:orderName];
    }
    
    if (accountNameArray.count % 4 == 0) {
        height += (accountNameArray.count / 4) * itemWidth + 20;
    } else {
        height += (accountNameArray.count / 4 + 1) * itemWidth + 20;
    }
    
    UILabel *order = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 220, 40)];
    order.backgroundColor = kClearColor;
    order.font = kNormalFont;
    order.textColor = [UIColor lightGrayColor ];
    order.text = @"订单";
    
    [_scrollView addSubview:order];
    
    height += 40;
    
    SplitLineView *orderLine = [[SplitLineView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 1)];
    
    [_scrollView addSubview:orderLine];
    
    height += 1;

    NSArray *nameArray = @[@"全部", @"待支付", @"待发货", @"待收货", @"已完成", @"已取消"];
    
    NSArray *imageArray = @[@"all_order_rd",
                            @"waiting_for_pay_rd",
                            @"waiting_for_send_rd",
                            @"waiting_for_receive_rd",
                            @"already_complete_rd",
                            @"already_cancel_rd"];
    
    int orderTypeArray[6] = {All, WaitingForPay, AlreadyPay, WaitingForReceive, AlreadyComplete, AlreadyCancel};
    
    for (int i = 0; i < 6; i++) {
        UIButton *orderButton = [[UIButton alloc] initWithFrame:CGRectMake(i % 4 * itemWidth, height + i / 4 * itemWidth, itemWidth, itemWidth)];
        orderButton.tag = orderTypeArray[i];
        
        if (!kIsiPhone) [orderButton addBorderWithDirection:(AddBorderDirectionBottom | AddBorderDirectionRight)];
        
        [orderButton addTarget:self action:@selector(pushToOrder:) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:orderButton];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - 50) / 2, (itemWidth - 50 - 5 - 14) / 2, 50, 50)];
        imageView.image = [UIImage imageNamed:imageArray[i]];
        
        [orderButton addSubview:imageView];
    
        UILabel *orderName = [[UILabel alloc] initWithFrame:CGRectMake(0, (itemWidth - 50 - 5 - 12) / 2 + 50 + 5, itemWidth, 14)];
        orderName.backgroundColor = kClearColor;
        orderName.font = [UIFont fontWithName:kFontFamily size:14];
        orderName.textAlignment = NSTextAlignmentCenter;
        orderName.textColor = [UIColor grayColor];
        orderName.text = nameArray[i];
        
        [orderButton addSubview:orderName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

#pragma mark - Private Functions -

- (void)pushToAccount:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    
    if (sender.tag == 0) {
        AddressListViewController *address = [[AddressListViewController alloc] init];
        address.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:address animated:YES];
    }
    
    else if (sender.tag == 1) {
        FavoriteListViewController *favorite = [[FavoriteListViewController alloc] init];
        favorite.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:favorite animated:YES];
    }
    
//    else if (sender.tag == 2) {
//        PickPictureViewController *pickPic = [[PickPictureViewController alloc] init];
//        
//        [self.navigationController pushViewController:pickPic animated:YES];
//        UpdatePasswordViewController *password = [[UpdatePasswordViewController alloc] init];
//        password.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:password animated:YES];
//    }
    
    else if (sender.tag == 3) {
        
    }
}

- (void)pushToAddress
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    
    AddressListViewController *address = [[AddressListViewController alloc] init];
    address.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:address animated:YES];
}

- (void)pushToPassword
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    
    UpdatePasswordViewController *password = [[UpdatePasswordViewController alloc] init];
    password.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:password animated:YES];
}

- (void)pushToOrder:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    
    OrderListViewController *order = [[OrderListViewController alloc] init];
    order.hidesBottomBarWhenPushed = YES;
    order.orderType = sender.tag;
    
    [self.navigationController pushViewController:order animated:YES];
}

- (void)pushToAdminOrder:(UIButton *)sender
{
    AdminOrderListViewController *list = [[AdminOrderListViewController alloc] init];
    list.hidesBottomBarWhenPushed = YES;
    list.orderType = sender.tag;
    
    [self.navigationController pushViewController:list animated:YES];
}

- (void)login
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.isReturnView = YES;
    
//    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
//    
//    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)logout
{
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.user = nil;
    appDelegate.user = [[User alloc] init];
    appDelegate.login = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:nil forKey:@"user_session_key"];
    [defaults setObject:nil forKey:@"userType"];
    [defaults setObject:nil forKey:@"lastSelectedShop"];
    [defaults setObject:nil forKey:@"display_name"];
//    [defaults setObject:nil forKey:@"birthday"];
//    [defaults setObject:nil forKey:@"nickname"];
//    [defaults setObject:nil forKey:@"phone"];

    [defaults synchronize];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [_hud addSuccessString:@"已安全退出" delay:2.0];
    
    [self changeUserStatus];
}

- (void)changeUserStatus
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _username.text = kNullToString(appDelegate.user.username);

//    UIButtonForBarButton *button = [[UIButtonForBarButton alloc] initWithTitle:@"" wordLength:@"2"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button setBackgroundColor:kClearColor];
    button.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if (appDelegate.isLogin) {
        [button setTitle:@"退出" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button setTitle:@"登录" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:button];
    rightBar.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = rightBar;
    
    if (!appDelegate.isLogin) {
        _scrollView.scrollEnabled = NO;
        _scrollView.pagingEnabled = NO;
        
        [_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight) animated:YES];
        
        _myShop.hidden = YES;
        
//        _pageControl.hidden = YES;
//        _guideLabel.hidden = YES;
    } else {
        if (appDelegate.user.userType == UserBuyer)
        {
            _scrollView.scrollEnabled = NO;
            _scrollView.pagingEnabled = NO;
            
            [_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight) animated:YES];
            
            _myShop.hidden = YES;
//            _pageControl.hidden = YES;
//            _guideLabel.hidden = YES;
        }
        else if (appDelegate.user.userType == UserSaler || appDelegate.user.userType == UserDistributor)
        {
            if (!_myShop) {
                CGFloat itemWidth = kScreenWidth / 4;
                
                _myShop = [[UIView alloc] initWithFrame:CGRectMake(3 * itemWidth, 41, itemWidth, itemWidth)];
                _myShop.backgroundColor = kClearColor;
                
                [_scrollView addSubview:_myShop];
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _myShop.frame.size.width, _myShop.frame.size.width)];
                [button addTarget:self action:@selector(getMyShops) forControlEvents:UIControlEventTouchUpInside];
                
                if (!kIsiPhone) [button addBorderWithDirection:(AddBorderDirectionBottom | AddBorderDirectionRight)];
                
                [_myShop addSubview:button];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - 50) / 2, (itemWidth - 50 - 5 - 14) / 2, 50, 50)];
                imageView.image = [UIImage imageNamed:@"shop_rd"];
                
                [button addSubview:imageView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (itemWidth - 50 - 5 - 12) / 2 + 50 + 5, itemWidth, 14)];
                label.backgroundColor = kClearColor;
                label.font = [UIFont fontWithName:kFontFamily size:14];
                label.textColor = [UIColor grayColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"我的商铺";
                
                [button addSubview:label];
            } else {
                _myShop.hidden = NO;
            }
            
//            if (!_pageControl) {
//                _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2, kScreenHeight - 48 - 40, 100, 20)];
//                
//                if (kDeviceOSVersion < 7.0) {
//                    _pageControl.frame = CGRectMake((kScreenWidth - 100) / 2, kScreenHeight - 88 - 64, 100, 20);
//                }
//                
//                _pageControl.numberOfPages = 2;
//                
//                if (kDeviceOSVersion >= 6.0) {
//                    _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
//                    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
//                }
//                
//                [self.view addSubview:_pageControl];
//                
//                _guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 110, kScreenHeight - 88, 100, 20)];
//                
//                if (kDeviceOSVersion < 7.0) {
//                    _guideLabel.frame = CGRectMake(kScreenWidth - 110, kScreenHeight - 88 - 64, 100, 20);
//                }
//                
//                _guideLabel.backgroundColor = kClearColor;
//                _guideLabel.font = kSmallFont;
//                _guideLabel.textColor = [UIColor lightGrayColor];
//                _guideLabel.text = @"右滑切换到商铺 >";
//                _guideLabel.textAlignment = NSTextAlignmentRight;
//                
//                [self.view addSubview:_guideLabel];
//            } else {
//                _pageControl.hidden = NO;
//                _guideLabel.hidden = NO;
//            }
//            
//            _pageControl.currentPage = 0;
            
            _scrollView.scrollEnabled = YES;
            _scrollView.pagingEnabled = YES;
            
//            [self generateSalerView];
            
            [_scrollView scrollRectToVisible:CGRectMake(0, 0, kScreenWidth, kScreenHeight) animated:YES];
        }
    }
}

- (void)getMyShops
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.shops.count <= 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"获取商铺列表...";
        
        NSDictionary *params = @{@"user_session_key":kNullToString(appDelegate.user.userSessionKey)};
        
        NSString *myShopsURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kShopMyShopsURL params:params];
        
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
                     YunLog(@"appDelebgate.user.shops = %@", appDelegate.user.shops);
                     
                     [self pushToShop];
                 } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                     [Tool resetUser];
                     
                     [self changeUserStatus];
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

- (void)pushToShop
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *shopCode = [defaults objectForKey:@"lastSelectedShop"];
    
    if (!shopCode) {
        [defaults setObject:@"0" forKey:@"lastSelectedShop"];
        
        [defaults synchronize];
    } else {
        AppDelegate *appDelegate = kAppDelegate;
        
        for (int i = 0; i < appDelegate.user.shops.count; i++) {
            if ([[appDelegate.user.shops[i] objectForKey:@"code"] isEqualToString:shopCode]) {
                MyShopViewController *myShop = [[MyShopViewController alloc] init];
                myShop.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:myShop animated:YES];
                
                return;
            }
        }
        
        [defaults setObject:@"0" forKey:@"lastSelectedShop"];
        
        [defaults synchronize];
    }
    
    MyShopListViewController *myShop = [[MyShopListViewController alloc] init];
    myShop.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:myShop animated:YES];
}

- (void)generateSalerView
{
    if (!_salerView) {
        _salerView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, _scrollView.frame.size.height)];
        _salerView.backgroundColor = kClearColor;
        
        [_scrollView addSubview:_salerView];
        
        int height = 10;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 220, 14)];
        titleLabel.backgroundColor = kClearColor;
        titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
        titleLabel.textColor = [UIColor lightGrayColor ];
        titleLabel.text = @"商铺";
        
        [_salerView addSubview:titleLabel];
        
        height += 14 + 8;
        
        SplitLineView *orderLine = [[SplitLineView alloc] initWithFrame:CGRectMake(15, height, 290, 1)];
        
        [_salerView addSubview:orderLine];
        
        height += 1 + 10;
        
        NSArray *nameArray = @[@"全部", @"待支付", @"待发货", @"待收货", @"已完成", @"已取消"];
        NSArray *imageArray = @[[UIImage imageNamed:@"admin_order_all_rd"],
                                [UIImage imageNamed:@"admin_order_pay_rd"],
                                [UIImage imageNamed:@"admin_order_send_rd"],
                                [UIImage imageNamed:@"admin_order_receive_rd"],
                                [UIImage imageNamed:@"admin_order_complete_rd"],
                                [UIImage imageNamed:@"admin_order_cancel_rd"]];
        
        int orderTypeArray[6] = {
            AdminOrderAll,
            AdminOrderWaitingForPay,
            AdminOrderWaitingForSend,
            AdminOrderWaitingForReceive,
            AdminOrderAlreadyComplete,
            AdminOrderAlreadyCancel
        };
        
        for (int i = 0; i < 6; i++) {
            UIButton *orderButton = [[UIButton alloc] initWithFrame:CGRectMake(15 + i % 4 * 80, height + i / 4 * 75, 50, 50)];
            orderButton.tag = orderTypeArray[i];
            [orderButton setImage:imageArray[i] forState:UIControlStateNormal];
            [orderButton addTarget:self action:@selector(pushToAdminOrder:) forControlEvents:UIControlEventTouchUpInside];
            
            [_salerView addSubview:orderButton];
            
            UILabel *orderName = [[UILabel alloc] initWithFrame:CGRectMake(15 + i % 4 * 80, height + i / 4 * 75 + 50 + 3, 50, 12)];
            orderName.backgroundColor = kClearColor;
            orderName.font = kSmallFont;
            orderName.textAlignment = NSTextAlignmentCenter;
            orderName.textColor = [UIColor grayColor];
            orderName.text = nameArray[i];
            
            [_salerView addSubview:orderName];
        }
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    _pageControl.currentPage = page;
    
    if (page == 1) {
        _guideLabel.hidden = YES;
    } else {
        _guideLabel.hidden = NO;
    }
}

@end
