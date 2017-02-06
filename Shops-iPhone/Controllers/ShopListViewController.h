//
//  ShopListViewController.h
//  Shops-iPhone
//
//  Created by rujax on 13-12-24.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define k3_5InchScreenFlash @"640x720"
#define k4InchScreenFlash @"640x896"
#define kScreenFlashTimestamp @"screenFlashTimestamp"

@interface ShopListViewController : UIViewController

/// 活动视图枚举类型
typedef NS_ENUM(NSInteger, ActivityTypeBanner) {
    BannerActivityShop            = 1, //!<   店铺
    BannerActivityWeb             = 2, //!<   Web类型活动
    BannerActivityProductVariant  = 3, //!<   商品活动不同形式
    BannerActivityProduct         = 4, //!<   商品活动
    BannerActivityActivity        = 5, //!<   活动
};

/// 接口请求参数
@property (nonatomic, copy) NSString *code;

/// 接口请求参数
@property (nonatomic, copy) NSString *type;

/// 接口请求参数
@property (nonatomic, copy) NSString *limit;

@end
