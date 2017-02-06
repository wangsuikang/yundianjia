//
//  OrderDetailViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-27.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 支付结果
typedef NS_ENUM(NSInteger, PayResultType) {
    PayResultSuccess    = 0,    //!< 成功
    PayResultFailure    = 1,    //!< 失败
    PayResultCancel     = 3,    //!< 取消
    PayresultNone       = 99    //!< 不涉及支付
};

@interface OrderDetailViewController : UIViewController

/// 订单的Id
@property (nonatomic, copy) NSString *orderID;

/// 判断是否是待支付
@property (nonatomic, assign) BOOL isReadyToPay;

@end
