//
//  ModifyProductGroupViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ModifyProductGroupViewController.h"

// Views
#import "LMComBoxView.h"

// Common
#import "LibraryHeadersForCommonController.h"

#define kSpace 10

@interface ModifyProductGroupViewController () <LMComBoxViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UITextField *nameTextFile;

@property (nonatomic, strong) LMComBoxView *statusComBox;

@property (nonatomic, strong) LMComBoxView *typeComBox;

@property (nonatomic, strong) UITextView *descTextView;

@property (nonatomic, strong) UIButton *cancalBtn;

@property (nonatomic, strong) UIButton *saveAndRefer;

@property (nonatomic, strong) NSMutableArray *itemsArray;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ModifyProductGroupViewController

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
        _naviTitle.text = @"商品组基本信息";
        
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
    
    self.itemsArray = [NSMutableArray arrayWithObjects:@"一级分类", @"二级分类", @"三级分类", @"四级分类", @"五级分类", @"六级分类", @"七级分类", @"八级分类", @"九级分类", nil];
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
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    _scrollView.backgroundColor = kGrayColor;
//    _scrollView.delegate = self;
//    _scrollView.showsHorizontalScrollIndicator = NO;
//    _scrollView.showsVerticalScrollIndicator = NO;
//    
//    [self.view addSubview:_scrollView];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, kScreenHeight - kNavTabBarHeight)];
    _bgView.backgroundColor = kWhiteColor;
    
    [self.view addSubview:_bgView];
    
    // 名称
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(4 * kSpace, 2 * kSpace, 50, 20)];
    nameLabel.text = @"名 称";
    nameLabel.font = kSizeFont;
    nameLabel.textColor = kBlackColor;
    
    [_bgView addSubview:nameLabel];
    
    // 名字文本编辑框
    _nameTextFile = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame) + kSpace, 2 * kSpace, kScreenWidth - 120, 20)];
//    _nameTextFile.placeholder = @"这里存放传进来的名字";
    _nameTextFile.text = _dict[@"name"];
    _nameTextFile.font = kSizeFont;
    _nameTextFile.textColor = kOrangeColor;
    
    [_bgView addSubview:_nameTextFile];
    
//    // 直线
    UIView *firstLine = [[UIView alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(nameLabel.frame) + 2 * kSpace, kScreenWidth - 4 * kSpace, 1)];
    firstLine.backgroundColor = [UIColor lightGrayColor];
    firstLine.alpha = 0.5;
    
    [_bgView addSubview:firstLine];
//
//    // 状态
//    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(4 * kSpace, CGRectGetMaxY(firstLine.frame) + 2 * kSpace, 50, 20)];
//    statusLabel.text = @"状 态";
//    statusLabel.font = kSizeFont;
//    statusLabel.textColor = kBlackColor;
//    
//    [_bgView addSubview:statusLabel];
//    
//    _statusComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(statusLabel.frame) + kSpace, CGRectGetMaxY(firstLine.frame) + 1.5 * kSpace, 160, 30)];
//    _statusComBox.arrowImgName = @"downArrow.png";
//    _statusComBox.titlesList = _itemsArray;
//    _statusComBox.delegate = self;
//    _statusComBox.supView = _bgView;
//    [_statusComBox defaultSettings];
//
//    [_bgView addSubview:_statusComBox];
//    
//    // twoLine
//    UIView *twoLine = [[UIView alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(statusLabel.frame) + 2 * kSpace, kScreenWidth - 4 * kSpace, 1)];
//    twoLine.backgroundColor = [UIColor lightGrayColor];
//    twoLine.alpha = 0.5;
//    
//    [_bgView addSubview:twoLine];
//    
//    // 类型
//    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(4 * kSpace, CGRectGetMaxY(twoLine.frame) + 2 * kSpace, 50, 20)];
//    typeLabel.text = @"类 型";
//    typeLabel.font = kSizeFont;
//    typeLabel.textColor = kBlackColor;
//    
//    [_bgView addSubview:typeLabel];
//    
//    _typeComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typeLabel.frame) + kSpace, CGRectGetMaxY(twoLine.frame) + 1.5 * kSpace, 160, 30)];
//    _typeComBox.arrowImgName = @"downArrow.png";
//    _typeComBox.titlesList = _itemsArray;
//    _typeComBox.delegate = self;
//    _typeComBox.supView = _bgView;
//    [_typeComBox defaultSettings];
//    
//    [_bgView addSubview:_typeComBox];
//    
//    // 中间分割view
//    UIView *dismemberView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(typeLabel.frame) + 2 * kSpace, kScreenWidth, 1.5 * kSpace)];
//    dismemberView.backgroundColor = kGrayColor;
//    
//    [_bgView addSubview:dismemberView];
    
    // 描素
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(4 * kSpace, CGRectGetMaxY(firstLine.frame) + 2 * kSpace, 50, 20)];
    descLabel.text = @"描 述";
    descLabel.font = kSizeFont;
    descLabel.textColor = kBlackColor;
    
    [_bgView addSubview:descLabel];
    
    // 添加textview
    _descTextView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(descLabel.frame) + kSpace, CGRectGetMaxY(firstLine.frame) + 1.5 * kSpace, kScreenWidth - CGRectGetMaxX(descLabel.frame) - 4 * kSpace, 150)];
    _descTextView.backgroundColor=[UIColor whiteColor]; //背景色
    _descTextView.scrollEnabled = YES;    //当文字超过视图的边框时是否允许滑动，默认为“YES”
    _descTextView.editable = YES;        //是否允许编辑内容，默认为“YES”
    _descTextView.delegate = self;       //设置代理方法的实现类
    _descTextView.layer.masksToBounds = YES;
    _descTextView.layer.cornerRadius = 5;
    _descTextView.layer.borderColor = kBlackColor.CGColor;
    _descTextView.layer.borderWidth = 1.0;
    _descTextView.font=[UIFont fontWithName:kLetterFamily size:kFontMidSize]; //设置字体名字和字体大小;
    _descTextView.returnKeyType = UIReturnKeyDefault;//return键的类型
    _descTextView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _descTextView.textAlignment = NSTextAlignmentLeft; //文本显示的位置默认为居左
    _descTextView.dataDetectorTypes = UIDataDetectorTypeAll; //显示数据类型的连接模式（如电话号码、网址、地址等）
    _descTextView.textColor = [UIColor blackColor];
//    _descTextView.text = @"请详细介绍您的客户";//设置显示的文本内容
    _descTextView.text = _dict[@"description"];
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
    _descTextView.text = [_dict objectForKey:@"description"];
    
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
        [_hud addErrorString:@"商品组名为空" delay:1.5];
        
        return;
    }
    
    if (_descTextView.text == nil || [_descTextView.text isEqualToString:@""]) {
        [_hud addErrorString:@"商品组描述为空" delay:1.5];
        
        return;
    }
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"name"                    :   kNullToString(_nameTextFile.text),
                             @"description"             :   kNullToString(_descTextView.text)};
    
    NSString *modifyGroupURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/product_groups/%@",[_dict objectForKey:@"id"]] params:params];
    
    YunLog(@"modifyGroupURL = %@", modifyGroupURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager PATCH:modifyGroupURL
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
              YunLog(@"modifyGroupURL - error = %@", error);
          }];
}

#pragma mark - LMComBoxDelegate - 

-(void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{

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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
