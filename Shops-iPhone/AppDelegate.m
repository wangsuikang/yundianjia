//
//  AppDelegate.m
//  Shops-iPhone
//
//  Created by rujax on 2013-10-30.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AppDelegate.h"

// Controllers
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "ProductDetailViewController.h"
#import "WebViewController.h"
#import "ActivityViewController.h"
#import "ScreenFlashViewController.h"
#import "GuideViewController.h"
#import "AdminHomeViewController.h"
#import "ConsumerChooseViewController.h"
#import "PopGestureRecognizerController.h"
#import "MyShopListViewController.h"

// Libraries
#import "AFNetworking.h"
#import "IQKeyboardManager.h"

#define kUpdateVersionDate 20160216

@interface AppDelegate () <UIAlertViewDelegate, WXApiDelegate, WeiboSDKDelegate>

@property (nonatomic, copy) NSString *trackViewUrl;

@property (nonatomic, strong) UIAlertView *updateAlertView;

///// 点击回调第一步获取到的参数 code 用来获取access_token   openid
//@property (nonatomic, copy) NSString *wxCode;
//
///// 第二步  根据code获取下面参数
///// 点击微信登陆回调获取的参数--acces_token
//@property (nonatomic, copy) NSString *access_token;
///// 点击微信登陆回调获取的参数--openid
//@property (nonatomic, copy) NSString *openid;
///// 点击微信登陆回调获取到的字典 这是第二步获取到的字典信息（里面包含了access_token  和 openid）
//@property (nonatomic, strong) NSDictionary *tokenOpenidDict;
//
///// 第三步  根据上面的两个参数获取用户基本信息
//@property (nonatomic, strong) NSDictionary *userInfoDict;
///// 微信登陆用户名称
//@property (nonatomic, copy) NSString *nickName;
///// 微信登陆用户的图片URL路劲
//@property (nonatomic, copy) NSString *wxHeadImgString;

@end

@implementation AppDelegate

- (void)customUI
{
    if (kDeviceOSVersion < 7.0) {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_selected_ios6"]];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    }

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}
                                             forState:UIControlStateNormal];

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]}
                                             forState:UIControlStateSelected];
}

/**
 *  一些需要开始注册使用的库
 */
- (void)startRegisterDefault
{
    /// 需要使用的库，基本的注册（键盘处理库）
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = NO;
    
    // 注册TalkingData 统计数据
//    [TalkingData sessionStarted:kTalkingDataAppKey withChannelId:kTalkingDataChannelAppStore];
}

