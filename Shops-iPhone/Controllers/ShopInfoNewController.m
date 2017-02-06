//
//  ShopInfoNewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/9/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ShopInfoNewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"
#import "YUNSegmentView.h"
#import "PopGestureRecognizerController.h"

// Views
#import "UILabelWithLine.h"
#import "KLCPopup.h"
#import "YunShareView.h"
#import "CartManager.h"
#import "TLCollectionWaterFallCell.h"
#import "TLCollectionWaterFallFlow.h"

// Controllers
#import "ProductDetailViewController.h"
#import "WebViewController.h"
#import "LoginViewController.h"
#import "PayCenterForUserViewController.h"
#import "CartNewViewController.h"
#import "AboutShopInfoViewController.h"

// Categories
#import "UIView+AddBadge.h"
#import "UIScrollView+IBFloatingHeader.h"

// Libraries
#import "WXApi.h"
#import "NSObject+NullToString.h"

#import "DKTabPageViewController.h"

#define kWrapperTopTag 1001
#define kHeaderSegmentTag 1011

static CGFloat const kMargin = 10.f;
static NSString * const reuseIdentifier = @"TLCollectionWaterFallCell";

typedef NS_ENUM(NSInteger, AlertTag) {
    TerminalAlert = 0,
    WeiXinShareAlert = 1,
};

@interface ShopInfoNewController () <YunShareViewDelegate, YUNSegmentViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray                   *products;
@property (nonatomic, strong) NSDictionary              *shop;
@property (nonatomic, strong) NSDictionary              *product_promotions;
@property (nonatomic, copy  ) NSString                  *favoriteID;
@property (nonatomic, strong) UIBarButtonItem           *favoriteItem;
@property (nonatomic, strong) UIButton                  *bottomCart;
@property (nonatomic, strong) UIView                    *bottomView;
@property (nonatomic, assign) NSInteger                 countBadge;
@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) TLCollectionWaterFallFlow *layout;
@property (nonatomic, strong) NSMutableArray            *dataList;

@property (nonatomic, strong) MBProgressHUD             *hud;

@property (nonatomic, assign) int                       pageNonce;

@property (nonatomic, assign) BOOL                      isLoading;
@property (nonatomic, assign) BOOL                      priceAsc;
@property (nonatomic, assign) NSInteger                 selectButtonIndex;
@property (nonatomic, assign) NSInteger                 subIndexOfPriceOrder;


@end

@implementation ShopInfoNewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //        self.headerHeight = 64;
    }
    return self;
}

#pragma mark init methods
//- (UICollectionView *)collectionView {
//    if (!_collectionView) {
//        _collectionView = [[UICollectionView alloc] initWithFrame:kScreenBounds
//                                             collectionViewLayout:self.layout];
//        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.dataSource = self;
//        _collectionView.delegate = self;
//        [_collectionView registerClass:[TLCollectionWaterFallCell class] forCellWithReuseIdentifier:reuseIdentifier];
//    }
//    return _collectionView;
//}

