//
//  MyBullViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/7/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyIndividualViewController.h"

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
#import "MyInfoViewController.h"
#import "MyPreferentialViewController.h"
#import "MyHistoryViewController.h"
#import "MyShopViewController.h"
#import "MyShopListViewController.h"
#import "AdminShopViewController.h"
#import "AdminHomeViewController.h"
#import "PopGestureRecognizerController.h"
#import "OrderButton.h"

#define kIconWidth (kScreenWidth > 375 ? 65 * 1.293 : (kScreenWidth > 320 ? 65 * 1.17 : 65))
#define kBtnWidth (kScreenWidth > 375 ? 40 * 1.293 : (kScreenWidth > 320 ? 40 * 1.17 : 40))
#define kSmallViewHeight 44
#define kLeftIconViewHeight 24
#define kMyBullSpace 10
#define kTopBgViewHeight (kScreenWidth / 375) * 210


@interface MyIndividualViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UIButton *loginWithExitBtn;
@property (nonatomic, strong) UIButton *myInfoBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imageSource;
@property (nonatomic, strong) NSMutableArray *titleSource;
@property (nonatomic, strong) NSArray *orderTypeArray;
@property (nonatomic, copy) NSString *shopID;

@property (nonatomic,assign) NSInteger  height;

/// 头像路径
@property (nonatomic, strong) NSString *imagePath;

@end

@implementation MyIndividualViewController

#pragma mark - Function -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.tabBarItem.image = [[UIImage imageNamed:@"my_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"my_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem.title = @"个人中心";
        
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"个人中心";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    self.tabBarController.tabBar.hidden = NO;
    
//    self.navigationController.navigationBar.translucent = YES;
    
//    // 设置透明导航栏
//    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
//    {
//        NSArray *list = self.navigationController.navigationBar.subviews;
//        
//        for (id obj in list) {
//            if ([obj isKindOfClass:[UIImageView class]]) {
//                UIImageView *imageView = (UIImageView *)obj;
//                imageView.alpha = 0.0;
//            }
//        }
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, kScreenWidth, 64)];
//        
//        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
//        
//        [self.navigationController.navigationBar addSubview:imageView];
//        
//        [self.navigationController.navigationBar sendSubviewToBack:imageView];
//    }
    
    UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
    NSString *cartCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"];
    if ([cartCount intValue] == 0) {
        cartVC.tabBarItem.badgeValue = nil;
    } else {
        cartVC.tabBarItem.badgeValue = cartCount;
    }
    
    [self changeUserStatus];
    
//    if (appDelegate.user.userType == userSaler || appDelegate.user.userType == userDistributor) {
//        [_imageSource removeAllObjects];
//        [_titleSource removeAllObjects];
//        
//        [self getData];
//        
//        [_tableView reloadData];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
//    // 设置透明导航栏
//    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
//    {
//        NSArray *list = self.navigationController.navigationBar.subviews;
//        
//        for (id obj in list)
//        {
//            if ([obj isKindOfClass:[UIImageView class]])
//            {
//                UIImageView *imageView = (UIImageView *)obj;
//                
//                imageView.alpha = 1.0;
//            }
//        }
//    }
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    // 指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
    
    // 创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    // 保存图片的路径
    _imagePath = [imageDocPath stringByAppendingPathComponent:@"image.png"];
    
    self.view.backgroundColor = kGrayColor;
    
    [self getData];
    
    YunLog(@"topHeight = %f", kTopBgViewHeight);
    
    [self createView];
    
//    [self createTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getData -

- (void)getData
{
    NSArray *imageArray = @[@"all_order_rd", @"waiting_for_pay_rd", @"waiting_for_send_rd", @"waiting_for_receive_rd",@"already_complete_rd"];
    NSArray *titleArray = @[@"全部", @"待支付", @"待发货", @"待收货",@"已完成订单"];
    
    NSArray *preferentialArray = @[@"preferential_price"];
    NSArray *preferentialTitleArray = @[@"优惠劵"];
    
    NSArray *buySaleArray = @[@"buy_sale_barter"];
    NSArray *buySaleTitleArray = @[@"卖家在这里"];
    
    _imageSource = [NSMutableArray arrayWithObjects:imageArray, preferentialArray, buySaleArray,nil];
    
    _titleSource = [NSMutableArray arrayWithObjects:titleArray, preferentialTitleArray, buySaleTitleArray, nil];
}

