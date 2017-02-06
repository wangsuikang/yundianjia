//
//  RateProductViewController.h
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateProductViewController : UIViewController

/// 订单的Id
@property (nonatomic, copy) NSString *orderID;

- (instancetype)initWithOrderId:(NSString *)orderId;

@end