- (TLCollectionWaterFallFlow *)layout {
    if (!_layout) {
        _layout = [[TLCollectionWaterFallFlow alloc] init];
        _layout.minimumInteritemSpacing = kMargin;
        _layout.minimumLineSpacing = kMargin;
        _layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _layout;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];
    
    UIView *bottomView = [_bottomCart superview];
    
    [_bottomCart removeFromSuperview];
    
    _bottomCart = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 32.5, 30)];
    [_bottomCart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
    [_bottomCart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:_bottomCart];
    
    NSInteger cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
    if (cartCount <= 0) {
        [_bottomCart removeBadge];
    } else {
        [_bottomCart removeBadge];
        [_bottomCart addBadge:[NSString stringWithFormat:@"%ld", cartCount]];
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin) {
        if ([_shop objectForKey:@"id"]) {
            [self checkFavorite];
        }
    }
    
    //    [TalkingData trackPageBegin:@"进入商铺详情页面"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [TalkingData trackPageEnd:@"离开商铺详情页面"];
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:YES];
    
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageNonce = 1;
    _selectButtonIndex = 0;
    
    self.view.backgroundColor = kBackgroundColor;
    
    _product_promotions = [NSDictionary dictionary];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    [self createCollectionView];
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 1.5*kMargin)/2.f;
    for (NSUInteger idx = 0; idx < 100; idx ++) {
        CGFloat height = 150;
        NSValue *value = [NSValue valueWithCGSize:CGSizeMake(width, height)];
        [_dataList addObject:value];
    }
    
    [self.view addSubview:self.collectionView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
    
    if (kDeviceOSVersion < 7.0) {
        _bottomView.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
    }
    
    _bottomView.backgroundColor = COLOR(245, 245, 245, 1);
    _bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
    _bottomView.layer.borderWidth = 1;
    _bottomView.clipsToBounds = NO;
    
    [self.view addSubview:_bottomView];
    
    _bottomCart = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 32.5, 30)];
    [_bottomCart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
    [_bottomCart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomView addSubview:_bottomCart];
    
    UIButton *buy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 8, 100, 32)];
    buy.tag = 200;
    buy.layer.cornerRadius = 3;
    buy.layer.masksToBounds = YES;
    buy.backgroundColor = [UIColor whiteColor];
    buy.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
    [buy setTitle:@"联系客服" forState:UIControlStateNormal];
    [buy setTitleColor:kOrangeColor forState:UIControlStateNormal];
    [buy addTarget:self action:@selector(contactServiceClick) forControlEvents:UIControlEventTouchUpInside];
    
    buy.layer.borderWidth = 1;
    buy.layer.borderColor = kOrangeColor.CGColor;
    
    [_bottomView addSubview:buy];
    
    UIButton *goToBuy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
    goToBuy.layer.cornerRadius = 6;
    goToBuy.layer.masksToBounds = YES;
    goToBuy.titleLabel.font = kNormalFont;
    goToBuy.backgroundColor = [UIColor orangeColor];
    [goToBuy setTitle:@"联系商家" forState:UIControlStateNormal];
    [goToBuy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goToBuy addTarget:self action:@selector(goToAboutShop) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomView addSubview:goToBuy];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"code"                    :   kNullToString(_code),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :    kNullToArray(appDelegate.user.userSessionKey)};
    
    NSString *shopURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kShopInfoNewURL,_code] params:params];
    
    YunLog(@"shop info url = %@", shopURL);
    
    [manager GET:shopURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"shop info responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _shop = [[responseObject objectForKey:@"data"] objectForKey:@"shop"];
                 
                 NSString *name = kNullToString([_shop objectForKey:@"name"]);
                 UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
                 
                 naviTitle.font = [UIFont fontWithName:kFontBold size:kFontNormalSize];
                 naviTitle.backgroundColor = kClearColor;
                 naviTitle.textColor = kNaviTitleColor;
                 naviTitle.text = name ? name : @"商品列表";
                 naviTitle.lineBreakMode = NSLineBreakByWordWrapping;
                 
                 // left bar button item
                 UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:naviTitle];
                 
                 NSMutableArray *items = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
                 [items addObject:titleItem];
                 
                 [self.navigationItem setLeftBarButtonItems:items];
                 
                 // right bar button item
                 UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 30, 32)];
                 [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
                 [share addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
                 
                 UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:share];
                 shareItem.style = UIBarButtonItemStylePlain;
                 
                 NSMutableArray *rightItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
                 [rightItems addObject:shareItem];
                 
                 self.navigationItem.rightBarButtonItems = rightItems;
                 
                 // 设置头部店铺的图片
                 UIImageView *top = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120 * kScreenWidth / 320)];
                 top.backgroundColor = kClearColor;
                 top.contentMode = UIViewContentModeCenter;
                 
                 CALayer *lineLayer = [CALayer layer];
                 lineLayer.frame = CGRectMake(0, top.frame.size.height - 1, kScreenWidth, 1);
                 lineLayer.backgroundColor = COLOR(232, 232, 232, 1).CGColor;
                 
                 [top.layer addSublayer:lineLayer];
                 
                 NSString *imageURL = kNullToString([[[_shop objectForKey:@"mobile_banners"] firstObject] objectForKey:@"image_url"]);
                 
                 NSString *pcImageURL = kNullToString([[[_shop objectForKey:@"pc_banners"] firstObject] objectForKey:@"image_url"]);
                 
                 __weak UIImageView *_top = top;
                 __weak typeof(self) weakSelf = self;
                 
                 UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 120 * kScreenWidth / 320)];
                 [wrapper addSubview:_top];
                 _top.contentMode = UIViewContentModeCenter;
                 
                 [_top setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
                             placeholderImage:[UIImage imageNamed:@"default_image"]
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          _top.image = image;
                                          _top.contentMode = UIViewContentModeScaleAspectFit;
                                          
                                          [weakSelf.view addSubview:wrapper];
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          [_top setImageWithURL:[NSURL URLWithString:pcImageURL] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                          _top.contentMode = UIViewContentModeScaleAspectFit;
                                          
                                          [weakSelf.view addSubview:wrapper];
                                      }];
                 
                 // 添加头部选择控件
                 [UIView animateWithDuration:0.4 animations:^{
                     self.collectionView.frame = CGRectMake(0, 64 + 120 * kScreenWidth / 320, kScreenWidth, kScreenHeight - 120 * kScreenWidth / 320 - 48 - 64);
                 } completion:^(BOOL finished) {
                     // 设置头部图片下面的控件
                     UIView *wrapperTop = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 120 * kScreenWidth / 320, kScreenWidth, 64)];
                     wrapperTop.backgroundColor = kWhiteColor;
                     wrapperTop.tag = kWrapperTopTag;
                     YUNSegmentView *header = [[YUNSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64) titles:@[@"店铺首页", @"新品上架", @"销量排序", @"价格排序"] icons:@[@"zhuye",@"shangxin",@"xiaoliang",@"jiage"]];
                     header.tag = kHeaderSegmentTag;
                     header.backgroundColor = [UIColor whiteColor];
                     header.delegate = self;
                     
                     [header highlightButtonAtIndex:0];
                     
                     [wrapperTop addSubview:header];
                     
                     [self.view addSubview:wrapperTop];
                 }];
                 
                 // 检测店铺是否收藏
                 [self checkFavorite];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"shop info error = %@", error);
         }];
    
    NSDictionary *listParams = @{@"page"                     :   @"1",
                                 @"per"                      :   @"10",
                                 @"terminal_session_key"     :   kNullToString(appDelegate.terminalSessionKey)
                                 };
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[kProductListURL stringByReplacingOccurrencesOfString:@":code" withString:kNullToString(_code)] params:listParams];
    
    YunLog(@"product list url = %@", listURL);
    
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product list responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _products = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                 
                 [self.collectionView reloadData];
                 
                 [_hud hide:YES];
             } else {
                 YunLog(@"%@",kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"get product list error = %@", error);
             
             [_hud addErrorString:@"获取商品数据异常" delay:2.0];
         }
     ];
    [self createMJRefresh];
}

