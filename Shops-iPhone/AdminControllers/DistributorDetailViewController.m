//
//  DistributorDetailViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "DistributorDetailViewController.h"

// Views
#import "LMComBoxView.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface DistributorDetailViewController () <LMComBoxViewDelegate>

@property (nonatomic, strong) LMComBoxView *statusComBox;

/// 下拉内容
@property (nonatomic, strong) NSMutableArray *itemsArray;

/// 商户名称
@property (nonatomic, strong) UILabel *name;

/// 商户简称
@property (nonatomic, strong) UILabel *short_name;

/// 联系人姓名
@property (nonatomic, strong) UILabel *contact_name;

/// 手机号码
@property (nonatomic, strong) UILabel *mobile_phone;

/// 邮箱
@property (nonatomic, strong) UILabel *emailLabel;

@end

@implementation DistributorDetailViewController

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
        naviTitle.text = @"分销商详情";
        
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
    
    NSArray *topTitle = @[@"商户名称", @"商户简称", @"状态"];
    NSArray *topWord = @[kNullToString(_distributorName),kNullToString(_distributorDesc), kNullToString(_phoneName), kNullToString(_phoneNumber), kNullToString(_email)];
//    NSArray *alarmWord = @[@"不超过8个字", @"不超过4个字，不能包含云店家", @"此手机号码是分销商的账户用户名"];
//    for (int i = 0; i < 3; i ++)
//    {
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (50 + 0.5) * i, 100, 50)];
//        titleLabel.text = topTitle[i];
//        titleLabel.textColor = [UIColor darkGrayColor];
//        titleLabel.textAlignment = NSTextAlignmentRight;
//        titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//        
//        [topView addSubview:titleLabel];
//        
//        if (i < 2)
//        {
//            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(titleLabel.frame), kScreenWidth - 60, 0.5)];
//            line.backgroundColor = kGrayColor;
//            
//            [topView addSubview:line];
//            
//            UILabel *textField = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            textField.layer.borderColor = [UIColor grayColor].CGColor;
//            textField.layer.borderWidth = 1;
//            textField.layer.cornerRadius = 5;
//            textField.layer.masksToBounds = YES;
//            textField.text = topWord[i];
//            textField.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
//            textField.textColor = [UIColor darkGrayColor];
////            textField.placeholder = alarmWord[i];
//            
//            [topView addSubview:textField];
//        }
////        if (i == 2)
////        {
////            _statusComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
////            _statusComBox.arrowImgName = @"downArrow.png";
////            _statusComBox.titlesList = _itemsArray;
////            _statusComBox.delegate = self;
////            _statusComBox.supView = topView;
////            [_statusComBox defaultSettings];
////            
////            [topView addSubview:_statusComBox];
////        }
//    }
//    
//    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 10, kScreenWidth, 170)];
//    buttomView.backgroundColor = [UIColor whiteColor];
//    
//    [self.view addSubview:buttomView];
//    
//    [self.view sendSubviewToBack:buttomView];
//    
//    NSArray *buttomTitle = @[@"联系人姓名", @"手机号码"];
//    NSArray *buttomWord = @[kNullToString(_phoneName), kNullToString(_phoneNumber)];
//    for (int i = 0; i < 2; i ++)
//    {
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 * i, 100, 50)];
//        titleLabel.text = buttomTitle[i];
//        titleLabel.textColor = [UIColor darkGrayColor];
//        titleLabel.textAlignment = NSTextAlignmentRight;
//        titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//        
//        [buttomView addSubview:titleLabel];
//        
//        
//        EditTextField *textField = [[EditTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//        textField.layer.borderColor = [UIColor grayColor].CGColor;
//        textField.layer.borderWidth = 1;
//        textField.layer.cornerRadius = 5;
//        textField.layer.masksToBounds = YES;
//        textField.text = buttomWord[i];
//        textField.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
//        textField.textColor = [UIColor darkGrayColor];
//        
//        [buttomView addSubview:textField];
//        
//        if (i == 1)
//        {
////            textField.placeholder = alarmWord[2];
//        }
//    }
//    
//    UIButton *commit = [UIButton buttonWithType:UIButtonTypeCustom];
//    commit.frame = CGRectMake(20, 120, (kScreenWidth - 60) / 2, 30);
//    commit.backgroundColor = kBlueColor;
//    [commit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [commit setTitle:@"保存并提交" forState:UIControlStateNormal];
//    commit.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//    //    [commit addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
//    commit.layer.masksToBounds = YES;
//    commit.layer.cornerRadius = 5;
//    
//    [buttomView addSubview:commit];
//    
//    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
//    cancel.frame = CGRectMake(CGRectGetMaxX(commit.frame) + 20, 120, (kScreenWidth - 60) / 2, 30);
//    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancel setTitle:@"取消" forState:UIControlStateNormal];
//    cancel.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//    //    [commit addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
//    cancel.layer.masksToBounds = YES;
//    cancel.layer.cornerRadius = 5;
//    cancel.layer.borderWidth = 1;
//    cancel.layer.borderColor = [UIColor blackColor].CGColor;
//    
//    [buttomView addSubview:cancel];
    for (int i = 0; i < 2; i ++)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (50 + 0.5) * i, 100, 50)];
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
            _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            _name.layer.borderColor = [UIColor grayColor].CGColor;
