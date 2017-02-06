//
//  OpenShopViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14/11/3.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "OpenShopViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Views
#import "CustomTableViewCell.h"

// Classes
#import "Tool.h"

@interface OpenShopViewController () <UIScrollViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger current;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *array;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, copy) NSString *shopName;

@property (nonatomic, copy) NSString *shopSyn;

@property (nonatomic, copy) NSString *companyName;

@property (nonatomic, copy) NSString *personName;

@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, copy) NSString *detailEmail;

@property (nonatomic, copy) NSString *detailAddress;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation OpenShopViewController

#pragma mark - Initialization -

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"我要开店";
        
        self.navigationItem.titleView = naviTitle;
    }
    
    return self;
}

#pragma mark - Life Cycle -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _array = [NSArray arrayWithObjects:@"企业", @"个人", nil];
    
    self.view.backgroundColor = kBackgroundColor;

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 25, 25);
    [backBtn setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UITableView *myTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48) style:UITableViewStyleGrouped];
    myTabView.delegate = self;
    myTabView.dataSource = self;
    myTabView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    myTabView.backgroundColor = kClearColor;
    
    self.tableView = myTabView;
    
    [self.view addSubview:myTabView];
    
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button.frame = CGRectMake(0, kScreenHeight - 48, kScreenWidth, 48);
    _button.backgroundColor = [UIColor orangeColor];
    [_button addTarget:self action:@selector(btnSubmmit) forControlEvents:UIControlEventTouchUpInside];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_button setTitle:@"提交审核" forState:UIControlStateNormal];
    
    [self.view addSubview:_button];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowForOpenShop:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Functions -

- (void)keyboardWillShowForOpenShop:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    
    _keyboardHeight = height;
}

- (void)textFieldWithText: (UITextField *)textField
{
    if (_current == 0)
    {
        switch (textField.tag)
        {
            case 0:
                self.shopName = textField.text;
                
                break;
                
            case 1:
                self.shopSyn = textField.text;
                
                break;
                
            case 3:
                self.companyName = textField.text;
                
                break;
                
            case 4:
                self.personName = textField.text;
                
                break;
                
            case 5:
                self.phoneNumber = textField.text;
                
                break;
                
            case 6:
                self.detailEmail = textField.text;
                
                break;
                
            case 7:
                self.detailAddress = textField.text;
                
                break;
                
            default:
                
                break;
        }
    }
    else
    {
        switch (textField.tag)
        {
            case 0:
                self.shopName = textField.text;
                
                break;
                
            case 1:
                self.shopSyn = textField.text;
                
                break;
                
            case 3:
                self.personName = textField.text;
                
                break;
                
            case 4:
                self.phoneNumber = textField.text;
                
                break;
                
            case 5:
                self.detailEmail = textField.text;
                
                break;
                
            case 6:
                self.detailAddress = textField.text;
                
                break;
                
            default:
                
                break;
        }
    }
}

