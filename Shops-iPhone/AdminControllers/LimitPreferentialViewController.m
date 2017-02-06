//
//  LimitPreferentialViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/9/1.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "LimitPreferentialViewController.h"

// Controllers
#import "LimitPreferentialDetailViewController.h"

// Libary
#import "UUDatePicker.h"

// Common
#import "LibraryHeadersForCommonController.h"

#import "SaleTextField.h"

#import "AppDelegate.h"

@interface LimitPreferentialViewController () <UITextFieldDelegate, UUDatePickerDelegate>
/// 左边时间选择器
@property (nonatomic ,strong) UITextField *leftTextField;

/// 右边时间选择器
@property (nonatomic ,strong) UITextField *rightTextField;

/// 填写金额上
@property (nonatomic ,strong) SaleTextField *limitTextFieldUp;

/// 填写金额下
@property (nonatomic ,strong) SaleTextField *limitTextFieldDown;

/// 打折上
@property (nonatomic ,strong) SaleTextField *discountTextFieldUp;

/// 打折下
@property (nonatomic ,strong) SaleTextField *discountTextFieldDown;

/// 当前选中的按钮
@property (nonatomic ,strong) UIButton *lastSelectedButton;

/// 当前选中的按钮
@property (nonatomic ,strong) UIButton *up;

/// 当前选中的按钮
@property (nonatomic ,strong) UIButton *down;

/// datePicker
@property (nonatomic, strong) UUDatePicker *datePicker;

/// 第三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 创建按钮
@property (nonatomic ,strong) UIButton *createButton;
@end

@implementation LimitPreferentialViewController


#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"限时特惠";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteActivitySucceed) name:@"deleteActivitySucceedDiscount" object:nil];
    
    self.view.backgroundColor = kGrayColor;
    
    _lastSelectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self createUI];
    
    //    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)deleteActivitySucceed
{
    _createButton.enabled = YES;
}

