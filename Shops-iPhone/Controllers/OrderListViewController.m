//
//  OrderListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-12.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "OrderListViewController.h"

// Classes
#import "Tool.h"
#import "AppDelegate.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Views

// Controllers
#import "OrderDetailViewController.h"
#import "PayResultViewController.h"
#import "WebViewController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "ChooseBankViewController.h"
#import "RateProductViewController.h"
#import "PopGestureRecognizerController.h"

// Categories
#import "NSObject+NullToString.h"
#import "UIImageView+AFNetworking.h"

// Protocols
#import "WXPayDelegate.h"

// Libraries
#import "AFNetworking.h"
#import "Umpay.h"


@interface OrderListViewController () <UITableViewDataSource, UITableViewDelegate, UmpayDelegate, WXPayDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *back;
@property (nonatomic, strong) NSMutableArray *orders;

@property (nonatomic, strong) AFHTTPRequestOperation *op;
@property (nonatomic, strong) AFHTTPRequestOperation *payOp;

@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) NSInteger refreshCount;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) NSInteger pageNonce;
@property (nonatomic, assign) NSInteger pageMax;
@property (nonatomic, assign) NSInteger pageLimit;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) NSString *statusString;
@property (nonatomic, strong) NSMutableArray *orderArray;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) CALayer *selectedBottomLine;

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, assign) NSInteger selectedOrderTimeTypeIndex;

@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation OrderListViewController

- (NSMutableArray *)orderArray
{
    if (_orderArray == nil) {
        _orderArray = [NSMutableArray arrayWithObjects:@"全部", @"待支付", @"待发货", @"", @"待收货", @"已完成", nil];
    }
    return _orderArray;
}

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _orders = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    YunLog(@"_status - %@", _statusString);
    
    [self getDataSource:_statusString];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
//    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
//    [pop setPopGestureEnabled:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, kScreenHeight - 40) style:UITableViewStylePlain];
    
    if (kDeviceOSVersion < 7.0) {
        _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 40);
    }
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _tableView.showsHorizontalScrollIndicator = NO;
    
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
//    searchBar.delegate = self;
//    searchBar.placeholder = @"订单编号/手机/地址/姓名";
//    searchBar.autocapitalizationType = NO;
//    searchBar.autocorrectionType = NO;
//    
//    _tableView.tableHeaderView = searchBar;
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, (back.frame.size.height - 200) / 2 + 40, 120, 200)];
    imageView.image = [UIImage imageNamed:@"no_order"];
    
    [back addSubview:imageView];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;
    
    [self.view addSubview:_tableView];
    
    //加左划手势
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    // 设置滑动手势的方向
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [_tableView addGestureRecognizer:swipeLeft];
    
    //加右划手势
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    // 设置滑动手势的方向
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [_tableView addGestureRecognizer:swipeRight];

    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 40)];
    
    if (kDeviceOSVersion < 7.0) {
        _bottomView.frame = CGRectMake(-1, 0, kScreenWidth + 2, 48);
    }
    
    _bottomView.backgroundColor = kGrayColor;
    
    [self.view addSubview:_bottomView];
    
    NSArray *titles = @[@"全部", @"待支付", @"待发货", @"待收货", @"已完成",];
    
    for (int i = 0; i < 5; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * (kScreenWidth / 5), 0, kScreenWidth / 5, _bottomView.frame.size.height)];
        button.tag = i;
        button.titleLabel.font = kSmallFont;
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeOrderType:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        
        CGSize size = [titles[i] sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
        
        YunLog(@"_selectedOrderTypeIndex = %ld" ,(long)_selectedOrderTypeIndex);
        
        if (i == _selectedOrderTypeIndex) {
            button.selected = YES;
            _selectedButton = button;
            
            if (_selectedBottomLine) {
                [_selectedBottomLine removeFromSuperlayer];
            }
            
            _selectedBottomLine = [CALayer layer];
            _selectedBottomLine.frame = CGRectMake((button.frame.size.width - size.width - 4) / 2 + button.frame.origin.x, _bottomView.frame.size.height - 2, size.width + 4, 2);
            _selectedBottomLine.cornerRadius = 2;
            _selectedBottomLine.masksToBounds = YES;
            _selectedBottomLine.backgroundColor = [UIColor orangeColor].CGColor;
            
            [_bottomView.layer addSublayer:_selectedBottomLine];
        }
        
        [_bottomView addSubview:button];
    }

    
    self.view.backgroundColor = kBackgroundColor;
    _pageNonce = 1;
    
    _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
    
    _naviTitle.font = kBigFont;
    _naviTitle.backgroundColor = kClearColor;
    _naviTitle.textColor = kLightBlackColor;
    _naviTitle.textAlignment = NSTextAlignmentCenter;
    
    NSString *status;
    
    switch (_orderType) {
        case All:
            status = @"0";
            _naviTitle.text = @"全部";
            
            break;
            
        case WaitingForPay:
            status = @"1";
            _naviTitle.text = @"待支付";
            
            break;
            
        case AlreadyPay:
            status = @"2";
            _naviTitle.text = @"待发货";
            
            break;
            
        case WaitingForReceive:
            status = @"4";
            _naviTitle.text = @"待收货";
            
            break;
            
        case AlreadyComplete:
            status = @"5";
            _naviTitle.text = @"已完成";
            
            break;
        default:
            break;
    }
    
    _naviTitle.text = [_naviTitle.text stringByAppendingString:@"订单"];
    
    self.navigationItem.titleView = _naviTitle;
    _statusString = status;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
//    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
//                                              style:UITableViewStylePlain];
//    if (kDeviceOSVersion < 7.0) {
//        _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64);
//    } else {
//        _tableView.separatorInset = UIEdgeInsetsZero;
//    }
//    

//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
//    _tableView.separatorColor = [UIColor lightGrayColor];
//    
//    [self.view addSubview:_tableView];
//    
//    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, (back.frame.size.height - 200) / 2, 120, 200)];
//    imageView.image = [UIImage imageNamed:@"no_order"];
//    
//    [back addSubview:imageView];
//    
//    _tableView.backgroundView = back;
//    _tableView.backgroundView.hidden = YES;
    
//    [self doList];
    
//    [self createMJRefresh];
}