#pragma mark - 创建上拉下拉刷新 -
/**
 *  创建上拉下拉刷新对象
 */
- (void)createMJRefresh
{
    //[self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //UITableViewController *tableViewController = [self.tabController selectedViewController];
}

/**
 下拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) {
        [_collectionView footerEndRefreshing];
        
        return;
    }
    
    _pageNonce++;
    
    [self getNextPageViewIsPullDown:NO withPage:_pageNonce isFrist:NO];
}

/**
 获取数据源
 
 @param pullDown 是否是下拉
 @param page     当前页数
 @param frist    是否是第一次调用该方法
 */
- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page isFrist:(BOOL)frist
{
    YunLog(@"发送请求～");
    
    _isLoading = YES;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!_hud)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        
    }
    
    if(pullDown == NO)
    {
        NSMutableDictionary *listParams = [NSMutableDictionary dictionaryWithDictionary:
                                           @{@"page"                     :   [NSString stringWithFormat:@"%ld",(long)page],
                                             @"per"                      :   @"10",
                                             @"terminal_session_key"     :   kNullToString(appDelegate.terminalSessionKey)}];
        switch (self.selectButtonIndex) {
            case 1:
                //新品上街
                break;
            case 2:
                //销量排行
                [listParams setObject:@"desc" forKey:@"dir"];
                [listParams setObject:@"sales_quantity" forKey:@"order"];
                break;
            case 3:
                if (self.priceAsc == NO) {
                    [listParams setObject:@"asc" forKey:@"dir"];
                    [listParams setObject:@"price" forKey:@"order"];
                }
                else {
                    [listParams setObject:@"desc" forKey:@"dir"];
                    [listParams setObject:@"price" forKey:@"order"];
                }
                
                break;
            default:
                break;
        }
        
        NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[kProductListURL stringByReplacingOccurrencesOfString:@":code" withString:kNullToString(_code)] params:listParams];
        
        YunLog(@"next listURL = %@", listURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:listURL
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"product list responseObject = %@", responseObject);
                 _isLoading = NO;
                 [_collectionView footerEndRefreshing];
                 
                 if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                     NSMutableArray *temp = [NSMutableArray arrayWithArray:_products];
                     
                     NSArray *newProducts = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                     if (newProducts.count > 0)
                     {
                         [temp addObjectsFromArray:newProducts];
                         self.products = temp;
                         [_collectionView reloadData];
                         _collectionView.footerHidden = NO;
                         [_hud hide:YES];
                         
                     }
                     else
                     {
                         _collectionView.footerHidden = YES;
                     }
                     
                 } else {
                     _collectionView.footerHidden = NO;
                     
                     YunLog(@"%@",kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
                     [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                    delay:2.0];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 YunLog(@"get product list error = %@", error);
                 _collectionView.footerHidden = NO;
                 
                 [_collectionView footerEndRefreshing];
                 
                 [_hud addErrorString:@"获取商品数据异常" delay:2.0];
             }
         ];
        
    }
    else
    {
        _collectionView.footerHidden = YES;
    }
}

