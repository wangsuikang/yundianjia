//
//  PayCenterForUserViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-12-06.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "PayCenterForUserViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"
#import "OrderManager.h"

// Views
#import "UIButtonForBarButton.h"

// Controllers
#import "AddressListViewController.h"
#import "AddressNewViewController.h"
#import "InvoiceListViewController.h"
#import "ProvinceViewController.h"
#import "CouponUseViewController.h"
#import "OrderListViewController.h"
#import "ChooseBankViewController.h"
#import "PopGestureRecognizerController.h"

// Protocols
#import "WXPayDelegate.h"

// Categories
#import "NSObject+NullToString.h"

#define kImageViewHeightWidth 90

// Libraries
//#import "Umpay.h"

@interface PayCenterForUserViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIWebViewDelegate, /*UmpayDelegate,*/ WXPayDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *goods;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *detailField;
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) UILabel *discountLabel;

@property (nonatomic, strong) NSArray *discounts;
@property (nonatomic, strong) NSDictionary *priceParams;
@property (nonatomic, strong) NSDictionary *priceResponse;

@property (nonatomic, strong) AFHTTPRequestOperation *op;
@property (nonatomic, strong) AFHTTPRequestOperation *orderOp;

@property (nonatomic, assign, getter=isAlipay) BOOL alipay;
@property (nonatomic, assign) BOOL commitButtonEnabled;
@property (nonatomic, assign) BOOL paying;
@property (nonatomic, assign) NSInteger shopViewCount;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIButton *commitOrder;
@property (nonatomic, strong) AFHTTPRequestOperation *payOp;

@property (nonatomic, strong) NSArray *shops;

@end

@implementation PayCenterForUserViewController

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
        naviTitle.text = @"结算中心";
        
        self.navigationItem.titleView = naviTitle;
        
        //        [[OrderManager defaultManager] addInfo:@"3" forKey:@"pay"];
        [[OrderManager defaultManager] addInfo:[NSMutableArray array] forKey:kInputCoupons];
        [[OrderManager defaultManager] addInfo:[NSMutableArray array] forKey:kSelectedCoupons];
        
        //        _paying = NO;
        _alipay = NO;
        _commitButtonEnabled = YES;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
//    NSData *paySelectProductsData = [NSKeyedArchiver archivedDataWithRootObject:nil];
    
//    NSData *paySelectProductsData = [NSKeyedArchiver archivedDataWithRootObject:@""];
//    [[NSUserDefaults standardUserDefaults] setObject:paySelectProductsData forKey:@"paySelectProducts"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
////    NSData *paySelectShopsData = [NSKeyedArchiver archivedDataWithRootObject:nil];
    
//    NSData *paySelectShopsData = [NSKeyedArchiver archivedDataWithRootObject:@""];
//    [[NSUserDefaults standardUserDefaults] setObject:paySelectShopsData forKey:@"paySelectShops"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    YunLog(@"_username = %@", [[OrderManager defaultManager] infoForKey:@"username"]);
    YunLog(@"_province = %@", [[OrderManager defaultManager] infoForKey:@"province"]);
    YunLog(@"_city     = %@", [[OrderManager defaultManager] infoForKey:@"city"]);
    YunLog(@"_area     = %@", [[OrderManager defaultManager] infoForKey:@"area"]);
    YunLog(@"_detail   = %@", [[OrderManager defaultManager] infoForKey:@"detail"]);
    YunLog(@"_phone    = %@", [[OrderManager defaultManager] infoForKey:@"phone"]);
    YunLog(@"_price    = %@", [[OrderManager defaultManager] infoForKey:@"price"]);
    YunLog(@"user_address_id    = %@", [[OrderManager defaultManager] infoForKey:@"user_address_id"]);
    
    NSString *isPay = [[NSUserDefaults standardUserDefaults] objectForKey:@"isPay"];
    if ([isPay isEqualToString:@"yes"]) {
        [self getUserAddressId];
//        [self getUserAddressInfo];
    }
    
        [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [TalkingData trackPageEnd:@"离开结算中心页面"];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserAddressInfo) name:kAddressUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewForNotification:) name:kNotificationDismissModalController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewWithPaySucceed) name:kNotificationDismissModalControllerWithPaySucceed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnViewWithClose) name:kNotificationDismissModalControllerWithClose object:nil];
    
    self.view.backgroundColor = kBackgroundColor;
    
    //    _goods = [[CartManager defaultCart] allSelectedProducts];
    
    //    UIButtonForBarButton *close = [[UIButtonForBarButton alloc] initWithTitle:@"关闭" wordLength:@"2"];
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [close setBackgroundColor:kClearColor];
    close.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    close.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [close addTarget:self action:@selector(returnView:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeItem  = [[UIBarButtonItem alloc] initWithCustomView:close];
    
    self.navigationItem.leftBarButtonItem = closeItem;
    
    if (kDeviceOSVersion < 7.0) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)
                                                  style:UITableViewStylePlain];
    } else {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                                  style:UITableViewStyleGrouped];
    }
    
    _tableView.delegate      = self;
    _tableView.dataSource    = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    _tableView.bounces = NO;
    
    [self.view addSubview:_tableView];
    
    _tableView.scrollEnabled = NO;
    
    [self getUserAddressInfo];
}

