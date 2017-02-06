//
//  CartViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "CartViewController.h"

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

// Categories
#import "UIImageView+AFNetworking.h"
#import "UIButton+TJButtom.h"

// Libraries
#import "SwipeTableView/SWTableViewCell.h"

#define kSpace 10
#define kSpaceDouble 20

@interface CartViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITabBarControllerDelegate, SWTableViewCellDelegate>

@property (nonatomic, strong) NSArray *goods;
@property (nonatomic, strong) UILabel *totalMoney;
@property (nonatomic, strong) UILabel *totalCount;
@property (nonatomic, strong) UILabel *nanviTitle;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *empty;
@property (nonatomic, assign) NSInteger imageViewWidthHeight;


@property (nonatomic, strong) UIButton *goToHomePage;

@property (nonatomic, assign) BOOL isSelectedAllProducts;


/// 底部存放删除和全选按钮的UIView
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign, getter = isPaying) BOOL paying;

@end

@implementation CartViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"购物车";
        
        self.tabBarItem.image = [[UIImage imageNamed:@"cart_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"cart_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        //        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"cart_tab_selected"]
        //                      withFinishedUnselectedImage:[UIImage imageNamed:@"cart_tab"]];
        
        //        [self.tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor grayColor]} forState:UIControlStateNormal];
        //        [self.tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor orangeColor]} forState:UIControlStateSelected];
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    self.tabBarController.tabBar.hidden = YES;
    
    self.needToHideBottomBar = YES;
    
    [self updateBadgeValue];
    
    //    AppDelegate *appDelegate = kAppDelegate;
    //
    //    if (appDelegate.isPaying) {
    //        [self.tabBarController setSelectedIndex:0];
    //
    //        appDelegate.paying = NO;
    //    }
    //
    //    double delayInSeconds = 1.0;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
    //        if (_paying && appDelegate.isLogin) {
    //            _paying = NO;
    //
    //            PayCenterForUserViewController *pay = [[PayCenterForUserViewController alloc] init];
    //            UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
    //
    //            [self.navigationController presentViewController:payNC animated:YES completion:nil];
    //
    //            return;
    //        }
    //    });
    
    [self updateGoods];
    
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
    
    // 添加返回箭头按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 25, 25);
    [backBtn setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backHomePage) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    // 添加中间的导航栏标题
    _nanviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 160) / 2, 0, 160, 40)];
    
    _nanviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    _nanviTitle.backgroundColor = kClearColor;
    _nanviTitle.textColor = kNaviTitleColor;
    _nanviTitle.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = _nanviTitle;
    
    // 判断各种按钮是否显示隐藏
    [self changeView];
    
    // 添加右边的编辑按钮
    if (_goods.count > 0 && _deleteItem == nil) {
        _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(itemBtnClick:)];
        [_deleteItem setTintColor:[UIColor orangeColor]];
        [_tableView setEditing:YES animated:YES];
        
        self.navigationItem.rightBarButtonItem = _deleteItem;
    }
    
    [_tableView reloadData];
    
    for (int i = 0; i < _goods.count; i++) {
        if ([[_goods[i] objectForKey:CartManagerSelectedKey] isEqualToString:@"yes"]) {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        }
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
        self.needToHideBottomBar = YES;
        CGRect frame = self.tabBarController.tabBar.frame;
        [self.tabBarController.tabBar setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, frame.size.height)];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
    [UIView animateWithDuration:0.8 animations:^{
        CGRect frame = self.tabBarController.tabBar.frame;
        [self.tabBarController.tabBar setFrame:CGRectMake(frame.origin.x, frame.origin.y - frame.size.height, frame.size.width, frame.size.height)];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    _isSelectedAllProducts = NO;
    
    // 添加一条顶部的分割线
    UIView *totalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    totalView.backgroundColor = COLOR(245, 245, 245, 1);
    
    [self.view addSubview:totalView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, kScreenWidth, kScreenHeight - 65 - 48)
                                              style:UITableViewStylePlain];
    
    if (kDeviceOSVersion < 7.0) {
        _tableView.frame = CGRectMake(0, 65, kScreenWidth, kScreenHeight - 65 - 48);
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self.view addSubview:_tableView];
    
    // 添加底部控件，存放删除，全选按钮
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
    
    if (kDeviceOSVersion < 7.0) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48)];
    }
    
    _bottomView.backgroundColor = COLOR(245, 245, 245, 1);
    _bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
    _bottomView.layer.borderWidth = 1;
    _bottomView.clipsToBounds = NO;
    
    [self.view addSubview:_bottomView];
    
    NSArray *arrayTemp = @[@"全选", @"删除", @"去结算"];
    
    // 添加全选和删除按钮
    for (int i = 0; i < arrayTemp.count; i++)
    {
        UIButton *btnSelectedAndClear = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnSelectedAndClear setTitle:arrayTemp[i] forState:UIControlStateNormal];
        [btnSelectedAndClear setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        btnSelectedAndClear.backgroundColor = kClearColor;
        
        if (i == 0) {
            btnSelectedAndClear.frame = CGRectMake(0, 0, 75, 48);
            btnSelectedAndClear.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
            [btnSelectedAndClear addTarget:self action:@selector(selectAllProducts:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i == 1) {
            btnSelectedAndClear.frame = CGRectMake(60, 0, 75, 48);
            btnSelectedAndClear.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
            [btnSelectedAndClear addTarget:self action:@selector(deleteSelectedGood:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i == 2) {
            btnSelectedAndClear.frame = CGRectMake(kScreenWidth - 100, 0, 100, 48);
            btnSelectedAndClear.titleLabel.font = [UIFont boldSystemFontOfSize:kFontBigSize];
            [btnSelectedAndClear addTarget:self action:@selector(goToPay) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_bottomView addSubview:btnSelectedAndClear];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        for (int i = 0; i < _goods.count; i++) {
            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[i]];
            
            [temp setObject:@"no" forKey:CartManagerSelectedKey];
            
            [[CartManager defaultCart] updateProduct:temp atIndex:i];
            [self updateGoods];
        }
    }
}

/**
 返回到首页
 */
- (void)backHomePage
{
    self.tabBarController.selectedIndex = 0;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.lastSelectedTabIndex = 0;
}

- (void)deleteSelectedGood:(UIButton *)sender
{
    NSArray *selectedRows = [_tableView indexPathsForSelectedRows];
    YunLog(@"测试，，--selectedRows = %@", selectedRows);
    
    if (selectedRows.count <= 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请先选择商品" delay:2.0];
        
        return;
    }
    
    YunLog(@"selectedRows = %@", selectedRows);
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < selectedRows.count; i++) {
        NSIndexPath *indexPath = selectedRows[i];
        
        [indexSet addIndex:indexPath.row];
    }
    
    [[CartManager defaultCart] removeProductsAtIndexes:indexSet];
    
    [self updateGoods];
    
    [_tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView reloadData];
    
    [self changeView];
    
    [self updateBadgeValue];
    
    if (_goods.count <= 0) {
        [self.tableView setEditing:NO animated:YES];
        
        _deleteItem = nil;
        
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)selectAllProducts:(UIButton *)leftBtn
{
    YunLog(@"_goodsTest = %@", _goods);
    
    if (_isSelectedAllProducts) { // 点击一次全部选中
        _isSelectedAllProducts = NO;
        
        if ([_deleteItem.title isEqualToString:@"编辑"])
        {
            [self.tableView setEditing:YES animated:YES];
            _deleteItem.title = @"完成";
        }
        
        for (int i=0; i< _goods.count; i++)
        {
            if ([[_goods[i] objectForKey:@"CartManagerSelectedKey"] isEqualToString:@"no"]) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[i]];
                
                [temp setObject:@"yes" forKey:CartManagerSelectedKey];
                
                [[CartManager defaultCart] updateProduct:temp atIndex:i];
                
                [self updateGoods];
            }
        }
        
        for (int i = 0; i < _goods.count; i++) {
            if ([[_goods[i] objectForKey:CartManagerSelectedKey] isEqualToString:@"yes"]) {
                [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                        animated:NO
                                  scrollPosition:UITableViewScrollPositionNone];
            }
        }
    } else { // 再次点击全部取消选中
        _isSelectedAllProducts = YES;
        
        if ([_deleteItem.title isEqualToString:@"完成"])
        {
            [self.tableView setEditing:NO animated:YES];
            _deleteItem.title = @"编辑";
        }
        
        for (int i=0; i< _goods.count; i++)
        {
            if ([[_goods[i] objectForKey:@"CartManagerSelectedKey"] isEqualToString:@"yes"]) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[i]];
                
                [temp setObject:@"no" forKey:CartManagerSelectedKey];
                
                [[CartManager defaultCart] updateProduct:temp atIndex:i];
                
                [self updateGoods];
            }
        }
        
        for (int i = 0; i < _goods.count; i++) {
            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[i]];
            
            [temp setObject:@"no" forKey:CartManagerSelectedKey];
            
            [[CartManager defaultCart] updateProduct:temp atIndex:i];
            [self updateGoods];
        }
    }
}

