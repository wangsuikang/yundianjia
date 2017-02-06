//
//  AppDelegate.h
//  Shops-iPhone
//
//  Created by rujax on 2013-10-30.
//  Copyright (c) 2013年 net.atyun. All rights reserved.

#import <UIKit/UIKit.h>

// Classes
#import "User.h"
#import "Tool.h"

// Controllers
#import "IndexTabViewController.h"

// Libraries
#import "WXApi.h"
#import "WeiboSDK.h"

// Protocols
//#import "APNSDelegate.h"
#import "WXPayDelegate.h"
#import "WXLoginDelegate.h"

#define kSearchHistory @"searchHistory"

typedef NS_ENUM(NSInteger, ShareType) {
    ShareToWeiBo = 0,    //!< 分享到微博
    ShareToWeiXin = 1,   //!< 分享到微信
    LoginToWeiXin = 2    //!< 微信登陆
};

typedef NS_ENUM(NSInteger, NotificationType) {
    NotificationShop            = 1,
    NotificationProduct         = 2,
    NotificationWebView         = 3,
    NotificationProductFormat   = 4,
    NotificationActivity        = 5,
    NotificationUpdateVersion   = 6,
    NotificationOther           = 99
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

/// 系统最底层窗口
@property (strong, nonatomic) UIWindow *window;

/// APNS消息体
@property (nonatomic, strong) NSDictionary *message;

/// 用户
@property (nonatomic, strong) User *user;

/// 判断用户是否登录
@property (nonatomic, assign, getter = isLogin) BOOL login;

/// 记录省份
@property (nonatomic, copy) NSString *province;

/// 记录城市
@property (nonatomic, copy) NSString *city;

/// 记录地区
@property (nonatomic, copy) NSString *area;

/// 记录省份ID
@property (nonatomic, copy) NSString *address_province_no;

/// 记录城市Id
@property (nonatomic, copy) NSString *address_city_no;

/// 记录地区ID
@property (nonatomic, copy) NSString *address_area_no;

/// 终端会话key
@property (nonatomic, copy) NSString *terminalSessionKey;

/// 判断用户是否支付
@property (nonatomic, assign, getter = isPaying) BOOL paying;

/// 分享类型
@property (nonatomic, assign) ShareType shareType;

/// 判断app是否从后台返回
@property (nonatomic, assign) BOOL isFromBackground;

/// 上一次选中的tab索引
@property (nonatomic, assign) NSUInteger lastSelectedTabIndex;

/// 设备令牌
@property (nonatomic, copy) NSString *deviceToken;

/// tab视图控制器
@property (nonatomic, strong) IndexTabViewController *indexTab;

/// APNS协议代理
//@property (nonatomic, strong) id<APNSDelegate> delegate;

/// 微信支付代理
@property (nonatomic, strong) id<WXPayDelegate> wxPayDelegate;

/// 微信登陆代理
@property (nonatomic, weak) id<WXLoginDelegate> wxLoginDelegate;

- (void)handleAPNSMessage;

@end
