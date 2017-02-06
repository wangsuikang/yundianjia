//
//  FeedbackViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "FeedbackViewController.h"

#import "Tool.h"
#import "LibraryHeadersForCommonController.h"

@interface FeedbackViewController () <UITextViewDelegate>

@property (nonatomic, copy) NSString *commitText;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FeedbackViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = [UIColor clearColor];
        naviTitle.textColor = [UIColor whiteColor];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"意见反馈";
        
        self.navigationItem.titleView = naviTitle;
        
        _commitText = @"";
    }
    return self;
}

#pragma mark - UIView Functions -

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *commit = [UIButton buttonWithType:UIButtonTypeCustom];
    commit.frame = CGRectMake(kScreenWidth - 25, 0, 25, 25);
    [commit setImage:[UIImage imageNamed:@"commit_feedback.png"] forState:UIControlStateNormal];
    [commit setImage:[UIImage imageNamed:@"commit_feedback_disabled.png"] forState:UIControlStateDisabled];
    [commit addTarget:self action:@selector(commitFeedBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *commitItem = [[UIBarButtonItem alloc] initWithCustomView:commit];
    commitItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = commitItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    textView.layer.borderWidth = 1.0;
    textView.layer.cornerRadius = 5.0;
    textView.clipsToBounds = YES;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.textColor = [UIColor blackColor];
    textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"feed_back.png"]];
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.returnKeyType = UIReturnKeyDefault;
    textView.keyboardType = UIKeyboardTypeDefault;
    textView.scrollEnabled = YES;
    textView.delegate = self;
    textView.font = kNormalFont;
    
    [self.view addSubview:textView];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [textView becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate -

- (void)textViewDidChange:(UITextView *)textView
{
    _commitText = textView.text;
    
    if (![_commitText isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Private Functions -

- (void)backToPrev:(UIButton *)sender
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commitFeedBack
{
    YunLog(@"%@", _commitText);
    
    if (![Tool isNetworkAvailable]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"当前网络不可用,请检查您的网络" delay:2.0];
    }
}

@end