#pragma mark - Private Functions -

- (void)changeView
{
    if (_goods.count <= 0) {
        _empty.hidden = NO;
        _goToHomePage.hidden = NO;
        _tableView.hidden = YES;
        _bottomView.hidden = YES;
        
        _nanviTitle.text = @"购物车";
        if (_deleteItem) {
            _deleteItem = nil;
            
            self.navigationItem.rightBarButtonItem = nil;
        }
    } else {
        _empty.hidden = YES;
        _goToHomePage.hidden = YES;
        _tableView.hidden = NO;
        _bottomView.hidden = NO;
        //        self.tabBarController.tabBar.hidden = YES;
        
        _nanviTitle.text = [NSString stringWithFormat:@"合计: %.2f", [[CartManager defaultCart] selectedAllMoney]];
    }
}

- (void)updateGoods
{
    _goods = nil;
    _goods = [[CartManager defaultCart] allProducts];
    
    YunLog(@"_goods = %@", _goods);
    
    _nanviTitle.text = [NSString stringWithFormat:@"合计:%.2f", [[CartManager defaultCart] selectedAllMoney]];
}

- (void)goToPay
{
    if (_goods.count == 0) {
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
    
    NSArray *allSelectProducts = [[CartManager defaultCart] allSelectedProducts];
    if (allSelectProducts.count <= 0) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"请选择结算的商品" delay:2.0];
        return;
    }
    
    YunLog(@"allSelectProducts = %@", allSelectProducts);
    
    _paying = YES;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin) {
        if (allSelectProducts.count > 0) {
            _paying = NO;
            
            PayCenterForUserViewController *pay = [[PayCenterForUserViewController alloc] init];
            
            UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
            
            [self.navigationController presentViewController:payNC animated:YES completion:nil];
        } else {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:@"请选择结算的商品" delay:2.0];
        }
        _paying = NO;
        
        PayCenterForUserViewController *pay = [[PayCenterForUserViewController alloc] init];
        
        //        UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
        
        //        [self.navigationController presentViewController:payNC animated:YES completion:nil];
        
        UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
        
        [self.navigationController presentViewController:payNC animated:YES completion:^{
            //            kApplication.delegate.window.rootViewController = payNC;
            //            [kApplication.delegate.window makeKeyAndVisible];
        }];
        
        //        pay.hidesBottomBarWhenPushed = YES;
        //
        //        [self.navigationController pushViewController:pay animated:YES];
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
- (void)minusCount:(UIButton *)sender
{
//    NSString *selected = [_goods[(sender.tag - 1) / 100] objectForKey:CartManagerSelectedKey];
//    
//    if ([selected isEqualToString:@"no"]) {
//        return;
//    }
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(sender.tag - 1) / 100 inSection:0]];
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:sender.tag + 2];
    
    NSInteger count = [textField.text integerValue];
    count -= 1;
    
    textField.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    
    NSInteger min_count = [[_goods[(sender.tag - 1) / 100] objectForKey:CartManagerMinCountKey] integerValue];
    
    if (count == min_count) {
        sender.enabled = NO;
    }
    
    UIButton *plutButton = (UIButton *)[cell.contentView viewWithTag:sender.tag + 1];
    plutButton.enabled = YES;
    
    [self updateViewAtIndex:(sender.tag - 1) / 100 count:count];
}

