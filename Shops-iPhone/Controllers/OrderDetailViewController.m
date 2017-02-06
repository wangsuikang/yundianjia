//
//  OrderDetailViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-27.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "OrderDetailViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"
#import "Tool.h"

// Views
#import "UIButtonForBarButton.h"
#import "KLCPopup.h"
#import "YunShareView.h"

// Controllers
#import "PayResultViewController.h"
#import "WebViewController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "ProductDetailViewController.h"
#import "ChooseBankViewController.h"
#import "RateProductViewController.h"

// Categories
#import "NSObject+NullToString.h"
#import "UIImageView+AFNetworking.h"

// Protocols
#import "WXPayDelegate.h"

// Libraries
#import "Umpay.h"

@interface OrderDetailViewController () <UmpayDelegate, UIActionSheetDelegate, UIAlertViewDelegate, WXPayDelegate, YunShareViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary   *detail;

@property (nonatomic, strong) UIScrollView           *scrollView;
@property (nonatomic, strong) UIView                 *bottomView;
@property (nonatomic, strong) UIView                 *statusContainer;

/// 点击的店铺名称
@property (nonatomic, copy  ) NSString               *shopCode;

@property (nonatomic, strong) AFHTTPRequestOperation *payOp;
@property (nonatomic, strong) MBProgressHUD          *hud;

@property (nonatomic, strong) UITableView  *tableView;

/// 滚动视图的高度
@property (nonatomic, assign) CGFloat scrollViewHeight;

/// 支付方式图片
@property (nonatomic, strong) UIImageView *payStyle;

/// 支付方式文字
@property (nonatomic, strong) UILabel *payStyleLabel;

/// 订单的Id
@property (nonatomic, copy) NSString *subOrderID;

/// 点击的商品名称
@property (nonatomic, copy) NSString *code;

/// 父订单编号
@property (nonatomic, copy) NSString *number;

/// 父订单总价
@property (nonatomic, copy) NSString *totalPrice;

/// 支付方式数组
@property (nonatomic, strong) NSMutableArray *paymentArr;

/// 各种支付方式对应的图标和值
@property (nonatomic, strong) NSDictionary *paymentDic;

@property (nonatomic, assign) BOOL isRefresh;
@end

@implementation OrderDetailViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kLightBlackColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"订单详情";
        
        self.navigationItem.titleView = naviTitle;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        backItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [TalkingData trackPageEnd:@"离开订单详情页面"];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [kNotificationCenter addObserver:self selector:@selector(reloadView) name:kOrderDetailNotificationReload object:nil];
    [kNotificationCenter addObserver:self selector:@selector(backToPrev:) name:kOrderPaySucceedNotification object:nil];

    _paymentDic = @{@"4":@"pay_weixin",
                    @"1":@"pay_ali",
                    @"3":@"upay",
                    @"10" : @"other"};
    
    _paymentArr = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];

    [self getDataSource];

//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    _scrollView.backgroundColor = kGrayColor;
//    if (kDeviceOSVersion < 7.0 || _isRefresh) {
//        _scrollView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64);
//    }
    
//    [self.view addSubview:_scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GetDataSource -

- (void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _isReadyToPay ? kScreenHeight - 37 : kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
}

- (void)getDataSource
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AppDelegate *appDelegate = kAppDelegate;
//    
    NSDictionary *params = @{@"oid"                     :   kNullToString(_orderID),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *detailURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kOrderDetailURL params:params];
    
    if (_isReadyToPay) {
        YunLog(@"order detailURL = %@", detailURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:detailURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"order detail responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                YunLog(@"order status = %@", [[[responseObject objectForKey:@"data"] objectForKey:@"order"] objectForKey:@"status"]);
                
                [_hud hide:YES];
                
                _detail = [NSMutableDictionary dictionaryWithDictionary:[[responseObject objectForKey:@"data"] objectForKey:@"order"]];
                _number = [_detail objectForKey:@"no"];
                _totalPrice = [_detail objectForKey:@"total_price"];
                
                NSArray *payArr = kNullToArray([_detail objectForKey:@"payment_categories"]);
                
                [_paymentArr removeAllObjects];
                
                for (NSDictionary *payDic in payArr) {
                    [_paymentArr addObject:kNullToString([payDic objectForKey:@"value"])];
                }
                
                YunLog(@"_detail_down = %@", _detail);
                
                if ([[_detail objectForKey:@"status"] isEqualToString:@"待付款"]) {
                    //                _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
                    //
                    //                if (_isRefresh) {
                    //                    _scrollView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 48 - 64);
                    //                }
                    
                    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 37, kScreenWidth + 2, 37)];
                    _bottomView.backgroundColor = [UIColor whiteColor];
                    
                    [self.view addSubview:_bottomView];
                    
//                    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 120, _bottomView.frame.size.height)];
//                    total.backgroundColor = kClearColor;
//                    total.font = kMidFont;
//                    total.textColor = kOrangeColor;
//                    total.text = [NSString stringWithFormat:@"订单金额为￥%@", [_detail objectForKey:@"total_price"]];
//                    
//                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:total.text];
//                    
//                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 6)];
//
//                    total.attributedText = str;
//
//                    [_bottomView addSubview:total];
                    
                    if (![_detail[@"payment_type"] isEqualToString:@"9"]) {
                        UIButton *goToBuy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 0, 110, 37)];
                        goToBuy.titleLabel.font = kNormalFont;
                        goToBuy.backgroundColor = [UIColor orangeColor];
                        goToBuy.tag = [[_detail objectForKey:@"id"] integerValue];
                        [goToBuy setTitle:@"立即支付" forState:UIControlStateNormal];
                        [goToBuy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [goToBuy addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [_bottomView addSubview:goToBuy];
                        
                        UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 0, 110, 37)];
                        cancel.titleLabel.font = kNormalFont;
                        cancel.backgroundColor = COLOR(75, 74, 75, 1);
                        [cancel setTitle:@"取消订单" forState:UIControlStateNormal];
                        cancel.titleLabel.font = kNormalFont;
                        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [cancel addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [_bottomView addSubview:cancel];
                    }
                } else if ([[_detail objectForKey:@"status"] isEqualToString:@"已取消"]) {
                    [_bottomView removeFromSuperview];
                    _bottomView = nil;
                }
                
                if (![[_detail objectForKey:@"status"] isEqualToString:@"已取消"] && ![[_detail objectForKey:@"status"] isEqualToString:@"待付款"]) {
                    
                    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 30, 32)];
                    [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
                    [share addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
                    
                    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:share];
                    shareItem.style = UIBarButtonItemStylePlain;
                    
                    self.navigationItem.rightBarButtonItem = shareItem;
                }
                
                [_tableView reloadData];
            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                [Tool resetUser];
                
                [self backToPrev:nil];
            } else {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"order detail error = %@", error);
            
            if (![operation isCancelled]) {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            }
        }];
    } else {
        NSDictionary *params = @{@"number"                  :   kNullToString(_orderID),
                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
        NSString *detailURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kSubOrderDetailURL, kNullToString(_orderID)] params:params];
        
        
        YunLog(@"order detailURL = %@", detailURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:detailURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"order detail responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                YunLog(@"order status = %@", [[[responseObject objectForKey:@"data"] objectForKey:@"order"] objectForKey:@"status"]);
                
                [_hud hide:YES];
                
                _detail = [[responseObject objectForKey:@"data"] objectForKey:@"order"];
                _number = [_detail objectForKey:@"no"];
                _totalPrice = [_detail objectForKey:@"pay_price"];
                
                NSArray *payArr = kNullToArray([_detail objectForKey:@"payment_categories"]);
                
                [_paymentArr removeAllObjects];
                
                for (NSDictionary *payDic in payArr) {
                    [_paymentArr addObject:kNullToString([payDic objectForKey:@"value"])];
                }
                
                YunLog(@"_detail_down = %@", _detail);
                
                if (![[_detail objectForKey:@"status"] isEqualToString:@"待发货"] && ![[_detail objectForKey:@"status"] isEqualToString:@"已取消"]) {
                    _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 37);
                    
                    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 37, kScreenWidth + 2, 37)];
                    _bottomView.backgroundColor = [UIColor whiteColor];
                    
                    [self.view addSubview:_bottomView];
                    
                    if ([[_detail objectForKey:@"status"] isEqualToString:@"订单完成"]) {
                        UIButton *goToRate = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 0, 110, 37)];
                        goToRate.titleLabel.font = kNormalFont;
                        goToRate.backgroundColor = [UIColor orangeColor];
                        goToRate.tag = [[_detail objectForKey:@"id"] integerValue];
                        [goToRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        if ([_detail[@"uncomment_count"] isEqualToString:@"1"]) {
                            [goToRate addTarget:self action:@selector(goToRate:) forControlEvents:UIControlEventTouchUpInside];
                            [goToRate setTitle:@"去评价" forState:UIControlStateNormal];
                        } else {
                            [goToRate removeTarget:self action:@selector(goToRate:) forControlEvents:UIControlEventTouchUpInside];
                            [goToRate setTitle:@"已评价" forState:UIControlStateNormal];
                        }
                        
                        [_bottomView addSubview:goToRate];
                    } else if ([[_detail objectForKey:@"status"] isEqualToString:@"已发货"]) {
                        // 确认收货按钮
                        UIButton *confirm = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 0, 110, 37)];
