//
//  AdminOrderListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-3-31.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "AdminOrderListViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"
#import "Tool.h"

// Controllers
#import "OrderListViewController.h"
#import "AdminOrderDetailViewController.h"
#import "AdminOrderOperationViewController.h"

// Categories
#import "UIImageView+AFNetworking.h"
#import "WebViewController.h"

// Libraries
#import "AFNetworking.h"

static int orderTypes[6] = {
    AdminOrderAll,
    AdminOrderWaitingForPay,
    AdminOrderWaitingForSend,
    AdminOrderWaitingForReceive,
    AdminOrderAlreadyComplete,
    AdminOrderAlreadyCancel
};

@interface AdminOrderListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) CALayer *selectedBottomLine;
@property (nonatomic, assign) NSInteger selectedOrderTypeIndex;
@property (nonatomic, assign) NSInteger selectedOrderChannelTypeIndex;
@property (nonatomic, assign) NSInteger selectedOrderTimeTypeIndex;

@property (nonatomic, strong) UIView *timeBack;

@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, copy) NSString *searchKey;

@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) NSInteger refreshCount;
@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation AdminOrderListViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _searchKey = @"";
        _selectedOrderTypeIndex = 0;
        _selectedOrderChannelTypeIndex = AdminOrderChannelAll;
        _selectedOrderTimeTypeIndex = AdminOrderTimeAll;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
//    [TalkingData trackPageBegin:@"进入商户订单列表页面"];
    
    YunLog(@"_searchKey = %@", _searchKey);
    
    _refreshCount = 1;
    
//    [self doList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRereshing) name:@"setExpressSucceed" object:nil];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *triangle = [UIButton buttonWithType:UIButtonTypeCustom];
    triangle.frame = CGRectMake(0, 0, 25, 25);
    [triangle setImage:[UIImage imageNamed:@"clock_barbutton"] forState:UIControlStateNormal];
    [triangle addTarget:self action:@selector(showTime:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *triItem = [[UIBarButtonItem alloc] initWithCustomView:triangle];
    triItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = triItem;
    
    NSArray *buttons = [NSArray arrayWithObjects:@"全部", @"直销", @"分销", nil];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:buttons];
    control.frame = CGRectMake((kScreenWidth - 180) / 2, 6, 180, 32);
//    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.selectedSegmentIndex = 0;
    control.tintColor = [UIColor orangeColor];
    [control addTarget:self action:@selector(segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = control;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48) style:UITableViewStylePlain];
    
    if (kDeviceOSVersion < 7.0) {
        _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 48);
    }
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _tableView.showsHorizontalScrollIndicator = NO;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    searchBar.delegate = self;
    searchBar.placeholder = @"订单编号/手机/地址/姓名";
    searchBar.autocapitalizationType = NO;
    searchBar.autocorrectionType = NO;
    
    _tableView.tableHeaderView = searchBar;
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, (back.frame.size.height - 200) / 2 + 40, 120, 200)];
    imageView.image = [UIImage imageNamed:@"no_order"];
    
    [back addSubview:imageView];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;
    
    [self.view addSubview:_tableView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
    
    if (kDeviceOSVersion < 7.0) {
        _bottomView.frame = CGRectMake(-1, kScreenHeight - 48 - 64, kScreenWidth + 2, 48);
    }
    
    _bottomView.backgroundColor = COLOR(245, 245, 245, 1);
//    _bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
//    _bottomView.layer.shadowOffset = CGSizeMake(1, 5);
//    _bottomView.layer.shadowOpacity = 1.0;
//    _bottomView.layer.shadowRadius = 5.0;
    _bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
    _bottomView.layer.borderWidth = 1;
    _bottomView.clipsToBounds = NO;
    
    [self.view addSubview:_bottomView];
    
    NSArray *titles = @[@"全部", @"待支付", @"待发货", @"待收货", @"已完成", @"已取消"];
    
    for (int i = 0; i < 6; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * (kScreenWidth / 6), 0, kScreenWidth / 6, _bottomView.frame.size.height)];
        button.tag = i;
        button.titleLabel.font = kSmallFont;
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeOrderType:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        
        CGSize size = [titles[i] sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
        
        if (i == _selectedOrderTypeIndex) {
            button.selected = YES;
            
            if (_selectedBottomLine) {
                [_selectedBottomLine removeFromSuperlayer];
            }
            
            _selectedBottomLine = [CALayer layer];
            _selectedBottomLine.frame = CGRectMake((button.frame.size.width - size.width - 4) / 2 + button.frame.origin.x, _bottomView.frame.size.height - 4, size.width + 4, 4);
            _selectedBottomLine.cornerRadius = 2;
            _selectedBottomLine.masksToBounds = YES;
            _selectedBottomLine.backgroundColor = [UIColor orangeColor].CGColor;
            
            [_bottomView.layer addSublayer:_selectedBottomLine];
        }
        
        [_bottomView addSubview:button];
    }
