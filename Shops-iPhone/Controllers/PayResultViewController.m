//
//  PayResultViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-12-10.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "PayResultViewController.h"

#import "UIButtonForBarButton.h"

#import "LibraryHeadersForCommonController.h"

@interface PayResultViewController () <UIWebViewDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation PayResultViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = [UIColor clearColor];
        naviTitle.textColor = [UIColor orangeColor];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"订单支付";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

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

#pragma mark - UIView Functions -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    YunLog(@"_payURL = %@", _payURL);
    
//    UIButtonForBarButton *close = [[UIButtonForBarButton alloc] initWithTitle:@"关闭" wordLength:@"2"];
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [close setBackgroundColor:kClearColor];
    close.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    close.titleLabel.textAlignment = NSTextAlignmentCenter;
    [close addTarget:self action:@selector(returnView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:close];
    
    self.navigationItem.leftBarButtonItem = closeItem;
	
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"请求支付...";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_payURL]];
    
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)returnView
{
    if (_hud) [_hud hide:NO];
    
    [kNotificationCenter postNotificationName:kOrderPaySucceedNotification object:nil];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate -

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_hud) [_hud hide:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    YunLog(@"open web pay url error = %@", error);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
    
    [self returnView];
}

@end