/**
 商品增加
 
 @param sender 被点击按钮
 */
- (void)plusCount:(UIButton *)sender
{
//    NSString *selected = [_goods[(sender.tag - 2) / 100] objectForKey:CartManagerSelectedKey];
//    
//    if ([selected isEqualToString:@"no"]) {
//        return;
//    }
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(sender.tag - 2) / 100 inSection:0]];
    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:sender.tag + 1];
    
    NSInteger count = [textField.text integerValue];
    count += 1;
    
    textField.text = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    
    NSInteger maxCount = [[_goods[(sender.tag - 2) / 100] objectForKey:CartManagerInventoryKey] integerValue];
    
    if (count == maxCount) {
        sender.enabled = NO;
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:@"亲、库存有限哦..." delay:2.0];
    }
    
    UIButton *minusButton = (UIButton *)[cell.contentView viewWithTag:sender.tag - 1];
    minusButton.enabled = YES;
    
    [self updateViewAtIndex:(sender.tag - 2) / 100 count:count];
}

- (void)updateViewAtIndex:(NSInteger)index count:(NSInteger)count
{
    NSDictionary *product = [_goods objectAtIndex:index];
    YunLog("product = %@", product);
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:product];
    
    [temp removeObjectForKey:CartManagerCountKey];
    [temp setObject:[NSString stringWithFormat:@"%lu", (unsigned long)count] forKey:CartManagerCountKey];
    
    [[CartManager defaultCart] updateProduct:temp atIndex:index];
    
    [self updateBadgeValue];
    
    [self updateGoods];
}

