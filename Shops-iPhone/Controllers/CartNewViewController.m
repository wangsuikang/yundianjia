//
//  CartViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "CartNewViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"
#import "AppDelegate.h"

// Views
#import "UIButtonForBarButton.h"

// Controllers
#import "LoginViewController.h"
#import "PayCenterForUserViewController.h"
#import "ProductDetailViewController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"

// Categories
#import "UIImageView+AFNetworking.h"
#import "UIButton+TJButtom.h"

// Libraries
#import "SwipeTableView/SWTableViewCell.h"

#define kSpace 10
#define kSpaceDouble 20

@interface CartNewViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITabBarControllerDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) NSArray *goods;
@property (nonatomic, strong) NSMutableArray *shops;
@property (nonatomic, strong) NSArray *variants;
@property (nonatomic, strong) UILabel *totalMoney;
@property (nonatomic, strong) UILabel *totalCount;
@property (nonatomic, strong) UILabel *nanviTitle;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *empty;

@property (nonatomic, strong) UIButton *goToHomePage;

@property (nonatomic, assign) BOOL isSelectedAllProducts;
@property (nonatomic, assign) BOOL isShopSelectProducts;

/// 去结算时选中的商品
@property (nonatomic, strong) NSMutableArray *paySelectProducts;

/// 底部存放删除和全选按钮的UIView
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign, getter = isPaying) BOOL paying;

/**
 *  是否可编辑
 */
@property (nonatomic, strong) NSMutableArray *canEditArray;

@property (nonatomic, strong) UILabel *sumLabel;

@end

@implementation CartNewViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"购物车";
        
        self.tabBarItem.image = [[UIImage imageNamed:@"cart_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"cart_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        // 添加返回箭头按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 25, 25);
        [backBtn setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        backItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem = backItem;
        
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        
        // 添加中间的导航栏标题
        _nanviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 160) / 2, 0, 160, 40)];
        
        _nanviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        _nanviTitle.backgroundColor = kClearColor;
        _nanviTitle.textColor = kNaviTitleColor;
        _nanviTitle.textAlignment = NSTextAlignmentCenter;
        _nanviTitle.text = @"购物车";
        
        self.navigationItem.titleView = _nanviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self calculateOrderMoney];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
//    self.needToHideBottomBar = NO;
    
    _paySelectProducts = [NSMutableArray array];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin) {
        [self getCartListProducts:NO];
    } else {
        // 当用户进入登陆页面点击了取消按钮的时候，不能在强制要求用户进行登陆
        NSString *isCartNew = [[NSUserDefaults standardUserDefaults] objectForKey:@"isCartNew"];
        if ([isCartNew isEqualToString:@"yes"]) {
            return;
        }
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"需要先登录哟~~" delay:1.5];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isReturnView = YES;
            loginVC.isBuyEnter = YES;
            loginVC.isCartNewEnter = YES;
            
            //        [self.navigationController pushViewController:loginVC animated:YES];
            
            UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            
            [self.navigationController presentViewController:loginNC animated:YES completion:nil];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.needToHideBottomBar) {
        [UIView animateWithDuration:0.8 animations:^{
            CGRect frame = self.tabBarController.tabBar.frame;
            [self.tabBarController.tabBar setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, frame.size.height)];
        }];
    }
    else {
//        self.needToHideBottomBar = YES;
//        CGRect frame = self.tabBarController.tabBar.frame;
//        [self.tabBarController.tabBar setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, frame.size.height)];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSMutableArray *tempShopArray = [NSMutableArray arrayWithCapacity:0];
    tempShopArray = _shops;
    NSMutableArray *paySelectShop = [NSMutableArray array];
    
    for (int i = 0; i< tempShopArray.count; i++) {
        NSDictionary *shopDict = tempShopArray[i];
        NSArray *variantArray = shopDict[@"product_variants"];
        for (int j = 0; j < variantArray.count; j++) {
            for (int z = 0; z < _paySelectProducts.count; z++) {
                NSDictionary *variantDict = variantArray[j];
                NSDictionary *selVariantDict = _paySelectProducts[z];
                if ([[variantDict safeObjectForKey:@"sku_id"] integerValue] == [[selVariantDict safeObjectForKey:@"sku_id"] integerValue]) {
                    [paySelectShop addObject:shopDict];
                }
            }
        }
    }
    
//    NSData *paySelectProductsData = [NSKeyedArchiver archivedDataWithRootObject:_paySelectProducts];
//    [[NSUserDefaults standardUserDefaults] setObject:paySelectProductsData forKey:@"paySelectProducts"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    NSData *paySelectShopsData = [NSKeyedArchiver archivedDataWithRootObject:paySelectShop];
//    [[NSUserDefaults standardUserDefaults] setObject:paySelectShopsData forKey:@"paySelectShops"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 当用户进入登陆页面点击了取消按钮的时候，不能在强制要求用户进行登陆  当用户离开这个页面的时候需要设置这个为no
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isCartNew"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *cartCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"];

    if ([cartCount intValue] == 0) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = cartCount;
    }
    
    [UIView animateWithDuration:0.8 animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        [self.tabBarController.tabBar setFrame:CGRectMake(frame.origin.x, kScreenHeight - frame.size.height, frame.size.width, frame.size.height)];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    _shops = [NSMutableArray arrayWithCapacity:0];
    _variants = [NSArray array];
    
    _isSelectedAllProducts = YES;
    _isShopSelectProducts = YES;
    
//    _canEditArray = [NSMutableArray arrayWithCapacity:0];
    
    // 添加一条顶部的分割线
//    UIView *totalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)];
//    totalView.backgroundColor = kWhiteColor;
//    
//    [self.view addSubview:totalView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, kScreenHeight - 49)
                                              style:UITableViewStyleGrouped];
    
    if (kDeviceOSVersion < 7.0) {
        _tableView.frame = CGRectMake(0, 10, kScreenWidth, kScreenHeight - 49);
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    _tableView.backgroundColor = COLOR(240, 240, 240, 1.0);
    [_tableView setEditing:YES animated:YES];
    _tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_tableView];
    
    // 添加底部控件，存放删除，全选按钮
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48 - 49, kScreenWidth + 2, 48)];
    if (_needToHideBottomBar) {
        _bottomView.frame = CGRectMake(-1, kScreenHeight - 48 , kScreenWidth + 2, 48);
    } else {
        _bottomView.frame = CGRectMake(-1, kScreenHeight - 48 - 49, kScreenWidth + 2, 48);
    }
    
    if (kDeviceOSVersion < 7.0) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2 - 49, 48)];
    }
    
    _bottomView.backgroundColor = [UIColor whiteColor];
