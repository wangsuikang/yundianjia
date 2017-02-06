//
//  PayCenterForUserViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-12-06.
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

@interface PayCenterForUserViewController : UIViewController

/// 当前订单
@property (nonatomic, strong) NSDictionary *order;

/// 是否直接购买
@property (nonatomic, assign) BOOL nowToBuy;

/// 购物车里面进来的商品结算订单
@property (nonatomic, strong) NSMutableArray *allSelectProducts;

/// 购物车中结算商品属于的店铺信息
@property (nonatomic, strong) NSMutableArray *paySelectShops;

/// 立即购买传送过来的优惠信息
@property (nonatomic, strong) NSMutableArray *promotionArray;

/// 立即购买传送过来的店铺
@property (nonatomic, strong) NSMutableDictionary *shopNowPayDict;

/// 立即购买的数量
@property (nonatomic ,strong) NSString *buyCount;

@end