- (void)swipeLeft
{
    _selectedOrderTypeIndex++;
    
    if (_selectedOrderTypeIndex > 4)
    {
        _selectedOrderTypeIndex--;
        return;
    }
    
    YunLog(@"swipeLeft _selectedOrderTypeIndex = %ld",(long)_selectedOrderTypeIndex);
    for (id so in _bottomView.subviews) {
        if ([so isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)so;
            if (button.tag == _selectedOrderTypeIndex)
            {
                _selectedButton = button;
                [self changeOrderType:_selectedButton];
            }
        }
    }
}

- (void)swipeRight
{
    _selectedOrderTypeIndex--;
    
    if (_selectedOrderTypeIndex < 0)
    {
        _selectedOrderTypeIndex++;
        return;
    }
    
    YunLog(@"swipeLeft _selectedOrderTypeIndex = %ld",(long)_selectedOrderTypeIndex);
    for (id so in _bottomView.subviews) {
        if ([so isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)so;
            if (button.tag == _selectedOrderTypeIndex)
            {
                _selectedButton = button;
                [self changeOrderType:_selectedButton];
            }
        }
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
    
    _pageNonce = 1;
    
    if (_selectedOrderTypeIndex > 2)
    {
        [self getDataSource:[NSString stringWithFormat:@"%ld",(long)_selectedOrderTypeIndex + 1]];
    }
    else
    {
        [self getDataSource:[NSString stringWithFormat:@"%ld",(long)_selectedOrderTypeIndex]];
    }
}

/**
 *  上拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
   
    _pageNonce++;
    
    if (_selectedOrderTypeIndex > 2)
    {
        [self getMoreData:[NSString stringWithFormat:@"%ld",(long)_selectedOrderTypeIndex + 1] withPage:[NSString stringWithFormat:@"%ld",(long)_pageNonce]];
    }
    else
    {
        [self getMoreData:[NSString stringWithFormat:@"%ld",(long)_selectedOrderTypeIndex] withPage:[NSString stringWithFormat:@"%ld",(long)_pageNonce]];
    }
}

#pragma mark - Get Data Source -

- (void)getDataSource:(NSString *)status
{
    _isLoading = YES;
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"page"                    :   @"1",
                             @"per"                     :   kIsiPhone ? @"5" : @"8",
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"status"                  :   status};
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kOrderCommitURLNew params:params];
    
    YunLog(@"listURL = %@", listURL);
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"%d type order list responseObject = %@", (int)_orderType, responseObject);
             [_orders removeAllObjects];
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
             if ([code isEqualToString:kSuccessCode]) {
                 NSArray *orders = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"orders"]);
                 
                 for (int i = 0; i < orders.count; i ++) {
                     if ([orders[i][@"status"] isEqualToString:@"待付款"]) {
                         [_orders addObject:orders[i]];
                     } else {
                         [_orders addObjectsFromArray:kNullToArray(orders[i][@"sub_orders"])];
                     }
                     
                     YunLog(@"sub_orders = %@， _orders = %@", kNullToArray(orders[i][@"sub_orders"]), _orders);
                 }
//                 [_tableView headerEndRefreshing];
                  [_tableView reloadData];
 
                  if (_orders.count <= 0) {
                      _tableView.backgroundView.hidden = NO;
                      
                      _tableView.headerHidden = YES;
                      _tableView.footerHidden = YES;
                      [_tableView footerEndRefreshing];
                      [_tableView headerEndRefreshing];
                  } else {
                      _tableView.backgroundView.hidden = YES;
                      _tableView.headerHidden = NO;
                      
                      if (_orders.count <=5)
                      {
                          _tableView.footerHidden = YES;
                      }
                      else
                      {
                          _tableView.footerHidden = NO;
                      }
                  }
 
                  _tableView.scrollEnabled = YES;
                  _tableView.allowsSelection = YES;
 
                  [_hud hide:YES];
              } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                  [Tool resetUser];
                  
                  [self backToPrev];
              } else {
                  [_tableView reloadData];

                  [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                 delay:2.0];
                  
                  _tableView.backgroundView.hidden = NO;
              }
             _isLoading = NO;
             [_tableView headerEndRefreshing];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
             
             _tableView.backgroundView.hidden = NO;
             _isLoading = NO;
             _tableView.headerHidden = NO;
             _tableView.footerHidden = NO;
             [_tableView headerEndRefreshing];
             [_tableView footerEndRefreshing];
             
             YunLog(@"%d type order list error = %@", (int)_orderType, error);
         }];
}

- (void)getMoreData:(NSString *)status withPage:(NSString *)page
{
    _isLoading = YES;
    
    NSInteger rc = _refreshCount;
    rc += 1;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"page"                    :   kNullToString(page),
                             @"per"                     :   kIsiPhone ? @"5" : @"8",
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"status"                  :   status};
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kOrderCommitURLNew params:params];
    
    YunLog(@"listURL = %@", listURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"refresh admin order list responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 NSArray *orders = [[responseObject objectForKey:@"data"] objectForKey:@"orders"];
                 
                 NSMutableArray *newOrders = [NSMutableArray array];
                 
                 for (int i = 0; i < orders.count; i ++) {
                     if ([orders[i][@"status"] isEqualToString:@"待付款"]) {
                         [newOrders addObject:orders[i]];
                     } else {
                         [newOrders addObjectsFromArray:kNullToArray(orders[i][@"sub_orders"])];
                     }
                 }
                 if (!newOrders) {
                     _tableView.footerHidden = YES;
                     [_tableView footerEndRefreshing];
                     
                 } else if (newOrders.count > 0) {
                     [_orders addObjectsFromArray:newOrders];
                     
                     _tableView.footerHidden = NO;

                     [_tableView reloadData];
                     
                     _refreshCount += 1;
                 }
             }
             
             else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             }
             else
             {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"])
                                delay:2.0];
                 
             }
             
             _isLoading = NO;
             [_tableView footerEndRefreshing];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"refresh admin order list error = %@", error);
             
             _isLoading = NO;
             _tableView.footerHidden = NO;
             [_tableView footerEndRefreshing];
             [_tableView headerEndRefreshing];

             if (![operation isCancelled]) {
                 [_hud addErrorString:@"获取更多订单失败" delay:2.0];
                 
                 [_tableView footerEndRefreshing];
                 [_tableView headerEndRefreshing];
             }
         }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    _refreshFooterView.delegate = nil;
    _tableView.delegate = nil;
}

#pragma mark - Private Functions -

- (void)changeOrderType:(UIButton *)sender
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";

    for (id so in _bottomView.subviews) {
        if ([so isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)so;
            button.selected = NO;
        }
    }
    
    YunLog(@"sender.tag = %ld", (long)sender.tag);
    
    sender.selected = YES;
    _selectedButton = sender;
    _selectedOrderTypeIndex = sender.tag;
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:kSmallFont}];
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.5];
    
    _selectedBottomLine.frame = CGRectMake((sender.frame.size.width - size.width - 4) / 2 + sender.frame.origin.x, _bottomView.frame.size.height - 2, size.width + 4, 2);
    
    [UIView commitAnimations];
    
    _pageNonce = 1;
    if (_selectedOrderTypeIndex > 2)
    {
        [self getDataSource:[NSString stringWithFormat:@"%ld",(long)_selectedOrderTypeIndex + 1]];
    }
    else
    {
        [self getDataSource:[NSString stringWithFormat:@"%ld",(long)_selectedOrderTypeIndex]];
    }
    
    switch (_selectedOrderTypeIndex) {
        case 0:
            _naviTitle.text = @"全部";
            _statusString = @"0";
            
            break;
            
        case WaitingForPay:
            _naviTitle.text = @"待支付";
            _statusString = @"1";
            
            break;
            
        case AlreadyPay:
            _naviTitle.text = @"待发货";
            _statusString = @"2";
            
            break;
            
        case WaitingForReceive:
            _naviTitle.text = @"待收货";
            _statusString = @"4";
            
            break;
            
        case AlreadyComplete:
            _naviTitle.text = @"已完成";
            _statusString = @"5";
            
            break;
        default:
            break;
    }
    _naviTitle.text = [_naviTitle.text stringByAppendingString:@"订单"];
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [_tableView removeHeader];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushToShop:(UIButton *)sender
{
    ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
    shop.code = [_orders[sender.tag] objectForKey:@"shop_code"];
    
    [self.navigationController pushViewController:shop animated:YES];
}

- (void)goToExpress:(UIButton *)sender
{
    NSString *expressURL = [_orders[sender.tag] objectForKey:@"express_url"];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    expressURL = [expressURL stringByAppendingFormat:@"&platform=iphone&user_session_key=%@", appDelegate.user.userSessionKey];
    
    YunLog(@"expressURL = %@", expressURL);
    
    WebViewController *web = [[WebViewController alloc] init];
    web.naviTitle = @"物流详情";
    web.url = expressURL;
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)goToPay:(UIButton *)sender
{
    sender.enabled = NO;
    
    NSDictionary *order = _orders[sender.tag];

    _tableView.allowsSelection = NO;

    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"oid"                     :   order[@"id"]};
    
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
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [weakSelf.hud hide:YES];
            
            sender.enabled = YES;
            
            weakSelf.tableView.allowsSelection = YES;
        
            NSString *tradeNO = kNullToString([[[responseObject objectForKey:@"data"] objectForKey:@"page_pay"] objectForKey:@"upay_trade_no"]);
            if (![tradeNO isEqualToString:@""]) {
                @try {
                    // 修复点击orderlist立即支付时的显示上一次选中cell的价格的bug
                    ChooseBankViewController *bankVC = [[ChooseBankViewController alloc] init];
                    
                    bankVC.tradeNO = tradeNO;
                    
//                    for (NSDictionary *dictionary in weakSelf.orders)
//                    {
//                        if ([[[dictionary objectForKey:@"id"] stringValue] isEqualToString:[NSString stringWithFormat:@"%ld",(long)sender.tag]])
//                        {
                            bankVC.price = [NSString stringWithFormat:@"￥%@", order[@"total_price"]];
                            YunLog(@"bankVC.price = %@",bankVC.price);
//                        }
//                    }
                    
                    bankVC.index = [weakSelf.navigationController.viewControllers indexOfObject:weakSelf];

                    [weakSelf.navigationController pushViewController:bankVC animated:YES];
                }
                @catch (NSException *exception) {
                    YunLog(@"umpay result exception = %@", exception);
                    
                    [weakSelf.hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
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
                req.timeStamp   = (UInt32)[response[@"timestamp"] intValue];
                req.package     = response[@"package"];
                req.sign        = response[@"sign"];
                
                [WXApi sendReq:req];
            }
            
            else {
                @try {
                    PayResultViewController *result = [[PayResultViewController alloc] init];
                    result.payURL = [[[responseObject objectForKey:@"data"] objectForKey:@"page_pay"] objectForKey:@"pay_url"];
                    
                    YunLog(@"result.payURL = %@",result.payURL);
                    
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
            [weakSelf.hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
            
            sender.enabled = YES;
            
            weakSelf.tableView.allowsSelection = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"get pay page error = %@", error);
        
        if ([weakSelf.payOp isCancelled]) {
            [weakSelf.hud addErrorString:@"用户取消支付" delay:2.0];
        } else {
            [weakSelf.hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
        }
        
        sender.enabled = YES;
        
        weakSelf.tableView.allowsSelection = YES;
    }];
    
    [_payOp start];
}

/**
 取消订单
 
 @param sender 点击的订单标记
 */
- (void)cancelOrder:(UIButton *)sender
{
    NSDictionary *order = _orders[sender.tag];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *cancelURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/order_parents/%@/cancel.json",order[@"number"]] params:params];
    
    YunLog(@"cancelURL = %@", cancelURL);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"取消订单中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager PATCH:cancelURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject = %@",responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
        
        [self headerRereshing];
        
        [_hud addSuccessString:@"订单取消成功" delay:1.0];
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
 评价订单
 
 @param sender 点击的订单标记
 */
- (void)goToRate:(UIButton *)sender
{
    RateProductViewController *rateVC = [[RateProductViewController alloc] initWithOrderId:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    
    [self.navigationController pushViewController:rateVC animated:YES];
}

/**
 确认收货
 
 @param sender 点击的订单标记
 */
- (void)received:(UIButton *)sender
{
    NSDictionary *order = _orders[sender.tag];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *receivedURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/orders/%@/confirm.json",order[@"no"]] params:params];
    
    YunLog(@"receivedURL = %@", receivedURL);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"确认收货中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager PATCH:receivedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject = %@",responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [self headerRereshing];
            
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

- (void)backToPrev:(UIButton *)sender
{
    if (sender) {
        if (_hud) [_hud hide:NO];
    }
    
    if ([_op isExecuting]) {
        [_op cancel];
    }
    
    if ([_payOp isExecuting]) {
        [_payOp cancel];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModalController object:self];
    });
}

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
    NSDictionary *order = _orders[indexPath.row];
    
    if ([[order objectForKey:@"status"] isEqualToString:@"已发货"])
    {
        return 148 + 90 * [order[@"items"] count] + 3 * ([order[@"items"] count] -1) + 10;
    } else if ([[order objectForKey:@"status"] isEqualToString:@"待付款"]) {
        NSInteger itemNum = 0;
        for (int i = 0; i < [order[@"sub_orders"] count]; i ++) {
            itemNum += [order[@"sub_orders"][i][@"items"] count];
        }
        return 37 * ([order[@"sub_orders"] count] * 2 + 2) + 90 * itemNum + 3 * (itemNum - [order[@"sub_orders"] count]) + 10;
    } else {
        return 111 + 90 * [order[@"items"] count] + 3 * ([order[@"items"] count] -1) + 10;
    }
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kGrayColor;
    
    NSDictionary *order = _orders[indexPath.row];
    
    // 背景白色
    UIView *backView = [[UIView alloc] init];
    
    backView.backgroundColor = kBackgroundColor;
    
    [cell.contentView addSubview:backView];
    
    CGFloat itemY = 0;
    
    CGFloat shopY = 0;
    
    NSInteger itemCount = 0;
    
    NSInteger count = 0;
    
    // 订单商品
    if ([[order objectForKey:@"status"] isEqualToString:@"待付款"]) {
        for (int i = 0; i < [order[@"sub_orders"] count]; i ++) {
            
            NSDictionary *subOrder = order[@"sub_orders"][i];

            // 店铺名称和状态
            UILabel *orderStatus = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 60, shopY, 60, 37)];
            orderStatus.text = subOrder[@"status"];
//                orderStatus.backgroundColor = kRedColor;
            orderStatus.textAlignment = NSTextAlignmentRight;
            orderStatus.textColor = kOrangeColor;
            orderStatus.font = kMidFont;
            
            [backView addSubview:orderStatus];
            
            UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(10, shopY, CGRectGetMinX(orderStatus.frame) - 20, 37)];
            shopName.text = [NSString stringWithFormat:@"店铺：%@", subOrder[@"shop_name"]];
//                shopName.backgroundColor = kOrangeColor;
            shopName.textColor = kLightBlackColor;
            shopName.font = kMidFont;
            
            [backView addSubview:shopName];
            
            UILabel *orderNum = [[UILabel alloc] initWithFrame:CGRectMake(10, shopY + 37, (kScreenWidth - 40) / 2, 37)];
            orderNum.text = [NSString stringWithFormat:@"订单编号：%@", subOrder[@"no"]];
//            orderNum.backgroundColor = kOrangeColor;
            orderNum.textColor = kLightBlackColor;
            orderNum.font = kSmallFont;
            orderNum.adjustsFontSizeToFitWidth = YES;
            
            [cell.contentView addSubview:orderNum];
            
            UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orderNum.frame) + 20, shopY + 37, (kScreenWidth - 40) / 2, 37)];
            time.text = [NSString stringWithFormat:@"时间：%@", subOrder[@"create_at"]];
