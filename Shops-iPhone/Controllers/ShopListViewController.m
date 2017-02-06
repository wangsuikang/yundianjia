//
//  ShopListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 13-12-24.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "ShopListViewController.h"

//DataSource
//#import "ShopListDataSource.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"
#import "EnterButton.h"

// Models
#import "BannerModel.h"
#import "ShopStreetModel.h"

//  Views
#import "SearchTextField.h"
#import "ShopListButton.h"
#import "NewSearchTextField.h"

//  Controllers
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "QRCodeByNatureViewController.h"
#import "SearchResultsViewController.h"
#import "ProductDetailViewController.h"
#import "WebViewController.h"
#import "ProductDetailViewController.h"
#import "ActivityViewController.h"
#import "LoginViewController.h"
#import "RecommendViewController.h"
#import "AboutViewController.h"
#import "OrderListViewController.h"
#import "FavoriteListViewController.h"
#import "AllActivityViewController.h"
#import "MessageCenterViewController.h"

// #import "RightPanNavigationController.h"
#import "PopGestureRecognizerController.h"
#import "OrderDetailViewController.h"

// Libraries
#import "MyControl.h"
#import "BlurImage.h"
#import "SDCycleScrollView.h"

// Categories
#import "NSObject+NullToString.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+WebCache.h"

#define kTopImageHeight 200
#define kSpace 15
#define kSpaceWidth 10
#define kShopViewHeight 30
#define kShopStreetHeight (kScreenWidth > 375 ? 143 * 1.293 : (kScreenWidth > 320 ? 143 * 1.17 : 143))
#define kActiveShopsImageWH 60
#define kLeftViewWidth 10


/// 展示商品Label
typedef NS_ENUM(NSInteger, ShopListTableViewType) {
    ShopListSearchTable = 100,   //!<   商品Label
};

/// 视图控制器中六个按钮
typedef NS_ENUM(NSInteger, ShopListChannelType) {
    ShopListChannelRecommendation   = 0, //!<   推荐
    ShopListChannelActivity         = 1, //!<   活动
    ShopListChannelShop             = 2, //!<   商铺
    ShopListChannelFavorite         = 3, //!<   收藏
    ShopListChannelOrder            = 4, //!<   订单
    ShopListChannelAbout            = 5, //!<   消息
};

@interface ShopListViewController () <UIScrollViewDelegate, UITextFieldDelegate, SearchTextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, UIGestureRecognizerDelegate, SDCycleScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *topImages;

@property (nonatomic, strong) NSArray *lists; //!<  数据源

@property (nonatomic, strong) NSMutableArray *defaultLists; //!<  首页数据源

/// 首页横幅视图
@property (nonatomic, strong) UIScrollView *banner;

@property (nonatomic ,strong) NSArray *channels;

@property (nonatomic, assign) NSInteger selectedChannelIndex;

@property (nonatomic, strong) CALayer *selectedChannelBottomLine;

@property (nonatomic, assign) BOOL isGenerateTableViews;

/// 背景滚动视图
//@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIScrollView *tableHeaderView;

@property (nonatomic, assign) CGFloat userContentOffsetX;

/// 搜索类型
@property (nonatomic, copy) NSString *searchType;

/// 搜索栏输入框
@property (nonatomic, strong) NewSearchTextField *searchText;

/// 取消搜索按钮
@property (nonatomic, strong) UIButton *searchCancel;

/// 搜索table遮罩层
@property (nonatomic, strong) UIView *searchView;

/// 搜索结果tableView
@property (nonatomic, strong) UITableView *searchTableView;

///扫二维码按钮
@property (nonatomic, strong) UIButton *openQRCode;

///定时器
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL reloading;

@property (nonatomic, assign) NSInteger refreshCount;

/// 记录视图的高度，用于设置滚动视图的contentSize
@property (nonatomic, assign) NSInteger overallHeight;

/// 底部试图
@property (nonatomic, strong) UIScrollView *bigScrollView;

/// 第一张广告图
@property (nonatomic, strong) UIImageView *fristImageView;

/// 第二张广告图
@property (nonatomic, strong) UIImageView *sencodImageView;

/// 第三张广告图
@property (nonatomic, strong) UIImageView *threeImageView;

/// 店铺街标签的UIView
@property (nonatomic, strong) UIView *shopStreetView;

/// 推荐商品标签UIView
@property (nonatomic, strong) UIView *commendShopView;

/// 存放四个leftView的颜色对象
@property (nonatomic, strong) NSMutableArray *leftViewArray;

/// 存放两个商品视图展示名称
@property (nonatomic, strong) NSMutableArray *shopNameArray;

/// 存放每个店铺里面每个产品对应的数据
@property (nonatomic, strong) NSMutableArray *productStreetArray;

/// 第三方库banner
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

/// 第三方库
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) MBProgressHUD *hudTwo;

/// 角标数字
@property (nonatomic, assign) NSInteger messageCount;

/// 用户连续点击首页tabBar按钮判断
@property (nonatomic, assign) BOOL tabBarClick;

/// 轮播图数组
@property (nonatomic, strong) NSMutableArray *bannarArray;

/// 店铺街数组
@property (nonatomic, strong) NSMutableArray *shopStreetArray;

/// 推荐商品数组
@property (nonatomic, strong) NSMutableArray *recommendProductsArray;

@end

@implementation ShopListViewController

#pragma mark - Lazy Load -

/**
 懒加载
 */
- (NSMutableArray *)leftViewArray
{
    if (_leftViewArray == nil)
    {
        _leftViewArray = [NSMutableArray array];
        
        for (int i = 0; i < 20; i++)
        {
            UIColor *color = nil;
            if (i % 4 == 0)
            {
                color = COLOR(1, 149, 107, 1);
                [_leftViewArray addObject:color];
            }
            else if (i % 4 == 1)
            {
                color = COLOR(1, 147, 230, 1);
                [_leftViewArray addObject:color];
            }
            else if (i % 4 == 2)
            {
                color = COLOR(224, 70, 60, 1);
                [_leftViewArray addObject:color];
            }
            else if (i % 4 == 3)
            {
                color = COLOR(118, 75, 165, 1);
                [_leftViewArray addObject:color];
            }
        }
    }
    return _leftViewArray;
}

/**
 懒加载
 
 @return 返回店铺街的小标题
 */
- (NSMutableArray *)shopNameArray
{
    if (_shopNameArray == nil)
    {
        _shopNameArray = [NSMutableArray array];
        
        [_shopNameArray addObject:@"  店 铺 街"];
        [_shopNameArray addObject:@"  推 荐 商 品"];
    }
    return _shopNameArray;
}

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image         = [[UIImage imageNamed:@"index_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"index_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem.title   = @"首页";
        
        _refreshCount           = 1;
        _selectedChannelIndex   = ShopListChannelRecommendation;
        _userContentOffsetX     = 0;
        _isGenerateTableViews   = NO;
    }
    return self;
}

#pragma mark - UIView Life Cycle -

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    //    self.navigationController.navigationBar.hidden = NO;
    
    // 页面访问量统计
    //  [TalkingData trackPageBegin:@"page_name"];
    
    [_searchCancel setHidden:YES];
    [_openQRCode setHidden:NO];
    _searchText.text = @"";
    
    _searchText.delegate = self;
    _searchTableView.delegate = self;
    
    UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
    NSString *cartCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"];
    if ([cartCount intValue] == 0) {
        cartVC.tabBarItem.badgeValue = nil;
    } else {
        cartVC.tabBarItem.badgeValue = cartCount;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 页面访问量统计
    //  [TalkingData trackPageEnd:@"page_name"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bannarArray = [NSMutableArray array];
    
    _shopStreetArray = [NSMutableArray array];
    
    _recommendProductsArray = [NSMutableArray array];
    
    [self createUI];
    
    [self getBanner];
    
    [self getShopStreetData];
    
    [self getRecommendProductData];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadDone:) name:ShopListDataEventDoneNotificationName object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadError:) name:ShopListDataEventErrorNotificationName object:nil];
    
    // 设置通知中心角标
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //    NSInteger count = [[defaults objectForKey:kRemoteNotification] integerValue];
    //
    //    if (count > 0) {
    //        UIViewController *about = [self.tabBarController.viewControllers objectAtIndex:3];
    //        about.tabBarItem.badgeValue = @"New";
    //    }
    
    self.view.userInteractionEnabled = YES;
    
    self.tabBarClick = YES;
    
    self.tabBarController.delegate = self;
    
    // 搜索 Table 遮罩层
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight)];
    
    if (kDeviceOSVersion < 7.0) {
        _searchView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    _searchView.backgroundColor = kBackgroundColor;
    _searchView.userInteractionEnabled = YES;
    _searchView.hidden = YES;
    
    [self.view addSubview:_searchView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(cancelSearch)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    
    [_searchView addGestureRecognizer:tap];
    
    // 搜索 Table
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)
                                                    style:UITableViewStyleGrouped];
    _searchTableView.tag = ShopListSearchTable;
    _searchTableView.userInteractionEnabled = YES;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    
    if (kDeviceOSVersion < 7.0) {
        _searchTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    
    UIView *view = [[UIView alloc] initWithFrame:kScreenBounds];
    view.backgroundColor = kBackgroundColor;
    
    _searchTableView.backgroundView = view;
    
    [_searchView addSubview:_searchTableView];
    
    YunLog(@"_searchView.subviews = %@", _searchView.subviews);
    
    UIView *container = [[UIView alloc] init];
    
    if (kIsiPhone)
    {
        container.frame  = CGRectMake(0, 0, kScreenWidth - 20, 44);
    }
    else
    {
        container.frame = CGRectMake(0, 0, kScreenWidth - 30, 44);
    }
    
    self.view.backgroundColor = COLOR(245, 245, 245, 1);
    
    // 购物车角标
    NSString *count = [[CartManager defaultCart] productCount];
    UIViewController *cartVC = [self.tabBarController.viewControllers objectAtIndex:1];
    
    if ([count isEqualToString:@"0"]) {
        cartVC.tabBarItem.badgeValue = nil;
    } else {
        cartVC.tabBarItem.badgeValue = count;
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    _searchType = kSearchTypeProduct;
    
    _searchText = [[NewSearchTextField alloc] init];
    
    if (kIsiPhone)
    {
        _searchText.frame  = CGRectMake(0, 7, container.frame.size.width - 40, 32);
    }
    else
    {
        _searchText.frame = CGRectMake(0, 7, container.frame.size.width - 50, 32);
    }
    
    _searchText.delegate = self;
    _searchText.searchDelegate = self;
    _searchText.text = @"";
    _searchText.placeholder = @"来搜索想要的商品吧~";
    
    [container addSubview:_searchText];
    
    // 顶部搜索取消按钮
    _searchCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    if (kIsiPhone)
    {
        _searchCancel.frame = CGRectMake(CGRectGetMaxX(_searchText.frame), 0, 50, 44);
    }
    else
    {
        _searchCancel.frame = CGRectMake(CGRectGetMaxX(_searchText.frame) + 5, 0, 50, 44);
    }
    _searchCancel.backgroundColor = kClearColor;
    _searchCancel.hidden = YES;
    _searchCancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [_searchCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_searchCancel setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_searchCancel addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:_searchCancel];
    
    // 搜索视图的通知相关
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchTableViewFrameChange:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchTableViewFrameChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotificationAction:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
//    ShopListDataSource *dataSource = [ShopListDataSource sharedDataSource];
    
    
    //    static dispatch_once_t predicateForShowInitData;
    //
    //    dispatch_once(&predicateForShowInitData, ^{
//    if ( (dataSource.getShopStreetDataDone || dataSource.getRecommendProductDataDone || dataSource.getBannerDone)) {
//        [self createUI];
//    }
//    else if (dataSource.waiting == YES) {
//        if (self.navigationController.view) {
//            if (!_hud) {
//                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                [_hud addSuccessString:@"努力加载中..." delay:2.0];
//            }
//        }
//    }
//    else {
//        if (self.navigationController.view) {
//            if (!_hud) {
//                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                [_hud addErrorString:@"数据错误，请检查网络" delay:2.0];
//            }
//        }
//    }
    //    });
    
    // 扫描二维码
    //    _openQRCode = [UIButton buttonWithType:UIButtonTypeCustom];
    //    _openQRCode.frame = CGRectMake(kScreenWidth - 45, 0, 30, 44);
    //    _openQRCode.backgroundColor = kClearColor;
    //    [_openQRCode addTarget:self action:@selector(pushToQRCode) forControlEvents:UIControlEventTouchUpInside];
    //    [self.navigationController.navigationBar addSubview:_openQRCode];
    //
    //    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake((_openQRCode.frame.size.width - 16) / 2, 7, 16, 16)];
    //    image.image = [UIImage imageNamed:@"scan"];
    //    [_openQRCode addSubview:image];
    //
    //    _label = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 55, 25, 50, 16)];
    //    _label.text = @"扫一扫";
    //    _label.textAlignment = NSTextAlignmentCenter;
    //    _label.textColor = COLOR(255, 255, 255, 1);
    //    _label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    //    [self.navigationController.navigationBar addSubview:_label];
    
    [_timer setFireDate:[NSDate distantPast]];
    
    // 顶部搜索输入框
    //    _searchType = kSearchTypeProduct;
    //
    //    _searchText = [[SearchTextField alloc] initWithFrame:CGRectMake(10, 6, kScreenWidth - 70, 32)];
    //    _searchText.delegate = self;
    //    _searchText.searchDelegate = self;
    //    _searchText.text = @"";
    //    _searchText.placeholder = @"快来搜索想要的商品吧~";
    //
    //    [self.navigationController.navigationBar addSubview:_searchText];
    
    // 顶部搜索输入按钮
    //    _searchCancel = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 0, 60, 44)];
    //    _searchCancel.backgroundColor = kClearColor;
    //    _searchCancel.hidden = YES;
    //    [_searchCancel setTitle:@"取消" forState:UIControlStateNormal];
    //    [_searchCancel setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    //    [_searchCancel addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [self.navigationController.navigationBar addSubview:_searchCancel];
    
    // 扫描二维码
    _openQRCode = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (kIsiPhone)
    {
        _openQRCode.frame = CGRectMake(CGRectGetMaxX(_searchText.frame), 0, 50, 44);
    }
    else
    {
        _openQRCode.frame = CGRectMake(CGRectGetMaxX(_searchText.frame) + 5, 0, 50, 44);
    }
    //        _openQRCode.backgroundColor = [UIColor redColor];
    //        _openQRCode.backgroundColor = kClearColor;
    
    [_openQRCode setImage:[UIImage imageNamed:@"sao_new"] forState:UIControlStateNormal];
    [_openQRCode addTarget:self action:@selector(pushToQRCode) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:_openQRCode];
    
    //        container.backgroundColor = [UIColor blackColor];
    
    [self.navigationItem setTitleView:container];
    
    // 搜索视图的通知相关
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(searchTableViewFrameChange:)
    //                                                 name:UIKeyboardWillShowNotification
    //                                               object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(searchTableViewFrameChange:)
    //                                                 name:UIKeyboardWillChangeFrameNotification
    //                                               object:nil];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(applicationDidBecomeActiveNotificationAction:)
    //                                                 name:UIApplicationDidBecomeActiveNotification
    //                                               object:nil];
    
    //    AppDelegate *appDelegate = kAppDelegate;
    //
    //    if ((_selectedChannelIndex == ShopListChannelFavorite || _selectedChannelIndex == ShopListChannelOrder)) {
    //        [self changeChannel:(UIButton *)_tableHeaderView.subviews[appDelegate.isLogin ? _selectedChannelIndex : 0]];
    //    }
    
    // 从后台进入前台
    //    if (_isGenerateTableViews) {
    //        AppDelegate *appDelegate = kAppDelegate;
    //
    //        if (appDelegate.isFromBackground) {
    //            appDelegate.isFromBackground = NO;
    //
    //            if ((_selectedChannelIndex == ShopListChannelFavorite || _selectedChannelIndex == ShopListChannelOrder) && !appDelegate.isLogin) {
    //                [self changeChannel:(UIButton *)_tableHeaderView.subviews[0]];
    //            } else {
    //                [self refreshPage];
    //            }
    //        } else {
    //            if ((_selectedChannelIndex == ShopListChannelFavorite || _selectedChannelIndex == ShopListChannelOrder)) {
    //                if (!appDelegate.isLogin) {
    //                    [self changeChannel:(UIButton *)_tableHeaderView.subviews[0]];
    //                } else {
    //                    [self refreshPage];
    //                }
    //            }
    //        }
    //    }
    
    //    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    //
    //    dispatch_after(time, dispatch_get_main_queue(), ^(void){
    //        [TalkingData trackPageBegin:@"进入商铺列表页面"];
    //    });
    
    // 计算消息数量
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _messageCount = [[defaults objectForKey:kRemoteNotification] integerValue];
    //    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 页面退出，消除对象
 */
//- (void)dealloc
//{
//    _searchText.delegate = nil;
//    //    _tableView.delegate = nil;
//    _searchTableView.delegate = nil;
//    
//    for (id so in _scrollView.subviews) {
//        if ([so isKindOfClass:[UITableView class]]) {
//            UITableView *tableView = (UITableView *)so;
//            tableView.delegate = nil;
//        }
//    }
//}

#pragma mark - GetData -

/**
 *  获得轮播图的数据
 */
- (void)getBanner
{
    NSString *bannerURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kHomeBannerURL params:nil];
    
    YunLog(@"轮播图 URL - %@",bannerURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:bannerURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"banner list responseObject = %@, %@", responseObject, [NSThread currentThread]);
        
        NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
        
        if ([code isEqualToString:kSuccessCode]) {
            NSArray *tops = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"banners"]);
            
            for (NSDictionary *dic in tops)
            {
                YunLog(@"banner = %@",dic);
                
                BannerModel *banner = [[BannerModel alloc] init];
                [banner setValuesForKeysWithDictionary:dic];
                
                [_bannarArray addObject:banner];
            }
    
            [self createHeaderView];
        }
        else {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"banner list error = %@", error);
    }];
}