- (void)registerTermimal
{
    NSString *termimalURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kTerminalSignUpURL params:nil];
    
    YunLog(@"termimalURL = %@", termimalURL);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_key"  :   [Tool getUniqueDeviceIdentifier],
                             @"device_token"  :   kNullToString(appDelegate.deviceToken),
                             @"app_id"        :   kBundleID};
    
    YunLog(@"register terminal params = %@", params);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:termimalURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"register terminal responseObject = %@", responseObject);
              
              NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
              
              if ([code isEqualToString:kSuccessCode]) {
                  AppDelegate *appDelegate = kAppDelegate;
                  
                  appDelegate.terminalSessionKey = kNullToString([[responseObject objectForKey:@"data"] objectForKey:@"terminal_session_key"]);
                  
              } else {
                  YunLog(@"terminal register error = %@", kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]));
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              YunLog(@"register terminal error = %@", error);
          }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.user = [[User alloc] init];
    self.login = NO;
    self.province = @"";
    self.paying = NO;
    self.isFromBackground = NO;
    self.lastSelectedTabIndex = 0;
    
    /// 注册各种库的使用
    [self startRegisterDefault];
    
    application.applicationIconBadgeNumber = 0;
    
    NSUserDefaults *defaults = kUserDefaults;
    
    YunLog(@"username = %@", [defaults objectForKey:@"username"]);
    YunLog(@"user_session_key = %@", [defaults objectForKey:@"user_session_key"]);
    YunLog(@"userType = %@", [defaults objectForKey:@"userType"]);
    
    if ([defaults objectForKey:@"username"] && [defaults objectForKey:@"user_session_key"]) {
        self.login = YES;
        self.user.username = [defaults objectForKey:@"username"];
        self.user.display_name = [defaults objectForKey:@"display_name"];
        self.user.userSessionKey = [defaults objectForKey:@"user_session_key"];
    }
    
    if (![defaults objectForKey:@"userType"]) {
        self.user.userType = 1;
    } else {
        self.user.userType = [[defaults objectForKey:@"userType"] integerValue];
    }
    
    if (![defaults objectForKey:kRemoteNotification]) {
        [defaults setObject:@"0" forKey:kRemoteNotification];
        
        [defaults synchronize];
    } else {
        if ([[defaults objectForKey:kRemoteNotification] isKindOfClass:[NSArray class]]) {
            [defaults setObject:@"0" forKey:kRemoteNotification];
            
            [defaults synchronize];
        }
    }
    
    YunLog(@"kRemoteNotification = %@", [defaults objectForKey:kRemoteNotification]);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self customUI];
    
    [self registerTermimal];
    
    [application setStatusBarHidden:NO];
    if (kDeviceOSVersion >= 7.0) {
        [application setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [NSThread sleepForTimeInterval:2.0];    // 屏闪停留3秒
    
    NSString *lastAppVersion = [defaults objectForKey:kLastAppVersion];
    
    YunLog(@"lastAppVersion = %@", lastAppVersion);
    
    NSString *currentAppVersion = [Tool versionString];
    
    YunLog(@"currentAppVersion = %@", currentAppVersion);
    
    if (!lastAppVersion) {
        [defaults setObject:currentAppVersion forKey:kLastAppVersion];
        
        [defaults synchronize];
        
        GuideViewController *guide = [[GuideViewController alloc] init];
        PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:guide];
        
        self.window.rootViewController = popNC;
        self.window.backgroundColor = COLOR(232, 228, 223, 1);
    
        [self.window makeKeyAndVisible];
    } else {
        if ([lastAppVersion integerValue] < [currentAppVersion integerValue]) {
            [defaults setObject:currentAppVersion forKey:kLastAppVersion];
            
            [defaults synchronize];
            
            GuideViewController *guide = [[GuideViewController alloc] init];
            PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:guide];
            
            self.window.rootViewController = popNC;
            self.window.backgroundColor = COLOR(232, 228, 223, 1);
                                           
            [self.window makeKeyAndVisible];
        } else {
//            IndexTabViewController *index = [[IndexTabViewController alloc] init];
//            
//            self.window.rootViewController = index;
//            self.window.backgroundColor = [UIColor whiteColor];
//            
//            [self.window makeKeyAndVisible];
            NSInteger userType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userType"] integerValue];
            YunLog(@"userType = %ld", (long)userType);
            
            if (self.isLogin)
            { // 登录状态
                if (userType == 1 && userType == 0) {
                    _indexTab = [[IndexTabViewController alloc] init];
                    
                    self.window.rootViewController = _indexTab;
                    self.window.backgroundColor = kWhiteColor;
                    
                    [self.window makeKeyAndVisible];
                } else if (userType == 2) {
                    
//                    _indexTab = [[IndexTabViewController alloc] init];
                    MyShopListViewController *shopsVC = [[MyShopListViewController alloc] init];
                    PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:shopsVC];
                    
                    self.window.rootViewController = popNC;
                    self.window.backgroundColor = kWhiteColor;
                    
                    [self.window makeKeyAndVisible];
                    
                } else if(userType == 3) {
                    MyShopListViewController *shopsVC = [[MyShopListViewController alloc] init];
                    PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:shopsVC];
                    
                    self.window.rootViewController = popNC;
                    self.window.backgroundColor = kWhiteColor;
                    
                    [self.window makeKeyAndVisible];
                } else {
                    _indexTab = [[IndexTabViewController alloc] init];
                    
                    self.window.rootViewController = _indexTab;
                    self.window.backgroundColor = kWhiteColor;
                    
                    [self.window makeKeyAndVisible];
                }
            } else {
                ConsumerChooseViewController *chooseVc = [[ConsumerChooseViewController alloc] init];
                
                PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:chooseVc];
                
                self.window.rootViewController = popNC;
                self.window.backgroundColor = kWhiteColor;
                
                [self.window makeKeyAndVisible];
            }
        }
    }
    
    // 微信注册 AppID
    [WXApi registerApp:kWeiXinAppID];
    
