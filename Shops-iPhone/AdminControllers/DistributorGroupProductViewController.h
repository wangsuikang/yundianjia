//
//  DistributeGroupProductViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistributorGroupProductViewController : UIViewController

/// 判断是是分销商商品组还是自己的商品组
@property (nonatomic, assign) BOOL isDistributor;

/// 分销组名称
@property (nonatomic, strong) NSString *distributeGroupName;

/// 商品组ID
@property (nonatomic, strong) NSString *pg_id;

/// 商铺id
@property (nonatomic, strong) NSString *sid;

/// 分销者id
@property (nonatomic, strong) NSString *distribution_owner_id;

@end