//                        confirm.tag = [[order objectForKey:@"id"] integerValue];
                        [confirm setBackgroundColor:[UIColor orangeColor]];
                        [confirm setTitle:@"确认收货" forState:UIControlStateNormal];
                        confirm.titleLabel.font = kNormalFont;
                        [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [confirm addTarget:self action:@selector(received:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [_bottomView addSubview:confirm];
                        
                        // 查看物流按钮
                        UIButton *logistics = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110 - 110, 0, 110, 37)];
//                        logistics.tag = indexPath.row;
                        logistics.backgroundColor = COLOR(75, 74, 75, 0.8);
                        [logistics setTitle:@"查看物流" forState:UIControlStateNormal];
                        logistics.titleLabel.font = kNormalFont;
                        [logistics setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [logistics addTarget:self action:@selector(goToExpress:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [_bottomView addSubview:logistics];
                    }
                }
                
                [_tableView reloadData];
            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                [Tool resetUser];
                
                [self backToPrev:nil];
            } else {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"order detail error = %@", error);
            
            if (![operation isCancelled]) {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            }
        }];
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isReadyToPay) {
        return [_detail[@"sub_orders"] count] + 3;
    }
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isReadyToPay) {
        NSInteger conut = [_detail[@"sub_orders"] count] + 3;
        
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return _paymentArr.count;
        } else if (section == conut - 1) {
            return 4;
        } else {
            return 3;
        }
    } else {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return _paymentArr.count;
        } else if (section == 3) {
            return 4;
        } else {
            return 3;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!_isReadyToPay && section == 1) {
        return 0.01f;
    }
    return 37;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *address = kNullToString([_detail objectForKey:@"consignee_address"]);
    
    CGSize addressSize = [address sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];
    
    if (_isReadyToPay) {
        NSInteger conut = [_detail[@"sub_orders"] count] + 3;
        
        if (indexPath.section == 0) {
            return 50 + addressSize.height;
        } else if (indexPath.section == 1) {
            return 70;
        } else if (indexPath.section == conut - 1) {
            return 37;
        } else {
            NSDictionary *sunOrder = _detail[@"sub_orders"][indexPath.section - 2];
            
            if (indexPath.row == 0 || indexPath.row == 1) {
                return 37;
            } else {
                return 93 * [sunOrder[@"items"] count] - 3;
            }
        }
    } else {
        if (indexPath.section == 0) {
            return 50 + addressSize.height;
        } else if (indexPath.section == 1) {
        } else if (indexPath.section == 3) {
            return 37;
        } else {
            if (indexPath.row == 0 || indexPath.row == 1) {
                return 37;
            } else {
                return 93 * [_detail[@"items"] count] - 3;
            }
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = COLOR(245, 244, 245, 1);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 17, 17)];

    [backView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, kScreenWidth - 40, 37)];
    titleLabel.textColor = kLightBlackColor;
    titleLabel.font = kMidFont;
    
    [backView addSubview:titleLabel];
    
    if (_isReadyToPay) {
        NSInteger conut = [_detail[@"sub_orders"] count] + 3;
        
        if (section == 0) {
            imageView.image = [UIImage imageNamed:@"addres"];
            titleLabel.text = @"收货人信息";
        } else if (section == 1) {
            imageView.image = [UIImage imageNamed:@"pay"];
            titleLabel.text = @"支付信息";
        } else if (section == conut - 1) {
            imageView.image = [UIImage imageNamed:@"money"];
            titleLabel.text = @"费用信息";
        } else {
            imageView.image = [UIImage imageNamed:@"good"];
            titleLabel.text = @"商品信息";
        }
    } else {
        if (section == 0) {
            imageView.image = [UIImage imageNamed:@"addres"];
            titleLabel.text = @"收货人信息";
        } else if (section == 1) {
            imageView.image = [UIImage imageNamed:@"pay"];
            titleLabel.text = @"支付信息";
            
            return nil;
        } else if (section == 3) {
            imageView.image = [UIImage imageNamed:@"money"];
            titleLabel.text = @"费用信息";
        } else {
            imageView.image = [UIImage imageNamed:@"good"];
            titleLabel.text = @"商品信息";
        }
    }
    
    return backView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!_isReadyToPay && section == 1) {
        return 0.01f;
    }
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *moneyArr = [NSArray array];
    
    if (_isReadyToPay) {
        moneyArr = @[@{@"title" : @"总价：" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"original_price"]]},
                     @{@"title" : @"运费：" , @"value" : [NSString stringWithFormat:@"¥%0.2f", [_detail[@"total_price"] floatValue] - [_detail[@"original_price"] floatValue]]},
                     @{@"title" : @"优惠：" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"discount_price"]]},
                     @{@"title" : @"需付总金额" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"total_price"]]}];
    } else {
        moneyArr = @[@{@"title" : @"总价：" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"original_price"]]},
                     @{@"title" : @"运费：" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"shipment_price"]]},
                     @{@"title" : @"优惠：" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"discount_price"]]},
                     @{@"title" : @"需付总金额" , @"value" : [NSString stringWithFormat:@"¥%@", _detail[@"pay_price"]]}];

    }
    
    NSArray *arr = @[@{@"icon" : @"zfbPay_icon" , @"title" : @"支付宝", @"no" :  @"1"},
                     @{@"icon" : @"" , @"title" : @"", @"no" :  @""},
                     @{@"icon" : @"UpayPay_icon" , @"title" : @"U付", @"no" :  @"3"},
                     @{@"icon" : @"weixinPay_icon" , @"title" : @"微信", @"no" :  @"4"},
                     @{@"icon" : @"" , @"title" : @"", @"no" :  @""},
                     @{@"icon" : @"" , @"title" : @"", @"no" :  @""},
                     @{@"icon" : @"" , @"title" : @"", @"no" :  @""},
                     @{@"icon" : @"" , @"title" : @"", @"no" :  @""},
                     @{@"icon" : @"" , @"title" : @"", @"no" :  @""},
                     @{@"icon" : @"UpayPay_icon" , @"title" : @"U付", @"no" :  @"3"}];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *str in _paymentArr)
    {
        NSInteger value = [str integerValue] - 1;
        [array addObject:arr[value]];
    }

    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    if (_isReadyToPay) {
        NSInteger conut = [_detail[@"sub_orders"] count] + 3;
        
        if (indexPath.section == 0) {
            // 用户名
            UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (kScreenWidth - 20) / 2, 20)];
            accountName.backgroundColor = kClearColor;
            accountName.font = kSmallFont;
            accountName.text = kNullToString([_detail objectForKey:@"consignee_name"]);
            accountName.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:accountName];
            
            // 手机号
            UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake(10 + (kScreenWidth - 20) / 2, 10, (kScreenWidth - 20) / 2, 20)];
            accountPhone.backgroundColor = kClearColor;
            accountPhone.font = kSmallFont;
            accountPhone.text = kNullToString([_detail objectForKey:@"consignee_phone"]);
            accountPhone.textAlignment = NSTextAlignmentRight;
            accountPhone.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:accountPhone];
            
            // 地址
            NSString *address = kNullToString([_detail objectForKey:@"consignee_address"]);
            
            CGSize addressSize = [address sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];
            
            UILabel *accountAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, kScreenWidth - 20, addressSize.height)];
            accountAddress.backgroundColor = kClearColor;
            accountAddress.numberOfLines = 0;
            accountAddress.text = address;
            accountAddress.font = kSmallFont;
            accountAddress.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:accountAddress];
        } else if (indexPath.section == 1) {
            UIImageView *selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30, 10, 10)];
