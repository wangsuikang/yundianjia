//
//  ConsumerChooseViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ConsumerChooseViewController.h"

#import "AppDelegate.h"

#import "AdminHomeViewController.h"
#import "IndexTabViewController.h"
#import "PopGestureRecognizerController.h"

#define kSpace 10

@interface ConsumerChooseViewController ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIButton *buyBtn;

@property (nonatomic, strong) UIButton *saleBtn;

@end

@implementation ConsumerChooseViewController

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];
    
    self.view.backgroundColor = kBackgroundColor;
    
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)createUI
{
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _bgView.backgroundColor = kClearColor;
    
    [self.view addSubview:_bgView];
    
    _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _bgImageView.image = [UIImage imageNamed:@"buy_sale"];
    
    [_bgView addSubview:_bgImageView];
    
    // 添加两个按钮
    _buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(2 * kSpace, kScreenHeight / 2 - 50, (kScreenWidth - 4 * kSpace) / 2, 150)];
//    _buyBtn.backgroundColor = [UIColor redColor];
    [_buyBtn addTarget:self action:@selector(enterBuyIndex:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bgView addSubview:_buyBtn];
    
    _saleBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2, kScreenHeight / 2 - 50, (kScreenWidth - 4 * kSpace) / 2, 150)];
//    _saleBtn.backgroundColor = [UIColor yellowColor];
    [_saleBtn addTarget:self action:@selector(enterSaleIndex:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bgView addSubview:_saleBtn];
}

#pragma mark - Btn Click -

- (void)enterBuyIndex:(UIButton *)sender
{
        AppDelegate *appDelegate = kAppDelegate;
        appDelegate.indexTab = [[IndexTabViewController alloc] init];
    
        appDelegate.window.rootViewController = appDelegate.indexTab;
        [appDelegate.window makeKeyAndVisible];
    
//    SaleAccedeViewController *saleVC = [[SaleAccedeViewController alloc] init];
//    
//    [self presentViewController:saleVC animated:YES completion:nil];
    
}

- (void)enterSaleIndex:(UIButton *)sender
{
    AdminHomeViewController *adminRegVC = [[AdminHomeViewController alloc] init];
//    adminRegVC.is
    
    
    [self.navigationController pushViewController:adminRegVC animated:YES];
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
