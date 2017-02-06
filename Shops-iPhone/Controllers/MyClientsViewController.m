//
//  MyClientsViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-4-28.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyClientsViewController.h"

// Views
#import "KLCPopup.h"
#import "YunShareView.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

@interface MyClientsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, YunShareViewDelegate>


@property (nonatomic, strong) NSArray *clients;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyClientsViewController

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
        naviTitle.text = @"我的客户";
        
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _tableView = [[UITableView alloc] initWithFrame:kScreenBounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"shop_id"                 :   kNullToString(_shopID),
                             @"page"                    :   @"1",
                             @"limit"                   :   @"8",
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *clientURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kShopClientURL params:params];
    
    YunLog(@"clientURL = %@", clientURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:clientURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"clientURL responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 _clients = [[responseObject objectForKey:@"data"] objectForKey:@"shop_clients"];
                 
                 [_tableView reloadData];
                 
                 [_hud hide:YES];
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"clientURL error = %@", error);
             
             if (![operation isCancelled]) {
                 [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             }
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

- (void)openShare
{
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_telephone" , @"title" : @"打电话"},
                                                                     
                                                                     @{@"icon" : @"share_message" , @"title" : @"发短信"}]
                                                         bottomBar:@[]
                               ];
    
    shareView.delegate = self;
    [shareView setTip:_titleName];
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _clients.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *username = kNullToString([_clients[indexPath.row] objectForKey:@"user_name"]);
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, (kScreenWidth - 20) / 2, 40)];
    name.backgroundColor = kClearColor;
    name.font = kBigFont;
    name.text = [username isEqualToString:@""] ? kNullToString([_clients[indexPath.row] objectForKey:@"user_phone"]) : username;
    name.textColor = [UIColor orangeColor];
    
    [cell.contentView addSubview:name];
    
    UILabel *phone = [[UILabel alloc] initWithFrame:CGRectMake(10 + (kScreenWidth - 20) / 2, 0, (kScreenWidth - 20) / 2, 40)];
    phone.backgroundColor = kClearColor;
    phone.font = kBigFont;
    phone.text = kNullToString([_clients[indexPath.row] objectForKey:@"user_phone"]);
    phone.textColor = [UIColor orangeColor];
    phone.textAlignment = NSTextAlignmentRight;
    
    [cell.contentView addSubview:phone];
    
    UILabel *lastBuy = [[UILabel alloc] initWithFrame:CGRectMake(10, 34, kScreenWidth - 20, 24)];
    lastBuy.backgroundColor = kClearColor;
    lastBuy.font = kNormalFont;
    lastBuy.text = [NSString stringWithFormat:@"最近一次购买: %@", kNullToString([_clients[indexPath.row] objectForKey:@"last_buy_at"])];
    lastBuy.textColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:lastBuy];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userName = kNullToString([_clients[indexPath.row] objectForKey:@"user_name"]);
    NSString *userPhone = kNullToString([_clients[indexPath.row] objectForKey:@"user_phone"]);
    
    userName = [userName isEqualToString:@""] ? [NSString stringWithFormat:@"%@", userPhone] : userName;
    
   _titleName = [NSString stringWithFormat:@"用户名: %@    手机号: %@", userName, userPhone];
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
//                                                             delegate:self
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@"打电话", @"发短信", nil];
//    actionSheet.tag = indexPath.row;
//    
//    [actionSheet showInView:self.view];
    [[NSUserDefaults standardUserDefaults] setObject:userPhone forKey:@"userPhone"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self openShare];
}

#pragma mark - UIActionSheetDelegate -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *userPhone = kNullToString([_clients[actionSheet.tag] objectForKey:@"user_phone"]);
    
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", userPhone]]];
            
            break;
            
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", userPhone]]];
            
            break;
            
        case 2:

            break;
            
        default:
            break;
    }
}

#pragma mark - YunShareViewDelegate -

- (void)shareViewDidSelectView:(YunShareView *)shareView inSection:(NSUInteger)section index:(NSUInteger)index {
    YunLog(@"您点击了第%ld排的第%ld个按钮", (long)section + 1, (long)index + 1);

    NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"];
    
    switch (index) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", userPhone]]];
            
            break;
            
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", userPhone]]];
            
            break;
            
        default:
            break;
    }
}

@end