//    _bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
//    _bottomView.layer.borderWidth = 1;
//    _bottomView.clipsToBounds = NO;
    
    [self.view addSubview:_bottomView];
    
    NSArray *arrayTemp = @[@"全选", @"", @"去结算"];
    
    // 添加全选和删除按钮
    for (int i = 0; i < arrayTemp.count; i++)
    {
        UIButton *btnSelectedAndClear = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnSelectedAndClear setTitle:arrayTemp[i] forState:UIControlStateNormal];
        [btnSelectedAndClear setTitleColor:kGrayFontColor forState:UIControlStateNormal];
        btnSelectedAndClear.backgroundColor = [UIColor whiteColor];
        
        if (i == 0) {
            btnSelectedAndClear.frame = CGRectMake(0, 0, 50, 48);
            btnSelectedAndClear.titleLabel.font = kMidFont;
            [btnSelectedAndClear addTarget:self action:@selector(selectAllProducts:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if (i == 1) {
            UILabel *sumLabel = [[UILabel alloc] init];
            sumLabel.frame = CGRectMake(50, 0, 200, 48);
            sumLabel.text = arrayTemp[i];
            sumLabel.font = kMidFont;
            sumLabel.textColor = kGrayFontColor;
            
            [_bottomView addSubview:sumLabel];
//            [btnSelectedAndClear addTarget:self action:@selector(deleteSelectedGood:) forControlEvents:UIControlEventTouchUpInside];
            _sumLabel = sumLabel;
        }
        if (i == 2) {
            btnSelectedAndClear.backgroundColor = kOrangeColor;
            [btnSelectedAndClear setTitleColor:kWhiteColor forState:UIControlStateNormal];
            btnSelectedAndClear.frame = CGRectMake(kScreenWidth - 100, 0, 100, 48);
            btnSelectedAndClear.titleLabel.font = kNormalFont;
            [btnSelectedAndClear addTarget:self action:@selector(goToPay) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_bottomView addSubview:btnSelectedAndClear];
    }
    
    [self calculateOrderMoney];
}

- (void)dealloc
{
    if (_hud) {
        [_hud hide:YES];
    }

}

#pragma mark - NavigationBar ItemClick -

// 响应按钮点击方法
- (void)itemBtnClick:(UIBarButtonItem *)item
{
    if([item.title isEqualToString:@"编辑"])
    {
        [self.tableView setEditing:YES animated:YES];
        item.title = @"完成";
        
        //        _isSelectedAllProducts = YES;
    }
    else if([item.title isEqualToString:@"完成"])
    {
        [self.tableView setEditing:NO animated:YES];
        item.title = @"编辑";
        
        _isSelectedAllProducts = YES;
        
        for (int i = 0; i< _shops.count; i++) {
            NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
            /// 全部勾选
            for (int j = 0; j < variantsArray.count; j++) {
                [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES];
            }
        }
    }
}

// 响应按钮点击方法
- (void)editBtnClick:(UIButton *)item
{
    [_canEditArray replaceObjectAtIndex:item.tag - 10 withObject:(![_canEditArray[item.tag - 10] boolValue]) ? @"YES" : @"NO"];
    if([item.titleLabel.text isEqualToString:@"编辑"])
    {
        [item setTitle:@"完成" forState:UIControlStateNormal];
        
        //        _isSelectedAllProducts = YES;
    } else if([item.titleLabel.text isEqualToString:@"完成"])
    {
        [item setTitle:@"编辑" forState:UIControlStateNormal];
        
//        _isSelectedAllProducts = YES;
//        
//        for (int i = 0; i < _goods.count; i++) {
//            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[i]];
//            
//            [temp setObject:@"no" forKey:CartManagerSelectedKey];
//            
//            [[CartManager defaultCart] updateProduct:temp atIndex:i];
//            [self updateGoods];
//        }
    }
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:item.tag - 10] withRowAnimation:UITableViewRowAnimationFade];
}

/**
 返回到首页
 */
- (void)backToPrev
{
    [_empty removeFromSuperview];
    _empty = nil;
    
    if (_isTabbarEnter) {
        self.tabBarController.selectedIndex = 0;

        AppDelegate *appDelegate = kAppDelegate;

        appDelegate.lastSelectedTabIndex = 0;
    } else {
         [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 返回到首页
 */
- (void)backHomePage
{
    [_empty removeFromSuperview];
    _empty = nil;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (self.tabBarController.selectedIndex == 0 && !_isTabbarEnter) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.tabBarController.selectedIndex = 0;
        
        appDelegate.lastSelectedTabIndex = 0;
    }
}

- (void)deleteSelectedGood:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"清空购物车...";
    
    NSDictionary *params = @{@"user_session_key"       :      kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *deleteCartURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartClearURL params:params];
    
    YunLog(@"deleteCartURL = %@", deleteCartURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager DELETE:deleteCartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"dele res = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            
            [self getCartListProducts:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@",error);
        
        [_hud hide:YES];
    }];
    
}

- (void)selectAllProducts:(UIButton *)leftBtn
{
    //    if (_tableView.editing == NO) {
    //        return;
    //    } else {
    [_tableView setEditing:YES animated:YES];
    
    [_tableView reloadData];
    
    for (int i = 0; i < _canEditArray.count; i++) {
        [_canEditArray replaceObjectAtIndex:i withObject:@"YES"];
    }
    
    if ([_deleteItem.title isEqualToString:@"编辑"]) {
        _deleteItem.title = @"完成";
    }
    
    if (_isSelectedAllProducts) { // 点击一次全部选中
        _isSelectedAllProducts = NO;
        _isShopSelectProducts = NO;
        
        /// 先清空原来里面的商品数据
        [_paySelectProducts removeAllObjects];
        
        for (int i = 0; i< _shops.count; i++) {
            NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
            /// 全部勾选
            for (int j = 0; j < variantsArray.count; j++) {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
                
                [_paySelectProducts addObject:variantsArray[j]];
            }
        }
        // 打印输出所有结算商品
        YunLog(@"去结算商品选中 = %@", _paySelectProducts);
    } else { // 再次点击全部取消选中
        _isSelectedAllProducts = YES;
        _isShopSelectProducts = YES;
        
        for (int i = 0; i< _shops.count; i++) {
            NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
            /// 全部取消勾选
            for (int j = 0; j < variantsArray.count; j++) {
                [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES];
                
                /// 将去结算的商品里面清空
                [_paySelectProducts removeAllObjects];
            }
        }
        // 打印输出所有结算商品
        YunLog(@"去结算商品全部取消 = %@", _paySelectProducts);
    }
    //    }
    
    [self calculateOrderMoney];
}

#pragma mark - Private Functions -

// 创建空得背景
- (void)createEmpty
{
    if (!_empty) {
        _empty = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 140) / 2, (kScreenHeight - 164) / 2, 140, 164)];
        
        _empty.userInteractionEnabled = YES;
        
        if (kDeviceOSVersion < 7.0) {
            _empty.frame = CGRectMake((kScreenWidth - 140) / 2, (kScreenHeight - 164) / 2 - 64, 140, 164);
        }
        
        _empty.image = [UIImage imageNamed:@"cart_empty"];
        
        [self.view addSubview:_empty];
        
        _goToHomePage = [UIButton buttonWithType:UIButtonTypeCustom];
        _goToHomePage.frame = CGRectMake(0, _empty.frame.size.height - 30, _empty.frame.size.width, 30);
        [_goToHomePage addTarget:self action:@selector(backHomePage) forControlEvents:UIControlEventTouchUpInside];
        
        [_empty addSubview:_goToHomePage];
    }
}