//            _name.layer.borderWidth = 1;
//            _name.layer.cornerRadius = 5;
//            _name.layer.masksToBounds = YES;
            _name.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
            _name.textColor = kOrangeColor;
            _name.text = topWord[i];
            _name.textAlignment = NSTextAlignmentCenter;
//            _name.placeholder = alarmWord[i];
            
            [topView addSubview:_name];
        }
        if (i == 1) {
            _short_name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            _short_name.layer.borderColor = [UIColor grayColor].CGColor;
//            _short_name.layer.borderWidth = 1;
//            _short_name.layer.cornerRadius = 5;
//            _short_name.layer.masksToBounds = YES;
            _short_name.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
            _short_name.textColor = kOrangeColor;
            _short_name.text = topWord[i];
            _short_name.textAlignment = NSTextAlignmentCenter;
//            _short_name.placeholder = alarmWord[i];
            
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
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 10, kScreenWidth, 170)];
    buttomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:buttomView];
    
    [self.view sendSubviewToBack:buttomView];
    
    NSArray *buttomTitle = @[@"联系人姓名", @"手机号码", @"邮箱"];
    for (int i = 0; i < 3; i ++)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50 * i, 100, 50)];
        titleLabel.text = buttomTitle[i];
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
        
        [buttomView addSubview:titleLabel];
        
        if (i == 0)
        {
            _contact_name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            _contact_name.layer.borderColor = [UIColor grayColor].CGColor;
//            _contact_name.layer.borderWidth = 1;
//            _contact_name.layer.cornerRadius = 5;
//            _contact_name.layer.masksToBounds = YES;
            _contact_name.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
            _contact_name.textColor = kOrangeColor;
            _contact_name.text = topWord[2];
            _contact_name.textAlignment = NSTextAlignmentCenter;
            
            [buttomView addSubview:_contact_name];
        }
        if (i == 1)
        {
            _mobile_phone = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            _mobile_phone.layer.borderColor = [UIColor grayColor].CGColor;
//            _mobile_phone.layer.borderWidth = 1;
//            _mobile_phone.layer.cornerRadius = 5;
//            _mobile_phone.layer.masksToBounds = YES;
            _mobile_phone.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
            _mobile_phone.textColor = kOrangeColor;
            _mobile_phone.text = topWord[3];
            _mobile_phone.textAlignment = NSTextAlignmentCenter;

//            _mobile_phone.placeholder = alarmWord[2];
//            _mobile_phone.keyboardType = UIKeyboardTypePhonePad;
            
            [buttomView addSubview:_mobile_phone];
        }
        if (i == 2)
        {
            _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 20, CGRectGetMinY(titleLabel.frame) + 10, kScreenWidth - CGRectGetMaxX(titleLabel.frame) - 20 - 30, 30)];
//            _emailLabel.layer.borderColor = [UIColor grayColor].CGColor;
//            _emailLabel.layer.borderWidth = 1;
//            _emailLabel.layer.cornerRadius = 5;
//            _emailLabel.layer.masksToBounds = YES;
            _emailLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
            _emailLabel.textColor = kOrangeColor;
            _emailLabel.text = topWord[4];
            _emailLabel.textAlignment = NSTextAlignmentCenter;

//            _email.placeholder = alarmWord[3];
            
            [buttomView addSubview:_emailLabel];
        }
    }

}

#pragma mark - LMComBoxDelegate -

-(void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    YunLog(@"点击点击点击");
    
    [self.view endEditing:YES];
}
@end