//            time.backgroundColor = kOrangeColor;
            time.textColor = kLightBlackColor;
            time.font = kSmallFont;
            time.textAlignment = NSTextAlignmentRight;
            time.adjustsFontSizeToFitWidth = YES;

            [cell.contentView addSubview:time];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, shopY + 37, kScreenWidth, 0.5)];
            line.backgroundColor = kGrayColor;
            
            [cell.contentView addSubview:line];
            
            for (int j = 0; j < [subOrder[@"items"] count]; j ++) {
                NSDictionary *item = subOrder[@"items"][j];
                
                itemCount += [subOrder[@"items"][j][@"quantity"] integerValue];
                
                CGFloat y = 0;
                
                if (i == 0) {
                    y = 37 * (i * 2 + 2) + count * 93;
                } else {
                    y = 37 * (i * 2 + 2) + count * 93 - 3 * i;
                }
                
                UIView *itemBackView = [[UIView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 90)];
                itemBackView.backgroundColor = COLOR(245, 244, 245, 1);
                
                [backView addSubview:itemBackView];
                
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
                itemName.text = item[@"product_name"];
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
                
                itemY = y;
                
                count += 1;
            }
            
            shopY = itemY + 90;
        }
    } else {
        // 店铺名称和状态
        UILabel *orderStatus = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 60, 0, 60, 37)];
        orderStatus.text = order[@"status"];
        //    orderStatus.backgroundColor = kRedColor;
        orderStatus.textAlignment = NSTextAlignmentRight;
        orderStatus.textColor = kOrangeColor;
        orderStatus.font = kMidFont;
        
        [backView addSubview:orderStatus];
        
        UILabel *shopName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetMinX(orderStatus.frame) - 20, 37)];
        shopName.text = [NSString stringWithFormat:@"店铺：%@", order[@"shop_name"]];
        //    shopName.backgroundColor = kOrangeColor;
        shopName.textColor = kLightBlackColor;
        shopName.font = kMidFont;
        
        [backView addSubview:shopName];
        
        UILabel *orderNum = [[UILabel alloc] initWithFrame:CGRectMake(10, 37, (kScreenWidth - 40) / 2, 37)];
        orderNum.text = [NSString stringWithFormat:@"订单编号：%@", order[@"no"]];
        //    shopName.backgroundColor = kOrangeColor;
        orderNum.textColor = kLightBlackColor;
        orderNum.font = kSmallFont;
        orderNum.adjustsFontSizeToFitWidth = YES;

        [cell.contentView addSubview:orderNum];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(orderNum.frame) + 20, 37, (kScreenWidth - 40) / 2, 37)];
        time.text = [NSString stringWithFormat:@"时间：%@", order[@"create_at"]];
        //    shopName.backgroundColor = kOrangeColor;
        time.textColor = kLightBlackColor;
        time.font = kSmallFont;
        time.textAlignment = NSTextAlignmentRight;
        time.adjustsFontSizeToFitWidth = YES;

        [cell.contentView addSubview:time];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 37, kScreenWidth, 0.5)];
        line.backgroundColor = kGrayColor;
        
        [cell.contentView addSubview:line];

        for (int i = 0; i < [order[@"items"] count]; i ++) {
            NSDictionary *item = order[@"items"][i];
            
            itemCount += [order[@"items"][i][@"quantity"] integerValue];
            
            CGFloat y = 74 + i * 93;
            
            UIView *itemBackView = [[UIView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 90)];
            itemBackView.backgroundColor = COLOR(245, 244, 245, 1);
            
            [backView addSubview:itemBackView];
            
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
            itemName.text = item[@"product_name"];
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
            
            itemY = y;
        }
    }
    
    // 商品价格
    UILabel *orderPrice = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 220, itemY + 90, 220, 37)];
    orderPrice.text = [NSString stringWithFormat:@"总价合计：¥%@ （含运费：¥%@）", order[@"pay_price"], order[@"shipment_price"]];
