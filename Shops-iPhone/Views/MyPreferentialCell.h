//
//  MyPreferentialCell.h
//  Shops-iPhone
//
//  Created by xxy on 15/7/21.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSpace    5
#define kSpaceMid 20

@interface MyPreferentialCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *kindLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *conditionLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic ,strong) NSDictionary *coupon;
- (void)config:(NSDictionary *)dict;

@end
