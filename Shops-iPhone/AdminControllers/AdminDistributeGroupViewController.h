//
//  AdminDistributeProductsViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdminDistributeGroupViewController : UIViewController

/// 分销商名称
@property (nonatomic, strong) NSString *distributorName;

/// 分销商code
@property (nonatomic, strong) NSString *shopID;

/// 分销商id
@property (nonatomic, strong) NSString *distribution_owner_id;

@end
