//
//  AdminSettingViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminSettingViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Views
#import "SplitLineView.h"
#import "WebViewController.h"
#import "InstructionsViewController.h"
#import "AdminHomeViewController.h"
#import "PopGestureRecognizerController.h"

// Categories
#import "NSFileManager+FileSize.h"

#import "RateProductViewController.h"

#define kSpace 10

@interface AdminSettingViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) NSMutableArray *imageData;

@property (nonatomic, strong) NSMutableArray *titleData;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) UIButton *exitBtn;

@end

@implementation AdminSettingViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kOrangeColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.text = @"设置";
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kGrayColor;
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    NSArray *imagesNameOne = @[@"need_read", @"buy_sale_barter"];
    NSArray *titleNameOne = @[@"商家必读", @"云店家买卖切换"];
    
    NSArray *yunNames = @[@"意见反馈",/* @"服务条款",*/ @"关于我们"];
    NSArray *yunImages = @[@"feedback_rd",/* @"clause_rd", */@"about_rd"];
    
    NSArray *toolNames = @[@"为我打分", @"清理缓存"];
    NSArray *imageNames = @[@"comment_for_me_rd", @"clean_cache_rd"];
    
    _imageData = [NSMutableArray arrayWithObjects:imagesNameOne, yunImages, imageNames, nil];
    _titleData = [NSMutableArray arrayWithObjects:titleNameOne, yunNames, toolNames, nil];
    
    [self createUI];
}

#pragma mark - createUI -

- (void)createUI
{
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, 40)];
    topBgView.backgroundColor = kGrayColor;
    
    [self.view addSubview:topBgView];
    
    UILabel *yunLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, kScreenWidth - 30, 40)];
    yunLabel.backgroundColor = kClearColor;
    yunLabel.font = kNormalFont;
    yunLabel.textColor = [UIColor lightGrayColor];
    yunLabel.text = [NSString stringWithFormat:@"云店家 ver%@", kAppVersion];
    
    [topBgView addSubview:yunLabel];
    
    
    CGFloat weixinLabelWidth = 180;
    UILabel *weixinLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - weixinLabelWidth - kSpace, 0, weixinLabelWidth, 40)];
    weixinLabel.backgroundColor = kClearColor;
    weixinLabel.font = kNormalFont;
    weixinLabel.textColor = [UIColor lightGrayColor];
    weixinLabel.text = @"云店家微信号: yundianjia";
    
    [topBgView addSubview:weixinLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight + topBgView.bounds.size.height, kScreenWidth, kScreenHeight - kNavTabBarHeight - 50 - 50) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kGrayColor;
    
    [self.view addSubview:_tableView];
    
    _exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(2 * kSpace, kScreenHeight - 50, kScreenWidth - 4 * kSpace, 40)];
    [_exitBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [_exitBtn setTitle:@"退  出" forState:UIControlStateNormal];
    _exitBtn.backgroundColor = kOrangeColor;
    _exitBtn.titleLabel.font = kBigBoldFont;
    _exitBtn.layer.cornerRadius = 10;
    _exitBtn.layer.masksToBounds = YES;
    [_exitBtn addTarget:self action:@selector(exitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_exitBtn];
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
             if (indexPath.row == 0) {
                 InstructionsViewController *instructions = [[InstructionsViewController alloc] init];
            
                 [self.navigationController pushViewController:instructions animated:YES];
             }
            
            if (indexPath.row == 1) {
                AppDelegate *appDelegate = kAppDelegate;
                
                _hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
                _hud.labelText = @"正在努力跳转...";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_hud hide:YES];
                    
                    appDelegate.indexTab = [[IndexTabViewController alloc] init];
                    
                    appDelegate.window.rootViewController = appDelegate.indexTab;
                    [appDelegate.window makeKeyAndVisible];
                });
            }
        }
            break;
        case 1:{
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
            
        case 2:{
            if (indexPath.row == 0) {
                // 为我打分
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yun-dian-jia/id783464466?mt=8"]];
            } else if (indexPath.row == 1) {
                // 清理缓存
                [self showCache];
            } else {
                // 退出
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

#pragma mark - Common Function - 

- (void)exitBtnClick:(UIButton *)sender
{
    YunLog(@"退出操作");
    
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.user = nil;
    appDelegate.user = [[User alloc] init];
    appDelegate.login = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:nil forKey:@"user_session_key"];
    [defaults setObject:nil forKey:@"userType"];
    [defaults setObject:nil forKey:@"lastSelectedShop"];
    [defaults setObject:nil forKey:@"display_name"];
    [defaults setObject:nil forKey:@"birthday"];
    [defaults setObject:nil forKey:@"nickname"];
    [defaults setObject:nil forKey:@"phone"];
    /// 设置购物车的数量为0
    [defaults setObject:@"0" forKey:@"cartCount"];
    
    [defaults synchronize];
    
    /// 移除购物车角标
    UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
    cartVC.tabBarItem.badgeValue = nil;
    
    if (_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:@"已安全退出" delay:2.0];
    }
    
    YunLog(@"yes logout");
    AdminHomeViewController *adminVC = [[AdminHomeViewController alloc] init];
//    adminVC.isBuyEnter = YES;
    
    PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:adminVC];
    
    appDelegate.window.rootViewController = popNC;
    [appDelegate.window makeKeyAndVisible];
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

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
