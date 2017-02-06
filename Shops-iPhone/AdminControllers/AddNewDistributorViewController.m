//
//  AddNewDistributorViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AddNewDistributorViewController.h"

// Views
#import "LMComBoxView.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface AddNewDistributorViewController () <LMComBoxViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LMComBoxView *statusComBox;

/// 下拉内容
@property (nonatomic, strong) NSMutableArray *itemsArray;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 商户名称
@property (nonatomic, strong) EditTextField *name;

/// 商户简称
@property (nonatomic, strong) EditTextField *short_name;

/// 联系人姓名
@property (nonatomic, strong) EditTextField *contact_name;

/// 手机号码
@property (nonatomic, strong) EditTextField *mobile_phone;

/// 邮箱
@property (nonatomic, strong) EditTextField *email;

@property (nonatomic, strong) IQKeyboardManager *keyManager;

@end

@implementation AddNewDistributorViewController

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
        naviTitle.text = @"新增分销商";
        
        self.navigationItem.titleView = naviTitle;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        backItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _keyManager = [IQKeyboardManager sharedManager];
    
    _keyManager.enable = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _keyManager = [IQKeyboardManager sharedManager];
    
    _keyManager.enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kGrayColor;
    
    _itemsArray = [NSMutableArray arrayWithObjects:@"新 增", @"待审核" ,@"审核通过", @"审核失败", @"上 线", @"关 闭", nil];
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 101)];
    topView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:topView];
    
    NSArray *topTitle = @[@"商户名称", @"商户简称"];
    NSArray *alarmWord = @[@"不超过8个字", @"不超过4个字，不能包含云店家", @"此手机号码是分销商的账户用户名", @"此邮箱用来接收销售统计报表"];
    
    for (int i = 0; i < 2; i ++)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (50 + 0.5) * i, 100, 50)];
        titleLabel.text = topTitle[i];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
        
        [topView addSubview:titleLabel];
        
        if (i < 2)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(titleLabel.frame), kScreenWidth - 60, 0.5)];
            line.backgroundColor = kGrayColor;
            
            [topView addSubview:line];
        }
        
        if (i == 0) {
            _name = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
            _name.layer.borderColor = [UIColor grayColor].CGColor;
            _name.layer.borderWidth = 1;
            _name.layer.cornerRadius = 5;
            _name.layer.masksToBounds = YES;
            _name.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
            _name.textColor = [UIColor darkGrayColor];
            _name.placeholder = alarmWord[i];
            _name.delegate = self;
            
            [topView addSubview:_name];
        }
        if (i == 1) {
            _short_name = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
            _short_name.layer.borderColor = [UIColor grayColor].CGColor;
            _short_name.layer.borderWidth = 1;
            _short_name.layer.cornerRadius = 5;
            _short_name.layer.masksToBounds = YES;
            _short_name.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
            _short_name.textColor = [UIColor darkGrayColor];
            _short_name.placeholder = alarmWord[i];
            _short_name.delegate = self;
            
            [topView addSubview:_short_name];
        }