- (void)btnSubmmit
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    NSDictionary *params = [[NSDictionary alloc] init];
    
    if (self.shopName == nil)
    {
        [_hud addErrorString:@"请输入店铺名称" delay:1.0];
        
        return;
    }
    
    if (self.shopSyn == nil)
    {
        [_hud addErrorString:@"请输入店铺简介" delay:1.0];
        
        return;
    }
    
    if (self.companyName == nil)
    {
        [_hud addErrorString:@"请输入公司名称" delay:1.0];
        
        return;
    }
    
    if (self.personName == nil)
    {
        [_hud addErrorString:@"请输入姓名" delay:1.0];
        
        return;
    }
    
    if (self.detailAddress == nil)
    {
        [_hud addErrorString:@"请输入详细地址" delay:1.0];
        
        return;
    }
    
    
    NSString *regexString = @"(^1(3[5-9]|47|5[012789]|8[23478])\\d{8}$|134[0-8]\\d{7}$)|(^18[019]\\d{8}$|1349\\d{7}$)|(^1(3[0-2]|45|5[56]|8[56])\\d{8}$)|(^1[35]3\\d{8}$)";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:nil];
    
    NSTextCheckingResult *result = [regex firstMatchInString:self.phoneNumber options:0 range:NSMakeRange(0, [self.phoneNumber length])];
    
    BOOL isValidateEmail;
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    isValidateEmail = [emailTest evaluateWithObject:self.detailEmail];
    
    if (!isValidateEmail)
    {
        [_hud addErrorString:@"请输入正确的邮箱格式" delay:1.0];
        
        return;
    }
    
    if (!result)
    {
        [_hud addErrorString:@"请输入正确的手机号码" delay:1.0];
        
        return;
    }
    
    if (self.phoneNumber == nil)
    {
        [_hud addErrorString:@"请输入手机号码" delay:1.0];
        
        return;
    }
    
    if (self.detailEmail == nil)
    {
        [_hud addErrorString:@"请输入邮箱地址" delay:1.0];
        
        return;
    }
    
    if (self.detailAddress == nil)
    {
        [_hud addErrorString:@"请输入详细地址" delay:1.0];
        
        return;
    }
    
    if (_current == 0)
    {
        params = @{@"shopName"     : kNullToString(self.shopName) ,
                   @"shopSyn"      : kNullToString(self.shopSyn),
                   @"companyName"  : kNullToString(self.companyName),
                   @"personName"   : kNullToString(self.personName),
                   @"phoneNumber"  : kNullToString(self.phoneNumber),
                   @"detailEmail"  : kNullToString(self.detailEmail),
                   @"detailAddress": kNullToString(self.detailAddress)};
        
    }
    
    else if (_current == 1)
    {
        params = @{@"shopName"     : kNullToString(self.shopName),
                   @"shopSyn"      : kNullToString(self.shopSyn),
                   @"personName"   : kNullToString(self.personName),
                   @"phoneNumber"  : kNullToString(self.phoneNumber),
                   @"detailEmail"  : kNullToString(self.detailEmail),
                   @"detailAddress": kNullToString(self.detailAddress)};
    }
    
    
    NSString *requestURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:nil params:nil];
    
    YunLog(@"%@", requestURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:requestURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"submmit responseObject = %@", responseObject);
        
              [_hud addSuccessString:@"操作成功" delay:1.0];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [_hud addErrorString:@"网络异常，请稍后尝试" delay:1.0];
          }];
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)resetView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
    
    [UIView commitAnimations];
}

- (void)moveViewTo:(float)value
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    _tableView.frame = CGRectMake(0, value, kScreenWidth, kScreenHeight - 48);
    
    [UIView commitAnimations];
}

#pragma mark - UITableViewDataSource Method And UITableViewDelegate Method-

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 35;
    }
    else
    {
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 41;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _current = indexPath.row;
    
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_current == 0)
    {
        return 8;
    }
    else
    {
        return 7;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = [[NSString alloc] init];
    
    if (_current == 0)
    {
        switch (section)
        {
            case 0:
                str = @"店铺名称";
                
                break;
                
            case 1:
                str = @"店铺简介";
                
                break;
                
            case 2:
                str = @"请选择";
                
                break;
                
            case 3:
                str = @"公司名称";
                
                break;
                
            case 4:
                str = @"姓名";
                
                break;
                
            case 5:
                str = @"电话";
                
                break;
                
            case 6:
                str = @"邮箱";
                
                break;
                
            case 7:
                str = @"详细地址";
                
                break;
                
            default:
                
                break;
        }
    }
    else
    {
        switch (section)
        {
            case 0:
                str = @"店铺名称";
                
                break;
                
            case 1:
                str = @"店铺简介";
                
                break;
                
            case 2:
                str = @"请选择";
                
                break;
                
            case 3:
                str = @"姓名";
                
                break;
                
            case 4:
                str = @"电话";
                
                break;
                
            case 5:
                str = @"邮箱";
                
                break;
                
            case 6:
                str = @"详细地址";
                
                break;
                
            default:
                
                break;
        }
    }
    
    return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIden = [NSString stringWithFormat:@"Cell%ld%ld", (long)indexPath.section, (long)indexPath.row];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;

    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    
    if (cell == nil)
    {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.delegate = self;
        [cell.textField addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
    }
    
    cell.textField.tag = indexPath.section;
    
    if (_current == 0)
    {
        switch (section)
        {
            case 0:
                cell.textField.placeholder = @"请输入店铺名称";
//                cell.textField.tag = 0;
                
                break;
                
            case 1:
                cell.textField.placeholder = @"请输入店铺简介";
//                cell.textField.tag = 1;
                
                break;
                
            case 2:
                cell.textField.hidden = YES;
                cell.textLabel.text = [_array objectAtIndex:row];
                
                if (indexPath.row == 0)
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;

                }
                else if (indexPath.row == 1)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                break;
                
            case 3:
                cell.textField.placeholder = @"请输入公司名称";
//                cell.textField.tag = 3;
                
                break;
                
            case 4:
                cell.textField.placeholder = @"请输入姓名";
//                cell.textField.tag = 4;
                
                break;
                
            case 5:
                cell.textField.placeholder = @"请输入电话号码";
//                cell.textField.tag = 5;
//                cell.textField.keyboardType = UIKeyboardTypePhonePad;
                
                break;
                
            case 6:
                cell.textField.placeholder = @"请输入邮箱地址";
//                cell.textField.tag = 6;
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                
                break;
                
            case 7:
                cell.textField.placeholder = @"请输入详细地址";
//                cell.textField.tag = 7;
                
                break;
        }
    }
    else
    {
        switch (section)
        {
            case 0:
                cell.textField.placeholder = @"请输入店铺名称";
//                cell.textField.tag = 0;
                
                break;
                
            case 1:
                cell.textField.placeholder = @"请输入店铺简介";
//                cell.textField.tag = 1;
                
                break;
                
            case 2:
                cell.textField.hidden = YES;
                cell.textLabel.text = [_array objectAtIndex:row];
                
                if (indexPath.row == 0)
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else if (indexPath.row == 1)
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                
                break;
            
            case 3:
                cell.textField.placeholder = @"请输入姓名";
//                cell.textField.tag = 4;
                
                break;
                
            case 4:
                cell.textField.placeholder = @"请输入电话号码";
//                cell.textField.tag = 5;
//                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                
                break;
                
            case 5:
                cell.textField.placeholder = @"请输入邮箱地址";
//                cell.textField.tag = 6;
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                
                break;
                
            case 6:
                cell.textField.placeholder = @"请输入详细地址";
//                cell.textField.tag = 7;
                
                break;
        }
        
    }
    
    return cell;
}