#pragma mark - CollectionView - Gesture -

- (void)createCollectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:kScreenBounds
                                             collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[TLCollectionWaterFallCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    
    //加左划手势
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesturLeft)];
    // 设置滑动手势的方向
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [_collectionView addGestureRecognizer:swipeLeft];
    
    //加右划手势
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesturRight)];
    // 设置滑动手势的方向
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [_collectionView addGestureRecognizer:swipeRight];
}

- (void)swipeGesturLeft
{
    _selectButtonIndex++;
    
    if (_selectButtonIndex > 3) {
        _selectButtonIndex--;
        return;
    } else {
        YUNSegmentView *header = (YUNSegmentView *)[self.view viewWithTag:kHeaderSegmentTag];
        [header highlightButtonAtIndex:_selectButtonIndex];
        [self swipeToControllerIndex:_selectButtonIndex];
    }
}

- (void)swipeGesturRight
{
    _selectButtonIndex--;
    if (_selectButtonIndex < 0) {
        _selectButtonIndex++;
        return;
    } else {
        
        YUNSegmentView *header = (YUNSegmentView *)[self.view viewWithTag:kHeaderSegmentTag];
        [header highlightButtonAtIndex:_selectButtonIndex];
        
        [self swipeToControllerIndex:_selectButtonIndex];
    }
}

