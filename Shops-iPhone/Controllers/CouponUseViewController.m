//
//  CouponUseViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-12-09.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "CouponUseViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"
#import "Tool.h"
#import "OrderManager.h"
#import "CartManager.h"

// Views
#import "LoginTextField.h"

// Categories
#import "NSObject+NullToString.h"

// Libraries
#import "AFNetworking.h"

@interface CouponUseViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *inputButton;

@property (nonatomic, copy) NSString *inputCode;
@property (nonatomic, strong) NSArray *coupons;
@property (nonatomic, strong) NSArray *usedCoupons;
@property (nonatomic, strong) NSMutableArray *selectedCoupons;
@property (nonatomic, strong) NSMutableArray *inputCoupons;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation CouponUseViewController

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
        naviTitle.text = @"优惠券使用";
        
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
    
//    [TalkingData trackPageBegin:@"进入优惠券使用页面"];
    
    _selectedCoupons = [[OrderManager defaultManager] infoForKey:kSelectedCoupons] ? [[OrderManager defaultManager] infoForKey:kSelectedCoupons] : [[NSMutableArray alloc] init];
    _inputCoupons = [[OrderManager defaultManager] infoForKey:kInputCoupons] ? [[OrderManager defaultManager] infoForKey:kInputCoupons] : [[NSMutableArray alloc] init];
    
    _usedCoupons = [[OrderManager defaultManager] infoForKey:@"usedCoupons"];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [TalkingData trackPageEnd:@"离开优惠券使用页面"];
    
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
    
    self.view.backgroundColor = kBackgroundColor;
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 10, kScreenWidth - 20, 16)];
    inputLabel.backgroundColor = kClearColor;
    inputLabel.font = kNormalFont;
    inputLabel.text = @"手工添加优惠券";
    
    [self.view addSubview:inputLabel];
    
    LoginTextField *inputText = [[LoginTextField alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 36, kScreenWidth - 20, 40) leftViewImage:@"login_coupon"];
    inputText.placeholder = @"请输入优惠券";
    inputText.delegate = self;
    [inputText addTarget:self action:@selector(textWithInput:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:inputText];
    
    _inputButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, 40, 24)];
    _inputButton.layer.cornerRadius = 6;
    _inputButton.layer.masksToBounds = YES;
    _inputButton.enabled = NO;
    _inputButton.backgroundColor = COLOR(147, 147, 147, 1);
    _inputButton.titleLabel.font = kNormalFont;
    [_inputButton setTitle:@"使用" forState:UIControlStateNormal];
    [_inputButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_inputButton addTarget:self action:@selector(inputCoupon:) forControlEvents:UIControlEventTouchUpInside];
    
    inputText.rightView = _inputButton;
    inputText.rightViewMode = UITextFieldViewModeAlways;
    
    AppDelegate *appDelegate = kAppDelegate;
    if (appDelegate.isLogin) {
        UILabel *myCoupon = [[UILabel alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 96, kScreenWidth - 20, 16)];
        myCoupon.backgroundColor = kClearColor;
        myCoupon.font = kNormalFont;
        myCoupon.text = @"我的优惠券";
        
        [self.view addSubview:myCoupon];
        
        NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
        
        NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kCouponQueryURL params:params];
        
        YunLog(@"coupon list url = %@", listURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:listURL parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"coupon list responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                _coupons = [[responseObject objectForKey:@"data"] objectForKey:@"coupons"];
                
                [self initCoupons];
            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                [Tool resetUser];
                
                [self backToPrev];
            } else {
                [self initCoupons];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"coupon list url = %@", error);
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initCoupons
{
    if (_coupons.count > 0) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 122, kScreenWidth - 20, kScreenHeight - 44 - 20 - 122 - 10)];
        scrollView.contentSize = CGSizeMake(kScreenWidth - 20, 900);
        scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:scrollView];
        
        int couponHeight = 0;
        for (NSDictionary *coupon in _coupons) {
            UIButton *container = [[UIButton alloc] initWithFrame:CGRectMake(0, couponHeight, kScreenWidth - 20, 74)];
            container.layer.cornerRadius = 6;
            container.layer.masksToBounds = YES;
            container.layer.borderColor = [UIColor orangeColor].CGColor;
            container.layer.borderWidth = 1;
            container.tag = [_coupons indexOfObject:coupon];
            [container addTarget:self action:@selector(selectCoupon:) forControlEvents:UIControlEventTouchUpInside];
            
            [scrollView addSubview:container];
            
            UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 74)];
            left.backgroundColor = [UIColor orangeColor];
            left.font = kSmallFont;
            left.textColor = [UIColor whiteColor];
            left.text = [NSString stringWithFormat:@"%@元", [coupon objectForKey:@"amount"]];
            left.textAlignment = NSTextAlignmentCenter;
            
            [container addSubview:left];
            
            UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(50, 9, 100, 12)];
            number.backgroundColor = kClearColor;
            number.font = kSmallFont;
            number.text = @"编号";
            number.textColor = [UIColor orangeColor];
            
            [container addSubview:number];
            
            UILabel *numberContent = [[UILabel alloc] initWithFrame:CGRectMake(50, 23, 100, 12)];
            numberContent.backgroundColor = kClearColor;
            numberContent.font = kSmallFont;
            numberContent.text = [coupon objectForKey:@"digit_code"];
            
            [container addSubview:numberContent];
            
            UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(50, 39, 100, 12)];
            time.backgroundColor = kClearColor;
            time.font = kSmallFont;
            time.text = @"有效期";
            time.textColor = [UIColor orangeColor];
            
            [container addSubview:time];
            
            UILabel *timeContent = [[UILabel alloc] initWithFrame:CGRectMake(50, 53, 140, 12)];
            timeContent.backgroundColor = kClearColor;
            timeContent.font = kSmallFont;
            timeContent.text = [NSString stringWithFormat:@"%@~%@", [[coupon objectForKey:@"started_at"] toString], [[coupon objectForKey:@"ended_at"] toString]];
            
            [container addSubview:timeContent];
            
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(195, 7, 100, 60)];
            description.backgroundColor = kClearColor;
            description.font = kSmallFont;
            description.numberOfLines = 4;
            description.text = [coupon objectForKey:@"description"];
            
            [container addSubview:description];
            
            couponHeight += 74 + 10;
        }
        
        scrollView.contentSize = CGSizeMake(300, couponHeight);
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, kCustomNaviHeight + 122, kScreenWidth - 20, 14)];
        label.backgroundColor = kClearColor;
        label.font = [UIFont fontWithName:kFontFamily size:14];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"您还没有优惠券";
        
        [self.view addSubview:label];
    }
}

