//
//  ActivityViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-2-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "ActivityViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"

// Controllers
#import "WebViewController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "ProductDetailViewController.h"
#import "CartNewViewController.h"
#import "LoginViewController.h"

// Views
#import "ShopListButton.h"
#import "UILabelWithLine.h"

// Categories
#import "UIImageView+AFNetworking.h"
#import "UIView+AddBadge.h"

@interface ActivityViewController () < UITableViewDataSource, UITableViewDelegate>

/// tableViewUI控件
@property (nonatomic, strong) UITableView *tableView;

/// 活动数组
@property (nonatomic, strong) NSArray *activities;

/// 商品分类的类型
@property (nonatomic, strong) NSArray *sku_categories;

/// 商品的优惠信息
@property (nonatomic, strong) NSArray *product_promotions;

/// 是否刷新
@property (nonatomic, assign) BOOL reloading;

/// 刷新当前页
@property (nonatomic, assign) NSInteger refreshCount;

/// 购物车按钮
@property (nonatomic, strong) UIButton *cart;

@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;

@end

@implementation ActivityViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    _refreshCount = 1;
    _reloading = NO;
    
//
//    [_cart removeFromSuperview];
//    
//    _cart = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 32.5, 30)];
//    [_cart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
//    [_cart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
//    
//    if ([[[CartManager defaultCart] productCount] isEqualToString:@"0"]) {
//        [_cart removeBadge];
//    } else {
//        [_cart addBadge:[[CartManager defaultCart] productCount]];
//    }
//    
//    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc] initWithCustomView:_cart];
//    cartItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.rightBarButtonItem = cartItem;
//    
//    if ([[[CartManager defaultCart] productCount] isEqualToString:@"0"]) {
//        [_cart removeBadge];
//    } else {
//        [_cart addBadge:[[CartManager defaultCart] productCount]];
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    _activities = [NSArray array];
    _sku_categories = [NSArray array];
    _product_promotions = [NSArray array];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    
    if(_isHomePage == YES)
    {
        naviTitle.text = @"推荐商品";
    }
    else
    {
        naviTitle.text = _activityName;
    }
    
    self.navigationItem.titleView = naviTitle;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    // 添加上拉下拉控件
    [self createMJRefresh];
    
    _pageNonce = 1;
    
    [self getNextPageViewIsPullDown:YES withPage:_pageNonce isFrist:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

#pragma mark - Private Functions -

/**
 popViewController方法返回上一个视图
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 进入购物车视图
 */
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



/// 获取促销信息
- (void)getProductPromotions:(NSDictionary *)activity
{
    NSString *productCode = [activity objectForKey:@"code"];
    
    NSString *promotionsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductPromotions,productCode] params:nil];
    
    YunLog(@"product promotions url = %@", promotionsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:promotionsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"pro res = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _product_promotions = [[responseObject objectForKey:@"data"] objectForKey:@"promotion_activities"];
            [self addToCartAndPromotion:activity isPromotion:YES];
            YunLog(@"promotion_activities = %@", _product_promotions);
        } else {
            [self addToCartAndPromotion:activity isPromotion:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
    }];
}