- (void)swipeToControllerIndex:(NSInteger)index
{
    if(index == self.selectButtonIndex && index == 3){
        if (self.priceAsc) {
            [self orderProductFromLowToHigh:nil];
        }
        else{
            [self orderProductFromHighToLow:nil];
        }
        return;
    }
    
    self.pageNonce = 1;
    
    self.selectButtonIndex = index;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    AppDelegate *appDelegate = kAppDelegate;
    NSMutableDictionary *listParams = [NSMutableDictionary dictionaryWithDictionary:@{@"code"                     :   kNullToString(_code),
                                                                                      @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                                                                                      @"per" : @"20"}];
    
    switch (index) {
            
        case 1:
            [listParams setObject:@"put_on_shelves_time" forKey:@"order"];
            [listParams setObject:@"desc" forKey:@"dir"];
            break;
        case 2:
            [listParams setObject:@"sales_quantity" forKey:@"order"];
            [listParams setObject:@"desc" forKey:@"dir"];
            break;
        default:
            break;
    }
    
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[kProductListURL stringByReplacingOccurrencesOfString:@":code" withString:kNullToString(_code)] params:listParams];
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product list responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _products = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                 
                 [_collectionView reloadData];
                 
                 [_hud hide:YES];
             } else {
                 YunLog(@"%@",kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"get product list error = %@", error);
             
             [_hud addErrorString:@"获取商品数据异常" delay:2.0];
         }
     ];
}

#pragma mark - FavoriteFunction -

- (void)checkFavorite
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"category"                 :   kNullToString(@"Shop")};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1
                                           requestURL:[NSString stringWithFormat:kHas_ExistedURL,_code]
                                               params:params];
    
    YunLog(@"favoriteURL = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:favoriteURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"favorite responseObject = %@", responseObject);
             
             UIButton *favorite = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 30, 32)];
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
             {
                 _favoriteID = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_id"];
                 
                 [favorite setImage:[UIImage imageNamed:@"top_already_favorite"] forState:UIControlStateNormal];
                 
                 [favorite removeTarget:self action:@selector(addFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [favorite removeTarget:self action:@selector(deleteFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [favorite addTarget:self action:@selector(deleteFavorite:)
                    forControlEvents:UIControlEventTouchUpInside];
             } else {
                 [favorite setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
                 
                 [favorite removeTarget:self action:@selector(addFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [favorite removeTarget:self action:@selector(deleteFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [favorite addTarget:self action:@selector(addFavorite:)
                    forControlEvents:UIControlEventTouchUpInside];
             }
             
             UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithCustomView:favorite];
             newItem.style = UIBarButtonItemStylePlain;
             
             NSMutableArray *items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
             [items removeObject:_favoriteItem];
             [items addObject:newItem];
             
             _favoriteItem = newItem;
             
             self.navigationItem.rightBarButtonItems = items;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"favorite error = %@", error);
         }];
}

- (void)addFavorite:(UIButton *)sender
{
    //    sender.enabled = NO;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        sender.enabled = YES;
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isReturnView = YES;
        
        [self.navigationController pushViewController:loginVC animated:YES];
        //        UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        //
        //        [self.navigationController presentViewController:loginNC animated:YES completion:nil];
        
        return;
    }
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [_hud show:YES];
    }
    
    _hud.labelText = @"努力收藏中...";
    
    NSDictionary *params = @{@"code"                    :   kNullToString(_code),
                             @"category"                :   kNullToString(@"Shop"),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAddFavoriteURL params:params];
    
    YunLog(@"add favorite 66 url = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:favoriteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"favData = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            //            NSArray *favorites = [[responseObject objectForKey:@"data"] objectForKey:@"favorites"];
            //            for (NSDictionary *favDict in favorites) {
            //                if ([favDict[@"code"] isEqualToString:kNullToString(_productCode)]) {
            _hud.detailsLabelText = @"收藏成功";
            [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_shop objectForKey:@"name"]]
                             delay:1.5];
            
            [sender setImage:nil forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"top_already_favorite"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [sender removeTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            _favoriteID = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_id"];
            
            //                    return;
            //                } else {
            //                     [_hud addErrorString:@"收藏失败" delay:1.5];
            //                }
            //            }
        } else {
            [_hud addErrorString:@"收藏失败" delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"fav error = %@", error);
        
        [_hud addErrorString:@"网络异常，添加收藏失败" delay:1.5];
    }];
}

- (void)deleteFavorite:(UIButton *)sender
{
    //    sender.enabled = NO;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [_hud show:YES];
    }
    
    _hud.labelText = @"删除收藏中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"ids"                     :   kNullToString(_favoriteID),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1
                                           requestURL:kDeleteFavoriteURL
                                               params:params];
    
    YunLog(@"delete favorite url = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager DELETE:favoriteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"res delete fav = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _hud.detailsLabelText = @"取消收藏成功";
            [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_shop objectForKey:@"name"]]
                             delay:1.5];
            
            [sender setImage:nil forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [sender removeTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [_hud addErrorString:@"取消收藏失败" delay:1.5];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"fav error = %@", error);
        
        [_hud addErrorString:@"网络异常，取消收藏失败" delay:1.5];
    }];
}


