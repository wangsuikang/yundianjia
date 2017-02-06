//
//  AddNewProductViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewProductViewController : UIViewController

/// 商铺code
@property (nonatomic, strong) NSString *shopCode;

/// 商品组id
@property (nonatomic, copy) NSString *product_group_id;

/// 商品id数组
@property (nonatomic, strong) NSMutableArray *IDArr;

@end
