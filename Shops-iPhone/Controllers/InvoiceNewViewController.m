//
//  InvoiceNewViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-14.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "InvoiceNewViewController.h"

// Classes
#import "AppDelegate.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface InvoiceNewViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation InvoiceNewViewController

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
        naviTitle.text = @"新增发票";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame = CGRectMake(0, 0, 40, 44);
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(returnView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:close];
    
    self.navigationItem.leftBarButtonItem = closeItem;
    
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(0, 0, 40, 44);
    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [done addTarget:self action:@selector(commitInvoice) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:done];
    
    self.navigationItem.rightBarButtonItem = doneItem;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 120)];
    _textView.delegate = self;
    _textView.text = @"";
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.layer.borderWidth = 1;
    _textView.layer.cornerRadius = 6;
    _textView.layer.masksToBounds = YES;
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.font = kNormalFont;
    
    [self.view addSubview:_textView];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_textView becomeFirstResponder];
    });
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
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)commitInvoice
{
    if ([_textView.text isEqualToString:@""]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请输入发票抬头" delay:1.0];
        
        return;
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:_textView.text forKey:@"title"];
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:appDelegate.user.invoices];
    [temp addObject:dic];
    
    appDelegate.user.invoices = [NSArray arrayWithArray:temp];
    
    [self returnView];
}

#pragma mark - UITextViewDelegate -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self commitInvoice];
        
        return NO;
    } else {
        return YES;
    }
}

@end