/**
 获得首页店铺街和商品推荐的数据
 */
- (void)getShopStreetData
{
    NSString *homeURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kShopStreetHomeURL params:nil];
    
    YunLog(@"推荐店铺 - homeURL = %@", homeURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:homeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"homePage - responseObject = %@",responseObject);

        if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
            NSArray *arrayShops = [[responseObject objectForKey:@"data"] objectForKey:@"shops"];
            
            for (NSDictionary *shopDict in arrayShops)
            {
                ShopStreetModel *shopStreetModel = [[ShopStreetModel alloc] init];
                [shopStreetModel setValuesForKeysWithDictionary:shopDict];
                
                [_shopStreetArray addObject:shopStreetModel];
            }
            
            [_tableView reloadData];
        }
        else {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     }];
}

/**
 获取首页推荐数据
 */
- (void)getRecommendProductData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    // 获取推荐商品数据
    NSString *activityURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kHomeRecommendProductsListURL params:nil];
    
    YunLog(@"shop HOME url = %@", activityURL);
    
    [manager GET:activityURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"shop activity responseObject = %@", responseObject);
        
        if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
        {
            _recommendProductsArray = [NSMutableArray arrayWithArray:kNullToArray([[[responseObject objectForKey:@"data"] objectForKey:@"tags"][0] objectForKey:@"products"])];
            for (NSInteger i = _recommendProductsArray.count - 1; i >= 0; i --) {
                if ([_recommendProductsArray[i] allKeys].count == 0) {
                    [_recommendProductsArray removeObjectAtIndex:i];
                }
            }
            
            if (_recommendProductsArray.count % 2 == 1) {
                [_recommendProductsArray removeLastObject];
            }
            
            [_tableView reloadData];
        }
        else
        {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"shop activity error = %@", error);
    }];
}

#pragma mark - Create UI -

- (void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = kBackgroundColor;
    
    [self createHeaderView];
    
    [self.view addSubview:_tableView];
}

- (void)createHeaderView
{
    _tableView.tableHeaderView = nil;
    
    CGFloat bannerMaxY = 0;
    CGFloat bannerH = 0.0;
    if (_bannarArray.count == 0) {
        bannerMaxY = 0;
        bannerH = 0;
    } else {
        bannerH = (kScreenWidth / 640) * 200;
        bannerMaxY = (kScreenWidth / 640) * 200;
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kIsiPhone ? bannerH + 70 * 2 + 1.5 : bannerH + 100 * 2 + 1.5)];
    backView.backgroundColor = [UIColor redColor];
    
    CGFloat bannerHeight = (kScreenWidth / 640) * 200;
    
    YunLog(@"kScreenWidth = %f, 375.0 / kScreenWidth = %f", kScreenWidth, 375.0 / kScreenWidth);
    
    /// 添加网络请求数据
    SDCycleScrollView *bannar= [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, bannerHeight) imagesGroup:nil];
    
    /// 分页控制器图标
    bannar.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    bannar.delegate = self;
    
    /// 分页控制器颜色
    [backView addSubview:bannar];
    
    /// 占位图片
    bannar.placeholderImage = [UIImage imageNamed:@"logo_register"];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    
    for (BannerModel *model in _bannarArray)
    {
        [imageArray addObject:model.image_size_640_200];
    }
    
    // 加载延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        bannar.imageURLStringsGroup = imageArray;
    });
    
    CGFloat space = 0.5;
    CGFloat buttonWidth = (kScreenWidth - 2 * space) / 3;
    CGFloat buttonHeight = 0;
    if (kIsiPhone) {
        buttonHeight = 70;
    } else {
        buttonHeight = 100;
    }
    
    CGFloat iconW = 0;
    if (kIsiPhone) {
        iconW = 40;
    } else {
        iconW = 60;
    }
    CGFloat iconX = buttonWidth / 2 - iconW / 2;
    
    CGFloat titleW = iconW;
    CGFloat titleH = 12;
    
    NSArray *buttonTittle = @[@"推荐",@"活动",@"商铺",@"收藏",@"订单",@"消息"];
    
    NSArray *buttonImageName = [NSArray array];
    
    buttonImageName = @[@"commend_icon",@"activity_icon",@"shop_icon",@"collection_icon",@"order_icon",@"message_icon"];
    
    for (int i = 0; i < 6; i ++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSInteger row = i / 3;
        NSInteger col = i % 3;
        
        button.frame = CGRectMake((buttonWidth + space) * col, space + bannerMaxY + (space + buttonHeight) * row, buttonWidth, buttonHeight);
        button.backgroundColor = COLOR(255, 255, 255, 1);
        button.tag = ShopListChannelRecommendation + i;
        [button addTarget:self action:@selector(homePageButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [backView addSubview:button];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, 8, iconW, iconW)];
        icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", buttonImageName[i]]];
        
        [button addSubview:icon];
        
        UILabel *title = [[UILabel alloc] init];
        if (kIsiPhone) {
            title.frame = CGRectMake(iconX, CGRectGetMaxY(icon.frame) + 2, titleW, titleH);
        } else {
            title.frame = CGRectMake(iconX, CGRectGetMaxY(icon.frame) + 10, titleW, titleH);
        }
        title.text = [NSString stringWithFormat:@"%@",buttonTittle[i]];
        if (kIsiPhone) {
            title.font = kSmallFont;
        } else {
            title.font = kNormalFont;
        }
        title.tag = ShopListChannelRecommendation + i + 100;
        title.textAlignment = NSTextAlignmentCenter;
        // 等待做处理
        if (i == 5) {
            if (_messageCount > 0) {
                title.textColor = [UIColor orangeColor];
                
                NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%ld)",buttonTittle[i],(long)_messageCount]];
                NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"消息"].location, [[noteStr string] rangeOfString:@"消息"].length);
                [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange];
                [title setAttributedText:noteStr] ;
                [title sizeToFit];
            }
        }
        
        [button addSubview:title];
        
        if (i == 5) {
            self.overallHeight = CGRectGetMaxY(button.frame) + kSpaceWidth;
            YunLog(@"test - self.overHeight = %ld",(long)self.overallHeight);
        }
    }
    
    CGFloat lineHeight = space;
    
    UIView *rowLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, bannerMaxY, kScreenWidth, lineHeight)];
    rowLine1.backgroundColor = kLineColor;
    [backView addSubview:rowLine1];
    
    UIView *rowLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, bannerMaxY + lineHeight + buttonHeight, kScreenWidth, lineHeight)];
    rowLine2.backgroundColor = kLineColor;
    [backView addSubview:rowLine2];
    
    UIView *rowLine3 = [[UIView alloc] initWithFrame:CGRectMake(0, bannerMaxY + (lineHeight + buttonHeight) * 2, kScreenWidth, lineHeight)];
    rowLine3.backgroundColor = kLineColor;
    [backView addSubview:rowLine3];
    
    UIView *colLine1 = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, bannerMaxY, space, (buttonHeight + lineHeight) * 2)];
    colLine1.backgroundColor = kLineColor;
    [backView addSubview:colLine1];
    
    UIView *colLine2 = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth * 2 + lineHeight, bannerMaxY, space, (buttonHeight + lineHeight) * 2)];
    colLine2.backgroundColor = kLineColor;
    
    [backView addSubview:colLine2];
    
    _tableView.tableHeaderView = backView;
}
/**
 创建首页轮播图
 */
//- (void)createBanner
//{
//    /// 背景滚动视图
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 48)];
//
//    [self.view addSubview:_scrollView];
//
//    CGFloat bannerHeight = (kScreenWidth / 640) * 200;
//
//    /// 添加网络请求数据
//    _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, bannerHeight) imagesGroup:nil];
//
//    /// 分页控制器图标
//    _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
//    _cycleScrollView.delegate = self;
//    
//    /// 分页控制器颜色
//    /// _cycleScrollView.dotColor = [UIColor orangeColor];
//    [_scrollView addSubview:_cycleScrollView];
//    
//    // 占位图片
//    _cycleScrollView.placeholderImage = [UIImage imageNamed:@"default_image_large"];
//}

/**
 创建首页视图中间六个按钮
 */