//    orderPrice.backgroundColor = kRedColor;
    orderPrice.textAlignment = NSTextAlignmentRight;
    orderPrice.textColor = kLightBlackColor;
    orderPrice.font = kSmallFont;
    
    [backView addSubview:orderPrice];
    
    UILabel *itemNum = [[UILabel alloc] initWithFrame:CGRectMake(10, itemY + 90, CGRectGetMinX(orderPrice.frame) - 20, 37)];
    itemNum.text = [NSString stringWithFormat:@"商品共%lu件", itemCount];
//    itemNum.backgroundColor = kOrangeColor;
    itemNum.textColor = kLightBlackColor;
    itemNum.font = kSmallFont;
    
    [backView addSubview:itemNum];
    
    if ([[order objectForKey:@"status"] isEqualToString:@"已发货"])
    {
        backView.frame = CGRectMake(0, 0, kScreenWidth, 148 + 90 * [order[@"items"] count] + 3 * ([order[@"items"] count] -1));
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(itemNum.frame) - 0.5, kScreenWidth, 0.5)];
        line.backgroundColor = kGrayColor;
        
        [backView addSubview:line];
        
//        if ([[order objectForKey:@"status"] isEqualToString:@"待付款"]) {
//            // 立即付款按钮
//            UIButton *goToPay = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 37)];
//            goToPay.tag = [[order objectForKey:@"id"] integerValue];
//            [goToPay setBackgroundColor:[UIColor orangeColor]];
//            [goToPay setTitle:@"立即付款" forState:UIControlStateNormal];
//            goToPay.titleLabel.font = kMidFont;
//            [goToPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [goToPay addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
//    
//            [cell.contentView addSubview:goToPay];
//    
//            // 取消订单按钮
//            UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 80, CGRectGetMaxY(line.frame), 80, 37)];
//            cancel.tag = indexPath.row;
//            cancel.backgroundColor = COLOR(75, 74, 75, 1);
//            [cancel setTitle:@"取消订单" forState:UIControlStateNormal];
//            cancel.titleLabel.font = kMidFont;
//            [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [cancel addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:cancel];
//        } else {
            // 确认收货按钮
            UIButton *confirm = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 37)];
            confirm.tag = indexPath.row;
            [confirm setBackgroundColor:[UIColor orangeColor]];
            [confirm setTitle:@"确认收货" forState:UIControlStateNormal];
            confirm.titleLabel.font = kMidFont;
            [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [confirm addTarget:self action:@selector(received:) forControlEvents:UIControlEventTouchUpInside];
        
            [cell.contentView addSubview:confirm];
            
            // 查看物流按钮
            UIButton *logistics = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 80, CGRectGetMaxY(line.frame), 80, 37)];
            logistics.tag = indexPath.row;
            logistics.backgroundColor = COLOR(75, 74, 75, 0.8);
            [logistics setTitle:@"查看物流" forState:UIControlStateNormal];
            logistics.titleLabel.font = kMidFont;
            [logistics setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [logistics addTarget:self action:@selector(goToExpress:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:logistics];
//        }
    } else if ([[order objectForKey:@"status"] isEqualToString:@"待付款"]) {
        NSInteger itemNumber = 0;
        NSInteger allNumber = 0;
        CGFloat allPrice = 0;
        for (int i = 0; i < [order[@"sub_orders"] count]; i ++) {
            itemNumber += [order[@"sub_orders"][i][@"items"] count];
            allPrice += [order[@"sub_orders"][i][@"original_price"] floatValue];
            for (int j = 0; j < [order[@"sub_orders"][i][@"items"] count]; j ++) {
                allNumber += [order[@"sub_orders"][i][@"items"][j][@"quantity"] integerValue];
            }
        }
        
        backView.frame = CGRectMake(0, 0, kScreenWidth, 37 * ([order[@"sub_orders"] count] * 2 + 2) + 90 * itemNumber + 3 * (itemNumber - [order[@"sub_orders"] count]));
        
        orderPrice.frame = CGRectMake(kScreenWidth - 220, shopY, 220, 37);
        
        itemNum.frame = CGRectMake(10, shopY, CGRectGetMinX(orderPrice.frame) - 20, 37);
        
        orderPrice.text = [NSString stringWithFormat:@"总价合计：¥%@ （含运费：¥%0.2f）", order[@"pay_cash_total_price"], [order[@"pay_cash_total_price"] floatValue] - allPrice];
        
        itemNum.text = [NSString stringWithFormat:@"商品共%lu件", allNumber];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(itemNum.frame) - 0.5, kScreenWidth, 0.5)];
        line.backgroundColor = kGrayColor;
        
        [backView addSubview:line];
        
        // 立即付款按钮
        UIButton *goToPay = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 37)];
        goToPay.tag = indexPath.row;
        [goToPay setBackgroundColor:[UIColor orangeColor]];
        [goToPay setTitle:@"立即付款" forState:UIControlStateNormal];
        goToPay.titleLabel.font = kMidFont;
        [goToPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [goToPay addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:goToPay];
        
        // 取消订单按钮
        UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 80, CGRectGetMaxY(line.frame), 80, 37)];
        cancel.tag = indexPath.row;
        cancel.backgroundColor = COLOR(75, 74, 75, 1);
        [cancel setTitle:@"取消订单" forState:UIControlStateNormal];
        cancel.titleLabel.font = kMidFont;
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:cancel];
    } else {
        backView.frame = CGRectMake(0, 0, kScreenWidth, 111 + 90 * [order[@"items"] count] + 3 * ([order[@"items"] count] -1));
    }
    