#pragma mark - Private Functions -

- (void)goToCart
{
//    self.tabBarController.selectedIndex = 1;
//    
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    self.tabBarController.tabBar.hidden = YES;
//    
//    appDelegate.lastSelectedTabIndex = 1;
    CartNewViewController *cart = [[CartNewViewController alloc] init];
    
    [self.navigationController pushViewController:cart animated:YES];
}

- (void)goToPay
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin) {
        NSData *dataProducts = [[NSUserDefaults standardUserDefaults] objectForKey:@"paySelectProducts"];
        
        NSMutableArray *paySelectProducts = [NSKeyedUnarchiver unarchiveObjectWithData:dataProducts];
        
        NSData *dataShops = [[NSUserDefaults standardUserDefaults] objectForKey:@"paySelectShops"];
        
        NSMutableArray *paySelectShops = [NSKeyedUnarchiver unarchiveObjectWithData:dataShops];
        
        if (paySelectProducts.count > 0) {
            PayCenterForUserViewController *pay = [[PayCenterForUserViewController alloc] init];
            pay.allSelectProducts = paySelectProducts;
            pay.paySelectShops = paySelectShops;
            
            UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
            
            [self.navigationController presentViewController:payNC animated:YES completion:nil];
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"没有选中的商品哟~" delay:2.0];
        }
    } else {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isReturnView = YES;
        loginVC.isBuyEnter = YES;
        
        //        [self.navigationController pushViewController:loginVC animated:YES];
        
        UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        
        [self.navigationController presentViewController:loginNC animated:YES completion:nil];
    }
}


