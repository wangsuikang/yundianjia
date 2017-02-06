//
//  ChooseBankViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/7/6.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseBankViewController : UIViewController

/// 订单号
@property (nonatomic, copy) NSString *tradeNO;

/// 订单的价格
@property (nonatomic, copy) NSString *price;

/// 导航视图控制器索引
@property (nonatomic, assign) NSUInteger index;

@end
