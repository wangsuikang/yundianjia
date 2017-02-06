//
//  AboutViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AboutViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"

// Views
#import "SplitLineView.h"

// Controllers
#import "FeedbackViewController.h"
#import "WebViewController.h"
#import "MessageCenterViewController.h"
#import "OpenShopViewController.h"
#import "MyShopListViewController.h"
#import "LoginViewController.h"
#import "PopGestureRecognizerController.h"
#import "AdminHomeViewController.h"
//#import "CartNewViewController.h"

// Categories
#import "NSFileManager+FileSize.h"

#import "RateProductViewController.h"

#define kSpace 10

@interface AboutViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

/// 滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;

// tableView
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *imageData;

@property (nonatomic, strong) NSMutableArray *titleData;

//@property (nonatomic, strong) UIButton *exitBtn;

/// trackView数据请求路劲
@property (nonatomic, copy) NSString *trackViewUrl;

/// 三方库AFHTTPRequestOperation对象
@property (nonatomic, strong) AFHTTPRequestOperation *versionOP;

/// 三方库MBProgressHUD对象
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AboutViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"关于我们";
        
        self.navigationItem.titleView = naviTitle;
        
        self.tabBarItem.image = [[UIImage imageNamed:@"about_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"about_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem.title = @"关于";
    }
    return self;
}

/**
 popViewController方法返回上一个视图
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
    NSString *cartCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"];
    if ([cartCount intValue] == 0) {
        cartVC.tabBarItem.badgeValue = nil;
    } else {
        cartVC.tabBarItem.badgeValue = cartCount;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    NSArray *buySaleArray = @[@"buy_sale_barter"];
    NSArray *buySaleTitleArray = @[@"卖家在这里"];
    
    NSArray *yunNames = @[@"意见反馈",/* @"服务条款",*/ @"关于我们"];
    NSArray *yunImages = @[@"feedback_rd",/* @"clause_rd",*/ @"about_rd"];
    
//    NSArray *toolNames = @[@"为我打分", @"清理缓存", @"我的购物车测试"];
//    NSArray *imageNames = @[@"comment_for_me_rd", @"clean_cache_rd", @"clean_cache_rd"];
    NSArray *toolNames = @[@"为我打分", @"清理缓存"];
    NSArray *imageNames = @[@"comment_for_me_rd", @"clean_cache_rd"];
    
    _imageData = [NSMutableArray arrayWithObjects:buySaleArray, yunImages, imageNames, nil];
    _titleData = [NSMutableArray arrayWithObjects:buySaleTitleArray, yunNames, toolNames, nil];
    
    [self createUI];
}

- (void)createUI
{
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, 40)];
    topBgView.backgroundColor = kGrayColor;
    
    [self.view addSubview:topBgView];
    
    UILabel *yunLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 30, 40)];
    yunLabel.backgroundColor = kClearColor;
    yunLabel.font = kNormalFont;
    yunLabel.textColor = [UIColor lightGrayColor];
    yunLabel.text = [NSString stringWithFormat:@"云店家 ver%@.%@", kAppVersion, kAppBuild];
    
    [topBgView addSubview:yunLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight + topBgView.bounds.size.height, kScreenWidth, kScreenHeight - kNavTabBarHeight - 40) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kGrayColor;
    _tableView.bounces = NO;
    
    [self.view addSubview:_tableView];
}

