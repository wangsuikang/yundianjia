//
//  AddressNewViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AddressNewViewController.h"

//Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "Tool.h"

// Views
#import "UIButtonForBarButton.h"
#import "LoginTextField.h"
#import "NoBorderTextField.h"

// Controllers
#import "ProvinceViewController.h"

// Libraries
#import "AFNetworking.h"

@interface AddressNewViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *zoneButton;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *phone;

@property (nonatomic, copy) NSString *addressString;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AddressNewViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.province && appDelegate.city && appDelegate.area) {
        UILabel *zoneLabel = (UILabel *)[_zoneButton viewWithTag:12345];
        
        if (![appDelegate.province isEqualToString:@""] && ![appDelegate.city isEqualToString:@""] && ![appDelegate.area isEqualToString:@""]) {
            zoneLabel.textColor = [UIColor orangeColor];
            zoneLabel.text = [NSString stringWithFormat:@"%@%@%@", appDelegate.province, appDelegate.city, appDelegate.area];
        }
        
        if ([appDelegate.province isEqualToString:@""] && [appDelegate.city isEqualToString:@""] && [appDelegate.area isEqualToString:@""]) {
            zoneLabel.textColor = [UIColor orangeColor];
            zoneLabel.text = @"";
        }
    }
    
    //    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    //    [TalkingData trackPageBegin:@"进入地址新增页面"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!_address) {
        AppDelegate *appDelegate = kAppDelegate;
        
        appDelegate.province = nil;
        appDelegate.city = nil;
        appDelegate.area = nil;
    }
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
    
    // 导航栏左边返回按钮
    //    UIButtonForBarButton *close = [[UIButtonForBarButton alloc] initWithTitle:@"关闭" wordLength:@"2"];
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame = CGRectMake(0, 0, 25, 25);
    [close setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(returnView) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:close];
    closeItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = closeItem;
    
    // 导航栏右边的完成、编辑按钮
    //    UIButtonForBarButton *done = [[UIButtonForBarButton alloc] initWithTitle:@"完成" wordLength:@"2"];
    UIButton *done = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [done setBackgroundColor:kClearColor];
    done.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    done.titleLabel.textAlignment = NSTextAlignmentCenter;
    [done addTarget:self action:@selector(commitAddress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:done];
    
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    
    if (!_address) {
        naviTitle.text = @"新增地址";
        
        _name = @"";
        _detail = @"";
        _phone = @"";
    } else {
        naviTitle.text = @"修改地址";
        
        _name = kNullToString([_address objectForKey:@"contact_name"]);
        _detail = kNullToString([_address objectForKey:@"address_detail"]);
        _phone = kNullToString([_address objectForKey:@"contact_phone"]);
        
        AppDelegate *appDelegate = kAppDelegate;
        
        appDelegate.province = kNullToString([_address objectForKey:@"address_province"]);
        appDelegate.city = kNullToString([_address objectForKey:@"address_city"]);
        appDelegate.area = kNullToString([_address objectForKey:@"address_area"]);
    }
    
    self.navigationItem.titleView = naviTitle;
    
    [self initLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)pushToProvince:(UIButton *)sender
{
    ProvinceViewController *province = [[ProvinceViewController alloc] init];
    province.hidesBottomBarWhenPushed = YES;
    
    if (_address) {
        province.addressEditing = YES;
    }
    
    [self.navigationController pushViewController:province animated:YES];
}

- (void)returnView
{
    //    if (_getDataIsYes) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressUpdate object:self];
    //        YunLog(@"hehe--- %d", _getDataIsYes);
    //
    //    }
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.province = nil;
    appDelegate.city = nil;
    appDelegate.area = nil;
    
    if (_hud) [_hud hide:NO];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initLayout
{
    int height = kCustomNaviHeight;
    
    for (int i = 0; i < 4; i++) {
        if (i == 1) {
            height += 48;
            
            continue;
        }
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 48)];
        container.backgroundColor = kClearColor;
        
        CALayer *bottomLine = [CALayer layer];
        bottomLine.frame = CGRectMake(0, container.frame.size.height - 1, container.frame.size.width, 1);
        bottomLine.backgroundColor = COLOR(188, 188, 188, 1).CGColor;
        
        [container.layer addSublayer:bottomLine];
        
        [self.view addSubview:container];
        
        // 左边标题
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 6, 36, 36)];
        leftLabel.text = @"姓名";
        leftLabel.font = kNormalFont;
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.textColor = [UIColor lightGrayColor];
        
        [container addSubview:leftLabel];
        
        // 右边输入框
        UITextField *rightTextField    = [[UITextField alloc] initWithFrame:CGRectMake(52, 0, kScreenWidth - 62, container.frame.size.height)];
        rightTextField.borderStyle     = UITextBorderStyleNone;
        rightTextField.font            = kNormalFont;
        rightTextField.delegate        = self;
        rightTextField.returnKeyType   = UIReturnKeyDone;
        rightTextField.backgroundColor = kClearColor;
        rightTextField.textColor       = [UIColor orangeColor];
        
        rightTextField.clearButtonMode          = UITextFieldViewModeWhileEditing;
        rightTextField.autocorrectionType       = UITextAutocorrectionTypeNo;
        rightTextField.autocapitalizationType   = UITextAutocapitalizationTypeNone;
        rightTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [rightTextField addTarget:self action:@selector(textFieldWithInput:) forControlEvents:UIControlEventEditingChanged];
        
        [container addSubview:rightTextField];
        
        switch (i) {
            case 0:
                leftLabel.text             = @"姓名";
                rightTextField.text        = _name;
                rightTextField.tag         = NameTextField;
                rightTextField.placeholder = @"请输入收货人名称";
                
                break;
                
            case 2:
                leftLabel.text             = @"街道";
                rightTextField.text        = _detail;
                rightTextField.tag         = StreetTextField;
                rightTextField.placeholder = @"请输入详细地址";
                
                break;
                
            case 3:
                leftLabel.text               = @"手机";
                rightTextField.text          = _phone;
                rightTextField.tag           = PhoneTextField;
                rightTextField.placeholder   = @"请输入手机号";
                rightTextField.keyboardType  = UIKeyboardTypeNumberPad;
                rightTextField.returnKeyType = UIReturnKeyDone;
                
                break;
                
            default:
                break;
        }
        
        if (i == 0) {
            double delayInSeconds   = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [rightTextField becomeFirstResponder];
            });
        }
        
        height += 48;
    }
    
    _zoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight + 48, kScreenWidth, 48)];
    _zoneButton.backgroundColor = kClearColor;
    [_zoneButton addTarget:self action:@selector(pushToProvince:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_zoneButton];
    
    UILabel *zoneLeftLabel            = [[UILabel alloc] initWithFrame:CGRectMake(6, 6, 36, 36)];
    zoneLeftLabel.text                = @"地区";
    zoneLeftLabel.textColor           = [UIColor lightGrayColor];
    zoneLeftLabel.font                = kNormalFont;
    zoneLeftLabel.textAlignment       = NSTextAlignmentCenter;
    zoneLeftLabel.layer.cornerRadius  = 6;
    zoneLeftLabel.layer.masksToBounds = YES;
    
    [_zoneButton addSubview:zoneLeftLabel];
    
    UILabel *zoneRightLabel        = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, kScreenWidth - 52 - 26, 48)];
    zoneRightLabel.backgroundColor = kClearColor;
    zoneRightLabel.textColor       = COLOR(191, 191, 197, 1);
    zoneRightLabel.font            = kNormalFont;
    zoneRightLabel.tag             = 12345;
    zoneRightLabel.text            = @"点击选择省市区";
    
    [_zoneButton addSubview:zoneRightLabel];
    
    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(_zoneButton.frame.size.width - 26, 16, 16, 16)];
    rightArrow.image        = [UIImage imageNamed:@"right_arrow_16"];
    
    [_zoneButton addSubview:rightArrow];
    
    CALayer *bottomLine        = [CALayer layer];
    bottomLine.frame           = CGRectMake(0, _zoneButton.frame.size.height - 1, _zoneButton.frame.size.width, 1);
    bottomLine.backgroundColor = COLOR(188, 188, 188, 1).CGColor;
    
    [_zoneButton.layer addSublayer:bottomLine];
    
    /*
     //    // 姓名
     //    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
     //    nameLabel.text = @"姓名";
     //    nameLabel.font = kNormalFont;
     //    nameLabel.textAlignment = NSTextAlignmentCenter;
     //    nameLabel.textColor = [UIColor lightGrayColor];
     //
     //    NoBorderTextField *nameTextField = [[NoBorderTextField alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 48)];
     //    nameTextField.backgroundColor = [UIColor purpleColor];
     //    nameTextField.leftView = nameLabel;
     //    nameTextField.font = kNormalFont;
     //    nameTextField.text = _name;
     //    nameTextField.tag = NameTextField;
     //    nameTextField.delegate = self;
     //    nameTextField.placeholder = @"请输入收货人名称";
     //    nameTextField.returnKeyType = UIReturnKeyDone;
     //    [nameTextField addTarget:self action:@selector(textFieldWithInput:) forControlEvents:UIControlEventEditingChanged];
     //
     //    [self.view addSubview:nameTextField];
     //
     //    double delayInSeconds = 0.1;
     //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
     //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     //        [nameTextField becomeFirstResponder];
     //    });
     //
     //    // 省市区
     //    _zoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, nameTextField.frame.origin.y + nameTextField.frame.size.height, kScreenWidth, 48)];
     //    _zoneButton.backgroundColor = kClearColor;
     //    [_zoneButton addTarget:self action:@selector(pushToProvince:) forControlEvents:UIControlEventTouchUpInside];
     //
     //    [self.view addSubview:_zoneButton];
     //
     //    UILabel *zoneLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 6, 36, 36)];
     //    zoneLeftLabel.text = @"地区";
     //    zoneLeftLabel.textColor = [UIColor lightGrayColor];
     //    zoneLeftLabel.font = kNormalFont;
     //    zoneLeftLabel.textAlignment = NSTextAlignmentCenter;
     //    zoneLeftLabel.layer.cornerRadius = 6;
     //    zoneLeftLabel.layer.masksToBounds = YES;
     //
     //    [_zoneButton addSubview:zoneLeftLabel];
     //
     //    UILabel *zoneRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, kScreenWidth - 52 - 26, 48)];
     //    zoneRightLabel.backgroundColor = kClearColor;
     //    zoneRightLabel.textColor = COLOR(191, 191, 197, 1);
     //    zoneRightLabel.font = kNormalFont;
     //    zoneRightLabel.tag = 12345;
     //    zoneRightLabel.text = @"点击选择省市区";
     //
     //    [_zoneButton addSubview:zoneRightLabel];
     //
     //    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(_zoneButton.frame.size.width - 26, 16, 16, 16)];
     //    rightArrow.image = [UIImage imageNamed:@"right_arrow_16"];
     //
     //    [_zoneButton addSubview:rightArrow];
     //
     //    CALayer *bottomLine = [CALayer layer];
     //    bottomLine.frame = CGRectMake(0, _zoneButton.frame.size.height - 1, _zoneButton.frame.size.width, 1);
     //    bottomLine.backgroundColor = COLOR(188, 188, 188, 1).CGColor;
     //
     //    [_zoneButton.layer addSublayer:bottomLine];
     //
     //    // 详细地址
     //    UILabel *streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
     //    streetLabel.text = @"街道";
     //    streetLabel.font = kNormalFont;
     //    streetLabel.textColor = [UIColor lightGrayColor];
     //    streetLabel.textAlignment = NSTextAlignmentCenter;
     //
     //    NoBorderTextField *streetTextField = [[NoBorderTextField alloc] initWithFrame:CGRectMake(0, _zoneButton.frame.origin.y + _zoneButton.frame.size.height, kScreenWidth, 48)];
     //    streetTextField.leftView = streetLabel;
     //    streetTextField.tag = StreetTextField;
     //    streetTextField.delegate = self;
     //    streetTextField.text = _detail;
     //    streetTextField.font = kNormalFont;
     //    streetTextField.placeholder = @"请输入街道地址";
     //    streetTextField.returnKeyType = UIReturnKeyDone;
     //    [streetTextField addTarget:self action:@selector(textFieldWithInput:) forControlEvents:UIControlEventEditingChanged];
     //
     //    [self.view addSubview:streetTextField];
     //
     //    // 手机
     //    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
     //    phoneLabel.text = @"手机";
     //    phoneLabel.font = kNormalFont;
     //    phoneLabel.textAlignment = NSTextAlignmentCenter;
     //    phoneLabel.textColor = [UIColor lightGrayColor];
     //
     //    NoBorderTextField *phoneTextField = [[NoBorderTextField alloc] initWithFrame:CGRectMake(0, streetTextField.frame.origin.y + streetTextField.frame.size.height, kScreenWidth, 48)];
     //    phoneTextField.leftView = phoneLabel;
     //    phoneTextField.tag = PhoneTextField;
     //    phoneTextField.delegate = self;
     //    phoneTextField.text = _phone;
     //    phoneTextField.placeholder = @"请输入手机号";
     //    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
     //    phoneTextField.returnKeyType = UIReturnKeyDone;
     //    phoneTextField.font = kNormalFont;
     //    [phoneTextField addTarget:self action:@selector(textFieldWithInput:) forControlEvents:UIControlEventEditingChanged];
     //
     //    [self.view addSubview:phoneTextField];
     */
    
}