- (void)updateBadgeValue
{
    NSString *count = [[CartManager defaultCart] productCount];
    if ([count isEqualToString:@"0"]) {
        self.tabBarItem.badgeValue = nil;
    } else {
        self.tabBarItem.badgeValue = count;
    }
}

//- (void)deleteGood:(UIButton *)sender
//{
//    NSDictionary *product = [[CartManager defaultCart] productAtIndex:(sender.tag - 4) / 100];
//
//    NSDictionary *params;
//
//    @try {
//        params = @{
//                   @"uuid":[Tool getUniqueDeviceIdentifier],
//                   @"product_name":[product objectForKey:CartManagerDescriptionKey],
//                   @"product_id":[product objectForKey:CartManagerSkuIDKey]
//                   };
//    }
//    @catch (NSException *exception) {
//        YunLog(@"delete product exception = %@", exception);
//    }
//    @finally {
//
//    }
//
//    [TalkingData trackEvent:@"更改购物车的商品" label:@"删除商品" parameters:params];
//
//    [[CartManager defaultCart] removeProductAtIndex:(sender.tag - 4) / 100];
//
//    NSString *count = [[CartManager defaultCart] productCount];
//    if ([count isEqualToString:@"0"]) {
//        self.tabBarItem.badgeValue = nil;
//    } else {
//        self.tabBarItem.badgeValue = count;
//    }
//
//    [self updateGoods];
//
//    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(sender.tag - 4) / 100 inSection:0]]
//                      withRowAnimation:UITableViewRowAnimationLeft];
//    [_tableView reloadData];
//
//    [self changeView];
//}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _goods.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *promotionArray = kNullToString([[_goods objectAtIndex:indexPath.row] objectForKey:CartManagerPromotionsKey]);
    NSString *description = kNullToString([_goods[indexPath.row] objectForKey:CartManagerDescriptionKey]);
     NSString *subtitle = kNullToString([_goods[indexPath.row] objectForKey:CartManagerSubtitleKey]);
    
    CGSize subSize = [subtitle sizeWithFont:kSmallFont size:CGSizeMake(142, 9999)];
    
    CGSize size = [description sizeWithFont:[UIFont fontWithName:kFontFamily size:14]
                                       size:CGSizeMake(142, 9999)];
    
    CGFloat height = 0;
    CGSize proSize = CGSizeZero;
    if (promotionArray.count > 0) {
        proSize = [[promotionArray[0] objectForKey:@"name"] sizeWithFont:[UIFont fontWithName:kFontFamily size:14] size:CGSizeMake(142, 9999)];
        
        height = size.height + proSize.height + subSize.height - 30;
    } else {
        height = size.height + subSize.height - 30;
    }
    
    CGFloat rowHeight = 0;
    
    if (proSize.height > 5) {
        if (promotionArray.count > 1) {
            rowHeight = 110 + height + 16;
        } else {
            rowHeight = 110 + height;
        }
    } else {
        rowHeight = 110 + height;
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.backgroundColor = kBackgroundColor;
    
    NSArray *promotionArray = [_goods[indexPath.row] objectForKey:CartManagerPromotionsKey];
    
    if (promotionArray.count > 0) {
        _imageViewWidthHeight = 100;
    } else {
        _imageViewWidthHeight = 90;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, _imageViewWidthHeight, _imageViewWidthHeight)]; // 宽高  80
    //    leftImage.backgroundColor = [UIColor redColor];
    imageView.backgroundColor = kClearColor;
    imageView.contentMode = UIViewContentModeCenter;
    
    __weak UIImageView *weakImageView = imageView;
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([_goods[indexPath.row] objectForKey:CartManagerImageURLKey])]]
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          weakImageView.image = image;
                                          weakImageView.contentMode = UIViewContentModeScaleToFill;
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          [weakImageView setImageWithURL:[NSURL URLWithString:kNullToString([_goods[indexPath.row] objectForKey:CartManagerSmallImageURLKey])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                          weakImageView.contentMode = UIViewContentModeScaleToFill;
                                      }];
    
    [cell.contentView addSubview:imageView];
    
    // 添加空白的点击按钮实现 点击图片进入商品详情
    EnterButton *enterProduct  = [[EnterButton alloc] initWithFrame:CGRectMake(kSpace, kSpace, 100, 90)];
    enterProduct.productCode = [_goods[indexPath.row] objectForKey:CartManagerProductCodeKey];
    enterProduct.shopCode = [_goods[indexPath.row] objectForKey:CartManagerShopCodeKey];