//    [self createMJRefresh];
    
    [self doList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    UISearchBar *searchBar = (UISearchBar *)_tableView.tableHeaderView;
    searchBar.delegate = nil;
    
    _tableView.delegate = nil;
}

#pragma mark - Private Functions -

- (void)selectTimeType:(UIButton *)sender
{
    if (sender.tag != _selectedOrderTimeTypeIndex) {
        _selectedOrderTimeTypeIndex = sender.tag;
        
        [self doList];
    }
    
    UIView *view = _timeBack.subviews[0];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.frame = CGRectMake(0, -180, kScreenWidth, 180);
                     }
                     completion:^(BOOL finished) {
                         _timeBack.hidden = YES;
                     }];
}

- (void)showTime:(UIButton *)sender
{
    if (!_timeBack) {
        _timeBack = [[UIView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - kCustomNaviHeight)];
        _timeBack.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _timeBack.hidden = YES;
        
        [self.view addSubview:_timeBack];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, -180, kScreenWidth, 180)];
        container.backgroundColor = [UIColor whiteColor];
        
        [_timeBack addSubview:container];
        
        for (int i = 0; i < 4; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i * 45, kScreenWidth, 45)];
            button.tag = i;
            button.backgroundColor = [UIColor whiteColor];
            [button addTarget:self action:@selector(selectTimeType:) forControlEvents:UIControlEventTouchUpInside];
            
            [container addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 30, 44)];
            label.backgroundColor = kClearColor;
            label.font = kNormalFont;
            
            switch (i) {
                case 0:
                    label.text = @"全部";
                    
                    break;
                    
                case 1:
                    label.text = @"今天";
                    
                    break;
                    
                case 2:
                    label.text = @"近七天";
                    
                    break;
                    
                case 3:
                    label.text = @"近一个月";
                    
                    break;
                    
                default:
                    break;
            }
            
            [button addSubview:label];
            
            CALayer *line = [CALayer layer];
            line.frame = CGRectMake(0, 44, kScreenWidth, 1);
            line.backgroundColor = [UIColor lightGrayColor].CGColor;
            
            [button.layer addSublayer:line];
        }
    }
    
    if (_timeBack.isHidden) {
        _timeBack.hidden = NO;
        
        UIView *view = _timeBack.subviews[0];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             view.frame = CGRectMake(0, 0, kScreenWidth, 180);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    } else {
        UIView *view = _timeBack.subviews[0];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             view.frame = CGRectMake(0, -180, kScreenWidth, 180);
                         }
                         completion:^(BOOL finished) {
                             _timeBack.hidden = YES;
                         }];
    }
}

- (void)segmentedChanged:(UISegmentedControl *)control
{
    _selectedOrderChannelTypeIndex = control.selectedSegmentIndex;
    _selectedOrderTimeTypeIndex = AdminOrderTimeAll;
    
    [self doList];
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToSend:(UIButton *)sender
{
    NSDictionary *order = _orders[sender.tag];
    
    AdminOrderOperationViewController *operation = [[AdminOrderOperationViewController alloc] init];
    operation.oid = kNullToString([order objectForKey:@"id"]);
    operation.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:operation animated:YES];
}

