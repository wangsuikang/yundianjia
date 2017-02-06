//
//  SettingFreeViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/9/1.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "SettingFreeViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "SettingFreeDetailViewController.h"

#import "UUDatePicker.h"
#import "SaleTextField.h"
#import "AppDelegate.h"

@interface SettingFreeViewController () <UITextFieldDelegate, UUDatePickerDelegate>
/// 左边时间选择器
@property (nonatomic ,strong) UITextField *leftTextField;

/// 右边时间选择器
@property (nonatomic ,strong) UITextField *rightTextField;

/// 填写金额
@property (nonatomic ,strong) SaleTextField *limitTextField;

/// 当前选中的按钮
@property (nonatomic ,strong) UIButton *lastSelectedButton;

/// datePicker
@property (nonatomic, strong) UUDatePicker *datePicker;

/// 第三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 创建按钮
@property (nonatomic ,strong) UIButton *createButton;
@end

@implementation SettingFreeViewController

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
        naviTitle.text = @"包邮设置";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteActivitySucceed) name:@"deleteActivitySucceedFreight" object:nil];
    
    self.view.backgroundColor = kGrayColor;
    
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
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, kScreenWidth, 100)];
    
    topView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:topView];
    
    UILabel *tittle = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth - 20, 30)];
    
    tittle.text = @"满包邮活动规则";
    tittle.textColor = kLightBlackColor;
    tittle.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    
    [topView addSubview:tittle];
    
    UIView *maclaOneView = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tittle.frame) + 20, 5, 5)];
    maclaOneView.backgroundColor = kLightBlackColor;
    maclaOneView.layer.masksToBounds = YES;
    maclaOneView.layer.cornerRadius = maclaOneView.bounds.size.width / 2;
    
    [topView addSubview:maclaOneView];
    
    NSString *explan = @"买家消费满足你设置的金额，则订单包邮";
    CGSize size = [explan sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20 - CGRectGetMaxX(maclaOneView.frame) - 10, 9999)];

    UILabel *explanation = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(maclaOneView.frame) + 10, CGRectGetMaxY(tittle.frame) + 12, size.width, size.height)];
    
    explanation.text = explan;
    explanation.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    explanation.textColor = [UIColor darkGrayColor];
    explanation.numberOfLines = 0;
    
    [topView addSubview:explanation];
    
    UILabel *dayTittle = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(topView.frame), 70, 44)];
    
    dayTittle.text = @"包邮日期：";
    dayTittle.font = kMidBoldFont;
    dayTittle.textColor = kLightBlackColor;
    
    [self.view addSubview:dayTittle];
    
    _leftTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dayTittle.frame), CGRectGetMaxY(topView.frame) + 10, (kScreenWidth - CGRectGetMaxX(dayTittle.frame) - 30- 20) / 2, 24)];
    
    _leftTextField.backgroundColor = [UIColor whiteColor];
    _leftTextField.layer.borderWidth = 0.5;
    _leftTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _leftTextField.layer.masksToBounds = YES;
    _leftTextField.layer.cornerRadius = 3;
    _leftTextField.delegate = self;
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
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftTextField.frame) + 5, CGRectGetMaxY(topView.frame) + 22, 30, 1)];
    
    line.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:line];
    
    _rightTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(line.frame) + 5, CGRectGetMaxY(topView.frame) + 10, (kScreenWidth - CGRectGetMaxX(dayTittle.frame) - 30 - 20) / 2, 24)];
    
    _rightTextField.backgroundColor = [UIColor whiteColor];
    _rightTextField.layer.borderWidth = 1;
    _rightTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _rightTextField.layer.masksToBounds = YES;
    _rightTextField.layer.cornerRadius = 3;
    _rightTextField.delegate = self;
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

    
    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 44, kScreenWidth, 100)];
    
    midView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:midView];
    
    UIButton *allFree = [UIButton buttonWithType:UIButtonTypeCustom];
    
    allFree.frame = CGRectMake(0, 0, 90, 50);
    allFree.contentEdgeInsets = UIEdgeInsetsMake(15, 20, 15, 50);
    [allFree setImage:[UIImage imageNamed:@"promotion_unselected"] forState:UIControlStateNormal];
    [allFree setImage:[UIImage imageNamed:@"promotion_selected"] forState:UIControlStateSelected];
    allFree.selected = YES;
    _lastSelectedButton = allFree;
    allFree.tag = 100;
    [allFree addTarget:self action:@selector(selectedWay:) forControlEvents:UIControlEventTouchUpInside];
    
    [midView addSubview:allFree];
    
    UILabel *allFreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(allFree.frame) - 30, 0, kScreenWidth - CGRectGetMaxX(allFree.frame) - 10, 50)];
    
    allFreeLabel.text = @"全场包邮";
    allFreeLabel.font = kFont;
    allFreeLabel.textColor = kLightBlackColor;
    
    [midView addSubview:allFreeLabel];
    
    UIButton *limitFree = [UIButton buttonWithType:UIButtonTypeCustom];
    
    limitFree.frame = CGRectMake(0, 50, 90, 50);
    limitFree.contentEdgeInsets = UIEdgeInsetsMake(15, 20, 15, 50);
    [limitFree setImage:[UIImage imageNamed:@"promotion_unselected"] forState:UIControlStateNormal];
    [limitFree setImage:[UIImage imageNamed:@"promotion_selected"] forState:UIControlStateSelected];
    limitFree.tag = 200;
    [limitFree addTarget:self action:@selector(selectedWay:) forControlEvents:UIControlEventTouchUpInside];

    [midView addSubview:limitFree];
    
    UILabel *limitFreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(limitFree.frame) - 30, 50, 90, 50)];
    
    limitFreeLabel.text = @"消费满包邮";
    limitFreeLabel.font = kFont;
    limitFreeLabel.textColor = kLightBlackColor;
    
    [midView addSubview:limitFreeLabel];
    
    _limitTextField = [[SaleTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(limitFreeLabel.frame) + 10, 60, 100, 30)];
    
    _limitTextField.backgroundColor = [UIColor whiteColor];
    _limitTextField.layer.borderWidth = 1;
    _limitTextField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _limitTextField.layer.masksToBounds = YES;
    _limitTextField.layer.cornerRadius = 3;