- (void)getUserAddressInfo
{
    AppDelegate *appDelegate = kAppDelegate;
    
    //创建操作队列
    NSOperationQueue *operationQueue=[[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount = 1;//设置最大线程数
    
    NSBlockOperation *blockOperation=[NSBlockOperation blockOperationWithBlock:^{ // 创建首先执行的队列
        NSLock *lock = [[NSLock alloc] init];
        [lock lock];
        
        NSDictionary *addressParams =  @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                         @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
        NSString *listURL = [Tool buildRequestURLHost:kRequestHost
                                           APIVersion:kAPIVersion1
                                           requestURL:kAddressQueryURL
                                               params:addressParams];
        
        YunLog(@"address listURL = %@", listURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager GET:listURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"address list responseObject = %@", responseObject);
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            
            if ([code isEqualToString:kSuccessCode]) {
                _hud.hidden = YES;
                appDelegate.user.addresses = [[responseObject objectForKey:@"data"] objectForKey:@"addresses"];
                
                for (int i = 0; i < appDelegate.user.addresses.count; i++) {
                    NSDictionary *address = [appDelegate.user.addresses objectAtIndex:i];
                    
                    if ([[address objectForKey:@"is_default"] integerValue] == 1) {
                        OrderManager *manager = [OrderManager defaultManager];
                        
                        [manager addInfo:kNullToString([address objectForKey:@"address_province"]) forKey:@"province"];
                        [manager addInfo:kNullToString([address objectForKey:@"address_city"]) forKey:@"city"];
                        [manager addInfo:kNullToString([address objectForKey:@"address_area"]) forKey:@"area"];
                        [manager addInfo:kNullToString([address objectForKey:@"address_detail"]) forKey:@"detail"];
                        [manager addInfo:kNullToString([address objectForKey:@"contact_name"]) forKey:@"username"];
                        [manager addInfo:kNullToString([address objectForKey:@"contact_phone"]) forKey:@"phone"];
                        [manager addInfo:kNullToString([address objectForKey:@"id"]) forKey:@"user_address_id"];
                        
                        break;
                    }
                }
                
                [self getUserAddressId];
                
                //                [_tableView reloadData];
            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                [Tool resetUser];
                
                [self returnView:PayresultNone];
                
                return;
            } else {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
                
                [self returnView:PayresultNone];
                
                return;
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"address list error = %@", error);
            
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            
            [self returnView:PayresultNone];
            
            return;
        }];
        NSDictionary *invoiceParams = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                        @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
        
        NSString *invoiceURL = [Tool buildRequestURLHost:kRequestHost
                                              APIVersion:kAPIVersion1
                                              requestURL:kInvoiceQueryURL
                                                  params:invoiceParams];
        
        YunLog(@"invoice listURL = %@", invoiceURL);
        
        [manager GET:invoiceURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            _tableView.scrollEnabled = YES;
            
            YunLog(@"invoice list responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            
            if ([code isEqualToString:kSuccessCode]) {
                _hud.hidden = YES;
                if ([[responseObject objectForKey:@"data"] objectForKey:@"invoices"]) {
                    [[OrderManager defaultManager] addInfo:kNullToString([[[[responseObject objectForKey:@"data"] objectForKey:@"invoices"] objectAtIndex:0] objectForKey:@"content"])
                                                    forKey:@"invoice"];
                }
                
                [_tableView reloadData];
            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                [Tool resetUser];
                
                [self returnView:PayresultNone];
                
                return;
            } else {
                [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
                
                [self returnView:PayresultNone];
                
                return;
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            _tableView.scrollEnabled = YES;
            
            YunLog(@"invoice list error = %@", error);
            
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            
            [self returnView:PayresultNone];
            
            return;
        }];
        [lock unlock];
    }];
    
    [operationQueue addOperation:blockOperation];
}


- (void)getUserAddressId
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    if (_nowToBuy == YES)
    {
        YunLog(@" _order = %@", _order);
        NSDictionary *variant = @{@"id"         :   kNullToString([_order objectForKey:@"sku_id"]),
                                  @"number"     :   kNullToString(_buyCount),
                                  @"sid"        :   kNullToString([_shopNowPayDict objectForKey:@"shop_code"])};
        
        [products addObject:variant];
    }
    else
    {
        for (int i = 0; i < _paySelectShops.count; i++) {
            NSDictionary *shopDict = _paySelectShops[i];
            NSArray *variantsArray = shopDict[@"product_variants"];
            
            for (int j = 0; j < variantsArray.count; j++) {
                for (int z = 0; z < _allSelectProducts.count; z++) {
                    if ([[variantsArray[j] objectForKey:@"sku_id"] integerValue] == [[_allSelectProducts[z] objectForKey:@"sku_id"] integerValue]) {
                        NSDictionary *variant = @{@"id"         :   kNullToString([_allSelectProducts[z] objectForKey:@"sku_id"]),
                                                  @"number"     :   kNullToString([_allSelectProducts[z] objectForKey:@"quantity"]),
                                                  @"sid"        :   [kNullToString([_allSelectProducts[z] objectForKey:@"distributor_code"]) isEqualToString:@""] ? kNullToString([_paySelectShops[i] objectForKey:@"code"]) : kNullToString([_allSelectProducts[z] objectForKey:@"distributor_code"])};
                        
                        [products addObject:variant];
                    }
                }
            }
        }

    }
    
    @try {
        NSString *user_address_id = [[OrderManager defaultManager] infoForKey:@"user_address_id"];

        _priceParams = @{@"product_variants"              :   products,
                         @"user_address_id"               :   kNullToString(user_address_id),
                         @"coupon_codes"                  :   @"",
                         @"coupon_digit_codes"            :   @"",
                         @"promotion_activity_codes"      :   @"",
                         @"user_phone"                    :   kNullToString(appDelegate.user.username)};
        
    }
    @catch (NSException *exception) {
        _priceParams = @{};
    }
    @finally {
        
    }
    
    YunLog(@"_priceParams = %@", _priceParams);
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"promotion_json"          :   _priceParams};
    
//    NSString *priceURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kPromotionsCalculateURL params:params];
    NSString *priceURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCalculateURL params:nil];
    
    YunLog(@"order price_detail url = %@", priceURL);
    YunLog(@"order price_detail params = %@", params);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:priceURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        YunLog(@"price = %@", responseObject);
        
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            
            _shops = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"shops"]);
            
            if (![[responseObject objectForKey:@"data"] objectForKey:@"amount"]) {
                [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                  
                [self returnView:PayresultNone];
                
                return;
            }
            
            OrderManager *manager = [OrderManager defaultManager];
            
            NSArray *payments = kNullToArray(responseObject[@"data"][@"payment_categories"]);
            
            if (payments.count > 0) {
                [manager addInfo:payments[0][@"value"] forKey:@"pay"];
            }
            
            [manager addInfo:payments forKey:@"paymentCategories"];
            
            [manager addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"amount"] forKey:@"price"];
            
            NSString *promotion_discount = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"promotion_discount"]);
            
            [manager addInfo:promotion_discount forKey:@"promotion_discount"];
            
            [manager addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"promotion_amount"]
                      forKey:@"promotion_amount"];
            [manager addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"freight_amount"]
                      forKey:@"freight_amount"];
            
            
            if ([promotion_discount floatValue] > 0.0) {
                [_hud addSuccessString:[NSString stringWithFormat:@"已为您优惠%@元", promotion_discount] delay:2.0];
            }
            
            [_tableView reloadData];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self returnView:PayresultNone];
            
            return;
        } else {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
            
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"price error = %@", error);
        
        [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
        
        [self returnView:PayresultNone];
        
        return;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Functions -

/**
 接收通知 消失模态窗口
 */
- (void)returnViewWithPaySucceed
{
    [self returnView:PayResultSuccess];
}

/**
 接收通知 消失模态窗口
 */
- (void)returnViewWithClose
{
    [self returnView:PayresultNone];
}

/**
 接收通知 消失模态窗口
 
 @param notification 通知对象
 */
- (void)returnViewForNotification:(NSNotification *)notification
{
    if ([_op isExecuting]) {
        [_op cancel];
    }
    
    if ([_orderOp isExecuting]) {
        [_orderOp cancel];
    }
    
    [[OrderManager defaultManager] clearInfo];
    
    if (_hud) [_hud hide:NO];
    
    AppDelegate *appDelegate = kAppDelegate;
    appDelegate.province = @"";
    appDelegate.city = @"";
    appDelegate.area = @"";
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        if (!_commitButtonEnabled) {
            OrderListViewController *order = [[OrderListViewController alloc] init];
            order.hidesBottomBarWhenPushed = YES;
            order.orderType = WaitingForPay;
            order.selectedOrderTypeIndex = 1;
            
            PopGestureRecognizerController *cartGestrue = appDelegate.indexTab.childViewControllers[1];
            appDelegate.indexTab.selectedIndex = 1;
            
            [cartGestrue pushViewController:order animated:YES];
        }
    }];
}

- (void)returnView:(PayResultType)payResult
{
    if ([_op isExecuting]) {
        [_op cancel];
    }
    
    if ([_orderOp isExecuting]) {
        [_orderOp cancel];
    }
    
    [[OrderManager defaultManager] clearInfo];
    
    if (_hud) [_hud hide:NO];
    
    AppDelegate *appDelegate = kAppDelegate;
    appDelegate.province = @"";
    appDelegate.city = @"";
    appDelegate.area = @"";
    
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isPay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        //        appDelegate.window.rootViewController = appDelegate.indexTab;
        //
        //        [appDelegate.window makeKeyAndVisible];
        
        if (_alipay) {
            if (!_commitButtonEnabled) {
                OrderListViewController *order = [[OrderListViewController alloc] init];
                order.hidesBottomBarWhenPushed = YES;
                order.orderType = All;
                order.selectedOrderTypeIndex = 0;
                
                PopGestureRecognizerController *cartGestrue = appDelegate.indexTab.childViewControllers[1];
                appDelegate.indexTab.selectedIndex = 1;
                
                [cartGestrue pushViewController:order animated:YES];
            }
        } else {
            switch (payResult) {
                case PayResultSuccess:
                {
                    //                    if (!_commitButtonEnabled) {
                    OrderListViewController *order = [[OrderListViewController alloc] init];
                    order.hidesBottomBarWhenPushed = YES;
                    order.orderType = AlreadyPay;
                    order.selectedOrderTypeIndex = 2;
                    
                    PopGestureRecognizerController *cartGestrue = appDelegate.indexTab.childViewControllers[1];
                    appDelegate.indexTab.selectedIndex = 1;
                    
                    [cartGestrue pushViewController:order animated:YES];
                    //                    }
                    
                    break;
                }
                    
                case PayResultFailure: case PayResultCancel:
                {
                    if (!_commitButtonEnabled) {
                        OrderListViewController *order = [[OrderListViewController alloc] init];
                        order.hidesBottomBarWhenPushed = YES;
                        order.orderType = WaitingForPay;
                        order.selectedOrderTypeIndex = 1;
                        
                        PopGestureRecognizerController *cartGestrue = appDelegate.indexTab.childViewControllers[1];
                        appDelegate.indexTab.selectedIndex = 1;
                        
                        [cartGestrue pushViewController:order animated:YES];
                    }
                    
                    break;
                }
                    
                case PayresultNone:
                {
                    break;
                }
                    
                default:
                {
                    if (!_commitButtonEnabled) {
                        OrderListViewController *order = [[OrderListViewController alloc] init];
                        order.hidesBottomBarWhenPushed = YES;
                        order.orderType = WaitingForPay;
                        order.selectedOrderTypeIndex = 1;
                        
                        PopGestureRecognizerController *cartGestrue = appDelegate.indexTab.childViewControllers[1];
                        appDelegate.indexTab.selectedIndex = 1;
                        
                        [cartGestrue pushViewController:order animated:YES];
                    }
                    
                    break;
                }
            }
        }
    }];
    
    //    [self.parentViewController dismissViewControllerAnimated:NO completion:^{
    //        appDelegate.window.rootViewController = (UIViewController *)appDelegate.indexTab;
    //
    //        [appDelegate.window makeKeyAndVisible];
    //    }];
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textWithInput:(UITextField *)textField
{
    switch (textField.tag) {
        case InvoiceTextField:
        {
            [[OrderManager defaultManager] addInfo:textField.text forKey:@"invoice"];
            
            break;
        }
            
        case NoteTextField:
            [[OrderManager defaultManager] addInfo:textField.text forKey:@"note"];
            
            break;
            
        default:
            break;
    }
}

