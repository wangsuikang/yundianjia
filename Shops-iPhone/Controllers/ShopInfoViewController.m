//
//  ShopInfoViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "ShopInfoViewController.h"

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

// Categories
#import "UIView+AddBadge.h"
#import "UIScrollView+IBFloatingHeader.h"

// Libraries
#import "WXApi.h"
#import "NSObject+NullToString.h"

#import "DKTabPageViewController.h"

typedef NS_ENUM(NSInteger, AlertTag) {
    TerminalAlert = 0,
    WeiXinShareAlert = 1,
};

@interface ShopInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, YUNSegmentViewDelegate, UIGestureRecognizerDelegate, YunShareViewDelegate>

@property (nonatomic, strong) UITableView     *tableView;
@property (nonatomic, strong) UIView          *back;

@property (nonatomic, strong) NSArray         *products;
@property (nonatomic, strong) NSDictionary    *shop;
@property (nonatomic, strong) NSDictionary    *product_promotions;
@property (nonatomic, copy  ) NSString        *favoriteID;
@property (nonatomic, strong) UIBarButtonItem *favoriteItem;
@property (nonatomic, strong) UIButton        *bottomCart;
@property (nonatomic, strong) UIView          *bottomView;
@property (nonatomic, assign) NSInteger       countBadge;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) int pageNonce;

@property (nonatomic, assign) BOOL isLoading;

@property DKTabPageViewController * tabController;

@property (nonatomic, assign) BOOL priceAsc;

@end

@implementation ShopInfoViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.headerHeight = 64;
    }
    return self;
}