#pragma mark - TableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _imageData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_imageData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSArray *imageArray = _imageData[indexPath.section];
    NSArray *titleArray = _titleData[indexPath.section];
    
    cell.imageView.image = [UIImage imageNamed:imageArray[indexPath.row]];
    
    cell.textLabel.text = titleArray[indexPath.row];
    
    if (kIsiPhone) {
        cell.textLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:kFontLargeSize];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            [self loginEnterSale];
            
            break;
        }
            
        case 1:
        {
            WebViewController *web = [[WebViewController alloc] init];
            web.hidesBottomBarWhenPushed = YES;
            
            if (indexPath.row == 0) {
                // 意见反馈
                web.naviTitle = @"意见反馈";
                
                AppDelegate *appDelegate = kAppDelegate;
                if (appDelegate.isLogin) {
                    web.url = [kFeedbackURL stringByAppendingString:[NSString stringWithFormat:@"&phone=%@", appDelegate.user.username]];;
                } else {
                    web.url = kFeedbackURL;
                }

//            } else if (indexPath.row == 1) {
//                // 服务条款
//                web.naviTitle = @"服务条款";
//                web.url = kClauseURL;
            } else {
                // 关于我们
                web.naviTitle = @"关于我们";
                web.url = kAboutShopURL;
            }
            
            [self.navigationController pushViewController:web animated:YES];
            
            break;
        }
            
        case 2:
        {
            if (indexPath.row == 0) {
                // 为我打分
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yun-dian-jia/id783464466?mt=8"]];
            } else if (indexPath.row == 1) {
                // 清理缓存
                [self showCache];
            } else if (indexPath.row == 2){
                // 进入我的购物车测试页面
//                CartNewViewController *cartNew = [[CartNewViewController alloc] init];
//                
//                [self.navigationController pushViewController:cartNew animated:YES];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kIsiPhone) {
        return 44;
    } else {
        return 80;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0000001;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)loginEnterSale
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin && appDelegate.user.userType == 1)
    {
        for (id so in appDelegate.window.subviews) {
            [so removeFromSuperview];
        }
        
        AdminHomeViewController *adminVC = [[AdminHomeViewController alloc] init];
        adminVC.isBuyEnter = YES;
        PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:adminVC];
        
        appDelegate.window.rootViewController = popNC;
        [appDelegate.window makeKeyAndVisible];
    } else if (appDelegate.isLogin && (appDelegate.user.userType == 2 || appDelegate.user.userType == 3)) {
        for (id so in appDelegate.window.subviews) {
            [so removeFromSuperview];
        }
        
        MyShopListViewController *shopVC = [[MyShopListViewController alloc] init];
        
        PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:shopVC];
        
        appDelegate.window.rootViewController = popNC;
        [appDelegate.window makeKeyAndVisible];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"需要先登录哟" delay:1.5];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isReturnView = YES;
            loginVC.isBuyEnter = YES;
            loginVC.isCartNewEnter = YES;
            
            UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            
            [self.navigationController presentViewController:loginNC animated:YES completion:nil];
        });
    }
}

/**
 pushViewController推出下一个视图控制器
 
 @param sender 被点击按钮
 */
- (void)pushToWebVC:(UIButton *)sender
{
    WebViewController *web = [[WebViewController alloc] init];
    web.hidesBottomBarWhenPushed = YES;
    
    if (sender.tag == 0) {
        web.naviTitle = @"意见反馈";
        
        AppDelegate *appDelegate = kAppDelegate;
        if (appDelegate.isLogin) {
            web.url = [kFeedbackURL stringByAppendingString:[NSString stringWithFormat:@"&phone=%@", appDelegate.user.username]];;
        } else {
            web.url = kFeedbackURL;
        }
    }
    else if (sender.tag == 1) {
        web.naviTitle = @"服务条款";
        web.url = kClauseURL;
    }
    else if (sender.tag == 2) {
        web.naviTitle = @"关于我们";
        web.url = kAboutShopURL;
    }
    
    [self.navigationController pushViewController:web animated:YES];
}

/**
 跳转到“我要开店”页面
 
 @param sender 被点击按钮
 */
- (void)pushToOpenShop:(UIButton *)sender
{
    OpenShopViewController *openShopViewCon = [[OpenShopViewController alloc] init];
    
    openShopViewCon.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:openShopViewCon animated:YES];
}

/**
 进入AppStore本款APP下载页面
 */
- (void)openCommentPage
{
    //RateProductViewController *rateController = [[RateProductViewController alloc] init];
    //rateController.hidesBottomBarWhenPushed = YES;
    //[self.navigationController pushViewController:rateController animated:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yun-dian-jia/id783464466?mt=8"]];
}

/**
 计算缓存，显示缓存
 */