- (void)keyboardWillShowForPayNumberPad:(NSNotification *)noti
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // 创建“Done”按钮
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        doneButton.adjustsImageWhenHighlighted = NO;
        doneButton.tag = 100;
        
        if (kDeviceOSVersion >= 7.0) {
            doneButton.frame = CGRectMake(-2, 163, 106, 53);
            doneButton.backgroundColor = COLOR(187, 190, 195, 1);
            [doneButton setTitle:@"完成" forState:UIControlStateNormal];
            [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {
            doneButton.frame = CGRectMake(0, 163, 106, 53);
            [doneButton setImage:[UIImage imageNamed:@"doneup"] forState:UIControlStateNormal];
            [doneButton setImage:[UIImage imageNamed:@"donedown"] forState:UIControlStateHighlighted];
        }
        
        [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 找到键盘view
        UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        
        UIView *keyboard;
        
        for (int i = 0; i < [tempWindow.subviews count]; i++){
            keyboard = [tempWindow.subviews objectAtIndex:i];
            
            // 找到键盘view并加入“Done”按钮
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES || ([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)) {
                [keyboard addSubview:doneButton];
                
                break;
            }
        }
    });
}

- (void)doneButton:(UIButton *)sender
{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)commitOrderClick:(UIButton *)sender
{
    NSString *price = kNullToString([[OrderManager defaultManager] infoForKey:@"price"]);
    
    YunLog(@"_price = %@", price);
    YunLog(@"commit order invoice = %@", kNullToString([[OrderManager defaultManager] infoForKey:@"invoice"]));
    
    NSString *username = kNullToString([[OrderManager defaultManager] infoForKey:@"username"]);
    
    if ([username isEqualToString:@""]) {
        [_hud addErrorString:@"请选择地址" delay:2.0];
        
        return;
    }
    
    if ([kNullToString([[OrderManager defaultManager] infoForKey:@"province"]) isEqualToString:@""]) {
        [_hud addErrorString:@"请选择省市区" delay:2.0];
        
        return;
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    YunLog(@"appDelegate.user.phone = %@", kNullToString(appDelegate.user.phone));
    YunLog(@"appDelegate.terminalSessionKey = %@", kNullToString(appDelegate.terminalSessionKey));
    
    NSString *detail = kNullToString([[OrderManager defaultManager] infoForKey:@"detail"]);
    
    if ([detail isEqualToString:@""]) {
        [_hud addErrorString:@"请输入详细地址" delay:2.0];
        
        return;
    }
    
    NSString *phone = kNullToString([[OrderManager defaultManager] infoForKey:@"phone"]);
    
    NSString *regexString = @"(^1(3[5-9]|47|5[012789]|8[23478])\\d{8}$|134[0-8]\\d{7}$)|(^18[019]\\d{8}$|1349\\d{7}$)|(^1(3[0-2]|45|5[56]|8[56])\\d{8}$)|(^1[35]3\\d{8}$)";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    
    NSTextCheckingResult *result = [regex firstMatchInString:phone options:0 range:NSMakeRange(0, [phone length])];
    if (!result) {
        [_hud addErrorString:@"请输入正确手机号" delay:2.0];
        
        return;
    }
    
    sender.enabled = NO;
    _commitButtonEnabled = NO;
    
    _hud.labelText = @"提交...";
    
//    NSString *commitURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kOrderCommitURL params:nil];
    NSString *commitURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kOrderCommitURLNew params:nil];
    
    YunLog(@"commitURL = %@", commitURL);
    
//    NSMutableArray *items = [[NSMutableArray alloc] init];
//    if (_nowToBuy == YES)
//    {
//        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
//        [temp setObject:kNullToString([_order safeObjectForKey:@"sku_id"]) forKey:@"sku_id"];
//        // TODO  这里需要等待详情页面OK之后做处理
//        [temp setObject:kNullToString(_buyCount) forKey:@"count"];
//        [temp setObject:kNullToString([_shopNowPayDict safeObjectForKey:@"shop_code"]) forKey:@"sid"];
//        
//        [items addObject:temp];
//        
//    }
//    else
//    {
//        for (NSDictionary *dict in _allSelectProducts) {
//            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
//            [temp setObject:kNullToString([dict safeObjectForKey:@"sku_id"]) forKey:@"sku_id"];
//            [temp setObject:kNullToString([dict safeObjectForKey:@"quantity"]) forKey:@"count"];
//            // 从传过来的店铺信息里面获取店铺的code
//            for (NSDictionary *shopDict in _paySelectShops) {
//                NSArray *productVatiantsArray = shopDict[@"product_variants"];
//                for (NSDictionary *productVariant in productVatiantsArray) {
//                    if ([[productVariant safeObjectForKey:@"sku_id"] isEqualToString:[dict safeObjectForKey:@"sku_id"]]) {
//                        [temp setObject:kNullToString([shopDict safeObjectForKey:@"code"]) forKey:@"sid"];
//                        YunLog(@"来来来来来来");
//                    }
//                }
//            }
//            
//            [items addObject:temp];
//        }
//        
//    }
//    
//    YunLog(@"commit items = %@", items);
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    
    if (_nowToBuy == YES)
    {
        NSDictionary *variant = @{@"id"         :   [_order objectForKey:@"sku_id"],
                                  @"number"     :   kNullToString(_buyCount),
                                  @"sid"        :   kNullToString([_shopNowPayDict objectForKey:@"shop_code"])};
        
        [products addObject:variant];
    }
    else
    {
        for (int i = 0; i < _paySelectShops.count; i++) {
            
        NSDictionary *shopDict = _paySelectShops[i];
        
        NSArray *variantsArray = shopDict[@"product_variants"];
        
            for (int j = 0; j < variantsArray.count; j++) {
                
                for (int z = 0; z < _allSelectProducts.count; z++) {
                    
                    if ([[variantsArray[j] objectForKey:@"sku_id"] integerValue] == [[_allSelectProducts[z] objectForKey:@"sku_id"] integerValue]) {
                        
                        NSDictionary *variant = @{@"id"         :   kNullToString([_allSelectProducts[z] objectForKey:@"sku_id"]),
                                                  @"number"     :   kNullToString([[_allSelectProducts[z] objectForKey:@"quantity"] stringValue]),
                                                  @"sid"        :   [kNullToString([_allSelectProducts[z] objectForKey:@"distributor_code"]) isEqualToString:@""] ? kNullToString([_paySelectShops[i] objectForKey:@"code"]) : kNullToString([_allSelectProducts[z] objectForKey:@"distributor_code"])};
                        
                        [products addObject:variant];
                    }
                 }
            }
        }
    }
    
    NSString *discount_codes = @"";
    
    for (NSString *code in [[OrderManager defaultManager] infoForKey:@"discounts"]) {
        discount_codes = [discount_codes stringByAppendingFormat:@"%@,", code];
    }
    
    YunLog(@"discount_codes = %@", discount_codes);
    
    NSDictionary *params;
    
    @try {
//        params = @{@"terminal_session_key"                      :   kNullToString(appDelegate.terminalSessionKey),
//                   @"user_session_key"                          :   kNullToString(appDelegate.user.userSessionKey),
//                   @"json_data":
//                       @{@"data":
//                             @{@"order_item_count"            :   [NSString stringWithFormat:@"%lu", _nowToBuy?1:(unsigned long)_allSelectProducts.count],
//                               @"total_price"                 :   price,
//                               @"discount_codes"              :   discount_codes,
//                               @"coupon_digit_codes"          :   kNullToArray([[OrderManager defaultManager] infoForKey:@"coupon_digit_codes"]),
//                               //                                 @"shop_id"                     :   @"",
//                               @"payment_type"                :   kNullToString([[OrderManager defaultManager] infoForKey:@"pay"]),
//                               @"contact_phone"               :   kNullToString(appDelegate.user.phone),
//                               @"consignee":
//                                   @{@"name"                :   kNullToString([[OrderManager defaultManager] infoForKey:@"username"]),
//                                     @"phone"               :   kNullToString([[OrderManager defaultManager] infoForKey:@"phone"]),
//                                     @"address":
//                                         @{@"province"    :   kNullToString([[OrderManager defaultManager] infoForKey:@"province"]),
//                                           @"city"        :   kNullToString([[OrderManager defaultManager] infoForKey:@"city"]),
//                                           @"area"        :   kNullToString([[OrderManager defaultManager] infoForKey:@"area"]),
//                                           @"detail"      :   kNullToString([[OrderManager defaultManager] infoForKey:@"detail"])},
//                                     @"post"                :   @""},
//                               @"note"                      :   kNullToString([[OrderManager defaultManager] infoForKey:@"note"]),
//                               @"user_address_id"           :   kNullToString([[OrderManager defaultManager] infoForKey:@"user_address_id"]),
//                               @"invoice"                   :   kNullToString([[OrderManager defaultManager] infoForKey:@"invoice"]),
//                               @"items"                     :   items}}};
        
        params = @{@"terminal_session_key"   :   kNullToString(appDelegate.terminalSessionKey),
                   @"user_session_key"       :   kNullToString(appDelegate.user.userSessionKey),
                   @"json_data"              :   @{@"product_variants"       :    products,
                                                   @"coupon_codes"           :    @"",
                                                   @"payment_category"       :    [[OrderManager defaultManager] infoForKey:@"pay"],
                                                   @"note"                   :    kNullToString([[OrderManager defaultManager] infoForKey:@"note"]),
                                                   @"invoice"                :    kNullToString([[OrderManager defaultManager] infoForKey:@"invoice"]),
                                                   @"category"               :    @"1",
                                                   @"usefor"                 :    @"1",
                                                   @"user_address_id"        :   kNullToString([[OrderManager defaultManager] infoForKey:@"user_address_id"]),
                                                   @"promotion_activity_codes": @"",
                                                   @"user_phone": @"",
                                                   @"split_number": @"",
                                                   @"logistics": @"",
                                                   @"points"   : @[]}
                   };
    }
    @catch (NSException *exception) {
        YunLog(@"build order params exception = %@", exception);
        
        params = @{};
    }
    @finally {
        
    };
    
     _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    YunLog(@"commit params = %@", params);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:commitURL
                                                                                parameters:params
                                                                                     error:nil];
    YunLog(@"request = %@", request);
    
    _orderOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _orderOp.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak typeof(self) weakSelf = self;
    
    YunLog(@"Commit Order Start");
    
    [_orderOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"Commit Order Done");
        
        YunLog(@"commit order responseObject = %@", responseObject);
        
        YunLog(@"commit order message = %@", kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [weakSelf.hud addSuccessString:@"提交订单成功" delay:2.0];
            
            NSString *orderID = [[[responseObject objectForKey:@"data"] objectForKey:@"order"] objectForKey:@"order_id"];
            
            // 提交订单，将购物车清空
//            if (_nowToBuy == NO)
//            {
//                [[CartManager defaultCart] deleteAllSelectProducts];
//                
//                UIViewController *cartVC = [weakSelf.tabBarController.viewControllers objectAtIndex:1];
//                cartVC.tabBarItem.badgeValue = nil;
//            }
            
//            appDelegate.province = @"";
//            appDelegate.city = @"";
//            appDelegate.area = @"";
//            
//            appDelegate.paying = YES;
//            
//            NSString *payment = [[OrderManager defaultManager] infoForKey:@"pay"];
//            
//            if ([payment isEqualToString:@"3"]) {
//                NSString *tradeNO = kNullToString([[[responseObject objectForKey:@"data"] objectForKey:@"order"] objectForKey:@"upay_trade_no"]);
//                ChooseBankViewController *chooseBankVC = [[ChooseBankViewController alloc] init];
//                
//                chooseBankVC.tradeNO = tradeNO;
//                chooseBankVC.price = [NSString stringWithFormat:@"￥%@", kNullToString([[OrderManager defaultManager] infoForKey:@"promotion_amount"])];
//                //                chooseBankVC.index = [weakSelf.navigationController.viewControllers indexOfObject:weakSelf];
//                
//                [weakSelf.navigationController pushViewController:chooseBankVC animated:YES];
//                
//                //                _paying = YES;
//            }
//            
//            else if ([payment isEqualToString:@"4"]) {
//                AppDelegate *delegate = kAppDelegate;
//                delegate.shareType = ShareToWeiXin;
//                delegate.wxPayDelegate = weakSelf;
//                
//                NSDictionary *response = (NSDictionary *)responseObject[@"data"][@"order"][@"wxpay"];
//                
//                YunLog(@"weixin pay response = %@", response);
//                
//                if ([response isKindOfClass:[NSString class]]) {
//                    [weakSelf.hud addErrorString:@"请求微信支付失败,请稍后再试" delay:2.0];
//                    
//                    OrderListViewController *order = [[OrderListViewController alloc] init];
//                    order.orderType = WaitingForPay;
//                    
//                    [weakSelf.navigationController pushViewController:order animated:YES];
//                    
//                    weakSelf.paying = YES;
//                } else {
//                    PayReq *req = [[PayReq alloc] init];
//                    
//                    req.openID      = response[@"appid"];
//                    req.partnerId   = response[@"partner_id"];
//                    req.prepayId    = response[@"prepayid"];
//                    req.nonceStr    = response[@"noncestr"];
//                    req.timeStamp   = (UInt32)[response[@"timestamp"] intValue];
//                    req.package     = response[@"package"];
//                    req.sign        = response[@"sign"];
//                    
//                    [WXApi sendReq:req];
//                }
//            }
//            
//            else {
//                weakSelf.alipay = YES;
//                
//                [weakSelf loadPayView:[[[responseObject objectForKey:@"data"] objectForKey:@"order"] objectForKey:@"page_pay_url"]];
//            }
            [weakSelf goToPay:orderID];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [weakSelf returnView:PayresultNone];
        } else  {
            NSString *message = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]);
            
            if ([message isEqualToString:@""]) {
                [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
            } else {
                [weakSelf.hud addErrorString:message delay:2.0];
            }
            
            sender.enabled = YES;
            _commitButtonEnabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if ([weakSelf.orderOp isCancelled]) {
//            [weakSelf.hud addErrorString:@"用户取消支付" delay:2.0];
//        } else {
            [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
//        }
        
        sender.enabled = YES;
        _commitButtonEnabled = YES;
        
        YunLog(@"commit order error = %@", error);
    }];
    
    [_orderOp start];
}

