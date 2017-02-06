//
//  AdminShopViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/4.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminShopViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

//  Controllers
#import "AdminInfoViewController.h"
#import "AdminOrderListViewController.h"
#import "ManageShopViewController.h"
#import "MyDistributorsViewController.h"
#import "AdminProductsViewController.h"
#import "AdminIncomeViewController.h"
#import "AdminDistributeGroupViewController.h"
#import "ProductGroupsViewController.h"
#import "AdminMessageCenterViewController.h"
#import "AdminSettingViewController.h"
#import "AddNewDistributorViewController.h"
#import "DistributionStatViewController.h"
#import "IndexTabViewController.h"
#import "PopGestureRecognizerController.h"
#import "PromotionViewController.h"
#import "MyClientsViewController.h"
#import "MyQRCodeViewController.h"
#import "MyShopListViewController.h"
#import "MyDistributorsViewControllerOne.h"
// Libraries
#import "SDCycleScrollView.h"

// Views
#import "KLCPopup.h"
#import "YunShareView.h"

#define kTopBgViewHeight (kScreenWidth / 375) * 210
#define kIconWidth (kScreenWidth > 375 ? 65 * 1.293 : (kScreenWidth > 320 ? 65 * 1.17 : 65))

@interface AdminShopViewController () <SDCycleScrollViewDelegate, UIScrollViewDelegate, YunShareViewDelegate>

/// 首页背景滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;

/// 首页banner滚动视图
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

/// 背景介绍图
@property (nonatomic, strong) UIImageView *topView;

/// 用户头像
@property (nonatomic, strong) UIButton *iconButton;

/// 返回按钮
@property (nonatomic, strong) UIButton *backButton;

/// 当前商铺信息
@property (nonatomic, strong) NSDictionary *shop;

/// 商铺名
@property (nonatomic, strong) UILabel *shopNameLabel;

/// 第三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 控制页面快速跳转的按钮
@property (nonatomic, strong) UIButton *controlButton;

/// 是否在顶端
@property (nonatomic, assign) BOOL isTop;

/// 今日收入
@property (nonatomic, strong) UILabel *today_income;

/// 累计收入
@property (nonatomic, strong) UILabel *total_income;

/// 今日订单
@property (nonatomic, strong) UILabel *order_count;

@end

@implementation AdminShopViewController

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
        naviTitle.text = @"个人中心";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = kBackgroundColor;
    
    self.navigationController.navigationBarHidden = YES;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(0, 0, 25, 25);
    
    if (_canBack == YES) {
        [_backButton setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
    }
    
    [_backButton addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBarHidden = NO;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTopView];
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"code"                 :   kNullToString(_shopCode)};
    
    NSString *infoURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/shops/%@/owner_shop.json",_shopCode] params:params];;
    
    YunLog(@"shop infoURL = %@", infoURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:infoURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"shop info responseObject = %@",responseObject);
             
             NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
             
             if ([code isEqualToString:kSuccessCode]) {
                 _shop = [[responseObject objectForKey:@"data"] objectForKey:@"shop"];
                 if (_shop) {
                     NSString *name = kNullToString([_shop objectForKey:@"name"]);
                     YunLog(@"shopname = %@", name);
                     
                     _shopNameLabel.text = [name isEqualToString:@""] ? @"草小姐的花店" : name;
                     
//                     NSArray *imageArr = kNullToArray([_shop objectForKey:@"mobile_banners"]);
                     NSString *backImage;
                     
                     NSArray *images = [[[responseObject objectForKey:@"data"] objectForKey:@"shop"] objectForKey:@"mobile_banners"];
                     for (NSDictionary *dic in images) {
//                         if ([[[dic objectForKey:@"use_for"] stringValue] isEqualToString:@"9"]) {
                              backImage = kNullToString(dic[@"image_url"]);
//                         }
                     }
                     
                     NSString *commissionRate = [[[responseObject objectForKey:@"data"] objectForKey:@"shop"] objectForKey:@"commission_rate"];
                     [kUserDefaults setObject:commissionRate forKey:@"commissionRate"];
                     [kUserDefaults synchronize];
                     
//                     [_topView setImageWithURL:[NSURL URLWithString:backImage] placeholderImage:[UIImage imageNamed:@"admin_topBg"]];
                     
                    [_iconButton setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:kNullToString([_shop objectForKey:@"logo"])] placeholderImage:[UIImage imageNamed:@"user_icon_shop"]];
                     
                     [[NSUserDefaults standardUserDefaults] setObject:kNullToString([_shop objectForKey:@"code"]) forKey:@"shopCode"];
                     [[NSUserDefaults standardUserDefaults] setObject:kNullToString([_shop objectForKey:@"id"]) forKey:@"shopID"];
                     [[NSUserDefaults standardUserDefaults] setObject:kNullToString([_shop objectForKey:@"status"]) forKey:@"shopType"];
                     [[NSUserDefaults standardUserDefaults] setObject:kNullToString([_shop objectForKey:@"shop_home_url"]) forKey:@"shop_home_url"];
                     [self getSaleData];
                 }
                 [_hud hide:YES];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"shop info error = %@", error);
             
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