//    enterProduct.tag = [[_goods[indexPath.row] objectForKey:CartManagerProductCodeKey] integerValue];
    enterProduct.backgroundColor = kClearColor;
    [enterProduct addTarget:self action:@selector(enterProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:enterProduct];
    
    int height = 10;
    
    NSString *description = kNullToString([_goods[indexPath.row] objectForKey:CartManagerDescriptionKey]);
    
    CGSize size = [description sizeWithFont:[UIFont fontWithName:kFontFamily size:14]
                                       size:CGSizeMake(142, 9999)];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(133, height, 142, size.height)];

    descriptionLabel.backgroundColor = kClearColor;
    descriptionLabel.font = [UIFont fontWithName:kFontFamily size:14];
    descriptionLabel.text = description;
    descriptionLabel.numberOfLines = 0;
    
    [cell.contentView addSubview:descriptionLabel];
    
    // 添加空白的点击按钮实现 点击商品标题进入商品详情

    EnterButton *enterTitleBtn = [[EnterButton alloc] initWithFrame:CGRectMake(133, height, 142, size.height)];

    //    [enterTitleBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
//    enterTitleBtn.tag = [[_goods[indexPath.row] objectForKey:CartManagerProductCodeKey] integerValue];
    enterTitleBtn.productCode = [_goods[indexPath.row] objectForKey:CartManagerProductCodeKey];
    enterTitleBtn.shopCode = [_goods[indexPath.row] objectForKey:CartManagerShopCodeKey];
    [enterTitleBtn addTarget:self action:@selector(enterProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:enterTitleBtn];
    
    NSString *subtitle = kNullToString([_goods[indexPath.row] objectForKey:CartManagerSubtitleKey]);
    
    CGSize subSize = [subtitle sizeWithFont:kSmallFont size:CGSizeMake(142, 9999)];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(133, height + size.height, 142, subSize.height)];
    
    subtitleLabel.backgroundColor = kClearColor;
    subtitleLabel.textColor = [UIColor lightGrayColor];
    subtitleLabel.font = kSmallFont;
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subtitleLabel.text = subtitle;
    
    [cell.contentView addSubview:subtitleLabel];
    
    height += (size.height + subSize.height > 34 ? size.height + subSize.height : 34);
    