- (void)goToExpress:(UIButton *)sender
{
    WebViewController *web = [[WebViewController alloc] init];
    web.url = kNullToString([_orders[sender.tag] objectForKey:@"express_url"]);
    web.naviTitle = @"快递详情";
    web.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)changeOrderType:(UIButton *)sender
{
    for (id so in _bottomView.subviews) {
        if ([so isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)so;
            button.selected = NO;
        }
    }
    
    YunLog(@"sender.tag = %ld", (long)sender.tag);
    
    sender.selected = YES;
    _selectedOrderTypeIndex = sender.tag;
    _selectedOrderTimeTypeIndex = AdminOrderTimeAll;
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:kSmallFont}];
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.5];
    
    _selectedBottomLine.frame = CGRectMake((sender.frame.size.width - size.width - 4) / 2 + sender.frame.origin.x, _bottomView.frame.size.height - 4, size.width + 4, 4);
    
    [UIView commitAnimations];
    
    [self doList];
}

- (void)doList
{
    _reloading = NO;
    _isLoading = YES;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"status"                  :   [NSString stringWithFormat:@"%u", orderTypes[_selectedOrderTypeIndex]],
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"page"                    :   @"1",
                             @"limit"                   :   @"8",
                             @"shop_id"                 :   kNullToString(_shopID),
                             @"channel"                 :   [NSString stringWithFormat:@"%ld", (long)_selectedOrderChannelTypeIndex],
                             @"last_time_type"          :   [NSString stringWithFormat:@"%ld", (long)_selectedOrderTimeTypeIndex],
                             @"key"                     :   kNullToString(_searchKey)};
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kOrderAdminListURL params:params];
    
//    NSString *newListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:<#(NSString *)#> params:<#(NSDictionary *)#>]
    
    YunLog(@"admin order listURL = %@", listURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"admin order list responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             [_tableView headerEndRefreshing];
             _tableView.footerHidden = NO;
             _isLoading = NO;

             if ([code isEqualToString:kSuccessCode]) {
                 _orders = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"orders"]);
                 
                 [_tableView reloadData];
                 
                 _refreshCount = 1;
                 
                 if (_orders.count <= 0) {
                     _tableView.backgroundView.hidden = NO;
                 } else {
                     _tableView.backgroundView.hidden = YES;
                 }
                 
                 _tableView.scrollEnabled = YES;
                 _tableView.allowsSelection = YES;
                 
                 if (_orders.count >= 8) {
                     
                 }
                 
                 [_tableView setContentOffset:CGPointMake(0, -kCustomNaviHeight) animated:NO];
                
                 [_hud hide:YES];                 
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
                 
                 _tableView.backgroundView.hidden = NO;
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"admin order list error = %@", error);
             [_tableView headerEndRefreshing];
             _isLoading = NO;

             if (![operation isCancelled]) {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
                 
                 _tableView.backgroundView.hidden = NO;
             }
         }];
}

