//
//  AddNewGroupViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AddNewGroupViewController.h"

// Views
#import "LMComBoxView.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface AddNewGroupViewController () <LMComBoxViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) LMComBoxView *groupComBox;

/// 下拉内容
@property (nonatomic, strong) NSMutableArray *itemsArray;

/// 下拉内容的id
@property (nonatomic, strong) NSMutableArray *idArray;

/// 选中的商品组id
@property (nonatomic, strong) NSString *selectedID;

@property (nonatomic, strong) MBProgressHUD *hud;

/// 分销比例
@property (nonatomic, strong) EditTextField *textField;

@property (nonatomic, strong) UITextView *textView;

@end

@implementation AddNewGroupViewController

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
        naviTitle.text = @"添加分销商品组";
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemsArray = [NSMutableArray array];
    _idArray = [NSMutableArray array];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在获取我的商品组";
    
    self.view.backgroundColor = kGrayColor;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    // 获取浏览商品数据
    NSDictionary *params = @{@"parent_shop_id"         :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                             @"user_session_key"       :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"   :   kNullToString(appDelegate.terminalSessionKey),
                             @"distribution_owner_id"  :   kNullToString(_distribution_owner_id),
                             @"distribution_shop_id"   :   kNullToString(_distribution_shop_id)};
    
    NSString *productGroupsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kProduct_group_no_in_distribution params:params];
    YunLog(@"我的商品组列表 = %@", productGroupsURL);
    
    [manager GET:productGroupsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            YunLog(@"我的商品组列表 = %@",responseObject);
            NSArray *items = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"product_groups"]);
            for (int i = 0; i < items.count; i++)
            {
              
                [_itemsArray addObject:kNullToString([items[i] objectForKey:@"name"])];
                [_idArray addObject:kNullToString([items[i] objectForKey:@"id"])];
    
            }
            _selectedID = _idArray.firstObject;
            _hud.hidden = YES;
        }
        else
        {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
        }
        [self createUI];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        YunLog(@"我的商品组列表 - error = %@", error);
        [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
        
        [self createUI];
    }];
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
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 151)];
    topView.backgroundColor = [UIColor whiteColor];
    topView.userInteractionEnabled = YES;
    
    [self.view addSubview:topView];
    
    NSArray *title = @[@"分销商", @"请选择商品组", @"分销比例"];
    
    for (int i = 0; i < 3; i ++)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (50 + 0.5) * i, 135, 50)];
        titleLabel.text = title[i];
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
        
        switch (i) {
            case 0:
            {
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame), kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 50)];
                nameLabel.text = kNullToString(_distributorName);
                nameLabel.textColor = [UIColor orangeColor];
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
                
                [topView addSubview:nameLabel];

            }
                break;
                
            case 1:
            {
                _groupComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10 + 64, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
                _groupComBox.arrowImgName = @"downArrow.png";
                _groupComBox.titlesList = _itemsArray;
                _groupComBox.delegate = self;
                _groupComBox.supView = self.view;
                [_groupComBox defaultSettings];
                
                [self.view addSubview:_groupComBox];
            }
                break;
                
            case 2:
            {
                _textField = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
                _textField.layer.borderColor = [UIColor grayColor].CGColor;
                _textField.layer.borderWidth = 1;
                _textField.layer.cornerRadius = 5;
                _textField.layer.masksToBounds = YES;
                _textField.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
                _textField.textColor = [UIColor darkGrayColor];
                _textField.placeholder = @"单位：%";
                _textField.keyboardType = UIKeyboardTypeDecimalPad;
                _textField.tag = 2;
                _textField.delegate = self;
                
                [topView addSubview:_textField];
            }
                break;
                
            default:
                break;
        }
    }
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 10, kScreenWidth, 210)];
    buttomView.backgroundColor = [UIColor whiteColor];
    buttomView.userInteractionEnabled = YES;
    
    [self.view addSubview:buttomView];
    
    [self.view sendSubviewToBack:buttomView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 135, 50)];
    titleLabel.text = @"分销协议备注";
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.textAlignment = NSTextAlignmentRight;
    titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    
    [buttomView addSubview:titleLabel];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, 10, kScreenWidth - 30 - CGRectGetMaxX(titleLabel.frame) - 20, 120)];
//    textView.borderStyle = UITextBorderStyleRoundedRect;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.borderWidth = 1;
    _textView.layer.cornerRadius = 5;
    _textView.layer.masksToBounds = YES;
    _textView.delegate = self;
    _textView.tag = 3;
    
    
    [buttomView addSubview:_textView];
    
    UIButton *commit = [UIButton buttonWithType:UIButtonTypeCustom];
    commit.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMaxY(_textView.frame) + 20, 120, 40);
    commit.backgroundColor = kBlueColor;
    [commit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commit setTitle:@"保存提交" forState:UIControlStateNormal];
    commit.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    [commit addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    commit.layer.masksToBounds = YES;
    commit.layer.cornerRadius = 5;
    
    [buttomView addSubview:commit];
}

- (void)commit
{
    AppDelegate *appDelegate = kAppDelegate;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"保存提交中...";

    if (_textField.text == nil || [_textField.text isEqualToString:@""]) {
        [_hud addErrorString:@"分销比例为空" delay:1.5];
        
        return;
    }
    
    if (_textView.text == nil || [_textView.text isEqualToString:@""]) {
        [_hud addErrorString:@"描述为空" delay:1.5];
        
        return;
    }

    NSDictionary *params = @{@"father_shop_id"                :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                             @"user_session_key"              :   kNullToString(appDelegate.user.userSessionKey),
                             @"distribution_shop_id"          :   kNullToString(_distribution_shop_id),
                             @"distribution_resource_id"      :   kNullToString(_selectedID),
                             @"percentage"                    :   kNullToString(_textField.text),
                             @"description_text"              :   kNullToString(_textView.text)};
    
    NSString *distributeGroupsURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                                   APIVersion:kAPIVersion1WithShops
                                                   requestURL:KAdd_distributor_product_group
                                                       params:params];
    YunLog(@"分配商品组URL = %@", distributeGroupsURL);
    
    [manager POST:distributeGroupsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        YunLog(@"分配商品组URL = %@",responseObject);
        
        if ([code isEqualToString:kSuccessCode]) {
            [_hud addSuccessString:@"提交成功..." delay:2.0];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddNewDistributorGroupSuccess object:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self backToPrev];
            });
        }
        else
        {
            [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
        
        YunLog(@"我的商铺列表 - error = %@", error);
    }];
}

#pragma mark - LMComBoxDelegate -

-(void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{
    _selectedID = _idArray[index];
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
    
    if (textField.tag == 2) {
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

#pragma mark - UITextViewDelegate -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    if (textView.tag == 3) {
        self.view.frame = CGRectMake(0, -170, kScreenWidth, kScreenHeight + 100);
    }
    
    [UIView commitAnimations];
    
    return YES;
}
- (BOOL)textViewShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    [UIView commitAnimations];
    
    return YES;
}

@end