// 获取购物车列表信息

- (void)getCartListProducts:(BOOL)isSunOfAdd
{
    AppDelegate *appDelegate = kAppDelegate;
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    if (!isSunOfAdd) {
        _hud.labelText = @"努力加载中...";
        //        [_shops removeAllObjects];
        //        [_paySelectProducts removeAllObjects];
    }
    
    NSDictionary *params = @{@"user_session_key"     :     kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *cartProductsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartListURL params:params];
    
    YunLog(@"cartProductsListURL = %@", cartProductsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:cartProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"cartCount = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        NSInteger cartCount = 0;
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            _shops = [[responseObject objectForKey:@"data"] objectForKey:@"shops"];
            
            NSMutableArray *tempArray = [NSMutableArray array];
            
//            if (!_canEditArray) {
                for (int i = 0; i < _shops.count; i++) {
                    [tempArray addObject:@"YES"];
                }
                _canEditArray = [NSMutableArray arrayWithArray:tempArray];
//            }
            
            
            /// 获取全部的购物车数量
            for (int i = 0; i< _shops.count; i++) {
                NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
                for (NSDictionary *variantDict in variantsArray) {
                    int variantCount = [[variantDict safeObjectForKey:@"quantity"] intValue];
                    cartCount += variantCount;
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", cartCount] forKey:@"cartCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updateBadgeValue:[NSString stringWithFormat:@"%ld", cartCount]];
            [self changeView:cartCount];
            
            // 添加右边的编辑按钮
            if (cartCount > 0 && _deleteItem == nil) {
//                _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(itemBtnClick:)];
//                [_deleteItem setTintColor:[UIColor orangeColor]];
//                [_tableView setEditing:YES animated:YES];
//                
//                self.navigationItem.rightBarButtonItem = _deleteItem;
//                
//                                /// 全部勾选   暂时不要
//                                for (int i = 0; i< _shops.count; i++) {
//                                    NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
//                
//                                    for (int j = 0; j < variantsArray.count; j++) {
//                                        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]
//                                                                animated:YES
//                                                          scrollPosition:UITableViewScrollPositionNone];
//                                    }
//                                }
            }
            
            [_tableView reloadData];
        } else {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        
        [_hud hide:YES];
    }];
}

- (void)getCartListProducts:(BOOL)isSunOfAdd isNeedRefresh:(BOOL)isNeedRefresh
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (isNeedRefresh) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    if (!isSunOfAdd) {
        _hud.labelText = @"努力加载中...";
        //        [_shops removeAllObjects];
        //        [_paySelectProducts removeAllObjects];
    }
    
    NSDictionary *params = @{@"user_session_key"     :     kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *cartProductsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartListURL params:params];
    
    YunLog(@"cartProductsListURL = %@", cartProductsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:cartProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"cartCount = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        NSInteger cartCount = 0;
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            _shops = [[responseObject objectForKey:@"data"] objectForKey:@"shops"];
            
            NSMutableArray *tempArray = [NSMutableArray array];
            
            if (isNeedRefresh) {
                for (int i = 0; i < _shops.count; i++) {
                    [tempArray addObject:@"YES"];
                }
                _canEditArray = [NSMutableArray arrayWithArray:tempArray];
            }
        
            /// 获取全部的购物车数量
            for (int i = 0; i< _shops.count; i++) {
                NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
                for (NSDictionary *variantDict in variantsArray) {
                    int variantCount = [[variantDict safeObjectForKey:@"quantity"] intValue];
                    cartCount += variantCount;
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", cartCount] forKey:@"cartCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updateBadgeValue:[NSString stringWithFormat:@"%ld", cartCount]];
            [self changeView:cartCount];
            
            // 添加右边的编辑按钮
            if (cartCount > 0 && _deleteItem == nil) {
                //                _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(itemBtnClick:)];
                //                [_deleteItem setTintColor:[UIColor orangeColor]];
                //                [_tableView setEditing:YES animated:YES];
                //
                //                self.navigationItem.rightBarButtonItem = _deleteItem;
                //
                //                                /// 全部勾选   暂时不要
                //                                for (int i = 0; i< _shops.count; i++) {
                //                                    NSArray *variantsArray = [_shops[i] objectForKey:@"product_variants"];
                //
                //                                    for (int j = 0; j < variantsArray.count; j++) {
                //                                        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]
                //                                                                animated:YES
                //                                                          scrollPosition:UITableViewScrollPositionNone];
                //                                    }
                //                                }
            }
            
            if (isNeedRefresh) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
            
        } else {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        
        [_hud hide:YES];
    }];
}