- (void)textFieldWithInput:(UITextField *)textField
{
    switch (textField.tag) {
        case NameTextField:
            _name = textField.text;
            
            break;
            
        case StreetTextField:
            _detail = textField.text;
            
            break;
            
        case PhoneTextField:
            _phone = textField.text;
            
            break;
            
        default:
            break;
    }
    
    YunLog(@"textFiled.text = %@", textField.text);
}

- (void)commitAddress:(UIButton *)sender
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力添加中...";
    
    [self doneButton:nil];
    
    if ([_name isEqualToString:@""]) {
        [_hud addErrorString:@"姓名不得为空" delay:1.0];
        
        return;
    }
    
    if ([_detail isEqualToString:@""]) {
        [_hud addErrorString:@"街道不得为空" delay:1.0];
        
        return;
    }
    
    NSString *regexString = @"(^1(3[5-9]|47|5[012789]|8[23478])\\d{8}$|134[0-8]\\d{7}$)|(^18[019]\\d{8}$|1349\\d{7}$)|(^1(3[0-2]|45|5[56]|8[56])\\d{8}$)|(^1[35]3\\d{8}$)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    
    NSTextCheckingResult *result = [regex firstMatchInString:_phone options:0 range:NSMakeRange(0, [_phone length])];
    
    if (!result) {
        [_hud addErrorString:@"请输入正确的手机号" delay:1.0];
        
        return;
    }
    
    YunLog(@"_name = %@", _name);
    YunLog(@"_detail = %@", _detail);
    YunLog(@"_phone = %@", _phone);
    
    YunLog(@"contact_name = %@", _address[@"contact_name"]);
    YunLog(@"contact_detail = %@", _address[@"contact_detail"]);
    YunLog(@"contact_phone = %@", _address[@"contact_phone"]);
    
    // 判断姓名，街道，手机号码是否有改动,如果没有改动字直接调用返回的方法
