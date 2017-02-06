//
//  WebViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "WebViewController.h"

// Libraries
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

// Views
#import "KLCPopup.h"
#import "YunShareView.h"

//Common
#import "LibraryHeadersForCommonController.h"

@interface WebViewController () <UIWebViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, NJKWebViewProgressDelegate, YunShareViewDelegate>

@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation WebViewController


#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    [self.navigationController.navigationBar addSubview:_progressView];
    
//    [TalkingData trackPageBegin:@"进入 WebView 页面"];
}

- (void)viewWillDisappear:(BOOL)animated
{    
//    [TalkingData trackPageEnd:@"离开 WebView 页面"];
    
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 监听进入后台和前台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = _naviTitle;
    
    self.navigationItem.titleView = naviTitle;
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    if (kDeviceOSVersion < 7.0) {
        _webView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64);
    }
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:_webView];

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    
    YunLog(@"alipay url = %@", [NSURLRequest requestWithURL:[NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openShare
{
//    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[@"Test", @"测试", @"http://www.yundianjia.com"] applicationActivities:nil];
//    avc.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
//    
//    [self presentViewController:avc animated:YES completion:nil];
    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@"分享到新浪微博", @"分享给微信好友", @"分享到微信朋友圈", nil];
//    [sheet showInView:self.view];
    
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_weixin" , @"title" : @"微信"},
                                                                     
                                                                     @{@"icon" : @"share_weixin_friend" , @"title" : @"朋友圈"},
                                                                     
                                                                     @{@"icon" : @"share_weibo" , @"title" : @"微博"}]
                                                         bottomBar:@[]
                               ];
    
    shareView.delegate = self;
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
}

- (void)isWeiXinInstalled:(NSInteger)scene
{
    if ([WXApi isWXAppInstalled]) {        
        [Tool shareToWeiXin:scene
                      title:_shareParams[@"title"]
                description:_shareParams[@"desc"]
                      thumb: _shareParams[@"logo"]   
                        url:_url];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"未安装微信客户端，去下载？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"现在下载", nil];
        [alert show];
    }
}

- (void)applicationWillEnterForeground:(NSNotification*)note
{

}
- (void)applicationDidEnterBackground:(NSNotification*)note
{
    
}

#pragma mark - UIWebViewDelegate -

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    YunLog(@"open %@ url error = %@", _naviTitle, error);
    
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    if ([error.localizedDescription isEqualToString:@"Frame load interrupted"]) {
        return;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_shareParams) {
        UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 30, 32)];
        [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
        [share addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:share];
        shareItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.rightBarButtonItem = shareItem;
    }
}

#pragma mark - UIActionSheetDelegate -

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (id so in actionSheet.subviews) {
        if ([so isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)so;
            button.titleLabel.font = kNormalBoldFont;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 微博分享内容
    NSString *title = _shareParams[@"title"];
    NSString *desc = _shareParams[@"desc"];
    
    NSUInteger titleLength = title.length;
    NSUInteger descLength = desc.length;
    NSUInteger urlLength = _url.length;
    
    if (titleLength + descLength + urlLength > 136) {
        desc = [desc substringWithRange:NSMakeRange(0, 136 - titleLength - urlLength)];
    }
    
    NSString *description = [NSString stringWithFormat:@"#%@# %@ %@", title, desc, _url];
    
    switch (buttonIndex) {
        case 0:
            [Tool shareToWeiBo:kNullToString(_shareParams[@"logo"]) description:description];
            
            break;
            
        case 1:
            [self isWeiXinInstalled:WXSceneSession];
            break;
            
        case 2:
            [self isWeiXinInstalled:WXSceneTimeline];
            break;
            
        default:
            break;
    }
}

#pragma mark - NJKWebViewProgressDelegate -

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

#pragma mark - UIAlertViewDelegate -

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    for (id so in alertView.subviews) {
        if ([so isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)so;
            label.font = kNormalBoldFont;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
    }
}

#pragma mark - YunShareDelegate - 

- (void)shareViewDidSelectView:(YunShareView *)shareView inSection:(NSUInteger)section index:(NSUInteger)index
{
    // 微博分享内容
    NSString *title = _shareParams[@"title"];
    NSString *desc = _shareParams[@"desc"];
    
    NSUInteger titleLength = title.length;
    NSUInteger descLength = desc.length;
    NSUInteger urlLength = _url.length;
    
    if (titleLength + descLength + urlLength > 136) {
        desc = [desc substringWithRange:NSMakeRange(0, 136 - titleLength - urlLength)];
    }
    
    NSString *description = [NSString stringWithFormat:@"#%@# %@ %@", title, desc, _url];
    
    switch (index) {
        case 0:
            [self isWeiXinInstalled:WXSceneSession];
            
            break;
            
        case 1:
           
            [self isWeiXinInstalled:WXSceneTimeline];
            
            break;
            
        case 2:
            [Tool shareToWeiBo:kNullToString(_shareParams[@"logo"]) description:description];
            
            break;
            
        default:
            break;
    }
}

@end