- (void)addToCartNew:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin) {
        NSDictionary *activity = _activities[sender.tag];
        
        NSArray *sku_categories = [[activity objectForKey:@"product_variant"] objectForKey:@"sku_categories"];
        NSNumber *sku_cateID = [[[[sku_categories firstObject] objectForKey:@"values"] firstObject] objectForKey:@"id"];
        
        //    NSString *sku_cateName = [[[[sku_categories firstObject] objectForKey:@"values"] firstObject] objectForKey:@"value"];
        
        NSDictionary *variant = [[[activity objectForKey:@"product_variant"] objectForKey:@"variants"] objectForKey:[NSString stringWithFormat:@"%@", sku_cateID]];
        
        YunLog(@"activity = %@", activity);
        NSString *subtitle  = kNullToString([variant objectForKey:@"value1"]);
        
        AppDelegate *appDelegate = kAppDelegate;
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"正在添加...";
        
        // TODO  在详情页面添加商品到购物车  默认选中的数量是1
        NSDictionary *params = @{@"user_session_key"    :   kNullToString(appDelegate.user.userSessionKey),
                                 @"pv_id"               :   kNullToString([variant objectForKey:@"sku_id"]),
                                 @"number"              :   kNullToString(@"1")};
        
        NSString *addCartURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAddCartProductURL params:nil];
        
        YunLog(@"addCartURL = %@", addCartURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager POST:addCartURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"add responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                //            UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
                //            cartVC.tabBarItem.badgeValue = [[CartManager defaultCart] productCount];
                //
                //            [_bottomCart addBadge:[[CartManager defaultCart] productCount]];
                
                _hud.detailsLabelText = @"已添加到购物车";
                [_hud addSuccessString:[NSString stringWithFormat:@"%@", subtitle] delay:1.0];
                
                YunLog(@"CartManager");
            } else {
                [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
            }            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"add to cart exception = %@", error);
            [_hud addErrorString:@"添加到购物车失败" delay:1.5];
        }];
    } else {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isReturnView = YES;
        loginVC.isBuyEnter = YES;
        
        UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        
        [self.navigationController presentViewController:loginNC animated:YES completion:nil];
    }
}

/**
 添加到购物车
 
 @param sender 被点击按钮
 */
- (void)addToCart:(UIButton *)sender
{
    NSDictionary *activity = _activities[sender.tag];
    
    [self getProductPromotions:activity];
}

- (void)addToCartAndPromotion:(NSDictionary *)activity isPromotion:(BOOL)isPromontion
{
    NSArray *sku_categories = [[activity objectForKey:@"product_variant"] objectForKey:@"sku_categories"];
    NSNumber *sku_cateID = [[[[sku_categories firstObject] objectForKey:@"values"] firstObject] objectForKey:@"id"];
    
    NSDictionary *variant = [[[activity objectForKey:@"product_variant"] objectForKey:@"variants"] objectForKey:[NSString stringWithFormat:@"%@", sku_cateID]];
    
    YunLog(@"activity = %@", activity);
    
    NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
    
    @try {
        [product setObject:kNullToString([activity objectForKey:@"name"]) forKey:CartManagerDescriptionKey];
        [product setObject:kNullToString([variant objectForKey:@"value1"]) forKey:CartManagerSubtitleKey];
        [product setObject:kNullToString([variant objectForKey:@"price"]) forKey:CartManagerPriceKey];
        [product setObject:kNullToString([[variant objectForKey:@"sku_id"] stringValue]) forKey:CartManagerSkuIDKey];
        [product setObject:kNullToString([activity objectForKey:@"icon"]) forKey:CartManagerImageURLKey];
        [product setObject:kNullToString([activity objectForKey:@"large_icon_200_200"]) forKey:CartManagerSmallImageURLKey];
        [product setObject:kNullToString([activity objectForKey:@"shop_code"]) forKey:CartManagerShopCodeKey];
        [product setObject:kNullToString([activity objectForKey:@"code"]) forKey:CartManagerProductCodeKey];
        if (isPromontion) {
            NSArray *promotinsArray = [NSArray array];
            promotinsArray = _product_promotions;
            [product setObject:kNullToArray(promotinsArray) forKey:CartManagerPromotionsKey];
        }
        
        if ([[activity objectForKey:@"is_limit_quantity"] integerValue] == 0) {
            [product setObject:@"1" forKey:CartManagerCountKey];
            [product setObject:@"1" forKey:CartManagerMinCountKey];
            [product setObject:@"0" forKey:CartManagerMaxCountKey];
        } else {
            NSString *min = kNullToString([activity objectForKey:@"minimum_quantity"]);
            
            if ([min integerValue] == 0) {
                min = @"1";
            }
            
            [product setObject:min forKey:CartManagerCountKey];
            [product setObject:min forKey:CartManagerMinCountKey];
            [product setObject:kNullToString([activity objectForKey:@"limited_quantity"]) forKey:CartManagerMaxCountKey];
        }
    }
    @catch (NSException *exception) {
        YunLog(@"add to cart exception = %@", exception);
    }
    @finally {
        
    }
    
    [[CartManager defaultCart] addProduct:product
                                  success:^{
                                      UIViewController *cartVC = [self.tabBarController.viewControllers objectAtIndex:1];
                                      cartVC.tabBarItem.badgeValue = [[CartManager defaultCart] productCount];
                                      
                                      [_cart addBadge:[[CartManager defaultCart] productCount]];
                                      
                                      _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                      [_hud addSuccessString:[NSString stringWithFormat:@"\"%@\"\n已添加到购物车", [activity objectForKey:@"name"]]
                                                       delay:1.0];
                                  }
                                  failure:^(int count){
                                      _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                      [_hud addErrorString:[NSString stringWithFormat:@"本商品限购%d件", count] delay:2.0];
                                  }];
}