- (void)createActivitySucceed
{
    _createButton.enabled = NO;
}

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    UILabel *dayTittle = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, 70, 44)];
    
    dayTittle.text = @"促销日期：";
    dayTittle.font = kMidBoldFont;
    dayTittle.textColor = kLightBlackColor;
    
    [self.view addSubview:dayTittle];
    
    _leftTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dayTittle.frame), 74, (kScreenWidth - CGRectGetMaxX(dayTittle.frame) - 30 - 20) / 2, 24)];
    
    _leftTextField.backgroundColor = [UIColor whiteColor];
    _leftTextField.layer.borderWidth = 0.5;
    _leftTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _leftTextField.layer.masksToBounds = YES;
    _leftTextField.layer.cornerRadius = 3;
    _leftTextField.delegate = self;
    _leftTextField.tag = 100;
    _leftTextField.textColor = [UIColor darkGrayColor];
    _leftTextField.font = kSmallFont;
    _leftTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_leftTextField];
    
    UIButton *pickLeft = [UIButton buttonWithType:UIButtonTypeCustom];

    pickLeft.userInteractionEnabled = NO;
    pickLeft.backgroundColor = kGrayColor;
    pickLeft.frame = CGRectMake(0, 0, 24, 24);
    pickLeft.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [pickLeft setImage:[UIImage imageNamed:@"day_picker"] forState:UIControlStateNormal];
    
    pickLeft.layer.borderWidth = 1;
    pickLeft.layer.borderColor = [UIColor grayColor].CGColor;
    
    _leftTextField.rightView = pickLeft;
    _leftTextField.rightViewMode = UITextFieldViewModeAlways;
    
    NSDate *now = [NSDate date];
    
    UUDatePicker *datePicker= [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, kScreenWidth, 216)
                                                        Delegate:self
                                                     PickerStyle:UUDateStyle_YearMonthDayHourMinute];
    
    datePicker.ScrollToDate = now;
    datePicker.minLimitDate = now;
    datePicker.tag = 100;
    
    _leftTextField.inputView = datePicker;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftTextField.frame) + 5, 64 + 22, 30, 1)];
    
    line.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:line];
    
    _rightTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(line.frame) + 5, 74, (kScreenWidth - CGRectGetMaxX(dayTittle.frame) - 30 - 20) / 2, 24)];
    
    _rightTextField.backgroundColor = [UIColor whiteColor];
    _rightTextField.layer.borderWidth = 1;
    _rightTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _rightTextField.layer.masksToBounds = YES;
    _rightTextField.layer.cornerRadius = 3;
    _rightTextField.delegate = self;
    _rightTextField.tag = 200;
    _rightTextField.textColor = [UIColor darkGrayColor];
    _rightTextField.font = kSmallFont;
    _rightTextField.textAlignment = NSTextAlignmentCenter;

    
    [self.view addSubview:_rightTextField];
    
    UIButton *pickRight = [UIButton buttonWithType:UIButtonTypeCustom];
    
    pickRight.userInteractionEnabled = NO;
    pickRight.backgroundColor = kGrayColor;
    pickRight.frame = CGRectMake(0, 0, 24, 24);
    pickRight.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [pickRight setImage:[UIImage imageNamed:@"day_picker"] forState:UIControlStateNormal];
    
    pickRight.layer.borderWidth = 1;
    pickRight.layer.borderColor = [UIColor grayColor].CGColor;
    
    _rightTextField.rightView = pickRight;
    _rightTextField.rightViewMode = UITextFieldViewModeAlways;
    
    _datePicker= [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, kScreenWidth, 216)
                                                        Delegate:self
                                                     PickerStyle:UUDateStyle_YearMonthDayHourMinute];

    _datePicker.ScrollToDate = now;
    _datePicker.minLimitDate = now;
    _datePicker.tag = 200;
    
    _rightTextField.inputView = _datePicker;
    
    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 44, kScreenWidth, 100)];
    
    midView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:midView];
    
    _up = [UIButton buttonWithType:UIButtonTypeCustom];
    _up.frame = CGRectMake(0, 0, 90, 50);
    _up.contentEdgeInsets = UIEdgeInsetsMake(15, 20, 15, 50);
    [_up setImage:[UIImage imageNamed:@"promotion_unselected"] forState:UIControlStateNormal];
    [_up setImage:[UIImage imageNamed:@"promotion_selected"] forState:UIControlStateSelected];
    _up.selected = YES;
    _lastSelectedButton = _up;
    _up.tag = 100;
    [_up addTarget:self action:@selector(selectedWay:) forControlEvents:UIControlEventTouchUpInside];
    
    [midView addSubview:_up];
    
    UILabel *upLabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_up.frame) - 30, 0, 55, 50)];
    
    upLabelLeft.text = @"消费满";
    upLabelLeft.font = kFont;
    upLabelLeft.textColor = kLightBlackColor;
    
    [midView addSubview:upLabelLeft];
    
    _limitTextFieldUp = [[SaleTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(upLabelLeft.frame) + 10, 10, (kScreenWidth - CGRectGetMaxX(upLabelLeft.frame) - 20 - 60) / 2, 30)];
    
    _limitTextFieldUp.backgroundColor = [UIColor whiteColor];
    _limitTextFieldUp.layer.borderWidth = 1;
    _limitTextFieldUp.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _limitTextFieldUp.layer.masksToBounds = YES;
    _limitTextFieldUp.layer.cornerRadius = 3;
