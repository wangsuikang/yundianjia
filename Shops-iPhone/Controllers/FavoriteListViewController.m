//
//  FavoriteListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-2-25.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "FavoriteListViewController.h"

// classes
#import "AppDelegate.h"
#import "CartManager.h"

// views
#import "ShopListButton.h"
#import "UILabelWithLine.h"

// controllers
#import "ProductDetailViewController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "CartNewViewController.h"

// libraries
#import "AFNetworking.h"
#import "SwipeTableView/SWTableViewCell.h"

// categories
#import "UIImageView+AFNetworking.h"
#import "UIView+AddBadge.h"

#define kShopSpace (kScreenWidth > 375 ? 10 * 1.293 : (kScreenWidth > 320 ? 10 * 1.17 : 10))

@interface FavoriteListViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *shopScope;
@property (nonatomic, strong) UIButton *productScope;
@property (nonatomic, strong) UIButton *cart;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) NSString *scopeType;

@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) NSInteger refreshCount;
@property (nonatomic, assign) BOOL noMore;
@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;

/// 第一次加载
@property (nonatomic,assign) BOOL firstLoad;

// tableView的背景视图view
@property (nonatomic, strong) UIView *back;

// 存放商品和商铺的按钮view
@property (nonatomic, strong) UIView *scopeView;

@end

@implementation FavoriteListViewController

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
        naviTitle.text = @"我的收藏";
        
        self.navigationItem.titleView = naviTitle;
        
        _scopeType = kScopeProduct;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    // 设置透明导航栏
//    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
//    {
//        NSArray *list=self.navigationController.navigationBar.subviews;
//        
//        for (id obj in list) {
//            
//            if ([obj isKindOfClass:[UIImageView class]]) {
//                
//                UIImageView *imageView=(UIImageView *)obj;
//                
//                imageView.hidden=NO;
//            }
//        }
//    }
    
    NSString *cartCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"];
    //    NSString *cartCountNow = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCountNow"];
    
    if (_cart) {
        [_cart removeFromSuperview];
    }
    
    _cart = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 32.5, 30)];
    [_cart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
    [_cart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
    
    if ([cartCount intValue] == 0) {
        [_cart removeBadge];
    } else {
        [_cart addBadge:cartCount];
    }
    
    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc] initWithCustomView:_cart];
    cartItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = cartItem;
    
//     [self getCartListProducts];
    
    if (self.firstLoad) {
        self.firstLoad = NO;
        if ([_scopeType isEqualToString:kScopeProduct]) {
            [self changeType:_productScope isHeadering:YES];
        } else {
            [self changeType:_shopScope isHeadering:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 添加上拉下拉控件
    [self createMJRefresh];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
    
    [_tableView removeHeader];
    [_tableView removeFooter];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.firstLoad = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _scopeView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 40, kScreenWidth, 40)];
    _scopeView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_scopeView];
    
    _productScope = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 2, _scopeView.frame.size.height)];
    _productScope.tag = 2;
    _productScope.backgroundColor = [UIColor orangeColor];
    _productScope.titleLabel.font = kNormalFont;
    [_productScope setTitle:@"商品" forState:UIControlStateNormal];
    [_productScope setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_productScope addTarget:self action:@selector(changeType: isHeadering:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scopeView addSubview:_productScope];
    
    _shopScope = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2, 0, kScreenWidth / 2, _scopeView.frame.size.height)];
    _shopScope.tag = 1;
    _shopScope.backgroundColor = [UIColor lightGrayColor];
    _shopScope.titleLabel.font = kNormalFont;
    [_shopScope setTitle:@"商铺" forState:UIControlStateNormal];
    [_shopScope setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shopScope addTarget:self action:@selector(changeType: isHeadering:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scopeView addSubview:_shopScope];
    
    //    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - 64 - scopeView.frame.size.height)];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - kCustomNaviHeight - _scopeView.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _back = [[UIView alloc] initWithFrame:_tableView.frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, (_back.frame.size.height - 150) / 2 - 20, 120, 150)];
    imageView.image = [UIImage imageNamed:@"no_favorite"];
    
    [_back addSubview:imageView];
    
    _tableView.backgroundView = _back;
    _tableView.backgroundView.hidden = YES;
    
    // 添加上拉下拉控件
//    [self createMJRefresh];
    
    _pageNonce = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _tableView.delegate = nil;
}