#pragma mark - Pull Refresh -

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh{
    
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
//    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

/**
 上拉刷新响应方法
 */
- (void)headerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce = 1;
    
    [self getNextPageViewIsPullDown:YES withPage:_pageNonce isFrist:NO];
}

/**
 下拉加载更多响应方法
 */
//- (void)footerRereshing
//{
//    if (_isLoading == YES) return;
//    
//    _pageNonce++;
//    
//    [self getNextPageViewIsPullDown:NO withPage:_pageNonce isFrist:NO];
//}

/**
 获取数据源
 
 @param pullDown 是否是下拉
 @param page     当前页数
 @param frist    是否是第一次调用该方法
 */
- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page isFrist:(BOOL)frist
{
    _isLoading = YES;
    
    if (!_hud)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        
    }
    
    if(pullDown == NO)
    {
        //        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //        _hud.labelText = @"努力加载中...";
        
        if (_activities.count >= 8) {
            //                NSInteger rc = _refreshCount;
            //                rc += 1;
            
            //        AppDelegate *appDelegate = kAppDelegate;
            //
            //        NSDictionary *params = [NSDictionary dictionary];
            NSString *requestURL;
            
            if(_isHomePage == YES)
            {
                //            params = @{@"activity_id"             :   kNullToString(@"7"),
                //                       @"page"                    :   [NSString stringWithFormat:@"%ld", (long)page],
                //                       @"limit"                   :   @"8",
                //                       @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
                if ([kRequestHost isEqualToString:@"http://api.shop.sit.yundianjia.net"]) {
                    requestURL = [NSString stringWithFormat:kHomeRecommendListURL,@"88386746"];
                }
                
                if ([kRequestHost isEqualToString:@"http://api.shop.yundianjia.com"]) {
                    requestURL = [NSString stringWithFormat:kHomeRecommendListURL,@"88386746"];
                }
            }
            else
            {
                //            params = @{@"activity_id"             :   kNullToString(_activityID),
                //                       @"page"                    :   [NSString stringWithFormat:@"%ld", (long)page],
                //                       @"limit"                   :   @"8",
                //                       @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
                requestURL = [NSString stringWithFormat:kHomeRecommendListURL,_activityCode];
            }
            
            NSString *activityURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                                   APIVersion:kAPIVersion1
                                                   requestURL:requestURL
                                                       params:nil];
            
            YunLog(@"shop refresh activity url = %@", activityURL);
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer.timeoutInterval = 30;
            
            __weak typeof(self) weakSelf = self;
            [manager GET:activityURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                YunLog(@"shop refresh list responseObject = %@", responseObject);
                
                NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
                if ([code isEqualToString:kSuccessCode]) {
                    NSMutableArray *newActivities = [NSMutableArray array];
                    NSArray *arrayTemp = [NSArray array];
//                    if ([[[responseObject objectForKey:@"data"] objectForKey:@"has_tags"] isEqualToString:@"2"]) {
//                        newActivities = kNullToArray([[[[responseObject objectForKey:@"data"] objectForKey:@"tags"] firstObject] objectForKey:@"products"]);
//                    }
//                    // TODO带确定是那个数据结构
//                    if ([[[responseObject objectForKey:@"data"] objectForKey:@"has_tags"] isEqualToString:@"1"]) {
//                        newActivities = kNullToArray([[[[responseObject objectForKey:@"data"] objectForKey:@"tags"] firstObject] objectForKey:@"products"]);
//                    }
                    arrayTemp = kNullToArray([[[[responseObject objectForKey:@"data"] objectForKey:@"tags"] firstObject] objectForKey:@"products"]);
                    
                    for (NSDictionary *dict in arrayTemp) { // 排除空得数据
                        NSString *code = [dict objectForKey:@"code"];
                        if (code.length > 0) {
                            [newActivities addObject:dict];
                        }
                    }
                    
                    YunLog(@"newActivities = %@", newActivities);
                    
                    if (newActivities.count > 0) {
                        weakSelf.activities = [weakSelf.activities arrayByAddingObjectsFromArray:newActivities];
                        
                        [weakSelf.tableView reloadData];
                        
                        _isLoading = NO;
                        _tableView.footerHidden = NO;
                        [_tableView footerEndRefreshing];
                        
                        [_hud hide:YES];
                    } else {
                        //                    [_hud addSuccessString:@"没有更多了哟~" delay:1];
                        
                        _isLoading = NO;
                        _tableView.footerHidden = YES;
                        [_tableView footerEndRefreshing];
                    }
                } else {
                    weakSelf.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                    
                    _isLoading = NO;
                    _tableView.footerHidden = NO;
                    [_tableView footerEndRefreshing];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                _isLoading = NO;
                _tableView.footerHidden = NO;
                [_tableView footerEndRefreshing];
                
                weakSelf.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                
                _isLoading = NO;
                
                YunLog(@"shop refresh activity error = %@", error);
            }];
            
            //        [op start];
        } else {
            _isLoading = NO;
            _tableView.footerHidden = YES;
            [_tableView footerEndRefreshing];
            
            //        [_hud addSuccessString:@"没有更多了哟~" delay:1];
        }
    }
    else
    {
        _pageNonce = 1;
        
        //        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //        _hud.labelText = @"努力加载中...";
        
        //        AppDelegate *appDelegate = kAppDelegate;
        //
        //        NSDictionary *params = [NSDictionary dictionary];
        NSString *requestURL;
        if(_isHomePage == YES)
        {
            //            params = @{@"activity_id"             :   kNullToString(@"7"),
            //                       @"page"                    :   [NSString stringWithFormat:@"%ld", (long)page],
            //                       @"limit"                   :   @"8",
            //                       @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
            if ([kRequestHost isEqualToString:@"http://api.shop.sit.yundianjia.net"]) {
                requestURL = [NSString stringWithFormat:kHomeRecommendListURL,@"88386746"];
            }
            
            if ([kRequestHost isEqualToString:@"http://api.shop.yundianjia.com"]) {
                requestURL = [NSString stringWithFormat:kHomeRecommendListURL,@"88386746"];
            }
        }
        else
        {
            //            params = @{@"activity_id"             :   kNullToString(_activityID),
            //                       @"page"                    :   [NSString stringWithFormat:@"%ld", (long)page],
            //                       @"limit"                   :   @"8",
            //                       @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
            requestURL = [NSString stringWithFormat:kHomeRecommendListURL,_activityCode];
        }
        
        NSString *activityURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:requestURL params:nil];
        
        YunLog(@"shop 推荐 url = %@", activityURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:activityURL
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"shop activity responseObject = %@", responseObject);
                 
                 if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
                 {
//                     if ([[[responseObject objectForKey:@"data"] objectForKey:@"has_tags"] isEqualToString:@"2"]) {
//                         _activities = kNullToArray([[[[responseObject objectForKey:@"data"] objectForKey:@"tags"] firstObject] objectForKey:@"products"]);
//                     }
//                     // TODO带确定是那个数据结构
//                     if ([[[responseObject objectForKey:@"data"] objectForKey:@"has_tags"] isEqualToString:@"1"]) {
//                         _activities = kNullToArray([[[[responseObject objectForKey:@"data"] objectForKey:@"tags"] firstObject] objectForKey:@"products"]);
//                     }
                     NSArray *arrayTemp = [NSArray array];
                     NSMutableArray *arrayProduct = [NSMutableArray array];
                     
                     arrayTemp = kNullToArray([[[[responseObject objectForKey:@"data"] objectForKey:@"tags"] firstObject] objectForKey:@"products"]);
                     
                     for (NSDictionary *dict in arrayTemp) { // 排除空得数据
                         NSString *code = [dict objectForKey:@"code"];
                         
                         if (code.length > 0) {
                             [arrayProduct addObject:dict];
                         }
                     }
                     
                     _activities = arrayProduct;
                     
                     _isLoading = NO;
                     
                     [_tableView headerEndRefreshing];
                     [_tableView reloadData];
                     [_hud hide:YES];
                     
                     if (_activities.count >= 8) {
                         _tableView.footerHidden = NO;
                     }
                     else
                     {
                         _tableView.footerHidden = YES;
                     }
                 } else {
                     _isLoading = NO;
                     
                     _tableView.footerHidden = NO;
                     [_tableView headerEndRefreshing];
                     //                     _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                     [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 YunLog(@"shop activity error = %@", error);
                 
                 _isLoading = NO;
                 _tableView.footerHidden = NO;
                 [_tableView headerEndRefreshing];
                 //                 _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                 [_hud addErrorString:@"获取商品数据异常" delay:2.0];
                 if(frist == YES)
                 {
                     _isLoading = NO;
                     [_tableView footerEndRefreshing];
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [self backToPrev];
                     });
                 }
             }];
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *activity = _activities[indexPath.row];
    
    // 小图
    //    if ([[activity objectForKey:@"page_style"] integerValue] == 1) {
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 90)];
    //        [imageView setImageWithURL:[NSURL URLWithString:kNullToString([activity objectForKey:@"large_icon"])]
    //                  placeholderImage:[UIImage imageNamed:@"default_image"]];
    imageView.contentMode = UIViewContentModeCenter;
    
    __weak UIImageView *_imageView = imageView;
    
    NSString *urlStr;
    if (_isHomePage || _isBannerPage) {
        urlStr = [activity safeObjectForKey:@"icon"];
    } else {
        urlStr = [activity safeObjectForKey:@"large_icon_200_200"];
    }
    
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString(urlStr)]]
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  // UIViewContentModeScaleAspectFit
                                  _imageView.contentMode = UIViewContentModeScaleToFill;
                                  _imageView.image = image;
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([activity safeObjectForKey:@"large_icon"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                  _imageView.contentMode = UIViewContentModeScaleToFill;
                              }];
    
    [cell.contentView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 10, kScreenWidth - 138, 16)];
    nameLabel.backgroundColor = kClearColor;
    nameLabel.font = [UIFont fontWithName:kFontFamily size:14];
    nameLabel.text = kNullToString([activity objectForKey:@"name"]);
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [cell.contentView addSubview:nameLabel];
    
    //        if ([[activity objectForKey:@"action_type"] integerValue] == 4) {
    NSArray *sku_categories = [[activity objectForKey:@"product_variant"] objectForKey:@"sku_categories"];
    NSNumber *sku_cateID = [[[[sku_categories firstObject] objectForKey:@"values"] firstObject] objectForKey:@"id"];
    
    NSString *sku_cateName = [[[[sku_categories firstObject] objectForKey:@"values"] firstObject] objectForKey:@"value"];
    
    NSDictionary *variants = [[[activity objectForKey:@"product_variant"] objectForKey:@"variants"] objectForKey:[NSString stringWithFormat:@"%@", sku_cateID]];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 28, kScreenWidth - 138, 16)];
    subLabel.backgroundColor = kClearColor;
    subLabel.font = kSmallFont;
    subLabel.text = kNullToString(sku_cateName);
    subLabel.textColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:subLabel];
    
    NSString *price = [NSString stringWithFormat:@"￥%@", kNullToString([variants objectForKey:@"price"])];
    
    CGSize priceSize = [price sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
    
    UILabel *nowPrice = [[UILabel alloc] initWithFrame:CGRectMake(128, 47, priceSize.width, 20)];
    nowPrice.backgroundColor = kClearColor;
    nowPrice.textColor = [UIColor orangeColor];
    nowPrice.font = kBigFont;
    nowPrice.text = price;
    
    [cell.contentView addSubview:nowPrice];
    
    NSString *marketPrice = [NSString stringWithFormat:@"￥%@", kNullToString([variants objectForKey:@"market_price"])];
    
    float priceFloat = [[variants objectForKey:@"price"] floatValue];
    float marketFloat = [[variants objectForKey:@"market_price"] floatValue];
    
    if (priceFloat < marketFloat) {
        CGSize size = [marketPrice sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
        
        UILabelWithLine *lastPrice = [[UILabelWithLine alloc] initWithFrame:CGRectMake(5 + nowPrice.frame.origin.x + nowPrice.frame.size.width, 47, size.width, 20)];
        lastPrice.backgroundColor = kClearColor;
        lastPrice.font = kNormalFont;
        lastPrice.text = marketPrice;
        lastPrice.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:lastPrice];
    }
    
    UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 80, 90, 10)];
    soldLabel.backgroundColor = kClearColor;
    soldLabel.textColor = [UIColor lightGrayColor];
    soldLabel.font = [UIFont fontWithName:kFontFamily size:10];
    
    if ([[variants objectForKey:@"inventory"] integerValue] > 0) {
        soldLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([activity objectForKey:@"sales_quantity"])];
    } else {
        soldLabel.text = @"已售完";
        soldLabel.textColor = [UIColor redColor];
    }
    
    [cell.contentView addSubview:soldLabel];
    
    if ([[variants objectForKey:@"inventory"] integerValue] > 0) {
        UIButton *cart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 92, 68, 82, 22)];
        cart.tag = indexPath.row;
        cart.layer.borderWidth = 1;
        cart.layer.borderColor = [UIColor orangeColor].CGColor;
        cart.layer.cornerRadius = 6;
        cart.layer.masksToBounds = YES;
        cart.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cart setTitle:@"加入购物车" forState:UIControlStateNormal];
        [cart setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        cart.titleLabel.font = kSmallFont;
        
        [cart addTarget:self action:@selector(addToCartNew:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:cart];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *activity = _activities[indexPath.row];
    
    int activityInt = [[activity objectForKey:@"action_type"] intValue];
    
    if (activityInt == 0) {
        activityInt = ActivityProduct;
    }
    
    switch (activityInt) {
        case ActivityWeb:
        {
            WebViewController *web = [[WebViewController alloc] init];
            web.naviTitle = kNullToString([activity objectForKey:@"name"]);
            web.url = kNullToString([activity objectForKey:@"action_value"]);
            web.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:web animated:YES];
            
            break;
        }
            
        case ActivityShop:
        {
//            ShopInfoViewController *info = [[ShopInfoViewController alloc] init];
//            info.code = kNullToString([activity objectForKey:@"action_value"]);
//            info.hidesBottomBarWhenPushed = YES;
//            
//            [self.navigationController pushViewController:info animated:YES];
            
            ShopInfoNewController *info = [[ShopInfoNewController alloc] init];
            info.code = kNullToString([activity objectForKey:@"action_value"]);
            info.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:info animated:YES];
            
            break;
        }
            
        case ActivityProductVariant:
        {
            break;
        }
            
        case ActivityProduct:
        {
            ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
            //            detail.productCode = kNullToString([activity objectForKey:@"action_value"]);
            //            detail.shopCode = kNullToString([[activity objectForKey:@"product"] objectForKey:@"shop_code"]);
            detail.productCode = kNullToString([activity objectForKey:@"code"]);
            detail.shopCode = kNullToString([activity objectForKey:@"shop_code"]);
            detail.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:detail animated:YES];
            
            break;
        }
            
        case ActivityActivity:
        {
            ActivityViewController *newActivity = [[ActivityViewController alloc] init];
            newActivity.activityID = kNullToString([activity objectForKey:@"action_value"]);
            newActivity.activityName = kNullToString([activity objectForKey:@"name"]);
            newActivity.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:newActivity animated:YES];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGPoint point = scrollView.contentOffset;
//    
//    YunLog(@"point.y = %f,crollView.contentSize.height = %f,scrollView.bounds.size.height = %f,self.view.frame.size.height / 3 = %f,    %f",point.y,scrollView.contentSize.height,scrollView.bounds.size.height,self.view.frame.size.height / 4,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
    
//    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
//        [self footerRereshing];
//    }
}
@end