- (void)goToPay:(NSString *)orderID
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"oid"                 :   orderID,
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
            
            // 提交订单，将购物车清空
            if (_nowToBuy == NO)
            {
                [[CartManager defaultCart] deleteAllSelectProducts];

                UIViewController *cartVC = [weakSelf.tabBarController.viewControllers objectAtIndex:1];
                cartVC.tabBarItem.badgeValue = nil;
            }

            appDelegate.province = @"";
            appDelegate.city = @"";
            appDelegate.area = @"";

            appDelegate.paying = YES;

            NSString *payment = [[OrderManager defaultManager] infoForKey:@"pay"];
            if ([payment isEqualToString:@"3"]) {
                NSString *tradeNO = kNullToString([[[responseObject objectForKey:@"data"] objectForKey:@"page_pay"] objectForKey:@"upay_trade_no"]);
                ChooseBankViewController *chooseBankVC = [[ChooseBankViewController alloc] init];

                chooseBankVC.tradeNO = tradeNO;
                chooseBankVC.price = [NSString stringWithFormat:@"￥%@", kNullToString([[OrderManager defaultManager] infoForKey:@"promotion_amount"])];

                [weakSelf.navigationController pushViewController:chooseBankVC animated:YES];

            } else if ([payment isEqualToString:@"4"]) {
                AppDelegate *delegate = kAppDelegate;
                delegate.shareType = ShareToWeiXin;
                delegate.wxPayDelegate = weakSelf;

                NSDictionary *response = (NSDictionary *)responseObject[@"data"][@"page_pay"][@"wxpay"];

                YunLog(@"weixin pay response = %@", response);

                if ([response isKindOfClass:[NSString class]]) {
                    [weakSelf.hud addErrorString:@"请求微信支付失败,请稍后再试" delay:2.0];

                    OrderListViewController *order = [[OrderListViewController alloc] init];
                    order.orderType = WaitingForPay;

                    [weakSelf.navigationController pushViewController:order animated:YES];

                    weakSelf.paying = YES;
                } else {
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
            } else {
                weakSelf.alipay = YES;
                
                [weakSelf loadPayView:[[[responseObject objectForKey:@"data"] objectForKey:@"page_pay"] objectForKey:@"pay_url"]];
            }
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [weakSelf.hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"]
                                   delay:2.0];
            
            weakSelf.commitOrder.enabled = YES;
            _commitButtonEnabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([weakSelf.payOp isCancelled]) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [weakSelf.hud addErrorString:@"用户取消支付" delay:2.0];
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [weakSelf.hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
        }
        
        weakSelf.commitOrder.enabled = YES;
        _commitButtonEnabled = YES;
        
        YunLog(@"commit order error = %@", error);
    }];
    
    [_payOp start];
}