//    _limitTextField.placeholder = @"请输入金额";
    _limitTextField.delegate = self;
    _limitTextField.tag = 100;
    _limitTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _limitTextField.textAlignment = NSTextAlignmentCenter;
     
    [midView addSubview:_limitTextField];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_limitTextField.frame) + 10, 50, 30, 50)];
    
    moneyLabel.text = @"元";
    moneyLabel.font = kFont;
    moneyLabel.textColor = kLightBlackColor;
    
    [midView addSubview:moneyLabel];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(midView.frame) + 10, kScreenWidth, kScreenHeight - CGRectGetMaxY(midView.frame) - 10)];
    
    bottomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:bottomView];
    
    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _createButton.frame = CGRectMake(10, 20, kScreenWidth - 20, 40);
    [_createButton setBackgroundImage:[UIImage imageNamed:@"commit_order"] forState:UIControlStateNormal];
    [_createButton setTitle:@"创建" forState:UIControlStateNormal];
    [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _createButton.titleLabel.font = kFont;
    _createButton.layer.masksToBounds = YES;
    _createButton.layer.cornerRadius = 3;
    [_createButton addTarget:self action:@selector(createNewActivity) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:_createButton];
    
}

- (void)pushToDetail
{
    SettingFreeDetailViewController *settingFreeDetail = [[SettingFreeDetailViewController alloc] init];
    
    [self.navigationController pushViewController:settingFreeDetail animated:YES];
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
        [_hud addErrorString:@"包邮开始日期为空" delay:1.5];
        
        return;
    }
   
    if (_rightTextField.text == nil || [_rightTextField.text isEqualToString:@""]) {
        [_hud addErrorString:@"包邮结束日期为空" delay:1.5];
        
        return;
    }
    
    if (_lastSelectedButton.tag == 200) {
        if (_limitTextField.text == nil || [_limitTextField.text isEqualToString:@""]) {
            [_hud addErrorString:@"包邮金额为空" delay:1.5];
            
            return;
        }
    }
    
    NSDictionary *promotionAction = @{@"freight_type"   :    @"free"};
    
    NSArray *promotionRules = @[@{@"entity_id"        :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                                  @"entity_type"      :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopType"]),
                                  @"condition_type"   :   @"ShopOrderAmount",
                                  @"min_value"        :   _lastSelectedButton.tag == 200 ? kNullToString(_limitTextField.text) : @"0",
                                  @"promotion_action" :   promotionAction}];
    
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
                                        @"name"            :   _lastSelectedButton.tag == 100 ? @"全场包邮" : [NSString stringWithFormat:@"全场满%@包邮",kNullToString(_limitTextField.text)],
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
                
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"createActivitySucceedFreight" object:nil];
                   
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
    _lastSelectedButton.selected = NO;
    _lastSelectedButton = sender;
    _lastSelectedButton.selected = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    YunLog(@"点击点击点击");
    
    [self.view endEditing:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [UIView commitAnimations];
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    if (textField.tag == 100) {
        self.view.frame = CGRectMake(0, -100, kScreenWidth, kScreenHeight + 100);
    }
    
    [UIView commitAnimations];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [UIView commitAnimations];
    
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
//            [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
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