#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        [_bottomCart addBadge:[NSString stringWithFormat:@"%ld", (long)cartCount]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageNonce = 1;
    self.view.backgroundColor = kBackgroundColor;
    
    _product_promotions = [NSDictionary dictionary];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
    NSArray *titles = @[@"店铺首页",@"新品上架",@"销量排行",@"价格排行"];
    for (int i = 0; i < 4; i++) {
        UITableViewController *vc = [UITableViewController new];
        vc.tableView.delegate = self;
        vc.tableView.dataSource = self;
        [vc.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        DKTabPageItem *item = [DKTabPageViewControllerItem tabPageItemWithTitle:titles[i]
                                                                 viewController:vc];
        [vc.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        //[vc.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
        
        [items addObject:item];
    }
    
    DKTabPageViewController *tabPageViewController = [[DKTabPageViewController alloc] initWithItems:items sourceController:self];
    self.tabController = tabPageViewController;
    tabPageViewController.tabPageBar.sourceController = self;
    tabPageViewController.tabPageBar.tabBarHeight = self.headerHeight;
    
    tabPageViewController.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self addChildViewController:tabPageViewController];
    [self.view addSubview:tabPageViewController.view];
    tabPageViewController.view.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 120 * kScreenWidth / 320 - 49 - 64);
    
    [tabPageViewController setTabPageBarAnimationBlock:^(DKTabPageViewController *weakTabPageViewController, UIButton *fromButton, UIButton *toButton, CGFloat progress) {
        
        // animated font
        CGFloat pointSize = weakTabPageViewController.tabPageBar.titleFont.pointSize;
        CGFloat selectedPointSize = 18;
        
        fromButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * (1 - progress)];
        toButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * progress];
        
        // animated text color
        CGFloat red, green, blue;
        [weakTabPageViewController.tabPageBar.titleColor getRed:&red green:&green blue:&blue alpha:NULL];
        
        CGFloat selectedRed, selectedGreen, selectedBlue;
        [weakTabPageViewController.tabPageBar.selectedTitleColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:NULL];
        
        [fromButton setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * (1 - progress)
                                                  green:green + (selectedGreen - green) * (1 - progress)
                                                   blue: blue + (selectedBlue - blue) * (1 - progress)
                                                  alpha:1] forState:UIControlStateSelected];
        
        [toButton setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * progress
                                                green:green + (selectedGreen - green) * progress
                                                 blue:blue + (selectedBlue - blue) * progress
                                                alpha:1] forState:UIControlStateNormal];
    }];
    
    
    //    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48)
    //                                              style:UITableViewStylePlain];
    //    _tableView.delegate = self;
    //    if (kDeviceOSVersion < 7.0)
    //        _tableView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - kCustomNaviHeight - 108);
    //
    //    _tableView.delegate = self;
    //    _tableView.dataSource = self;
    ////    _tableView.bounces = NO;
    //    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //[self.view addSubview:_tableView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
    
    if (kDeviceOSVersion < 7.0) {
        bottomView.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
    }
    
    bottomView.backgroundColor = COLOR(245, 245, 245, 1);
    //    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    //    bottomView.layer.shadowOffset = CGSizeMake(1, 5);
    //    bottomView.layer.shadowOpacity = 1.0;
    //    bottomView.layer.shadowRadius = 5.0;
    bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
    bottomView.layer.borderWidth = 1;
    bottomView.clipsToBounds = NO;
    
    [self.view addSubview:bottomView];
    
    _bottomCart = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 32.5, 30)];
    [_bottomCart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
    [_bottomCart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:_bottomCart];
    
    UIButton *goToBuy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 130, 8, 120, 32)];
    goToBuy.layer.cornerRadius = 6;
    goToBuy.layer.masksToBounds = YES;
    goToBuy.backgroundColor = [UIColor orangeColor];
    [goToBuy setTitle:@"去结算" forState:UIControlStateNormal];
    [goToBuy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goToBuy addTarget:self action:@selector(goToPay) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:goToBuy];
    
    //    NSDictionary *parameters = @{@"uuid"        :   [Tool getUniqueDeviceIdentifier],
    //                                 @"shop_code"   :   kNullToString(_code),
    //                                 @"shop_name"   :   kNullToString([_shop objectForKey:@"name"])};
    //
    //    [TalkingData trackEvent:@"查看商户" label:@"商户首页" parameters:parameters];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"code"                 :   kNullToString(_code),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :    kNullToArray(appDelegate.user.userSessionKey)};
    
    //    NSString *shopURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kShopInfoURL params:params];
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
                                          
                                          [UIView animateWithDuration:0.4 animations:^{
                                              self.tabController.view.frame = CGRectMake(0, 64 + 120 * kScreenWidth / 320, self.tabController.view.frame.size.width, self.tabController.view.frame.size.height);
                                          }];
                                          [weakSelf.view addSubview:wrapper];
                                          [self.view bringSubviewToFront:self.tabController.view];
                                          
                                          //UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                                          //[[tableController tableView] setTableHeaderView:wrapper];
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          
                                      }];
                 
                 _tableView.tableHeaderView = top;
                 
                 // 检测店铺是否收藏
                 [self checkFavorite];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"shop info error = %@", error);
         }];
    
    NSDictionary *listParams = @{@"code"                     :   kNullToString(_code),
                                 @"terminal_session_key"     :   kNullToString(appDelegate.terminalSessionKey),
                                 @"per"                      : @"20"};
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[kProductListURL stringByReplacingOccurrencesOfString:@":code" withString:kNullToString(_code)] params:listParams];
    
    YunLog(@"product list url = %@", listURL);
    
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product list responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _products = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                 
                 UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                 [[tableController tableView] reloadData];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _tableView.delegate = nil;
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

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
    //    [manager GET:favoriteURL
    //      parameters:nil
    //         success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //             YunLog(@"delete favorite responseObject = %@", responseObject);
    //
    //             sender.enabled = YES;
    //
    //             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
    //             {
    //                 _hud.detailsLabelText = @"取消收藏";
    //                 [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_product objectForKey:@"name"]] delay:2.0];
    //
    //                 [sender setImage:nil forState:UIControlStateNormal];
    //                 [sender setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
    //                 [sender removeTarget:sender action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
    //                 [sender addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
    //             } else {
    //                 [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
    //             }
    //
    //         }
    //         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //             YunLog(@"add favorite error = %@", error);
    //
    //             sender.enabled = YES;
    //
    //             [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
    //         }];
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
        
        UITableView *tableView = (UITableView *)[self.tabController.selectedViewController view];
        [tableView footerEndRefreshing];
        
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
    
    if (!_hud)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        
    }
    
    if(pullDown == NO)
    {
        //        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //        _hud.labelText = @"努力加载中...";
        
        NSMutableDictionary *listParams = [NSMutableDictionary dictionaryWithDictionary:@{@"code"                     :   kNullToString(_code),
                                                                                          @"page"                     :   [NSString stringWithFormat:@"%ld",(long)page]}];
        switch (self.currentIndex) {
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
        YunLog(@"listURL = %@", listURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        UITableView *tableView = (UITableView *)[self.tabController.selectedViewController view];
        
        [manager GET:listURL
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"product list responseObject = %@", responseObject);
                 _isLoading = NO;
                 [tableView footerEndRefreshing];
                 
                 if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                     NSMutableArray *temp = [NSMutableArray arrayWithArray:_products];
                     
                     NSArray *newProducts = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                     if (newProducts.count > 0)
                     {
                         [temp addObjectsFromArray:newProducts];
                         self.products = temp;
                         UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                         [[tableController tableView] reloadData];
                         tableController.tableView.footerHidden = NO;
                         [_hud hide:YES];
                         
                     }
                     else
                     {
                         UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                         tableController.tableView.footerHidden = YES;
                     }
                     
                 } else {
                     UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                     tableController.tableView.footerHidden = NO;
                     
                     YunLog(@"%@",kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
                     [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                    delay:2.0];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 YunLog(@"get product list error = %@", error);
                 UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                 tableController.tableView.footerHidden = NO;
                 
                 [tableView footerEndRefreshing];
                 
                 [_hud addErrorString:@"获取商品数据异常" delay:2.0];
             }
         ];
        
    }
    else
    {
        
        //        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //        _hud.labelText = @"努力加载中...";
        UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
        tableController.tableView.footerHidden = YES;
    }
}