- (void)loadPayView:(NSString *)url
{
    YunLog(@"alipay url = %@",url);
    
    UILabel *title = (UILabel *)self.navigationItem.titleView;
    title.textColor = [UIColor orangeColor];
    title.text = @"订单支付";
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"请求支付...";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - 64)];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [webView loadRequest:request];
}

- (void)delCoupon:(UIButton *)sender
{
    YunLog(@"delete coupon sender.tag = %lu", (unsigned long)sender.tag);
    
    NSString *code = [[[OrderManager defaultManager] infoForKey:@"discounts"] objectAtIndex:sender.tag];
    
    YunLog(@"code = %@", code);
    
    NSMutableArray *selectedCoupons = [NSMutableArray arrayWithArray:[[OrderManager defaultManager] infoForKey:kSelectedCoupons]];
    
    YunLog(@"selectedCoupons = %@", selectedCoupons);
    
    BOOL already = NO;
    
    for (NSString *selectedCode in selectedCoupons) {
        if ([code isEqualToString:selectedCode]) {
            [selectedCoupons removeObject:selectedCode];
            
            [[OrderManager defaultManager] addInfo:selectedCoupons forKey:kSelectedCoupons];
            
            already = YES;
            
            break;
        }
    }
    
    YunLog(@"selectedCoupons = %@", selectedCoupons);
    
    if (!already) {
        NSMutableArray *inputCoupons = [NSMutableArray arrayWithArray:[[OrderManager defaultManager] infoForKey:kInputCoupons]];
        
        YunLog(@"inputCoupons = %@", inputCoupons);
        
        for (NSString *inputCode in inputCoupons) {
            if ([code isEqualToString:inputCode]) {
                [inputCoupons removeObject:inputCode];
                
                [[OrderManager defaultManager] addInfo:inputCoupons forKey:kInputCoupons];
                
                break;
            }
        }
        
        YunLog(@"inputCoupons = %@", inputCoupons);
    }
    
    NSArray *discounts = [[[OrderManager defaultManager] infoForKey:kInputCoupons] arrayByAddingObjectsFromArray:selectedCoupons];
    
    YunLog(@"discounts = %@", discounts);
    
    [[OrderManager defaultManager] addInfo:discounts forKey:@"discounts"];
    
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag + 1 inSection:4]]
                      withRowAnimation:UITableViewRowAnimationLeft];
    
    [self calculatePromotion];
}

