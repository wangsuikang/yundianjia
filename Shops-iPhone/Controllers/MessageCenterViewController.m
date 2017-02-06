//
//  MessageCenterViewController.h
//  Shops-iPhone
//
//  Created by rujax on 14-3-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MessageCenterViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"

// Controllers
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "ProductDetailViewController.h"
#import "WebViewController.h"
#import "ActivityViewController.h"

@interface MessageCenterViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *messages;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MessageCenterViewController

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
        naviTitle.text = @"消息中心";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
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
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"app_id"                  :   kBundleID,
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *messageURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kAppMessageURL params:params];
    
    YunLog(@"messageURL = %@", messageURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:messageURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 _messages = [[responseObject objectForKey:@"data"] objectForKey:@"messages"];
                 
                 [_tableView reloadData];
                 
                 [_hud hide:YES];
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             
             YunLog(@"get message error = %@", error);
         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = _messages[indexPath.row];
    
    CGSize size = [kNullToString([message objectForKey:@"text"]) sizeWithFont:kNormalFont
                                                                         size:CGSizeMake(kScreenWidth - 40, 9999)];
    
    return 10 + size.height + 20 + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *message = _messages[indexPath.row];
    
    CGSize size = [kNullToString([message objectForKey:@"text"]) sizeWithFont:kNormalFont
                                                                         size:CGSizeMake(kScreenWidth - 40, 9999)];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth - 40, size.height)];
    textLabel.backgroundColor = kClearColor;
    textLabel.font = kNormalFont;
    textLabel.textColor = [UIColor grayColor];
    textLabel.numberOfLines = 0;
    textLabel.text = kNullToString([message objectForKey:@"text"]);
    
    [cell.contentView addSubview:textLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10 + size.height + 2, kScreenWidth - 40, 16)];
    timeLabel.backgroundColor = kClearColor;
    timeLabel.font = [UIFont fontWithName:kFontFamily size:14];
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.text = kNullToString([message objectForKey:@"time"]);
    
    [cell.contentView addSubview:timeLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = _messages[indexPath.row];
    
    NSString *category = kNullToString([message objectForKey:@"category"]);
    NSInteger categoryInt = [category integerValue];
    NSString *content = kNullToString([message objectForKey:@"content"]);
    
    @try {
        switch (categoryInt) {
            case NotificationShop:
            {
//                ShopInfoViewController *shop = [[ShopInfoViewController alloc] init];
//                shop.code = content;
//                shop.hidesBottomBarWhenPushed = YES;
//                
//                [self.navigationController pushViewController:shop animated:YES];
                
                ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
                shop.code = content;
                shop.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:shop animated:YES];
                
                break;
            }
                
            case NotificationProduct:
            {
                ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
                detail.productCode = content;
                detail.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:detail animated:YES];
                
                break;
            }
                
            case NotificationWebView:
            {
                WebViewController *web = [[WebViewController alloc] init];
                web.url = content;
                web.naviTitle = @"推送消息";
                web.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:web animated:YES];
                
                break;
            }
                
            case NotificationProductFormat:
            {
//                ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
//                detail.code = content;
//                detail.hidesBottomBarWhenPushed = YES;
//                
//                [self.navigationController pushViewController:detail animated:YES];
                
                break;
            }
                
            case NotificationActivity:
            {
                ActivityViewController *activity = [[ActivityViewController alloc] init];
                activity.activityID = content;
                activity.activityName = @"最新活动";
                activity.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:activity animated:YES];
                
                break;
            }
                
            case NotificationUpdateVersion:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yun-dian-jia/id783464466?mt=8"]];
                
                break;
            }
                
            case NotificationOther:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:content
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                break;
            }
                
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        YunLog(@"didReceiveRemoteNotification, exception = %@", exception);
    }
    @finally {
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
