//
//  ModifyAgreementViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/19.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ModifyAgreementViewController.h"

// Views
#import "LMComBoxView.h"

// Common
#import "LibraryHeadersForCommonController.h"

#define kSpace 10

@interface ModifyAgreementViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) EditTextField *nameTextFile;

@property (nonatomic, strong) LMComBoxView *statusComBox;

@property (nonatomic, strong) LMComBoxView *typeComBox;

@property (nonatomic, strong) UITextView *descTextView;

@property (nonatomic, strong) UIButton *cancalBtn;

@property (nonatomic, strong) UIButton *saveAndRefer;

@property (nonatomic, strong) NSMutableArray *itemsArray;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ModifyAgreementViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kOrangeColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.text = @"修改分销协议";
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isFirst"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kGrayColor;
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self createUI];
}

#pragma mark - createUI -

- (void)createUI
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleOneTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, kScreenHeight - kNavTabBarHeight)];
    _bgView.backgroundColor = kWhiteColor;
    
    [self.view addSubview:_bgView];
    
    // 名称
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, 2 * kSpace, 80, 20)];
    nameLabel.text = @"分成比例";
    nameLabel.font = kSizeFont;
    nameLabel.textColor = kBlackColor;
    nameLabel.textAlignment = NSTextAlignmentRight;
    
    [_bgView addSubview:nameLabel];
    
    // 分成比例编辑框
    _nameTextFile = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + kSpace, kSpace, kScreenWidth - CGRectGetMaxX(nameLabel.frame) - kSpace - 30 - 60, 40)];
    //    _nameTextFile.placeholder = @"这里存放传进来的名字";
    _nameTextFile.text = kNullToString(_distribution[@"percentage"]);
    _nameTextFile.font = kSizeFont;
    _nameTextFile.textColor = kOrangeColor;
    _nameTextFile.layer.masksToBounds = YES;
    _nameTextFile.layer.cornerRadius = 5;
    _nameTextFile.layer.borderColor = kBlackColor.CGColor;
    _nameTextFile.layer.borderWidth = 1.0;
    _nameTextFile.keyboardType = UIKeyboardTypeDecimalPad;
    
    [_bgView addSubview:_nameTextFile];
    
    UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 50, 60)];
    alarmLabel.textAlignment = NSTextAlignmentLeft;
    alarmLabel.text = @"单位%";
    alarmLabel.textColor = [UIColor darkGrayColor];
    alarmLabel.font = [UIFont fontWithName:kFontFamily size:kFontSmallSize];
    
    [_bgView addSubview:alarmLabel];

    //    // 直线
    UIView *firstLine = [[UIView alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(nameLabel.frame) + 2 * kSpace, kScreenWidth - 4 * kSpace, 1)];
    firstLine.backgroundColor = [UIColor lightGrayColor];
    firstLine.alpha = 0.5;
    
    [_bgView addSubview:firstLine];
    
    // 备注
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(firstLine.frame) + 2 * kSpace, 80, 20)];
    descLabel.text = @"备 注";
    descLabel.font = kSizeFont;
    descLabel.textColor = kBlackColor;
    descLabel.textAlignment = NSTextAlignmentRight;
    
    [_bgView addSubview:descLabel];
    
    // 添加textview
    _descTextView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(descLabel.frame) + kSpace, CGRectGetMaxY(firstLine.frame) + 1.5 * kSpace, kScreenWidth - CGRectGetMaxX(descLabel.frame) - 4 * kSpace, 150)];
    _descTextView.backgroundColor = [UIColor whiteColor]; //背景色
    _descTextView.scrollEnabled = YES;    //当文字超过视图的边框时是否允许滑动，默认为“YES”
    _descTextView.editable = YES;        //是否允许编辑内容，默认为“YES”
    _descTextView.delegate = self;       //设置代理方法的实现类
    _descTextView.layer.masksToBounds = YES;
    _descTextView.layer.cornerRadius = 5;
    _descTextView.layer.borderColor = kBlackColor.CGColor;
    _descTextView.layer.borderWidth = 1.0;
    _descTextView.font = [UIFont fontWithName:kLetterFamily size:kFontMidSize]; //设置字体名字和字体大小;
    _descTextView.returnKeyType = UIReturnKeyDefault;//return键的类型
    _descTextView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _descTextView.textAlignment = NSTextAlignmentLeft; //文本显示的位置默认为居左
    _descTextView.dataDetectorTypes = UIDataDetectorTypeAll; //显示数据类型的连接模式（如电话号码、网址、地址等）
    _descTextView.textColor = [UIColor blackColor];
    //    _descTextView.text = @"请详细介绍您的客户";//设置显示的文本内容
    _descTextView.text = kNullToString(_distribution[@"description_text"]);
    _descTextView.tag = 2;

    [_bgView addSubview:_descTextView];
    
    // threeLine
    UIView *threeLine = [[UIView alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(_descTextView.frame) + 2 * kSpace, kScreenWidth - 4 * kSpace, 1)];
    threeLine.backgroundColor = [UIColor lightGrayColor];
    threeLine.alpha = 0.5;
    
    [_bgView addSubview:threeLine];
    
    // 取消按钮
    _cancalBtn = [[UIButton alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(threeLine.frame) + 2 * kSpace, (kScreenWidth - 6 * kSpace) / 2, 50)];
    _cancalBtn.backgroundColor = kClearColor;
    [_cancalBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancalBtn setTitleColor:kBlackColor forState:UIControlStateNormal];
    _cancalBtn.titleLabel.font = kLargeBoldFont;
    _cancalBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_cancalBtn addTarget:self action:@selector(cancalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _cancalBtn.layer.borderColor = kBlackColor.CGColor;
    _cancalBtn.layer.borderWidth = 1.5;
    _cancalBtn.layer.masksToBounds = YES;
    _cancalBtn.layer.cornerRadius = 5;
    
    [_bgView addSubview:_cancalBtn];
    
    // 保存提交
    _saveAndRefer = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_cancalBtn.frame) + 2 * kSpace, CGRectGetMaxY(threeLine.frame) + 2 * kSpace, (kScreenWidth - 6 * kSpace) / 2, 50)];
    _saveAndRefer.backgroundColor = COLOR(0, 183, 238, 1);
    [_saveAndRefer setTitle:@"保存/提交" forState:UIControlStateNormal];
    [_saveAndRefer setTitleColor:kWhiteColor forState:UIControlStateNormal];
    _saveAndRefer.titleLabel.font = kLargeBoldFont;
    _saveAndRefer.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_saveAndRefer addTarget:self action:@selector(saveAndReferClick:) forControlEvents:UIControlEventTouchUpInside];
    _saveAndRefer.layer.masksToBounds = YES;
    _saveAndRefer.layer.cornerRadius = 5;
    _saveAndRefer.alpha = 0.85;
    
    [_bgView addSubview:_saveAndRefer];
    
    CGFloat bgViewHeight = _bgView.frame.size.height;
    if (bgViewHeight > kScreenHeight) {
        _scrollView.contentSize = CGSizeMake(kScreenWidth, bgViewHeight + 100);
    }
}

