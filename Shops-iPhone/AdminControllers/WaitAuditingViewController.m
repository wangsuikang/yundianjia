//
//  WaitAuditingViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/18.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "WaitAuditingViewController.h"

#import "LibraryHeadersForCommonController.h"

#import "PopGestureRecognizerController.h"
#import "IndexTabViewController.h"
#import "AppDelegate.h"

#define kSpace 10

@interface WaitAuditingViewController ()

@property (nonatomic, strong) UIView *nextView;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation WaitAuditingViewController

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = kBackgroundColor;
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.alpha = 0.0;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        
        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSArray *list=self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.alpha = 1.0;
            }];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectZero;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
//    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,30,30)];
//    [rightButton addTarget:self action:@selector(enterBuyClick:)forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    
//    self.navigationItem.rightBarButtonItem= rightItem;
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CreateUI -

- (void)createUI
{
    _nextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _nextView.backgroundColor = kWhiteColor;
    
    [self.view addSubview:_nextView];
    
    // 右上角按钮
    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth - 200) / 2, kScreenHeight - 44, 200, 44)];
    [rightButton addTarget:self action:@selector(enterBuyClick:)forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"进入买家版看看吧!" forState:UIControlStateNormal];
    [rightButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = kNormalFont;
    
    [self.view addSubview:rightButton];
    
    // 添加背景图片
    UIImageView *nextBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    if ([_status isEqualToString:@"1"]) {
        if (kScreenWidth > 320) {
            nextBgImageView.image = [UIImage imageNamed:@"auditin_1_iphone6"];
        } else {
            nextBgImageView.image = [UIImage imageNamed:@"auditin_1_iphone4"];
        }
    }
    
    if ([_status isEqualToString:@"2"]) {
        if (kScreenWidth > 320) {
            nextBgImageView.image = [UIImage imageNamed:@"auditin_2_iphone6"];
        } else {
            nextBgImageView.image = [UIImage imageNamed:@"auditin_2_iphone4"];
        }
    }
    
    if ([_status isEqualToString:@"4"]) {
        if (kScreenWidth > 320) {
            nextBgImageView.image = [UIImage imageNamed:@"auditin_4_iphone6"];
        } else {
            nextBgImageView.image = [UIImage imageNamed:@"auditin_4_iphone4"];
        }
    }
    
    [_nextView addSubview:nextBgImageView];
    
    // 添加进入买家首页的按钮
//    UIButton *enterBuy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 160, 2 * kSpace, 150, 20)];
//    [enterBuy setTitle:@"进入买家版看看吧!" forState:UIControlStateNormal];
//    [enterBuy setTitleColor:kOrangeColor forState:UIControlStateNormal];
//    enterBuy.backgroundColor = [UIColor redColor];
//    enterBuy.titleLabel.font = kSizeFont;
//    [enterBuy addTarget:self action:@selector(enterBuyClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_nextView addSubview:enterBuy];
}

- (void)enterBuyClick:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        ShopListDataSource *dataSource = [ShopListDataSource sharedDataSource];
//        
//        [dataSource reloadData];
//    });
    
    _hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    _hud.labelText = @"正在努力跳转...";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud hide:YES];
        
        appDelegate.indexTab = [[IndexTabViewController alloc] init];
        
        appDelegate.window.rootViewController = appDelegate.indexTab;
        [appDelegate.window makeKeyAndVisible];
    });
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