//            selectImage.backgroundColor = kOrangeColor;
            selectImage.image = [UIImage imageNamed:@"payType_unselscted"];
            
            NSInteger payCellIndex = 0;
           
            for (int i = 0; i < [array count]; i ++) {
                if ([_detail[@"payment_type"] isEqualToString:array[i][@"no"]]) {
                    payCellIndex = i;
                }
            }
            
            if (indexPath.row == payCellIndex) {
                selectImage.image = [UIImage imageNamed:@"payType_selscted"];
            }
            
            [cell.contentView addSubview:selectImage];
            
            UIImageView *selectTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(40, 17.5, 100, 35)];
            selectTypeImage.image = [UIImage imageNamed:array[indexPath.row][@"icon"]];
            
            [cell.contentView addSubview:selectTypeImage];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 69.5, kScreenWidth, 0.5)];
            line.backgroundColor = kGrayColor;
            
            [cell.contentView addSubview:line];
        } else if (indexPath.section == conut - 1) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 37)];
            title.backgroundColor = kClearColor;
            title.font = kSmallFont;
            title.text = moneyArr[indexPath.row][@"title"];
            title.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:title];
            
            UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, kScreenWidth - 130, 37)];
            money.backgroundColor = kClearColor;
            money.font = kSmallFont;
            money.text = moneyArr[indexPath.row][@"value"];
            money.textAlignment = NSTextAlignmentRight;
            money.textColor = kLightBlackColor;
            if (indexPath.row == 3) {
                money.textColor = kOrangeColor;
            }
            
            [cell.contentView addSubview:money];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 36.5, kScreenWidth, 0.5)];
            line.backgroundColor = kGrayColor;
            
            [cell.contentView addSubview:line];
        } else {
            NSDictionary *sunOrder = _detail[@"sub_orders"][indexPath.section - 2];
            
            if (indexPath.row == 0) {
                CGSize buttonSize = [[NSString stringWithFormat:@"店铺：%@", sunOrder[@"shop_name"]] sizeWithFont:kMidFont size:CGSizeMake(9999, 9999)];
                UIButton *shopName = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, buttonSize.width + 1, 37)];
                [shopName setTitle:[NSString stringWithFormat:@"店铺：%@", sunOrder[@"shop_name"]] forState:UIControlStateNormal];
                //    shopName.backgroundColor = kOrangeColor;
                [shopName setTitleColor:kLightBlackColor forState:UIControlStateNormal];
                shopName.titleLabel.font = kMidFont;
                shopName.tag = indexPath.section;
                [shopName addTarget:self action:@selector(pushToShop:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.contentView addSubview:shopName];
            } else if (indexPath.row == 1) {
                UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, (kScreenWidth - 40) / 2, 37)];
                shopName.text = [NSString stringWithFormat:@"订单编号：%@", sunOrder[@"no"]];
                //    shopName.backgroundColor = kOrangeColor;
                shopName.textColor = kLightBlackColor;
                shopName.font = kSmallFont;
                shopName.adjustsFontSizeToFitWidth = YES;
                
                [cell.contentView addSubview:shopName];
                
                UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shopName.frame) + 20, 0, (kScreenWidth - 40) / 2, 37)];
                time.text = [NSString stringWithFormat:@"时间：%@", sunOrder[@"create_at"]];
                //    shopName.backgroundColor = kOrangeColor;
                time.textColor = kLightBlackColor;
                time.font = kSmallFont;
                time.textAlignment = NSTextAlignmentRight;
                time.adjustsFontSizeToFitWidth = YES;

                [cell.contentView addSubview:time];
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
                line.backgroundColor = kGrayColor;
                
                [cell.contentView addSubview:line];
            } else {
                for (int i = 0; i < [sunOrder[@"items"] count]; i ++) {
                    NSDictionary *item = sunOrder[@"items"][i];
                    
                    CGFloat y = i * 93;
                    
                    UIButton *itemBackView = [[UIButton alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 90)];
                    itemBackView.backgroundColor = COLOR(245, 244, 245, 1);
                    [itemBackView addTarget:self action:@selector(pushToProduct:) forControlEvents:UIControlEventTouchUpInside];
                    itemBackView.tag = indexPath.section * 10 + indexPath.row;
                    [cell.contentView addSubview:itemBackView];
                    
                    UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 70, 70)];
                    [itemIcon setImageWithURL:[NSURL URLWithString:kNullToString([item objectForKey:@"icon_url"])] placeholderImage:[UIImage imageNamed:@"default_image"]];
                    
                    [itemBackView addSubview:itemIcon];
                    
                    UILabel *itemPrice = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(itemIcon.frame)+ 15, CGRectGetMaxY(itemIcon.frame) - 12, kScreenWidth - CGRectGetMaxX(itemIcon.frame) - 15 * 2, 12)];
                    itemPrice.text = [NSString stringWithFormat:@"¥%@ x %@", item[@"price"], item[@"count"]];
                    //        itemPrice.backgroundColor = kOrangeColor;
                    itemPrice.textColor = kLightBlackColor;
                    itemPrice.font = kSmallFont;
                    
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:itemPrice.text];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange([item[@"price"] length] + 2, [[NSString stringWithFormat:@"%@", item[@"count"]] length] + 2)];
                    
                    itemPrice.attributedText = str;
                    
                    [itemBackView addSubview:itemPrice];
                    
                    UILabel *itemName = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(itemIcon.frame)+ 15, 10, kScreenWidth - CGRectGetMaxX(itemIcon.frame) - 15 * 2, 30)];
                    itemName.text = item[@"name"];
                    //        itemName.backgroundColor = kOrangeColor;
                    itemName.numberOfLines = 0;
                    itemName.textColor = kLightBlackColor;
                    itemName.font = kMidFont;
                    
                    [itemBackView addSubview:itemName];
                    
                    UILabel *itemVariantName = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(itemIcon.frame)+ 15, CGRectGetMaxY(itemName.frame), kScreenWidth - CGRectGetMaxX(itemIcon.frame) - 15 * 2, 20)];
                    itemVariantName.text = item[@"product_variant_name"];
                    //        itemVariantName.backgroundColor = kRedColor;
                    itemVariantName.numberOfLines = 0;
                    itemVariantName.textColor = [UIColor lightGrayColor];
                    itemVariantName.font = kSmallFont;
                    
                    [itemBackView addSubview:itemVariantName];
                }
            }
        }
    } else {
        if (indexPath.section == 0) {
            // 用户名
            UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (kScreenWidth - 20) / 2, 20)];
            accountName.backgroundColor = kClearColor;
            accountName.font = kSmallFont;
            accountName.text = kNullToString([_detail objectForKey:@"consignee_name"]);
            accountName.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:accountName];
            
            // 手机号
            UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake(10 + (kScreenWidth - 20) / 2, 10, (kScreenWidth - 20) / 2, 20)];
            accountPhone.backgroundColor = kClearColor;
            accountPhone.font = kSmallFont;
            accountPhone.text = kNullToString([_detail objectForKey:@"consignee_phone"]);
            accountPhone.textAlignment = NSTextAlignmentRight;
            accountPhone.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:accountPhone];
            
            // 地址
            NSString *address = kNullToString([_detail objectForKey:@"consignee_address"]);
            
            CGSize addressSize = [address sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];
            
            UILabel *accountAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, kScreenWidth - 20, addressSize.height)];
            accountAddress.backgroundColor = kClearColor;
            accountAddress.numberOfLines = 0;
            accountAddress.text = address;
            accountAddress.font = kSmallFont;
            accountAddress.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:accountAddress];
        } else if (indexPath.section == 1) {
            
        } else if (indexPath.section == 3) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 37)];
            title.backgroundColor = kClearColor;
            title.font = kSmallFont;
            title.text = moneyArr[indexPath.row][@"title"];
            title.textColor = kLightBlackColor;
            
            [cell.contentView addSubview:title];
            
            UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, kScreenWidth - 130, 37)];
            money.backgroundColor = kClearColor;
            money.font = kSmallFont;
            money.text = moneyArr[indexPath.row][@"value"];
            money.textAlignment = NSTextAlignmentRight;
            money.textColor = kLightBlackColor;
            if (indexPath.row == 3) {
                money.textColor = kOrangeColor;
            }
            
            [cell.contentView addSubview:money];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 36.5, kScreenWidth, 0.5)];
            line.backgroundColor = kGrayColor;
            
            [cell.contentView addSubview:line];
        } else {
            if (indexPath.row == 0) {
                CGSize buttonSize = [[NSString stringWithFormat:@"店铺：%@", _detail[@"shop_name"]] sizeWithFont:kMidFont size:CGSizeMake(9999, 9999)];
                UIButton *shopName = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, buttonSize.width + 1, 37)];
                [shopName setTitle:[NSString stringWithFormat:@"店铺：%@", _detail[@"shop_name"]] forState:UIControlStateNormal];
                //    shopName.backgroundColor = kOrangeColor;
                [shopName setTitleColor:kLightBlackColor forState:UIControlStateNormal];
                shopName.titleLabel.font = kMidFont;
                shopName.tag = indexPath.section;
                [shopName addTarget:self action:@selector(pushToShop:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.contentView addSubview:shopName];
            } else if (indexPath.row == 1) {
                UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 37)];
                shopName.text = [NSString stringWithFormat:@"订单编号：%@", _detail[@"no"]];
                //    shopName.backgroundColor = kOrangeColor;
                shopName.textColor = kLightBlackColor;
                shopName.font = kSmallFont;
                shopName.adjustsFontSizeToFitWidth = YES;

                [cell.contentView addSubview:shopName];
                
                UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shopName.frame) + 20, 0, (kScreenWidth - 40) / 2, 37)];
                time.text = [NSString stringWithFormat:@"时间：%@", _detail[@"create_at"]];
                //    shopName.backgroundColor = kOrangeColor;
                time.textColor = kLightBlackColor;
                time.font = kSmallFont;
                time.textAlignment = NSTextAlignmentRight;
                time.adjustsFontSizeToFitWidth = YES;

                [cell.contentView addSubview:time];
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
                line.backgroundColor = kGrayColor;
                
                [cell.contentView addSubview:line];
            } else {
                for (int i = 0; i < [_detail[@"items"] count]; i ++) {
                    NSDictionary *item = _detail[@"items"][i];
                    
                    CGFloat y = i * 93;
                    
                    UIButton *itemBackView = [[UIButton alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 90)];
                    itemBackView.backgroundColor = COLOR(245, 244, 245, 1);
                    [itemBackView addTarget:self action:@selector(pushToProduct:) forControlEvents:UIControlEventTouchUpInside];
                    
                    itemBackView.tag = indexPath.row;
                    [cell.contentView addSubview:itemBackView];
                    
                    UIImageView *itemIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 70, 70)];
                    [itemIcon setImageWithURL:[NSURL URLWithString:kNullToString([item objectForKey:@"icon_url"])] placeholderImage:[UIImage imageNamed:@"default_image"]];
                    
                    [itemBackView addSubview:itemIcon];
                    
                    UILabel *itemPrice = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(itemIcon.frame)+ 15, CGRectGetMaxY(itemIcon.frame) - 12, kScreenWidth - CGRectGetMaxX(itemIcon.frame) - 15 * 2, 12)];
                    itemPrice.text = [NSString stringWithFormat:@"¥%@ x %@", item[@"price"], item[@"quantity"]];
                    //        itemPrice.backgroundColor = kOrangeColor;
                    itemPrice.textColor = kLightBlackColor;
                    itemPrice.font = kSmallFont;
                    
                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:itemPrice.text];
                    [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange([item[@"price"] length] + 2, [[NSString stringWithFormat:@"%@", item[@"quantity"]] length] + 2)];
                    
                    itemPrice.attributedText = str;
                    
                    [itemBackView addSubview:itemPrice];
                    
                    UILabel *itemName = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(itemIcon.frame)+ 15, 10, kScreenWidth - CGRectGetMaxX(itemIcon.frame) - 15 * 2, 30)];
                    itemName.text = item[@"name"];
                    //        itemName.backgroundColor = kOrangeColor;
                    itemName.numberOfLines = 0;
                    itemName.textColor = kLightBlackColor;
                    itemName.font = kMidFont;
                    
                    [itemBackView addSubview:itemName];
                    
                    UILabel *itemVariantName = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetMaxX(itemIcon.frame)+ 15, CGRectGetMaxY(itemName.frame), kScreenWidth - CGRectGetMaxX(itemIcon.frame) - 15 * 2, 20)];
                    itemVariantName.text = item[@"product_variant_name"];
                    //        itemVariantName.backgroundColor = kRedColor;
                    itemVariantName.numberOfLines = 0;
                    itemVariantName.textColor = [UIColor lightGrayColor];
                    itemVariantName.font = kSmallFont;
                    
                    [itemBackView addSubview:itemVariantName];
                }
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && _isReadyToPay) {
        [self changeType:_paymentArr[indexPath.row]];
    }
}