//    CGSize proSize = [promotionString sizeWithFont:[UIFont fontWithName:kFontFamily size:14]
//                                              size:CGSizeMake(142, 9999)];
//    
//    if (promotionString.length > 0) {
//        UILabel *promotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x, height + 5, 142, proSize.height)];
//        promotionLabel.text = promotionString;
//        promotionLabel.textColor = [UIColor redColor];
//        promotionLabel.font = kMidSizeFont;
//        
//        [cell.contentView addSubview:promotionLabel];
//        
//        height = CGRectGetMaxY(promotionLabel.frame) + 5;
//    }
    
    CGFloat promotionsLabelX = descriptionLabel.frame.origin.x;
    CGFloat promotionsLabelWidth = 142;
    
    for (int i = 0; i < promotionArray.count; i++) {
        CGSize proSize = [[promotionArray[i] objectForKey:@"name"] sizeWithFont:[UIFont fontWithName:kFontFamily size:14] size:CGSizeMake(142, 9999)];
        CGFloat promotionsLabelHeight = proSize.height;
        CGFloat promotionsLabelY = height;
        height += promotionsLabelHeight;
        UILabel *promotionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(promotionsLabelX, promotionsLabelY, promotionsLabelWidth, promotionsLabelHeight)];
        
        promotionsLabel.text = [promotionArray[i] objectForKey:@"name"];
        promotionsLabel.textColor = [UIColor redColor];
        promotionsLabel.font = kMidSizeFont;

        [cell.contentView addSubview:promotionsLabel];
    }
    
    UILabel *nowPrice = [[UILabel alloc] initWithFrame:CGRectMake(133, height + 5, 36, 14)];

    nowPrice.backgroundColor = kClearColor;
    nowPrice.font = [UIFont fontWithName:kFontFamily size:14];
    nowPrice.text = @"单价: ";
    
    [cell.contentView addSubview:nowPrice];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(nowPrice.frame.origin.x + nowPrice.frame.size.width, height + 5, kScreenWidth - nowPrice.frame.origin.x - nowPrice.frame.size.width - 10, 14)];
    price.backgroundColor = kClearColor;
    price.textColor = [UIColor orangeColor];
    price.font = [UIFont fontWithName:kFontFamily size:14];
    price.text = [NSString stringWithFormat:@"￥%@", kNullToString([_goods[indexPath.row] objectForKey:CartManagerPriceKey])];
    
    [cell.contentView addSubview:price];
    
    height += 14 + 12;
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(133, height + 5, 36, 14)];

    countLabel.backgroundColor = kClearColor;
    countLabel.font = [UIFont fontWithName:kFontFamily size:14];
    countLabel.text = @"数量: ";
    
    [cell.contentView addSubview:countLabel];
    
    UIButton *minusCount = (UIButton *)[cell.contentView viewWithTag:indexPath.row * 100 + 1];
