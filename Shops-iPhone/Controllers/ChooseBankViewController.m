//
//  ChooseBankViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/7/6.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ChooseBankViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"
#import "OrderManager.h"

//Controllers
#import "OrderListViewController.h"
#import "MoreBankViewController.h"

// Libraries
#import "Umpay.h"

@interface ChooseBankViewController () <UmpayDelegate, UITableViewDataSource, UITableViewDelegate>

/// 进入选择银行后第一页显示的银行数组
@property (nonatomic, strong) NSArray *bankNameArray;

/// 进入选择银行后点击更多银行按钮时加载的银行数组
@property (nonatomic, strong) NSArray *moreBankNameArray;

/// 目前显示在页面上的银行数组
@property (nonatomic, strong) NSArray *nowBankNameArray;

/// 显示待银行的tableView
@property (nonatomic, strong) UITableView *tableView;

/// 加载视图 （第三方库）
@property (nonatomic, copy) MBProgressHUD *hud;

/// 当前选中的cell的索引
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation ChooseBankViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *navImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 38) / 2, 11, 38, 22)];
        
        navImageView.image = [UIImage imageNamed:@"ump_nav_icon"];
        
        self.navigationItem.titleView = navImageView;
        
        self.view.backgroundColor = kBackgroundColor;
        
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        _index = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    [self.navigationController.navigationBar setBarTintColor:COLOR(22, 108, 175, 1)];
    
    [self createUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
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

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 50, 25);
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _bankNameArray = @[@"中国招商银行", @"中国工商银行", @"中国建设银行", @"中国银行", @"中国民生银行", @"中国光大银行", @"选择更多"];
    _moreBankNameArray = @[@"农业银行", @"邮储银行", @"交通银行", @"中信银行", @"华夏银行", @"上海银行", @"北京银行", @"东亚银行", @"兴业银行", @"宁波银行", @"浦发银行", @"广发银行", @"平安银行", @"包商银行", @"长沙银行", @"承德银行", @"成都农商银行", @"重庆农村商业银行", @"重庆银行", @"大连银行", @"东营市商业银行", @"鄂尔多斯银行", @"福建省农村信用社", @"贵阳银行", @"广州银行", @"广州农村商业银行", @"哈尔滨银行", @"湖南省农村信用社", @"徽商银行", @"河北银行", @"杭州银行", @"锦州银行", @"江苏常熟农村商业银行", @"江苏银行", @"江阴农村商业银行", @"九江银行", @"兰州银行", @"龙江银行", @"青海银行", @"上海农商银行", @"上饶银行", @"顺德农村商业银行", @"台州银行", @"威海市商业银行", @"潍坊银行", @"温州银行", @"乌鲁木齐商业银行", @"无锡农村商业银行", @"宜昌市商业银行", @"鄞州银行", @"浙江稠州商业银行", @"浙江泰隆商业银行", @"浙江民泰商业银行", @"南京银行", @"南昌银行", @"齐鲁银行", @"尧都农村商业银行", @"吴江农村商业银行"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

/**
 点击退出按钮时调用
 
 当数据源数据小于等于7时，直接退出选择银行页面；当数据源数据大于7时加载进入选择银行的第一页
 */
- (void)doBack
{
    if( _nowBankNameArray.count <= 7)
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
        [self.navigationController popViewControllerAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModalController object:self];
        });
    }
    else
    {
        _nowBankNameArray = [NSArray arrayWithArray:_bankNameArray];
        
         _selectedIndexPath = nil;
        
        [_tableView reloadData];
    }
}

/**
 创建视图UI
 */
- (void)createUI
{
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, 30)];

    topLabel.text = @"信用卡";
    topLabel.font = [UIFont systemFontOfSize:15];
    topLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:topLabel];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLabel.frame), kScreenWidth, 3)];
    topLine.backgroundColor = COLOR(22, 108, 175, 1);
    
    [self.view addSubview:topLine];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 97, kScreenWidth, kScreenHeight - 64 - 49 - 44 - 33) style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _nowBankNameArray = [NSArray arrayWithArray:_bankNameArray];
    
    [self.view addSubview:_tableView];

    //底部确认支付按钮
    UIButton *goToPay = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [goToPay setImage:[UIImage imageNamed:@"goToPay"] forState:UIControlStateNormal];
    goToPay.frame = CGRectMake((kScreenWidth - 144) / 2, kScreenHeight - 49, 150, 40);
    [goToPay addTarget:self action:@selector(goToPay) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:goToPay];
    
    //底部订单详情
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49 - 44, kScreenWidth, 40)];
    
    bottomLabel.backgroundColor = COLOR(22, 108, 175, 1);
    bottomLabel.text = [NSString stringWithFormat:@"订单金额:%@",_price];
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.font = [UIFont systemFontOfSize:18];
    
    [self.view addSubview:bottomLabel];
    
    UIImageView *detailImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, kScreenHeight - 49 - 44 - 8, 50, 50)];
    
    detailImage.image = [UIImage imageNamed:@"detail"];
    
    [self.view addSubview:detailImage];
}

