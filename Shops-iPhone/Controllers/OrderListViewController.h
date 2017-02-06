//
//  OrderListViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-12.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OrderType) {
    All = 0,
    WaitingForPay,
    AlreadyPay,
    WaitingForReceive,
    AlreadyComplete,
    AlreadyCancel
};

@interface OrderListViewController : UIViewController

@property (nonatomic, assign) OrderType orderType;

@property (nonatomic, assign) NSInteger selectedOrderTypeIndex;

@end