- (void)textWithInput:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        _inputButton.backgroundColor = COLOR(147, 147, 147, 1);
        _inputButton.enabled = NO;
    } else {
        _inputButton.backgroundColor = [UIColor orangeColor];
        _inputButton.enabled = YES;
    }
    
    _inputCode = textField.text;
}

- (void)inputCoupon:(UIButton *)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (_inputCoupons.count <= 0) {
        [_inputCoupons addObject:_inputCode];
    } else {
        for (NSString *codeStr in _inputCoupons) {
            if ([codeStr isEqualToString:_inputCode]) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:@"此优惠劵已被当前订单使用" delay:2.0];
                
                return;
            }
        }
        
        [_inputCoupons addObject:_inputCode];
    }

    [self calculatePromotionByType:@"input"];
}

- (void)selectCoupon:(UIButton *)sender
{
    YunLog(@"coupon index = %ld", (long)sender.tag);
    
    NSString *code = [_coupons[sender.tag] objectForKey:@"code"];

    if (_selectedCoupons.count <= 0) {
        [_selectedCoupons addObject:code];
    } else {
        for (NSString *codeStr in _selectedCoupons) {
            if ([codeStr isEqualToString:code]) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:@"此优惠劵已被当前订单使用" delay:2.0];
                
                return;
            }
        }
        
        [_selectedCoupons addObject:code];
    }
    
    [self calculatePromotionByType:@"select"];
}

- (void)calculatePromotionByType:(NSString *)type
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.mode = MBProgressHUDModeText;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *priceURL = [Tool buildRequestURLHost:kRequestHost
                                        APIVersion:kAPIVersion1
                                        requestURL:kPromotionsCalculateURL
                                            params:params];
    
    YunLog(@"order price url = %@", priceURL);
    
    NSArray *goods = [[CartManager defaultCart] allProducts];
    YunLog(@"goods = %@", goods);
    
    NSMutableArray *products = [[NSMutableArray alloc] init];
    for (NSDictionary *product in goods) {
        NSDictionary *variants = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [product objectForKey:CartManagerSkuIDKey], @"id",
                                  [product objectForKey:CartManagerCountKey], @"number",
                                  [product objectForKey:CartManagerProductCodeKey], @"sid", nil];
        
        [products addObject:variants];
    }
    
    NSString *inputCode = @"";
    
    for (NSString *code in _inputCoupons) {
        inputCode = [inputCode stringByAppendingFormat:@"%@,", code];
    }
    
    YunLog(@"inputCode = %@", inputCode);
    
    NSString *selectedCode = @"";
    
    for (NSString *code in _selectedCoupons) {
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
                              @"user_phone"                 :   kNullToString(appDelegate.user.username)}};
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
            
            if ([type isEqualToString:@"input"]) {
                BOOL couponAvailable = NO;
                
                for (NSDictionary *couponDic in userCoupon) {
                    if ([_inputCode isEqualToString:[couponDic objectForKey:@"digit_code"]]) {
                        couponAvailable = YES;
                    }
                }
                
                if (!couponAvailable) {
                    [_inputCoupons removeObject:_inputCode];
                    
                    [_hud addErrorString:@"请输入正确的优惠劵码" delay:2.0];
                    
                    return;
                }
                
                [[OrderManager defaultManager] addInfo:_inputCoupons forKey:kInputCoupons];
            } else {
                [[OrderManager defaultManager] addInfo:_selectedCoupons forKey:kSelectedCoupons];
            }
            
            [[OrderManager defaultManager] addInfo:userCoupon forKey:@"usedCoupons"];
            
            [[OrderManager defaultManager] addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"amount"]
                                            forKey:@"price"];
            [[OrderManager defaultManager] addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"promotion_amount"]
                                            forKey:@"promotion_amount"];
            [[OrderManager defaultManager] addInfo:[[responseObject objectForKey:@"data"] objectForKey:@"promotion_discount"]
                                            forKey:@"promotion_discount"];
            
            NSArray *discounts = [_inputCoupons arrayByAddingObjectsFromArray:_selectedCoupons];
            
            YunLog(@"discounts = %@", discounts);
            
            [[OrderManager defaultManager] addInfo:discounts forKey:@"discounts"];
            
            [_hud addSuccessString:[NSString stringWithFormat:@"已为您优惠%@元", [[responseObject objectForKey:@"data"] objectForKey:@"promotion_discount"]]
                             delay:2.0];
            
            [self backToPrev];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self backToPrev];
        } else {
            [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            
            [self backToPrev];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"use coupon error = %@", error);
        
        [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];

        [self backToPrev];
    }];
    
    [op start];
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