//    _limitTextFieldUp.placeholder = @"请输入金额";
    _limitTextFieldUp.delegate = self;
    _limitTextFieldUp.tag = 300;
    _limitTextFieldUp.keyboardType = UIKeyboardTypeDecimalPad;
    _limitTextFieldUp.textAlignment = NSTextAlignmentCenter;
    
    [midView addSubview:_limitTextFieldUp];
    
    UILabel *upLabelMid = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_limitTextFieldUp.frame), 0, 30, 50)];
    
    upLabelMid.textAlignment = NSTextAlignmentCenter;
    upLabelMid.textColor = kOrangeColor;
    upLabelMid.text = @"打";
    upLabelMid.font = kNormalFont;
    
    [midView addSubview:upLabelMid];
    
    _discountTextFieldUp = [[SaleTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(upLabelMid.frame), 10, (kScreenWidth - CGRectGetMaxX(upLabelLeft.frame) - 20 - 60) / 2, 30)];
    
    _discountTextFieldUp.backgroundColor = [UIColor whiteColor];
    _discountTextFieldUp.layer.borderWidth = 1;
    _discountTextFieldUp.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _discountTextFieldUp.layer.masksToBounds = YES;
    _discountTextFieldUp.layer.cornerRadius = 3;
    _discountTextFieldUp.delegate = self;
    _discountTextFieldUp.tag = 400;
    _discountTextFieldUp.keyboardType = UIKeyboardTypeDecimalPad;
    _discountTextFieldUp.textAlignment = NSTextAlignmentCenter;
    
    [midView addSubview:_discountTextFieldUp];
    
    UILabel *upLabelRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_discountTextFieldUp.frame), 0, 30, 50)];
    
    upLabelRight.textAlignment = NSTextAlignmentCenter;
    upLabelRight.text = @"折";
    upLabelRight.font = kNormalFont;
    upLabelRight.textColor = kLightBlackColor;
    
    [midView addSubview:upLabelRight];
    
    _down = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _down.frame = CGRectMake(0, 50, 90, 50);
    _down.contentEdgeInsets = UIEdgeInsetsMake(15, 20, 15, 50);
    [_down setImage:[UIImage imageNamed:@"promotion_unselected"] forState:UIControlStateNormal];
    [_down setImage:[UIImage imageNamed:@"promotion_selected"] forState:UIControlStateSelected];
    _down.tag = 200;
    [_down addTarget:self action:@selector(selectedWay:) forControlEvents:UIControlEventTouchUpInside];
    
    [midView addSubview:_down];
    
    UILabel *downLabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_down.frame) - 30, 50, 55, 50)];
    
    downLabelLeft.text = @"消费满";
    downLabelLeft.font = kFont;
    downLabelLeft.textColor = kLightBlackColor;
    
    [midView addSubview:downLabelLeft];
    
    _limitTextFieldDown = [[SaleTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(downLabelLeft.frame) + 10, 60, (kScreenWidth - CGRectGetMaxX(upLabelLeft.frame) - 20 - 60) / 2, 30)];
    
    _limitTextFieldDown.backgroundColor = [UIColor whiteColor];
    _limitTextFieldDown.layer.borderWidth = 1;
    _limitTextFieldDown.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _limitTextFieldDown.layer.masksToBounds = YES;
    _limitTextFieldDown.layer.cornerRadius = 3;
//    _limitTextFieldDown.placeholder = @"请输入金额";
    _limitTextFieldDown.delegate = self;
    _limitTextFieldDown.tag = 500;
    _limitTextFieldDown.keyboardType = UIKeyboardTypeDecimalPad;
    _limitTextFieldDown.textAlignment = NSTextAlignmentCenter;
    
    [midView addSubview:_limitTextFieldDown];
    
    UILabel *downLabelMid = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_limitTextFieldDown.frame), 50, 30, 50)];
    
    downLabelMid.textAlignment = NSTextAlignmentCenter;
    downLabelMid.textColor = kOrangeColor;
    downLabelMid.text = @"减";
    downLabelMid.font = kNormalFont;
    
    [midView addSubview:downLabelMid];
    
    _discountTextFieldDown = [[SaleTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(downLabelMid.frame), 60, (kScreenWidth - CGRectGetMaxX(upLabelLeft.frame) - 20 - 60) / 2, 30)];
    
    _discountTextFieldDown.backgroundColor = [UIColor whiteColor];
    _discountTextFieldDown.layer.borderWidth = 1;
    _discountTextFieldDown.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _discountTextFieldDown.layer.masksToBounds = YES;
    _discountTextFieldDown.layer.cornerRadius = 3;
    _discountTextFieldDown.delegate = self;
    _discountTextFieldDown.tag = 600;
    _discountTextFieldDown.keyboardType = UIKeyboardTypeDecimalPad;
    _discountTextFieldDown.textAlignment = NSTextAlignmentCenter;
    
    [midView addSubview:_discountTextFieldDown];
    
    UILabel *downLabelRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_discountTextFieldDown.frame), 50, 30, 50)];
    
    downLabelRight.textAlignment = NSTextAlignmentCenter;
    downLabelRight.text = @"元";
    downLabelRight.font = kNormalFont;
    downLabelRight.textColor = kLightBlackColor;
    
    [midView addSubview:downLabelRight];

    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _createButton.frame = CGRectMake(10, CGRectGetMaxY(midView.frame) + 20, kScreenWidth - 20, 40);
    [_createButton setBackgroundImage:[UIImage imageNamed:@"commit_order"] forState:UIControlStateNormal];
    [_createButton setTitle:@"创建" forState:UIControlStateNormal];
    [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _createButton.titleLabel.font = kFont;
    _createButton.layer.masksToBounds = YES;
    _createButton.layer.cornerRadius = 3;
    [_createButton addTarget:self action:@selector(createNewActivity) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_createButton];
}