//- (void)createButton
//{
//    CGFloat bannerMaxY = (kScreenWidth / 640) * 200;
//    
//    CGFloat space = 0.5;
//    CGFloat buttonWidth = (kScreenWidth - 2 * space) / 3;
//    CGFloat buttonHeight = 0;
//    if (kIsiPhone) {
//        buttonHeight = 70;
//    } else {
//        buttonHeight = 100;
//    }
//    
//    CGFloat iconW = 0;
//    if (kIsiPhone) {
//        iconW = 40;
//    } else {
//        iconW = 60;
//    }
//    CGFloat iconX = buttonWidth / 2 - iconW / 2;
//    
//    CGFloat titleW = iconW;
//    CGFloat titleH = 12;
//    
//    NSArray *buttonTittle = @[@"推荐",@"活动",@"商铺",@"收藏",@"订单",@"消息"];
//    
//    NSArray *buttonImageName = [NSArray array];
//    
//    buttonImageName = @[@"commend_icon",@"activity_icon",@"shop_icon",@"collection_icon",@"order_icon",@"message_icon"];
//    
//    for (int i = 0; i < 6; i ++)
//    {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        
//        NSInteger row = i / 3;
//        NSInteger col = i % 3;
//        
//        button.frame = CGRectMake((buttonWidth + space) * col, space + bannerMaxY + (space + buttonHeight) * row, buttonWidth, buttonHeight);
//        button.backgroundColor = COLOR(255, 255, 255, 1);
//        button.tag = ShopListChannelRecommendation + i;
//        [button addTarget:self action:@selector(homePageButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [_scrollView addSubview:button];
//        
//        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, 8, iconW, iconW)];
//        icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", buttonImageName[i]]];
//        
//        [button addSubview:icon];
//        
//        UILabel *title = [[UILabel alloc] init];
//        if (kIsiPhone) {
//            title.frame = CGRectMake(iconX, CGRectGetMaxY(icon.frame) + 2, titleW, titleH);
//        } else {
//            title.frame = CGRectMake(iconX, CGRectGetMaxY(icon.frame) + 10, titleW, titleH);
//        }
//        title.text = [NSString stringWithFormat:@"%@",buttonTittle[i]];
//        if (kIsiPhone) {
//            title.font = kSmallFont;
//        } else {
//            title.font = kNormalFont;
//        }
//        title.tag = ShopListChannelRecommendation + i + 100;
//        title.textAlignment = NSTextAlignmentCenter;
//        // 等待做处理
//        if (i == 5) {
//            if (_messageCount > 0) {
//                title.textColor = [UIColor orangeColor];
//                
//                NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%ld)",buttonTittle[i],(long)_messageCount]];
//                NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"消息"].location, [[noteStr string] rangeOfString:@"消息"].length);
//                [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange];
//                [title setAttributedText:noteStr] ;
//                [title sizeToFit];
//            }
//        }
//        
//        [button addSubview:title];
//        
//        if (i == 5) {
//            self.overallHeight = CGRectGetMaxY(button.frame) + kSpaceWidth;
//            YunLog(@"test - self.overHeight = %ld",(long)self.overallHeight);
//        }
//    }
//    
//    CGFloat lineHeight = space;
//    
//    UIView *rowLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, bannerMaxY, kScreenWidth, lineHeight)];
//    rowLine1.backgroundColor = kLineColor;
//    [_scrollView addSubview:rowLine1];
//    
//    UIView *rowLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, bannerMaxY + lineHeight + buttonHeight, kScreenWidth, lineHeight)];
//    rowLine2.backgroundColor = kLineColor;
//    [_scrollView addSubview:rowLine2];
//    
//    UIView *rowLine3 = [[UIView alloc] initWithFrame:CGRectMake(0, bannerMaxY + (lineHeight + buttonHeight) * 2, kScreenWidth, lineHeight)];
//    rowLine3.backgroundColor = kLineColor;
//    [_scrollView addSubview:rowLine3];
//    
//    UIView *colLine1 = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, bannerMaxY, space, (buttonHeight + lineHeight) * 2)];
//    colLine1.backgroundColor = kLineColor;
//    [_scrollView addSubview:colLine1];
//    
//    UIView *colLine2 = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth * 2 + lineHeight, bannerMaxY, space, (buttonHeight + lineHeight) * 2)];
//    colLine2.backgroundColor = kLineColor;
//    
//    [_scrollView addSubview:colLine2];
//}

/**
 创建首页店铺街视图和商品推荐视图
 */