/**
 点击确认支付按钮方法进入Umpay支付页面
 
 如果支付失败，跳转到待支付订单页面
 */
- (void)goToPay
{
    NSString *bankName = self.nowBankNameArray[self.selectedIndexPath.row];
    YunLog(@"bankName = %@", bankName);
    
    if ([Umpay pay:self.tradeNO cardType:@"1" bankName:bankName rootViewController:self.navigationController delegate:self]){
        YunLog(@"umpay success");
    } else {
        YunLog(@"umpay failure");
        
        OrderListViewController *order = [[OrderListViewController alloc] init];
        order.orderType = WaitingForPay;
        order.selectedOrderTypeIndex = 1;
        
        [self.navigationController pushViewController:order animated:YES];
    }
    
//    if ([Umpay pay:self.tradeNO cardType:@"1" bankName:bankName rootViewController:[[UIApplication sharedApplication] delegate].window.rootViewController delegate:self]){
//        YunLog(@"umpay success");
//    } else {
//        YunLog(@"umpay failure");
//        
//        OrderListViewController *order = [[OrderListViewController alloc] init];
//        order.orderType = WaitingForPay;
//        
//        [self.navigationController pushViewController:order animated:YES];
//    }
}

#pragma mark - UmpayDelegate -

/**
 Umpay支付

 @param orderId       订单的Id
 @param resultCode    支付后返回的结果
 @param resultMessage 返回的结果信息
 */
- (void)onPayResult:(NSString *)orderId resultCode:(NSString *)resultCode resultMessage:(NSString *)resultMessage
{
    if ([resultCode isEqualToString:kUmpaykSuccessCode]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:resultMessage delay:1.0];
        YunLog(@"_index = %ld", (unsigned long)_index);
        
        [self.navigationController popToViewController:self.navigationController.viewControllers[_index] animated:NO];
//        double delayInSeconds = 1.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//            
//            [self.navigationController popViewControllerAnimated:YES];
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModalControllerWithPaySucceed object:self];
            });
//        });
    } else {
        if ([resultCode isEqualToString:kUmpayFailureCode]) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:resultMessage delay:1.0];
        
            _selectedIndexPath = nil;

            YunLog(@"_index = %ld", (unsigned long)_index);

            [self.navigationController popToViewController:self.navigationController.viewControllers[_index] animated:NO];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModalController object:self];
            });
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"网络异常,请稍后再试" delay:1.0];
        
            [self.navigationController popToViewController:self.navigationController.viewControllers[_index] animated:NO];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModalController object:self];
            });
        }
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nowBankNameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_nowBankNameArray.count <= 7 )
    {
     return (kScreenHeight - 64 - 33 - 49 - 40) / _nowBankNameArray.count;
    }
    else
    {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"bankID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    CGSize size = [_nowBankNameArray[indexPath.row] sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];
    
    CGFloat cellHeight = (kScreenHeight - 64 - 33 - 49 - 40) / _nowBankNameArray.count;
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    } else
    {
        if (cell.contentView.subviews.count > 0)
        {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
    
    if ([self.selectedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    if (_nowBankNameArray.count <= 7)
    {
        CGFloat imageHeigt = cellHeight - 16;
        CGFloat imageWidth = imageHeigt;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, imageWidth, imageHeigt)];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bank_%ld", (long)indexPath.row + 1]];
        
        [cell.contentView addSubview:imageView];
        
        UILabel *bankNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageWidth + 25, 0, 150, cellHeight)];
        bankNameLabel.text = _nowBankNameArray[indexPath.row];
        
        [cell.contentView addSubview:bankNameLabel];
    }
    else
    {
        UILabel *bankNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, size.width + 20, 44)];
        bankNameLabel.textAlignment = NSTextAlignmentCenter;
        bankNameLabel.text = _nowBankNameArray[indexPath.row];
        
        YunLog(@"_nowBankNameArray[indexPath.row] = %@", _nowBankNameArray[indexPath.row]);
        
        [cell.contentView addSubview:bankNameLabel];

//        cell.textLabel.text = _nowBankNameArray[indexPath.row];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_nowBankNameArray.count <= 7)
    {
        if (indexPath.row == 6)
        {
            if (self.selectedIndexPath)
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                _selectedIndexPath = nil;
            }
            
            _nowBankNameArray = [NSArray arrayWithArray:_moreBankNameArray];
            
            [tableView reloadData];
        }
        else
        {
            if (self.selectedIndexPath)
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            self.selectedIndexPath = indexPath;
        }
    }
    else
    {
        if (self.selectedIndexPath)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        self.selectedIndexPath = indexPath;
    }
}

@end
