//
//  AdminInfoViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/5.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminInfoViewController.h"

// Controllers
#import "MyShopListViewController.h"
#import "MyClientsViewController.h"
#import "MyQRCodeViewController.h"
#import "PopGestureRecognizerController.h"

// Common
#import "LibraryHeadersForCommonController.h"

#define kIconWidth (kScreenWidth > 375 ? 65 * 1.293 : (kScreenWidth > 320 ? 65 * 1.17 : 65))

@interface AdminInfoViewController () <UITableViewDataSource, UITableViewDelegate>

/// 商铺名
@property (nonatomic, strong) UILabel *shopNameLabel;

/// 商铺logo
@property (nonatomic, strong) UIImageView *iconView;

/// 信息栏
@property (nonatomic, strong) UITableView *tableView;

/// 信息标题
@property (nonatomic, strong) NSArray *infoArray;

/// 信息标题图片
@property (nonatomic, strong) NSArray *infoImageArray;

/// 店铺信息
@property (nonatomic, strong) NSDictionary *shop;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 信息详情
@property (nonatomic, strong) NSMutableArray *detailInfo;

@end

@implementation AdminInfoViewController

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
        naviTitle.text = @"个人信息";
        
        self.navigationItem.titleView = naviTitle;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];

        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        backItem.style = UIBarButtonItemStylePlain;

        self.navigationItem.leftBarButtonItem = backItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _infoArray = @[@"姓 名", @"邮 箱", @"联系电话", @"我的店铺", @"我的客户", @"我的二维码"];
    
    _infoImageArray = @[@"admin_name", @"admin_mail", @"admin_telephone", @"admin_shopCenter", @"admin_companyName", @"admin_QR_Code"];

    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, kScreenHeight + 64)];
    backgroundView.image = [UIImage imageNamed:@"admin_login_background"];
    
    [self.view addSubview:backgroundView];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 64 + 5, kIconWidth, kIconWidth)];
    _iconView.image = [UIImage imageNamed:@"user_icon_shop"];
    
    [self.view addSubview:_iconView];
    
    _shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconView.frame) + 10, CGRectGetMaxY(_iconView.frame) - kIconWidth / 2 - 20, 200, 30)];
    _shopNameLabel.textAlignment = NSTextAlignmentLeft;
    _shopNameLabel.textColor = [UIColor whiteColor];
    _shopNameLabel.font = kBigFont;
    
    [self.view addSubview:_shopNameLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconView.frame) + 10, kScreenWidth, 30)];
    titleLabel.text = @"您的基本信息";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = kBigBoldFont;
    
    [self.view addSubview:titleLabel];
    
    [self getAdminInfo];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 5, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    //    _tableView.layer.masksToBounds = YES;
    //    _tableView.layer.cornerRadius  = 5;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.backgroundColor =kClearColor;
    _tableView.bounces = NO;
    _tableView.scrollEnabled = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];

    self.view.backgroundColor = kBackgroundColor;
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.alpha = 0.0;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        
        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
//    [pop setPopGestureEnabled:YES];

    NSArray *list = self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.alpha = 1.0;
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)getAdminInfo
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),};
    
    NSString *adminInfoURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/shops/%@/owner_shop.json",_shopCode] params:params];
    
    YunLog(@"adminInfoURL = %@", adminInfoURL);
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:adminInfoURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"adminInfo responseObject = %@", responseObject);
             if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
             {
                 _shop = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"shop"]);
                 _hud.hidden = YES;
                 
                 _shopNameLabel.text = kNullToString([_shop objectForKey:@"name"]);
                 
                 NSString *iconString = kNullToString([_shop objectForKey:@"logo"]);
                 [_iconView setImageWithURL:[NSURL URLWithString:iconString]
                           placeholderImage:[UIImage imageNamed:@"user_icon_shop"]];
                 [_tableView reloadData];
             }
             else
             {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             YunLog(@"error - %@", error);
         }];

}

- (void)backToPrev
{
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _infoArray.count;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kIsiPhone) {
        return 44;
    } else {
        return 65;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        if (indexPath.row > 2)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kClearColor;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSString *imageName = _infoImageArray[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    cell.textLabel.text = _infoArray[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.row == 0)
    {
         cell.detailTextLabel.text = kNullToString([_shop objectForKey:@"contact_name"]);
    }
    if (indexPath.row == 1)
    {
        cell.detailTextLabel.text = kNullToString([_shop objectForKey:@"email"]);
    }
    if (indexPath.row == 2)
    {
        cell.detailTextLabel.text = kNullToString([_shop objectForKey:@"fixed_line_phone"]);
    }
    
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (kIsiPhone) {
        cell.textLabel.font = kNormalFont;
        cell.detailTextLabel.font = kNormalFont;
    } else {
        cell.textLabel.font = kBigFont;
        cell.detailTextLabel.font = kBigFont;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 3:
        {
            MyShopListViewController *shoplist = [[MyShopListViewController alloc] init];
            
            [self.navigationController pushViewController:shoplist animated:YES];
         }
            break;
            
        case 4:
        {
            MyClientsViewController *client = [[MyClientsViewController alloc] init];
            client.shopID = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]);
            
            [self.navigationController pushViewController:client animated:YES];
        }
            break;
            
        case 5:
        {
            MyQRCodeViewController *qrcode = [[MyQRCodeViewController alloc] init];
            qrcode.shopName = kNullToString([_shop objectForKey:@"name"]);
            qrcode.shopURL = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shop_home_url"]);
            YunLog(@"qrcode = %@", qrcode.shopURL);
            
            [self.navigationController pushViewController:qrcode animated:YES];
        }
            break;

            
        default:
            break;
    }
}

@end