- (void)pushToDetail
{
    LimitPreferentialDetailViewController *limitPreferentialDetail = [[LimitPreferentialDetailViewController alloc] init];
    
    [self.navigationController pushViewController:limitPreferentialDetail animated:YES];
}

- (void)createNewActivity
{
    YunLog(@"保存并提交被点击");
    // 上传商品组
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在创建...";
    
    
    if (_leftTextField.text == nil || [_leftTextField.text isEqualToString:@""]) {
        [_hud addErrorString:@"促销开始日期为空" delay:1.5];
        
        return;
    }
    
    if (_rightTextField.text == nil || [_rightTextField.text isEqualToString:@""]) {
        [_hud addErrorString:@"促销结束日期为空" delay:1.5];
        
        return;
    }
    
    if (_up.selected) {
        if (_limitTextFieldUp.text == nil || [_limitTextFieldUp.text isEqualToString:@""]) {
            [_hud addErrorString:@"促销金额为空" delay:1.5];
            
            return;
        }
        if (_discountTextFieldUp.text == nil || [_discountTextFieldUp.text isEqualToString:@""]) {
            [_hud addErrorString:@"促销折扣为空" delay:1.5];
            
            return;
        }
        if ([_discountTextFieldUp.text integerValue] <= 0 || [_discountTextFieldUp.text integerValue] >= 10) {
            [_hud addErrorString:@"促销折扣输入不符合要求" delay:1.5];
            
            return;
        }
    }
    
    if (_down.selected) {
        if (_limitTextFieldDown.text == nil || [_limitTextFieldDown.text isEqualToString:@""]) {
            [_hud addErrorString:@"促销金额为空" delay:1.5];
            
            return;
        }
        if (_discountTextFieldDown.text == nil || [_discountTextFieldDown.text isEqualToString:@""]) {
            [_hud addErrorString:@"促销折扣为空" delay:1.5];
            
            return;
        }
        
        if ([_limitTextFieldDown.text integerValue] < [_discountTextFieldDown.text integerValue]) {
            [_hud addErrorString:@"优惠金额不能超过促销金额" delay:1.5];
            
            return;
        }

    }
    
    NSMutableArray *promotionRules = [NSMutableArray array];
    
    NSDictionary *promotionAction = [NSDictionary dictionary];
    
    if (_lastSelectedButton == _up) {
        promotionAction = @{@"discount_percent"    :   kNullToString(_discountTextFieldUp.text)};
        NSDictionary *rule = @{@"entity_id"        :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                               @"entity_type"      :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"]),
                               @"condition_type"   :   @"ShopOrderAmount",
                               @"min_value"        :   kNullToString(_limitTextFieldUp.text),
                               @"promotion_action" :   promotionAction};
        [promotionRules addObject:rule];
    }
    
    if (_lastSelectedButton == _down) {
        promotionAction = @{@"discount_amount"    :    kNullToString(_discountTextFieldDown.text)};
        NSDictionary *rule = @{@"entity_id"        :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                               @"entity_type"      :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"]),
                               @"condition_type"   :   @"ShopOrderAmount",
                               @"min_value"        :   kNullToString(_limitTextFieldDown.text),
                               @"promotion_action" :   promotionAction};
        [promotionRules addObject:rule];
    }
    
//    NSArray *promotionRules = @[@{@"entity_id"        :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
//                                  @"entity_type"      :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"]),
//                                  @"condition_type"   :   @"ShopOrderAmount",
//                                  @"min_value"        :   _lastSelectedButton.tag == 100 ? kNullToString(_limitTextFieldUp.text) : kNullToString(_limitTextFieldDown.text),
//                                  @"promotion_action" :   promotionAction}];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
//    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    NSDate *minLimitDate = [inputFormatter dateFromString:_leftTextField.text];
    NSDate *maxLimitDate = [inputFormatter dateFromString:_rightTextField.text];
    
    NSDate *min = minLimitDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
    NSString *minString = [dateFormatter stringFromDate:min];
    NSLog(@"%@",minString);
    
    NSDate *max = maxLimitDate;
    NSDateFormatter *dateFormatterMax = [[NSDateFormatter alloc]init];
    [dateFormatterMax setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
    NSString *maxString = [dateFormatter stringFromDate:max];
    NSLog(@"%@",maxString);
    
    NSDictionary *promotionActivity = @{@"started_at"      :   minString,
                                        @"ended_at"        :   maxString,
                                        @"name"            :   _lastSelectedButton == _up ? [NSString stringWithFormat:@"消费满%@元打%@折",_limitTextFieldUp.text,_discountTextFieldUp.text] : [NSString stringWithFormat:@"消费满%@元减%@元",_limitTextFieldDown.text,_discountTextFieldDown.text],
                                        @"promotion_rules" :   promotionRules,
                                        @"shop_id"         :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"])};
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"promotion_activity"      :   promotionActivity};
    
    NSString *setFreightFreeURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAdminSaveActivities params:nil];
    
    YunLog(@"setFreightFreeURL = %@", setFreightFreeURL);
    YunLog(@"setFreightFreeParams = %@", params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:setFreightFreeURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"setFreightFree responseObject = %@", responseObject);
              if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
              {
                  [_hud addSuccessString:@"成功创建活动~" delay:2.0];

                  [[NSNotificationCenter defaultCenter] postNotificationName:@"createActivitySucceedDiscount" object:nil];
                  
                  [self createActivitySucceed];
              }
              else
              {
                  [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
              }
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
              YunLog(@"setFreightFreeURL - error = %@", error);
          }];
}

