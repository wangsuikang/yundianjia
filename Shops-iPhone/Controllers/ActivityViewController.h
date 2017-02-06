//
//  ActivityViewController.h
//  Shops-iPhone
//
//  Created by rujax on 14-2-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 活动视图枚举类型
typedef NS_ENUM(NSInteger, ActivityType) {
    ActivityWeb             = 1, //!<   web类型
    ActivityShop            = 2, //!<   商铺活动
    ActivityProductVariant  = 3, //!<   商品活动不同形式
    ActivityProduct         = 4, //!<   商品活动
    ActivityActivity        = 5, //!<   任何活动
};

@interface ActivityViewController : UIViewController

/// 活动ID
@property (nonatomic, copy) NSString *activityID;

/// 活动code
@property (nonatomic, copy) NSString *activityCode;

/// 活动名称
@property (nonatomic, copy) NSString *activityName;

/// 是否是首页推荐按钮
@property (nonatomic, assign) BOOL isHomePage;

/// 是否从轮播图进入
@property (nonatomic, assign) BOOL isBannerPage;


@end