- (void)goToAboutShop
{
    AboutShopInfoViewController *webView = [[AboutShopInfoViewController alloc] init];
    
    webView.shopCode = _code;
    
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TLCollectionWaterFallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                       reuseIdentifier forIndexPath:indexPath];
    NSDictionary *productDict = _products[indexPath.row];
    
    [cell config:productDict];
    
    return  cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize cellSize = CGSizeMake((kScreenWidth - 3 * 10) / 2, (kScreenWidth - 3 * 10) / 2 + 40);
    
    return  cellSize;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YunLog(@"点击了collection");
    
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = kNullToString([_products[indexPath.row] objectForKey:@"code"]);
    detail.shopCode = _code;
    
    YunLog(@"detail.shopCode = %@", detail.shopCode);
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
        && ( scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 3) > 0) {
        // TODO 等待处理
        [self footerRereshing];
    }
    
    @synchronized(scrollView) {
        //        [self.view bringSubviewToFront:self.bottomView];
        
        UIView *wrapperTop = (UIView *)[self.view viewWithTag:kWrapperTopTag];
        
        [self.view bringSubviewToFront:_collectionView];
        [self.view bringSubviewToFront:wrapperTop];
        
        //
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        YunLog(@"tanslation =====  %@", NSStringFromCGPoint(translation));
        YunLog(@"_collectionView.consetY----------- %f", _collectionView.contentOffset.y);
        //        static BOOL needAnimation;
        
        if (_collectionView.frame.origin.y <= (kScreenWidth * 120 / 320 + 64)) {
            if ([scrollView contentOffset].y > 0 && translation.y < 0) {
                YunLog(@"----------------111----%f", [scrollView contentOffset].y);
                YunLog(@"----------------222----%f", translation.y);
                [UIView animateWithDuration:0.4 animations:^{
                    wrapperTop.frame = CGRectMake(0, 64, kScreenWidth, 64);
                    
                    self.collectionView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 48);
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
        
        if (wrapperTop.frame.origin.y == 64 && translation.y > 0 && [scrollView contentOffset].y < 64) {
            [UIView animateWithDuration:0.4 animations:^{
                wrapperTop.frame = CGRectMake(0, (64 + kScreenWidth * 120 / 320), kScreenWidth, 64);
                
                self.collectionView.frame = CGRectMake(0, (64 + kScreenWidth * 120 / 320), kScreenWidth, kScreenHeight - 64 - 48 - kScreenWidth * 120 / 320);
                [_collectionView setContentOffset:CGPointZero];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint point = scrollView.contentOffset;
//
//    YunLog(@"point.y = %f,crollView.contentSize.height = %f,scrollView.bounds.size.height = %f,self.view.frame.size.height / 3 = %f,    %f",point.y,scrollView.contentSize.height,scrollView.bounds.size.height,self.view.frame.size.height / 4,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
//
//    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
////        [self footerRereshing];
//    }
//}

#pragma mark - ShareFunction -
- (void)openShare
{
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_weixin" , @"title" : @"微信"},
                                                                     
                                                                     @{@"icon" : @"share_weixin_friend" , @"title" : @"朋友圈"},
                                                                     
                                                                     @{@"icon" : @"share_weibo" , @"title" : @"微博"}]
                                                         bottomBar:@[]
                               ];
    
    shareView.delegate = self;
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
    
    //    NSDictionary *params= @{@"uuid"         :   [Tool getUniqueDeviceIdentifier],
    //                            @"shop_name"    :   kNullToString([_shop objectForKey:@"name"]),
    //                            @"shop_code"    :   kNullToString([_shop objectForKey:@"code"])};
    //
    //    [TalkingData trackEvent:@"分享" label:@"商户" parameters:params];
    
    //    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"取消"
    //                                         destructiveButtonTitle:nil
    //                                              otherButtonTitles:@"分享到新浪微博", @"分享给微信好友", @"分享到微信朋友圈", nil];
    //    [sheet showInView:self.view];
    //
    
    
}

- (void)isWeiXinInstalled:(NSInteger)scene
{
    if ([WXApi isWXAppInstalled]) {
        NSString *thumb;
        
        if (![[[_shop objectForKey:@"share_logo"] toString] isEqualToString:@""]) {
            thumb = [_shop objectForKey:@"share_logo"];
        } else if (![[[_shop objectForKey:@"logo"] toString] isEqualToString:@""]) {
            thumb = [_shop objectForKey:@"logo"];
        } else {
            thumb = @"";
        }
        
        [Tool shareToWeiXin:scene
                      title:[_shop objectForKey:@"short_name"]
                description:[_shop objectForKey:@"short_desc"]
                      thumb:thumb
                        url:[_shop objectForKey:@"share_url"]];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"未安装微信客户端，去下载？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"现在下载", nil];
        //        alert.tag = WeiXinShareAlert;
        [alert show];
    }
}

#pragma mark - YunSegmentDelegate -

- (void)segmentButtonDidClick:(UIButton *)sender index:(NSInteger)index {
    YunLog(@"来来来来啊-----%ld", index);
    //    if (index == 3) {
    //        if (self.subIndexOfPriceOrder == 1) {
    //            self.subIndexOfPriceOrder = 2;
    //            [self orderProductFromLowToHigh:nil];
    //        } else {
    //            self.subIndexOfPriceOrder = 1;
    //            [self orderProductFromHighToLow:nil];
    //        }
    //    } else {
    //        if (index == _selectButtonIndex) return;
    //
    //        _selectButtonIndex = index;
    //
    //        [self swipeToControllerIndex:_selectButtonIndex];
    //    }
    [self swipeToControllerIndex:index];
}

/**
 价格从低到高排序
 */
- (void)orderProductFromLowToHigh:(UIButton *)sender
{
    self.pageNonce = 1;
    //    self.subIndexOfPriceOrder = 1;
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    AppDelegate *appDelegate = kAppDelegate;
    NSMutableDictionary *listParams = [NSMutableDictionary dictionaryWithDictionary:@{@"code"                    :   kNullToString(_code),
                                                                                      @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)}];
    [listParams setObject:@"price" forKey:@"order"];
    [listParams setObject:@"asc" forKey:@"dir"];
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[kProductListURL stringByReplacingOccurrencesOfString:@":code" withString:kNullToString(_code)] params:listParams];
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product list responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _products = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                 
                 [_collectionView reloadData];
                 
                 [_hud hide:YES];
                 self.priceAsc = NO;
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPriceFromLowToHighNotification object:self];
                 
             } else {
                 YunLog(@"%@",kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"get product list error = %@", error);
             
             [_hud addErrorString:@"获取商品数据异常" delay:2.0];
         }
     ];
    
}