//    if (_name == _address[@"contact_name"] && _detail == _address[@"address_detail"] && _phone == _address[@"contact_phone"])
//    {
//        [self returnView];
//        
//        return;
//    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if ([appDelegate.province isEqualToString:@""]) {
        [_hud addErrorString:@"请选择省市区" delay:1.0];
        
        return;
    }
    
    sender.enabled = NO;
    
//    if (!_hud)
//    {
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        
//    }
    
    NSString *requestURL;
    if (!_address) {
        requestURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kAddressAddURL params:nil];
    } else {
        requestURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kAddressModifyURL params:nil];
    }
    
    YunLog(@"procince_name = %@, id = %@", appDelegate.province, appDelegate.address_province_no);
    YunLog(@"city_name = %@, id = %@", appDelegate.city, appDelegate.address_city_no);
    YunLog(@"area_name = %@, id = %@", appDelegate.area, appDelegate.address_area_no);
    
    NSDictionary *temp = @{@"contact_name"            :   kNullToString(_name),
                           @"contact_phone"           :   kNullToString(_phone),
                           @"address_province"        :   kNullToString(appDelegate.province),
                           @"address_city"            :   kNullToString(appDelegate.city),
                           @"address_area"            :   kNullToString(appDelegate.area),
                           @"address_province_no"     :   kNullToString(appDelegate.address_province_no),
                           @"address_city_no"         :   kNullToString(appDelegate.address_city_no),
                           @"address_area_no"         :   kNullToString(appDelegate.address_area_no),
                           @"address_detail"          :   kNullToString(_detail)};
    
    YunLog(@"address requestURL = %@", requestURL);
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:temp];
    
    if (_address)
    {
        [data setObject:kNullToString([_address objectForKey:@"id"]) forKey:@"id"];
    }
    
    YunLog(@"data addressNew person = %@", data);
    
    NSDictionary *params;
    
    @try {
        params = @{@"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey),
                   @"user_session_key"      :   kNullToString(appDelegate.user.userSessionKey),
                   @"intf_revision"         :   kIntfRevision,
                   @"app_revision"          :   kAppVersion,
                   @"platform"              :   @"iphone",
                   @"json_data"             :   @{@"data"   :   data}};
    }
    @catch (NSException *exception) {
        YunLog(@"commit address params exception = %@", exception);
        
        params = @{};
    }
    @finally {
        
    }
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:requestURL
                                                                                parameters:params
                                                                                     error:nil];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"address new/edit responseObject = %@", responseObject);
        
        appDelegate.province = @"";
        appDelegate.city = @"";
        appDelegate.area = @"";
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            [_hud addSuccessString:@"添加成功" delay:1.0];
            
            [appDelegate.user addAddress:[[responseObject objectForKey:@"data"] objectForKey:@"address"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddressUpdate object:self];
            
            [self returnView];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self returnView];
        } else {
            [_hud addErrorString:@"网络异常，请稍后再试" delay:1.0];
            
            sender.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常，请稍后再试" delay:1.0];
        
        sender.enabled = YES;
        
        YunLog(@"address new/edit error = %@", error);
    }];
    
    [op start];
}

