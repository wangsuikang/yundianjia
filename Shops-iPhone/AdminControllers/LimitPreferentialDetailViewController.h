//
//  LimitPreferentialDetailViewController.h
//  Shops-iPhone
//
//  Created by cml on 15/9/1.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LimitPreferentialDetailViewController : UIViewController

/// 活动详情字典
@property (nonatomic, strong) NSDictionary *activityDic;

/// 活动规则数组
@property (nonatomic, strong) NSArray *rulesArr;
@end