#pragma mark - Private Functions -

- (void)reloadView
{
    [self getDataSource];
}

- (void)backToPrev:(UIButton *)sender
{
    if ([_payOp isExecuting]) {
        [_payOp cancel];
    }
    
    if (_hud) [_hud hide:NO];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isBack"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)initLayout
//{
//    int headHeight = 40;
//    
//    int height = 10;
//    
//    /*
//     * category = 1, 普通订单
//     * category = 2, 礼物订单
//     */
//    
//    if ([[_detail objectForKey:@"category"] integerValue] == 1) {
//        // 收货人信息
//        UIView *userContainer = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, headHeight)];
//        userContainer.backgroundColor = COLOR(245, 244, 245, 1);
//        
//        [_scrollView addSubview:userContainer];
//        
//        height += userContainer.frame.size.height;
//        
//        UIImageView *userBubble = [[UIImageView alloc] initWithFrame:CGRectMake(10, (headHeight - 16) / 2, 16, 16)];
//        userBubble.image = [UIImage imageNamed:@"addres"];
//        
//        [userContainer addSubview:userBubble];
//        
//        UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, kScreenWidth - 46, userContainer.frame.size.height)];
//        userName.backgroundColor = kClearColor;
//        userName.font = kNormalFont;
//        userName.text = @"收货人信息";
//        
//        [userContainer addSubview:userName];
//        
//        // 用户名
//        UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(10, height, (kScreenWidth - 20) / 2, 40)];
//        accountName.backgroundColor = kClearColor;
//        accountName.font = kNormalFont;
//        accountName.text = kNullToString([_detail objectForKey:@"consignee_name"]);
//        accountName.textColor = [UIColor grayColor];
//        
//        [_scrollView addSubview:accountName];
//        
//        // 手机号
//        UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake(10 + (kScreenWidth - 20) / 2, height, (kScreenWidth - 20) / 2, 40)];
//        accountPhone.backgroundColor = kClearColor;
//        accountPhone.font = kNormalFont;
//        accountPhone.text = kNullToString([_detail objectForKey:@"consignee_phone"]);
//        accountPhone.textAlignment = NSTextAlignmentRight;
//        accountPhone.textColor = [UIColor grayColor];
//        
//        [_scrollView addSubview:accountPhone];
//        
//        height += 20;
//        
//        // 地址
//        NSString *address = kNullToString([_detail objectForKey:@"consignee_address"]);
//        
//        CGSize addressSize = [address sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];
//        
//        UILabel *accountAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 15, kScreenWidth - 20, addressSize.height)];
//        accountAddress.backgroundColor = kClearColor;
//        accountAddress.numberOfLines = 0;
//        accountAddress.text = address;
//        accountAddress.font = kNormalFont;
//        accountAddress.textColor = [UIColor grayColor];
//        
//        [_scrollView addSubview:accountAddress];
//        
//        height += addressSize.height + 10;
//        
//        UIImageView *accountLine = [self splitLine:CGRectMake(0, height +10, kScreenWidth, 1)];
//        
//        [_scrollView addSubview:accountLine];
//        
//        // 白色背景
//        UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userContainer.frame), kScreenSize.width, height - CGRectGetMaxY(userContainer.frame) + 10)];
//        backView1.backgroundColor = [UIColor whiteColor];
//        
//        [_scrollView addSubview:backView1];
//        
//        [_scrollView sendSubviewToBack:backView1];
//        
//        height += 1 + 20;
//    }
//    
//    NSString *payTime = kNullToString([_detail objectForKey:@"payment_at"]);
//    NSString *payTypeDesc = kNullToString(_detail[@"payment_type_desc"]);
//    NSString *invoice = kNullToString(_detail[@"invoice"]);
//    NSString *note = kNullToString(_detail[@"note"]);
//    
//    NSMutableArray *times = [[NSMutableArray alloc] init];
//    
//    if (![payTime isEqualToString:@""]) [times addObject:@{@"时间":payTime}];
//    if (![payTypeDesc isEqualToString:@""]) [times addObject:@{@"类型":payTypeDesc}];
//    if (![invoice isEqualToString:@""]) [times addObject:@{@"发票":invoice}];
//    if (![note isEqualToString:@""]) [times addObject:@{@"备注":note}];
//    
//    if (times.count > 0) {
//        UIView *timeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, headHeight)];
//        timeContainer.backgroundColor = COLOR(245, 244, 245, 1);
//        
//        [_scrollView addSubview:timeContainer];
//        
//        height += timeContainer.frame.size.height;
//        
//        UIImageView *timeBubble = [[UIImageView alloc] initWithFrame:CGRectMake(10, (headHeight - 16) / 2, 16, 16)];
//        timeBubble.image = [UIImage imageNamed:@"pay"];
//        
//        [timeContainer addSubview:timeBubble];
//        
//        UILabel *timeTile = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, kScreenWidth - 46, timeContainer.frame.size.height)];
//        timeTile.backgroundColor = kClearColor;
//        timeTile.font = kNormalFont;
//        timeTile.text = @"支付信息";
//        
//        [timeContainer addSubview:timeTile];
//        
//        UIView *backView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(timeContainer.frame), kScreenSize.width, height +(40 + 1) * times.count - CGRectGetMaxY(timeContainer.frame))];
//        backView2.backgroundColor = [UIColor whiteColor];
//        
//        [_scrollView addSubview:backView2];
//        
//        [_scrollView sendSubviewToBack:backView2];
//    }
//    
//    for (NSDictionary *dic in times) {
//        UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(10, height, 40, 40)];
//        left.backgroundColor = kClearColor;
//        left.font = kNormalFont;
//        left.text = dic.allKeys[0];
//        
//        // 支付时间
//        if ([dic.allKeys[0] isEqualToString:@"时间"])
//        {
//            UILabel *payTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) + 10, height + 5, kScreenWidth - CGRectGetMaxX(left.frame) - 20, 30)];
//            payTimeLabel.textColor = [UIColor grayColor];
//            payTimeLabel.textAlignment = NSTextAlignmentRight;
//            payTimeLabel.text = payTime;
//            payTimeLabel.font = kNormalFont;
//            
//            [_scrollView addSubview:payTimeLabel];
//        }
//        
//        // 支付发票
//        if ([dic.allKeys[0] isEqualToString:@"发票"])
//        {
//            UILabel *payInvoiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) + 10, height + 5, kScreenWidth - CGRectGetMaxX(left.frame) - 20, 30)];
//            payInvoiceLabel.textColor = [UIColor grayColor];
//            payInvoiceLabel.textAlignment = NSTextAlignmentRight;
//            payInvoiceLabel.text = invoice;
//            payInvoiceLabel.font = kNormalFont;
//            
//            [_scrollView addSubview:payInvoiceLabel];
//        }
//        
//        // 支付备注
//        if ([dic.allKeys[0] isEqualToString:@"备注"])
//        {
//            UILabel *payNoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(left.frame) + 10, height + 5, kScreenWidth - CGRectGetMaxX(left.frame) - 20, 30)];
//            payNoteLabel.textColor = [UIColor grayColor];
//            payNoteLabel.textAlignment = NSTextAlignmentRight;
//            payNoteLabel.text = note;
//            payNoteLabel.font = kNormalFont;
//            
//            [_scrollView addSubview:payNoteLabel];
//        }
//
//
//        // 支付类型
//        if ([dic.allKeys[0] isEqualToString:@"类型"])
//        {
//            _payStyle = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenSize.width - 40, height + 5, 30, 30)];
//            
//            [_scrollView addSubview:_payStyle];
//            
//            _payStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(_payStyle.frame) - 10 - 60, height + 5, 50, 30)];
//            _payStyleLabel.textColor = [UIColor grayColor];
//            _payStyleLabel.textAlignment = NSTextAlignmentRight;
//            _payStyleLabel.font = kNormalFont;
//            
//            [_scrollView addSubview:_payStyleLabel];
//            
//            if ([[_detail objectForKey:@"payment_type"] isEqualToString:@"1"])
//            {
//                _payStyle.image = [UIImage imageNamed:@"pay_ali"];
//                _payStyleLabel.text = @"支付宝";
//            }
//            else if ([[_detail objectForKey:@"payment_type"] isEqualToString:@"4"])
//            {
//                _payStyle.image = [UIImage imageNamed:@"pay_weixin"];
//                _payStyleLabel.text = @"微信";
//            }
//            else
//            {
//                _payStyle.image = [UIImage imageNamed:@"upay"];
//                _payStyleLabel.text = @"UPay";
//            }
//            
//            // 修改支付方式按钮
//            if ([[_detail objectForKey:@"status"] isEqualToString:@"待付款"]) {
//                _payStyle.frame = CGRectMake(kScreenSize.width - 60, height + 5, 30, 30);
//                _payStyleLabel.frame = CGRectMake(CGRectGetMidX(_payStyle.frame) - 10 - 60, height + 5, 50, 30);
//                
//                UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 26, height + (headHeight - 16) / 2, 16, 16)];
//                rightArrow.image = [UIImage imageNamed:@"right_arrow_16"];
//                
//                [_scrollView addSubview:rightArrow];
//                UIButton *changePayType = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 40)];
//                changePayType.tag = [[_detail objectForKey:@"id"] integerValue];
//                [changePayType addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
//        
//                [_scrollView addSubview:changePayType];
//            }
//
//        }
//        
//        left.textColor = [UIColor grayColor];
//        
//        [_scrollView addSubview:left];
//        
//        height += left.frame.size.height;
//        
//        UIImageView *timeLine = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//        
//        [_scrollView addSubview:timeLine];
//        
//        height += 1;
//    }
//    
//    if (times.count > 0) height += 10;
//    
//    // 子订单
//    NSArray *subOrders = [_detail objectForKey:@"sub_orders"];
//    
//    for (int i = 0; i < subOrders.count; i++) {
//        NSDictionary *subOrder = subOrders[i];
//        
//        UIButton *topContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, headHeight)];
//        topContainer.backgroundColor = COLOR(245, 244, 245, 1);
//        topContainer.tag = i;
//        
//        [_scrollView addSubview:topContainer];
//        
////        // 右箭头
////        UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 26, (headHeight - 16) / 2, 16, 16)];
////        rightArrow.image = [UIImage imageNamed:@"right_arrow_16"];
////        
////        [topContainer addSubview:rightArrow];
//        
//        UIImageView *shopBubble = [[UIImageView alloc] initWithFrame:CGRectMake(10, (headHeight - 16) / 2, 16, 16)];
//        shopBubble.image = [UIImage imageNamed:@"good"];
//        
//        [topContainer addSubview:shopBubble];
//        
//        // 商品信息
//        UILabel *goodInfo = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, kScreenWidth - 56, headHeight)];
//        goodInfo.backgroundColor = kClearColor;
//        goodInfo.text = @"商品信息";
//        goodInfo.font = kNormalFont;
//        
//        [topContainer addSubview:goodInfo];
////        UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, kScreenWidth - 56, headHeight)];
////        shopName.backgroundColor = kClearColor;
////        shopName.font = [UIFont fontWithName:kFontBold size:kFontNormalSize];
////        shopName.text = [subOrder objectForKey:@"shop_name"];
//        
////        [topContainer addSubview:shopName];
//        
//        height += topContainer.frame.size.height;
//        
//        // 商品
//        NSArray *items = [subOrder objectForKey:@"items"];
//        
//        for (int j = 0; j < items.count; j++) {
//            UIButton *itemContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 100)];
//            itemContainer.backgroundColor = [UIColor whiteColor];
//            [itemContainer addTarget:self action:@selector(pushToProduct:) forControlEvents:UIControlEventTouchUpInside];
//            //            itemContainer.tag = [[items[j] objectForKey:@"sku_id"] integerValue];
//            itemContainer.tag = i * 100 + j;
//            
//            [_scrollView addSubview:itemContainer];
//            
//            // 图
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 108, 80)];
//            
//            //            imageView.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
//            //            imageView.layer.shadowOpacity = 1.0;
//            //            imageView.layer.shadowRadius = 5.0;
//            //            imageView.layer.shadowOffset = CGSizeMake(0, 1);
//            
//            imageView.clipsToBounds = NO;
//            
//            [itemContainer addSubview:imageView];
//            
//            [imageView setImageWithURL:[NSURL URLWithString:kNullToString([items[j] objectForKey:@"icon_url"])]
//                      placeholderImage:[UIImage imageNamed:@"default_image"]];
//            
//            // 名称
//            NSString *text = kNullToString([items[j] objectForKey:@"name"]);
//            CGSize size = [text sizeWithFont:[UIFont fontWithName:kFontFamily size:14]
//                                        size:CGSizeMake(kScreenWidth - 130, 68)];
//            
//            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(140, 24, kScreenSize.width - 140 - 10, size.height + 5)];
//            title.backgroundColor = kClearColor;
//            title.textColor = [UIColor darkGrayColor];
//            title.font = kNormalFont;
//            title.text = text;
//            title.textAlignment = NSTextAlignmentRight;
//            title.numberOfLines = 0;
//            
//            [itemContainer addSubview:title];
//            
//            // 金额和数量
//            UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(140, 62, kScreenSize.width - 140 - 10, 20)];
//            money.backgroundColor = kClearColor;
//            money.textColor = [UIColor darkGrayColor];
//            money.font = kBigFont;
//            money.textAlignment = NSTextAlignmentRight;
//            money.text = [NSString stringWithFormat:@"￥%@ x %@", [items[j] objectForKey:@"price"], [items[j] objectForKey:@"count"]];
//            
//            [itemContainer addSubview:money];
//            
//            height += 100;
//            
//            if (j < items.count) {
//                // 分割线
//                UIImageView *line = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//                
//                [_scrollView addSubview:line];
//                
//                height += 1;
//            }
//        }
//        
////        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 20)];
////        splitView.backgroundColor = COLOR(245, 245, 245, 1);
////        
////        [_scrollView addSubview:splitView];
//        
////        height += 20;
//        
//        NSInteger orderCount = 5;
//        
//        if ([[subOrder objectForKey:@"discount_price"] floatValue] > 0.0) {
//            orderCount = 7;
//        }
//        
//        for (int k = 0; k < orderCount; k++) {
//            UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(10, height, 40, 36)];
//            left.backgroundColor = kClearColor;
//            left.font = kNormalFont;
//            left.textColor = [UIColor darkGrayColor];
//            
//            [_scrollView addSubview:left];
//            
//            UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(50, height, kScreenWidth - 80, 36)];
//            right.backgroundColor = kClearColor;
//            right.textColor = [UIColor darkGrayColor];
//            right.font = kNormalFont;
//            
//            [_scrollView addSubview:right];
//            
//            UIView *backView3 = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenSize.width, 36)];
//            backView3.backgroundColor = [UIColor whiteColor];
//            
//            [_scrollView addSubview:backView3];
//            [_scrollView sendSubviewToBack:backView3];
//
//            switch (k) {
//                case 0: // 编号
//                    left.text = @"编号:";
//                    right.text = [subOrder objectForKey:@"no"];
//                    
//                    break;
//                    
//                case 1: // 时间
//                    left.text = @"时间:";
//                    right.text = [subOrder objectForKey:@"create_at"];
//                    
//                    break;
//                    
//                case 2: // 状态
//                    left.text = @"状态:";
//                    right.text = [subOrder objectForKey:@"status"];
//                    
//                    break;
//                    
//                case 3: // 运费
//                    left.text = @"运费:";
//                    right.text = [NSString stringWithFormat:@"￥%@", [subOrder objectForKey:@"shipment_price"]];
//                    
//                    break;
//                    
//                case 4: // 小计 或 总价
//                    if (orderCount == 4) {
//                        left.text = @"总价:";
//                        right.text = [NSString stringWithFormat:@"￥%@", [subOrder objectForKey:@"pay_price"]];
//                    } else {
//                        left.text = @"小计:";
//                        right.text = [NSString stringWithFormat:@"￥%@", [subOrder objectForKey:@"pay_price"]];
//                    }
//                    
//                    break;
//                    
//                case 5: // 优惠
//                    left.text = @"优惠";
//                    right.text = [NSString stringWithFormat:@"￥%@", [subOrder objectForKey:@"discount_price"]];
//                    
//                    break;
//                    
//                case 6: // 总价
//                    left.text = @"总价";
//                    right.text = [NSString stringWithFormat:@"￥%@", [subOrder objectForKey:@"pay_price"]];
//                    
//                default:
//                    break;
//            }
//            
//            height += left.frame.size.height;
//            
//            // 分割线
//            UIImageView *line;
//            
//            if (k == orderCount - 1) {
//                line = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//            } else {
//                line = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//            }
//            
//            [_scrollView addSubview:line];
//            
//            height += 1;
//        }
//        
//        // 店铺名
//        UIImageView *shopImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, height + (headHeight - 16) / 2, 16, 16)];
//        shopImage.image = [UIImage imageNamed:@"shop_bubble"];
//        
//        [_scrollView addSubview:shopImage];
//        
//        UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(36, height, kScreenWidth - 80 - 36, headHeight)];
//        shopName.font = kNormalFont;
//        shopName.text = [subOrder objectForKey:@"shop_name"];
//
//        [_scrollView addSubview:shopName];
//        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(0, height, kScreenWidth - 80, headHeight);
//        [button addTarget:self action:@selector(pushToShop:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [_scrollView addSubview:button];
//        
//        if ([[subOrder objectForKey:@"status"] isEqualToString:@"已发货（待收货确认）"]) {
//            UIButton *received= [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, height, 80, headHeight)];
//            received.tag = [[subOrder objectForKey:@"id"] integerValue];
//            received.backgroundColor = [UIColor orangeColor];
//            [received setTitle:@"确认收货" forState:UIControlStateNormal];
//            received.titleLabel.font = kNormalFont;
//            [received setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [received addTarget:self action:@selector(received:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [_scrollView addSubview:received];
//            
//            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 10 -16, height + (headHeight - 16) / 2, 16, 16)];
//            arrow.image = [UIImage imageNamed:@"right_arrow_16"];
//            
//            [_scrollView addSubview:arrow];
//        }
//        else if ([[subOrder objectForKey:@"status"] isEqualToString:@"订单完成"]) {
//            // 去评价按钮
//            UIButton *goToRate = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, height, 80, headHeight)];
//            [goToRate setBackgroundColor:[UIColor orangeColor]];
//            [goToRate setTitle:@"去评价" forState:UIControlStateNormal];
//            goToRate.titleLabel.font = kNormalFont;
//            [goToRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [goToRate addTarget:self action:@selector(goToRate:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [_scrollView addSubview:goToRate];
//            
//            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 10 -16, height + (headHeight - 16) / 2, 16, 16)];
//            arrow.image = [UIImage imageNamed:@"right_arrow_16"];
//            
//            [_scrollView addSubview:arrow];
//        }
//
//        else
//        {
//            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 16, height + (headHeight - 16) / 2 , 16, 16)];
//            arrow.image = [UIImage imageNamed:@"right_arrow_16"];
//            
//            [_scrollView addSubview:arrow];
//        }
//
//        
//        UIView *backView4 = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenSize.width, headHeight)];
//        backView4.backgroundColor = [UIColor whiteColor];
//        
//        [_scrollView addSubview:backView4];
//        [_scrollView sendSubviewToBack:backView4];
//
//        height += headHeight;
//        
//        // 分割线
//        UIImageView *line = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//
//        [_scrollView addSubview:line];
//
//        height += 1;
//        
//        
//        
//
//        
//        
//
//        
////        // 礼包
////        if ([[_detail objectForKey:@"category"] integerValue] == 2) {
////            UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 20)];
////            splitView.backgroundColor = COLOR(245, 245, 245, 1);
////            
////            [_scrollView addSubview:splitView];
////            
////            height += 20;
////            
////            for (int i = 0; i < 2; i++) {
////                UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(10, height, 60, 36)];
////                left.backgroundColor = kClearColor;
////                left.font = kNormalFont;
////                left.textColor = [UIColor lightGrayColor];
////                
////                [_scrollView addSubview:left];
////                
////                UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(70, height, kScreenWidth - 80, 36)];
////                right.backgroundColor = kClearColor;
////                right.font = kNormalFont;
////                
////                [_scrollView addSubview:right];
////                
////                switch (i) {
////                    case 0: // 姓名
////                        left.text = @"姓名";
////                        right.text = kNullToString([subOrder objectForKey:@"consignee_name"]);
////                        
////                        break;
////                        
////                    case 1: // 手机
////                        left.text = @"手机";
////                        right.text = kNullToString([subOrder objectForKey:@"consignee_phone"]);
////                        
////                        break;
////                        
////                    default:
////                        break;
////                }
////                
////                height += 36;
////                
////                // 分割线
////                UIImageView *line = [self splitLine:CGRectMake(10, height, kScreenWidth - 10, 1)];
////                
////                [_scrollView addSubview:line];
////                
////                height += 1;
////            }
////            
////            // 地址
////            UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(10, height, 60, 36)];
////            left.backgroundColor = kClearColor;
////            left.font = kNormalFont;
////            left.textColor = [UIColor lightGrayColor];
////            left.text = @"地址";
////            
////            [_scrollView addSubview:left];
////            
////            NSString *address = kNullToString([subOrder objectForKey:@"consignee_address"]);
////            
////            CGSize size = [address sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 80, 9999)];
////            
////            UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(70, height + 10, kScreenWidth - 80, size.height)];
////            right.backgroundColor = kClearColor;
////            right.font = kNormalFont;
////            right.numberOfLines = 0;
////            right.text = address;
////            
////            [_scrollView addSubview:right];
////            
////            height += MAX(36, size.height + 20);
////            
////            // 分割线
////            UIImageView *line = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
////            
////            [_scrollView addSubview:line];
////            
////            height += 1;
////        }
//        
//        height += 20;
//        
//        NSString *expressURL = kNullToString([subOrders[i] objectForKey:@"express_url"]);
//        
//        if (![expressURL isEqualToString:@""]) {
//            UIImageView *upLine = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//            
//            [_scrollView addSubview:upLine];
//            
//            height += 1;
//            
//            UIButton *expressButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 36)];
//            expressButton.backgroundColor = kClearColor;
//            expressButton.tag = i;
//            [expressButton addTarget:self action:@selector(goToExpress:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [_scrollView addSubview:expressButton];
//            
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 36, expressButton.frame.size.height)];
//            label.backgroundColor = kClearColor;
//            label.font = kNormalFont;
//            label.text = @"查看物流";
//            
//            [expressButton addSubview:label];
//            
//            UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 26, 10, 16, 16)];
//            arrow.image = [UIImage imageNamed:@"right_arrow_16"];
//            
//            [expressButton addSubview:arrow];
//            
//            UIView *backView5 = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenSize.width, 36)];
//            backView5.backgroundColor = [UIColor whiteColor];
//            
//            [_scrollView addSubview:backView5];
//            [_scrollView sendSubviewToBack:backView5];
//
//            height += 36;
//            
//            UIImageView *downLine = [self splitLine:CGRectMake(0, height, kScreenWidth, 1)];
//            
//            [_scrollView addSubview:downLine];
//            
//            height += 1;
//            
//            height += 20;
//        }
//    }
//    
//    _scrollViewHeight = height + 20;
//    
//    _scrollView.contentSize = CGSizeMake(kScreenWidth, _scrollViewHeight);
//}

