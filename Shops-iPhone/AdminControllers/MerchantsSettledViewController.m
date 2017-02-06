//
//  MerchantsSettledViewController.m
//  Shops-iPhone
//
//  Created by cml on 16/8/9.
//  Copyright © 2016年 net.atyun. All rights reserved.
//

#import "MerchantsSettledViewController.h"

// Controllers
#import "EnterpriseSettledViewController.h"
#import "PersonalSettledViewController.h"

@interface MerchantsSettledViewController ()

@end

@implementation MerchantsSettledViewController

#pragma mark - Initialization -

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kLightBlackColor;
        naviTitle.alpha = 0.8;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"商家入驻";
        
        self.navigationItem.titleView = naviTitle;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        backItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
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
    CGFloat height = kScreenWidth * 360 / 320;
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    backImageView.image = [UIImage imageNamed:@"settled_back"];
    
    [self.view addSubview:backImageView];
    
    CGFloat buttonHeight = (kScreenWidth - 20) * 50 / 300;
    
    UIButton *enterprise = [[UIButton alloc] initWithFrame:CGRectMake(10, kScreenHeight - 64 - 15 - buttonHeight, kScreenWidth - 20, buttonHeight)];
//    enterprise.backgroundColor = kRedColor;
    [enterprise setBackgroundImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [enterprise setTitle:@"企业用户商家入驻" forState:UIControlStateNormal];
    [enterprise setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    enterprise.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    [enterprise addTarget:self action:@selector(gotoSettled:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:enterprise];
    
    UIButton *personal = [[UIButton alloc] initWithFrame:CGRectMake(10, kScreenHeight - 64 - 15 * 2 - buttonHeight * 2, kScreenWidth - 20, buttonHeight)];
//    personal.backgroundColor = kRedColor;
    [personal setBackgroundImage:[UIImage imageNamed:@"button_back"] forState:UIControlStateNormal];
    [personal setTitle:@"个人用户商家入驻" forState:UIControlStateNormal];
    [personal setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    personal.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    [personal addTarget:self action:@selector(gotoSettled:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:personal];
}

- (void)gotoSettled:(UIButton *)sender
{
    if ([sender.currentTitle isEqualToString:@"个人用户商家入驻"]) {
        PersonalSettledViewController *personal = [[PersonalSettledViewController alloc] init];
        
        [self.navigationController pushViewController:personal animated:YES];
    } else {
        EnterpriseSettledViewController *enterprise = [[EnterpriseSettledViewController alloc] init];
        
        [self.navigationController pushViewController:enterprise animated:YES];
    }
}
@end