//        if (i == 2)
//        {
//            _statusComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            _statusComBox.arrowImgName = @"downArrow.png";
//            _statusComBox.titlesList = _itemsArray;
//            _statusComBox.delegate = self;
//            _statusComBox.supView = topView;
//            [_statusComBox defaultSettings];
//            
//            [topView addSubview:_statusComBox];
//        }
    }
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 10, kScreenWidth, 230)];
    buttomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:buttomView];
    
    [self.view sendSubviewToBack:buttomView];
    
    NSArray *buttomTitle = @[@"联系人姓名", @"手机号码", @"邮箱"];
    for (int i = 0; i < 3; i ++)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 * i, 100, 50)];
        titleLabel.text = buttomTitle[i];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
        
        [buttomView addSubview:titleLabel];
 
        if (i == 0)
        {
            _contact_name = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
            _contact_name.layer.borderColor = [UIColor grayColor].CGColor;
            _contact_name.layer.borderWidth = 1;
            _contact_name.layer.cornerRadius = 5;
            _contact_name.layer.masksToBounds = YES;
            _contact_name.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
            _contact_name.textColor = [UIColor darkGrayColor];
            _contact_name.tag = 100;
            _contact_name.delegate = self;
            
            [buttomView addSubview:_contact_name];
        }
        if (i == 1)
        {
            _mobile_phone = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
            _mobile_phone.layer.borderColor = [UIColor grayColor].CGColor;
            _mobile_phone.layer.borderWidth = 1;
            _mobile_phone.layer.cornerRadius = 5;
            _mobile_phone.layer.masksToBounds = YES;
            _mobile_phone.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
            _mobile_phone.textColor = [UIColor darkGrayColor];
            _mobile_phone.placeholder = alarmWord[2];
            _mobile_phone.keyboardType = UIKeyboardTypePhonePad;
            _mobile_phone.tag = 200;
            _mobile_phone.delegate = self;
            
            [buttomView addSubview:_mobile_phone];
        }
        if (i == 2)
        {
            _email = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
            _email.layer.borderColor = [UIColor grayColor].CGColor;
            _email.layer.borderWidth = 1;
            _email.layer.cornerRadius = 5;
            _email.layer.masksToBounds = YES;
            _email.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
            _email.textColor = [UIColor darkGrayColor];
            _email.placeholder = alarmWord[3];
            _email.tag = 300;
            _email.delegate = self;
            
            [buttomView addSubview:_email];
        }
    }

    UIButton *commit = [UIButton buttonWithType:UIButtonTypeCustom];
    commit.frame = CGRectMake(20, 170, (kScreenWidth - 60) / 2, 40);
    commit.backgroundColor = kBlueColor;
    [commit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commit setTitle:@"保存并提交" forState:UIControlStateNormal];
    commit.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    //    [commit addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
    commit.layer.masksToBounds = YES;
    commit.layer.cornerRadius = 5;
    [commit addTarget:self action:@selector(addNewDistributor) forControlEvents:UIControlEventTouchUpInside];
    
    [buttomView addSubview:commit];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(CGRectGetMaxX(commit.frame) + 20, 170, (kScreenWidth - 60) / 2, 40);
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    cancel.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    //    [commit addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
    cancel.layer.masksToBounds = YES;
    cancel.layer.cornerRadius = 5;
    cancel.layer.borderWidth = 1;
    cancel.layer.borderColor = [UIColor blackColor].CGColor;
    
    [buttomView addSubview:cancel];
}


- (void)addNewDistributor
{
    AppDelegate *appDelegate = kAppDelegate;
    
     _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
     _hud.labelText = @"正在添加...";
    
    if (_name.text == nil || [_name.text isEqualToString:@""]) {
        [_hud addErrorString:@"商户名称为空" delay:1.5];
        
        return;
    }
    if (_name.text.length > 8) {
        [_hud addErrorString:@"商户名称不超过8个字" delay:1.5];
        
        return;
    }
    if (_short_name.text == nil || [_short_name.text isEqualToString:@""]) {
        [_hud addErrorString:@"商户简称为空" delay:1.5];
        
        return;
    }
    if (_short_name.text.length > 8) {
        [_hud addErrorString:@"商户简称不超过4个字" delay:1.5];
        
        return;
    }
    if (_contact_name.text == nil || [_contact_name.text isEqualToString:@""]) {
        [_hud addErrorString:@"联系人姓名为空" delay:1.5];
        
        return;
    }
    if (_mobile_phone.text == nil || [_mobile_phone.text isEqualToString:@""]) {
        [_hud addErrorString:@"手机号码为空" delay:1.5];
        
        return;
    }
    if (_email.text == nil || [_email.text isEqualToString:@""]) {
        [_hud addErrorString:@"邮箱为空" delay:1.5];
        
        return;
    }
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"name"                    :   kNullToString(_name.text),
                             @"short_name"              :   kNullToString(_short_name.text),
                             @"contact_name"            :   kNullToString(_contact_name.text),
                             @"mobile_phone"            :   kNullToString(_mobile_phone.text),
                             @"sid"                     :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopCode"]),
                             @"email"                   :   kNullToString(_email.text)};
    
    NSString *addNewDistributorURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:KAdd_Distributor params:params];
    
    YunLog(@"addNewDistributorURL = %@", addNewDistributorURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:addNewDistributorURL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"addNewDistributor responseObject = %@", responseObject);
              if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
              {
                  [_hud addSuccessString:@"添加分销商成功" delay:2.0];
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddNewDistributorSuccess object:nil];
                  
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self backToPrev];
                  });
              }
              else
              {
                  [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
              }
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
              YunLog(@"addNewDistributorURL - error = %@", error);
          }];
}

- (void)cancel
{
    [self backToPrev];
}

#pragma mark - LMComBoxDelegate -

-(void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{
    
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
    
    if (textField.tag == 100 || textField.tag == 200 || textField.tag == 300) {
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
@end
