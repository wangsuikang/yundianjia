//
//  AboutShopInfoViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/10/14.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import "AboutShopInfoViewController.h"

#import "LibraryHeadersForCommonController.h"

@interface AboutShopInfoViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AboutShopInfoViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"联系商家";
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _webView = [[UIWebView alloc] initWithFrame:kScreenBounds];
    
    _webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    _webView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;//自动检测网页上的电话号码，单击可以拨打//自动检测网页上的电话号码，单击可以拨打
    _webView.autoresizesSubviews = NO; //自动调整大小
    _webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    _webView.delegate = self;
    
    [self.view addSubview:_webView];
    
    NSDictionary *params = @{@"sid"        :     kNullToString(_shopCode)};
    
    NSString *webViewURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kNullToString(@"") requestURL:kAboutShopInfoURL params:params];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:webViewURL]];

    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

/**
 返回上一个界面
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate - 

//代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //返回YES，进行加载。通过UIWebViewNavigationType可以得到请求发起的原因
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //开始加载，可以加上风火轮（也叫菊花）
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    _hud.labelText = @"正在加载中...";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //完成加载
    [_hud addSuccessString:@"加载成功" delay:1.0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //加载出错
    [_hud addErrorString:@"加载失败" delay:1.0];
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