//- (void)createUI
//{
//    //加载之前删除所有之前的view
//    [self removeUI];
//    
////    ShopListDataSource *shopListDataSource = [ShopListDataSource sharedDataSource];
//    
//    [self createBanner];
//    [self createButton];
//    
//    // 第一张广告图  ----需要进行判断是否需要添加
//    //    _fristImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.overallHeight, kScreenWidth, 60)];
//    //    _fristImageView.image = [UIImage imageNamed:@"commit_order"];
//    //
//    //    [_scrollView addSubview:_fristImageView];
//    
//    // 添加一个透明按钮，进行广告的点击时间处理
//    //    UIButton *fristBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.overallHeight, kScreenWidth, 60)];
//    //    [fristBtn addTarget:self action:@selector(enterAdvertisingClick:) forControlEvents:UIControlEventTouchUpInside];
//    //    fristBtn.backgroundColor = kClearColor;
//    //    [_scrollView addSubview:fristBtn];
//    //
//    //    self.overallHeight = CGRectGetMaxY(_fristImageView.frame) + kSpaceWidth;
//    
//    /// 店铺街标签view
//    CGFloat shopStreetViewY = self.overallHeight;
//    _shopStreetView = [[UIView alloc] initWithFrame:CGRectMake(0, shopStreetViewY, kScreenWidth, 30)];
//    _shopStreetView.backgroundColor = COLOR(255, 255, 255, 1);
//    
//    [_scrollView addSubview:_shopStreetView];
//    
//    /// 添加标签 （店铺名Label）
//    CGFloat shopStreetLabelW = _shopStreetView.bounds.size.width;
//    CGFloat shopStreetLabelH = _shopStreetView.bounds.size.height;
//    
//    UILabel *shopStreetLabel = [MyControl createLabelWithFrame:CGRectMake(15, 0, shopStreetLabelW, shopStreetLabelH) Font:14 Text:@"店铺街"];
//    shopStreetLabel.textColor = COLOR(115, 115, 115, 1);
//    shopStreetLabel.textAlignment = NSTextAlignmentLeft;
//    
//    [_shopStreetView addSubview:shopStreetLabel];
//    
//    /// 活动提示标签
//    UILabel *streetActiveLabel = [[UILabel alloc] init];
//    streetActiveLabel.text = @"优惠活动：满200减10元活动";
//    streetActiveLabel.font = [UIFont systemFontOfSize:10];
//    streetActiveLabel.textColor = COLOR(234, 34, 40, 1);
//    
//    CGFloat streetActiveLabelW = [streetActiveLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
//                                                                      options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]}
//                                                                      context:nil].size.width;
//    
//    CGFloat streetActiveLabelX = _shopStreetView.bounds.size.width - (streetActiveLabelW + 10);
//    
//    streetActiveLabel.frame = CGRectMake(streetActiveLabelX, 0, streetActiveLabelW, _shopStreetView.bounds.size.height);
//    // 可以直接开启
//    //    [_shopStreetView addSubview:streetActiveLabel];
//    
//    /// 店铺商品展示
//    
//    CGFloat backProductStreetViewX = kSpaceWidth; // 10
//    CGFloat backProductStreetViewW = kScreenWidth - backProductStreetViewX * 2;
//    CGFloat backProductStreetViewH = (kScreenWidth - kSpaceWidth * 2) / 3 + 40;
//    
//    for (int i = 0; i < shopListDataSource.shopStreetArray.count; i++) {
//        /// 获取数据，进行展示
//        ShopStreetModel *shopStreetModel = shopListDataSource.shopStreetArray[i];
//        YunLog(@"shopStreetModel = %@", shopStreetModel);
//        
//        NSArray *arrayTemp = shopStreetModel.products;
//        
//        _productStreetArray = [NSMutableArray array];
//        
//        // 获取每个店铺街下面三个产品的有关数据
//        for (NSDictionary *productDictTemp in arrayTemp)
//        {
//            ShopStreetProductsModel *productsModel = [[ShopStreetProductsModel alloc] init];
//            [productsModel setValuesForKeysWithDictionary:productDictTemp];
//            
//            [self.productStreetArray addObject:productsModel];
//        }
//        
//        CGFloat backProductStreetViewY = (CGRectGetMaxY(_shopStreetView.frame) + kSpaceWidth) + (backProductStreetViewH + kSpaceWidth) * i;
//        
//        UIView *backProductStreetView = [[UIView alloc] initWithFrame:CGRectMake(backProductStreetViewX, backProductStreetViewY, backProductStreetViewW, backProductStreetViewH)];
//        backProductStreetView.backgroundColor = COLOR(255, 255, 255, 1);
//        
//        [_scrollView addSubview:backProductStreetView];
//        
//        /**
//         获取最后一个商品展示的高度
//         */
//        if (i == shopListDataSource.shopStreetArray.count - 1) {
//            self.overallHeight = CGRectGetMaxY(backProductStreetView.frame) + kSpaceWidth;
//        }
//        
//        _scrollView.contentSize = CGSizeMake(kScreenWidth, self.overallHeight);
//        
//        /// 添加左边的小视图
//        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSpaceWidth, 33)];
//        leftView.backgroundColor = self.leftViewArray[i];
//        
//        [backProductStreetView addSubview:leftView];
//        
//        /// 添加店铺图标
//        CGFloat shopIconImageViewX = CGRectGetMaxX(leftView.frame) + kSpaceWidth;
//        CGFloat shopIconImageViewW = 25;
//        CGFloat shopIconImageViewH = 25;
//        CGFloat shopIconImageViewY = (leftView.bounds.size.height - shopIconImageViewH) / 2;
//        
//        UIImageView *shopIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(shopIconImageViewX, shopIconImageViewY, shopIconImageViewW, shopIconImageViewH)];
//        [shopIconImageView setImageWithURL:[NSURL URLWithString:shopStreetModel.logo] placeholderImage:[UIImage imageNamed:@"default_image"]];
//        
//        [backProductStreetView addSubview:shopIconImageView];
//        
//        /// 添加店铺名
//        UILabel *shopNameLabel = [[UILabel alloc] init];
//        shopNameLabel.text = shopStreetModel.title;
//        shopNameLabel.font = kSmallFont;
//        shopNameLabel.textColor = COLOR(40, 40, 40, 1);
//        
//        CGFloat shopNameLabelW = [streetActiveLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 33)
//                                                                      options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                                                   attributes:@{NSFontAttributeName:shopNameLabel.font}
//                                                                      context:nil].size.width;
//        
//        CGFloat shopNameLabelX = CGRectGetMaxX(shopIconImageView.frame) + 10;
//        CGFloat shopNameLabelH = leftView.bounds.size.height;
//        
//        shopNameLabel.frame = CGRectMake(shopNameLabelX, 0, shopNameLabelW, shopNameLabelH);
//        
//        [backProductStreetView addSubview:shopNameLabel];
//        
//        /// 添加箭头指示
//        CGFloat arrowheadImageViewW = kSpaceWidth;
//        CGFloat arrowheadImageViewH = kSpaceWidth * 2;
//        CGFloat arrowheadImageViewX = backProductStreetView.bounds.size.width - arrowheadImageViewW - (kSpace / 2);
//        CGFloat arrowheadImageViewY = (leftView.bounds.size.height - arrowheadImageViewH) / 2;
//        
//        UIImageView *arrowheadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowheadImageViewX, arrowheadImageViewY, arrowheadImageViewW, arrowheadImageViewH)];
//        arrowheadImageView.image = [UIImage imageNamed:@"arrowhead"];
//        
//        [backProductStreetView addSubview:arrowheadImageView];
//        
//        /// 添加按钮，跳转到指定的店铺页面
//        EnterButton *enterShopBtn = [[EnterButton alloc] initWithFrame:CGRectMake(0, 0, backProductStreetViewW, CGRectGetMaxY(leftView.frame))];
//        enterShopBtn.tag = i;
//        [enterShopBtn addTarget:self action:@selector(enterShopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        enterShopBtn.backgroundColor = kClearColor;
//        
//        [backProductStreetView addSubview:enterShopBtn];
//        
//        /// 添加下面的一条线
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftView.frame), backProductStreetViewW, 1)];
//        lineView.backgroundColor = COLOR(222, 222, 222, 1);
//        
//        [backProductStreetView addSubview:lineView];
//        
//        /// 添加示例商品展示图
//        CGFloat shopShowViewY = CGRectGetMaxY(lineView.frame) + kSpace;
//        CGFloat shopShowViewW = (backProductStreetViewW - (4 * kSpace / 2)) / 3;
//        CGFloat shopShowViewH = shopShowViewW;
//        
//        for (int j = 0; j < self.productStreetArray.count; j++)
//        {
//            ShopStreetProductsModel *pModel = self.productStreetArray[j];
//            
//            YunLog(@"pModel = %@", pModel);
//            
//            CGFloat shopShowViewX = kSpace / 2 + (shopShowViewW + kSpace / 2) * j;
//            UIView *shopShowView = [[UIView alloc] initWithFrame:CGRectMake(shopShowViewX, shopShowViewY, shopShowViewW, shopShowViewH)];
//            
//            [backProductStreetView addSubview:shopShowView];
//            
//            /// 添加后面的商品图片
//            UIImageView *productImageView = [[UIImageView alloc] initWithFrame:shopShowView.bounds];
//            
//            __weak typeof(productImageView) weakProductImageView = productImageView;
//            weakProductImageView.contentMode = UIViewContentModeCenter;
//            
//            if (pModel.image_url == nil) {
//                [weakProductImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pModel.smal_image_url]]
//                                            placeholderImage:[UIImage imageNamed:@"default_image"]
//                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                         weakProductImageView.contentMode = UIViewContentModeScaleAspectFit;
//                                                         weakProductImageView.image = image;
//                                                     }
//                                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                         
//                                                     }];
//            } else {
//                [weakProductImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pModel.image_url]]
//                                            placeholderImage:[UIImage imageNamed:@"default_image"]
//                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                         weakProductImageView.contentMode = UIViewContentModeScaleAspectFit;
//                                                         weakProductImageView.image = image;
//                                                     }
//                                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                         [weakProductImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pModel.smal_image_url]]
//                                                                                     placeholderImage:[UIImage imageNamed:@"default_image"]
//                                                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                                                                  weakProductImageView.contentMode = UIViewContentModeScaleAspectFit;
//                                                                                                  weakProductImageView.image = image;
//                                                                                              }
//                                                                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                                                              }];
//                                                     }];
//            }
//            
//            [shopShowView addSubview:productImageView];
//            
//            /// 添加进入按钮product
//            EnterButton *enterProductBtn = [[EnterButton alloc] initWithFrame:shopShowView.bounds];
//            enterProductBtn.productCode = pModel.code;
//            enterProductBtn.shopCode = shopStreetModel.action_value;
//            
//            [enterProductBtn addTarget:self action:@selector(enterProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            enterProductBtn.backgroundColor = kClearColor;
//            
//            [shopShowView addSubview:enterProductBtn];
//            
//            /// 添加透明度展示商品名称UIView
//            CGFloat alphaShopViewH = 0;
//            if (kIsiPhone) {
//                alphaShopViewH = kSpaceWidth * 2;
//            } else {
//                alphaShopViewH = kSpaceWidth * 4;
//            }
//            
//            UIView *alphaShopView = [[UIView alloc] initWithFrame:CGRectMake(shopShowViewX, shopShowViewY + (shopShowViewH - alphaShopViewH), shopShowViewW, alphaShopViewH)];
//            alphaShopView.backgroundColor = COLOR(0, 0, 0, 0.5);
//            
//            [backProductStreetView addSubview:alphaShopView];
//            
//            /// 添加商品名称UILabel
//            UILabel *shopsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth / 2, 0, shopShowViewW - kSpaceWidth, alphaShopView.bounds.size.height)];
//            
//            // shopsNameLabel.text = productDictTemp[@"title"];
//            shopsNameLabel.text = pModel.title;
//            shopsNameLabel.font = [UIFont systemFontOfSize:kFontSmallSize];
//            shopsNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//            shopsNameLabel.textColor = [UIColor whiteColor];
//            
//            [alphaShopView addSubview:shopsNameLabel];
//        }
//        
//        [self.productStreetArray removeAllObjects];
//        self.productStreetArray = nil;
//    }
//    
//    /// 循环创建下面两个商品展示视图
//    for (int i = 0; i < shopListDataSource.recommendProductsArray.count; i++)
//    {
//        /// 第二个广告图片展示
//        //        _sencodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.overallHeight, kScreenWidth, 60)];
//        //        _sencodImageView.image = [UIImage imageNamed:@"commit_order"];
//        //
//        //        [_scrollView addSubview:_sencodImageView];
//        //
//        //        // 添加广告位上的点击按钮
//        //        // 添加一个透明按钮，进行广告的点击时间处理
//        //        UIButton *sencodBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.overallHeight, kScreenWidth, 60)];
//        //        [sencodBtn addTarget:self action:@selector(enterAdvertisingClick:) forControlEvents:UIControlEventTouchUpInside];
//        //        sencodBtn.backgroundColor = kClearColor;
//        //        [_scrollView addSubview:sencodBtn];
//        //
//        //        self.overallHeight = CGRectGetMaxY(_sencodImageView.frame) + kSpaceWidth;
//        
//        // 获取对应的楼层商品展示数据
//        NSDictionary *productDict = shopListDataSource.recommendProductsArray[i];
//        
//        /// 推荐商品展示标签
//        _commendShopView = [[UIView alloc] initWithFrame:CGRectMake(0, self.overallHeight, kScreenWidth, 30)];
//        _commendShopView.backgroundColor = COLOR(255, 255, 255, 1);
//        
//        [_scrollView addSubview:_commendShopView];
//        
//        /// 添加标签 （店铺名Label）
//        CGFloat commendLabelW = _commendShopView.bounds.size.width;
//        CGFloat commendLabelH = _commendShopView.bounds.size.height;
//        NSString *commendLableText = [productDict safeObjectForKey:@"name"];
//        UILabel *commendLabel = [MyControl createLabelWithFrame:CGRectMake(15, 0, commendLabelW, commendLabelH) Font:14 Text:commendLableText];
//        commendLabel.textColor = COLOR(115, 115, 115, 1);
//        commendLabel.textAlignment = NSTextAlignmentLeft;
//        
//        [_commendShopView addSubview:commendLabel];
//        
//        /// 活动提示标签
//        UILabel *commendActiveLabel = [[UILabel alloc] init];
//        commendActiveLabel.text = @"优惠活动：满200减10元活动";
//        commendActiveLabel.font = [UIFont systemFontOfSize:10];
//        commendActiveLabel.textColor = COLOR(234, 34, 40, 1);
//        
//        CGFloat commendActiveLabelW = [streetActiveLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
//                                                                           options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}
//                                                                           context:nil].size.width;
//        
//        CGFloat commendActiveLabelX = _commendShopView.bounds.size.width - (commendActiveLabelW + 10);
//        commendActiveLabel.frame = CGRectMake(commendActiveLabelX, 0, commendActiveLabelW, _commendShopView.bounds.size.height);
//        //        可以直接开启是否添加活动标题
//        //        [_commendShopView addSubview:commendActiveLabel];
//        
//        /// 获取高度
//        self.overallHeight = CGRectGetMaxY(_commendShopView.frame) + kSpaceWidth;
//        
//        /// 添加推荐商品展示窗口
//        CGFloat commendShopViewW = (kScreenWidth - (3 * kSpaceWidth)) / 2;
//        CGFloat commendShopViewH = commendShopViewW;
//        
//        // 获取该层里面的所有的商品 进行布局
//        NSArray *arr = [productDict objectForKey:@"products"];
//        
//        NSMutableArray *productsArray = [NSMutableArray arrayWithArray:arr];
//        
//        // 判断如果数据为空，直接删除
//        NSMutableArray *tempArray = [NSMutableArray array];
//        tempArray = productsArray;
//        for (int i = (int)tempArray.count - 1; i >= 0; i--) {
//            NSDictionary *dict = tempArray[i];
//            
//            NSString *Id = [dict safeObjectForKey:@"id"];
//            if (!Id.length > 0) {
//                [productsArray removeObjectAtIndex:i];
//            }
//        }
//
//        /// 取双
//        if (productsArray.count % 2 != 0) {
//            [productsArray removeLastObject];
//        }
//        
//        for(int j = 0;j < productsArray.count; j++){
//            NSDictionary *product = productsArray[j];
//            //           NSDictionary *product = dictTemp[@"product"];
//            
//            CGFloat commendShopViewX = kSpaceWidth + (commendShopViewW + kSpaceWidth) * ( j % 2 );
//            CGFloat commendShopViewY = self.overallHeight + ((commendShopViewH + kSpaceWidth) * ( j / 2 ) );
//            
//            UIView *commendShopsView = [[UIView alloc] initWithFrame:CGRectMake(commendShopViewX, commendShopViewY, commendShopViewW, commendShopViewH)];
//            commendShopsView.backgroundColor = COLOR(255, 255, 255, 1);
//            
//            [_scrollView addSubview:commendShopsView];
//            
//            // 添加点击时间处理的按钮
//            EnterButton *enterActiveBtn = [[EnterButton alloc] initWithFrame:commendShopsView.bounds];
//            [enterActiveBtn addTarget:self action:@selector(enterRecommendProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//            enterActiveBtn.productCode = [product safeObjectForKey:@"code"];
//            enterActiveBtn.shopCode = [product safeObjectForKey:@"shop_code"];
//            enterActiveBtn.backgroundColor = kClearColor;
//            
//            [commendShopsView addSubview:enterActiveBtn];
//            
//            // 添加后面的商品图片
//            UIImageView *shopImageView = [[UIImageView alloc] initWithFrame:commendShopsView.bounds];
//            
//            __weak typeof(shopImageView) _shopImageView = shopImageView;
//            _shopImageView.contentMode = UIViewContentModeCenter;
//            
//            [_shopImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[product safeObjectForKey:@"large_icon_200_200"]]]
//                                  placeholderImage:[UIImage imageNamed:@"default_image"]
//                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                               _shopImageView.contentMode = UIViewContentModeScaleAspectFit;
//                                               _shopImageView.image = image;
//                                           }
//                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                               [_shopImageView setImageWithURL:[NSURL URLWithString:[product safeObjectForKey:@"icon"]]
//                                                              placeholderImage:[UIImage imageNamed:@"default_image"]];
//                                               // 新添加的 不确定是否正确
//                                               _shopImageView.contentMode = UIViewContentModeScaleAspectFit;
//                                           }];
//            
//            [commendShopsView addSubview:_shopImageView];
//            
//            // 判断是否需要添加活动商品的图标
//            UIImageView *activeShopsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kActiveShopsImageWH, kActiveShopsImageWH)];
//            activeShopsImageView.image = [UIImage imageNamed:@"active"];
//            
//            [commendShopsView addSubview:activeShopsImageView];
//            
//            // 添加透明UIView
//            CGFloat alphaCommendViewH = 0;
//            if (kIsiPhone) {
//                alphaCommendViewH = kSpaceWidth * 4;
//            } else {
//                alphaCommendViewH = kSpaceWidth * 6;
//            }
//            
//            UIView *alphaCommendView = [[UIView alloc] initWithFrame:CGRectMake(0, commendShopViewH - alphaCommendViewH, commendShopViewW, alphaCommendViewH)];
//            
//            [commendShopsView addSubview:alphaCommendView];
//            
//            // 添加一张背景图片实现模糊效果
//            UIImageView *backGroundImageView = [[UIImageView alloc] initWithFrame:alphaCommendView.bounds];
//            UIImage *image = [BlurImage blurryImage:[UIImage imageNamed:@"cover"] withBlurLevel:0.8];
//            backGroundImageView.image = image;
//            backGroundImageView.alpha = 0.6;
//            
//            [alphaCommendView addSubview:backGroundImageView];
//            
//            // 添加推荐名称
//            UILabel *commendShopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth, 0, commendShopViewW - 2 * kSpaceWidth, kSpaceWidth * 2)];
//            commendShopNameLabel.textColor = COLOR(255, 255, 255, 1);
//            commendShopNameLabel.text = [product safeObjectForKey:@"name"];
//            commendShopNameLabel.font = [UIFont boldSystemFontOfSize:kFontSmallSize];
//            
//            [alphaCommendView addSubview:commendShopNameLabel];
//            
//            // 添加推荐商品名称
//            // 宽度带确定数据之后可以计算
//            //            UILabel *commendNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth, CGRectGetMaxY(commendShopNameLabel.frame) + kSpaceWidth / 2, (commendShopViewW / 2), kSpaceWidth - 1)];
//            //
//            //            commendNameLabel.text = @"仿纸杯";
//            //            commendNameLabel.textColor = COLOR(114, 111, 111, 1);
//            //            commendActiveLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//            //            commendNameLabel.font = [UIFont systemFontOfSize:9];
//            //
//            //            [alphaCommendView addSubview:commendNameLabel];
//            
//            // 添加商品售价
//            UILabel *shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth, CGRectGetMaxY(commendShopNameLabel.frame) - kSpace / 5, commendShopViewW, kSpaceWidth * 2)];
//            shopPriceLabel.text = [NSString stringWithFormat:@"￥%@", [product safeObjectForKey:@"price"]];
//            //            shopPriceLabel.text = @"￥9.90";
//            shopPriceLabel.textColor = COLOR(224, 70, 60, 1);
//            shopPriceLabel.font = [UIFont systemFontOfSize:kFontSmallSize];
//            
//            [alphaCommendView addSubview:shopPriceLabel];
//            
//            // 获取高度
//            if (j == productsArray.count - 1)
//            {
//                self.overallHeight = CGRectGetMaxY(commendShopsView.frame) + kSpaceWidth;
//            }
//            // 计算最后的高度
//            if (i == shopListDataSource.recommendProductsArray.count - 1 && j == productsArray.count - 1)
//            {
//                self.overallHeight  = kSpaceWidth +CGRectGetMaxY(commendShopsView.frame);
//            }
//        }
//        
//        _scrollView.contentSize = CGSizeMake(kScreenWidth, self.overallHeight);
//    }
//}

/**
 用于在重新刷新加载数据后删除_scrollView中原本的UIView以供添加新的UIView
 */