//    [WXApi registerApp:@"wxd930ea5d5a258f4f" withDescription:@"demo 2.0"];
    
//    [[LXMThirdLoginManager sharedManager] setupWithSinaWeiboAppKey:kSinaWeiboAppKey SinaWeiboRedirectURI:kSinaWeiboRedirectURI WeChatAppKey:kWeChatAppKey WeChatAppSecret:kWeChatAppSecret QQAppKey:kQQAppKey];
    
    // 微博注册 AppKey
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kWeiBoAppKey];
    
    // 向苹果注册
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    YunLog(@"userInfo = %@", userInfo);
    
    if (userInfo) {
        _message = nil;
        
        [defaults setObject:@"1" forKey:kRemoteNotification];
        
        [defaults synchronize];
        
        NSString *category = kNullToString([userInfo objectForKey:@"category"]);
        NSString *content = kNullToString([userInfo objectForKey:@"content"]);
        
        @try {
            _message = @{@"title":kNullToString([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]),
                         @"category":category,
                         @"content":content};
        }
        @catch (NSException *exception) {
            YunLog(@"message exception = %@", exception);
            
            _message = nil;
        }
        @finally {
            
        }
        
//        [self handleAPNSMessage];
    }
   
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (_shareType == ShareToWeiXin) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if (_shareType == LoginToWeiXin )
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (_shareType == ShareToWeiXin) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if (_shareType == LoginToWeiXin )
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    YunLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    YunLog(@"applicationDidBecomeActive");
    
    self.isFromBackground = YES;
    
    if ([_updateAlertView isVisible]) {
        [_updateAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    
    NSString *dateString = [formatter stringFromDate:date];
    
//    if ([dateString integerValue] > kUpdateVersionDate) {
//        if ([kRequestHost isEqualToString:@"http://api.shop.yundianjia.com"]) {
//            if ([Tool isNetworkAvailable]) {
//                NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@&country=cn", kAppID];
//                
//                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                manager.requestSerializer.timeoutInterval = 30;
//
//                [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    YunLog(@"scan update responseObject = %@", responseObject);
//                    
//                    NSDictionary *results = [responseObject objectForKey:@"results"];
//                    //            YunLog(@"scan update results = %@", results);
//                    
//                    _trackViewUrl = kNullToString([[results valueForKey:@"trackViewUrl"] objectAtIndex:0]);
//                    YunLog(@"_trackViewUrl = %@", _trackViewUrl);
//                    
//                    NSString *currentVersion = kNullToString([[results valueForKey:@"version"] objectAtIndex:0]);
//                    
//                    if (![kAppVersion isEqualToString:currentVersion]) {
//                        _updateAlertView = [[UIAlertView alloc] initWithTitle:@"发现新版本"
//                                                                      message:nil
//                                                                     delegate:self
//                                                            cancelButtonTitle:nil
//                                                            otherButtonTitles:@"去更新", nil];
//                        [_updateAlertView show];
//                    }
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    YunLog(@"scan update error = %@", error);
//                }];
//            }
//        }
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /// 这里是清理当时 从保存商品成功后跳转的条件
    [kUserDefaults setObject:@"no" forKey:@"jumpSave"];
    [kUserDefaults setObject:@"no" forKey:@"isPay"];
    [kUserDefaults setObject:@"0.0" forKey:@"commissionRate"];
    
    [kUserDefaults synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    YunLog(@"applicationWillTerminate");
}

// for registerForRemoteNotificationTypes
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    YunLog(@"didRegisterForRemoteNotificationsWithDeviceToken, deviceToken = %@", deviceToken);
    
    self.deviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    
    self.deviceToken = [self.deviceToken substringWithRange:NSMakeRange(1, self.deviceToken.length - 2)];
    
    YunLog(@"self.deviceToken = %@", self.deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    YunLog(@"didFailToRegisterForRemoteNotificationsWithError, error = %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    YunLog(@"didReceiveRemoteNotification, userInfo = %@", userInfo);
    
    _message = nil;
    
    application.applicationIconBadgeNumber = 0;
    
    NSString *category = kNullToString([userInfo objectForKey:@"category"]);
    NSString *content = kNullToString([userInfo objectForKey:@"content"]);
    
    @try {
        _message = @{@"title"       :   kNullToString([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]),
                     @"category"    :   category,
                     @"content"     :   content};
    }
    @catch (NSException *exception) {
        YunLog(@"message exception = %@", exception);
        
        _message = nil;
    }
    @finally {
        
    }
    
    YunLog(@"_message = %@", _message);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"1" forKey:kRemoteNotification];
    
    [defaults synchronize];
    
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    
    UIViewController *about = (UIViewController *)tab.viewControllers[3];
    about.tabBarItem.badgeValue = @"New";
    
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"云店家精心为您推荐"
                                                            message:kNullToString([[userInfo objectForKey:@"aps"] objectForKey:@"alert"])
                                                           delegate:self
                                                  cancelButtonTitle:@"忽略"
                                                  otherButtonTitles:@"查看", nil];
        [alertView show];
    } else {
        [self handleAPNSMessage];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    YunLog(@"didReceiveLocalNotification, notification = %@", notification);
}

#pragma mark - WXApiDelegate -

- (void)onReq:(BaseReq *)req
{
    YunLog(@"asdf");
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case WXSuccess:
                if (_wxPayDelegate && [_wxPayDelegate respondsToSelector:@selector(showPayResult:message:)]) {
                    [_wxPayDelegate showPayResult:WXPayResultSuccess message:@"订单支付成功！"];
                }
                
                YunLog(@"支付成功 resp.errCode = %d", resp.errCode);
                
                break;
                
            case WXErrCodeUserCancel:
                if (_wxPayDelegate && [_wxPayDelegate respondsToSelector:@selector(showPayResult:message:)]) {
                    [_wxPayDelegate showPayResult:WXPayResultFailure message:@"支付已取消"];
                }
                
                YunLog(@"支付取消 resp.errCode = %d", resp.errCode);
                YunLog(@"支付取消 resp.errStr = %@", resp.errStr);
                
                break;
                
            default:
                if (_wxPayDelegate && [_wxPayDelegate respondsToSelector:@selector(showPayResult:message:)]) {
                    [_wxPayDelegate showPayResult:WXPayResultFailure message:resp.errStr];
                }
                
                YunLog(@"支付失败 resp.errCode = %d, resp.errStr = %@", resp.errCode, resp.errStr);
                
                break;
        }
    }
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        YunLog(@"执行了吗 --- %d", resp.errCode);
        SendAuthResp *respGet = (SendAuthResp *)resp;