//    minusCount.backgroundColor = [UIColor yellowColor];
    if (!minusCount) {
        minusCount = [[UIButton alloc] initWithFrame:CGRectMake(price.frame.origin.x - 20, height - 1 - 20, 70, 70)];
        
        [minusCount setImage:[UIImage imageNamed:@"minus_enabled"] forState:UIControlStateNormal];
        [minusCount setImage:[UIImage imageNamed:@"minus_disabled"] forState:UIControlStateDisabled];
       
        minusCount.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [minusCount setEnlargeEdgeWithTop:20 right:20 bottom:20 left:20];
        [minusCount addTarget:self action:@selector(minusCount:) forControlEvents:UIControlEventTouchUpInside];
        minusCount.tag = indexPath.row * 100 + 1;
        
        [cell.contentView addSubview:minusCount];
    }
    
    if ([[[_goods objectAtIndex:indexPath.row] objectForKey:CartManagerCountKey] intValue] <= [[_goods[indexPath.row] objectForKey:CartManagerMinCountKey] integerValue]) {
        minusCount.enabled = NO;
    }
    
    UIButton *plusCount = (UIButton *)[cell.contentView viewWithTag:indexPath.row * 100 + 2];
    
    if (!plusCount) {
        plusCount = [[UIButton alloc] initWithFrame:CGRectMake(price.frame.origin.x + 70 - 20, height - 1 - 20, 70, 70)];
        [plusCount setImage:[UIImage imageNamed:@"plus_enabled"] forState:UIControlStateNormal];
        [plusCount setImage:[UIImage imageNamed:@"plus_disabled"] forState:UIControlStateDisabled];
//        plusCount.backgroundColor = [UIColor blackColor];
        plusCount.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [plusCount addTarget:self action:@selector(plusCount:) forControlEvents:UIControlEventTouchUpInside];
        plusCount.tag = indexPath.row * 100 + 2;
        
        [cell.contentView addSubview:plusCount];
    }
    
    if ([[[_goods objectAtIndex:indexPath.row] objectForKey:CartManagerCountKey] intValue] == [[_goods[indexPath.row] objectForKey:CartManagerMaxCountKey] integerValue]) {
        plusCount.enabled = NO;
    }
    
    UILabel *showCount = (UILabel *)[cell.contentView viewWithTag:indexPath.row * 100 + 3];
    
    if (!showCount) {
        showCount = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(minusCount.frame) - 20, height + 4, 40, 20)];
        showCount.backgroundColor = kClearColor;
        showCount.font = kNormalFont;
        showCount.textAlignment = NSTextAlignmentCenter;
        showCount.tag = indexPath.row * 100 + 3;
        
        [cell.contentView addSubview:showCount];
    }
    
    showCount.text = [NSString stringWithFormat:@"%@", kNullToString([_goods[indexPath.row] objectForKey:CartManagerCountKey])];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YunLog(@"indexPath.row = %ld", (long)indexPath.row);
    
    if (self.tableView.editing == YES) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[indexPath.row]];
        
        [temp setObject:@"yes" forKey:CartManagerSelectedKey];
        
        [[CartManager defaultCart] updateProduct:temp atIndex:indexPath.row];
        
        [self updateGoods];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YunLog(@"indexPath.row = %ld", (long)indexPath.row);
    
    if (self.tableView.editing == YES) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_goods[indexPath.row]];
        
        [temp setObject:@"no" forKey:CartManagerSelectedKey];
        
        [[CartManager defaultCart] updateProduct:temp atIndex:indexPath.row];
        
        [self updateGoods];
    }
    
}

// 返回每个cell，对应的操作风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
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

#pragma mark - EnterProductDetail -

/**
 进入点击的商品详情
 */
- (void)enterProductBtnClick:(EnterButton *)btn
{
//    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isCartEnterProductDetail"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = btn.productCode;
    detail.shopCode = btn.shopCode;
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
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
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath * path = [self.tableView indexPathForCell:cell];
    YunLog(@"index row = %ld", (long)path.row);
    
    NSMutableArray *selectedRows = [NSMutableArray array];
    [selectedRows addObject:path];
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    [indexSet addIndex:path.row];
    
    [[CartManager defaultCart] removeProductsAtIndexes:indexSet];
    
    [self updateGoods];
    
    [_tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self changeView];
    
    [self updateBadgeValue];
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

@end
