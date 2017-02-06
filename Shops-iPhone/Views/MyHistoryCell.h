//
//  MyHistoryCell.h
//  Shops-iPhone
//
//  Created by xxy on 15/7/20.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTitleHeight 20

@interface MyHistoryCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *photoImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

- (void)config:(NSDictionary *)dict;

@end
