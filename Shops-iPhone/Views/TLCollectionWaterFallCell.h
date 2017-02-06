//
//  TLCollectionWaterfallCell.h
//  TLCollectionWaterfallFlow
//
//  Created by andezhou on 15/8/11.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLCollectionWaterFallCell : UICollectionViewCell

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic ,strong) NSDictionary *coupon;

- (void)config:(NSDictionary *)productDict;

@end