#pragma mark - Analyzing Login Status -

- (void)changeUserStatus
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _userName.text = kNullToString(appDelegate.user.display_name);
    
    if (appDelegate.isLogin) {
//        UIImage *image=[UIImage imageWithContentsOfFile:_imagePath];
        
//        if (image == nil)
//        {
            [_iconBtn setImage:[UIImage imageNamed:@"user_icon_shop"] forState:UIControlStateNormal];
//        }
//        else
//        {
//            [_iconBtn setImage:image forState:UIControlStateNormal];
//        }

        [_loginWithExitBtn setTitle:@"退出" forState:UIControlStateNormal];
        
        [_loginWithExitBtn removeTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [_loginWithExitBtn removeTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginWithExitBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_iconBtn setImage:[UIImage imageNamed:@"user_icon_shop"] forState:UIControlStateNormal];
       
        [_loginWithExitBtn setTitle:@"登录" forState:UIControlStateNormal];
        
        [_loginWithExitBtn removeTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [_loginWithExitBtn removeTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginWithExitBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - createUI -

- (void)createTopView
{
    AppDelegate *appDelegate = kAppDelegate;
    
    // 添加后面背景视图view
    _topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kTopBgViewHeight)];
    
    [self.view addSubview:_topBgView];
    
    // 添加背景图片
    _bgImageView = [[UIImageView alloc] initWithFrame:_topBgView.bounds];
    _bgImageView.image = [UIImage imageNamed:@"admin_topBg"];
    
    [_topBgView addSubview:_bgImageView];
    
    // TODO
    // 添加中间头像的按钮图标 表色边框等待以后处理
    _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _iconBtn.frame = CGRectMake((kScreenWidth - kIconWidth) / 2, 40, kIconWidth, kIconWidth);
    [_iconBtn addTarget:self action:@selector(enterMyInformation:) forControlEvents:UIControlEventTouchUpInside];
//    _iconBtn.backgroundColor = [UIColor redColor];
//    _iconBtn.layer.borderColor   = [UIColor whiteColor].CGColor;
//    _iconBtn.layer.borderWidth   = 1.5f;
//    _iconBtn.layer.masksToBounds = YES;
//    _iconBtn.layer.cornerRadius  = 5;
    
//    if (!appDelegate.isLogin)
//    {
        [_iconBtn setImage:[UIImage imageNamed:@"user_icon_shop"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        //根据图片路径载入图片
//        UIImage *image=[UIImage imageWithContentsOfFile:_imagePath];
//        
//        if (image == nil)
//        {
//            [_iconBtn setImage:[UIImage imageNamed:@"user_icon_1"] forState:UIControlStateNormal];
//        }
//        else
//        {
//            [_iconBtn setImage:image forState:UIControlStateNormal];
//        }
//    }
//
//    [_iconBtn setImageEdgeInsets:UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5)];
    
    [_topBgView addSubview:_iconBtn];
    
    // 添加账户名称
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconBtn.frame) + 15, kScreenWidth, 20)];
    _userName.text = kNullToString(appDelegate.user.display_name);
    if (kIsiPhone) {
        _userName.font = [UIFont boldSystemFontOfSize:kFontNormalSize];
    } else {
        _userName.font = [UIFont boldSystemFontOfSize:kFontSize];
    }
    _userName.textColor = [UIColor whiteColor];
    _userName.textAlignment = NSTextAlignmentCenter;
    
    [_topBgView addSubview:_userName];
    
    // 添加登录  退出按钮
    _loginWithExitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [_loginWithExitBtn setTitleColor:kNaviTitleColor forState:UIControlStateNormal];
    if (appDelegate.isLogin) {
        [_loginWithExitBtn setTitle:@"退出" forState:UIControlStateNormal];
        [_loginWithExitBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_loginWithExitBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginWithExitBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    if (kIsiPhone) {
        _loginWithExitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kFontBigSize];
    } else {
        _loginWithExitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kFontLargeSize];
    }
    _loginWithExitBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);

//    [_topBgView addSubview:_loginWithExitBtn];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:_loginWithExitBtn];
    rightBar.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = rightBar;
    
    // 添加个人信息

//    _myInfoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
//    [_myInfoBtn setTitle:@"个人中心" forState:UIControlStateNormal];
//    [_myInfoBtn addTarget:self action:@selector(enterMyInformation:) forControlEvents:UIControlEventTouchUpInside];
//    [_myInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _myInfoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
//    _myInfoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);

//    

    //    [_topBgView addSubview:_myInfoBtn];

//    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:_myInfoBtn];
//    leftBar.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.leftBarButtonItem = leftBar;
    
    // 循环添加下面四个按钮
    NSArray *imageArray = [NSArray array];
   
    imageArray = @[@"address_administer", @"my_collection", @"pwd_administer", @"my_spoor"];
    
    NSArray *titleArray = @[@"地址管理", @"我的收藏", @"密码管理", @"我的足迹"];
    
    CGFloat btnY = CGRectGetMaxY(_userName.frame) + 10;
    CGFloat btnWidth = kBtnWidth;
    CGFloat btnHeight = kBtnWidth;
    CGFloat space = (kScreenWidth - (imageArray.count * btnWidth)) / 5;
    
    for (int i = 0; i < imageArray.count; i++) {
        CGFloat btnX = space + (btnWidth + space) * i;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
        [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        
        btn.tag = i;
        [btn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topBgView addSubview:btn];
        
        // 添加标题
        CGFloat labelY = 0;
        if (kIsiPhone) {
            labelY = btnY + btnHeight;
        } else {
            labelY = btnY + btnHeight + kMyBullSpace;
        }
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(btnX - 15, labelY, btnWidth + 30, 20)];
        label.text = titleArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        if (kIsiPhone) {
            label.font = [UIFont boldSystemFontOfSize:14];
        } else {
            label.font = [UIFont boldSystemFontOfSize:kFontSize];
        }
        
        [_topBgView addSubview:label];
    }
}