#pragma mark - CreateUI -

//- (void)createTopView
//{
//    
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    
//    _scrollView.backgroundColor = kGrayColor;
//    _scrollView.bounces = NO;
//    _scrollView.showsHorizontalScrollIndicator = NO;
//    _scrollView.showsVerticalScrollIndicator = NO;
//    _scrollView.delegate = self;
//    
//    YunLog(@"_scrollView.frame = %@", NSStringFromCGRect(_scrollView.frame));
//    
//    [self.view addSubview:_scrollView];
//    
//    UIView *topBackView = [[UIView alloc] init];
//    topBackView.backgroundColor = [UIColor whiteColor];
//    topBackView.userInteractionEnabled = YES;
//    
//    [_scrollView addSubview:topBackView];
//    
//    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopBgViewHeight)];
//    _topView.userInteractionEnabled = YES;
//    _topView.image = [UIImage imageNamed:@"admin_topBg"];
//    
//    [topBackView addSubview:_topView];
//    
//    if (_canBack == YES) {
//        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        backButton.frame = CGRectMake(15, 30, 25, 25);
//        [backButton setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
//        [backButton addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
//        
//        [_topView addSubview:backButton];
//    }
//    
////    _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
////    _iconButton.frame = CGRectMake((kScreenWidth - kIconWidth) / 2, (_topView.frame.size.height - kIconWidth / 2), kIconWidth, kIconWidth);
////    [_iconButton setBackgroundImage:[UIImage imageNamed:@"user_icon"] forState:UIControlStateNormal];
////    [_iconButton addTarget:self action:@selector(pushToAdminInfo) forControlEvents:UIControlEventTouchUpInside];
////    
////    [topBackView addSubview:_iconButton];
//    
//    CGFloat shopNameLabelWidth = 200;
//    _shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - shopNameLabelWidth) / 2, CGRectGetMaxY(_topView.frame) + 10, shopNameLabelWidth, 30)];
//    _shopNameLabel.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
//    _shopNameLabel.textColor = kLightBlackColor;
//    _shopNameLabel.textAlignment = NSTextAlignmentCenter;
//    
//    [topBackView addSubview:_shopNameLabel];
//    
//    CGFloat managerButtonWidth = 100;
//    
//    UIImageView *managerView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - managerButtonWidth, CGRectGetMaxY(_shopNameLabel.frame) + 10, 20, 20)];
//    managerView.image = [UIImage imageNamed:@"admin_manage"];
//    
//    [topBackView addSubview:managerView];
//    
//    UILabel *managerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(managerView.frame) + 5, CGRectGetMaxY(_shopNameLabel.frame) + 10, 75, 20)];
//    managerLabel.text = @"个人信息";
//    managerLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
//    managerLabel.textColor = kLightBlackColor;
//    
//    [topBackView addSubview:managerLabel];
//    
//    UIButton *managerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    managerButton.frame = CGRectMake(kScreenWidth / 2 - managerButtonWidth, CGRectGetMaxY(_shopNameLabel.frame) + 10, managerButtonWidth, 20);
//    [managerButton addTarget:self action:@selector(pushToAdminInfo) forControlEvents:UIControlEventTouchUpInside];
//    //    managerButton.titleLabel.font = kNormalFont;
//    //    [managerButton setTitle:@"管理店铺" forState:UIControlStateNormal];
//    //    [managerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    //    [managerButton setImage:[UIImage imageNamed:@"admin_manage"] forState:UIControlStateNormal];
//    
//    [topBackView addSubview:managerButton];
//    
//    UIImageView *shareView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth /2 + 30, CGRectGetMaxY(_shopNameLabel.frame) + 10, 20, 20)];
//    shareView.image = [UIImage imageNamed:@"admin_share"];
//    
//    [topBackView addSubview:shareView];
//    
//    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shareView.frame) + 5, CGRectGetMaxY(_shopNameLabel.frame) + 10, 75, 20)];
//    shareLabel.text = @"分享店铺";
//    shareLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
//    shareLabel.textColor = kLightBlackColor;
//    
//    [topBackView addSubview:shareLabel];
//    
//    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    shareButton.frame = CGRectMake(kScreenWidth /2 + 30, CGRectGetMaxY(_shopNameLabel.frame) + 10, managerButtonWidth, 20);
//    [shareButton addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
//    //    shareButton.titleLabel.font = kNormalFont;
//    //    [shareButton setTitle:@"分享店铺" forState:UIControlStateNormal];
//    //    [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    //    [shareButton setImage:[UIImage imageNamed:@"admin_share"] forState:UIControlStateNormal];
//    
//    [topBackView addSubview:shareButton];
//    
//    UIView  *line1 = [[UIView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(managerButton.frame) + 15, kScreenWidth - 60, 1)];
//    line1.backgroundColor = [UIColor lightGrayColor];
//    
//    [topBackView addSubview:line1];
//    
//    NSArray *labelName = @[@"今日收入", @"累计收入", @"今日订单"];
//    
//    for (int i = 0; i < labelName.count; i ++) {
//        CGFloat incomeLabelWidth = kScreenWidth / labelName.count;
//        CGFloat incomeLabelX = incomeLabelWidth *i;
//
//        if (i == 0)
//        {
//            _today_income = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(line1.frame) + 30, incomeLabelWidth, 20)];
//            _today_income.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
//            _today_income.textAlignment = NSTextAlignmentCenter;
//            _today_income.textColor = [UIColor orangeColor];
//            _today_income.text = @"0.00";
//            
//            [topBackView addSubview:_today_income];
//        }
//        if (i == 1)
//        {
//            _total_income = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(line1.frame) + 30, incomeLabelWidth, 20)];
//            _total_income.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
//            _total_income.textAlignment = NSTextAlignmentCenter;
//            _total_income.textColor = kLightBlackColor;
//            _total_income.text = @"0.00";
//            
//            [topBackView addSubview:_total_income];
//        }
//        if (i == 2)
//        {
//            _order_count = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(line1.frame) + 30, incomeLabelWidth, 20)];
//            _order_count.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
//            _order_count.textAlignment = NSTextAlignmentCenter;
//            _order_count.textColor = kLightBlackColor;
//            _order_count.text = @"0";
//            
//            [topBackView addSubview:_order_count];
//        }
//        
//        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(_today_income.frame) + 10, incomeLabelWidth, 30)];
//        nameLabel.text = labelName[i];
//        nameLabel.font = [UIFont systemFontOfSize:15];
//        nameLabel.textAlignment = NSTextAlignmentCenter;
//        nameLabel.textColor = kLightBlackColor;
//        
//        [topBackView addSubview:nameLabel];
//    }
//    
//    CGFloat topBackViewY = CGRectGetMaxY(line1.frame) + 50 + 30 + 20;
//    
//    topBackView.frame = CGRectMake(0, 0, kScreenWidth, topBackViewY);
//    
//    //    CGFloat bannerHeight = (kScreenWidth / 640) * 200;
//    //
//    //    /// 添加网络请求数据
//    //    _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, topBackViewY + 10, kScreenWidth, bannerHeight) imagesGroup:nil];
//    //
//    //    /// 分页控制器图标
//    //    _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
//    //    _cycleScrollView.delegate = self;
//    //
//    //    /// 分页控制器颜色
//    //    /// _cycleScrollView.dotColor = [UIColor orangeColor];
//    //    [_scrollView addSubview:_cycleScrollView];
//    //
//    //    // 占位图片
//    //    _cycleScrollView.placeholderImage = [UIImage imageNamed:@"default_image_large"];
//    //
//    //    NSMutableArray *imagArr = [NSMutableArray array];
//    //
//    //    for (int i = 0; i < 3; i ++)
//    //    {
//    //        UIImage *image = [UIImage imageNamed:@"default_image_large"];
//    //        [imagArr addObject:image];
//    //    }
//    //
//    //    _cycleScrollView.localizationImagesGroup = imagArr;
//    
//    //    /// 加载延时
//    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    //        _cycleScrollView.imageURLStringsGroup = nil;
//    //    });
//    
//    UIView *buttomBackView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBackView.frame) + 10, kScreenWidth, kScreenHeight - (CGRectGetMaxY(topBackView.frame) + 10 - CGRectGetMaxY(line1.frame)))];
//    buttomBackView.backgroundColor = [UIColor whiteColor];
//    
//    [_scrollView addSubview:buttomBackView];
//    
//    UIImageView *addView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2 , 15, 25, 25)];
//    addView.image = [UIImage imageNamed:@"admin_add"];
//    
//    [buttomBackView addSubview:addView];
//    
//    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addView.frame) + 5, 15, 120, 25)];
//    addLabel.text = @"添加分销商";
//    addLabel.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
//    addLabel.textColor = kLightBlackColor;
//    
//    [buttomBackView addSubview:addLabel];
//    
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake((kScreenWidth - 150) / 2 , 15, 150, 25);
//    [addButton addTarget:self action:@selector(addNewDistributor) forControlEvents:UIControlEventTouchUpInside];
//    //    addButton.titleLabel.font = kBigFont;
//    //    [addButton setTitle:@"添加分销商" forState:UIControlStateNormal];
//    //    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    //    [addButton setImage:[UIImage imageNamed:@"admin_add"] forState:UIControlStateNormal];
//    
//    [buttomBackView addSubview:addButton];
//    
//    NSArray *imageArr = @[@"admin_product", @"admin_order", @"admin_distributor", /*@"admin_sale",*/ @"admin_income", @"admin_sell", @"admin_productGroup", @"admin_maijia"];
//    
//    _scrollView.contentSize = CGSizeMake(kScreenWidth, CGRectGetMaxY(buttomBackView.frame));
//    
//    CGFloat allSpace = buttomBackView.frame.size.height - 15 - 25 - 15 - 49 - 10;
//    
//    CGFloat colSpace = 25;
//    CGFloat shopButtonWidth = (kScreenWidth - 4 * colSpace) / 3;
//    CGFloat rowSpace = allSpace / 3 - shopButtonWidth;
//    
//    for (int i = 0; i < imageArr.count; i ++) {
//        int row = i / 3;
//        int col = i % 3;
//        
//        CGFloat shopButtonX = colSpace + (shopButtonWidth +colSpace) * col;
//        CGFloat shopButtonY = CGRectGetMaxY(addButton.frame) + 25 + (shopButtonWidth +rowSpace) * row;
//        
//        UIButton *shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        shopButton.frame = CGRectMake(shopButtonX, shopButtonY, shopButtonWidth, shopButtonWidth);
//        shopButton.tag = i;
//        [shopButton setImage:[UIImage imageNamed:imageArr[i]] forState:UIControlStateNormal];
//        [shopButton addTarget:self action:@selector(pushToDetail:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [buttomBackView addSubview:shopButton];
//    }
//    
//    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, buttomBackView.frame.size.height - 49, kScreenWidth, 49)];
//    buttomView.backgroundColor = COLOR(253, 161, 81, 1);
//    
//    [buttomBackView addSubview:buttomView];
//    
//    NSArray *tabImageArr = @[@"admin_news",@"admin_service",@"admin_setting"];
//    
//    CGFloat tabButtonWidth = 0.49 * 92;
//    CGFloat space = (kScreenWidth - tabButtonWidth * 3) / 4;
//    
//    for (int i = 0; i < 3; i ++) {
//        CGFloat tabButtonX = space + (tabButtonWidth + space) * i;
//        
//        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        tabButton.frame = CGRectMake(tabButtonX, 0, tabButtonWidth, 49);
//        [tabButton setImage:[UIImage imageNamed:tabImageArr[i]] forState:UIControlStateNormal];
//        tabButton.tag = i;
//        
//        if (i == 1)
//        {
//            [tabButton addTarget:self action:@selector(dialPhone:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else
//        {
//            [tabButton addTarget:self action:@selector(tabButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        [buttomView addSubview:tabButton];
//    }
//}