//- (void)doSearch:(NSString *)text
//{
//    
//    _tableView.backgroundView.hidden = YES;
//    
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    NSDictionary *params = @{@"key"                     :   kNullToString(text),
//                             @"status"                  :   [NSString stringWithFormat:@"%u", orderTypes[_selectedOrderTypeIndex]],
//                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
//                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
//                             @"page"                    :   @"1",
//                             @"limit"                   :   @"8",
//                             @"channel"                 :   [NSString stringWithFormat:@"%u", _selectedOrderChannelTypeIndex]};
//    
//    NSString *searchURL = [Tool buildRequestURLHost:kRequestHost
//                                         APIVersion:kAPIVersion2
//                                         requestURL:kOrderAdminListURL
//                                             params:params];
//    
//    YunLog(@"searchURL = %@", searchURL);
//    
//    searchURL = [searchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 30;
//
//    [manager GET:searchURL
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             YunLog(@"search order responseObject = %@", responseObject);
//             
//             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
//             
//             if ([code isEqualToString:kSuccessCode]) {
//                 _orders = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"orders"]);
//                 
//                 [_tableView reloadData];
//                 
//                 _refreshCount = 1;
//                 
//                 _tableView.scrollEnabled = YES;
//                 _tableView.allowsSelection = YES;
//                 
//                 if (_orders.count <= 0) {
//                     _tableView.backgroundView.hidden = NO;
//                 } else {
//                     _tableView.backgroundView.hidden = YES;
//                 }
//                 
////                 if (!_orders || _orders.count <= 0) {
////                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"搜索结果"
////                                                                         message:[NSString stringWithFormat:@"没有搜索到与\"%@\"相关的订单", text]
////                                                                        delegate:self
////                                                               cancelButtonTitle:@"确定"
////                                                               otherButtonTitles:nil];
////                     [alertView show];
////                 }
//             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
//                 [Tool resetUser];
//                 
//                 [self backToPrev];
//             } else {
//                 _tableView.backgroundView.hidden = NO;
//             }
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             YunLog(@"search order error = %@", error);
//             
//             if (![operation isCancelled]) {
//                 
//                 _tableView.backgroundView.hidden = NO;
//             }
//         }];
//}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"已取消"] || [[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"])
    {
        return 36 + 104 + 4;
    }
    else
    {
        return 36 + 104 + 34;
    }
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
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    int height = 20;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int height = 10;
    
    cell.contentView.backgroundColor = kGrayColor;
    
    UIView *backView = [[UIView alloc] init];
    
    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"已取消"] || [[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"])
    {
         backView.frame = CGRectMake(0, 46, kScreenSize.width, 98);
    }
    else
    {
        backView.frame = CGRectMake(0, 46, kScreenSize.width, 128);
    }

    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    // 顶部 title
    UIButton *topContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 36)];
    topContainer.backgroundColor = COLOR(245, 244, 245, 1);
    topContainer.tag = indexPath.row;
    
    [cell.contentView addSubview:topContainer];
    
    //    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 26, 10, 16, 16)];
    //    rightArrow.image = [UIImage imageNamed:@"right_arrow_16"];
    //
    //    [topContainer addSubview:rightArrow];
    
    // 编号
    UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 170, 36)];
    noLabel.backgroundColor = kClearColor;
    noLabel.font = kSmallFont;
    noLabel.text = [NSString stringWithFormat:@"编号: %@", [_orders[indexPath.row] objectForKey:@"no"]];
    
    [topContainer addSubview:noLabel];
    
    // 金额
    CGSize moneyLabelSize = [[NSString stringWithFormat:@"￥%@", [_orders[indexPath.row] objectForKey:@"total_price"]] sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 10 - moneyLabelSize.width, topContainer.frame.size.height + 30, moneyLabelSize.width, moneyLabelSize.height)];
    moneyLabel.backgroundColor = kClearColor;
    moneyLabel.font = kBigFont;
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.text = [NSString stringWithFormat:@"￥%@", [_orders[indexPath.row] objectForKey:@"total_price"]];
    moneyLabel.textColor = [UIColor orangeColor];
    moneyLabel.textAlignment = NSTextAlignmentRight;
    
    [cell.contentView addSubview:moneyLabel];
    
    height += topContainer.frame.size.height + 6;
    
    // 图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, height, 86, 86)];
    
    imageView.clipsToBounds = NO;
    
    [cell.contentView addSubview:imageView];
    
    NSString *imageURL;
    @try {
        imageURL = [[_orders[indexPath.row] objectForKey:@"items"][0] objectForKey:@"icon"];
    }
    @catch (NSException *exception) {
        imageURL = @"";
    }
    @finally {
        
    }
    
    [imageView setImageWithURL:[NSURL URLWithString:imageURL]
              placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    int tempHeight = height;
    
    // 时间
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 150 - 10, CGRectGetMaxY(imageView.frame) - 30, 150, 12)];
    time.backgroundColor = kClearColor;
    time.textAlignment = NSTextAlignmentRight;
    time.font = [UIFont fontWithName:kFontFamily size:12];
    time.text = [NSString stringWithFormat:@"%@",[_orders[indexPath.row] objectForKey:@"create_at"]];
    //    time.textColor = [UIColor grayColor];
    
    [cell.contentView addSubview:time];
    
    //分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 6, kScreenSize.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:line];

    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"已取消"] || [[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"])
    {
        line.hidden = YES;
    }
    else
    {
        line.hidden = NO;
    }

    tempHeight = CGRectGetMaxY(imageView.frame) + 6;
    
    // 状态
    CGSize statusLabelSize = [[_orders[indexPath.row] objectForKey:@"status"] sizeWithAttributes:@{NSFontAttributeName:kSmallFont}];
    
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 10 - statusLabelSize.width - 30, 0, 30, 36)];
    status.backgroundColor = kClearColor;
    status.font = kSmallFont;
    status.text = @"状态: ";
    status.textColor = [UIColor darkGrayColor];
    
    [topContainer addSubview:status];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 10 - statusLabelSize.width, 0, statusLabelSize.width, topContainer.frame.size.height)];
    statusLabel.textAlignment = NSTextAlignmentRight;
    statusLabel.backgroundColor = kClearColor;
    statusLabel.font = kSmallFont;
    statusLabel.text = [_orders[indexPath.row] objectForKey:@"status"];
    
    YunLog( @"status = %@",statusLabel.text);
    
    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"已取消"])
    {
        statusLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        statusLabel.textColor = [UIColor orangeColor];
    }
    
    [topContainer addSubview:statusLabel];