- (void)createView
{
    AppDelegate *appDelegate = kAppDelegate;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    [self.view addSubview:scrollView];
    
    // 添加后面背景视图view
    _topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopBgViewHeight)];
    
    [scrollView addSubview:_topBgView];
    
    // 添加背景图片
    _bgImageView = [[UIImageView alloc] initWithFrame:_topBgView.bounds];
    _bgImageView.image = [UIImage imageNamed:@"admin_topBg"];
    
    [_topBgView addSubview:_bgImageView];
    
    // TODO
    // 添加中间头像的按钮图标 表色边框等待以后处理
    _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _iconBtn.frame = CGRectMake((kScreenWidth - kIconWidth) / 2, _topBgView.frame.size.height / 2 - kIconWidth, kIconWidth, kIconWidth);
    [_iconBtn addTarget:self action:@selector(enterMyInformation:) forControlEvents:UIControlEventTouchUpInside];
    //    _iconBtn.backgroundColor = [UIColor redColor];
    //    _iconBtn.layer.borderColor   = [UIColor whiteColor].CGColor;
    //    _iconBtn.layer.borderWidth   = 1.5f;
    //    _iconBtn.layer.masksToBounds = YES;
    //    _iconBtn.layer.cornerRadius  = 5;
    
    //    if (!appDelegate.isLogin)
    //    {
    [_iconBtn setImage:[UIImage imageNamed:@"user_icon_shop"] forState:UIControlStateNormal];
    //    }
    //    else
    //    {
    //        //根据图片路径载入图片
    //        UIImage *image=[UIImage imageWithContentsOfFile:_imagePath];
    //
    //        if (image == nil)
    //        {
    //            [_iconBtn setImage:[UIImage imageNamed:@"user_icon_1"] forState:UIControlStateNormal];
    //        }
    //        else
    //        {
    //            [_iconBtn setImage:image forState:UIControlStateNormal];
    //        }
    //    }
    //
    //    [_iconBtn setImageEdgeInsets:UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5)];
    
    [_topBgView addSubview:_iconBtn];
    
    // 添加账户名称
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconBtn.frame) + 15, kScreenWidth, 20)];
    _userName.text = kNullToString(appDelegate.user.display_name);
    if (kIsiPhone) {
        _userName.font = [UIFont boldSystemFontOfSize:kFontNormalSize];
    } else {
        _userName.font = [UIFont boldSystemFontOfSize:kFontSize];
    }
    _userName.textColor = [UIColor whiteColor];
    _userName.textAlignment = NSTextAlignmentCenter;
    
    [_topBgView addSubview:_userName];
    
    // 添加登录  退出按钮
    _loginWithExitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [_loginWithExitBtn setTitleColor:kNaviTitleColor forState:UIControlStateNormal];
    if (appDelegate.isLogin) {
        [_loginWithExitBtn setTitle:@"退出" forState:UIControlStateNormal];
        [_loginWithExitBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_loginWithExitBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginWithExitBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
    if (kIsiPhone) {
        _loginWithExitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kFontBigSize];
    } else {
        _loginWithExitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kFontLargeSize];
    }
    _loginWithExitBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:_loginWithExitBtn];
    rightBar.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = rightBar;
    
    CGFloat myAllOrderViewHeight = kIsiPhone ? 40 : 60;
    
    UIView *myAllOrderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topBgView.frame) + 10, kScreenWidth, myAllOrderViewHeight)];
    myAllOrderView.backgroundColor = [UIColor whiteColor];
    
    [scrollView addSubview:myAllOrderView];
    
    UIImageView *myOrderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10,  kIsiPhone ? 20 : 40, kIsiPhone ? 20 : 40)];
    myOrderImageView.image = [UIImage imageNamed:@"all_order_rd"];
    
    [myAllOrderView addSubview:myOrderImageView];
    
    UILabel *myOrderLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(myOrderImageView.frame) + 10, 0, 100, myAllOrderViewHeight)];
    myOrderLabel.text = @"我的订单";
    myOrderLabel.font = kMidFont;
    myOrderLabel.textAlignment = NSTextAlignmentLeft;
    myOrderLabel.textColor = ColorFromRGB(0x282828);
    
    [myAllOrderView addSubview:myOrderLabel];
    
    CGFloat arrowImageHeight = kIsiPhone ? 15 : 30;
    CGFloat arrowImageWidth = kIsiPhone ? 10 : 20;
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20 - arrowImageWidth, (myAllOrderViewHeight - arrowImageHeight) / 2, arrowImageWidth, arrowImageHeight)];
    arrowImage.image = [UIImage imageNamed:@"order_arrow_right"];
    
    [myAllOrderView addSubview:arrowImage];
    
    UILabel *orderDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(arrowImage.frame) - 80 - arrowImageWidth, 0, 80, myAllOrderViewHeight)];
    orderDetailLabel.text = @"查看全部";
    orderDetailLabel.font = kMidFont;
    orderDetailLabel.textAlignment = NSTextAlignmentRight;
    orderDetailLabel.textColor = ColorFromRGB(0x686868);
    
    [myAllOrderView addSubview:orderDetailLabel];
    
    UIButton *myOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myOrderButton.frame = CGRectMake(-1, 0, kScreenWidth + 2, myAllOrderViewHeight);
    myOrderButton.layer.borderWidth = 0.5;
    myOrderButton.layer.borderColor = ColorFromRGB(0xb2b2b2).CGColor;
    myOrderButton.tag = 0;
    [myOrderButton addTarget:self action:@selector(goToOrderList:) forControlEvents:UIControlEventTouchUpInside];
    
    [myAllOrderView addSubview:myOrderButton];
    
    CGFloat buttonWidth = 80;
    CGFloat buttonHeight = kIsiPhone ? 55 : 80;
    
    UIView *myOrderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myAllOrderView.frame), kScreenWidth, buttonHeight)];
    myOrderView.backgroundColor = [UIColor whiteColor];
    
    [scrollView addSubview:myOrderView];
    
    CGFloat space = (kScreenWidth - buttonWidth * 4) / 6.5;
    NSArray *buttonImageArr = @[@"waiting_for_pay_rd", @"waiting_for_send_rd", @"waiting_for_receive_rd", @"already_complete_rd"];
    NSArray *buttonTittleArr = @[@"待付款", @"待发货", @"待收货", @"已完成"];
    
    for (int i = 0; i < 4; i ++) {
        OrderButton *button = [[OrderButton alloc] initWithFrame:CGRectMake(space + (buttonWidth + space *1.5) * i, 0, buttonWidth, buttonHeight)];
        [button setImage:[UIImage imageNamed:buttonImageArr[i]] forState:UIControlStateNormal];
        [button setTitle:buttonTittleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:ColorFromRGB(0x282828) forState:UIControlStateNormal];
        button.titleLabel.font = kMidFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.tag = i + 1;
        [button addTarget:self action:@selector(goToOrderList:) forControlEvents:UIControlEventTouchUpInside];
        
        [myOrderView addSubview:button];
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, myOrderView.frame.size.height - 0.5, kScreenWidth, 0.5)];
    line.backgroundColor = ColorFromRGB(0xb2b2b2);
    
    [myOrderView addSubview:line];
    [myOrderView bringSubviewToFront:line];

    CGFloat orderButtonWidth = (kScreenWidth - 1) / 3;
    CGFloat orderButtonHeight = kIsiPhone ? 80 : 120;
    CGFloat lineHeight = 0.5;
    
    
    NSArray *orderButtonImageArr = @[@"pwd_administer", @"address_administer", @"my_collection", @"preferential_price", @"my_spoor", @"my_saler"];
    NSArray *orderButtonTittleArr = @[@"密码管理", @"地址管理", @"我的收藏", @"优惠劵", @"我的足迹", @"卖家中心"];
    NSArray *orderButtonColorArr = @[ColorFromRGB(0x4368aa), ColorFromRGB(0x25c9cf), ColorFromRGB(0xf17843), ColorFromRGB(0xa719b4), ColorFromRGB(0x168b19), ColorFromRGB(0xa7292e)];

    
    for (int i = 0; i < 6; i ++)
    {
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        
        OrderButton *button = [[OrderButton alloc] initWithFrame:CGRectMake((lineHeight + orderButtonWidth) * col, CGRectGetMaxY(myOrderView.frame) + 10 + (lineHeight + orderButtonHeight) * row, orderButtonWidth, orderButtonHeight)];
        [button setImage:[UIImage imageNamed:orderButtonImageArr[i]] forState:UIControlStateNormal];
        [button setTitle:orderButtonTittleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:orderButtonColorArr[i] forState:UIControlStateNormal];
        button.titleLabel.font = kMidFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.tag = 100 + i;
        [button addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];

        button.backgroundColor = [UIColor whiteColor];

        [scrollView addSubview:button];
    }
    
    UIView *rowLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myOrderView.frame) + 10, kScreenWidth, lineHeight)];
    rowLine1.backgroundColor = kLineColor;
    [scrollView addSubview:rowLine1];
    
    UIView *rowLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myOrderView.frame) + 10 + orderButtonHeight, kScreenWidth, lineHeight)];
    rowLine2.backgroundColor = kLineColor;
    [scrollView addSubview:rowLine2];
    
    UIView *rowLine3 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(myOrderView.frame) + 10 + orderButtonHeight * 2, kScreenWidth, lineHeight)];
    rowLine3.backgroundColor = kLineColor;
    [scrollView addSubview:rowLine3];
    
    UIView *colLine1 = [[UIView alloc] initWithFrame:CGRectMake(orderButtonWidth, CGRectGetMaxY(myOrderView.frame) + 10, lineHeight, (orderButtonHeight + lineHeight) * 2)];
    colLine1.backgroundColor = kLineColor;
    [scrollView addSubview:colLine1];
    
    UIView *colLine2 = [[UIView alloc] initWithFrame:CGRectMake(orderButtonWidth * 2 + lineHeight, CGRectGetMaxY(myOrderView.frame) + 10, lineHeight, (orderButtonHeight + lineHeight) * 2)];
    colLine2.backgroundColor = kLineColor;
    
    [scrollView addSubview:colLine2];
    
    scrollView.contentSize = CGSizeMake(kScreenWidth, CGRectGetMaxY(rowLine3.frame) + 10);
}