//- (void)addFavorite:(UIButton *)sender
//{
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    if (!appDelegate.isLogin) {
//        LoginViewController *loginVC = [[LoginViewController alloc] init];
//        loginVC.isReturnView = YES;
//        
//        [self.navigationController pushViewController:loginVC animated:YES];
//        
//        //        UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        //
//        //        [self.navigationController presentViewController:loginNC animated:YES completion:nil];
//        //
//        return;
//    }
//    
//    if (!_hud) {
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    } else {
//        [_hud show:YES];
//    }
//    //    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    //    _hud.labelText = @"努力收藏中...";
//    
//    NSDictionary *params = @{@"resource_id"             :   kNullToString([_shop objectForKey:@"id"]),
//                             @"resource_type"           :   @"1",
//                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
//                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
//    
//    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHost
//                                           APIVersion:kAPIVersion1
//                                           requestURL:kFavoriteAddURL
//                                               params:params];
//    
//    YunLog(@"add favorite url = %@", favoriteURL);
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 30;
//    
//    [manager GET:favoriteURL
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             YunLog(@"add favorite responseObject = %@", responseObject);
//             
//             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
//             {
//                 NSDictionary *favoriteDic = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_item"];
//                 if (favoriteDic) {
//                     _favoriteID = [NSString stringWithFormat:@"%@", [favoriteDic objectForKey:@"id"]];
//                     
//                     _hud.detailsLabelText = @"收藏成功";
//                     YunLog(@"shop.name = %@",[_shop objectForKey:@"name"]);
//                     [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_shop objectForKey:@"name"]] delay:2.0];
//                     
//                     [sender setImage:nil forState:UIControlStateNormal];
//                     [sender setImage:[UIImage imageNamed:@"top_already_favorite"] forState:UIControlStateNormal];
//                     
//                     [sender removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
//                     [sender addTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
//                     
//                 } else {
//                     [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
//                 }
//             } else {
//                 [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"]
//                                delay:2.0];
//             }
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             YunLog(@"add favorite error = %@", error);
//             
//             [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
//         }];
//}
//
//- (void)deleteFavorite:(UIButton *)sender
//{
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    NSDictionary *params = @{@"ids"                     :   kNullToString(_favoriteID),
//                             @"resource_type"           :   @"1",
//                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
//                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
//    
//    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHost
//                                           APIVersion:kAPIVersion1
//                                           requestURL:kFavoriteDeleteURL
//                                               params:params];
//    
//    YunLog(@"delete favorite url = %@", favoriteURL);
//    
//    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 30;
//    
//    [manager GET:favoriteURL
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             YunLog(@"delete favorite responseObject = %@", responseObject);
//             
//             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
//             {
//                 _hud.detailsLabelText = @"取消收藏";
//                 [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_shop objectForKey:@"name"]] delay:2.0];
//                 
//                 [sender setImage:nil forState:UIControlStateNormal];
//                 [sender setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
//                 
//                 [sender removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
//                 [sender addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
//                 
//             } else {
//                 [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"]
//                                delay:2.0];
//             }
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             YunLog(@"add favorite error = %@", error);
//             
//             [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
//         }];
//}

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

- (void)addToCart:(UIButton *)sender
{
    NSDictionary *productDic = [_products objectAtIndex:sender.tag];
    
    YunLog(@"productDic = %@", productDic);
    
    [self getProductPromotions:productDic];
}

/// 获取促销信息
- (void)getProductPromotions:(NSDictionary *)productDic
{
    NSString *productCode = [productDic objectForKey:@"code"];
    
    NSString *promotionsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductPromotions,productCode] params:nil];
    
    YunLog(@"product promotions url = %@", promotionsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:promotionsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"pro res = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _product_promotions = [[[responseObject objectForKey:@"data"] objectForKey:@"promotion_activities"] firstObject];
            [self addToCartAndPromotion:productDic isPromotion:YES];
            YunLog(@"promotion_activities = %@", _product_promotions);
        } else {
            [self addToCartAndPromotion:productDic isPromotion:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
    }];
}

