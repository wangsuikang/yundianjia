//
//  MyPreferentialCell.m
//  Shops-iPhone
//
//  Created by xxy on 15/7/21.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyPreferentialCell.h"
// Common
#import "LibraryHeadersForCommonController.h"

@implementation MyPreferentialCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    // 添加背景图片
    _bgImage = [[UIImageView alloc] initWithFrame:self.bounds];
    
    [self.contentView addSubview:_bgImage];
    
    // 添加￥图标
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kSpace, kSpace, 20, 20)];
    label.text = @"￥";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:kFontSize];
    
    [self.contentView addSubview:label];
    
    // 添加价钱Label
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpaceMid, kSpace, 80, 30)];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.text = @"0";
    _priceLabel.font = [UIFont systemFontOfSize:kFontLangeBigSize];
    
    [self.contentView addSubview:_priceLabel];
    
    // 添加全国通用或是指定店铺使用
    _kindLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 60, kSpaceMid / 2, 80, 15)];
    _kindLabel.textColor = [UIColor whiteColor];
    _kindLabel.text = @"全店通用";
    _kindLabel.font = [UIFont systemFontOfSize:kFontSmallSize];
    
    [self.contentView addSubview:_kindLabel];
    
    // 添加发行店铺
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(_priceLabel.frame) + 15, self.bounds.size.width, 15)];
    _titleLabel.text = @"发行店铺：";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:kFontSmallMoreSize];
    
    [self.contentView addSubview:_titleLabel];
    
    // 添加使用条件
    _conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(_titleLabel.frame), self.bounds.size.width, 15)];
    _conditionLabel.text = @"满￥80.00";
    _conditionLabel.textColor = [UIColor whiteColor];
    _conditionLabel.font = [UIFont systemFontOfSize:kFontSmallMoreSize];
    
    [self.contentView addSubview:_conditionLabel];
    
    // 添加使用时间的Label
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(_conditionLabel.frame), self.bounds.size.width, 15)];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:kFontSmallMoreSize];
    _timeLabel.text = @"2015-01-20 至 2015-01-23";
    
    [self.contentView addSubview:_timeLabel];

}

- (void)setCoupon:(NSDictionary *)coupon{
    _coupon = coupon;
    NSDictionary *dict = [coupon objectForKey:@"user_coupons"];
    _priceLabel.text = kNullToString([dict objectForKey:@"price"]);
    _kindLabel.text = kNullToString([dict objectForKey:@"type"]);
    _titleLabel.text = [coupon objectForKey:@"title"];
    _conditionLabel.text = kNullToString([dict objectForKey:@"usage_conditions"]);
    _timeLabel.text = kNullToString([dict objectForKey:@"available_date"]);
    _bgImage.image = [UIImage imageNamed:@"favourable_bgimage_invalid"];
    if (![[dict objectForKey:@"status"] isEqualToString:@"激活"]) {
        _bgImage.image = [UIImage imageNamed:@"favourable_bgimage"];
    }
}

- (void)config:(NSDictionary *)dict
{
    // TODO  等待接口具体数据
}

@end