- (void)cancelOrder:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *cancelURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/order_parents/%@/cancel.json", _detail[@"no"]] params:params];
    
    YunLog(@"cancelURL = %@", cancelURL);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"取消订单中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager PATCH:cancelURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject = %@",responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            
            [_hud addSuccessString:@"订单取消成功" delay:1.0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self backToPrev:nil];
            });
            
        }
        else
        {
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:1.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络繁忙,请稍后再试" delay:1.0];
    }];
}

/**
 确认收货

 @param sender 点击的订单标记
 */
- (void)received:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;

    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};

    NSString *receivedURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/orders/%@/confirm.json",_orderID] params:params];

    YunLog(@"receivedURL = %@", receivedURL);

    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"确认收货中...";

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;

    [manager PATCH:receivedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject = %@",responseObject);

        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [kNotificationCenter postNotificationName:kOrderDetailNotificationReload object:nil];

            [_hud addSuccessString:@"确认收货成功" delay:1.0];
        }
        else
        {
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:1.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络繁忙,请稍后再试" delay:1.0];
    }];
}

/**
 修改订单支付方式
 
 @param sender 点击按钮
 */
- (void)changePayType:(UIButton *)sender
{
//    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
//                                    initWithTitle:nil
//                                    delegate:self
//                                    cancelButtonTitle:@"取消"
//                                    destructiveButtonTitle:nil
//                                    otherButtonTitles: @"U付", @"微信支付",@"支付宝",nil];
//    myActionSheet.tag = 100;
//    
//    [myActionSheet showInView:self.view];
    NSArray *arr = @[@{@"icon" : @"pay_ali" , @"title" : @"支付宝"},
                     @{@"icon" : @"" , @"title" : @""},
                     @{@"icon" : @"upay" , @"title" : @"U付"},
                     @{@"icon" : @"pay_weixin" , @"title" : @"微信"},
                     @{@"icon" : @"" , @"title" : @""},
                     @{@"icon" : @"" , @"title" : @""},
                     @{@"icon" : @"" , @"title" : @""},
                     @{@"icon" : @"" , @"title" : @""},
                     @{@"icon" : @"" , @"title" : @""},
                     @{@"icon" : @"upay" , @"title" : @"U付"}];
   
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *str in _paymentArr)
    {
        NSInteger value = [str integerValue] - 1;
        [array addObject:arr[value]];
    }
    
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:array
                                                         bottomBar:@[]
                               ];
    shareView.tip = @"修改支付方式";
    shareView.tag = 200;
    shareView.delegate = self;
    
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];

}

