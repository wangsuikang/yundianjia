//
//  AdminOrderOperationViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-4-2.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "AdminOrderOperationViewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Classes
#import "OrderManager.h"

// Controllers
#import "QRCodeByNatureViewController.h"

@interface AdminOrderOperationViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *companies;
@property (nonatomic, copy) NSString *companyCode;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *expressNumber;

@property (nonatomic, strong) UILabel *companyText;
@property (nonatomic, strong) UITextField *numberTextField;
@property (nonatomic, strong) UIButton *save;
@property (nonatomic, strong) UIView *pickerToolView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AdminOrderOperationViewController

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
        naviTitle.text = @"发货";
        
        self.navigationItem.titleView = naviTitle;
        
        _companyCode = @"";
        _companyName = @"";
        _expressNumber = @"";
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    NSString *number = kNullToString([[OrderManager defaultManager] infoForKey:@"expressNumber"]);
    
    if (![number isEqualToString:@""]) {
        _expressNumber = number;
        _numberTextField.text = number;
        
        [[OrderManager defaultManager] clearInfo];
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;

    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};

    NSString *companyURL = [Tool buildRequestURLHost:kRequestHost
                                          APIVersion:kAPIVersion1
                                          requestURL:kOrderExpressCompanyURL
                                              params:params];
    
    YunLog(@"express company url = %@", companyURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:companyURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"express company responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 _companies = [[responseObject objectForKey:@"data"] objectForKey:@"express_companies"];
                 
                 [self initLayout];

                 [_hud hide:YES];
                 
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
                 
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"get express company error = %@", error);
             
             if (![operation isCancelled]) {
                 [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
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
    _pickerView.delegate = nil;
    _numberTextField.delegate = nil;
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initLayout
{
    int height = kCustomNaviHeight;
    
    // 公司
    UIButton *companyContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 40)];
    companyContainer.backgroundColor = COLOR(245, 245, 245, 1);
    
    [self.view addSubview:companyContainer];
    
    height += companyContainer.frame.size.height;

    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 36)];
    companyLabel.backgroundColor = kClearColor;
    companyLabel.font = kNormalFont;
    companyLabel.text = @"快递公司";
    
    [companyContainer addSubview:companyLabel];

    UIButton *companyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 44)];
    companyButton.backgroundColor = kClearColor;
    [companyButton addTarget:self action:@selector(openCompanies) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:companyButton];
    
    height += companyButton.frame.size.height;
    
    CALayer *companyBottomLayer = [CALayer layer];
    companyBottomLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    companyBottomLayer.frame = CGRectMake(0, 43, kScreenWidth, 1);
    
    [companyButton.layer addSublayer:companyBottomLayer];
    
    _companyText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 26, 44)];
    _companyText.backgroundColor = kClearColor;
    _companyText.font = kNormalFont;
    _companyText.text = @"请选择快递公司";
    _companyText.textColor = COLOR(191, 191, 191, 1); //[UIColor lightGrayColor];
    
    [companyButton addSubview:_companyText];
    
    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 26, 14, 16, 16)];
    rightArrow.image = [UIImage imageNamed:@"right_arrow_16"];
    
    [companyButton addSubview:rightArrow];
    
    height += 20;
    
    // 单号
    UIButton *numberContainer = [[UIButton alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 40)];
    numberContainer.backgroundColor = COLOR(245, 245, 245, 1);
    
    [self.view addSubview:numberContainer];
    
    height += numberContainer.frame.size.height;
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 36)];
    numberLabel.backgroundColor = kClearColor;
    numberLabel.font = kNormalFont;
    numberLabel.text = @"快递单号";
    
    [numberContainer addSubview:numberLabel];
    
    _numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, height, kScreenWidth - 50, 44)];
    _numberTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _numberTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _numberTextField.keyboardType = UIKeyboardTypeDefault;
    _numberTextField.returnKeyType = UIReturnKeyDone;
    _numberTextField.placeholder = @"请输入快递单号";
    _numberTextField.text = @"";
    _numberTextField.textColor = [UIColor orangeColor];
    _numberTextField.font = kNormalFont;
    _numberTextField.delegate = self;
    [_numberTextField addTarget:self action:@selector(textFieldWithInput:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:_numberTextField];
    
    UIButton *sao = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 40, height + 7, 30, 30)];
    [sao setImage:[UIImage imageNamed:@"sao_30"] forState:UIControlStateNormal];
    [sao addTarget:self action:@selector(pushToQRCode) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sao];
    
    height += _numberTextField.frame.size.height;
    
    CALayer *numberBottomLayer = [CALayer layer];
    numberBottomLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    numberBottomLayer.frame = CGRectMake(0, height - 1, kScreenWidth, 1);
    
    [self.view.layer addSublayer:numberBottomLayer];
    
    _save = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - 48, kScreenWidth, 48)];
    _save.backgroundColor = [UIColor orangeColor];
    [_save setTitle:@"保存" forState:UIControlStateNormal];
    [_save addTarget:self action:@selector(commitExress:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_save];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 216)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.backgroundColor = COLOR(232, 232, 232, 1);
    
    [self.view addSubview:_pickerView];
}