//- (void)createTableView
//{

//    // 创建一个tableview
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topBgView.bounds.size.height, kScreenWidth, kScreenHeight - _topBgView.bounds.size.height - 48) style:UITableViewStyleGrouped];
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.sectionHeaderHeight = 0;
//    _tableView.backgroundColor = [UIColor whiteColor];
//    
//    [self.view addSubview:_tableView];
//}

#pragma mark - TopBtnClick -

- (void)goToOrderList:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    int orderTypeArray[6] = {All, WaitingForPay, AlreadyPay, WaitingForReceive, AlreadyComplete};
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    OrderListViewController *order = [[OrderListViewController alloc] init];
    order.hidesBottomBarWhenPushed = YES;
    order.orderType = orderTypeArray[sender.tag];
    order.selectedOrderTypeIndex = orderTypeArray[sender.tag];
    [self.navigationController pushViewController:order animated:YES];
}

- (void)enterMyInformation:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    
    MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] init];
    myInfoVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:myInfoVC animated:YES];
}

- (void)loginEnterSale
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.isReturnView = NO;
    loginVC.isBuyEnter = YES;
    
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
//    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)login
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.isReturnView = YES;
    loginVC.isBuyEnter = YES;
    
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
//    [self.navigationController pushViewController:loginVC animated:YES];
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
    [defaults setObject:nil forKey:@"birthday"];
    [defaults setObject:nil forKey:@"nickname"];
    [defaults setObject:nil forKey:@"phone"];
    /// 设置购物车的数量为0
    [defaults setObject:@"0" forKey:@"cartCount"];
    
    [defaults synchronize];
    
    /// 移除购物车角标
    UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
    cartVC.tabBarItem.badgeValue = nil;
    
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [_hud addSuccessString:@"已安全退出" delay:2.0];
    
    [self changeUserStatus];
    
    YunLog(@"yes logout");
    
    [_imageSource removeAllObjects];
    [_titleSource removeAllObjects];
    
    [self getData];
    
    [_tableView reloadData];
    
}

