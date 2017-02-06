//
//  AdminOrderListViewController.h
//  Shops-iPhone
//
//  Created by rujax on 14-3-31.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AdminOrderType) {
    AdminOrderAll                   = 0, // 全部
    AdminOrderWaitingForPay         = 1, // 待支付
    AdminOrderWaitingForSend        = 2, // 待发货
    AdminOrderWaitingForReceive     = 4, // 待收货
    AdminOrderAlreadyComplete       = 5, // 已完成
    AdminOrderAlreadyCancel         = 7  // 已取消
};

typedef NS_ENUM(NSInteger, AdminOrderTimeType) {
    AdminOrderTimeAll               = 0,
    AdminOrderTimeToday             = 1,
    AdminOrderTimeLast7Day          = 2,
    AdminOrderTimeLast30Day         = 3
};

typedef NS_ENUM(NSInteger, AdminOrderChannelType) {
    AdminOrderChannelAll            = 0,
    AdminOrderChannelShop           = 1,
    AdminOrderChannelDistributor    = 2
};

@interface AdminOrderListViewController : UIViewController

@property (nonatomic, assign) AdminOrderType orderType;
@property (nonatomic, copy) NSString *shopID;

@end