- (void)singleOneTap:(UIGestureRecognizer *)ges
{
    [self.view endEditing:YES];
}

#pragma mark - Btn Click -

- (void)cancalBtnClick:(UIButton *)sender
{
    YunLog(@"取消按钮被点击了");
    _descTextView.text = kNullToString([_distribution objectForKey:@"description_text"]);
    
    [self backToPrev];
}

- (void)saveAndReferClick:(UIButton *)sender
{
    YunLog(@"保存并提交被点击");
    // 上传商品组
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在修改...";
    
    
    if (_nameTextFile.text == nil || [_nameTextFile.text isEqualToString:@""]) {
        [_hud addErrorString:@"分成比例为空" delay:1.5];
        
        return;
    }
    
    if (_nameTextFile.text )
    
    if (_descTextView.text == nil || [_descTextView.text isEqualToString:@""]) {
        [_hud addErrorString:@"备注为空" delay:1.5];
        
        return;
    }
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"percentage"              :   kNullToString(_nameTextFile.text),
                             @"description_text"        :   kNullToString(_descTextView.text)};
    
    NSString *modifyAgreementURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/distributions/%@.json",[_distribution objectForKey:@"id"]] params:params];
    
    YunLog(@"modifyAgreementURL = %@", modifyAgreementURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager PATCH:modifyAgreementURL
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               YunLog(@"modifyGroup responseObject = %@", responseObject);
               if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
               {
                   [_hud addSuccessString:@"修改成功" delay:2.0];
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
               YunLog(@"modifyAgreementURL - error = %@", error);
           }];
}

#pragma mark - UITextViewDelegate -

//将要开始编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSString *isFirstString = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirst"];
    
    if ([isFirstString isEqualToString:@"no"]) {
        
    } else {
        textView.text = _descTextView.text;
        
        [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isFirst"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    if (textView.tag == 2) {
        self.view.frame = CGRectMake(0, -70, kScreenWidth, kScreenHeight + 100);
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


#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