//- (void)bottomBtnClick:(UIButton *)sender
//{
//    YunLog(@"btn.tag = %ld", (long)sender.tag);
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    if (!appDelegate.isLogin) {
//        [self login];
//        
//        return;
//    }
//    
//    if (sender.tag == 0) {
//        AddressListViewController *address = [[AddressListViewController alloc] init];
//        address.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:address animated:YES];
//    }
//    
//    else if (sender.tag == 1) {
//        FavoriteListViewController *favorite = [[FavoriteListViewController alloc] init];
//        favorite.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:favorite animated:YES];
//    }
//    
//    else if (sender.tag == 2) {
//        UpdatePasswordViewController *password = [[UpdatePasswordViewController alloc] init];
//        password.hidesBottomBarWhenPushed = YES;
//
//        [self.navigationController pushViewController:password animated:YES];
//    }
//    
//    else if (sender.tag == 3) {
//        MyHistoryViewController *myHisVC = [[MyHistoryViewController alloc] init];
//        myHisVC.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:myHisVC animated:YES];
//    }
//}

- (void)bottomBtnClick:(UIButton *)sender
{
    YunLog(@"btn.tag = %ld", (long)sender.tag);
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        [self login];
        
        return;
    }
    
    switch (sender.tag) {
        case 100:
        {
            UpdatePasswordViewController *password = [[UpdatePasswordViewController alloc] init];
            password.hidesBottomBarWhenPushed = YES;

            [self.navigationController pushViewController:password animated:YES];
        }
            break;
            
        case 101:
        {
            AddressListViewController *address = [[AddressListViewController alloc] init];
            address.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:address animated:YES];
        }
            break;
            
        case 102:
        {
            FavoriteListViewController *favorite = [[FavoriteListViewController alloc] init];
            favorite.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:favorite animated:YES];
        }
            break;
            
        case 103:
        {
            MyPreferentialViewController *myPreVC = [[MyPreferentialViewController alloc] init];
            myPreVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:myPreVC animated:YES];
        }
            break;
            
        case 104:
        {
            MyHistoryViewController *myHisVC = [[MyHistoryViewController alloc] init];
            myHisVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:myHisVC animated:YES];
        }
            break;
            
        case 105:
        {
            if (appDelegate.isLogin && appDelegate.user.userType == 1)
            {
                for (id so in appDelegate.window.subviews) {
                    [so removeFromSuperview];
                }
                
                AdminHomeViewController *adminVC = [[AdminHomeViewController alloc] init];
                adminVC.isBuyEnter = YES;
                PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:adminVC];
                
                appDelegate.window.rootViewController = popNC;
                [appDelegate.window makeKeyAndVisible];
            } else if (appDelegate.isLogin && (appDelegate.user.userType == 2 || appDelegate.user.userType == 3)) {
                for (id so in appDelegate.window.subviews) {
                    [so removeFromSuperview];
                }
                
                MyShopListViewController *shopVC = [[MyShopListViewController alloc] init];
                
                PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:shopVC];
                
                
                appDelegate.window.rootViewController = popNC;
                [appDelegate.window makeKeyAndVisible];
            } else {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:@"需要先登录哟" delay:1.5];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loginEnterSale];
                });
            }
        }
            break;
            
        default:
            break;
    }
}