//#pragma mark - Private Functions -
//
//// 获取购物车列表信息
//
//- (void)getCartListProducts
//{
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    NSDictionary *params = @{@"user_session_key"     :     kNullToString(appDelegate.user.userSessionKey)};
//    
//    NSString *cartProductsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartBaseURL params:params];
//    
//    YunLog(@"cartProductsURL = %@", cartProductsURL);
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 30;
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    
//    [manager GET:cartProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        YunLog(@"cartCount = %@", responseObject);
//        
//        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
//        
//        if ([code isEqualToString:kSuccessCode]) {
//            NSInteger cartCount = [[[[responseObject objectForKey:@"data"] objectForKey:@"cart"] objectForKey:@"product_total_count"] integerValue];
//            
//            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", cartCount] forKey:@"cartCount"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        YunLog(@"error = %@", error);
//    }];
//}
//
#pragma mark - Private Functions -

/**
 返回上一个界面
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 切换收藏类型
 
 @param sender      点击的按钮
 @param isHeadering 判断是否是下拉刷新
 */
- (void)changeType:(UIButton *)sender isHeadering:(BOOL)isHeadering
{
    _refreshCount = 1;
    _noMore = NO;
    _reloading = NO;
    _pageNonce = 1;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    if (isHeadering) {
        _hud.labelText = @"努力加载中...";
    }
    else
    {
        _hud.labelText = @"切换收藏类别...";
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    NSString *categoryStr;
    
    if (sender.tag == 1) {
        categoryStr = @"Shop";
    }
    
    if (sender.tag == 2) {
        categoryStr = @"Product";
    }
    
    NSDictionary *params = @{@"category"                :   categoryStr,
                             @"page"                    :   @"1",
                             @"per"                     :   kIsiPhone ? @"8" : @"10",
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1
                                           requestURL:kAdminFavoritesURL
                                               params:params];
    
    YunLog(@"favorite choose url = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:favoriteURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"favorite query responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             if ([code isEqualToString:kSuccessCode]) {
                 _items = [[responseObject objectForKey:@"data"] objectForKey:@"favorites"];
                 YunLog(@"items:%@",_items);
                 sender.backgroundColor = [UIColor orangeColor];
                 
                 if (sender.tag == 2) {
                     _scopeType = kScopeProduct;
                     _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                     
                     _shopScope.backgroundColor = [UIColor lightGrayColor];
                 }
                 else if (sender.tag == 1) {
                     _scopeType = kScopeShop;
                     _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                     
                     _productScope.backgroundColor = [UIColor lightGrayColor];
                 }
                 
                 //_tableView.contentOffset = CGPointMake(0, 0);
                 
                 [_tableView headerEndRefreshing];
                 
                 [_hud hide:YES];
                 
                 [_tableView reloadData];
                 
                 if (_items.count >= 8) {
                     [_tableView setFooterHidden:NO];
                     [_tableView setHeaderHidden:NO];
                 } else if (_items.count < 8 && _items.count > 0) {
                     _noMore = YES;
                     [_tableView setHeaderHidden:NO];
                     [_tableView setFooterHidden:YES];
                 } else if (_items.count == 0) {
                     [_tableView setHeaderHidden:YES];
                     [_tableView setFooterHidden:YES];
                 }
                 
                 if (_items.count <= 0) {
                     _tableView.backgroundView.hidden = NO;
                     _tableView.headerHidden = YES;
                     
                 } else {
                     _tableView.backgroundView.hidden = YES;
                     _tableView.headerHidden = NO;
                 }
                 
                 [_hud hide:YES];
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
}

/**
 去购物车页面
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

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_scopeType isEqualToString:kScopeProduct]) {
        return 100;
    } else {
        //        return 120 * kScreenWidth / 320 + 50;
        return 170;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *cellDict = _items[indexPath.row];
    
    if (!cell) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" tableView:tableView];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect rect;
    
    // 商品
    if ([_scopeType isEqualToString:kScopeProduct])
    {
        if (kDeviceOSVersion >= 7.0) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        rect = CGRectMake(0, 0, kScreenWidth, 100);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 108, 80)];
        
        imageView.contentMode = UIViewContentModeCenter;
        
        __weak UIImageView *_imageView = imageView;
        
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([cellDict safeObjectForKey:@"image_url_200"])]]
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                      _imageView.image = image;
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([cellDict safeObjectForKey:@"image_url"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                      _imageView.contentMode = UIViewContentModeScaleAspectFill;
                                  }];
        
        [cell.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 12, kScreenWidth - 138, 14)];
        nameLabel.backgroundColor = kClearColor;
        nameLabel.font = [UIFont fontWithName:kFontFamily size:14];
        nameLabel.text = kNullToString([cellDict safeObjectForKey:@"title"]);
        nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [cell.contentView addSubview:nameLabel];
        
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 30, kScreenWidth - 138, 14)];
        subLabel.backgroundColor = kClearColor;
        subLabel.font = kSmallFont;
        subLabel.text = kNullToString([cellDict safeObjectForKey:@"subtitle"]);
        subLabel.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:subLabel];
        
        NSString *price = [NSString stringWithFormat:@"￥%@", kNullToString([cellDict safeObjectForKey:@"price"])];
        
        CGSize priceSize = [price sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
        
        UILabel *nowPrice = [[UILabel alloc] initWithFrame:CGRectMake(128, 47, priceSize.width, 20)];
        nowPrice.backgroundColor = kClearColor;
        nowPrice.textColor = [UIColor orangeColor];
        nowPrice.font = kBigFont;
        nowPrice.text = price;
        
        [cell.contentView addSubview:nowPrice];
        
        NSString *marketPrice = [NSString stringWithFormat:@"￥%@", kNullToString([cellDict safeObjectForKey:@"market_price"])];
        
        float priceFloat = [[cellDict safeObjectForKey:@"price"] floatValue];
        float marketFloat = [[cellDict safeObjectForKey:@"market_price"] floatValue];
        
        if (priceFloat < marketFloat) {
            CGSize size = [marketPrice sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
            
            UILabelWithLine *lastPrice = [[UILabelWithLine alloc] initWithFrame:CGRectMake(5 + nowPrice.frame.origin.x + nowPrice.frame.size.width, 47, size.width, 20)];
            lastPrice.backgroundColor = kClearColor;
            lastPrice.font = kNormalFont;
            lastPrice.text = marketPrice;
            lastPrice.textColor = [UIColor lightGrayColor];
            
            [cell.contentView addSubview:lastPrice];
        }
        
        UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 80, 80, 10)];
        soldLabel.backgroundColor = kClearColor;
        soldLabel.textColor = [UIColor lightGrayColor];
        soldLabel.font = [UIFont fontWithName:kFontFamily size:10];
        
        if ([[cellDict safeObjectForKey:@"inventory_quantity"] integerValue] > 0) {
            soldLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([cellDict safeObjectForKey:@"sales_quantity"])];
        } else {
            soldLabel.text = @"已售完";
            soldLabel.textColor = [UIColor redColor];
        }
        
        [cell.contentView addSubview:soldLabel];
        
//        if ([[_items[indexPath.row] objectForKey:@"inventory_quantity"] integerValue] > 0) {
//            UIButton *cart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 92, 70, 82, 25)];
//            cart.tag = indexPath.row;
//            cart.layer.borderWidth = 1;
//            cart.layer.borderColor = [UIColor orangeColor].CGColor;
//            cart.layer.cornerRadius = 5;
//            cart.layer.masksToBounds = YES;
//            cart.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//            [cart setTitle:@"加入购物车" forState:UIControlStateNormal];
//            [cart setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//            cart.titleLabel.font = kSmallFont;
//
//            [cart addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
//
//            [cell.contentView addSubview:cart];
//        }
       

        // 库存
        UILabel *inventoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(soldLabel.frame), 80, 90, 10)];
        inventoryLabel.backgroundColor = kClearColor;
        inventoryLabel.textColor = [UIColor lightGrayColor];
        inventoryLabel.font = [UIFont fontWithName:kFontFamily size:10];
        
        if ([[cellDict safeObjectForKey:@"inventory_quantity"] integerValue] > 0) {
            inventoryLabel.alpha = 1.0;
            inventoryLabel.text = [NSString stringWithFormat:@"库存 %@", kNullToString([cellDict safeObjectForKey:@"inventory_quantity"])];
        } else {
            inventoryLabel.alpha = 0.0;
        }
        
        [cell.contentView addSubview:inventoryLabel];
    }
    // 商铺
    else
    {
        //        CGFloat imageHeight = 120 * kScreenWidth / 320;
        CGFloat imageHeight = 120;
        
        rect = CGRectMake(0, 0, kScreenWidth, imageHeight + 50);
        
        UIView *view = [[UIView alloc] initWithFrame:cell.frame];
        view.backgroundColor = [UIColor whiteColor];
        
        cell.backgroundView = view;
        
        //        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, imageHeight + 30)];
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(kShopSpace, 10, kScreenWidth - 2 * kShopSpace, 150)];
        //        container.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
        //        container.layer.shadowOpacity = 1.0;
        //        container.layer.shadowRadius = 5.0;
        //        container.layer.shadowOffset = CGSizeMake(0, 1);
        //        container.clipsToBounds = NO;
        //        container.backgroundColor = kBackgroundColor;
        
        [cell.contentView addSubview:container];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, imageHeight)];
        imageView.backgroundColor = kClearColor;
        imageView.contentMode = UIViewContentModeCenter;
        [imageView addBorderWithDirection:AddBorderDirectionLeft | AddBorderDirectionTop | AddBorderDirectionRight];
        
        __weak UIImageView *_imageView = imageView;
        
        [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([[[_items[indexPath.row] objectForKey:@"mobile_banners"] firstObject] objectForKey:@"image_url"])]]
                          placeholderImage:[UIImage imageNamed:@"default_image"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       _imageView.image = image;
                                       _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([[[_items[indexPath.row] objectForKey:@"pc_banners"] firstObject] objectForKey:@"image_url"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                       _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                   }];
        
        [container addSubview:imageView];
        
        UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight, container.frame.size.width, 30)];
        labelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        labelView.layer.borderWidth = 1;
        
        [container addSubview:labelView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageHeight, container.frame.size.width - 10, 30)];
        label.backgroundColor = kClearColor;
        label.font = [UIFont fontWithName:kFontFamily size:14];
        label.text = kNullToString([_items[indexPath.row] objectForKey:@"name"]);
        
        [container addSubview:label];
    }
    
    NSInteger status = [[_items[indexPath.row] objectForKey:@"status"] integerValue];
    
    if (status == 3) {
        UIView *back = [[UIView alloc] initWithFrame:rect];
        back.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
        
        [cell.contentView addSubview:back];
        
        UIView *icon = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 50, 20)];
        icon.layer.borderColor = [UIColor whiteColor].CGColor;
        icon.layer.borderWidth = 1;
        
        [back addSubview:icon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, icon.frame.size.width, icon.frame.size.height)];
        label.backgroundColor = kClearColor;
        label.font = [UIFont fontWithName:kFontFamily size:14];
        label.text = @"已下架";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        
        [icon addSubview:label];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger status = [[_items[indexPath.row] objectForKey:@"status"] integerValue];
    
    if (status == 3) return;
    
    if ([_scopeType isEqualToString:kScopeShop]) {
//        ShopInfoViewController *shop = [[ShopInfoViewController alloc] init];
//        shop.code = kNullToString([_items[indexPath.row] objectForKey:@"code"]);
//        YunLog(@"shop.code = %@",shop.code);
//        shop.hidesBottomBarWhenPushed = YES;
//        
//        [self.navigationController pushViewController:shop animated:YES];
        
        ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
        shop.code = kNullToString([_items[indexPath.row] objectForKey:@"code"]);
        YunLog(@"shop.code = %@",shop.code);
        shop.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:shop animated:YES];
    } else {
        ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
        detail.productCode = kNullToString([_items[indexPath.row] objectForKey:@"code"]);
        if ([kNullToString([_items[indexPath.row] objectForKey:@"distributor_code"]) isEqualToString:@""]) {
            detail.shopCode = kNullToString([_items[indexPath.row] objectForKey:@"shop_code"]);
        } else {
            detail.shopCode = kNullToString([_items[indexPath.row] objectForKey:@"distributor_code"]);
        }
        
         YunLog(@"detail.shopCode = %@",detail.shopCode);
        detail.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - Pull Refresh -

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh
{
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

/**
 上拉刷新响应方法
 */
- (void)headerRereshing
{
    if (_isLoading == YES) return;
    
    if ([_scopeType isEqualToString:kScopeProduct]) {
        [self changeType:_productScope isHeadering:YES];
    } else {
        [self changeType:_shopScope isHeadering:YES];
    }
}

/**
 下拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce ++;
    
    [self getNextPageViewWithPage:_pageNonce];
}

/**
 上拉加载更多数据
 
 @param page 加载数据的页码
 */
- (void)getNextPageViewWithPage:(NSInteger)page
{
    if (_items.count >= 8 && !_noMore)
    {
        //        NSInteger rc = _refreshCount;
        //        rc += 1;
        if (!_hud) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            _hud.labelText = @"努力加载中...";
        }
        
        AppDelegate *appDelegate = kAppDelegate;
        
        NSString *categoryStr = [_scopeType isEqualToString:kScopeProduct] ? @"Product" : @"Shop";
        
        NSDictionary *params = @{@"category"                :   categoryStr,
                                 @"page"                    :   [NSString stringWithFormat:@"%ld", (long)_pageNonce],
                                 @"per"                     :   kIsiPhone ? @"8" : @"10",
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
        
        NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                               APIVersion:kAPIVersion1
                                               requestURL:kAdminFavoritesURL
                                                   params:params];
        
        YunLog(@"favorite query url = %@", favoriteURL);
        
        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                     URLString:favoriteURL
                                                                                    parameters:nil
                                                                                         error:nil];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        
        __weak typeof(self) weakSelf = self;
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"favorite refresh list responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                NSArray *newItems = [[responseObject objectForKey:@"data"] objectForKey:@"favorites"];
                
                if (!newItems) {
                    _noMore = YES;
                    _tableView.footerHidden = YES;
                    [_tableView footerEndRefreshing];
                    [_hud hide:YES];
                    
                    return;
                } else if (newItems.count > 0) {
                    _items = [_items arrayByAddingObjectsFromArray:newItems];
                    
                    [_tableView reloadData];
                    
                    _refreshCount += 1;
                    
                    if (newItems.count < 8) {
                        _noMore = YES;
                        
                        [_hud hide:YES];
                        _tableView.footerHidden = NO;
                        [_tableView footerEndRefreshing];
                        [_tableView headerEndRefreshing];
                    } else {
                        [_hud hide:YES];
                        _tableView.footerHidden = NO;
                        [_tableView footerEndRefreshing];
                        [_tableView headerEndRefreshing];
                    }
                }
            } else {
                weakSelf.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                _tableView.footerHidden = NO;
                [_tableView footerEndRefreshing];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            weakSelf.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
            _tableView.footerHidden = NO;
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            
            YunLog(@"favorite refresh list error = %@", error);
        }];
        
        [op start];
    }
    else
    {
        _tableView.footerHidden = YES;
        [_tableView footerEndRefreshing];
        [_tableView headerEndRefreshing];
        
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [_hud addSuccessString:@"没有更多了哟~" delay:1];
        _pageNonce--;
    }
}

