//
//  AdminShopViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/8/4.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdminShopViewController : UIViewController

/// 商户按钮枚举类型
typedef NS_ENUM(NSInteger, ButtonTypeBanner) {
    AdminProducts = 0,
    AdminOrderList,
    MyDistributors,
    AdminIncome,
    DistributionStat,
    ProductGroups,
    AdminCustomer,
    AdminQRCode,
    ShopList,
};

/// 商铺code
@property (nonatomic, copy) NSString *shopCode;

/// 商铺id
@property (nonatomic, copy) NSString *shopID;

/// 判断是否能够返回
@property (nonatomic, assign) BOOL canBack;


@end