//- (void)removeUI
//{
//    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//}

#pragma mark - SDCycleScrollView Delegate -

/**
 轮播图第三方库代理方法实现
 
 @param cycleScrollView 轮播图控件
 @param index 被点击的图片位置
 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
//    ShopListDataSource *shopListDataSource = [ShopListDataSource sharedDataSource];
    
    BannerModel *bannerModel = _bannarArray[index];
    
    NSInteger activityInt = [bannerModel.action_type integerValue];
    
    switch (activityInt)
    {
        case BannerActivityShop:  // 店铺商品
        {
            ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
            shop.code = bannerModel.action_value;
            YunLog(@"shop.code = %@",shop.code);
            shop.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:shop animated:YES];
            
            break;
        }
            
        case BannerActivityWeb: // Web类型活动
        {
            WebViewController *web = [[WebViewController alloc] init];
            web.naviTitle = kNullToString(bannerModel.title);
            web.url = kNullToString(bannerModel.action_value);
            web.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:web animated:YES];
            
            break;
        }
            
        case BannerActivityProductVariant: // 特殊商品
        {
            break;
        }
            
        case BannerActivityProduct: // 商品
        {
            ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
            detail.productCode = bannerModel.code;
            detail.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:detail animated:YES];
            
            break;
        }
            
        case BannerActivityActivity: // 活动商品
        {
            ActivityViewController *activity = [[ActivityViewController alloc] init];
            activity.activityCode = bannerModel.action_value;
            activity.activityName = kNullToString(bannerModel.title);
            activity.isHomePage = NO;
            activity.isBannerPage = YES;
            activity.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:activity animated:YES];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Button Did Click -

/**
 中间按钮点击事件
 
 @param button 被点击的按钮
 */
- (void)homePageButtonDidClick:(UIButton *)button
{
    switch (button.tag) {
        case ShopListChannelRecommendation:  //!< 推荐
        {
            ActivityViewController *vc = [[ActivityViewController alloc] init];
            vc.isHomePage = YES;
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
            
        case ShopListChannelActivity:  //!< 活动
        {
            AllActivityViewController *activityVC = [[AllActivityViewController alloc] init];
            activityVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:activityVC animated:YES];
            
            break;
        }
            
        case ShopListChannelShop:  //!< 商铺
        {
            RecommendViewController *vc = [[RecommendViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
            
        case ShopListChannelFavorite: //!< 收藏
        {
            
            AppDelegate *appDelegate = kAppDelegate;
            
            if (!appDelegate.isLogin) {
                [self login];
                
                return;
            }
            
            FavoriteListViewController *favorite = [[FavoriteListViewController alloc] init];
            favorite.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:favorite animated:YES];
            
            break;
        }
            
        case ShopListChannelOrder:  //!< 订单
        {
            AppDelegate *appDelegate = kAppDelegate;
            
            if (!appDelegate.isLogin) {
                [self login];
                
                return;
            }
            
            OrderListViewController *order = [[OrderListViewController alloc] init];
            order.hidesBottomBarWhenPushed = YES;
            order.orderType = 0;
            
            [self.navigationController pushViewController:order animated:YES];
            
            break;
        }
            
        case ShopListChannelAbout:  //!< 消息
        {
            UILabel *titleLabel = (UILabel *)[self.view viewWithTag:button.tag + 100];
            titleLabel.text = @"消息";
            titleLabel.textColor = [UIColor blackColor];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setObject:@"0" forKey:kRemoteNotification];
            
            [defaults synchronize];
            
            MessageCenterViewController *message = [[MessageCenterViewController alloc] init];
            message.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:message animated:YES];
        }
            
        default:
            break;
    }
}

/**
 跳转到登陆界面
 */
- (void)login
{
    //    LoginViewController *loginVC = [[LoginViewController alloc] init];
    //    loginVC.isReturnView = YES;
    //
    ////    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    ////
    ////    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
    //    [self.navigationController pushViewController:loginVC animated:YES];
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.isReturnView = YES;
    loginVC.isBuyEnter = YES;
    
    //        [self.navigationController pushViewController:loginVC animated:YES];
    
    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
}

#pragma mark - Enter Shop -

/**
 店铺被点击后，进入店铺的详情页面
 
 @param sender 对应的店铺的有关信息
 */
- (void)enterShopBtnClick:(UIButton *)btn
{
    YunLog(@"进入店铺页面");
    
    NSInteger count = btn.tag;
    ShopStreetModel *shopStreetModel = _shopStreetArray[count];
    
    ShopInfoNewController *shopVC = [[ShopInfoNewController alloc] init];
    shopVC.code = shopStreetModel.action_value;
    
    shopVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:shopVC animated:YES];
}

/**
 商品被点击后，进入商品详情页面
 
 @param sender 对应的商品信息
 */
- (void)enterProductBtnClick:(EnterButton *)btn
{
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = btn.productCode;
    detail.shopCode = btn.shopCode;
    //    detail.productCode = @"101243142";
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

/**
 推荐商品被点击，进入商品详情页面
 
 @param btn 对应的商品信息
 */
- (void)enterRecommendProductBtnClick:(EnterButton *)btn
{
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = btn.productCode;
    detail.shopCode = btn.shopCode;
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

/**
 广告点击事件的处理
 
 @param adBtn 点击的第几个广告
 */
- (void)enterAdvertisingClick:(UIButton *)adBtn
{
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = @"104107804";
    
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - UIApplicationNotifications -

- (void)applicationDidBecomeActiveNotificationAction:(NSNotification *)notification
{
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.isFromBackground = NO;
    
    //    [self refreshPage];
}

#pragma mark - Private Functions -

- (void)refreshPage
{
    _refreshCount = 1;
    //    _noMore = NO;
    _reloading = NO;
    
    //    [self getShopList];
}

/**
 搜索视图的位置放生变化时调用
 
 @param noti 收到的通知
 */
- (void)searchTableViewFrameChange:(NSNotification *)noti
{
    NSDictionary *info = [noti userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    YunLog(@"keyboardSize.height = %f", keyboardSize.height);
    
    if (kDeviceOSVersion < 7.0) {
        _searchTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - keyboardSize.height - 60);
    } else {
        _searchTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - keyboardSize.height + 44);
    }
}

/**
 根据不同的类型，跳转到不同的页面中
 
 @param index 对应的点击对象标注
 */
- (void)pushVCForRecommendation:(NSInteger)index
{
    NSInteger actionType = [[_lists[index] objectForKey:@"action_type"] integerValue];
    
    switch (actionType) {
        case 1:
        {
            WebViewController *web = [[WebViewController alloc] init];
            web.naviTitle = kNullToString([_lists[index] objectForKey:@"title"]);
            web.url = kNullToString([_lists[index] objectForKey:@"action_value"]);
            web.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:web animated:YES];
            
            break;
        }
            
        case 2:
        {
            ShopInfoNewController *info = [[ShopInfoNewController alloc] init];
            info.code = kNullToString([_lists[index] objectForKey:@"action_value"]);
            info.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:info animated:YES];
            
            break;
        }
            
        case 3:
        {
            ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
            //            detail.productID = kNullToString([_lists[index] objectForKey:@"action_value"]);
            
            detail.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:detail animated:YES];
            
            break;
        }
            
        case 4:
        {
            break;
        }
            
        case 5:
        {
            ActivityViewController *activity = [[ActivityViewController alloc] init];
            activity.activityID = kNullToString([_lists[index] objectForKey:@"action_value"]);
            activity.activityName = kNullToString([_lists[index] objectForKey:@"title"]);
            activity.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:activity animated:YES];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)pushVCForFavorite:(NSInteger)index
{
    ShopInfoNewController *info = [[ShopInfoNewController alloc] init];
    info.code = kNullToString([_lists[index] objectForKey:@"shop_code"]);
    info.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:info animated:YES];
}

- (void)pushVCForActivity:(NSInteger)index
{
    ActivityViewController *activity = [[ActivityViewController alloc] init];
    activity.activityID = kNullToString([_lists[index] objectForKey:@"action_value"]);
    activity.activityName = kNullToString([_lists[index] objectForKey:@"title"]);
    activity.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:activity animated:YES];
}

- (void)pushVCForOrder:(NSInteger)index
{
    OrderDetailViewController *order = [[OrderDetailViewController alloc] init];
    order.orderID = [NSString stringWithFormat:@"%ld", (long)index];
    order.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:order animated:YES];
}

- (void)pushToFavorite
{
    FavoriteListViewController *favorite = [[FavoriteListViewController alloc] init];
    favorite.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:favorite animated:YES];
}

- (void)goToExpress:(UIButton *)sender
{
    NSString *expressURL = kNullToString([_lists[sender.tag] objectForKey:@"express_url"]);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    expressURL = [expressURL stringByAppendingFormat:@"&platform=iphone&user_session_key=%@", appDelegate.user.userSessionKey];
    
    YunLog(@"expressURL = %@", expressURL);
    
    WebViewController *web = [[WebViewController alloc] init];
    web.naviTitle = @"物流详情";
    web.url = expressURL;
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)goToPay:(UIButton *)sender
{
    [self pushVCForOrder:sender.tag];
}

/**
 点击清除搜索历史按钮时调用
 */
- (void)cleanSearchHistory
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:nil forKey:kSearchHistory];
    
    [defaults synchronize];
    
    [_searchText resignFirstResponder];
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:@"搜索历史清除成功" delay:1.0];
    }
    
    _searchTableView.hidden = YES;
    
    [_searchTableView reloadData];
}

/**
 确定搜索时调用
 
 @param text 搜索的关键字
 */
- (void)pushToSearchVC:(NSString *)text
{
    SearchResultsViewController *search = [[SearchResultsViewController alloc] init];
    search.searchType = _searchType;
    search.keyword = text;
    search.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:search animated:YES];
    
//    _scrollView.hidden = NO;
    //    _tableView.hidden = NO;
    _tableHeaderView.hidden = NO;
    _searchView.hidden = YES;
}

/**
 点击扫二维码按钮时调用
 */
- (void)pushToQRCode
{
    //    QRCodeByZBarViewController *qr = [[QRCodeByZBarViewController alloc] init];
    //    qr.hidesBottomBarWhenPushed = YES;
    //    qr.useType = QRCodeNormal;
    //
    //    [self.navigationController pushViewController:qr animated:YES];
    
    QRCodeByNatureViewController *qr = [[QRCodeByNatureViewController alloc] init];
    qr.hidesBottomBarWhenPushed = YES;
    qr.useType = QRCodeNormal;
    
    [self.navigationController pushViewController:qr animated:YES];
}

/**
 点击取消搜索按钮时调用
 */
- (void)cancelSearch
{
    self.tabBarController.tabBar.hidden = NO;
    
    _searchText.text = @"";
    _searchView.hidden = YES;
    _searchCancel.hidden = YES;
//    _scrollView.hidden = NO;
    //    _tableView.hidden = NO;
    _tableHeaderView.hidden = NO;
    _openQRCode.hidden = NO;
    
    [_searchText resignFirstResponder];
}

