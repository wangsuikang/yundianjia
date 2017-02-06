//
//  DistributorDetailViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistributorDetailViewController : UIViewController

/// 商户名称
@property (nonatomic, copy) NSString *distributorName;

/// 商户简介
@property (nonatomic, copy) NSString *distributorDesc;

/// 邮箱
@property (nonatomic, copy) NSString *email;

/// 联系人姓名
@property (nonatomic, copy) NSString *phoneName;

/// 手机号码
@property (nonatomic, copy) NSString *phoneNumber;

@end