- (void)calculatePromotion
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"计算优惠...";
    
    AppDelegate *appDelegate = kAppDelegate;
    NSString *user_address_id = [[OrderManager defaultManager] infoForKey:@"user_address_id"];
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *priceURL = [Tool buildRequestURLHost:kRequestHost
                                        APIVersion:kAPIVersion1
                                        requestURL:kPromotionsCalculateURL
                                            params:params];
    
    YunLog(@"order price url = %@", priceURL);
    
    NSArray *goods = [[CartManager defaultCart] allProducts];
    YunLog(@"goods = %@", goods);
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    if (_nowToBuy == YES)
    {
        NSDictionary *variants = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [_order objectForKey:CartManagerSkuIDKey], @"id",
                                  [_order objectForKey:CartManagerCountKey], @"number",
                                  [_order objectForKey:CartManagerShopCodeKey], @"sid", nil];
        
        [products addObject:variants];
        
    }
    else
    {
        for (NSDictionary *product in goods) {
            NSDictionary *variants = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [product objectForKey:CartManagerSkuIDKey], @"id",
                                      [product objectForKey:CartManagerCountKey], @"number",
                                      [product objectForKey:CartManagerShopCodeKey], @"sid", nil];
            
            [products addObject:variants];
        }
    }
    
    NSString *inputCode = @"";
    
    for (NSString *code in [[OrderManager defaultManager] infoForKey:kInputCoupons]) {
        inputCode = [inputCode stringByAppendingFormat:@"%@,", code];
    }
    
    YunLog(@"inputCode = %@", inputCode);
    
    NSString *selectedCode = @"";
    
    for (NSString *code in [[OrderManager defaultManager] infoForKey:kSelectedCoupons]) {
        selectedCode = [selectedCode stringByAppendingFormat:@"%@,", code];
    }
    
    YunLog(@"selectedCode = %@", selectedCode);
    
    NSDictionary *priceParams;
    
    @try {
        priceParams = @{@"promotion_json":
                            @{@"product_variants"           :   products,
                              @"coupon_codes"               :   kNullToString(selectedCode),
                              @"coupon_digit_codes"         :   kNullToString(inputCode),
                              @"promotion_activity_codes"   :   @"",
                              @"user_phone"                 :   kNullToString(appDelegate.user.username),
                              @"user_address_id"            :   kNullToString(user_address_id)}
                        };
    }
    @catch (NSException *exception) {
        YunLog(@"use coupon exception = %@", exception);
        
        priceParams = @{};
    }
    @finally {
        
    }
    
    YunLog(@"use coupon params = %@", priceParams);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:priceURL
                                                                                parameters:priceParams
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"use coupon responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [_hud hide:YES];
            
            NSArray *userCoupon = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"user_coupons"]);
            
            YunLog(@"userCoupon = %@", userCoupon);
            
            [[OrderManager defaultManager] addInfo:userCoupon forKey:@"usedCoupons"];
            
            [[OrderManager defaultManager] addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"amount"]
                                            forKey:@"price"];
            [[OrderManager defaultManager] addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"promotion_amount"]
                                            forKey:@"promotion_amount"];
            [[OrderManager defaultManager] addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"promotion_discount"]
                                            forKey:@"promotion_discount"];
            
            [_hud addSuccessString:[NSString stringWithFormat:@"已为您优惠%@元", [[responseObject objectForKey:@"data"] objectForKey:@"promotion_discount"]]  delay:2.0];
            
            [_tableView reloadData];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [_hud hide:YES];
        } else {
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"use coupon error = %@", error);
        
        [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
        
    }];
    
    [op start];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // 收货信息
            return 1;
            break;
            
        case 1: // 订单信息
            if (_nowToBuy == YES)
            {
                return 1;
            }
            else
            {
                return _paySelectShops.count;
//                return 1;
            }
            break;
            
        case 2: // 发票信息
            return 1;
            break;
            
        case 3: // 订单备注
            return 1;
            break;
            
        case 4: // 优惠信息
            return 1 + [[[OrderManager defaultManager] infoForKey:@"discounts"] count];
            //                        + [[[OrderManager defaultManager] infoForKey:@"coupon_digit"] count];
            break;
            
        case 5: // 支付方式
            return [[[OrderManager defaultManager] infoForKey:@"paymentCategories"] count]; // 3;
            
            break;
            
        case 6: // 结算信息
            return 4;
            break;
            
        case 7: // 提交按钮
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"收货信息";
            
            break;
            
        case 1:
            return @"订单信息";
            
            break;
            
        case 2:
            return @"发票信息";
            break;
            
        case 3:
            return @"订单备注";
            break;
            
        case 4:
            return @"优惠信息";
            
            break;
            
        case 5:
            return @"支付方式";
            
            break;
            
        case 6:
            return @"结算信息";
            
            break;
            
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    switch (indexPath.section) {
        case 0:
        {
            NSString *province = kNullToString([[OrderManager defaultManager] infoForKey:@"province"]);
            NSString *city = kNullToString([[OrderManager defaultManager] infoForKey:@"city"]);
            NSString *area = kNullToString([[OrderManager defaultManager] infoForKey:@"area"]);
            NSString *detail = kNullToString([[OrderManager defaultManager] infoForKey:@"detail"]);
            
            NSString *address = [[[province stringByAppendingString:city] stringByAppendingString:area] stringByAppendingString:detail];
            
            int addressWidth = kScreenWidth - 40;
            if (kDeviceOSVersion < 7.0) {
                addressWidth -= 10;
            }
            
            CGSize addressSize = [address sizeWithFont:kNormalFont size:CGSizeMake(addressWidth, 9999)];
            
            height = 50 + addressSize.height;
            
            break;
        }
        case 1:
        {
            NSArray *promotion = [_shops[indexPath.row] objectForKey:@"promotion_activities"];
            if (_nowToBuy == YES)
            {
                if (promotion.count > 0) {
                    height = 140 + promotion.count * 20;
                } else {
                    height = 140;
                }
            }
            else
            {
                int productViewCount = [self getShopOfProductsCount:indexPath];
                // 获取对应商品的优惠信息
                
                if (promotion.count > 0) {
                    height = 40 + promotion.count * 20 + productViewCount * 100;
                } else {
                    height = 40 + productViewCount * 100;
                }
            }
            break;
        }
        case 7:
        {
                height = 40;
                
                break;
            }
            
        default:
        {
            break;
        }
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (kDeviceOSVersion >= 7.0) {
        if (section == 0) {
            return 38.0f;
        } else {
            return 20.0f;
        }
    } else {
        if (section == 7) {
            return 30;
        } else {
            return 40;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (kDeviceOSVersion < 7.0) {
        NSArray *labels = @[@"收货信息", @"订单信息", @"发票信息", @"订单备注", @"优惠信息", @"支付方式", @"结算信息", @""];
        
        CGRect rect = [_tableView rectForHeaderInSection:section];
        
        UIView *view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = kBackgroundColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 16, kScreenWidth - 20, 14)];
        label.backgroundColor = kClearColor;
        label.font = [UIFont fontWithName:kFontFamily size:14];
        label.text = labels[section];
        
        [view addSubview:label];
        
        return view;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    
    cell.textLabel.font = kNormalFont;
    
    // 收货信息
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // 收货人姓名
        NSString *username = [[OrderManager defaultManager] infoForKey:@"username"];
        
        UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, (kScreenWidth - 30) / 2, 40)];
        accountName.backgroundColor = kClearColor;
        accountName.font = kBigFont;
        accountName.text = kNullToString(username);
        accountName.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8];
        
        [cell.contentView addSubview:accountName];
        
        // 收货人电话
        NSString *phone = [[OrderManager defaultManager] infoForKey:@"phone"];
        
        UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 30) / 2, 0, (kScreenWidth - 30) / 2 - 10, 40)];
        accountPhone.backgroundColor = kClearColor;
        accountPhone.font = kBigFont;
        accountPhone.text = kNullToString(phone);
        accountPhone.textAlignment = NSTextAlignmentRight;
        accountPhone.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8];
        
        [cell.contentView addSubview:accountPhone];
        
        int addressWidth = kScreenWidth - 40;
        if (kDeviceOSVersion < 7.0) {
            addressWidth -= 10;
        }
        
        // 收货人地址
        NSString *province = [[OrderManager defaultManager] infoForKey:@"province"];
        NSString *city = [[OrderManager defaultManager] infoForKey:@"city"];
        NSString *area = [[OrderManager defaultManager] infoForKey:@"area"];
        NSString *detail = [[OrderManager defaultManager] infoForKey:@"detail"];
        
        NSString *address = [[[kNullToString(province) stringByAppendingString:kNullToString(city)] stringByAppendingString:kNullToString(area)] stringByAppendingString:kNullToString(detail)];
        
        CGSize addressSize = [address sizeWithFont:kNormalFont size:CGSizeMake(addressWidth, 9999)];
        
        UILabel *accountAddress = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, addressWidth, addressSize.height)];
        accountAddress.backgroundColor = kClearColor;
        accountAddress.numberOfLines = 0;
        accountAddress.text = address;
        accountAddress.font = kNormalFont;
        accountAddress.textColor = COLOR(30, 144, 255, 1);
        
        [cell.contentView addSubview:accountAddress];
    }
    
    // 订单信息
    else if (indexPath.section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_nowToBuy == YES)
        {
            UIView *shopView = [[UIView alloc] init];
            
            NSArray *promotion = [_shops[indexPath.row] objectForKey:@"promotion_activities"];
            
            if (promotion.count > 0) {
                shopView.frame = CGRectMake(0, 0, kScreenWidth, (140 + 20 * promotion.count));
            } else {
                shopView.frame = CGRectMake(0, 0, kScreenWidth, 140);
            }
            
            // 店铺标题
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 30)];
            titleLabel.text = [_shopNowPayDict safeObjectForKey:@"shop_name"];
            titleLabel.font = kNormalFont;
            titleLabel.textColor = [UIColor blackColor];
            
            [shopView addSubview:titleLabel];
            
            // 分割线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), kScreenWidth, kLineHeight)];
            lineView.backgroundColor = [UIColor lightGrayColor];
            
            [shopView addSubview:lineView];
            
            // 添加图片
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView.frame) + 5, kImageViewHeightWidth, kImageViewHeightWidth)];
            
            imageView.contentMode = UIViewContentModeCenter;
            
            __weak UIImageView *_imageView = imageView;
            
            [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([_shopNowPayDict safeObjectForKey:@"image_url_200"])]]
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          // UIViewContentModeScaleAspectFit
                                          _imageView.contentMode = UIViewContentModeScaleToFill;
                                          _imageView.image = image;
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([_shopNowPayDict safeObjectForKey:@"image_url_218"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                          _imageView.contentMode = UIViewContentModeScaleToFill;
                                      }];
            
            [shopView addSubview:imageView];
            
            NSString *productNameText = [_shopNowPayDict safeObjectForKey:@"title"];
            
            CGFloat productNameHeight = [Tool calculateContentLabelHeight:productNameText withFont:kNormalFont withWidth:kScreenWidth - 150];
            
            // 添加商品标题
            UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, imageView.frame.origin.y + 10, kScreenWidth - 150, productNameHeight)];
            productName.textColor = kBlackColor;
            productName.text = productNameText;
            productName.numberOfLines = 0;
            productName.font = kNormalFont;
            
            [shopView addSubview:productName];
            
            // 添加数量信息
            UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 40, imageView.frame.origin.y + 10, 30, 20)];
            quantityLabel.text = [NSString stringWithFormat:@"x %@", _buyCount];
            quantityLabel.font = kMidFont;
            quantityLabel.textColor = kBlackColor;
            
            [shopView addSubview:quantityLabel];
            
            // 添加类型信息
            UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(productName.frame) + 5, kScreenWidth - 120, 20)];
            variantLabel.textColor = [UIColor lightGrayColor];
            NSString *variantName = [NSString stringWithFormat:@"%@ %@ %@",[_order safeObjectForKey:@"value1"], [_order safeObjectForKey:@"value2"], [_order safeObjectForKey:@"value3"]];
            variantLabel.text = variantName;
            variantLabel.font = kMidFont;
            
            [shopView addSubview:variantLabel];
            
            // 添加价格
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(variantLabel.frame) + 5, kScreenWidth - 120, 20)];
            priceLabel.text = [NSString stringWithFormat:@"￥ %@", [_order objectForKey:@"price"]];
            priceLabel.textColor = [UIColor redColor];
            priceLabel.font = kMidFont;
            
            [shopView addSubview:priceLabel];
            
            if (promotion.count > 0) {
                // 分割线
                UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, kScreenWidth, kLineHeight)];
                bottomLineView.backgroundColor = [UIColor lightGrayColor];
                
                [shopView addSubview:bottomLineView];
                
                for (int t = 0; t < promotion.count; t++) {
                    CGFloat promotionLabelY = CGRectGetMaxY(bottomLineView.frame) + 20 * t;
                    UILabel *promotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, promotionLabelY, kScreenWidth - 20, 20)];
                    promotionLabel.textColor = [UIColor redColor];
                    promotionLabel.text = [NSString stringWithFormat:@"优惠: %@", [promotion[t] objectForKey:@"name"]];
                    promotionLabel.font = kMidFont;
                    
                    [shopView addSubview:promotionLabel];
                }
            }
            // 最下面的一条分割线
            UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shopView.frame) - 1, kScreenWidth, kLineHeight)];
            bottomLineView.backgroundColor = [UIColor lightGrayColor];
            
            [shopView addSubview:bottomLineView];
            
            [cell.contentView addSubview:shopView];
        }
        else
        {
            
        // 这里有多少个shop就返回多少个cell
            NSDictionary *shopDict = _paySelectShops[indexPath.row];
            NSArray *variantsArray = [shopDict objectForKey:@"product_variants"];
            NSArray *promotion = [_shops[indexPath.row] objectForKey:@"promotion_activities"];
             UIView *shopView = [[UIView alloc] init];
            shopView.backgroundColor = kWhiteColor;
            int productViewCount = [self getShopOfProductsCount:indexPath];
            if (promotion.count > 0) {
                shopView.frame = CGRectMake(0, 0, kScreenWidth, 40 + 100 * productViewCount + 20 * promotion.count);
            } else {
                shopView.frame = CGRectMake(0, 0, kScreenWidth, 40 + 100 * productViewCount);
            }
            
             //店铺标题
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 30)];
            titleLabel.text = shopDict[@"name"];
            titleLabel.font = kNormalFont;
            titleLabel.textColor = [UIColor blackColor];

            [shopView addSubview:titleLabel];

            // 分割线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), kScreenWidth, kLineHeight)];
            lineView.backgroundColor = [UIColor lightGrayColor];
            
            [shopView addSubview:lineView];
            
            // 创建每个商品信息的对应view
            NSInteger productCount = 0;
            NSInteger productHeight = 0;
            for (int i = 0; i < variantsArray.count; i++) {
                for (int j = 0; j < _allSelectProducts.count; j++) {
                    if ([[variantsArray[i] objectForKey:@"sku_id"] integerValue] == [[_allSelectProducts[j] objectForKey:@"sku_id"] integerValue]) {
                        // 添加商品图片
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView.frame) + 5 + productCount * 100, kImageViewHeightWidth, kImageViewHeightWidth)];

                        imageView.contentMode = UIViewContentModeCenter;

                        __weak UIImageView *_imageView = imageView;

                        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([_allSelectProducts[j] objectForKey:@"image_url_200"])]]
                                         placeholderImage:nil
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      // UIViewContentModeScaleAspectFit
                                                      _imageView.contentMode = UIViewContentModeScaleToFill;
                                                      _imageView.image = image;
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                      [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([_allSelectProducts[j] objectForKey:@"image_url_270"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                                      _imageView.contentMode = UIViewContentModeScaleToFill;
                                                  }];
                        productCount += 1;
                        
                        [shopView addSubview:imageView];
                        
                        NSString *productNameText = [_allSelectProducts[j] objectForKey:@"product_name"];
                        
                        CGFloat productNameHeight = [Tool calculateContentLabelHeight:productNameText withFont:kNormalFont withWidth:kScreenWidth - 150];
                        
                        // 添加商品名称
                        CGFloat productNameY = imageView.frame.origin.y + 5;

                        UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, productNameY, kScreenWidth - 150, productNameHeight)];
                        productName.textColor = kBlackColor;
                        productName.text = productNameText;
                        productName.numberOfLines = 0;
                        productName.font = kNormalFont;

                        [shopView addSubview:productName];

                        // 添加数量信息
                        UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 40, productNameY, 30, 20)];
                        quantityLabel.text = [NSString stringWithFormat:@"x %@", [_allSelectProducts[j] objectForKey:@"quantity"]];
                        quantityLabel.font = kMidFont;
                        quantityLabel.textColor = kBlackColor;

                        [shopView addSubview:quantityLabel];

                        // 添加类型信息
                        UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(productName.frame) + 5, kScreenWidth - 120, 20)];
                        variantLabel.textColor = [UIColor lightGrayColor];
                        variantLabel.text = kNullToString([_allSelectProducts[j] objectForKey:@"product_variant_name"]);
                        variantLabel.font = kMidFont;

                        [shopView addSubview:variantLabel];

                        // 添加价格
                        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(variantLabel.frame) + 5, kScreenWidth - 120, 20)];
                        priceLabel.text = [NSString stringWithFormat:@"￥ %@", [_allSelectProducts[j] objectForKey:@"price"]];
                        priceLabel.textColor = [UIColor redColor];
                        priceLabel.font = kMidFont;
                        
                        [shopView addSubview:priceLabel];
                        
                        productHeight = CGRectGetMaxY(imageView.frame);
                    }
                }
            }
            
            // 判断是否需要添加优惠信息
            // 添加底部分割线，计算优惠信息
            if (promotion.count > 0) {
                // 分割线
                UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, productHeight + 5, kScreenWidth, kLineHeight)];
                bottomLineView.backgroundColor = [UIColor lightGrayColor];

                [shopView addSubview:bottomLineView];


                for (int t = 0; t < promotion.count; t++) {
                    CGFloat promotionLabelY = productHeight + 10 + 20 * t;
                    UILabel *promotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, promotionLabelY, kScreenWidth - 20, 20)];
                    promotionLabel.textColor = [UIColor redColor];
                    promotionLabel.text = [NSString stringWithFormat:@"优惠: %@", [promotion[t] objectForKey:@"name"]];
                    promotionLabel.font = kMidFont;

                    [shopView addSubview:promotionLabel];
                }
                //  最下面的一条分割线
                UIView *bottomLineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shopView.frame) - 1, kScreenWidth, kLineHeight)];
                bottomLineView2.backgroundColor = [UIColor lightGrayColor];
                
                [shopView addSubview:bottomLineView2];
            } else {
                // 分割线
                UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shopView.frame) - 1, kScreenWidth, kLineHeight)];
                bottomLineView.backgroundColor = [UIColor lightGrayColor];
                
                [shopView addSubview:bottomLineView];
            }
            
            [cell.contentView addSubview:shopView];


            // TODO  还没有设置每个店铺view的frame
