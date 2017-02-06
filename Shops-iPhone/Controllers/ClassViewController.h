//
//  ClassViewController.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/15.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassViewController : UIViewController

/// 访问后台数据请求参数
@property (nonatomic, copy) NSString *code;

/// 访问后台数据请求参数
@property (nonatomic, copy) NSString *type;

/// 访问后台数据请求参数
@property (nonatomic, copy) NSString *limit;

@end
