//
//  AddNewGroupViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewGroupViewController : UIViewController

/// 分销商店铺id
@property (nonatomic, copy) NSString *distribution_shop_id;

@property (nonatomic, copy) NSString *distributorName;

/// 分销店铺用户id
@property (nonatomic, copy) NSString *distribution_owner_id;

@end