//        self.wxCode = respGet.code;
        switch (resp.errCode) {
            case WXSuccess:
                if (_wxLoginDelegate && [_wxLoginDelegate respondsToSelector:@selector(showLoginResult:SendauthResp:message:)]) {
                    [_wxLoginDelegate showLoginResult:WXLoginResultSuccess SendauthResp:respGet message:@"登陆成功"];
                }
                
//                [self getAccess_token];
                
//                [self getUserInfo];
                
                YunLog(@"登陆成功 resp.errCode = %d", resp.errCode);
                
                break;
                
            case WXErrCodeUserCancel:
                if (_wxLoginDelegate && [_wxLoginDelegate respondsToSelector:@selector(showLoginResult:SendauthResp:message:)]) {
                    [_wxLoginDelegate showLoginResult:WXLoginResultFailure SendauthResp:respGet message:@"取消登陆"];
                }

                
                YunLog(@"取消登陆 resp.errCode = %d", resp.errCode);
                YunLog(@"取消登陆 resp.errStr = %@", resp.errStr);
                
                break;
                
            default:
                if (_wxLoginDelegate && [_wxLoginDelegate respondsToSelector:@selector(showLoginResult:SendauthResp:message:)]) {
                    [_wxLoginDelegate showLoginResult:WXLoginResultFailure SendauthResp:respGet message:resp.errStr];
                }
                
                YunLog(@"登陆失败 resp.errCode = %d, resp.errStr = %@", resp.errCode, resp.errStr);
                
                break;
        }
    }
}