/**
 修改订单支付方式
 
 @param sender 点击支付方式传入的参数
 */
- (void)changeType:(NSString *)type
{
    YunLog(@"_paymentArr = %@", _paymentArr);
    
    if ([_paymentArr containsObject:type])
    {
        AppDelegate *appDelegate = kAppDelegate;
        
        NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                                 @"payment_type"            :   kNullToString(type)};
        
        NSString *changePayTypeURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/order_parents/%@.json",_number] params:params];
        
        YunLog(@"changePayTypeURL = %@", changePayTypeURL);
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"修改支付方式中...";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager PUT:changePayTypeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"responseObject = %@",responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                [_detail setValue:type forKey:@"payment_type"];
                
                NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:1];
                [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
                
                [_hud addSuccessString:@"订单修改成功" delay:1.0];
            }
            else
            {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:1.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:1.0];
        }];
        
    }
    else
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"该订单不支持此种支付方式..." delay:1.0];

    }
}

- (UIImageView *)splitLine:(CGRect)frame
{
    UIImageView *line = [[UIImageView alloc] initWithFrame:frame];
    
    UIGraphicsBeginImageContext(line.frame.size);
    [line.image drawInRect:CGRectMake(0, 0, line.frame.size.width, 1)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
//    CGContextSetStrokeColorWithColor(ctx, COLOR(232, 232, 232, 1).CGColor);
    
    CGContextMoveToPoint(ctx, 0, 1);
    CGContextAddLineToPoint(ctx, line.frame.size.width, 1);
    CGContextStrokePath(ctx);
    
    line.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return line;
}

- (void)pushToShop:(UIButton *)sender
{
    YunLog(@"_detail = %@", _detail);
    
    ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
    
    if (_isReadyToPay) {
        shop.code = [[_detail objectForKey:@"sub_orders"][sender.tag - 2] objectForKey:@"shop_code"];
    } else {
        shop.code = [_detail  objectForKey:@"shop_code"];
    }
    
    [self.navigationController pushViewController:shop animated:YES];
}

- (void)pushToProduct:(UIButton *)sender
{
    NSInteger i = sender.tag / 10 - 2;
    NSInteger j = sender.tag % 10 - 2;
    
    NSDictionary *order = [NSDictionary dictionary];
    NSDictionary *item = [NSDictionary dictionary];
    
    if (_isReadyToPay) {
        order = _detail[@"sub_orders"][i];
        item = order[@"items"][j];
    } else {
        item = _detail[@"items"][j];
    }

    ProductDetailViewController *product = [[ProductDetailViewController alloc] init];
    product.shopCode = kNullToString([item objectForKey:@"shop_code"]);
    
    YunLog(@"product.shopCode = %@",product.shopCode);
    product.productCode = kNullToString([item objectForKey:@"product_code"]);
    YunLog(@"product.code = %@",product.productCode);
    product.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:product animated:YES];
}