- (void)openCompanies
{
    [_numberTextField resignFirstResponder];
    
    _save.hidden = YES;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         _pickerView.frame = CGRectMake(0, kScreenHeight - 216, kScreenWidth, 216);
                     }
                     completion:^(BOOL finished) {
                         if (!_pickerToolView) {
                             _pickerToolView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 216 - 44, kScreenWidth, 44)];
                             _pickerToolView.backgroundColor = [UIColor orangeColor];
                             
                             [self.view addSubview:_pickerToolView];
                             
                             UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 0, 60, 44)];
                             button.backgroundColor = kClearColor;
                             [button setTitle:@"确定" forState:UIControlStateNormal];
                             [button addTarget:self action:@selector(confirmPicker) forControlEvents:UIControlEventTouchUpInside];
                             
                             [_pickerToolView addSubview:button];
                         } else {
                             _pickerToolView.hidden = NO;
                         }
                     }];
}

- (void)confirmPicker
{
    _pickerToolView.hidden = YES;
    
    NSInteger selectedRow = [_pickerView selectedRowInComponent:0];
    
    _companyText.text = kNullToString([_companies[selectedRow] objectForKey:@"name"]);
    _companyText.textColor = [UIColor orangeColor];
    
    _companyCode = kNullToString([_companies[selectedRow] objectForKey:@"code"]);
    _companyName = kNullToString([_companies[selectedRow] objectForKey:@"name"]);
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         _pickerView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 216);
                     }
                     completion:^(BOOL finished) {
                         _save.hidden = NO;
                         
                         if ([_companyCode isEqualToString:@"others"]) {
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入快递公司名称"
                                                                                 message:nil
                                                                                delegate:self
                                                                       cancelButtonTitle:@"取消"
                                                                       otherButtonTitles:@"确定", nil];
                             alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                             [alertView show];
                             
//                             [[NSNotificationCenter defaultCenter] removeObserver:self];
//                             
//                             [self keyboardWillRemoveForLoginNumberPad];
                         }
                         
                         if ([_companyCode isEqualToString:@"self"]) {
                             _expressNumber = @"";
                             _numberTextField.text = @"";
                             _numberTextField.enabled = NO;
                         } else {
                             _numberTextField.enabled = YES;
                         }
                     }];
}

- (void)textFieldWithInput:(UITextField *)textField
{
    _expressNumber = textField.text;
}

- (void)commitExress:(UIButton *)sender
{
    YunLog(@"_companyCode = %@, _companyName = %@, _expressNumber = %@", _companyCode, _companyName, _expressNumber);
    
    if ([_companyCode isEqualToString:@""]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请选择快递" delay:2.0];
        
        return;
    }
    
    if (![_companyCode isEqualToString:@"self"] && [_expressNumber isEqualToString:@""]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请输入快递单号" delay:2.0];
        
        return;
    }
    
    sender.enabled = NO;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"发货中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"express_company_code"    :   kNullToString(_companyCode),
                             @"express_company_name"    :   kNullToString(_companyName),
                             @"express_no"              :   kNullToString(_expressNumber),
                             @"oid"                     :   kNullToString(_oid)};

    NSString *expressURL = [Tool buildRequestURLHost:kRequestHost
                                          APIVersion:kAPIVersion1
                                          requestURL:kOrderSetExpressURL
                                              params:params];
    
    YunLog(@"expressURL = %@", expressURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:expressURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"set express responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 [_hud addSuccessString:@"发货成功" delay:2.0];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"setExpressSucceed" object:nil];
                 
                 [self backToPrev];
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"set express error = %@", error);
             
             if (![operation isCancelled]) {
                 [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             }
         }];
}