- (void)changeView:(NSInteger)cartCount
{
    if (cartCount <= 0) {
        _tableView.hidden = YES;
        _bottomView.hidden = YES;
        
        //        _nanviTitle.text = @"购物车";
        if (_deleteItem) {
            _deleteItem = nil;
            
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        if (!_empty) {
            [self createEmpty];
        } else {
            _empty.hidden = NO;
            _goToHomePage.enabled = NO;
            _goToHomePage.hidden = NO;
        }
        
    } else {
        _tableView.hidden = NO;
        _bottomView.hidden = NO;
        
        _empty.hidden = YES;
        _goToHomePage.enabled = YES;
        _goToHomePage.hidden = YES;
        //        self.tabBarController.tabBar.hidden = YES;
        
        //        _nanviTitle.text = [NSString stringWithFormat:@"合计: %.2f", [[CartManager defaultCart] selectedAllMoney]];
    }
}

- (void)updateGoods
{
    _goods = nil;
    _goods = [[CartManager defaultCart] allProducts];
    
    YunLog(@"_goods = %@", _goods);
    
    //    _nanviTitle.text = [NSString stringWithFormat:@"合计:%.2f", [[CartManager defaultCart] selectedAllMoney]];
}

- (void)goToPay
{
    if (_shops.count == 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"购物车空空如也" delay:2.0];
        
        return;
    }
    
    NSArray *selectedRows = [_tableView indexPathsForSelectedRows];
    if (selectedRows.count <= 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请选择结算的商品" delay:2.0];
        return;
    }
    
    //    NSArray *allSelectProducts = [[CartManager defaultCart] allSelectedProducts];
    if (_paySelectProducts.count <= 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请选择结算的商品" delay:2.0];
        return;
    }
    
    _paying = YES;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin) {
        if (_paySelectProducts.count > 0) {
            _paying = NO;
            
            /// 计算出所有去结算的商品属于的店铺（但是这里的店铺是没有经过处理的，店铺里面传过去的包含加入购物车里面的该店铺下的所有商品）
            NSMutableArray *tempShopArray = [NSMutableArray arrayWithCapacity:0];
            tempShopArray = _shops;
            NSMutableArray *paySelectShop = [NSMutableArray array];
            YunLog(@"first payselectProducts = %@", _paySelectProducts);
            for (int i = 0; i< tempShopArray.count; i++) {
                NSDictionary *shopDict = tempShopArray[i];
                NSArray *variantArray = shopDict[@"product_variants"];
                NSInteger addCount = 0;
                for (int j = 0; j < variantArray.count; j++) {
                    for (int z = 0; z < _paySelectProducts.count; z++) {
                        NSDictionary *variantDict = variantArray[j];
                        NSDictionary *selVariantDict = _paySelectProducts[z];
                        if ([[variantDict safeObjectForKey:@"sku_id"] integerValue] == [[selVariantDict safeObjectForKey:@"sku_id"] integerValue]) {
                            if (addCount == 0) {
                                [paySelectShop addObject:shopDict];
                                
                                addCount++;
                            }
                        }
                    }
                }
                YunLog(@"----------^^^^^^^^^_____-%ld", addCount);
            }
            YunLog(@"two payselectProducts = %@ ", _paySelectProducts);
            
            PayCenterForUserViewController *pay = [[PayCenterForUserViewController alloc] init];
            pay.allSelectProducts = _paySelectProducts;
            pay.paySelectShops = paySelectShop;
            
            UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
            
            [self.navigationController presentViewController:payNC animated:YES completion:nil];
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"请选择结算的商品" delay:2.0];
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

/**
 商品减少
 
 @param sender 点击的按钮
 */
- (void)minusCount:(EnterButton *)sender
{
    [_canEditArray replaceObjectAtIndex:sender.cartIndexPatch.section withObject:@"NO"];
    NSDictionary *shopDictionary = _shops[sender.cartIndexPatch.section];
    NSDictionary *varinatDictionary = [shopDictionary objectForKey:@"product_variants"][sender.cartIndexPatch.row];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:sender.cartIndexPatch];
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:sender.tag + 2];
    
    NSInteger count = [textField.text integerValue];
    NSString *numberCount = [NSString stringWithFormat:@"%ld", (count - 1)];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSArray *jsonData = @[@{@"pv_id"    :     kNullToString([varinatDictionary objectForKey:@"sku_id"]),
                            @"number"   :     kNullToString(numberCount)}];
    
    YunLog(@"json_data: %@",jsonData);
    
    /// 这里是嵌套了两层字典
    NSDictionary *params = @{@"user_session_key"        :     kNullToString(appDelegate.user.userSessionKey),
                             @"json_data"               :     jsonData};
    
    NSString *changeCartNumURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartChangeNumURL params:nil];
    
    YunLog(@"changeCartURL = %@", changeCartNumURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:changeCartNumURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject Count = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            NSDictionary *line_item = [[[responseObject objectForKey:@"data"] objectForKey:@"line_items"] firstObject];
            NSString *quantityString = [NSString stringWithFormat:@"%@", [line_item objectForKey:@"quantity"]];
            NSString *message = [line_item objectForKey:@"message"];
            // 这里的quantity时number类型的数据
            if (message.length > 0) {
                textField.text = @"0";
                sender.enabled = NO;
                
                NSInteger cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", cartCount - 1] forKey:@"cartCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                textField.text = quantityString;
                
                NSInteger cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", cartCount - 1] forKey:@"cartCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            NSInteger min_count = [[line_item objectForKey:@"minimum_quantity"] integerValue];
            if (count == min_count) {
                sender.enabled = NO;
            }
            
            UIButton *plutButton = (UIButton *)[cell.contentView viewWithTag:sender.tag + 1];
            plutButton.enabled = YES;
            [self getCartListProducts:YES isNeedRefresh:NO];
            
//            [self calculateOrderMoney];
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
        }
        
        [_hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"changer error = %@", error);
    }];
}

/**
 商品增加
 
 @param sender 被点击按钮
 */
- (void)plusCount:(EnterButton *)sender
{
    [_canEditArray replaceObjectAtIndex:sender.cartIndexPatch.section withObject:@"NO"];
    NSDictionary *shopDictionary = _shops[sender.cartIndexPatch.section];
    NSDictionary *varinatDictionary = [shopDictionary objectForKey:@"product_variants"][sender.cartIndexPatch.row];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:sender.cartIndexPatch];
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:sender.tag + 1];
    
    NSInteger count = [textField.text integerValue];
    NSString *numberCount = [NSString stringWithFormat:@"%ld", (count + 1)];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSArray *jsonData = @[@{@"pv_id"    :     kNullToString([varinatDictionary objectForKey:@"sku_id"]),
                            @"number"   :     kNullToString(numberCount)}];
    
    YunLog(@"json_data: %@",jsonData);
    
    /// 这里是嵌套了两层字典
    NSDictionary *params = @{@"user_session_key"        :     kNullToString(appDelegate.user.userSessionKey),
                             @"json_data"               :     jsonData};
    
    NSString *changeCartNumURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartChangeNumURL params:nil];
    
    YunLog(@"changeCartURL = %@", changeCartNumURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:changeCartNumURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject Count22 = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            NSDictionary *line_item = [[[responseObject objectForKey:@"data"] objectForKey:@"line_items"] firstObject];
            NSString *quantityString = [NSString stringWithFormat:@"%@", [line_item objectForKey:@"quantity"]];
            NSInteger linitedString = [[line_item objectForKey:@"limited_quantity"] integerValue];
            NSInteger lim_count = [[line_item objectForKey:@"limited_quantity"] integerValue];
            //            NSString *inventoryQuantity = [line_item objectForKey:@"inventory_quantity"];
            NSInteger inventoryCount = [[line_item objectForKey:@"inventory_quantity"] integerValue];
            
            if (linitedString == 0) { // 不限购，只需要判断库存量就OK
                textField.text = quantityString;
                
                NSInteger cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)cartCount + 1] forKey:@"cartCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (count == inventoryCount) {
                    sender.enabled = NO;
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [_hud addSuccessString:@"亲、库存有限哦..." delay:1.5];
                } else {
                    [self getCartListProducts:YES isNeedRefresh:NO];
                }
            } else { /// 限购 需要判断库存量和限购量
                textField.text = quantityString;
                NSInteger cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)cartCount + 1] forKey:@"cartCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (count == inventoryCount) {
                    sender.enabled = NO;
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [_hud addSuccessString:@"亲、库存有限哦..." delay:1.5];
                }
                
                if (count == lim_count) {
                    sender.enabled = NO;
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [_hud addSuccessString:[NSString stringWithFormat:@"本商品限购%ld件哟",(long)lim_count] delay:1.5];
                }
