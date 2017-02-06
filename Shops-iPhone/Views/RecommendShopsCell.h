//
//  RecommendShopsCell.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/25.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "recommendShopsModel.h"

@interface RecommendShopsCell : UITableViewCell
/// 背景视图
@property (nonatomic, strong) UIImageView *bigImageView;

/// 点击按钮
@property (nonatomic, strong) UIView *bottomView;

/// 标题
@property (nonatomic, strong) UILabel *labelTitle;

/// 详情
@property (nonatomic, strong) UILabel *labelDetail;

/**
 根据推荐商品数据模型赋值
 
 @param recommendShopsModel 对应的数据模型
 */
- (void)config:(recommendShopsModel *)recommendShopsModel;

/**
 判断Cell是否使用复用
 
 @param tableView 当前的tableView
 
 @return 返回指定的Cell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