- (void)pushToQRCode
{
    QRCodeByNatureViewController *qrcode = [[QRCodeByNatureViewController alloc] init];
    qrcode.useType = QRCodeExpress;
    qrcode.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:qrcode animated:YES];
    
//    QRCodeByZBarViewController *qrcode = [[QRCodeByZBarViewController alloc] init];
//    qrcode.useType = QRCodeExpress;
//    qrcode.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:qrcode animated:YES];
}

- (void)keyboardWillShowForLoginNumberPad
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // 创建“Done”按钮
        if (_doneButton) {
            [_doneButton removeFromSuperview];
            _doneButton = nil;
        }
        
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _doneButton.adjustsImageWhenHighlighted = NO;
        
        if (kDeviceOSVersion >= 7.0) {
            _doneButton.frame = CGRectMake(0, 163, 104, 53);
            _doneButton.backgroundColor = COLOR(187, 190, 195, 1);
            [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
            [_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {
            _doneButton.frame = CGRectMake(0, 163, 104, 53);
            [_doneButton setImage:[UIImage imageNamed:@"doneup"] forState:UIControlStateNormal];
            [_doneButton setImage:[UIImage imageNamed:@"donedown"] forState:UIControlStateHighlighted];
        }
        
        [_doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 找到键盘view
        UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        
        UIView *keyboard;
        
        for (int i = 0; i < [tempWindow.subviews count]; i++){
            keyboard = [tempWindow.subviews objectAtIndex:i];
            
            // 找到键盘view并加入“Done”按钮
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES || ([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)) {
                [keyboard addSubview:_doneButton];
                
                break;
            }
        }
    });
}

- (void)keyboardWillRemoveForLoginNumberPad
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_doneButton removeFromSuperview];
        _doneButton = nil;
    });
}

- (void)doneButton:(UIButton *)sender
{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self keyboardWillRemoveForLoginNumberPad];
}

#pragma mark - UITextFieldDelegate - 

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShowForLoginNumberPad)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [self keyboardWillShowForLoginNumberPad];
    
//    switch (textField.tag) {
//        case LoginName:
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(keyboardWillShowForLoginNumberPad)
//                                                         name:UIKeyboardWillShowNotification
//                                                       object:nil];
//            
//            [self keyboardWillShowForLoginNumberPad];
//            
//            break;
//            
//        case LoginPhone:
//            [[NSNotificationCenter defaultCenter] removeObserver:self];
//            
//            [self keyboardWillShowForLoginNumberPad];
//            
//            break;
//            
//        case LoginVerifyCode:
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(keyboardWillShowForLoginNumberPad)
//                                                         name:UIKeyboardWillShowNotification
//                                                       object:nil];
//            
//            [self keyboardWillShowForLoginNumberPad];
//            
//            break;
//            
//        case LoginPassword:
//            [[NSNotificationCenter defaultCenter] removeObserver:self];
//            
//            [self keyboardWillRemoveForLoginNumberPad];
//            
//            break;
//            
//        default:
//            break;
//    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIPickerViewDataSource and UIPickerViewDelegate -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _companies.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_companies[row] objectForKey:@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    _selectedRow = row;
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        _companyCode = @"";
        _companyName = @"";
        _companyText.text = @"请选择快递公司";
        _companyText.textColor = COLOR(191, 191, 191, 1);
        _expressNumber = @"";
        _numberTextField.text = @"";
    } else {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if (![textField.text isEqualToString:@""]) {
            _companyName = textField.text;
            _companyText.text = [_companyText.text stringByAppendingFormat:@" | %@", textField.text];
            _companyText.textColor = [UIColor orangeColor];
        } else {
            _companyCode = @"";
            _companyName = @"";
            _companyText.text = @"请选择快递公司";
            _companyText.textColor = COLOR(191, 191, 191, 1);
            _expressNumber = @"";
            _numberTextField.text = @"";
        }
    }
}

@end