- (void)selectedWay:(UIButton *)sender
{
    if (sender != _lastSelectedButton) {
        sender.selected = YES;
        _lastSelectedButton.selected = NO;
        _lastSelectedButton = sender;
    } else {
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)pickTimerViewComeOut:(UIButton *)sender
{
    if (sender.tag == 100) {
        [self textFieldDidBeginEditing:_leftTextField];
    }
    else
    {
        [self textFieldDidBeginEditing:_rightTextField];
    }
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UUDatePicker's delegate -

- (void)uuDatePicker:(UUDatePicker *)datePicker year:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute weekDay:(NSString *)weekDay
{
    switch (datePicker.tag) {
        case 100:
        {
            _leftTextField.text = [NSString stringWithFormat:@"%@%@%@ %@:%@:00",year,month,day,hour,minute];
            
            NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
//            [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [inputFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
            NSDate *minLimitDate = [inputFormatter dateFromString:_leftTextField.text];
            
            _datePicker.ScrollToDate = minLimitDate;
            _datePicker.minLimitDate = minLimitDate;
            
            YunLog(@"minLimitDate - %@",minLimitDate);
        }
            break;
            
        case 200:
            _rightTextField.text = [NSString stringWithFormat:@"%@%@%@ %@:%@:00",year,month,day,hour,minute];
            break;
            
        default:
            break;
    }
}
@end