- (void)createTopView
{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, kScreenWidth, kScreenHeight + 20)];
    
    _scrollView.backgroundColor = kGrayColor;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    YunLog(@"_scrollView.frame = %@", NSStringFromCGRect(_scrollView.frame));
    
    [self.view addSubview:_scrollView];
    
    UIView *topBackView = [[UIView alloc] init];
    topBackView.backgroundColor = [UIColor whiteColor];
    topBackView.userInteractionEnabled = YES;
    
    [_scrollView addSubview:topBackView];
    
    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopBgViewHeight)];
    _topView.userInteractionEnabled = YES;
    _topView.image = [UIImage imageNamed:@"admin_topBg"];
    
    [topBackView addSubview:_topView];
    
    _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _iconButton.backgroundColor = [UIColor redColor];
    _iconButton.frame = CGRectMake((kScreenWidth - kIconWidth) / 2, (_topView.frame.size.height / 2  - kIconWidth) + 10, kIconWidth, kIconWidth);
    [_iconButton setBackgroundImage:[UIImage imageNamed:@"user_icon_shop"] forState:UIControlStateNormal];
    
    _iconButton.layer.masksToBounds = YES;
    _iconButton.layer.cornerRadius = kIconWidth / 2;
    [_iconButton addTarget:self action:@selector(pushToAdminInfo) forControlEvents:UIControlEventTouchUpInside];

    [topBackView addSubview:_iconButton];
    

    _shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconButton.frame) + 10, kScreenWidth, 25)];
    _shopNameLabel.font = kNormalBoldFont;
    _shopNameLabel.textColor = [UIColor whiteColor];
    _shopNameLabel.textAlignment = NSTextAlignmentCenter;
    
    [topBackView addSubview:_shopNameLabel];
    
    CGFloat changeShopButtonWidth = 100;
    
    UIButton *shareShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareShopButton.frame = CGRectMake((kScreenWidth - changeShopButtonWidth) / 2, CGRectGetMaxY(_shopNameLabel.frame) + 10, changeShopButtonWidth, 20);
    [shareShopButton setImage:[UIImage imageNamed:@"admin_share_shop"] forState:UIControlStateNormal];
    [shareShopButton setTitle:@"分享店铺" forState:UIControlStateNormal];
    [shareShopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shareShopButton.titleLabel.font = kMidFont;
    [shareShopButton addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
    
    [_topView addSubview:shareShopButton];
    
    if (_canBack)
    {
        UIButton *changeShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        changeShopButton.frame = CGRectMake(kScreenWidth / 2 - changeShopButtonWidth, CGRectGetMaxY(_shopNameLabel.frame) + 10, changeShopButtonWidth, 20);
        [changeShopButton setImage:[UIImage imageNamed:@"admin_change_shop"] forState:UIControlStateNormal];
        [changeShopButton setTitle:@"切换店铺" forState:UIControlStateNormal];
        [changeShopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        changeShopButton.titleLabel.font = kMidFont;
        [changeShopButton addTarget:self action:@selector(gotoMyShopList) forControlEvents:UIControlEventTouchUpInside];
        
        [_topView addSubview:changeShopButton];
        
        shareShopButton.frame = CGRectMake(kScreenWidth / 2, CGRectGetMaxY(_shopNameLabel.frame) + 10, changeShopButtonWidth, 20);
    }
    
//    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    shareButton.frame = CGRectMake(kScreenWidth - 40, 10, 30, 30);
//    [shareButton setImage:[UIImage imageNamed:@"admin_share_shop"] forState:UIControlStateNormal];
//    [shareButton addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
//    
//    [topBackView addSubview:shareButton];
    
    NSArray *labelName = @[@"今日收入", @"累计收入", @"今日订单"];
    
    for (int i = 0; i < labelName.count; i ++) {
        CGFloat incomeLabelWidth = kScreenWidth / labelName.count;
        CGFloat incomeLabelX = incomeLabelWidth *i;
        
        if (i == 0)
        {
            _today_income = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(_topView.frame) + 10, incomeLabelWidth, 20)];
            _today_income.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
            _today_income.textAlignment = NSTextAlignmentCenter;
            _today_income.textColor = [UIColor orangeColor];
            _today_income.text = @"0.00";
            
            [topBackView addSubview:_today_income];
        }
        if (i == 1)
        {
            _total_income = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(_topView.frame) + 10, incomeLabelWidth, 20)];
            _total_income.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
            _total_income.textAlignment = NSTextAlignmentCenter;
            _total_income.textColor = kLightBlackColor;
            _total_income.text = @"0.00";
            
            [topBackView addSubview:_total_income];
        }
        if (i == 2)
        {
            _order_count = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(_topView.frame) + 10, incomeLabelWidth, 20)];
            _order_count.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
            _order_count.textAlignment = NSTextAlignmentCenter;
            _order_count.textColor = kLightBlackColor;
            _order_count.text = @"0";
            
            [topBackView addSubview:_order_count];
        }
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(incomeLabelX, CGRectGetMaxY(_today_income.frame) + 10, incomeLabelWidth, 30)];
        nameLabel.text = labelName[i];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = kLightBlackColor;
        
        [topBackView addSubview:nameLabel];
    }
    
    CGFloat topBackViewY = CGRectGetMaxY(_topView.frame) + 50 + 30;
    
    topBackView.frame = CGRectMake(0, 0, kScreenWidth, topBackViewY);
    
    UIView *buttomBackView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBackView.frame) + 10, kScreenWidth, 0)];
    buttomBackView.backgroundColor = [UIColor whiteColor];
    
    [_scrollView addSubview:buttomBackView];
    
    UIImageView *addView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2 , 15, 25, 25)];
    addView.image = [UIImage imageNamed:@"admin_add"];
    
    [buttomBackView addSubview:addView];
    
    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addView.frame) + 5, 15, 120, 25)];
    addLabel.text = @"添加分销商";
    addLabel.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
    addLabel.textColor = kLightBlackColor;
    
    [buttomBackView addSubview:addLabel];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake((kScreenWidth - 150) / 2 , 15, 150, 25);
    [addButton addTarget:self action:@selector(addNewDistributor) forControlEvents:UIControlEventTouchUpInside];
    
    [buttomBackView addSubview:addButton];
    
    UIView  *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addLabel.frame) + 15, kScreenWidth, 0.5)];
    line1.backgroundColor = [UIColor lightGrayColor];
    line1.alpha = 0.7;
    
    [buttomBackView addSubview:line1];
    
    NSArray *imageArr = @[@"admin_product", @"admin_order", @"admin_distributor", @"admin_income", @"admin_sell", @"admin_productGroup", @"admin_customer", @"admin_QRcode", @"admin_maijia"];
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, CGRectGetMaxY(buttomBackView.frame));
    
    CGFloat colSpace = 25;
    CGFloat shopButtonWidth = (kScreenWidth - 4 * colSpace) / 3;
    
    CGFloat lastButtonY;
    
    for (int i = 0; i < imageArr.count; i ++) {
        int row = i / 3;
        int col = i % 3;
        
        CGFloat shopButtonX = colSpace + (shopButtonWidth +colSpace) * col;
        CGFloat shopButtonY = CGRectGetMaxY(line1.frame) + colSpace + (shopButtonWidth + colSpace) * row;
        
        UIButton *shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shopButton.frame = CGRectMake(shopButtonX, shopButtonY, shopButtonWidth, shopButtonWidth);
        shopButton.tag = i;
        [shopButton setImage:[UIImage imageNamed:imageArr[i]] forState:UIControlStateNormal];
        [shopButton addTarget:self action:@selector(pushToDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttomBackView addSubview:shopButton];
        
        lastButtonY = CGRectGetMaxY(shopButton.frame);
    }
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, lastButtonY + colSpace, kScreenWidth, 48)];
    buttomView.backgroundColor = kOrangeColor;
    
    [buttomBackView addSubview:buttomView];
    
    buttomBackView.frame = CGRectMake(0, CGRectGetMaxY(topBackView.frame) + 10, kScreenWidth, CGRectGetMaxY(buttomView.frame));
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, CGRectGetMaxY(buttomBackView.frame));
    
    NSArray *tabImageArr = @[@"admin_news",@"admin_service",@"admin_setting"];
    
    CGFloat tabButtonWidth = 40;
    CGFloat space = (kScreenWidth - tabButtonWidth * 3) / 4;
    
    for (int i = 0; i < 3; i ++) {
        CGFloat tabButtonX = space + (tabButtonWidth + space) * i;
        
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.frame = CGRectMake(tabButtonX, 4, tabButtonWidth, 40);
        [tabButton setImage:[UIImage imageNamed:tabImageArr[i]] forState:UIControlStateNormal];
        tabButton.tag = i;
        
        if (i == 1)
        {
            [tabButton addTarget:self action:@selector(dialPhone:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [tabButton addTarget:self action:@selector(tabButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [buttomView addSubview:tabButton];
    }
}

- (void)getSaleData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"])};
    
    NSString *getSaleDataURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShop_home_statistic params:params];
    
    YunLog(@"getSaleDataURL = %@", getSaleDataURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:getSaleDataURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"getSaleData responseObject = %@",responseObject);
             
             NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
             
             if ([code isEqualToString:kSuccessCode]) {
                 if ([[[responseObject objectForKey:@"data"] objectForKey:@"order_count"] isKindOfClass:[NSString class]]) {
                     _order_count.text = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"order_count"]);
                 } else {
                     _order_count.text = kNullToString([[[responseObject objectForKey:@"data"] objectForKey:@"order_count"] stringValue]);
                 }
                 
                 if ([[[responseObject objectForKey:@"data"] objectForKey:@"today_income"] isKindOfClass:[NSString class]]) {
                     _today_income.text = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"today_income"]);
                 } else {
                     _today_income.text = kNullToString([[[responseObject objectForKey:@"data"] objectForKey:@"today_income"] stringValue]);
                 }
                 
                 if ([[[responseObject objectForKey:@"data"] objectForKey:@"total_income"] isKindOfClass:[NSString class]]) {
                     _total_income.text = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"total_income"]);
                 } else {
                     _total_income.text = kNullToString([[[responseObject objectForKey:@"data"] objectForKey:@"total_income"] stringValue]);
                 }                 
                [_hud hide:YES];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"getSaleData error = %@", error);
             
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
}