#pragma mark - UITextFieldDelegate Method -

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        
        return NO;
    }

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self resetView];
    
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (textField.tag + _current > 4) {
            [self moveViewTo:48 - _keyboardHeight];
        }
        
        else {
            _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
            
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:textField.tag]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
        }
    });
    
//    int n = textField.tag;
//    
//    switch (n)
//    {
//        case 0:
//        case 1:
//            //[self moveView:0];
//            //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//            break;
//            
//        case 3:
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7]
//                                  atScrollPosition:UITableViewScrollPositionNone
//                                          animated:YES];
//            //[self moveView:-40];
//            break;
//            
//        case 4:
//            //[self moveView:-60];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:6]
//                                  atScrollPosition:UITableViewScrollPositionNone
//                                          animated:YES];
//            
//            break;
//            
//        case 5:
//            //[self moveView:-119];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:6]
//                                  atScrollPosition:UITableViewScrollPositionNone
//                                          animated:YES];
//            
//            break;
//            
//        case 6:
//            //[self moveView:-200];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7]
//                                  atScrollPosition:UITableViewScrollPositionMiddle
//                                          animated:YES];
//            
//            break;
//            
//        case 7:
//            //[self moveView:-200];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:7]
//                                  atScrollPosition:UITableViewScrollPositionMiddle
//                                          animated:YES];
//            
//            break;
//            
//        default:
//            
//            break;
//    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{    
//    int n = textField.tag;
//    
//    switch (n)
//    {
//        case 0:
//        case 1:
//            //[self moveView:0];
//            //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//            break;
//            
//        case 3:
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                                  atScrollPosition:UITableViewScrollPositionNone
//                                          animated:YES];
//            
//            break;
//            
//        case 4:
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
//                                  atScrollPosition:UITableViewScrollPositionNone
//                                          animated:YES];
//            
//            break;
//            
//        case 5:
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                                  atScrollPosition:UITableViewScrollPositionNone
//                                          animated:YES];
//            
//            break;
//            
//        case 6:
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                                  atScrollPosition:UITableViewScrollPositionMiddle
//                                          animated:YES];
//            
//            break;
//            
//        case 7:
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                                  atScrollPosition:UITableViewScrollPositionTop
//                                          animated:YES];
//            
//            break;
//            
//        default:
//            
//            break;
//    }
    
    return YES;
}

@end