//                [self getCartListProducts:YES];
            }
           
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *minusButton = (UIButton *)[cell.contentView viewWithTag:sender.tag - 1];
                minusButton.enabled = YES;
            });
            [self calculateOrderMoney];
            
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
        }
        
        [_hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"changer error = %@", error);
    }];
}

- (void)updateViewAtIndex:(NSInteger)index count:(NSInteger)count
{
    NSDictionary *product = [_goods objectAtIndex:index];
    YunLog("product = %@", product);
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:product];
    
    [temp removeObjectForKey:CartManagerCountKey];
    [temp setObject:[NSString stringWithFormat:@"%lu", (unsigned long)count] forKey:CartManagerCountKey];
    
    [[CartManager defaultCart] updateProduct:temp atIndex:index];
    
    //    [self updateBadgeValue];
    
    [self updateGoods];
}

- (void)updateBadgeValue:(NSString *)cartCount
{
    if ([cartCount isEqualToString:@"0"]) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = cartCount;
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _shops.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *variants = [_shops[section] objectForKey:@"product_variants"];
    
    return variants.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *shopDictionary = _shops[indexPath.section];
    NSDictionary *varinatDictionary = [shopDictionary objectForKey:@"product_variants"][indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"tableView:tableView];
//        cell.rightUtilityButtons = [self rightButtons];
//        cell.delegate = self;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [UIColor whiteColor];
    
//    [self.tableView setEditing:YES animated:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 80)]; // 宽高  80
    //    leftImage.backgroundColor = [UIColor redColor];
    imageView.backgroundColor = kClearColor;
    imageView.contentMode = UIViewContentModeCenter;
    
    __weak UIImageView *weakImageView = imageView;
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([varinatDictionary objectForKey:@"image_url_200"])]]
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  weakImageView.image = image;
                                  weakImageView.contentMode = UIViewContentModeScaleAspectFit;
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  [weakImageView setImageWithURL:[NSURL URLWithString:kNullToString([varinatDictionary objectForKey:@"image_url_270"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                  weakImageView.contentMode = UIViewContentModeScaleAspectFit;
                              }];
    
    [cell.contentView addSubview:imageView];
    
    // 添加空白的点击按钮实现 点击图片进入商品详情
    EnterButton *enterProduct  = [[EnterButton alloc] initWithFrame:CGRectMake(kSpace, kSpace, 100, 90)];
    enterProduct.productCode = [varinatDictionary objectForKey:@"product_code"];
    enterProduct.shopCode = [shopDictionary objectForKey:@"code"];
    enterProduct.backgroundColor = kClearColor;
    [enterProduct addTarget:self action:@selector(enterProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:enterProduct];
    
    int height = 10;
    
    NSString *description = kNullToString([varinatDictionary objectForKey:@"product_name"]);
    
    //    CGSize size = [description sizeWithFont:[UIFont fontWithName:kFontFamily size:14]
    //                                       size:CGSizeMake(152, 9999)];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, height, kScreenWidth - 115 - 20, 20)];
    descriptionLabel.backgroundColor = kClearColor;
    descriptionLabel.font = kSmallFont;
    descriptionLabel.text = [NSString stringWithFormat:@"%@", description];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [cell.contentView addSubview:descriptionLabel];
    
    // 添加空白的点击按钮实现 点击商品标题进入商品详情
    EnterButton *enterTitleBtn = [[EnterButton alloc] initWithFrame:CGRectMake(115, height, kScreenWidth - 115, 20)];
    //    [enterTitleBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    enterTitleBtn.productCode = [varinatDictionary objectForKey:@"product_code"];
    enterTitleBtn.shopCode = [shopDictionary objectForKey:@"code"];
    [enterTitleBtn addTarget:self action:@selector(enterProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:enterTitleBtn];
    
    NSString *subtitle = kNullToString([varinatDictionary objectForKey:@"product_variant_name"]);
    
    //    CGSize subSize = [subtitle sizeWithFont:kSmallFont size:CGSizeMake(152, 9999)];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, CGRectGetMaxY(descriptionLabel.frame), kScreenWidth - 115 - 10, 20)];
    subtitleLabel.backgroundColor = kClearColor;
    subtitleLabel.textColor = [UIColor lightGrayColor];
    subtitleLabel.font = kSmallMoreSizeFont;
    //    subtitleLabel.numberOfLines = 0;
    subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subtitleLabel.text = [NSString stringWithFormat:@"%@", subtitle];
    
    [cell.contentView addSubview:subtitleLabel];
    
    //    height += (size.height + subSize.height > 34 ? size.height + subSize.height : 34) + 5;
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(descriptionLabel.frame), CGRectGetMaxY(imageView.frame) - 30, 150, 30)];
    price.backgroundColor = kClearColor;
    price.textColor = [UIColor orangeColor];
    price.font = kNormalFont;
    price.text = [NSString stringWithFormat:@"￥ %@", kNullToString([varinatDictionary objectForKey:@"price"])];
    
    [cell.contentView addSubview:price];
    
    // 加按钮
    EnterButton *plusCount = (EnterButton *)[cell.contentView viewWithTag:indexPath.section * 100 + indexPath.row + 2];
    
    plusCount = [[EnterButton alloc] initWithFrame:CGRectMake(kScreenWidth - 30 - 20 - 40, CGRectGetMaxY(imageView.frame) - 30, 30, 30)];
//    [plusCount setImage:[UIImage imageNamed:@"plus_enabled"] forState:UIControlStateNormal];
//    [plusCount setImage:[UIImage imageNamed:@"plus_disabled"] forState:UIControlStateDisabled];
    plusCount.layer.borderColor = kGrayColor.CGColor;
    plusCount.layer.borderWidth = 1;
    [plusCount setTitleColor:kGrayFontColor forState:UIControlStateNormal];
    plusCount.backgroundColor = kBackgroundColor;
    [plusCount setTitle:@"+" forState:UIControlStateNormal];
    
    [plusCount setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
    [plusCount addTarget:self action:@selector(plusCount:) forControlEvents:UIControlEventTouchUpInside];
    plusCount.tag = indexPath.section * 100 + indexPath.row + 2;
    plusCount.cartIndexPatch = indexPath;
    
    [cell.contentView addSubview:plusCount];
    
    if ([[varinatDictionary objectForKey:@"quantity"] intValue] == [[varinatDictionary objectForKey:@"limited_quantity"] integerValue]) {
        plusCount.enabled = NO;
    }
    
    // 数量
    UILabel *showCount = (UILabel *)[cell.contentView viewWithTag:indexPath.section * 100 + indexPath.row + 3];
    
    showCount = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(plusCount.frame) - 30, CGRectGetMinY(plusCount.frame), 30, 30)];
    showCount.backgroundColor = kClearColor;
    showCount.font = kNormalFont;
    showCount.textAlignment = NSTextAlignmentCenter;
    showCount.tag = indexPath.section * 100 + indexPath.row + 3;
    showCount.textColor = kGrayFontColor;
    showCount.backgroundColor = COLOR(232, 238, 241, 1.0);
    
    [cell.contentView addSubview:showCount];
    
    // 减按钮
    EnterButton *minusCount = (EnterButton *)[cell.contentView viewWithTag:indexPath.section * 100 + indexPath.row + 1];

    minusCount = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(showCount.frame) - 30, CGRectGetMinY(plusCount.frame), 30, 30)];
    minusCount.layer.borderColor = kGrayColor.CGColor;
    minusCount.layer.borderWidth = 1;
    [minusCount setTitleColor:kGrayFontColor forState:UIControlStateNormal];
    minusCount.backgroundColor = kBackgroundColor;
    
    [minusCount setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
    [minusCount addTarget:self action:@selector(minusCount:) forControlEvents:UIControlEventTouchUpInside];
    [minusCount setTitle:@"-" forState:UIControlStateNormal];
    
    minusCount.tag = indexPath.section * 100 + indexPath.row + 1;
    minusCount.cartIndexPatch = indexPath;
    
    [cell.contentView addSubview:minusCount];
    
    if ([[varinatDictionary objectForKey:@"quantity"] intValue] <= [[varinatDictionary objectForKey:@"minimum_quantity"] integerValue]) {
        minusCount.enabled = NO;
    }
    
    // 删除按钮
    EnterButton *deleteButton = [EnterButton buttonWithType:UIButtonTypeCustom];
    deleteButton.cartIndexPatch = indexPath;
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    deleteButton.titleLabel.font = kMidFont;
    [deleteButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    deleteButton.backgroundColor = COLOR(117, 117, 117, 1.0);
    deleteButton.frame = CGRectMake(kScreenWidth, 0.5, 0, 110 - 0.5);
    [deleteButton addTarget:self action:@selector(deleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:deleteButton];
    
    if (_canEditArray.count > 0 && _canEditArray != nil) {
        if (![_canEditArray[indexPath.section] boolValue]) {
            price.hidden = YES;
            minusCount.hidden = NO;
            minusCount.enabled = YES;
            plusCount.hidden = NO;
            plusCount.enabled = YES;
            showCount.text = [NSString stringWithFormat:@"%@", kNullToString([varinatDictionary objectForKey:@"quantity"])];
            showCount.layer.borderColor = kGrayColor.CGColor;
            showCount.layer.borderWidth = 1;
            showCount.backgroundColor = COLOR(232, 238, 241, 1.0);
            
//            [UIView animateWithDuration:0.5 animations:^{
                CGRect frame = deleteButton.frame;
                frame.size.width = 45;
                frame.origin.x = kScreenWidth - 45;
                deleteButton.frame = frame;
//            }];
            
        } else {
            price.hidden = NO;
            minusCount.hidden = YES;
            minusCount.enabled = NO;
            plusCount.hidden = YES;
            plusCount.enabled = NO;
            showCount.text = [NSString stringWithFormat:@"x%@", kNullToString([varinatDictionary objectForKey:@"quantity"])];
            showCount.backgroundColor = [UIColor whiteColor];
            
//            [UIView animateWithDuration:0.5 animations:^{
                CGRect frame = deleteButton.frame;
                frame.size.width = 0;
                frame.origin.x = kScreenWidth;
                deleteButton.frame = frame;
//            }];
        }
    }
    
    return cell;
}

/// 头部View
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *shopDictionary = _shops[section];
    
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
    headerView.contentView.backgroundColor = kWhiteColor;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    view.backgroundColor = kWhiteColor;
    
    [headerView.contentView addSubview:view];
    
    // 标题
    UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth / 2, 44)];
    shopName.text = [shopDictionary objectForKey:@"name"];
    shopName.textColor = kGrayFontColor;
    shopName.font = kMidSizeFont;
    
    [view addSubview:shopName];
    
    // 点击店铺标题跳转到店铺首页
    // 标题
    EnterButton *enterShop = [[EnterButton alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth / 2, 44)];
    [enterShop addTarget:self action:@selector(enterShopBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    enterShop.shopCode = [shopDictionary objectForKey:@"code"];
    enterShop.backgroundColor = kClearColor;
    
    [view addSubview:enterShop];
    
    // 编辑按钮
    EnterButton *allSelectBtn = [[EnterButton alloc] initWithFrame:CGRectMake(kScreenWidth - 50, 0, 40, 44)];
    if ([_canEditArray[section] boolValue]) {
        [allSelectBtn setTitle:@"编辑" forState:UIControlStateNormal];
    } else {
        [allSelectBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    [allSelectBtn setTitleColor:kBlackColor forState:UIControlStateNormal];
    allSelectBtn.titleLabel.font = kMidSizeFont;
    allSelectBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    allSelectBtn.tag = section + 10;
    [allSelectBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:allSelectBtn];
    
    return headerView;
}

// 底部View
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //    static NSString *footerIdenty = @"footer";
    
    NSDictionary *shopDictionary = _shops[section];
    NSArray *promotion = [NSArray array];
    promotion = [shopDictionary objectForKey:@"promotion"];
    
    UITableViewHeaderFooterView * footerView = [[UITableViewHeaderFooterView alloc] init];
    footerView.contentView.backgroundColor = kOrangeColor;
    
    CGFloat footerHeight = 0;
    NSString *promotionString;
    if (promotion.count > 0) {
        footerHeight = 30;
        
        for (int i = 0; i < promotion.count; i++) {
            promotionString = [NSString stringWithFormat:@"%@  %@", kNullToString(promotionString), kNullToString(promotion[i])];
        }
    } else {
        footerHeight = 10;
        footerView.backgroundColor = kClearColor;
        footerView.contentView.backgroundColor = kClearColor;
    }
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, footerHeight)];
    bottomView.backgroundColor = kClearColor;
    
    [footerView.contentView addSubview:bottomView];
    
    // 优惠信息
    if (promotion.count > 0) {
        UILabel *promotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, footerHeight)];
        promotionLabel.textColor = [UIColor redColor];
        
        promotionLabel.text = [NSString stringWithFormat:@"优惠: %@", promotionString];
        promotionLabel.font = kMidSizeFont;
        
        [bottomView addSubview:promotionLabel];
        
        /// 顶部的一条直线
