//
//  MyQRCodeViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-4-16.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyQRCodeViewController.h"

#import "LibraryHeadersForCommonController.h"

// Classes
#import "QRCodeGenerator.h"

@interface MyQRCodeViewController ()

@end

@implementation MyQRCodeViewController

#pragma mark - Initialization -

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"我的二维码";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(20, 20 + kCustomNaviHeight, kScreenWidth - 40, kScreenHeight - 40 - kCustomNaviHeight)];
    back.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:back];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, back.frame.size.width - 40, 36)];
    name.backgroundColor = kClearColor;
    name.font = kNormalFont;
    name.text = kNullToString(_shopName);
    
    [back addSubview:name];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = [UIColor lightGrayColor].CGColor;
    line.frame = CGRectMake(20, 56, name.frame.size.width, 2);
    
    [back.layer addSublayer:line];
    
    CGFloat qrcodeWidth = kIsiPhone ? 240 : 400;
    
    CGFloat qrcodeButtonHeight = 58 + (back.frame.size.height - 58 - 32 - qrcodeWidth) / 2;
    
    UIButton *qrcodeButton = [[UIButton alloc] initWithFrame:CGRectMake((back.frame.size.width - qrcodeWidth) / 2, qrcodeButtonHeight, qrcodeWidth, qrcodeWidth)];
    [qrcodeButton setImage:[QRCodeGenerator qrImageForString:kNullToString(_shopURL) imageSize:qrcodeWidth]
                  forState:UIControlStateNormal];
//    [qrcodeButton addTarget:self action:@selector(openActionSheet) forControlEvents:UIControlEventTouchUpInside];
    
    [back addSubview:qrcodeButton];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(20, back.frame.size.height - 42, back.frame.size.width - 40, 32)];
    notice.backgroundColor = kClearColor;
    notice.font = kSmallFont;
    notice.text = @"扫描二维码收藏店铺";
    notice.textColor = [UIColor lightGrayColor];
    notice.textAlignment = NSTextAlignmentCenter;
    
    [back addSubview:notice];
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

- (void)openActionSheet
{
    
}

@end