/**
 价格从高到低排序
 */
- (void)orderProductFromHighToLow:(UIButton *)sender
{
    self.pageNonce = 1;
    //    self.subIndexOfPriceOrder = 2;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSMutableDictionary *listParams = [NSMutableDictionary dictionaryWithDictionary:@{@"code"                     :   kNullToString(_code),
                                                                                      @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)}];
    [listParams setObject:@"price" forKey:@"order"];
    [listParams setObject:@"desc" forKey:@"dir"];
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[kProductListURL stringByReplacingOccurrencesOfString:@":code" withString:kNullToString(_code)] params:listParams];
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product list responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _products = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                 
                 [_collectionView reloadData];
                 
                 [_hud hide:YES];
                 self.priceAsc = YES;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPriceFromHighToLowNotification object:self];
                 
             } else {
                 YunLog(@"%@",kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
                 
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"get product list error = %@", error);
             
             [_hud addErrorString:@"获取商品数据异常" delay:2.0];
         }
     ];
}

#pragma mark - YunShareViewDelegate -

- (void)shareViewDidSelectView:(YunShareView *)shareView inSection:(NSUInteger)section index:(NSUInteger)index
{
    //    YunLog(@"您点击了第%lu排的第%lu个按钮", section + 1, index + 1);
    // 微博分享内容
    NSString *title = kNullToString([_shop objectForKey:@"share_title"]);
    NSString *desc = kNullToString([_shop objectForKey:@"short_desc"]);
    NSString *url = kNullToString([_shop objectForKey:@"share_url"]);
    
    NSUInteger titleLength = title.length;
    NSUInteger descLength = desc.length;
    NSUInteger urlLength = url.length;
    
    if (titleLength + descLength + urlLength > 136) {
        desc = [desc substringWithRange:NSMakeRange(0, 136 - titleLength - urlLength)];
    }
    
    NSString *description = [NSString stringWithFormat:@"#%@# %@ %@", title, desc, url];
    
    switch (index) {
        case 0:
            [self isWeiXinInstalled:WXSceneSession];
            
            break;
            
        case 1:
            [self isWeiXinInstalled:WXSceneTimeline];
            
            break;
            
        case 2:
        {
            NSString *thumb;
            
            if (![[[_shop objectForKey:@"share_logo"] toString] isEqualToString:@""]) {
                thumb = [_shop objectForKey:@"share_logo"];
            } else if (![[[_shop objectForKey:@"logo"] toString] isEqualToString:@""]) {
                thumb = [_shop objectForKey:@"logo"];
            } else {
                thumb = @"";
            }
            
            [Tool shareToWeiBo:thumb description:description];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - contactServiceClick -

- (void)contactServiceClick
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"联系客服" message:_shop[@"phone"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"联系TA", nil];
    alertView.tag = 20;
    
    [alertView show];
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 20) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.message]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