//        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, kScreenWidth, kLineHeight)];
//        topLineView.backgroundColor = [UIColor lightGrayColor];
//        
//        [bottomView addSubview:topLineView];
    }
    
    /// 底部直线  分割线
//    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, footerHeight - 1, kScreenWidth, kLineHeight)];
//    bottomLineView.backgroundColor = [UIColor lightGrayColor];
//    
//    [bottomView addSubview:bottomLineView];
    
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSDictionary *shopDictionary = _shops[section];
    NSArray *promotion = [NSArray array];
    promotion = [shopDictionary objectForKey:@"promotion"];
    
    CGFloat footerHeight = 0;
    
    if (promotion.count > 0) {
        footerHeight = 30;
    } else {
        footerHeight = 10;
    }
    return footerHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YunLog(@"indexPath.row = %ld", (long)indexPath.row);
    
    NSArray *variantsArray = [_shops[indexPath.section] objectForKey:@"product_variants"];
    
    NSDictionary *variantsDict = variantsArray[indexPath.row];
    
    [_paySelectProducts addObject:variantsDict];

    YunLog(@"_paySelectProducts = %@", _paySelectProducts);
    
    [self calculateOrderMoney];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YunLog(@"indexPath.row = %ld", (long)indexPath.row);
    NSArray *variantsArray = [_shops[indexPath.section] objectForKey:@"product_variants"];
    
    NSDictionary *variantsDict = variantsArray[indexPath.row];
    
    for (int i = 0; i < _paySelectProducts.count; i++) {
        NSDictionary *dict = _paySelectProducts[i];
        if ([[dict objectForKey:@"sku_id"] integerValue] == [[variantsDict objectForKey:@"sku_id"] integerValue]) {
            [_paySelectProducts removeObjectAtIndex:i];
            [self calculateOrderMoney];
            return;
        }
    }
}