#pragma mark - Private Functions -
- (void)addNewDistributor
{
    AddNewDistributorViewController *addNewDistributor = [[AddNewDistributorViewController alloc] init];
    
    [self.navigationController pushViewController:addNewDistributor animated:YES];
}

- (void)pushToAdminInfo
{
    NSString *shopCode = kNullToString([_shop objectForKey:@"code"]);
    
    YunLog(@"shopcode = %@", shopCode);
    
    AdminInfoViewController *adminInfo = [[AdminInfoViewController alloc] init];
    adminInfo.shopCode = shopCode;
    YunLog(@"adminInfo.shopCode = %@", adminInfo.shopCode);
    adminInfo.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:adminInfo animated:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:shopCode forKey:@"lastSelectedShop"];
    
    [defaults synchronize];
}

- (void)manageShop
{
    ManageShopViewController *manageShop = [[ManageShopViewController alloc] init];
    
    [self.navigationController pushViewController:manageShop animated:YES];
}

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushToDetail:(UIButton *)sender
{
    switch (sender.tag) {
        case AdminProducts:  // 我的商品
        {
            AdminProductsViewController *adminProVC = [[AdminProductsViewController alloc] init];
            adminProVC.shopCode = kNullToString(_shopCode);
            adminProVC.shopID = kNullToString(_shopID);
            
            [self.navigationController pushViewController:adminProVC animated:YES];
        }
            
            break;
            
        case AdminOrderList:  // 我的订单
        {
            AdminOrderListViewController *list = [[AdminOrderListViewController alloc] init];
            list.shopID = kNullToString([_shop objectForKey:@"id"]);
            list.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:list animated:YES];
        }
            
            break;
            
        case MyDistributors:  // 我的分销商
        {
            MyDistributorsViewController *distributors = [[MyDistributorsViewController alloc] init];
//            MyDistributorsViewControllerOne *distributors = [[MyDistributorsViewControllerOne alloc] init];
            distributors.hidesBottomBarWhenPushed = YES;
            distributors.shopCode = kNullToString([_shop objectForKey:@"code"]);
            distributors.shopID = kNullToString([_shop objectForKey:@"id"]);
            
            [self.navigationController pushViewController:distributors animated:YES];
        }
            
            break;
            
//        case Promotion:
//        {
//            PromotionViewController *promotion = [[PromotionViewController alloc] init];
//            
//            [self.navigationController pushViewController:promotion animated:YES];
//        }
            
            break;
        
        case AdminIncome:  // 我的收入
        {
            AdminIncomeViewController *income =[[AdminIncomeViewController alloc] init];
            
            [self.navigationController pushViewController:income animated:YES];
        }
            
            break;
            
        case DistributionStat:  // 销售统计
        {
            DistributionStatViewController *disVC = [[DistributionStatViewController alloc] init];
            
            [self.navigationController pushViewController:disVC animated:YES];
            
        }
            break;
            
        case ProductGroups:  // 我的商品组
        {
            ProductGroupsViewController *proGroups = [[ProductGroupsViewController alloc] init];
            proGroups.shopID = kNullToString(_shopID);
            
            [self.navigationController pushViewController:proGroups animated:YES];
        }
            
            break;
            
        case AdminCustomer:  // 我的客户
        {
            MyClientsViewController *client = [[MyClientsViewController alloc] init];
            client.shopID = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]);
            
            [self.navigationController pushViewController:client animated:YES];
        }
            
            break;
            
        case AdminQRCode:  // 我的二维码
        {
            MyQRCodeViewController *qrcode = [[MyQRCodeViewController alloc] init];
            qrcode.shopName = kNullToString([_shop objectForKey:@"name"]);
            qrcode.shopURL = kNullToString([_shop objectForKey:@"share_url"]);
            YunLog(@"qrcode = %@", qrcode.shopURL);
            
            [self.navigationController pushViewController:qrcode animated:YES];
        }
            
            break;
            
        case ShopList:
        {
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
        break;
    }
}