//-(void)getAccess_token
//{
//    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
//    
//    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeiXinAppID,kWeiXinAppKey,_wxCode];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSURL *zoneUrl = [NSURL URLWithString:url];
//        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
//        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (data) {
//                _tokenOpenidDict = [NSDictionary dictionary];
//                _tokenOpenidDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//                YunLog(@"获取token openid  = %@", _tokenOpenidDict);
//                /*
//                 {
//                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
//                 "expires_in" = 7200;
//                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
//                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
//                 scope = "snsapi_userinfo,snsapi_base";
//                 }
//                 */
//                
////                self.access_token.text = [dic objectForKey:@"access_token"];
////                self.openid.text = [dic objectForKey:@"openid"];
//                _access_token = [_tokenOpenidDict objectForKey:@"access_token"];
//                _openid = [_tokenOpenidDict objectForKey:@"openid"];
//                
//                [self getUserInfo];
//            }
//        });
//    });
//}
//
//-(void)getUserInfo
//{
//    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
//    
//    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token,self.openid];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSURL *zoneUrl = [NSURL URLWithString:url];
//        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
//        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (data) {
//                _userInfoDict = [NSDictionary dictionary];
//                _userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//                
//                YunLog(@"获取userInfo = %@", _userInfoDict);
//                /*
//                 {
//                 city = Haidian;
//                 country = CN;
//                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
//                 language = "zh_CN";
//                 nickname = "xxx";
//                 openid = oyAaTjsDx7pl4xxxxxxx;
//                 privilege =     (
//                 );
//                 province = Beijing;
//                 sex = 1;
//                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
//                 }
//                 */
//                
////                self.nickname.text = [dic objectForKey:@"nickname"];
////                self.wxHeadImg.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"headimgurl"]]]];
//                _nickName = [_userInfoDict objectForKey:@"nickname"];
//                _wxHeadImgString = [_userInfoDict objectForKey:@"headimgurl"];
//            }
//        });
//        
//    });
//}

#pragma mark - WeiboSDKDelegate -

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView == _updateAlertView) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_trackViewUrl]];
        } else {
            [self handleAPNSMessage];
        }
    }
}

#pragma mark - Public Functions -

- (void)handleAPNSMessage
{
    if (!_message) {
        return;
    }
    
    YunLog(@"_message = %@", _message);
    
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    
    UIViewController *about = (UIViewController *)tab.viewControllers[3];
    about.tabBarItem.badgeValue = @"New";
    
    NSString *category = kNullToString([_message objectForKey:@"category"]);
    NSInteger categoryInt = [category integerValue];
    NSString *content = kNullToString([_message objectForKey:@"content"]);
    
    @try {
        UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
        
        UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
        
        if (nav.presentedViewController) {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
        
        switch (categoryInt) {
            case NotificationShop:
            {
//                ShopInfoViewController *shop = [[ShopInfoViewController alloc] init];
//                shop.code = content;
//                shop.hidesBottomBarWhenPushed = YES;
//                
//                [nav pushViewController:shop animated:YES];
                
                ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
                shop.code = content;
                shop.hidesBottomBarWhenPushed = YES;
                
                [nav pushViewController:shop animated:YES];
                
                break;
            }
                
            case NotificationProduct:
            {
                ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
                detail.productCode = content;
                detail.hidesBottomBarWhenPushed = YES;
                
                [nav pushViewController:detail animated:YES];
                
                break;
            }
                
            case NotificationWebView:
            {
                WebViewController *web = [[WebViewController alloc] init];
                web.url = content;
                web.naviTitle = @"推送消息";
                web.hidesBottomBarWhenPushed = YES;
                
                [nav pushViewController:web animated:YES];
                
                break;
            }
                
            case NotificationProductFormat:
            {
//                ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
//                detail.code = content;
//                detail.hidesBottomBarWhenPushed = YES;
//                
//                [nav pushViewController:detail animated:YES];
                
                break;
            }
                
            case NotificationActivity:
            {
                ActivityViewController *activity = [[ActivityViewController alloc] init];
                activity.activityID = content;
                activity.activityName = @"最新活动";
                activity.hidesBottomBarWhenPushed = YES;
                
                [nav pushViewController:activity animated:YES];
                
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
    
    _message = nil;
    YunLog(@"didReceiveRemoteNotification, exception =");
}

@end