//            for (int i = 0; i < _paySelectShops.count; i++) {
//                NSDictionary *shopDict = _paySelectShops[i];
//                NSArray *variantsArray = shopDict[@"product_variants"];
//                UIView *shopView = [[UIView alloc] init];
//                if (_promotionArray.count > 0) {
//                    shopView.frame = CGRectMake(0, 0, kScreenWidth, 30 + 100 * _shopViewCount + 20 * _promotionArray.count);
//                } else {
//                    shopView.frame = CGRectMake(0, 0, kScreenWidth, 30 + 100 * _shopViewCount);
//                }
//                
//                shopView.backgroundColor = kWhiteColor;
//                // 店铺标题
//                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 30)];
//                titleLabel.text = shopDict[@"name"];
//                titleLabel.font = kNormalFont;
//                titleLabel.textColor = [UIColor blackColor];
//                
//                [shopView addSubview:titleLabel];
//                
//                // 分割线
//                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), kScreenWidth, kLineHeight)];
//                lineView.backgroundColor = [UIColor lightGrayColor];
//                
//                [shopView addSubview:lineView];
//                // 循环创建对应商品的一些控件信息
//                NSInteger productCount = 0;
//                NSInteger productHeight = 0;
//                for (int j = 0; j < variantsArray.count; j++) {
//                    for (int z = 0; z < _allSelectProducts.count; z++) {
//                        if ([[variantsArray[j] objectForKey:@"product_code"] integerValue] == [[_allSelectProducts[z] objectForKey:@"product_code"] integerValue]) {
//                            // 添加图片
//                            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView.frame) + 5 + productCount * 100, kImageViewHeightWidth, kImageViewHeightWidth)];
//                            
//                            imageView.contentMode = UIViewContentModeCenter;
//                            
//                            __weak UIImageView *_imageView = imageView;
//                            
//                            [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([_allSelectProducts[z] objectForKey:@"image_url_200"])]]
//                                             placeholderImage:nil
//                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                          // UIViewContentModeScaleAspectFit
//                                                          _imageView.contentMode = UIViewContentModeScaleToFill;
//                                                          _imageView.image = image;
//                                                      }
//                                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                          [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([_allSelectProducts[z] objectForKey:@"image_url_270"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
//                                                          _imageView.contentMode = UIViewContentModeScaleToFill;
//                                                      }];
//                            productCount += 1;
//                            
//                            [shopView addSubview:imageView];
//                            
//                            CGFloat productNameY = imageView.frame.origin.y + 10;
//                            // 添加商品标题
//                            UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, productNameY, kScreenWidth - 120, 20)];
//                            productName.textColor = kBlackColor;
//                            productName.text = [_allSelectProducts[z] objectForKey:@"product_name"];
//                            productName.font = kNormalFont;
//                            
//                            [shopView addSubview:productName];
//                            
//                            // 添加数量信息
//                            UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 50, productNameY, 40, 20)];
//                            quantityLabel.text = [NSString stringWithFormat:@"x %@", [_allSelectProducts[z] objectForKey:@"quantity"]];
//                            quantityLabel.font = kMidFont;
//                            quantityLabel.textColor = kBlackColor;
//                            
//                            [shopView addSubview:quantityLabel];
//                            
//                            // 添加类型信息
//                            UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(productName.frame) + 5, kScreenWidth - 120, 20)];
//                            variantLabel.textColor = [UIColor lightGrayColor];
//                            variantLabel.text = [_allSelectProducts[z] objectForKey:@"product_variant_name"];
//                            variantLabel.font = kMidFont;
//                            
//                            [shopView addSubview:variantLabel];
//                            
//                            // 添加价格
//                            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(variantLabel.frame) + 5, kScreenWidth - 120, 20)];
//                            priceLabel.text = [NSString stringWithFormat:@"￥ %@", [_allSelectProducts[z] objectForKey:@"price"]];
//                            priceLabel.textColor = [UIColor redColor];
//                            priceLabel.font = kMidFont;
//                            
//                            [shopView addSubview:priceLabel];
//                            
//                            productHeight = CGRectGetMaxY(imageView.frame);
//                        }
//                    }
//                }
//                
//                // 添加底部分割线，计算优惠信息
//                NSArray *promotionArray = shopDict[@"promotion"];
//                if (promotionArray.count > 0) {
//                    // 分割线
//                    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, productHeight + 5, kScreenWidth, kLineHeight)];
//                    bottomLineView.backgroundColor = [UIColor lightGrayColor];
//                    
//                    [shopView addSubview:bottomLineView];
//                    
//                    
//                    for (int t = 0; t < promotionArray.count; t++) {
//                        CGFloat promotionLabelY = productHeight + 5 + 20 * t;
//                        UILabel *promotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, promotionLabelY, kScreenWidth - 20, 20)];
//                        promotionLabel.textColor = [UIColor redColor];
//                        promotionLabel.text = [NSString stringWithFormat:@"优惠: %@", promotionArray[t]];
//                        promotionLabel.font = kMidFont;
//                        
//                        [shopView addSubview:promotionLabel];
//                    }
//                }
//                
//                [cell.contentView addSubview:shopView];
//            }
        }
    }
    
    // 发票信息
    else if (indexPath.section == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 12, kScreenWidth - 30, 20)];
        textField.tag = InvoiceTextField;
        textField.delegate = self;
        textField.placeholder = @"请输入发票内容";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
            textField.text = kNullToString([[OrderManager defaultManager] infoForKey:@"invoice"]);
        YunLog(@"输出的发票信息是： = %@", [[OrderManager defaultManager] infoForKey:@"invoice"]);
        
        [textField addTarget:self action:@selector(textWithInput:) forControlEvents:UIControlEventEditingChanged];
        
        [cell.contentView addSubview:textField];
    }
    
    // 订单备注
    else if (indexPath.section == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 12, kScreenWidth - 30, 20)];
        textField.tag = NoteTextField;
        textField.delegate = self;
        textField.placeholder = @"请输入订单备注";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.text = kNullToString([[OrderManager defaultManager] infoForKey:@"note"]);
        [textField addTarget:self action:@selector(textWithInput:) forControlEvents:UIControlEventEditingChanged];
        
        [cell.contentView addSubview:textField];
    }
    
    // 优惠信息
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"使用优惠券";
            cell.textLabel.backgroundColor = [UIColor redColor];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = [NSString stringWithFormat:@"编号: %@", [[OrderManager defaultManager] infoForKey:@"discounts"][indexPath.row - 1]];
            
            UIButton *del = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 59, 10, 44, 24)];
            del.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
            del.tag = indexPath.row - 1;
            del.backgroundColor = kClearColor;
            del.layer.cornerRadius = 6;
            del.layer.masksToBounds = YES;
            del.layer.borderColor = [UIColor orangeColor].CGColor;
            del.layer.borderWidth = 1;
            [del setTitle:@"删除" forState:UIControlStateNormal];
            [del setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [del addTarget:self action:@selector(delCoupon:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:del];
        }
    }
    
    // 支付方式
    else if (indexPath.section == 5) {
        cell.detailTextLabel.font = [UIFont fontWithName:kFontFamily size:14];
        
        UIImageView *selectView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"pay_type_unselect"]];
        cell.accessoryView = selectView;
        
        NSDictionary *payment = [[OrderManager defaultManager] infoForKey:@"paymentCategories"][indexPath.row];
        
        if ([[[OrderManager defaultManager] infoForKey:@"pay"] integerValue] == [[payment objectForKey:@"value"] integerValue]) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectView setImage:[UIImage imageNamed:@"pay_type_selected"]];
        }
        
        NSString *payImage;
        if ([payment[@"title"] isEqualToString:@"微信支付"]) {
            payImage = @"pay_weixin_icon";
        } else if ([payment[@"title"] isEqualToString:@"信用卡便捷支付"]) {
            payImage = @"upay_icon";
        } else if ([payment[@"title"] isEqualToString:@"支付宝账号支付"]) {
            payImage = @"pay_ali_icon";
        }
        
        [cell.imageView setImage:[UIImage imageNamed:payImage]];
        cell.textLabel.text = kNullToString([payment objectForKey:@"title"]);
        cell.detailTextLabel.text = kNullToString([payment objectForKey:@"subtitle"]);
    }
    
    // 结算信息
    else if (indexPath.section == 6) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"商品总价";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", kNullToString([[OrderManager defaultManager] infoForKey:@"price"])];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = @"已优惠";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", kNullToString([[OrderManager defaultManager] infoForKey:@"promotion_discount"])];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = @"运费";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", kNullToString([[OrderManager defaultManager] infoForKey:@"freight_amount"])];
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = @"应付金额";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", kNullToString([[OrderManager defaultManager] infoForKey:@"promotion_amount"])];
        }
        
    }
    
    // 提交按钮
    else if (indexPath.section == 7) {
        _commitOrder = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        _commitOrder.enabled = _commitButtonEnabled;
        
        [_commitOrder setBackgroundImage:[UIImage imageNamed:@"commit_order"] forState:UIControlStateNormal];
        [_commitOrder setTitle:@"提交订单" forState:UIControlStateNormal];
        [_commitOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitOrder addTarget:self action:@selector(commitOrderClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:_commitOrder];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: // 收货信息
        {
            // 收货人地区
            AddressListViewController *list = [[AddressListViewController alloc] init];
            list.isPay = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isPay"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.navigationController pushViewController:list animated:YES];
            
            break;
        }
            
        case 4: // 优惠信息
        {
            if (indexPath.row == 0) {
                CouponUseViewController *coupon = [[CouponUseViewController alloc] init];
                coupon.params = _priceParams;
                
                [self.navigationController pushViewController:coupon animated:YES];
            }
        }
            
        case 5: // 支付方式
        {
            NSDictionary *payment = [[OrderManager defaultManager] infoForKey:@"paymentCategories"][indexPath.row];
            
            [[OrderManager defaultManager] addInfo:[payment objectForKey:@"value"] forKey:@"pay"];
            
            for (int i = 0; i < [tableView numberOfRowsInSection:5]; i++) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:5]];
                
//                cell.accessoryType = UITableViewCellAccessoryNone;
                [((UIImageView *)cell.accessoryView) setImage:[UIImage imageNamed:@"pay_type_unselect"]];
            }
            
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:5]];
            
            [((UIImageView *)selectedCell.accessoryView) setImage:[UIImage imageNamed:@"pay_type_selected"]];
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Clu Shop Products - 