// 返回每个cell，对应的操作风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleDelete;//默认删除风格
    
    return result;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{//设置是否显示一个可编辑视图的视图控制器。
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];//切换接收者的进入和退出编辑模式。
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *appDelegate = kAppDelegate;
        
        NSMutableArray *variantsArray = [_shops[indexPath.section] objectForKey:@"product_variants"];
        NSDictionary *variantsDict = variantsArray[indexPath.row];
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"正在删除中...";
        
        NSDictionary *params = @{@"user_session_key"       :      kNullToString(appDelegate.user.userSessionKey),
                                 @"ids"                    :      kNullToString([variantsDict objectForKey:@"sku_id"])};
        
        NSString *deleteCartURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartListURL params:params];
        
        YunLog(@"deleteCartURL = %@", deleteCartURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager DELETE:deleteCartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"dele res = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            
            if ([code isEqualToString:kSuccessCode]) {
                [_hud hide:YES];
                if (variantsArray.count == 1) {
                    [_canEditArray removeObjectAtIndex:indexPath.section];
                }
                [self getCartListProducts:NO];
            } else {
                [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"error = %@",error);
            
            [_hud hide:YES];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_canEditArray[indexPath.section] boolValue]) {
        return YES;
    }
    return NO;
}


//- (void)tableView:(UITableView *)tableView  :(NSIndexPath *)indexPath
//{
//    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[indexPath.row]];
//
//    [temp setObject:@"no" forKey:CartManagerSelectedKey];
//
//    [[CartManager defaultCart] updateProduct:temp atIndex:indexPath.row];
//
//    [self updateGoods];
//}

#pragma mark - Select All Products -