//- (void)pushToShop
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *shopCode = [defaults objectForKey:@"lastSelectedShop"];
//    
//    if (!shopCode) {
//        [defaults setObject:@"0" forKey:@"lastSelectedShop"];
//        
//        [defaults synchronize];
//    } else {
//        AppDelegate *appDelegate = kAppDelegate;
//        
//        for (int i = 0; i < appDelegate.user.shops.count; i++) {
//            if ([[appDelegate.user.shops[i] objectForKey:@"code"] isEqualToString:shopCode]) {
////                MyShopViewController *myShop = [[MyShopViewController alloc] init];
////                myShop.shopCode = shopCode;
////                myShop.hidesBottomBarWhenPushed = YES;
////                
////                [self.navigationController pushViewController:myShop animated:YES];、
//                
//                AdminShopViewController *myShopVc = [[AdminShopViewController alloc] init];
//                //            AdminHomeViewController *vc = [[AdminHomeViewController alloc] init];
//                myShopVc.shopCode = shopCode;
//#warning 这里是严重的问题 需要处理的
//                // TODO :这里是严重的问题 需要处理的
//                myShopVc.shopID = _shopID;
//                
//                myShopVc.navigationController.navigationBarHidden = YES;
//                myShopVc.hidesBottomBarWhenPushed = YES;
//                
//                [self.navigationController pushViewController:myShopVc animated:YES];
//
//                return;
//            }
//        }
//        
//        [defaults setObject:@"0" forKey:@"lastSelectedShop"];
//        
//        [defaults synchronize];
//    }
//    
//    MyShopListViewController *myShop = [[MyShopListViewController alloc] init];
//    myShop.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:myShop animated:YES];
//}