- (int)getShopOfProductsCount:(NSIndexPath *)indexPath
{
    NSDictionary *shopDict = _paySelectShops[indexPath.row];
    NSArray *productVariantArray = [shopDict objectForKey:@"product_variants"];
    int productViewCount = 0;
    // 计算对应的shop里面添加进入结算的商品数量
    for (int i = 0; i < productVariantArray.count; i++) {
        for (int j = 0; j < _allSelectProducts.count; j++) {
            if ([[productVariantArray[i] objectForKey:@"sku_id"] integerValue] == [[_allSelectProducts[j] objectForKey:@"sku_id"] integerValue]) {
                productViewCount++;
            }
        }
    }
    return productViewCount;
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case InvoiceTextField:
            
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
            break;
            
        case NoteTextField:
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UIWebViewDelegate -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    YunLog(@"WebView Open Start");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    YunLog(@"WebView Open Done");
    
    if (_hud) [_hud hide:YES];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    YunLog(@"open web pay url error = %@", error);
    
    if (!_hud) _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [_hud addErrorString:@"网络异常,请查看待支付订单" delay:2.0];
    
    [self returnView:PayResultFailure];
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

//- (void)onPayResult:(NSString *)orderId resultCode:(NSString *)resultCode resultMessage:(NSString *)resultMessage
//{
//    if ([resultCode isEqualToString:kUmpaykSuccessCode]) {
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [_hud addSuccessString:resultMessage delay:2.0];
//
//        double delayInSeconds = 1.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self returnView:];
//        });
//    } else if ([resultCode isEqualToString:kUmpayFailureCode]) {
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [_hud addErrorString:resultMessage delay:2.0];
//
//        OrderListViewController *order = [[OrderListViewController alloc] init];
//        order.orderType = WaitingForPay;
//
//        [self.navigationController pushViewController:order animated:YES];
//
//        _paying = YES;
//    } else {
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
//
//        OrderListViewController *order = [[OrderListViewController alloc] init];
//        order.orderType = WaitingForPay;
//
//        [self.navigationController pushViewController:order animated:YES];
//
//        _paying = YES;
//    }
//}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"订单支付成功"]) {
        [self returnView:PayResultSuccess];
    } else {
        [self returnView:PayResultCancel];
        //        OrderListViewController *order = [[OrderListViewController alloc] init];
        //        order.orderType = WaitingForPay;
        //
        //        [self.navigationController pushViewController:order animated:YES];
        
        //        _paying = YES;
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