#pragma mark - Add To Cart -

- (void)addToCart:(UIButton *)sender
{
    NSDictionary *productDict = _items[sender.tag];
    
    NSString *name = kNullToString([productDict objectForKey:@"title"]);
    
    NSString *subtitle  = kNullToString([productDict objectForKey:@"title"]);
    NSString *price     = kNullToString([productDict objectForKey:@"price"]);
    NSString *skuid     = kNullToString([productDict objectForKey:@"sku_id"]);
    NSString *inventory = kNullToString([productDict objectForKey:@"inventory_quantity"]);
    NSString *imageURL  = kNullToString([productDict objectForKey:@"image_url"]);
    NSString *smal_imageURL = kNullToString([productDict objectForKey:@"smal_image_url"]);
    NSString *shop_code = kNullToString([productDict objectForKey:@"shop_code"]);
    NSString *code =kNullToString([productDict objectForKey:@"code"]);
    
    @try {
        NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
        
        [product setObject:name forKey:CartManagerDescriptionKey];
        [product setObject:subtitle forKey:CartManagerSubtitleKey];
        [product setObject:price forKey:CartManagerPriceKey];
        [product setObject:skuid forKey:CartManagerSkuIDKey];
        [product setObject:imageURL forKey:CartManagerImageURLKey];
        [product setObject:smal_imageURL forKey:CartManagerSmallImageURLKey];
        [product setObject:inventory forKey:CartManagerInventoryKey];
        [product setObject:shop_code forKey:CartManagerShopCodeKey];
        [product setObject:code forKey:CartManagerProductCodeKey];
        
        if ([[productDict objectForKey:@"is_limit_quantity"] integerValue] == 0) {
            [product setObject:@"1" forKey:CartManagerCountKey];
            [product setObject:@"1" forKey:CartManagerMinCountKey];
            [product setObject:@"0" forKey:CartManagerMaxCountKey];
        } else {
            NSString *min = kNullToString([productDict objectForKey:@"minimum_quantity"]);
            
            if ([min integerValue] == 0) {
                min = @"1";
            }
            
            [product setObject:min forKey:CartManagerCountKey];
            [product setObject:min forKey:CartManagerMinCountKey];
            [product setObject:kNullToString([productDict objectForKey:@"limited_quantity"]) forKey:CartManagerMaxCountKey];
        }
        
        [[CartManager defaultCart] addProduct:product
                                      success:^{
                                          UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
                                          cartVC.tabBarItem.badgeValue = [[CartManager defaultCart] productCount];
                                          
                                          [_cart addBadge:[[CartManager defaultCart] productCount]];
                                          
                                          _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                          _hud.detailsLabelText = @"已添加到购物车";
                                          [_hud addSuccessString:[NSString stringWithFormat:@"%@", subtitle] delay:1.0];
                                          
                                          YunLog(@"CartManager");
                                      }
                                      failure:^(int count) {
                                          _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                          [_hud addErrorString:[NSString stringWithFormat:@"本商品限购%d件", count] delay:1.5];
                                      }];
    }
    @catch (NSException *exception) {
        YunLog(@"add to cart exception = %@", exception);
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"添加到购物车失效" delay:1.5];
    }
    @finally {
        
    }
}