- (void)openShare
{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@"分享到新浪微博", @"分享给微信好友", @"分享到微信朋友圈", nil];
//    sheet.tag = 200;
//    
//    [sheet showInView:self.view];
    
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_weixin" , @"title" : @"微信"},
                                                                     
                                                                     @{@"icon" : @"share_weixin_friend" , @"title" : @"朋友圈"},
                                                                     
                                                                     @{@"icon" : @"share_weibo" , @"title" : @"微博"}]
                                                         bottomBar:@[]
                               ];
    
    shareView.delegate = self;
    shareView.tag = 100;
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
}

- (void)isWeiXinInstalled:(NSInteger)scene
{
    if ([WXApi isWXAppInstalled]) {
        NSString *thumb = @"";
        
        [Tool shareToWeiXin:scene
                      title:kNullToString([_detail objectForKey:@"share_title"])
                description:kNullToString([_detail objectForKey:@"share_text"])
                      thumb:thumb
                        url:kNullToString([_detail objectForKey:@"share_url"])];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"未安装微信客户端，去下载？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"现在下载", nil];
        [alert show];
    }
}

- (void)goToExpress:(UIButton *)sender
{
    NSString *expressURL = kNullToString(_detail[@"express_url"]);
    
//    AppDelegate *appDelegate = kAppDelegate;
    
//    expressURL = [expressURL stringByAppendingFormat:@"&platform=iphone&user_session_key=%@", appDelegate.user.userSessionKey];
    
    YunLog(@"expressURL = %@", expressURL);
    
    WebViewController *web = [[WebViewController alloc] init];
    web.naviTitle = @"物流详情";
    web.url = expressURL;
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)goToPay:(UIButton *)sender
{
    sender.enabled = NO;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"oid"                 :   [NSString stringWithFormat:@"%ld", (long)sender.tag],
                             @"terminal_session_key":   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"    :   kNullToString(appDelegate.user.userSessionKey)};

    NSString *pageURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kPayPageURL params:params];
    
    YunLog(@"get pay page url = %@", pageURL);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:pageURL
                                                                                parameters:nil
                                                                                     error:nil];

    _payOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _payOp.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak typeof(self) weakSelf = self;
    
    [_payOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"get pay page responseObject = %@", responseObject);
        
        NSString *code = [[[responseObject objectForKey:@"status"] objectForKey:@"code"] toString];
        if ([code isEqualToString:kSuccessCode]) {
            [weakSelf.hud hide:YES];
            
            sender.enabled = YES;
            
            // Umpay 支付
            NSString *tradeNO = [[[[responseObject objectForKey:@"data"] objectForKey:@"page_pay"] objectForKey:@"upay_trade_no"] toString];
            if (![tradeNO isEqualToString:@""]) {
                @try {
                    ChooseBankViewController *bankVC = [[ChooseBankViewController alloc] init];
                    
                    bankVC.tradeNO = tradeNO;
                    
                    YunLog(@"tradeNO = %@",tradeNO);
                    
                    bankVC.price = [NSString stringWithFormat:@"￥%@", weakSelf.totalPrice];
                    YunLog(@"bankVC.price = %@",bankVC.price);
                    
                    bankVC.index = [weakSelf.navigationController.viewControllers indexOfObject:weakSelf];
                    
                    [weakSelf.navigationController pushViewController:bankVC animated:YES];
                }
                @catch (NSException *exception) {
                    YunLog(@"umpay result exception = %@", exception);
                    
                    [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                }
                @finally {
                    
                }
                
                return;
            }
            
            // 微信支付
            NSDictionary *response = responseObject[@"data"][@"page_pay"][@"wxpay"];
            
            YunLog(@"weixin pay response = %@", response);
            
            if ([response isKindOfClass:[NSString class]]) {
                response = nil;
            }
            
            if (response) {
                appDelegate.shareType = ShareToWeiXin;
                appDelegate.wxPayDelegate = weakSelf;
                
                PayReq *req = [[PayReq alloc] init];
                
                req.openID      = response[@"appid"];
                req.partnerId   = response[@"partner_id"];
                req.prepayId    = response[@"prepayid"];
                req.nonceStr    = response[@"noncestr"];
                req.timeStamp   = [response[@"timestamp"] intValue];
                req.package     = response[@"package"];
                req.sign        = response[@"sign"];
                
                [WXApi sendReq:req];
            }
            
            // 内置浏览器支付
            else {
                @try {
                    PayResultViewController *result = [[PayResultViewController alloc] init];
                    result.payURL = [[[responseObject objectForKey:@"data"] objectForKey:@"page_pay"] objectForKey:@"pay_url"];
                    
                    YunLog(@"alpay.payURL = %@",result.payURL);
                    
                    UINavigationController *resultNC = [[UINavigationController alloc] initWithRootViewController:result];
                    
                    [weakSelf.navigationController presentViewController:resultNC animated:YES completion:nil];
                }
                @catch (NSException *exception) {
                    YunLog(@"open web pay page exception = %@", exception);
                }
                @finally {
                    
                }
            }
        } else {
            [weakSelf.hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"]
                                   delay:2.0];
            
            sender.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"get pay page error = %@", error);
        
        if ([weakSelf.payOp isCancelled]) {
            [weakSelf.hud addErrorString:@"用户取消支付" delay:3.0];
        } else {
            [weakSelf.hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
        }
        
        sender.enabled = YES;
        sender.backgroundColor = [UIColor orangeColor];
    }];
    
    [_payOp start];
}