- (void)getShopList
{
    //    YunLog(@"_selectedChannelIndex = %ld", (long)_selectedChannelIndex);
    //
    //    AppDelegate *appDelegate = kAppDelegate;
    //
    //    BOOL useDefault = NO;
    //
    //    @try {
    //        NSMutableDictionary *defaultList = (NSMutableDictionary *)_defaultLists[_selectedChannelIndex];
    //        NSArray *content = [defaultList objectForKey:@"content"];
    //        if (content.count > 0) {
    //            YunLog(@"_defaultLists[%ld] = %@", (long)_selectedChannelIndex, _defaultLists[_selectedChannelIndex]);
    //
    //            useDefault = YES;
    //        }
    //    }
    //    @catch (NSException *exception) {
    //
    //    }
    //    @finally {
    //
    //    }
    //
    //    if (useDefault) {
    //        _lists = [NSArray arrayWithArray:[_defaultLists[_selectedChannelIndex] objectForKey:@"content"]];
    //
    //        UITableView *tableView = (UITableView *)_scrollView.subviews[_selectedChannelIndex];
    //        if (!tableView.dataSource) tableView.dataSource = self;
    //
    //        [tableView reloadData];
    //
    //        [_scrollView setContentOffset:CGPointMake(tableView.frame.origin.x, 0) animated:NO];
    //
    //        //        [tableView setContentOffset:CGPointZero animated:NO];
    //
    //        if (_lists.count >= 8 && ![[_defaultLists[_selectedChannelIndex] objectForKey:@"noMore"] isEqualToString:@"noMore"]) {
    //            [self finishedLoadData];
    //        }
    //    } else {
    //        if (!_hud) _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    //        _hud.labelText = @"努力加载中...";
    //
    //        NSDictionary *params = @{@"page"                    :   @"1",
    //                                 @"limit"                   :   @"8",
    //                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
    //                                 @"channel_id"              :   [NSString stringWithFormat:@"%ld", (long)_selectedChannelIndex]};
    //
    //        NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion3 requestURL:kShopListURL params:params];
    //
    //        if (_selectedChannelIndex == ShopListChannelFavorite || _selectedChannelIndex == ShopListChannelOrder) {
    //            listURL = [listURL stringByAppendingFormat:@"&user_session_key=%@", kNullToString(appDelegate.user.userSessionKey)];
    //        }
    //
    //        YunLog(@"shop list url = %@", listURL);
    //
    //        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //        manager.requestSerializer.timeoutInterval = 30;
    //
    //        [manager GET:listURL
    //          parameters:nil
    //             success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //                 YunLog(@"shop list responseObject = %@", responseObject);
    //
    //                 NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
    //
    //                 if ([code isEqualToString:kSuccessCode]) {
    //                     _channels = [[responseObject objectForKey:@"data"] objectForKey:@"channels"];
    //                     _lists = [[responseObject objectForKey:@"data"] objectForKey:@"lists"];
    //
    //                     if (!_defaultLists) {
    //                         _defaultLists = [[NSMutableArray alloc] initWithCapacity:_channels.count];
    //
    //                         for (int i = 0; i < _channels.count; i++) {
    //                             [_defaultLists addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"content", @"more", @"noMore", nil]];
    //                         }
    //
    //                         YunLog(@"init _defaultLists = %@", _defaultLists);
    //                     }
    //
    //                     @try {
    //                         [(NSMutableDictionary *)_defaultLists[_selectedChannelIndex] setObject:[NSArray arrayWithArray:_lists]
    //                                                                                         forKey:@"content"];
    //                     }
    //                     @catch (NSException *exception) {
    //                         YunLog(@"default lists set object exception = %@", exception);
    //                     }
    //                     @finally {
    //
    //                     }
    //
    //                     YunLog(@"_defaultLists = %@", _defaultLists);
    //
    //                     [self generateTableHeaderView];
    //
    //                     YunLog(@"_scrollView.subviews = %@", _scrollView.subviews);
    //
    //                     UITableView *tableView = (UITableView *)_scrollView.subviews[_selectedChannelIndex];
    //                     tableView.dataSource = self;
    //
    //                     [tableView reloadData];
    //
    //                     [_scrollView setContentOffset:CGPointMake(tableView.frame.origin.x, 0) animated:NO];
    //
    //                     [tableView setContentOffset:CGPointZero animated:NO];
    //
    //                     [self removeFooterView];
    //
    //                     if (_lists.count >= 8) {
    //                         [self finishedLoadData];
    //                     }
    //
    //                     [_hud hide:YES];
    //                     //                     _hud = nil;
    //                 } else {
    //                     NSString *message = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]);
    //
    //                     if ([message isEqualToString:@""]) {
    //                         [_hud addErrorString:@"获取商品数据异常" delay:2.0];
    //                     } else {
    //                         [_hud addErrorString:message delay:2.0];
    //                     }
    //                 }
    //             }
    //             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                 YunLog(@"shop list error = %@", error);
    //
    //                 [_hud addErrorString:@"获取商品数据异常" delay:2.0];
    //             }
    //         ];
    //
    //        // 检测 user_session_key 合法性
    //        if (![appDelegate.user.userSessionKey isEqualToString:@""])
    //        {
    //            NSDictionary *invoiceParams = @{@"user_session_key"        :    kNullToString(appDelegate.user.userSessionKey),
    //                                            @"terminal_session_key"    :    kNullToString(appDelegate.terminalSessionKey)};
    //
    //            NSString *invoiceURL = [Tool buildRequestURLHost:kRequestHost
    //                                                  APIVersion:kAPIVersion1
    //                                                  requestURL:kInvoiceQueryURL
    //                                                      params:invoiceParams];
    //
    //            YunLog(@"invoice listURL = %@", invoiceURL);
    //
    //            [manager GET:invoiceURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //                YunLog(@"invoice list responseObject = %@", responseObject);
    //
    //                NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
    //
    //                if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
    //                    [Tool resetUser];
    //                }
    //
    //            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                YunLog(@"valid user_session_key error = %@", error);
    //            }];
    //        }
    //    }
}

- (void)generateTableHeaderView
{
    //    if (!_isGenerateTableViews) {
    //        if (!_tableHeaderView) {
    //            _tableHeaderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, 44)];
    //            _tableHeaderView.showsHorizontalScrollIndicator = NO;
    //            _tableHeaderView.showsVerticalScrollIndicator = NO;
    //            _tableHeaderView.backgroundColor = [UIColor whiteColor];
    //
    //            [_tableHeaderView addBorderWithDirection:AddBorderDirectionBottom
    //                                               color:[UIColor lightGrayColor]
    //                                              border:1
    //                                              indent:10];
    //
    //            [self.view addSubview:_tableHeaderView];
    //        } else {
    //            if (_tableHeaderView.subviews.count > 0) [_tableHeaderView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //        }
    //
    //        int width = 10;
    //
    //        for (int i = 0; i < _channels.count; i++) {
    //            NSString *name = kNullToString([_channels[i] objectForKey:@"name"]);
    //
    //            UIButton *button = [[UIButton alloc] init];
    //            button.tag = [[_channels[i] objectForKey:@"id"] integerValue];
    //            [button setTitle:name forState:UIControlStateNormal];
    //            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    //            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //            button.titleLabel.font = kNormalFont;
    //            [button addTarget:self action:@selector(changeChannel:) forControlEvents:UIControlEventTouchUpInside];
    //
    //            [_tableHeaderView addSubview:button];
    //
    //            CGSize size = [name sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
    //
    //            CGFloat buttonWidth;
    //
    //            if (_channels.count > 4) {
    //                buttonWidth = size.width + 32;
    //            } else {
    //                buttonWidth = size.width + 32 > (kScreenWidth / _channels.count) ? size.width + 32 : kScreenWidth / _channels.count;
    //            }
    //
    //            //        button.frame = CGRectMake(width, 0, buttonWidth, _tableHeaderView.frame.size.height);
    //            button.frame = CGRectMake(width, 0, (kScreenWidth - 20) / 4, _tableHeaderView.frame.size.height);
    //
    //            width += button.frame.size.width;
    //
    //            if (i == _selectedChannelIndex) {
    //                button.selected = YES;
    //                if (_selectedChannelBottomLine) {
    //                    [_selectedChannelBottomLine removeFromSuperlayer];
    //                }
    //
    //                _selectedChannelBottomLine = [CALayer layer];
    //                _selectedChannelBottomLine.frame = CGRectMake(button.frame.origin.x, _tableHeaderView.frame.size.height - 1, (kScreenWidth - 20) / 4, 1);
    //                _selectedChannelBottomLine.backgroundColor = [UIColor orangeColor].CGColor;
    //
    //                //            _selectedChannelBottomLine = [CALayer layer];
    //                //            _selectedChannelBottomLine.frame = CGRectMake((button.frame.size.width - size.width - 4) / 2 + button.frame.origin.x, _tableHeaderView.frame.size.height - 4, size.width + 4, 4);
    //                //            _selectedChannelBottomLine.cornerRadius = 2;
    //                //            _selectedChannelBottomLine.masksToBounds = YES;
    //                //            _selectedChannelBottomLine.backgroundColor = [UIColor orangeColor].CGColor;
    //
    //                [_tableHeaderView.layer addSublayer:_selectedChannelBottomLine];
    //            }
    //
    //            [_tableHeaderView addSubview:button];
    //        }
    //
    //        [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //
    //        for (int i = 0; i < _channels.count; i++) {
    //            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.frame.size.height)
    //                                                                  style:UITableViewStylePlain];
    //            tableView.delegate = self;
    //
    //            /**
    //             * 由于每个tableView根据数据动态生成 但使用同一个dataSource 因此后指定dataSrouce
    //             *
    //             * tableView.dataSource = self;
    //             */
    //
    //            tableView.tag = ShopListSearchTable + i + 1;
    //            tableView.backgroundColor = [UIColor whiteColor];
    //
    //            UIView *back = [[UIView alloc] initWithFrame:tableView.frame];
    //            back.backgroundColor = [UIColor whiteColor];
    //
    //            tableView.backgroundView = back;
    //
    //            if (i != 1) {
    //                tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //            }
    //
    //            [_scrollView addSubview:tableView];
    //        }
    //
    //        _scrollView.contentSize = CGSizeMake(_channels.count * kScreenWidth, _scrollView.frame.size.height);
    //        _tableHeaderView.contentSize = CGSizeMake(width, 44);
    //
    //        _isGenerateTableViews = YES;
    //    }
}

- (void)changeChannel:(UIButton *)sender
{
    //    for (id so in _tableHeaderView.subviews) {
    //        if ([so isKindOfClass:[UIButton class]]) {
    //            UIButton *button = (UIButton *)so;
    //            button.selected = NO;
    //        }
    //    }
    //
    //    YunLog(@"sender.tag = %ld", (long)sender.tag);
    //
    //    sender.selected = YES;
    //    _selectedChannelIndex = sender.tag;
    //
    //    //    NSString *title = [sender titleForState:UIControlStateNormal];
    //
    //    //    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
    //
    //    [UIView beginAnimations:@"" context:nil];
    //    [UIView setAnimationDuration:0.5];
    //
    //    //    _selectedChannelBottomLine.frame = CGRectMake((sender.frame.size.width - size.width - 4) / 2 + sender.frame.origin.x, _tableHeaderView.frame.size.height - 4, size.width + 4, 4);
    //
    //    _selectedChannelBottomLine.frame = CGRectMake(sender.frame.origin.x, _tableHeaderView.frame.size.height - 1, (kScreenWidth - 20) / 4, 1);
    //
    //    [UIView commitAnimations];
    //
    //    [_tableHeaderView scrollRectToVisible:sender.frame animated:YES];
    //
    //    AppDelegate *appDelegate = kAppDelegate;
    //
    //    if ((sender.tag == ShopListChannelFavorite || sender.tag == ShopListChannelOrder) && !appDelegate.isLogin) {
    //        LoginViewController *loginVC = [[LoginViewController alloc] init];
    //
    //        UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    //
    //        [self.navigationController presentViewController:loginNC animated:YES completion:nil];
    //
    //        AppDelegate *appDelegate = kAppDelegate;
    //
    //        appDelegate.isFromBackground = YES;
    //    } else {
    //        [self refreshPage];
    //    }
}
//- (void)runTopImages
//{
//    NSInteger page = _pageControl.currentPage;
//
//    page++;
//    page = page > _topImages.count - 1 ? 0 : page;
//    _pageControl.currentPage = page;
//
//    [self turnPage];
//}
//
//- (void)turnPage
//{
//    NSInteger page = _pageControl.currentPage;
//
//    if (page < _topImages.count) {
//        _shopName.text = [_topImages[page] objectForKey:@"title"];
//    }
//
//    [_imageScrollView setViewAtIndex:page];
//}

- (void)registerTermimal
{
    NSString *termimalURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kTerminalSignUpURL params:nil];
    
    YunLog(@"termimalURL = %@", termimalURL);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_key"  :   [Tool getUniqueDeviceIdentifier],
                             @"device_token"  :   kNullToString(appDelegate.deviceToken),
                             @"app_id"        :   kBundleID};
    
    YunLog(@"register terminal params = %@", params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:termimalURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"register terminal responseObject = %@", responseObject);
              
              NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
              
              if ([code isEqualToString:kSuccessCode]) {
                  AppDelegate *appDelegate = kAppDelegate;
                  
                  appDelegate.terminalSessionKey = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"terminal_session_key"]);
                  
              } else {
                  YunLog(@"terminal register error = %@", kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              YunLog(@"register terminal error = %@", error);
          }];
}

- (void)requestScreenFlash
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *screenURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kAppFlashURL params:params];
    
    YunLog(@"screenURL = %@", screenURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:screenURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"request screen flash responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 
                 NSString *timestamp = [defaults objectForKey:kScreenFlashTimestamp];
                 
                 NSArray *screenFlash;
                 
                 if (kScreenHeight == 480) {
                     screenFlash = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:k3_5InchScreenFlash]);
                 } else if (kScreenHeight == 568) {
                     screenFlash = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:k4InchScreenFlash]);
                 }
                 
                 YunLog(@"screenFlash = %@", screenFlash);
                 
                 if (!screenFlash || screenFlash.count <= 0) {
                     NSFileManager *fileManager = [NSFileManager defaultManager];
                     
                     NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                     
                     documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"screen_flash"];
                     
                     NSError *error;
                     NSArray *paths = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
                     
                     YunLog(@"paths = %@", paths);
                     
                     for (int i = 0; i < paths.count; i++) {
                         NSString *deleteFilePath = [documentsDirectoryPath stringByAppendingPathComponent:paths[i]];
                         
                         if ([fileManager removeItemAtPath:deleteFilePath error:&error]) {
                             YunLog(@"delete file success, path = %@", deleteFilePath);
                         } else {
                             YunLog(@"delete file failure, path = %@, error = %@", deleteFilePath, error);
                         }
                     }
                     
                     return;
                 }
                 
                 @try {
                     if (!timestamp) {
                         [self downloadScreenFlash:[screenFlash[0] objectForKey:@"url"] success:^{
                             [defaults setObject:[NSString stringWithFormat:@"%@", [screenFlash[0] objectForKey:@"timestamp"]]
                                          forKey:kScreenFlashTimestamp];
                             
                             [defaults synchronize];
                         } failure:^{
                             YunLog(@"save screen flash image error");
                         }];
                     } else {
                         if (![timestamp isEqualToString:[NSString stringWithFormat:@"%@", [screenFlash[0] objectForKey:@"timestamp"]]]) {
                             [self downloadScreenFlash:[screenFlash[0] objectForKey:@"url"] success:^{
                                 [defaults setObject:[NSString stringWithFormat:@"%@", [screenFlash[0] objectForKey:@"timestamp"]]
                                              forKey:kScreenFlashTimestamp];
                                 
                                 [defaults synchronize];
                             } failure:^{
                                 YunLog(@"save screen flash image error");
                             }];
                         } else {
                             YunLog(@"screen flash image already latest");
                         }
                     }
                 }
                 @catch (NSException *exception) {
                     YunLog(@"get screen flash exception = %@", exception);
                 }
                 @finally {
                     
                 }
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"request screen flash error = %@", error);
         }];
}