#pragma mark - EnterOrderState -

- (void)enterGoodsState:(UIButton *)sender
{
    YunLog(@"sender.tag = %ld", (long)sender.tag);
    
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

#pragma mark - tableViewDelegate - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _imageSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_imageSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSArray *imageArray = _imageSource[indexPath.section];
    NSArray *titleArray = _titleSource[indexPath.section];
    
    cell.imageView.image = [UIImage imageNamed:imageArray[indexPath.row]];
    
    cell.textLabel.text = titleArray[indexPath.row];
    if (kIsiPhone) {
        cell.textLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:kFontLargeSize];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int orderTypeArray[6] = {All, WaitingForPay, AlreadyPay, WaitingForReceive, AlreadyComplete};
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (indexPath.section == 0) {
        if (!appDelegate.isLogin) {
            [self login];
            
            return;
        }
        OrderListViewController *order = [[OrderListViewController alloc] init];
        order.hidesBottomBarWhenPushed = YES;
        order.orderType = orderTypeArray[indexPath.row];
        order.selectedOrderTypeIndex = orderTypeArray[indexPath.row];
        [self.navigationController pushViewController:order animated:YES];
    } else if (indexPath.section == 1) {
        if (!appDelegate.isLogin) {
            [self login];
            
            return;
        }
        if (indexPath.row == 0) {
            MyPreferentialViewController *myPreVC = [[MyPreferentialViewController alloc] init];
            myPreVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:myPreVC animated:YES];
        }
//        else if (indexPath.row == 1) {
//            if (appDelegate.user.shops.count <= 0) {
//                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                _hud.labelText = @"获取商铺列表...";
//                
//                NSDictionary *params = @{@"user_session_key":kNullToString(appDelegate.user.userSessionKey)};
//                
//                NSString *myShopsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShopAdminShopsURL params:params];
//                
//                YunLog(@"myShopsURL = %@", myShopsURL);
//                
//                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                manager.requestSerializer.timeoutInterval = 30;
//                
//                [manager GET:myShopsURL
//                  parameters:nil
//                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                         YunLog(@"my shop responseObject = %@", responseObject);
//                         
//                         [_hud hide:YES];
//                         
//                         NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
//                         
//                         NSArray *tempArray = [[responseObject objectForKey:@"data"] objectForKey:@"shop_list"];
//                         NSDictionary *dict = [tempArray lastObject];
//                         _shopID = dict[@"id"];
//                         YunLog(@"id = %@", _shopID);
//                         
//                         if ([code isEqualToString:kSuccessCode]) {
//                             appDelegate.user.shops = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"shop_list"]);
//                             
//                             [self pushToShop];
//                         } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
//                             [Tool resetUser];
//                             
////                             [self changeUserStatus];
//                         } else {
//                             [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
//                                            delay:2.0];
//                         }
//                     }
//                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                         YunLog(@"my shop error = %@", error);
//                         
//                         if (![operation isCancelled]) {
//                             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
//                         }
//                     }];
//            } else {
//                [self pushToShop];
//            }
//        }
    }
    else if (indexPath.section == 2) {
        if (appDelegate.isLogin && appDelegate.user.userType == 1)
        {
            for (id so in appDelegate.window.subviews) {
                [so removeFromSuperview];
            }
            
            AdminHomeViewController *adminVC = [[AdminHomeViewController alloc] init];
            adminVC.isBuyEnter = YES;
            PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:adminVC];
            
            appDelegate.window.rootViewController = popNC;
            [appDelegate.window makeKeyAndVisible];
        } else if (appDelegate.isLogin && (appDelegate.user.userType == 2 || appDelegate.user.userType == 3)) {
            for (id so in appDelegate.window.subviews) {
                [so removeFromSuperview];
            }
            
            MyShopListViewController *shopVC = [[MyShopListViewController alloc] init];
            
            PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:shopVC];
            
            
            appDelegate.window.rootViewController = popNC;
            [appDelegate.window makeKeyAndVisible];
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"需要先登录哟" delay:1.5];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loginEnterSale];
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kIsiPhone) {
        return 44;
    } else {
        return 80;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0000001;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