- (void)shopAllSelectProduct:(EnterButton *)sender
{
    [_tableView setEditing:YES animated:YES];
    
    if ([_deleteItem.title isEqualToString:@"编辑"]) {
        _deleteItem.title = @"完成";
    }
    
    NSDictionary *variantsDict = _shops[sender.tag];
    NSArray *variantsArray = [variantsDict objectForKey:@"product_variants"];

    /*     这里的代码请勿删除，留着有用
     
>>>>>>> 0a84219cb68cbeee6dd2c31fc970dc586f0b471d
    //    if (_paySelectProducts.count <= 0) {  /// 如果购物车为空，点击全选直接接将对应的店铺商品全部加入
    //        _isShopSelectProducts = NO;
    //        for (int i = 0; i < variantsArray.count; i++) {
    //            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag]
    //                                    animated:YES
    //                              scrollPosition:UITableViewScrollPositionNone];
    //            [_paySelectProducts addObject:variantsArray[i]];
    //        }
    //    } else {
    //        if (_isShopSelectProducts) {
    //            _isShopSelectProducts = NO;
    //            for (int i = 0; i < variantsArray.count; i++) {
    //                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag]
    //                                        animated:YES
    //                                  scrollPosition:UITableViewScrollPositionNone];
    //                /// 判断是否已经存在选中商品数组中  不存在就直接加入
    //                for (int j = 0; j < _paySelectProducts.count; j++) {
    //                    if ([[variantsArray[i] objectForKey:@"sku_id"] integerValue] == [[_paySelectProducts[j] objectForKey:@"sku_id"] integerValue]) {
    //                        YunLog(@"这个商品已经存在了得哦");
    //                        break;
    //                    } else {
    //                        [_paySelectProducts addObject:variantsArray[i]];
    //                    }
    //                }
    //            }
    //        } else {
    //            _isShopSelectProducts = YES;
    //            NSMutableArray *tempArray = [NSMutableArray array];
    //            tempArray = _paySelectProducts;
    //
    //            for (int i = 0; i < variantsArray.count; i++) {
    //                [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag] animated:YES];
    //

    //
    //            for (int i = 0; i < variantsArray.count; i++) {
    //                [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag] animated:YES];
    //

    //                /// 从选中的商品数组中删除这个店铺的所有商品
    //                for (int j = 0; j < tempArray.count; j++) {
    //                    if ([[variantsArray[i] objectForKey:@"sku_id"] integerValue] == [[tempArray[j] objectForKey:@"sku_id"] integerValue]) {
    //                        [_paySelectProducts removeObjectAtIndex:j];
    //                    }
    //                }
    //            }
    //        }
    //    }
    */
    
    
    
    if (_paySelectProducts.count <= 0) {  /// 如果购物车为空，点击全选直接接将对应的店铺商品全部加入
        for (int i = 0; i < variantsArray.count; i++) {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
            [_paySelectProducts addObject:variantsArray[i]];
        }
    }
    else { // 里面有数据，先将该店铺里面对应的商品全部删除  然后全部选中
        NSMutableArray *tempArray = [NSMutableArray array];
        tempArray = _paySelectProducts;

        for (int i = 0; i < variantsArray.count; i++) {
            /// 从选中的商品数组中删除这个店铺的所有商品
            for (int j = 0; j < tempArray.count; j++) {
                if ([[variantsArray[i] objectForKey:@"sku_id"] integerValue] == [[tempArray[j] objectForKey:@"sku_id"] integerValue]) {
                    [_paySelectProducts removeObjectAtIndex:j];
                }
            }
        }
        
        // 将该店铺里面的商品全部选中，并且添加入选中的数组中
        for (int i = 0; i < variantsArray.count; i++) {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:sender.tag]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
            [_paySelectProducts addObject:variantsArray[i]];
        }
    }
    
    YunLog(@"payselectProducts-------------%ld--------", (unsigned long)_paySelectProducts.count);
}

#pragma mark - EnterProductDetail -

/**
 进入点击的商品详情
 */
- (void)enterProductBtnClick:(EnterButton *)btn
{
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isCartEnterProductDetail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = btn.productCode;
    detail.shopCode = btn.shopCode;
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)enterShopBtnClick:(EnterButton *)btn
{
    YunLog(@"进入店铺页面");
    
//    ShopInfoViewController *shop = [[ShopInfoViewController alloc] init];
//    shop.code = btn.shopCode;
//    
//    YunLog(@"shop.code = %@",shop.code);
//    
//    shop.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:shop animated:YES];
    
    ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
    shop.code = btn.shopCode;
    
    YunLog(@"shop.code = %@",shop.code);
    
    shop.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:shop animated:YES];
}

#pragma mark - SWTableViewCell Utility -
/**
 返回UITableViewCell左滑后出现的按钮组
 
 @return 按钮组
 */
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"删除"];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewCellDelegate -
/**
 左滑按钮组中的按钮点击事件处理方法
 
 @param cell  对应的Cell
 @param index 选中的Cell
 */
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index indexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *shopDict = [[NSDictionary alloc] init];
    shopDict = _shops[indexPath.section];
    
    NSMutableArray *variantsArray = [NSMutableArray array];
    variantsArray = [shopDict objectForKey:@"product_variants"];
    
    NSDictionary *variantsDict = variantsArray[indexPath.row];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在删除中...";
    
    NSDictionary *params = @{@"user_session_key"       :      kNullToString(appDelegate.user.userSessionKey),
                             @"ids"                    :      kNullToString([variantsDict objectForKey:@"sku_id"])};
    
    NSString *deleteCartURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartListURL params:params];
    
    YunLog(@"deleteCartURL = %@", deleteCartURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager DELETE:deleteCartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"dele res = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            
            [self getCartListProducts:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@",error);
        
        [_hud hide:YES];
    }];
}

/**
 prevent multiple cells from showing utilty buttons simultaneously
 
 @param cell 所在的cell
 
 @return 如果返回YES,则不能同时处理多个左滑
 */
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

#pragma mark - deleButtonClick -

- (void)deleButtonClick:(EnterButton *)sender
{
    NSIndexPath *indexPath = sender.cartIndexPatch;
    AppDelegate *appDelegate = kAppDelegate;
    
    NSMutableArray *variantsArray = [_shops[indexPath.section] objectForKey:@"product_variants"];
    NSDictionary *variantsDict = variantsArray[indexPath.row];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在删除中...";
    
    NSDictionary *params = @{@"user_session_key"       :      kNullToString(appDelegate.user.userSessionKey),
                             @"ids"                    :      kNullToString([variantsDict objectForKey:@"sku_id"])};
    
    NSString *deleteCartURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartListURL params:params];
    
    YunLog(@"deleteCartURL = %@", deleteCartURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager DELETE:deleteCartURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"dele res = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            if (variantsArray.count == 1) {
                [_canEditArray removeObjectAtIndex:indexPath.section];
            }
            [self getCartListProducts:NO];
        } else {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@",error);
        
        [_hud hide:YES];
    }];

}

#pragma mark - private pathod -

- (void)calculateOrderMoney
{
    // 计算订单金额
    CGFloat orderMoney = 0.00;
    for (NSDictionary *dic in _paySelectProducts) {
        orderMoney += [dic[@"price"] floatValue] * [dic[@"quantity"] integerValue];
    }
    
    NSString *orderStr = [NSString stringWithFormat:@"合计 ¥:%.2f  (不含邮费)", orderMoney];
    
    NSMutableAttributedString *orderAttributedStr = [[NSMutableAttributedString alloc] initWithString:orderStr];
    [orderAttributedStr addAttribute:NSForegroundColorAttributeName value:kGrayFontColor range:NSMakeRange(0, orderStr.length)];
    [orderAttributedStr addAttribute:NSForegroundColorAttributeName value:kOrangeColor range:NSMakeRange(5, [NSString stringWithFormat:@"%.2f", orderMoney].length)];
    [orderAttributedStr addAttribute:NSForegroundColorAttributeName value:COLOR(200, 200, 200, 1) range:NSMakeRange(orderStr.length - 6, 6)];
    [orderAttributedStr addAttribute:NSFontAttributeName value:kSmallMoreSizeFont range:NSMakeRange(orderStr.length - 6, 6)];
    _sumLabel.attributedText = orderAttributedStr;
}

@end