- (void)downloadScreenFlash:(NSString *)imageURL success:(void (^)(void))success failure:(void (^)(void))failure
{
    YunLog(@"imageURL = %@", imageURL);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"screen_flash"];
    
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:documentsDirectoryPath isDirectory:&isDir]) {
        NSError *error;
        if ([fileManager createDirectoryAtPath:documentsDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            YunLog(@"create screen flash images directory success");
        } else {
            YunLog(@"create screen flash images directory error = %@", error);
        }
    }
    
    NSString *pathComponent;
    
    if (kScreenHeight == 480) {
        pathComponent = [NSString stringWithFormat:@"%@_%@", k3_5InchScreenFlash, [imageURL toMD5]];
    } else {
        pathComponent = [NSString stringWithFormat:@"%@_%@", k4InchScreenFlash, [imageURL toMD5]];
    }
    
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:pathComponent];
    
    YunLog(@"filePath = %@",filePath);
    
    if ([fileManager fileExistsAtPath:filePath]) {
        YunLog(@"file exist at path = %@", filePath);
        
        return;
    }
    
    UIImage *image;
    
    NSURL *url = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data) {
        image = [UIImage imageWithData:data];
    } else {
        image = nil;
    }
    
    if (image != nil) {
        NSError *error;
        NSArray *paths = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
        
        YunLog(@"paths = %@", paths);
        
        for (int i = 0; i < paths.count; i++) {
            NSString *deleteFilePath = [documentsDirectoryPath stringByAppendingPathComponent:paths[i]];
            
            if ([fileManager removeItemAtPath:deleteFilePath error:&error]) {
                YunLog(@"delete file success, path = %@", deleteFilePath);
            } else {
                YunLog(@"delete file failure, path = %@, error = %@", deleteFilePath, error);
            }
        }
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath options:NSAtomicWrite error:nil];
        
        YunLog(@"save screen flash image filePath = %@", filePath);
        
        success();
    } else {
        failure();
    }
}

#pragma mark - UIAlertViewDelegate -

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    for (id so in alertView.subviews) {
        if ([so isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)so;
            label.font = [UIFont fontWithName:kFontBold size:kFontNormalSize];
        }
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 112) {
//        if (buttonIndex == 0) {
//            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
//
//            [self registerTermimal];
//        }
//    } else {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_trackViewUrl]];
//    }
//}


//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    if (scrollView == _scrollView) {
//        int page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / _channels.count) / scrollView.frame.size.width) + 1;
//        
//        if (page < 0) {
//            page = 0;
//        } else if (page > _channels.count - 1) {
//            page = (int)_channels.count - 1;
//        }
//        
//        YunLog(@"page = %d", page);
//        
//        //        [self changeChannel:(UIButton *)_tableHeaderView.subviews[page]];
//    }
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (scrollView == _scrollView) {
//        YunLog(@"%@", NSStringFromCGRect(scrollView.frame));
//        YunLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
//        
//        int page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / _channels.count) / scrollView.frame.size.width) + 1;
//        
//        if (page < 0) {
//            page = 0;
//        } else if (page > _channels.count - 1) {
//            page = (int)_channels.count - 1;
//        }
//        
//        YunLog(@"page = %d", page);
//        
//        //        [self changeChannel:(UIButton *)_tableHeaderView.subviews[page]];
//    }
//}

//- (void)getNextPageView
//{
//    UITableView *tableView = (UITableView *)_scrollView.subviews[_selectedChannelIndex];
//    
//    if (_lists.count >= 8 && ![[_defaultLists[_selectedChannelIndex] objectForKey:@"noMore"] isEqualToString:@"noMore"]) {
//        NSInteger rc = _refreshCount;
//        rc += 1;
//        
//        AppDelegate *appDelegate = kAppDelegate;
//        
//        NSDictionary *params = @{@"page"                    :   [NSString stringWithFormat:@"%ld", (long)rc],
//                                 @"limit"                   :   @"8",
//                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
//                                 @"channel_id"              :   [NSString stringWithFormat:@"%ld", (long)_selectedChannelIndex]};
//        
//        NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion3 requestURL:kShopListURL params:params];
//        
//        if (_selectedChannelIndex == ShopListChannelFavorite || _selectedChannelIndex == ShopListChannelOrder) {
//            listURL = [listURL stringByAppendingFormat:@"&user_session_key=%@", kNullToString(appDelegate.user.userSessionKey)];
//        }
//        
//        YunLog(@"shop refresh list url = %@", listURL);
//        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.requestSerializer.timeoutInterval = 30;
//        
//        [manager GET:listURL
//          parameters:nil
//             success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                 YunLog(@"shop refresh list responseObject = %@", responseObject);
//                 
//                 NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
//                 
//                 if ([code isEqualToString:kSuccessCode]) {
//                     NSArray *newLists = [[responseObject objectForKey:@"data"] objectForKey:@"lists"];
//                     
//                     if (!newLists) {
//                         [_defaultLists[_selectedChannelIndex] setObject:@"noMore" forKey:@"noMore"];
//                         
//                         tableView.contentInset = UIEdgeInsetsZero;
//                     } else if (newLists.count > 0) {
//                         _lists = [_lists arrayByAddingObjectsFromArray:newLists];
//                         
//                         [_defaultLists[_selectedChannelIndex] setObject:[NSArray arrayWithArray:_lists] forKey:@"content"];
//                         
//                         [tableView reloadData];
//                         
//                         _refreshCount += 1;
//                         
//                         if (newLists.count < 8) {
//                             [_defaultLists[_selectedChannelIndex] setObject:@"noMore" forKey:@"noMore"];
//                         } else {
//                             tableView.contentInset = UIEdgeInsetsZero;
//                         }
//                     }
//                 } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
//                     [Tool resetUser];
//                 } else {
//                     if (!_hud) {
//                         _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                         [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
//                     }
//                     tableView.contentInset = UIEdgeInsetsZero;
//                 }
//             }
//             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                 if (!_hud) {
//                     _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//                     [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
//                 }
//                 
//                 
//                 tableView.contentInset = UIEdgeInsetsZero;
//                 
//                 YunLog(@"shop refresh list error = %@", error);
//             }];
//    } else {
//        
//        tableView.contentInset = UIEdgeInsetsZero;
//    }
//}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *searchHistory = [defaults objectForKey:kSearchHistory];
    YunLog(@"searchHistory = %@", searchHistory);
    
    self.tabBarController.tabBar.hidden = YES;
    
    //    _tableView.hidden = YES;
//    _scrollView.hidden      = YES;
    _tableHeaderView.hidden = YES;
    _openQRCode.hidden      = YES;
    _searchView.hidden      = NO;
    _searchCancel.hidden    = NO;
    
    if (searchHistory.count > 0) {
        _searchTableView.hidden = NO;
        
        [_searchTableView reloadData];
    } else {
        _searchTableView.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    YunLog(@"textField = %@", textField.text);
    YunLog(@"_searchType = %@", _searchType);
    
    [textField resignFirstResponder];
    
    if ([textField.text isEqualToString:@""]) {
        if (!_hud) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"请输入搜索词" delay:2.0];
        }
        
        return NO;
    }
    
    [self pushToSearchVC:textField.text];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *searchHistory = [NSMutableArray arrayWithArray:[defaults objectForKey:kSearchHistory]];
    
    for (NSString *history in searchHistory) {
        if ([textField.text isEqualToString:history]) {
            [searchHistory removeObject:history];
            
            break;
        }
    }
    
    [searchHistory insertObject:textField.text atIndex:0];
    
    [defaults setObject:searchHistory forKey:kSearchHistory];
    
    [defaults synchronize];
    
    return YES;
}

#pragma mark - SearchTextFieldDelegate -

/**
 SearchTextField代理方法
 
 切换搜索类型时调用
 
 @param searchTextField 当前searchTextField
 */
- (void)searchTextFieldToggleType:(SearchTextField *)searchTextField
{
    UIButton *button = (UIButton *)searchTextField.leftView;
    
    if ([_searchType isEqualToString:kSearchTypeProduct]) {
        _searchType = kSearchTypeShop;
        
        UILabel *label = (UILabel *)[button viewWithTag:TitleLabel];
        label.text = @"商铺";
        
        UIImageView *imageView = (UIImageView *)[button viewWithTag:ArrowImageView];
        imageView.image = [UIImage imageNamed:@"search_up"];
        if (!_hud) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addSuccessString:@"搜索类型切换为\"商铺\"" delay:1.0];
        }
    } else {
        _searchType = kSearchTypeProduct;
        
        UILabel *label = (UILabel *)[button viewWithTag:TitleLabel];
        label.text = @"商品";
        
        UIImageView *imageView = (UIImageView *)[button viewWithTag:ArrowImageView];
        imageView.image = [UIImage imageNamed:@"search_down"];
        
        if (!_hud) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addSuccessString:@"搜索类型切换为\"商品\"" delay:1.0];
        }
    }
}