//    int height = 10;
//    
//    cell.contentView.backgroundColor = kGrayColor;
//    
//    UIView *backView = [[UIView alloc] init];
//    
//    if (![[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"])
//    {
//        backView.frame = CGRectMake(0, 46, kScreenSize.width, 98);
//    }
//    else
//    {
//        backView.frame = CGRectMake(0, 46, kScreenSize.width, 128);
//    }
//    
//    backView.backgroundColor = [UIColor whiteColor];
//    
//    [cell.contentView addSubview:backView];
//    
//    // 顶部 title
//    UIButton *topContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 36)];
//    topContainer.backgroundColor = COLOR(245, 244, 245, 1);
//    topContainer.tag = indexPath.row;
//    
//    [cell.contentView addSubview:topContainer];
//    
////    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 26, 10, 16, 16)];
////    rightArrow.image = [UIImage imageNamed:@"right_arrow_16"];
////    
////    [topContainer addSubview:rightArrow];
//    
//    // 编号
//    UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 170, 36)];
//    noLabel.backgroundColor = kClearColor;
//    noLabel.font = kSmallFont;
//    noLabel.text = [NSString stringWithFormat:@"编号: %@", [_orders[indexPath.row] objectForKey:@"no"]];
//    
//    [topContainer addSubview:noLabel];
//    
//    // 金额
//    CGSize moneyLabelSize = [[NSString stringWithFormat:@"￥%@", [_orders[indexPath.row] objectForKey:@"total_price"]] sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
//    
//    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 10 - moneyLabelSize.width, topContainer.frame.size.height + 30, moneyLabelSize.width, moneyLabelSize.height)];
//    moneyLabel.backgroundColor = kClearColor;
//    moneyLabel.font = kBigFont;
//    moneyLabel.textAlignment = NSTextAlignmentRight;
//    moneyLabel.text = [NSString stringWithFormat:@"￥%@", [_orders[indexPath.row] objectForKey:@"total_price"]];
//    moneyLabel.textColor = [UIColor orangeColor];
//    moneyLabel.textAlignment = NSTextAlignmentRight;
//    
//    [cell.contentView addSubview:moneyLabel];
//    
//    height += topContainer.frame.size.height + 6;
//    
//    // 图片
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, height, 86, 86)];
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
//    [imageView setImageWithURL:[NSURL URLWithString:kNullToString([_orders[indexPath.row] objectForKey:@"icon"])]
//              placeholderImage:[UIImage imageNamed:@"default_image"]];
//    
//    int tempHeight = height;
//    
//    // 时间
//    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 150 - 10, CGRectGetMaxY(imageView.frame) - 30, 150, 12)];
//    time.backgroundColor = kClearColor;
//    time.textAlignment = NSTextAlignmentRight;
//    time.font = [UIFont fontWithName:kFontFamily size:12];
//    time.text = [NSString stringWithFormat:@"%@",[_orders[indexPath.row] objectForKey:@"create_at"]];
////    time.textColor = [UIColor grayColor];
//    
//    [cell.contentView addSubview:time];
//    
//    //分割线
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 6, kScreenSize.width, 0.5)];
//    line.backgroundColor = [UIColor lightGrayColor];
//    
//    [cell.contentView addSubview:line];
//    
//    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"])
//    {
//        line.hidden = NO;
//    }
//    else
//    {
//        line.hidden = YES;
//    }
//    
//    
//    
////    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(time.frame.size.width + time.frame.origin.x, tempHeight, kScreenWidth - time.frame.size.width - time.frame.origin.x - 10, 14)];
////    timeLabel.backgroundColor = kClearColor;
////    timeLabel.font = [UIFont fontWithName:kFontFamily size:14];
////    timeLabel.text = [_orders[indexPath.row] objectForKey:@"create_at"];
////    timeLabel.textColor = COLOR(30, 144, 255, 1);
////    
////    [cell.contentView addSubview:timeLabel];
//    
//    tempHeight = CGRectGetMaxY(imageView.frame) + 6;
//    
//    // 状态
//    CGSize statusLabelSize = [[_orders[indexPath.row] objectForKey:@"status"] sizeWithAttributes:@{NSFontAttributeName:kSmallFont}];
//    
//    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 10 - statusLabelSize.width - 30, 0, 30, 36)];
//    status.backgroundColor = kClearColor;
//    status.font = kSmallFont;
//    status.text = @"状态: ";
//    status.textColor = [UIColor darkGrayColor];
//    
//    [topContainer addSubview:status];
//    
//    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenSize.width - 10 - statusLabelSize.width, 0, statusLabelSize.width, topContainer.frame.size.height)];
//    statusLabel.textAlignment = NSTextAlignmentRight;
//    statusLabel.backgroundColor = kClearColor;
//    statusLabel.font = kSmallFont;
//    statusLabel.text = kNullToString([_orders[indexPath.row] objectForKey:@"status"]);
//    
//    YunLog( @"status = %@",statusLabel.text);
//    
//    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"已取消"])
//    {
//        statusLabel.textColor = [UIColor lightGrayColor];
//    }
//    else
//    {
//        statusLabel.textColor = [UIColor orangeColor];
//    }
//    
//    [topContainer addSubview:statusLabel];
//    
//    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"]) {
//        // 支付按钮
//        UIButton *goToPay = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 29.5)];
//        goToPay.tag = [[_orders[indexPath.row] objectForKey:@"id"] integerValue];
////        goToPay.layer.borderColor = [UIColor orangeColor].CGColor;
////        goToPay.layer.borderWidth = 0;
////        goToPay.layer.cornerRadius = 3;
////        goToPay.layer.masksToBounds = YES;
//        [goToPay setBackgroundColor:[UIColor orangeColor]];
//        [goToPay setTitle:@"立即支付" forState:UIControlStateNormal];
//        goToPay.titleLabel.font = [UIFont systemFontOfSize:15.0];
//        [goToPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [goToPay addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [cell.contentView addSubview:goToPay];
//        
//        // 取消订单按钮
//        UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80 - 80, CGRectGetMaxY(line.frame), 80, 29.5)];
//        cancel.tag = [[_orders[indexPath.row] objectForKey:@"id"] integerValue];
//        cancel.backgroundColor = COLOR(75, 74, 75, 1);
////        cancel.layer.borderColor = [UIColor orangeColor].CGColor;
////        cancel.layer.borderWidth = 0;
////        cancel.layer.cornerRadius = 3;
////        cancel.layer.masksToBounds = YES;
//        [cancel setTitle:@"取消订单" forState:UIControlStateNormal];
//        cancel.titleLabel.font = [UIFont systemFontOfSize:14.0];
//        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [cancel addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:cancel];
//        
////        // 修改支付方式按钮
////        UIButton *changePayType = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 60 - 60 - 10 - 90 - 10, 176 - 25 - 20, 90, 25)];
////        changePayType.tag = [[_orders[indexPath.row] objectForKey:@"id"] integerValue];
////        changePayType.layer.borderColor = [UIColor orangeColor].CGColor;
////        changePayType.layer.borderWidth = 0;
////        changePayType.layer.cornerRadius = 3;
////        changePayType.layer.masksToBounds = YES;
////        [changePayType setTitle:@"修改支付方式" forState:UIControlStateNormal];
////        changePayType.titleLabel.font = [UIFont systemFontOfSize:14.0];
////        [changePayType setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
////        [changePayType addTarget:self action:@selector(changePayType:) forControlEvents:UIControlEventTouchUpInside];
////
////        [cell.contentView addSubview:changePayType];
//    }
//    
////    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"订单完成"]) {
////        // 去评价按钮
////        UIButton *goToRate = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, CGRectGetMaxY(line.frame), 80, 29.5)];
////        goToRate.tag = [[_orders[indexPath.row] objectForKey:@"id"] integerValue];
////        //        goToPay.layer.borderColor = [UIColor orangeColor].CGColor;
////        //        goToPay.layer.borderWidth = 0;
////        //        goToPay.layer.cornerRadius = 3;
////        //        goToPay.layer.masksToBounds = YES;
////        [goToRate setBackgroundColor:[UIColor orangeColor]];
////        [goToRate setTitle:@"去评价" forState:UIControlStateNormal];
////        goToRate.titleLabel.font = [UIFont systemFontOfSize:15.0];
////        [goToRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////        [goToRate addTarget:self action:@selector(goToRate:) forControlEvents:UIControlEventTouchUpInside];
////        
////        [cell.contentView addSubview:goToRate];
////    }
//
//    NSString *expressURL = kNullToString([_orders[indexPath.row] objectForKey:@"express_url"]);
//    
//    // 快递按钮
//    if (![expressURL isEqualToString:@""]) {
//        UIButton *expressButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 90, 176 - 32 - 20, 90, 32)];
//        expressButton.tag = indexPath.row;
//        expressButton.layer.borderColor = [UIColor orangeColor].CGColor;
//        expressButton.layer.borderWidth = 1;
//        expressButton.layer.cornerRadius = 6;
//        expressButton.layer.masksToBounds = YES;
//        [expressButton setTitle:@"查看物流" forState:UIControlStateNormal];
//        [expressButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//        [expressButton addTarget:self action:@selector(goToExpress:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [cell.contentView addSubview:expressButton];
//    }
//    
////    UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 14)];
////    number.backgroundColor = kClearColor;
////    number.font = [UIFont fontWithName:kFontFamily size:14];
////    number.text = [NSString stringWithFormat:@"编号: %@", [_orders[indexPath.row] objectForKey:@"no"]];
////    
////    [topContainer addSubview:number];
////    
////    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 100, 14)];
////    price.backgroundColor = kClearColor;
////    price.font = [UIFont fontWithName:kFontFamily size:14];
////    price.textAlignment = NSTextAlignmentRight;
////    price.textColor = [UIColor orangeColor];
////    price.text = [NSString stringWithFormat:@"￥%@", [[_orders objectAtIndex:indexPath.row] objectForKey:@"total_price"]];
////    
////    [topContainer addSubview:price];
////    
////    NSArray *items = [_orders[indexPath.row] objectForKey:@"items"];
////    for (int i = 0; i < items.count; i++) {
////        UIView *itemContainer = [[UIView alloc] initWithFrame:CGRectMake(0, topContainer.frame.size.height + i * 81 + height, kScreenWidth, 80)];
////        [cell.contentView addSubview:itemContainer];
////        
////        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 135, 100)];
////        [imageView setImageWithURL:[NSURL URLWithString:[items[i] objectForKey:@"icon"]]
////                  placeholderImage:[UIImage imageNamed:@"default_image"]];
////        
////        imageView.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
////        imageView.layer.shadowOpacity = 1.0;
////        imageView.layer.shadowRadius = 5.0;
////        imageView.layer.shadowOffset = CGSizeMake(0, 1);
////        
////        imageView.clipsToBounds = NO;
////        
////        [itemContainer addSubview:imageView];
////        
////        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, kScreenWidth - 170, 14)];
////        time.backgroundColor = kClearColor;
////        time.font = [UIFont fontWithName:kFontFamily size:14];
////        time.text = [NSString stringWithFormat:@"时间: %@", [_orders[indexPath.row] objectForKey:@"create_at"]];
////        
////        [itemContainer addSubview:time];
////        
////        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(160, 28, kScreenWidth - 170, 14)];
////        status.backgroundColor = kClearColor;
////        status.font = [UIFont fontWithName:kFontFamily size:14];
////        status.textAlignment = NSTextAlignmentRight;
////        status.text = [NSString stringWithFormat:@"状态: %@", [_orders[indexPath.row] objectForKey:@"status"]];
////        status.textColor = COLOR(30, 144, 255, 1);
////        
////        [itemContainer addSubview:status];
////
////        
////        NSString *text = [items[i] objectForKey:@"name"];
////        CGSize size = [text sizeWithFont:[UIFont fontWithName:kFontFamily size:14]
////                       constrainedToSize:CGSizeMake(210, 48)
////                           lineBreakMode:NSLineBreakByClipping
////                             lineSpacing:0
////                        characterSpacing:0
////                            kerningTable:nil
////                            allowOrphans:YES];
////        
////        FXLabel *title = [[FXLabel alloc] initWithFrame:CGRectMake(100, 12, 210, size.height)];
////        title.backgroundColor = kClearColor;
////        title.font = [UIFont fontWithName:kFontFamily size:14];
////        title.text = text;
////        title.numberOfLines = 0;
////        title.lineSpacing = 0;
////        
////        [itemContainer addSubview:title];
////        
////        UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(100, 54, 210, 14)];
////        money.backgroundColor = kClearColor;
////        money.font = [UIFont fontWithName:kFontFamily size:14];
////        money.text = [NSString stringWithFormat:@"￥%@ x %@", [items[i] objectForKey:@"price"], [items[i] objectForKey:@"count"]];
////        
////        [itemContainer addSubview:money];
////
////        if (i == items.count - 1) {
////            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(10, itemContainer.frame.size.height, kScreenWidth - 20, 1)];
////            [itemContainer addSubview:line];
////            
////            UIGraphicsBeginImageContext(line.frame.size);
////            [line.image drawInRect:CGRectMake(0, 0, line.frame.size.width, 1)];
////            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
////            
////            CGContextRef ctx = UIGraphicsGetCurrentContext();
////            CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
////            
////            CGContextMoveToPoint(ctx, 0, 1);
////            CGContextAddLineToPoint(ctx, line.frame.size.width, 1);
////            CGContextStrokePath(ctx);
////            
////            line.image = UIGraphicsGetImageFromCurrentImageContext();
////            UIGraphicsEndImageContext();
////        } else {
////            UIImageView *dash = [[UIImageView alloc] initWithFrame:CGRectMake(10, itemContainer.frame.size.height, 300, 1)];
////            [itemContainer addSubview:dash];
////            
////            UIGraphicsBeginImageContext(dash.frame.size);
////            [dash.image drawInRect:CGRectMake(0, 0, 300, 1)];
////            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
////            
////            CGFloat lengths[] = {5, 5};
////            CGContextRef ctx = UIGraphicsGetCurrentContext();
////            CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
////            
////            CGContextSetLineDash(ctx, 0, lengths, 2);
////            CGContextMoveToPoint(ctx, 0, 1);
////            CGContextAddLineToPoint(ctx, 300, 1);
////            CGContextStrokePath(ctx);
////            
////            dash.image = UIGraphicsGetImageFromCurrentImageContext();
////            UIGraphicsEndImageContext();
////        }
////    }
////    
////    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(10, height + 10 + 36 + 81 * [[_orders[indexPath.row] objectForKey:@"items"] count], 32, 12)];
////    status.backgroundColor = kClearColor;
////    status.font = kSmallFont;
////    status.text = @"状态: ";
////    status.textColor = [UIColor grayColor];
////    
////    [cell.contentView  addSubview:status];
////    
////    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + status.frame.size.width, status.frame.origin.y, 100, 12)];
////    statusLabel.backgroundColor = kClearColor;
////    statusLabel.font = kSmallFont;
////    statusLabel.text = [_orders[indexPath.row] objectForKey:@"status"];
////    statusLabel.textColor = COLOR(30, 144, 255, 1);
////    
////    [cell.contentView  addSubview:statusLabel];
////
////    UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake(10, status.frame.origin.y + status.frame.size.height + 8, 32, 12)];
////    total.backgroundColor = kClearColor;
////    total.font = kSmallFont;
////    total.text = @"总价: ";
////    total.textColor = [UIColor grayColor];
////    
////    [cell.contentView  addSubview:total];
////    
////    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + total.frame.size.width, total.frame.origin.y, 100, 12)];
////    totalLabel.backgroundColor = kClearColor;
////    totalLabel.font = kSmallFont;
////    totalLabel.text = [NSString stringWithFormat:@"￥%@", [_orders[indexPath.row] objectForKey:@"total_price"]];
////    totalLabel.textColor = [UIColor orangeColor];
////    
////    [cell.contentView  addSubview:totalLabel];
////
////    if ([[_orders[indexPath.row] objectForKey:@"status"] isEqualToString:@"待付款"]) {
////        UIButton *goToPay = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 90, status.frame.origin.y, 90, 32)];
////        goToPay.tag = [[_orders[indexPath.row] objectForKey:@"id"] integerValue];
////        goToPay.layer.borderColor = [UIColor orangeColor].CGColor;
////        goToPay.layer.borderWidth = 1;
////        goToPay.layer.cornerRadius = 6;
////        goToPay.layer.masksToBounds = YES;
////        [goToPay setTitle:@"立即支付" forState:UIControlStateNormal];
////        [goToPay setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
////        [goToPay addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
////        
////        [cell.contentView addSubview:goToPay];
////    }
////
////    if (![[_orders[indexPath.row] objectForKey:@"express_url"] isEqualToString:@""]) {
////        UIButton *expressButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 90, status.frame.origin.y, 90, 32)];
////        expressButton.tag = indexPath.row;
////        expressButton.layer.borderColor = [UIColor orangeColor].CGColor;
////        expressButton.layer.borderWidth = 1;
////        expressButton.layer.cornerRadius = 6;
////        expressButton.layer.masksToBounds = YES;
////        [expressButton setTitle:@"查看物流" forState:UIControlStateNormal];
////        [expressButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
////        [expressButton addTarget:self action:@selector(goToExpress:) forControlEvents:UIControlEventTouchUpInside];
////        
////        [cell.contentView addSubview:expressButton];
////    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    
    NSDictionary *order = _orders[indexPath.row];
    
    OrderDetailViewController *orderDetail = [[OrderDetailViewController alloc] init];
    
    if ([order[@"status"] isEqualToString:@"待付款"]) {
        orderDetail.orderID = order[@"id"];
        orderDetail.isReadyToPay = YES;
    } else {
        orderDetail.orderID = order[@"no"];
        orderDetail.isReadyToPay = NO;
    }
    
    orderDetail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:orderDetail animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [alert show];

}

#pragma mark - UmpayDelegate -

- (void)onPayResult:(NSString *)orderId resultCode:(NSString *)resultCode resultMessage:(NSString *)resultMessage
{
    if ([resultCode isEqualToString:kUmpaykSuccessCode]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:resultMessage delay:2.0];
        
    } else if ([resultCode isEqualToString:kUmpayFailureCode]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:resultMessage delay:2.0];
        
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
    }
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    _tableView.allowsSelection = YES;
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"订单支付成功"]) {
        [self getDataSource:_statusString];
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    
    YunLog(@"point.y = %f,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4 = %f",point.y,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
    
    if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
        && ( scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
        [self footerRereshing];
    }
}

@end