- (void)gotoMyShopList
{
    MyShopListViewController *shoplist = [[MyShopListViewController alloc] init];
    
    [self.navigationController pushViewController:shoplist animated:YES];
}

- (void)tabButtonClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            AdminMessageCenterViewController *messageCenter  = [[AdminMessageCenterViewController alloc] init];
            
            [self.navigationController pushViewController:messageCenter animated:YES];
        }
            break;
            
        case 1:
        
            break;
            
        case 2:
        {
            AdminSettingViewController *setVC = [[AdminSettingViewController alloc] init];
            
            [self.navigationController pushViewController:setVC animated:YES];
            
        }
            
            break;
            
        default:
            break;
    }
    
}
//- (void)viewCanScroll:(UIButton *)sender
//{
//    CGPoint point = _scrollView.contentOffset;
//
//    if (point.y == -20.0)
//    {
//        [UIView animateWithDuration:0.5 animations:^{
//            _scrollView.contentOffset = CGPointMake(0, _scrollView.contentSize.height - kScreenHeight - 20);
//            _controlButton.hidden = YES;
//        } completion:^(BOOL finished) {
//            _controlButton.hidden = NO;
//        }];
//    }
//    else
//    {
//        [UIView animateWithDuration:0.5 animations:^{
//            _scrollView.contentOffset = CGPointMake(0, -20);
//            _controlButton.hidden = YES;
//        } completion:^(BOOL finished) {
//            _controlButton.hidden = NO;
//        }];
//    }
//}