- (void)showCache
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"shops"];
    
    NSError *error;
    
    NSArray *paths = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
    
    YunLog(@"paths = %@", paths);
    
    long long size = 0;
    
    for (int i = 0; i < paths.count; i++) {
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:paths[i]];
        
        size += [fileManager fileSizeAtPath:filePath];
    }
    
    YunLog(@"cache file total size = %lld", size);
    
    NSString *sizeStr;
    
    if (size < 1024 && size > 0) {
        sizeStr = [NSString stringWithFormat:@"%lld B", size];
    } else if (size >= 1024 && size < 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%.1f KB", (float)size / 1024];
    } else if (size >= 1024 * 1024) {
        sizeStr = [NSString stringWithFormat:@"%.1f MB", (float)size / 1024 / 1024];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"还没有缓存哟 ~";
        
        [_hud hide:YES afterDelay:2.0];
        
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"缓存大小"
                                                        message:sizeStr
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"清理", nil];
    alertView.tag = 113;
    
    [alertView show];
}

/**
 清理缓存
 */
- (void)cleanCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"shops"];
    
    NSError *error;
    NSArray *paths = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
    
    YunLog(@"paths = %@", paths);
    
    for (int i = 0; i < paths.count; i++) {
        NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:paths[i]];
        
        if ([fileManager removeItemAtPath:filePath error:&error]) {
            YunLog(@"delete file success, path = %@", filePath);
        } else {
            YunLog(@"delete file failure, path = %@, error = %@", filePath, error);
        }
    }
	
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [_hud addSuccessString:@"缓存清理完成" delay:1.0];
}

/**
 检测版本更新
 */
- (void)scanNewVersion
{
    if ([Tool isNetworkAvailable]) {
        UIAlertView *scanAlert = [[UIAlertView alloc] initWithTitle:@"正在检测..."
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:nil];
        scanAlert.tag = 112;
        [scanAlert show];
        
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aiv.center = CGPointMake(scanAlert.bounds.size.width / 2, scanAlert.bounds.size.height - 40);
        [aiv startAnimating];
        [scanAlert addSubview:aiv];
        
        NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@&country=cn", kAppID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        _versionOP = [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            YunLog(@"scan update responseObject = %@", responseObject);
            
            NSDictionary *results = [responseObject objectForKey:@"results"];
            YunLog(@"scan update results = %@", results);
            
            _trackViewUrl = kNullToString([[results valueForKey:@"trackViewUrl"] objectAtIndex:0]);
            YunLog(@"_trackViewUrl = %@", _trackViewUrl);
            
            NSString *currentVersion = kNullToString([[results valueForKey:@"version"] objectAtIndex:0]);
            
            [scanAlert dismissWithClickedButtonIndex:0 animated:NO];
            
            if (![kAppVersion isEqualToString:currentVersion]) {
                UIAlertView *updateView = [[UIAlertView alloc] initWithTitle:@"发现新版本"
                                                                     message:nil
                                                                    delegate:self
                                                           cancelButtonTitle:@"取消"
                                                           otherButtonTitles:@"更新", nil];
                updateView.tag = 111;
                [updateView show];
            } else {
                UIAlertView *alreadyView = [[UIAlertView alloc] initWithTitle:@"已是最新"
                                                                      message:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
                [alreadyView show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [scanAlert dismissWithClickedButtonIndex:0 animated:NO];
            
            YunLog(@"scan update error = %@", error);
            
            if (![operation isCancelled]) {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"服务器繁忙,请稍后再试"
                                                                     message:@""
                                                                    delegate:self
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                [errorAlert show];
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前网络不可用"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

/**
 消息推送
 
 @param sender 被点击按钮
 */
- (void)pushToMessageCenter:(UIButton *)sender
{
    [sender removeBadge];
    
    self.tabBarItem.badgeValue = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"0" forKey:kRemoteNotification];
    
    [defaults synchronize];
    
    MessageCenterViewController *message = [[MessageCenterViewController alloc] init];
    message.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:message animated:YES];
}

#pragma mark - UIAlertViewDelegate -

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 111:
        {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_trackViewUrl]];
            }
            
            break;
        }
            
        case 112:
        {
            if ([_versionOP isExecuting]) {
                [_versionOP cancel];
            }
            
            break;
        }
            
        case 113:
        {
            if (buttonIndex == 1) {
                [self cleanCache];
            }
            
            break;
        }
            
        default:
            break;
    }
}

@end