#pragma mark - SWTableViewCell Utility -
/**
 *  返回UITableViewCell左滑后出现的按钮组
 *
 *  @return 按钮组
 */
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"取消收藏"];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewCellDelegate -
/**
 *  左滑按钮组中的按钮点击事件处理方法
 *
 *  @param cell  <#cell description#>
 *  @param index <#index description#>
 */
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = _items[cell.tag];
    YunLog(@"item = %@", item);
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [_hud show:YES];
    }
    
    _hud.labelText = @"删除收藏中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSString *favoriteID = item[@"favorite_id"];
    
    NSDictionary *params = @{@"ids"                     :   kNullToString(favoriteID),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *deleteFavURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1
                                           requestURL:kDeleteFavoriteURL
                                               params:params];
    
    YunLog(@"delete favorite url = %@", deleteFavURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    __weak typeof(self) weakSelf = self;
    [manager DELETE:deleteFavURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"delete favorite responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
             {
                 NSMutableArray *temp = [NSMutableArray arrayWithArray:_items];
                 [temp removeObject:item];
                 _items = temp;
                 if (_items.count <= 0) {
                     _tableView.backgroundView.hidden = NO;
                 } else {
                     _tableView.backgroundView.hidden = YES;
                 }
                 [weakSelf.tableView reloadData];
                 
                 _hud.detailsLabelText = @"取消收藏";
                 if ([_scopeType isEqualToString:kScopeProduct]) {
                     [_hud addSuccessString:[NSString stringWithFormat:@"%@", [item objectForKey:@"title"]] delay:2.0];
                 } else {
                     [_hud addSuccessString:[NSString stringWithFormat:@"%@", [item objectForKey:@"name"]] delay:2.0];
                 }
             }
             else {
                 [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"add favorite error = %@", error);
             
             [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
         }];
}
/**
 *  prevent multiple cells from showing utilty buttons simultaneously
 *
 *  @param cell 所在的cell
 *
 *  @return 如果返回YES,则不能同时处理多个左滑
 */
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    YunLog(@"point.y = %f,crollView.contentSize.height = %f,scrollView.bounds.size.height = %f,self.view.frame.size.height / 3 = %f,    %f",point.y,scrollView.contentSize.height,scrollView.bounds.size.height,self.view.frame.size.height / 4,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
    
    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
        [self footerRereshing];
    }
}

@end
