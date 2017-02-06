//
//  MyShopListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-4-16.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyShopListViewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "MyShopViewController.h"
#import "AdminShopViewController.h"
#import "AdminShopViewController.h"
#import "PopGestureRecognizerController.h"
#import "ConsumerChooseViewController.h"

// Comones
#import "MBProgressHUD+Extend.h"
#import "MBProgressHUD.h"

@interface MyShopListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyShopListViewController

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
        naviTitle.text = @"商铺列表";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];
    
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
//    [pop setPopGestureEnabled:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
//    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.shops.count > 0) {
        if (appDelegate.user.shops.count == 1) {
            [self enterShopView:appDelegate.user.shops]; // 等于1  直接跳入
        } else {
            
        }
    } else {
        [self getData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EnterShopView - 

- (void)enterShopView:(NSArray *)array
{
    NSString *shopCode = kNullToString([[array firstObject] objectForKey:@"code"]);
    NSString *shopID = kNullToString([[array firstObject] objectForKey:@"id"]);
    
    AdminShopViewController *myShopVc = [[AdminShopViewController alloc] init];
    myShopVc.shopCode = shopCode;
    myShopVc.shopID = shopID;
    myShopVc.canBack = NO;
    
    myShopVc.navigationController.navigationBarHidden = YES;
    myShopVc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:myShopVc animated:YES];
}

#pragma mark - Login -
// TODO
//- (void)loginData
//{
//    AppDelegate *appDelegate = kAppDelegate;
//    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT"];
//    NSString *passWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD"];
//    NSDictionary *params = @{@"login"                 :   kNullToString(userName),
//                             @"password"              :   kNullToString(passWord),
//                             @"phone_code_type"       :   @"sign_in",
//                             @"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey),
//                             @"source"                :   @"1"};
//}

#pragma mark - GetData -

- (void)getData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"获取商铺列表...";
    
    NSDictionary *params = @{@"user_session_key":kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *myShopsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShopAdminShopsURL params:params];
    
    YunLog(@"myShopsURL = %@", myShopsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:myShopsURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"my shop responseObject = %@", responseObject);
             
             [_hud hide:YES];
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             NSArray *tempArray = [[responseObject objectForKey:@"data"] objectForKey:@"shop_list"];
             NSDictionary *dict = [tempArray lastObject];
             _shopID = dict[@"id"];
             YunLog(@"id = %@", _shopID);
             
             if ([code isEqualToString:kSuccessCode]) {
                 appDelegate.user.shops = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"shop_list"]);
                 
                 if (appDelegate.user.shops.count == 1) {
                     [self enterShopView:appDelegate.user.shops];
                 }
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     ConsumerChooseViewController *choose = [[ConsumerChooseViewController alloc] init];
                     
                     [self.navigationController pushViewController:choose animated:YES];
                 });
                 //                             [self changeUserStatus];
             } else {
                 [Tool resetUser];

                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     ConsumerChooseViewController *choose = [[ConsumerChooseViewController alloc] init];
                     
                     [self.navigationController pushViewController:choose animated:YES];
                 });

             }
             
             [_tableView reloadData];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"my shop error = %@", error);
             
             if (![operation isCancelled]) {
                 [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             }
         }];
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = kAppDelegate;
    
    return appDelegate.user.shops.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    cell.textLabel.text = kNullToString([appDelegate.user.shops[indexPath.row] objectForKey:@"name"]);
    cell.textLabel.font  = kMidFont;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSString *shopCode = kNullToString([appDelegate.user.shops[indexPath.row] objectForKey:@"code"]);
    NSString *shopID = kNullToString([appDelegate.user.shops[indexPath.row] objectForKey:@"id"]);
    //    MyShopViewController *myShop = [[MyShopViewController alloc] init];
    //    myShop.shopCode = shopCode;
    //    myShop.hidesBottomBarWhenPushed = YES;
    //        [self.navigationController pushViewController:myShop animated:YES];
    
    AdminShopViewController *myShopVc = [[AdminShopViewController alloc] init];
    //            AdminHomeViewController *vc = [[AdminHomeViewController alloc] init];
    myShopVc.shopCode = shopCode;
    myShopVc.shopID = shopID;
    myShopVc.canBack = YES;
    
    myShopVc.navigationController.navigationBarHidden = YES;
    myShopVc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:myShopVc animated:YES];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    [defaults setObject:shopCode forKey:@"lastSelectedShop"];
//    
//    [defaults synchronize];
}

@end