//    // 顶部 title
//    UIButton *topContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 36)];
//    topContainer.backgroundColor = COLOR(245, 245, 245, 1);
//    
//    [cell.contentView addSubview:topContainer];
    
//    // 编号
//    UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 36)];
//    noLabel.backgroundColor = kClearColor;
//    noLabel.font = kNormalFont;
//    noLabel.text = [NSString stringWithFormat:@"编号: %@", [_orders[indexPath.row] objectForKey:@"no"]];
//    
//    [topContainer addSubview:noLabel];
    
//    // 金额
//    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + noLabel.frame.origin.x + noLabel.frame.size.width, 0, kScreenWidth - noLabel.frame.size.width - noLabel.frame.origin.x - 20, 36)];
//    moneyLabel.backgroundColor = kClearColor;
//    moneyLabel.font = kNormalFont;
//    moneyLabel.text = [NSString stringWithFormat:@"￥%@", [_orders[indexPath.row] objectForKey:@"total_price"]];
//    moneyLabel.textColor = [UIColor orangeColor];
//    moneyLabel.textAlignment = NSTextAlignmentRight;
//    
//    [topContainer addSubview:moneyLabel];
//    
//    height += topContainer.frame.size.height + 20;
//    
    // 图片
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, height, 108, 80)];
//    
////    imageView.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
////    imageView.layer.shadowOpacity = 1.0;
////    imageView.layer.shadowRadius = 5.0;
////    imageView.layer.shadowOffset = CGSizeMake(0, 1);
//    
//    imageView.clipsToBounds = NO;
//    
//    [cell.contentView addSubview:imageView];
//    
//    NSString *imageURL;
//    
//    @try {
//        imageURL = [[_orders[indexPath.row] objectForKey:@"items"][0] objectForKey:@"icon"];
//    }
//    @catch (NSException *exception) {
//        imageURL = @"";
//    }
//    @finally {
//        
//    }
//    
//    [imageView setImageWithURL:[NSURL URLWithString:imageURL]
//              placeholderImage:[UIImage imageNamed:@"default_image"]];
//    
//    int tempHeight = height;
    