- (void)keyboardWillShowForNumberPad:(NSNotification *)noti
{
    [self keyboardWillShow:noti];
    
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

- (void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    
    // 找到键盘view
    UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    
    UIView *keyboard;
    
    for (int i = 0; i < [tempWindow.subviews count]; i++){
        keyboard = [tempWindow.subviews objectAtIndex:i];
        
        // 找到键盘view并加入“Done”按钮
        if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES || ([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)) {
            UIButton *button = (UIButton *)[keyboard viewWithTag:100];
            [button removeFromSuperview];
            
            break;
        }
    }
}

- (void)doneButton:(UIButton *)sender
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSDictionary* userInfo = [noti userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
}

#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    if (textField.tag == StreetTextField || textField.tag == PhoneTextField) {
        self.view.frame = CGRectMake(0, -50, kScreenWidth, kScreenHeight + 50);
    }
    
    [UIView commitAnimations];
    //    if (textField.tag == NameTextField) {
    //        [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    } else if (textField.tag == StreetTextField) {
    //        [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    //        [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                 selector:@selector(keyboardWillShow:)
    //                                                     name:UIKeyboardWillShowNotification
    //                                                   object:nil];
    //
    //        [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                 selector:@selector(keyboardWillHide:)
    //                                                     name:UIKeyboardWillHideNotification
    //                                                   object:nil];
    //
    //        if (kDeviceOSVersion >= 5.0) {
    //            [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                     selector:@selector(keyboardWillShow:)
    //                                                         name:UIKeyboardWillChangeFrameNotification
    //                                                       object:nil];
    //        }
    //    } else if (textField.tag == PhoneTextField) {
    //        [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                 selector:@selector(keyboardWillShowForNumberPad:)
    //                                                     name:UIKeyboardWillShowNotification
    //                                                   object:nil];
    //
    //        [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                 selector:@selector(keyboardWillHide:)
    //                                                     name:UIKeyboardWillHideNotification
    //                                                   object:nil];
    //
    //        if (kDeviceOSVersion >= 5.0) {
    //            [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                     selector:@selector(keyboardWillShowForNumberPad:)
    //                                                         name:UIKeyboardWillChangeFrameNotification
    //                                                       object:nil];
    //        }
    //    }
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    
    NSString *aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == PhoneTextField) {
        if ([aString length] > 11) {
            return NO;
        }
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
