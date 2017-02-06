//
//  ProductRevelationController.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductRevelationController : UIViewController

/// 接口请求参数
@property (nonatomic, copy) NSString *id;

/// 接口请求参数
@property (nonatomic, copy) NSString *page;

/// 接口请求参数
@property (nonatomic, copy) NSString *per;

/// 导航栏标题
@property (nonatomic, copy) NSString *titleName;

/// 商品id
@property (nonatomic, assign) NSInteger productId;

/// UITableView
@property (nonatomic, strong) UITableView *tableView;

/// 数据源
@property (nonatomic, strong) NSMutableArray *dataScource;


@end