//    // 时间
//    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10, tempHeight, 40, 14)];
//    time.backgroundColor = kClearColor;
//    time.font = [UIFont fontWithName:kFontFamily size:14];
//    time.text = @"时间: ";
//    time.textColor = [UIColor grayColor];
//    
//    [cell.contentView addSubview:time];
//    
//    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(time.frame.size.width + time.frame.origin.x, tempHeight, kScreenWidth - time.frame.size.width - time.frame.origin.x - 10, 14)];
//    timeLabel.backgroundColor = kClearColor;
//    timeLabel.font = [UIFont fontWithName:kFontFamily size:14];
//    timeLabel.text = [_orders[indexPath.row] objectForKey:@"create_at"];
//    timeLabel.textColor = COLOR(30, 144, 255, 1);
//    
//    [cell.contentView addSubview:timeLabel];
//    
//    tempHeight += time.frame.size.height + 8;
//    
//    // 状态
//    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10, tempHeight, 40, 14)];
//    status.backgroundColor = kClearColor;
//    status.font = [UIFont fontWithName:kFontFamily size:14];
//    status.text = @"状态: ";
//    status.textColor = [UIColor grayColor];
//    
//    [cell.contentView addSubview:status];
//    
//    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(status.frame.size.width + status.frame.origin.x, tempHeight, kScreenWidth - status.frame.size.width - status.frame.origin.x - 10, 14)];
//    statusLabel.backgroundColor = kClearColor;
//    statusLabel.font = [UIFont fontWithName:kFontFamily size:14];
//    statusLabel.text = [_orders[indexPath.row] objectForKey:@"status"];
//    statusLabel.textColor = [UIColor orangeColor];
//    
//    [cell.contentView  addSubview:statusLabel];
//    
    NSInteger statusInt = [[_orders[indexPath.row] objectForKey:@"status_value"] integerValue];

    // 发货按钮
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.tag = indexPath.row;
//    sendButton.layer.borderColor = [UIColor orangeColor].CGColor;
//    sendButton.layer.borderWidth = 1;
//    sendButton.layer.cornerRadius = 6;
//    sendButton.layer.masksToBounds = YES;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [sendButton setBackgroundColor:[UIColor orangeColor]];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(goToSend:) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.userType != 3) {
        if (statusInt == 2) {
            sendButton.frame = CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 29.5);
            [sendButton setTitle:@"去发货" forState:UIControlStateNormal];
        } else if (statusInt == 4) {
            sendButton.frame = CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 29.5);
            [sendButton setTitle:@"重新发货" forState:UIControlStateNormal];
        }
        
        [cell.contentView addSubview:sendButton];
    }
    
    NSString *expressURL = kNullToString([_orders[indexPath.row] objectForKey:@"express_url"]);
    
    // 快递按钮
    if (![expressURL isEqualToString:@""]) {
        UIButton *expressButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 29.5)];
        
        if (sendButton.frame.origin.x > 0) {
            expressButton.frame = CGRectMake(sendButton.frame.origin.x - 80, sendButton.frame.origin.y, 80, 29.5);
        }
        
        expressButton.tag = indexPath.row;
//        expressButton.layer.borderColor = [UIColor orangeColor].CGColor;
//        expressButton.layer.borderWidth = 1;
//        expressButton.layer.cornerRadius = 6;
//        expressButton.layer.masksToBounds = YES;
//        expressButton.titleLabel.font = kNormalFont;
        expressButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [expressButton setBackgroundColor:[UIColor orangeColor]];
        [expressButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        expressButton.alpha = 0.7;
        [expressButton setTitle:@"查看物流" forState:UIControlStateNormal];
        [expressButton addTarget:self action:@selector(goToExpress:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:expressButton];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AdminOrderDetailViewController *detail = [[AdminOrderDetailViewController alloc] init];
    detail.oid = kNullToString([_orders[indexPath.row] objectForKey:@"id"]);
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - UISearchBarDelegate -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _tableView.scrollEnabled = NO;
    _tableView.allowsSelection = NO;
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    NSArray *searchSubviews;
    
    @try {
        if (kDeviceOSVersion >= 7.0) {
            searchSubviews = [[searchBar.subviews objectAtIndex:0] subviews];
        } else {
            searchSubviews = searchBar.subviews;
        }
    }
    @catch (NSException *exception) {
        YunLog(@"get search subviews exception = %@", exception);
    }
    @finally {
        
    }
    
    for (id cc in searchSubviews) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)cc;
            btn.frame = CGRectMake(btn.frame.origin.x, 0, btn.frame.size.width, searchBar.frame.size.height);
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            btn.titleLabel.font = kNormalFont;
            
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    if ([_searchKey isEqualToString:searchBar.text]) {
        _tableView.scrollEnabled = YES;
        _tableView.allowsSelection = YES;
    } else {
        _searchKey = searchBar.text;
        
        [self doList];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    _searchKey = searchBar.text;
    
    [self doList];
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        UISearchBar *searchBar = (UISearchBar *)_tableView.tableHeaderView;
        searchBar.text = @"";
        _searchKey = @"";
        
        [self doList];
    }
}

