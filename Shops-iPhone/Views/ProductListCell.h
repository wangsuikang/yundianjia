//
//  ProductListCell.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListModel.h"

@interface ProductListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImageIcon;
@property (nonatomic, strong) UILabel *productNameLabel;
@property (nonatomic, strong) UILabel *productDetailLabel;
@property (nonatomic, strong) UILabel *productPriceLabel;
@property (nonatomic, strong) UILabel *marketPriceLabel;
@property (nonatomic, strong) UIView *marketPriceView;
@property (nonatomic, strong) UILabel *workOffLabel;

/**
 根据推荐商品数据模型赋值
 
 @param productListModel 对应的数据模型
 */
- (void)config:(ProductListDetailModel *)productListModel;

/**
 判断Cell是否使用复用
 
 @param tableView 当前的tableView
 
 @return 返回指定的Cell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