- (void)addToCartAndPromotion:(NSDictionary *)productDic isPromotion:(BOOL)isPromontion
{
    NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
    
    @try {
        [product setObject:kNullToString([productDic objectForKey:@"title"]) forKey:CartManagerDescriptionKey];
        [product setObject:kNullToString([productDic objectForKey:@"name"]) forKey:CartManagerSubtitleKey];
        [product setObject:kNullToString([productDic objectForKey:@"price"]) forKey:CartManagerPriceKey];
        [product setObject:kNullToString([[productDic objectForKey:@"sku_id"] stringValue]) forKey:CartManagerSkuIDKey];
        [product setObject:kNullToString([productDic objectForKey:@"image_url"]) forKey:CartManagerImageURLKey];
        [product setObject:kNullToString([productDic objectForKey:@"smal_image_url"]) forKey:CartManagerSmallImageURLKey];
        [product setObject:kNullToString([productDic objectForKey:@"shop_code"]) forKey:CartManagerShopCodeKey];
        [product setObject:kNullToString([productDic objectForKey:@"code"]) forKey:CartManagerProductCodeKey];
        if (isPromontion) {
            [product setObject:kNullToString([_product_promotions objectForKey:@"name"]) forKey:CartManagerPromotionsKey];
        }
        
        if ([[productDic objectForKey:@"is_limit_quantity"] integerValue] == 0) {
            [product setObject:@"1" forKey:CartManagerCountKey];
            [product setObject:@"1" forKey:CartManagerMinCountKey];
            [product setObject:@"0" forKey:CartManagerMaxCountKey];
        } else {
            NSString *min = kNullToString([productDic objectForKey:@"minimum_quantity"]);
            
            if ([min integerValue] == 0) {
                min = @"1";
            }
            
            [product setObject:min forKey:CartManagerCountKey];
            [product setObject:min forKey:CartManagerMinCountKey];
            [product setObject:kNullToString([productDic objectForKey:@"limited_quantity"]) forKey:CartManagerMaxCountKey];
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
                                      
                                      [_bottomCart addBadge:[[CartManager defaultCart] productCount]];
                                      
                                      _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                      _hud.detailsLabelText = @"已添加到购物车";
                                      [_hud addSuccessString:[NSString stringWithFormat:@"%@", kNullToString([productDic objectForKey:@"title"])] delay:1.0];
                                  }
                                  failure:^(int count){
                                      _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                      [_hud addErrorString:[NSString stringWithFormat:@"本商品限购%d件", count] delay:2.0];
                                  }];
}

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

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;//self.headerHeight;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.headerHeight)];
//        YUNSegmentView *header = [[YUNSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 64) titles:@[@"店铺首页", @"新品上架", @"销量排序", @"价格排序"] icons:@[@"zhuye",@"shangxin",@"xiaoliang",@"jiage"]];
//        header.backgroundColor = [UIColor whiteColor];
//        header.delegate = self;
//        [header highlightButtonAtIndex:self.currentIndex];
//        [wrapper addSubview:header];
//
//
//        UIView *priceSelection = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, priceRowHeight)];
//        priceSelection.backgroundColor = [UIColor whiteColor];
//        UIButton *fromLowToHigh = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth * 0.5, priceRowHeight)];
//        [fromLowToHigh setTitle:@"从低到高" forState:UIControlStateNormal];
//        [fromLowToHigh setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
//        [fromLowToHigh.titleLabel setFont:[UIFont fontWithName:kFontFamily size:kFontSmallSize]];
//        [fromLowToHigh addTarget:self action:@selector(orderProductFromLowToHigh:) forControlEvents:UIControlEventTouchUpInside];
//        [fromLowToHigh setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
//        [fromLowToHigh setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
//
//        UIButton *fromHighToLow = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth * 0.5, 0, kScreenWidth * 0.5, priceRowHeight)];
//        [fromHighToLow setTitle:@"从高到低" forState:UIControlStateNormal];
//        [fromHighToLow setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
//        [fromHighToLow.titleLabel setFont:[UIFont fontWithName:kFontFamily size:kFontSmallSize]];
//        [fromHighToLow addTarget:self action:@selector(orderProductFromHighToLow:) forControlEvents:UIControlEventTouchUpInside];
//        [fromHighToLow setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
//        [fromHighToLow setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
//
//        [priceSelection addSubview:fromLowToHigh];
//        [priceSelection addSubview:fromHighToLow];
//
//        switch (self.subIndexOfPriceOrder) {
//            case 1:
//                [fromLowToHigh setSelected:YES];
//                break;
//            case 2:
//                [fromHighToLow setSelected:YES];
//                break;
//            default:
//                [fromLowToHigh setSelected:NO];
//                [fromHighToLow setSelected:NO];
//                break;
//        }
//
//        [wrapper addSubview:priceSelection];
//
//        if (self.headerHeight > 65.0){
//            priceSelection.hidden = NO;
//        }
//        else {
//            priceSelection.hidden = YES;
//        }
//
//        return wrapper;
//    }
//    else {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//        view.backgroundColor = [UIColor redColor];
//        return view;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    //    cell.backgroundColor = COLOR(245, 245, 245, 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    
    __weak UIImageView *_imageView = imageView;
    _imageView.contentMode = UIViewContentModeCenter;
    
    NSString *imageStr = kNullToString([_products[indexPath.row] objectForKey:@"image_url_200"]);
    
    if ([imageStr isEqualToString:@""]) {
        imageStr = kNullToString([_products[indexPath.row] objectForKey:@"smal_image_url"]);
    }
    
    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageStr]]
                      placeholderImage:[UIImage imageNamed:@"default_image"]
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                   _imageView.image = image;
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   
                               }];
    
    [cell.contentView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 12, kScreenWidth - 138, 14)];
    nameLabel.backgroundColor = kClearColor;
    nameLabel.font = [UIFont fontWithName:kFontFamily size:14];
    nameLabel.text = kNullToString([_products[indexPath.row] objectForKey:@"title"]);
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [cell.contentView addSubview:nameLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 30, kScreenWidth - 138, 14)];
    subLabel.backgroundColor = kClearColor;
    subLabel.font = kSmallFont;
    subLabel.text = kNullToString([_products[indexPath.row] objectForKey:@"subtitle"]);
    subLabel.textColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:subLabel];
    
    NSString *price = [NSString stringWithFormat:@"￥%@", kNullToString([_products[indexPath.row] objectForKey:@"price"])];
    
    CGSize priceSize = [price sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
    
    UILabel *nowPrice = [[UILabel alloc] initWithFrame:CGRectMake(128, 50, priceSize.width, 20)];
    nowPrice.backgroundColor = kClearColor;
    nowPrice.textColor = [UIColor orangeColor];
    nowPrice.font = kBigFont;
    nowPrice.text = price;
    
    [cell.contentView addSubview:nowPrice];
    
    NSString *marketPrice = [NSString stringWithFormat:@"￥%@", kNullToString([_products[indexPath.row] objectForKey:@"market_price"])];
    
    float priceFloat = [[_products[indexPath.row] objectForKey:@"price"] floatValue];
    float marketFloat = [[_products[indexPath.row] objectForKey:@"market_price"] floatValue];
    
    if (priceFloat < marketFloat) {
        CGSize size = [marketPrice sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
        
        UILabelWithLine *lastPrice = [[UILabelWithLine alloc] initWithFrame:CGRectMake(5 + nowPrice.frame.origin.x + nowPrice.frame.size.width, 50, size.width, 20)];
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
    
    if ([[_products[indexPath.row] objectForKey:@"inventory_quantity"] integerValue] > 0) {
        soldLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([_products[indexPath.row] objectForKey:@"sales_quantity"])];
    } else {
        soldLabel.text = @"已售完";
        soldLabel.textColor = [UIColor redColor];
    }
    
    [cell.contentView addSubview:soldLabel];
    YunLog(@"_product = %@", _products);
    
//        if ([[_products[indexPath.row] objectForKey:@"inventory_quantity"] integerValue] > 0) {
//            UIButton *cart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 92, 68, 82, 22)];
//            cart.tag = indexPath.row;
//            cart.layer.borderWidth = 1;
//            cart.layer.borderColor = [UIColor orangeColor].CGColor;
//            cart.layer.cornerRadius = 6;
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
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = kNullToString([_products[indexPath.row] objectForKey:@"code"]);
    detail.shopCode = _code;
    
    YunLog(@"detail.shopCode = %@", detail.shopCode);
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.tabController.view.frame.origin.y > 64) {
        CGFloat currentOffsetY = self.tabController.view.frame.origin.y;
        
        if (currentOffsetY < (64 + kScreenWidth * 60 / 320)) {
            [UIView animateWithDuration:0.4 animations:^{
                self.tabController.view.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 49);
            }];
        }
        else {
            [UIView animateWithDuration:0.4 animations:^{
                self.tabController.view.frame = CGRectMake(0, 64 + kScreenWidth * 120 / 320, kScreenWidth, kScreenHeight - 64 - kScreenWidth * 120 / 320 - 49);
            }];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
        && ( scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 3) > 0) {
        [self footerRereshing];
    }
    
    @synchronized(scrollView) {
        [self.view bringSubviewToFront:self.bottomView];
        
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        
        static BOOL needAnimation;
        if ( self.tabController.view.frame.origin.y >= 64 && self.tabController.view.frame.origin.y <= (64 + kScreenWidth * 120 / 320) && translation.y != 0){
            if ([scrollView contentOffset].y > 0 && translation.y > 0){
                needAnimation = YES;
                //[scrollView.panGestureRecognizer setTranslation:CGPointZero inView:scrollView.superview];
                return;
            }
            else {
                CGFloat finnalOriginY = 0;
                if (translation.y > 0) {
                    finnalOriginY = self.tabController.view.frame.origin.y + translation.y >  64 + kScreenWidth * 120 / 320 ? 65 + kScreenWidth * 120 / 320 : self.tabController.view.frame.origin.y + translation.y;
                }
                else {
                    finnalOriginY = self.tabController.view.frame.origin.y + translation.y <  64 ? 63 : self.tabController.view.frame.origin.y + translation.y;
                }
                CGFloat finalHeight = MIN(MAX(kScreenHeight - 49 - finnalOriginY, kScreenHeight - 64 - kScreenWidth * 120 / 320 - 49), kScreenHeight - 64 - 49);
                
                if (needAnimation) {
                    needAnimation = NO;
                    [UIView animateWithDuration:0.2 animations:^{
                        self.tabController.view.frame = CGRectMake(0, finnalOriginY, kScreenWidth, finalHeight);
                    }];
                }
                else {
                    self.tabController.view.frame = CGRectMake(0, finnalOriginY, kScreenWidth, finalHeight);
                }
                
                [scrollView.panGestureRecognizer setTranslation:CGPointZero inView:scrollView.superview];
            }
        }
        else if (self.tabController.view.frame.origin.y > (64 + kScreenWidth * 120 / 320) && translation.y < 0){
            self.tabController.view.frame = CGRectMake(0, (64 + kScreenWidth * 120 / 320), kScreenWidth, kScreenHeight - 64 - 49 -kScreenWidth * 120 / 320);
            [scrollView.panGestureRecognizer setTranslation:CGPointZero inView:scrollView.superview];
        }
        else if (self.tabController.view.frame.origin.y < 64 && translation.y > 0){
            CGFloat finnalOriginY = 0;
            finnalOriginY = self.tabController.view.frame.origin.y + translation.y >  64 + kScreenWidth * 120 / 320 ? 65 + kScreenWidth * 120 / 320 : self.tabController.view.frame.origin.y + translation.y;
            //CGFloat finalHeight = MAX(self.tabController.view.frame.size.height - translation.y - 49, kScreenHeight - 64 - );
            self.tabController.view.frame = CGRectMake(0, finnalOriginY, kScreenWidth, kScreenHeight - 49 - finnalOriginY);
            [scrollView.panGestureRecognizer setTranslation:CGPointZero inView:scrollView.superview];
        }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    switch (alertView.tag) {
    //        case TerminalAlert:
    //            if (buttonIndex == 0) {
    //
    //            }
    //            break;
    //
    //        case WeiXinShareAlert:
    //            if (buttonIndex == 1) {
    //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
    //            }
    //            break;
    //
    //        default:
    //            break;
    //    }
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (id so in actionSheet.subviews) {
        if ([so isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)so;
            button.titleLabel.font = [UIFont fontWithName:kFontBold size:kFontNormalSize];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 微博分享内容
    NSString *title = kNullToString([_shop objectForKey:@"share_title"]);
    NSString *desc = kNullToString([_shop objectForKey:@"share_desc"]);
    NSString *url = kNullToString([_shop objectForKey:@"share_url"]);
    
    NSUInteger titleLength = title.length;
    NSUInteger descLength = desc.length;
    NSUInteger urlLength = url.length;
    
    if (titleLength + descLength + urlLength > 136) {
        desc = [desc substringWithRange:NSMakeRange(0, 136 - titleLength - urlLength)];
    }
    
    NSString *description = [NSString stringWithFormat:@"#%@# %@ %@", title, desc, url];
    
    switch (buttonIndex) {
        case 0:
            //            [Tool shareToWeiBo:_scrollView description:description];
            
            [self isWeiXinInstalled:WXSceneSession];
            
            break;
            
        case 1:
            //            [self isWeiXinInstalled:WXSceneSession];
            
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

#pragma mark - YUNSegmentViewDelegate -

- (void)segmentButtonDidClick:(UIButton *)sender index:(NSInteger)index
{
    [self.tabController setSelectedIndex:index];
}

/**
 价格从低到高排序
 */
- (void)orderProductFromLowToHigh:(UIButton *)sender
{
    self.pageNonce = 1;
    self.subIndexOfPriceOrder = 1;
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    AppDelegate *appDelegate = kAppDelegate;
    NSMutableDictionary *listParams = [NSMutableDictionary dictionaryWithDictionary:@{@"code"                     :   kNullToString(_code),
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
                 
                 UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                 [[tableController tableView] reloadData];
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
    self.subIndexOfPriceOrder = 2;
    
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
                 
                 UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                 [[tableController tableView] reloadData];
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

#pragma mark - DKTTabPageViewControllerDelegate -
- (void)swipeToControllerIndex:(NSInteger)index
{
    if(index == self.currentIndex && index == 3){
        if (self.priceAsc) {
            [self orderProductFromLowToHigh:nil];
        }
        else{
            [self orderProductFromHighToLow:nil];
        }
        return;
    }
    else if (index == self.currentIndex && index != 3) {
        
        return;
    }
    
    if (self.currentIndex == 3 && index != 3) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kJumpOutPriceOrderNotification object:self];
    }
    
    
    self.pageNonce = 1;
    
    self.currentIndex = index;
    
    if (index != 3) {
        self.headerHeight = 64;
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        self.subIndexOfPriceOrder = 0;
    }
    else {
        if (self.priceAsc) {
            [self orderProductFromLowToHigh:nil];
        }
        else{
            [self orderProductFromHighToLow:nil];
        }
        return;
    }
    
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
                 
                 UITableViewController *tableController = (UITableViewController *)[self.tabController selectedViewController];
                 [[tableController tableView] reloadData];
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

@end