- (void)openShare
{
    //    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"取消"
    //                                         destructiveButtonTitle:nil
    //                                              otherButtonTitles:@"分享到新浪微博", @"分享给微信好友", @"分享到微信朋友圈", nil];
    //    sheet.tag = 200;
    //
    //    [sheet showInView:self.view];
    
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_weixin" , @"title" : @"微信"},
                                                                     
                                                                     @{@"icon" : @"share_weixin_friend" , @"title" : @"朋友圈"},
                                                                     
                                                                     @{@"icon" : @"share_weibo" , @"title" : @"微博"}]
                                                         bottomBar:@[]
                               ];
    
    shareView.delegate = self;
    shareView.tag = 100;
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
}

- (void)isWeiXinInstalled:(NSInteger)scene
{
    if ([WXApi isWXAppInstalled]) {
        NSString *thumb = [_shop objectForKey:@"logo"];
        
        [Tool shareToWeiXin:scene
                      title:kNullToString([_shop objectForKey:@"name"])
                description:kNullToString([_shop objectForKey:@"description_text"])
                      thumb:thumb
                        url:kNullToString([_shop objectForKey:@"share_url"])];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"未安装微信客户端，去下载？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"现在下载", nil];
        [alert show];
    }
}

- (void)dialPhone:(UIButton *)sender
{
    NSString *message = @"确认拨打 4006119978";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.tag = sender.tag;

    [alertView show];
}
#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *telTo = @"tel://4006119978";
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telTo]];
    }
}