#pragma mark - 创建上拉下拉刷新 -
/**
 *  创建上拉下拉刷新对象
 */
- (void)createMJRefresh
{
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

/**
 *  下拉刷新响应方法
 */
- (void)headerRereshing
{
    if (_isLoading == YES) return;
    
    [self doList];
}

/**
 *  上拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    [self getNextPageView];
}

- (void)getNextPageView
{
    _isLoading = YES;
    
    if (_orders.count >= 8) {
        NSInteger rc = _refreshCount;
        rc += 1;
        
        AppDelegate *appDelegate = kAppDelegate;
        
        NSDictionary *params = @{@"status"                  :   [NSString stringWithFormat:@"%u", orderTypes[_selectedOrderTypeIndex]],
                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                                 @"page"                    :   [NSString stringWithFormat:@"%ld", (long)rc],
                                 @"limit"                   :   @"8",
                                 @"shop_id"                 :   kNullToString(_shopID),
                                 @"channel"                 :   [NSString stringWithFormat:@"%ld", (long)_selectedOrderChannelTypeIndex],
                                 @"last_time_type"          :   [NSString stringWithFormat:@"%ld", (long)_selectedOrderTimeTypeIndex],
                                 @"key"                     :   kNullToString(_searchKey)};
        
        NSString *listURL = [Tool buildRequestURLHost:kRequestHost
                                           APIVersion:kAPIVersion2
                                           requestURL:kOrderAdminListURL
                                               params:params];
        
        YunLog(@"admin order listURL = %@", listURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:listURL
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"refresh admin order list responseObject = %@", responseObject);
                 
                 NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
                 
                 [_tableView footerEndRefreshing];
                 _isLoading = NO;
                 
                 if ([code isEqualToString:kSuccessCode]) {
                     NSArray *newOrders = [[responseObject objectForKey:@"data"] objectForKey:@"orders"];
                     
                     if (!newOrders) {
                         _tableView.footerHidden = YES;
                     } else if (newOrders.count > 0) {
                         _orders = [_orders arrayByAddingObjectsFromArray:newOrders];
                         _tableView.footerHidden = NO;
                         [_tableView reloadData];
                         
                         _refreshCount += 1;
                         
                         if (newOrders.count < 8) {
                             _tableView.footerHidden = YES;
                         } else {
                             
                         }
                     }
                 }
                 
                 else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                     _tableView.footerHidden = NO;

                     [Tool resetUser];
                     
                     [self backToPrev];
                 }
                 else
                 {
                     _tableView.footerHidden = NO;

                     [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"])
                                    delay:2.0];
                     
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 YunLog(@"refresh admin order list error = %@", error);
                 [_tableView footerEndRefreshing];
                 _tableView.footerHidden = NO;
                 _isLoading = NO;

                 if (![operation isCancelled]) {
                     [_hud addErrorString:@"获取更多订单失败" delay:2.0];
                     
                 }
             }];
    } else {
        [_tableView footerEndRefreshing];
        _tableView.footerHidden = YES;
        _isLoading = NO;
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    YunLog(@"point.y = %f,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4 = %f",point.y,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
    YunLog(@"scrollView.contentSize.height = %f", scrollView.contentSize.height);
    YunLog(@"scrollView.frame.size.height = %f", scrollView.frame.size.height);
    
    if (scrollView.contentSize.height > scrollView.frame.size.height) {
        if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
            && ( scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
            [self footerRereshing];
        }
    } else {
        if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
            && (scrollView.bounds.size.height - (self.view.frame.size.height / 4) * 3) > 0) {
            [self footerRereshing];
        }
    }
    
}

@end