#pragma mark - UITabBarControllerDelegate -

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    if (self.tabBarClick) {
//        self.tabBarClick = NO;
//        AppDelegate *appDelegate = kAppDelegate;
//        
//        NSUInteger currentSelectedIndex = tabBarController.selectedIndex;
//        if (currentSelectedIndex == appDelegate.lastSelectedTabIndex && currentSelectedIndex == 0) {
//            //        [_defaultLists removeAllObjects];
//            //        _defaultLists = nil;
//            //
//            //        _selectedChannelIndex = ShopListChannelRecommendation;
//            //
//            //        [self changeChannel:(UIButton *)_tableHeaderView.subviews[_selectedChannelIndex]];
//            //        ShopListDataSource *dataSource = [ShopListDataSource singleton];
//            //        if (dataSource.waiting == NO
//            //            && dataSource.getBannerDone == NO
//            //            && dataSource.getRecommendProductDataDone ==NO
//            //            && dataSource.getShopStreetDataDone ==NO){
//            //        }
//            
//            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//            _hud.labelText = @"努力加载中....";
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [_hud hide:YES];
//                self.tabBarClick = YES;
//            });
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                ShopListDataSource *dataSource = [ShopListDataSource sharedDataSource];
//                
//                [dataSource reloadData];
//            });
//        } else {
//            appDelegate.lastSelectedTabIndex = currentSelectedIndex;
//        }
//    }
//    
//}

#pragma mark - UIGestureRecognizerDelegate -

/**
 点击搜索视图的空白处时调用
 
 可以返回首页
 
 @param gestureRecognizer 手势
 @param touch             手势的位置
 
 @return 判断是否返回首页
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    YunLog(@"gestureRecognizer = %@", gestureRecognizer);
    
    CGPoint touchPoint = [touch locationInView:_searchView];
    
    if (_searchTableView.isHidden) {
        return YES;
    } else {
        if (touchPoint.y < MIN(_searchTableView.contentSize.height, _searchTableView.frame.size.height) + 10) {
            return NO;
        } else {
            return YES;
        }
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchTableView) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        return [(NSArray *)[defaults objectForKey:kSearchHistory] count];
    } else {
        if (section == 0) {
            return _shopStreetArray.count;
        } else {
            return _recommendProductsArray.count / 2;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _searchTableView) {
        return @"历史记录";
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _searchTableView) {
        return 30;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView == _searchTableView) {
        return 40;
    } else {
        return 0.01;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    CGFloat alphaCommendViewH = 0;
    if (kIsiPhone) {
        alphaCommendViewH = kSpaceWidth * 4;
    } else {
        alphaCommendViewH = kSpaceWidth * 6;
    }
    
    if (tableView == _tableView) {
        if (indexPath.section == 0) {
            return 30 + (kScreenWidth - 20 - (4 * kSpace / 2)) / 3 + 40 + kSpaceWidth * 2;
        } else {
           return (kScreenWidth - kSpaceWidth * 3) / 2 + kSpaceWidth + alphaCommendViewH;
        }
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = kGrayColor;
        
        UILabel *shopStreetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 30)];
        shopStreetLabel.backgroundColor = [UIColor whiteColor];
        shopStreetLabel.text = self.shopNameArray[section];
        shopStreetLabel.textColor = kBlackColor;
        
        [backView addSubview:shopStreetLabel];
        
        return backView;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView == _searchTableView) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (kDeviceOSVersion < 7.0) {
            button.backgroundColor = kClearColor;
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        } else {
            button.backgroundColor = [UIColor orangeColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        [button setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(cleanSearchHistory) forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell.contentView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        }
    }
    
//    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
//    view.backgroundColor = [UIColor whiteColor];
//    
//    cell.backgroundView = view;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (tableView == _searchTableView) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = kNullToString([defaults objectForKey:kSearchHistory][indexPath.row]);
    } else {
        cell.backgroundColor = kGrayColor;
        cell.contentView.backgroundColor = kClearColor;
        
        if (indexPath.section == 0) {
            UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30 + (kScreenWidth - 20 - (4 * kSpace / 2)) / 3 + 30 + kSpaceWidth * 2)];
            backView.backgroundColor = COLOR(248, 248, 248, 1);
            
            [cell.contentView addSubview:backView];
            
            /// 获取数据，进行展示
            ShopStreetModel *shopStreetModel = _shopStreetArray[indexPath.row];
            YunLog(@"shopStreetModel = %@", shopStreetModel);

            NSArray *arrayTemp = shopStreetModel.products;

            _productStreetArray = [NSMutableArray array];

            // 获取每个店铺街下面三个产品的有关数据
            for (NSDictionary *productDictTemp in arrayTemp)
            {
                ShopStreetProductsModel *productsModel = [[ShopStreetProductsModel alloc] init];
                [productsModel setValuesForKeysWithDictionary:productDictTemp];

                [_productStreetArray addObject:productsModel];
            }
            
            // 头部背景
            UIView *backImage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 33)];
            backImage.backgroundColor = [UIColor whiteColor];
            
            [backView addSubview:backImage];
            
            /// 添加左边的小视图
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSpaceWidth, 33)];
            leftView.backgroundColor = self.leftViewArray[indexPath.row];

            [backView addSubview:leftView];

            /// 添加店铺图标
            CGFloat shopIconImageViewX = CGRectGetMaxX(leftView.frame) + kSpaceWidth;
            CGFloat shopIconImageViewW = 25;
            CGFloat shopIconImageViewH = 25;
            CGFloat shopIconImageViewY = (leftView.bounds.size.height - shopIconImageViewH) / 2;

            UIImageView *shopIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(shopIconImageViewX, shopIconImageViewY, shopIconImageViewW, shopIconImageViewH)];
            [shopIconImageView setImageWithURL:[NSURL URLWithString:shopStreetModel.logo] placeholderImage:[UIImage imageNamed:@"default_image"]];

            [backView addSubview:shopIconImageView];

            /// 添加店铺名
            UILabel *shopNameLabel = [[UILabel alloc] init];
            shopNameLabel.text = shopStreetModel.title;
            shopNameLabel.font = kSmallFont;
            shopNameLabel.textColor = COLOR(40, 40, 40, 1);

            CGFloat shopNameLabelW = [shopNameLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 33)
                                                                          options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                       attributes:@{NSFontAttributeName:shopNameLabel.font}
                                                                          context:nil].size.width;

            CGFloat shopNameLabelX = CGRectGetMaxX(shopIconImageView.frame) + 10;
            CGFloat shopNameLabelH = leftView.bounds.size.height;

            shopNameLabel.frame = CGRectMake(shopNameLabelX, 0, shopNameLabelW, shopNameLabelH);

            [backView addSubview:shopNameLabel];

            /// 添加箭头指示
            CGFloat arrowheadImageViewW = kSpaceWidth;
            CGFloat arrowheadImageViewH = kSpaceWidth * 2;
            CGFloat arrowheadImageViewX = kScreenWidth - 20 - arrowheadImageViewW - (kSpace / 2);
            CGFloat arrowheadImageViewY = (leftView.bounds.size.height - arrowheadImageViewH) / 2;

            UIImageView *arrowheadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arrowheadImageViewX, arrowheadImageViewY, arrowheadImageViewW, arrowheadImageViewH)];
            arrowheadImageView.image = [UIImage imageNamed:@"arrowhead"];

            [backView addSubview:arrowheadImageView];

            /// 添加按钮，跳转到指定的店铺页面
            EnterButton *enterShopBtn = [[EnterButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 10, CGRectGetMaxY(leftView.frame))];
            enterShopBtn.tag = indexPath.row;
            [enterShopBtn addTarget:self action:@selector(enterShopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            enterShopBtn.backgroundColor = kClearColor;

            [backView addSubview:enterShopBtn];

            /// 添加下面的一条线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftView.frame), kScreenWidth, 1)];
            lineView.backgroundColor = COLOR(222, 222, 222, 1);

            [backView addSubview:lineView];

            /// 添加示例商品展示图
            CGFloat shopShowViewY = CGRectGetMaxY(lineView.frame) + kSpace;
            CGFloat shopShowViewW = (kScreenWidth - 4 * kSpace) / 3;
            CGFloat shopShowViewH = shopShowViewW;

            for (int j = 0; j < _productStreetArray.count; j++)
            {
                ShopStreetProductsModel *pModel = _productStreetArray[j];

                YunLog(@"pModel = %@", pModel);

                CGFloat shopShowViewX = kSpace + (shopShowViewW + kSpace) * j;
                UIView *shopShowView = [[UIView alloc] initWithFrame:CGRectMake(shopShowViewX, shopShowViewY, shopShowViewW, shopShowViewH)];

                [backView addSubview:shopShowView];

                /// 添加后面的商品图片
                UIImageView *productImageView = [[UIImageView alloc] initWithFrame:shopShowView.bounds];

                __weak typeof(productImageView) weakProductImageView = productImageView;
                weakProductImageView.contentMode = UIViewContentModeCenter;

                if (pModel.image_url == nil) {
                    [weakProductImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pModel.smal_image_url]]
                                                placeholderImage:[UIImage imageNamed:@"default_image"]
                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                             weakProductImageView.contentMode = UIViewContentModeScaleAspectFit;
                                                             weakProductImageView.image = image;
                                                         }
                                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

                                                         }];
                } else {
                    [weakProductImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pModel.image_url]]
                                                placeholderImage:[UIImage imageNamed:@"default_image"]
                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                             weakProductImageView.contentMode = UIViewContentModeScaleAspectFit;
                                                             weakProductImageView.image = image;
                                                         }
                                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                             [weakProductImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pModel.smal_image_url]]
                                                                                         placeholderImage:[UIImage imageNamed:@"default_image"]
                                                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                                      weakProductImageView.contentMode = UIViewContentModeScaleAspectFit;
                                                                                                      weakProductImageView.image = image;
                                                                                                  }
                                                                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                  }];
                                                         }];
                }

                [shopShowView addSubview:productImageView];
                
                /// 添加透明度展示商品名称UIView
                CGFloat alphaShopViewH = 0;
                if (kIsiPhone) {
                    alphaShopViewH = kSpaceWidth * 2;
                } else {
                    alphaShopViewH = kSpaceWidth * 4;
                }
                
                UIView *alphaShopView = [[UIView alloc] initWithFrame:CGRectMake(shopShowViewX, shopShowViewY + shopShowViewH, shopShowViewW, alphaShopViewH)];
                alphaShopView.backgroundColor = [UIColor whiteColor];
                
                [backView addSubview:alphaShopView];
                
                /// 添加商品名称UILabel
                UILabel *shopsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth / 2, 0, shopShowViewW - kSpaceWidth, alphaShopView.bounds.size.height)];
                
                // shopsNameLabel.text = productDictTemp[@"title"];
                shopsNameLabel.text = pModel.title;
                shopsNameLabel.font = [UIFont systemFontOfSize:kFontSmallSize];
                shopsNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                shopsNameLabel.textColor = kGrayFontColor;
                
                [alphaShopView addSubview:shopsNameLabel];
                
                /// 添加进入按钮product
                
                EnterButton *enterProductBtn = [[EnterButton alloc] initWithFrame:CGRectMake(0, 0, shopShowView.bounds.size.width, shopShowView.bounds.size.height + kSpaceWidth * 2)];
                enterProductBtn.productCode = pModel.code;
                enterProductBtn.shopCode = shopStreetModel.action_value;
                
                [enterProductBtn addTarget:self action:@selector(enterProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                enterProductBtn.backgroundColor = kClearColor;
                
                [shopShowView addSubview:enterProductBtn];
            }
            
            [self.productStreetArray removeAllObjects];
            self.productStreetArray = nil;
        } else {
            
            cell.contentView.backgroundColor = COLOR(248, 248, 248, 1);
            
            /// 循环创建下面两个商品展示视图
            for (int i = 0; i < 2; i++)
            {
                // 获取对应的楼层商品展示数据
                NSDictionary *productDict = _recommendProductsArray[indexPath.row * 2 + i];

                /// 添加推荐商品展示窗口
                CGFloat commendShopViewW = (kScreenWidth - (3 * kSpaceWidth)) / 2;
                CGFloat commendShopViewH = commendShopViewW;

                CGFloat commendShopViewX = kSpaceWidth + (commendShopViewW + kSpaceWidth) * i;
                CGFloat commendShopViewY = 0;

                UIView *commendShopsView = [[UIView alloc] initWithFrame:CGRectMake(commendShopViewX, commendShopViewY, commendShopViewW, commendShopViewH)];
                commendShopsView.backgroundColor = COLOR(255, 255, 255, 1);

                [cell.contentView addSubview:commendShopsView];

                // 添加点击时间处理的按钮
                EnterButton *enterActiveBtn = [[EnterButton alloc] initWithFrame:commendShopsView.bounds];
                [enterActiveBtn addTarget:self action:@selector(enterRecommendProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                enterActiveBtn.productCode = [productDict safeObjectForKey:@"code"];
                enterActiveBtn.shopCode = [productDict safeObjectForKey:@"shop_code"];
                enterActiveBtn.backgroundColor = kClearColor;
                __weak typeof(enterActiveBtn) _enterActiveBtn = enterActiveBtn;

                [enterActiveBtn setBackgroundImageForState:UIControlStateNormal withURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[productDict safeObjectForKey:@"large_icon_200_200"]]] placeholderImage:[UIImage imageNamed:@"default_image"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                    [_enterActiveBtn setBackgroundImage:image forState:UIControlStateNormal];
                } failure:^(NSError * _Nonnull error) {
                    [_enterActiveBtn setBackgroundImage:[UIImage imageNamed:@"default_image"] forState:UIControlStateNormal];
                }];

                [commendShopsView addSubview:enterActiveBtn];
//
                // 判断是否需要添加活动商品的图标
                UIImageView *activeShopsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kActiveShopsImageWH, kActiveShopsImageWH)];
                activeShopsImageView.image = [UIImage imageNamed:@"active"];

                [commendShopsView addSubview:activeShopsImageView];

                // 添加透明UIView
                CGFloat alphaCommendViewH = 0;
                if (kIsiPhone) {
                    alphaCommendViewH = kSpaceWidth * 4;
                } else { 
                    alphaCommendViewH = kSpaceWidth * 6;
                }

                UIView *alphaCommendView = [[UIView alloc] initWithFrame:CGRectMake(0, commendShopViewH, commendShopViewW, alphaCommendViewH)];

                [commendShopsView addSubview:alphaCommendView];

                // 添加一张背景图片实现模糊效果
                UIImageView *backGroundImageView = [[UIImageView alloc] initWithFrame:alphaCommendView.bounds];
                backGroundImageView.backgroundColor = [UIColor whiteColor];
                [alphaCommendView addSubview:backGroundImageView];

                // 添加推荐名称
                UILabel *commendShopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth, 0, commendShopViewW - 2 * kSpaceWidth, kSpaceWidth * 2)];
                commendShopNameLabel.textColor = kGrayFontColor;
                commendShopNameLabel.text = [productDict safeObjectForKey:@"name"];
                commendShopNameLabel.font = [UIFont boldSystemFontOfSize:kFontSmallSize];

                [alphaCommendView addSubview:commendShopNameLabel];
                
                // 添加商品售价
                UILabel *shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceWidth, CGRectGetMaxY(commendShopNameLabel.frame) - kSpace / 5, commendShopViewW, kSpaceWidth * 2)];
                shopPriceLabel.text = [NSString stringWithFormat:@"￥%@", [productDict safeObjectForKey:@"price"]];
                //            shopPriceLabel.text = @"￥9.90";
                shopPriceLabel.textColor = COLOR(224, 70, 60, 1);
                shopPriceLabel.font = [UIFont systemFontOfSize:kFontSmallSize];
                
                [alphaCommendView addSubview:shopPriceLabel];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _searchTableView) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [self pushToSearchVC:[defaults objectForKey:kSearchHistory][indexPath.row]];
    } else {
        
    }
}


#pragma mark - ShopListDataLoadEvent -

/**
 *  首页数据加载成功的异步NSNotification通知的处理方法
 *
 *  @param sender 对应的NSNotification通知对象
 */
//- (void)dataLoadDone:(NSNotification*)sender
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_hud hide:YES];
//        
//        [self createUI];
//    });
//}

/**
 *  首页数据加载失败的异步NSNotification通知的处理方法,已定义的错误消息将在NSNotification的userInfo属性中以‘messgae’为键保存,否则为nil。
 *
 *  @param sender 对应的NSNotification通知对象
 */
- (void)dataLoadError:(NSNotification*)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_hud hide:YES];
        
        //获取错误信息
        NSString *message = [[sender userInfo] objectForKey:@"messgae"];
        
        if (self.navigationController.view) {
            if (!_hud) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:(message == nil ? @"数据加载错误" : message) delay:2.0];
            }
        }
    });
}

@end