#pragma mark - YunShareDelegate -

- (void)shareViewDidSelectView:(YunShareView *)shareView inSection:(NSUInteger)section index:(NSUInteger)index
{
    YunLog(@"YunShareDelegate");
    
    if (shareView.tag == 100)
    {
        
        //      微博分享内容
        //        NSString *shopName = kNullToString([_detail objectForKey:@""]);
        //        NSString *productName = kNullToString([_detail objectForKey:@""]);
        //        NSString *productURL = kNullToString([_detail objectForKey:@""]);
        //
        //        NSUInteger shopNameLength = shopName.length;
        //        NSUInteger productNameLength = productName.length;
        //        NSUInteger productURLLength = productURL.length;
        //
        //        NSString *desc = @"云店家手机APP购物支付很方便大家赶快来试试吧";
        //        if (shopNameLength + productNameLength + productURLLength > (140 - 4 - 2 - 4)) {
        //            desc = [desc substringWithRange:NSMakeRange(0, 130 - shopNameLength - productNameLength - productURLLength)];
        //        }
        
        NSString *description = [_shop objectForKey:@"description_text"];
        
        //        NSString *description = [_detail objectForKey:@"share_order"];
        
        YunLog(@"share weibo description = %@", description);
        
        switch (index) {
            case 0:
                [self isWeiXinInstalled:WXSceneSession];
                
                break;
                
            case 1:
                [self isWeiXinInstalled:WXSceneTimeline];
                
                break;
                
            case 2:
                [Tool shareToWeiBo:[_shop objectForKey:@"logo"] description:description];
                
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - SDCycleScrollViewDelegate -

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    
}

@end
