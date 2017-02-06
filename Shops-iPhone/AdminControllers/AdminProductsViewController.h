//
//  AdminProductsViewController.h
//  Shops-iPhone
//
//  Created by 席小雨 on 15/8/11.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ProductStatusType) {
    All = 0,  /// 全部
    Selling,  /// 出售中
    Stand,    /// 待发布
    Revoke    /// 已下架
};

@interface AdminProductsViewController : UIViewController

@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, assign) NSInteger selectedProdectTypeIndex;

@property (nonatomic, copy) NSString *shopCode;

@property (nonatomic, copy) NSString *shopID;

@end