/**
 评价订单
 
 @param sender 点击的订单标记
 */
- (void)goToRate:(UIButton *)sender
{
    YunLog(@"_detail = %@", _detail);
      
    RateProductViewController *rateVC = [[RateProductViewController alloc] initWithOrderId:_detail[@"no"]];
    
    [self.navigationController pushViewController:rateVC animated:YES];
}

#pragma mark - WXPayDelegate -

- (void)showPayResult:(WXPayResult)result message:(NSString *)message
{
    NSString *title = @"";
    
    if (result == WXPayResultSuccess) {
        title = @"订单支付成功";
        
        
    } else {
        title = @"订单支付失败";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    alert.tag = 111;
    
    [alert show];
}

#pragma mark - UmpayDelegate -

- (void)onPayResult:(NSString *)orderId resultCode:(NSString *)resultCode resultMessage:(NSString *)resultMessage
{
    if ([resultCode isEqualToString:kUmpaykSuccessCode]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:resultMessage delay:2.0];
        
        [kNotificationCenter postNotificationName:kOrderPaySucceedNotification object:nil];
    } else if ([resultCode isEqualToString:kUmpayFailureCode]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:resultMessage delay:2.0];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark - UIActionSheetDelegate -

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
    switch (buttonIndex) {
        case 0:
            [self changeType:_paymentArr[buttonIndex]];
            break;
            
        case 1:
            [self changeType:@"4"];
            break;
            
        case 2:
            [self changeType:@"3"];
            break;
            
        default:
            break;
    }

}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111) {
        if ([alertView.title isEqualToString:@"订单支付成功"]) {
            [kNotificationCenter postNotificationName:kOrderPaySucceedNotification object:nil];
    }
    } else {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        }
    }
}

#pragma mark - YunShareDelegate -

- (void)shareViewDidSelectView:(YunShareView *)shareView inSection:(NSUInteger)section index:(NSUInteger)index
{
    YunLog(@"YunShareDelegate");
    
    if (shareView.tag == 100)
    {
        
//      微博分享内容
        NSString *shopName = kNullToString([_detail objectForKey:@""]);
        NSString *productName = kNullToString([_detail objectForKey:@""]);
        NSString *productURL = kNullToString([_detail objectForKey:@""]);
    
        NSUInteger shopNameLength = shopName.length;
        NSUInteger productNameLength = productName.length;
        NSUInteger productURLLength = productURL.length;
    
        NSString *desc = @"云店家手机APP购物支付很方便大家赶快来试试吧";
        if (shopNameLength + productNameLength + productURLLength > (140 - 4 - 2 - 4)) {
            desc = [desc substringWithRange:NSMakeRange(0, 130 - shopNameLength - productNameLength - productURLLength)];
        }
    
        NSString *description = [NSString stringWithFormat:@"#晒单啦#我在%@购买了%@，%@%@", shopName, productName, desc, productURL];

//        NSString *description = [_detail objectForKey:@"share_order"];
        
        YunLog(@"share weibo description = %@", description);
        
        switch (index) {
            case 0:
                [self isWeiXinInstalled:WXSceneSession];
                
                break;
                
            case 1:
                [self isWeiXinInstalled:WXSceneTimeline];
                
                break;
                
            case 2:
                [Tool shareToWeiBo:nil description:description];
                
                break;
                
            default:
                break;
        }
    }
    else if (shareView.tag == 200)
    {
        
        [self changeType:_paymentArr[index]];
    }
}

@end
