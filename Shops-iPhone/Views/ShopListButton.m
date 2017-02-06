//
//  ShopListButton.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-23.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "ShopListButton.h"

#import "UIImageView+AFNetworking.h"

@interface ShopListButton()

@end

@implementation ShopListButton

@synthesize shopImageView = _shopImageView, titleLabel = _titleLabel, descLabel = _descLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
//        self.layer.shadowOpacity = 1.0;
//        self.layer.shadowRadius = 5.0;
//        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.clipsToBounds = NO;
        self.backgroundColor = COLOR(245, 245, 245, 1);
    }
    return self;
}

- (UIImageView *)shopImageView
{
    if (!_shopImageView) {
        _shopImageView = [[UIImageView alloc] init];
//        _shopImageView.contentMode = UIViewContentModeScaleAspectFit;
        _shopImageView.contentMode = UIViewContentModeCenter;
        _shopImageView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:_shopImageView];
    }
    
    return _shopImageView;
}

- (UIImageView *)leftTopView
{
    if (!_leftTopView) {
        _leftTopView = [[UIImageView alloc] init];
        _leftTopView.contentMode = UIViewContentModeScaleAspectFit;
        _leftTopView.backgroundColor = kClearColor;
        _leftTopView.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_left_top_%@", self.actionType]];
//        _leftTopView.image = [UIImage imageNamed:@"list_left_top_5"];
        
        [self addSubview:_leftTopView];
    }
    
    return _leftTopView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = kClearColor;
        _titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
        
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.backgroundColor = kClearColor;
        _descLabel.font = kSmallFont;
        _descLabel.textColor = [UIColor lightGrayColor];
        _descLabel.numberOfLines = 0;
        
        [self addSubview:_descLabel];
    }
    
    return _descLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _shopImageView.frame = CGRectMake(0, 0, self.frame.size.width, 160);
//    _leftTopView.frame = CGRectMake(0, 0, 40, 40);
    _leftTopView.frame = CGRectMake(self.frame.size.width - 50, 0, 50, 50);
    _titleLabel.frame = CGRectMake(2, _shopImageView.frame.size.height, self.frame.size.width - 2 * 2, 30);
    
    CGSize size = [_descLabel.text sizeWithFont:kSmallFont size:CGSizeMake(self.frame.size.width - 4, 9999)];
    
    _descLabel.frame = CGRectMake(2, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, self.frame.size.width - 4, size.height);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//
//}


@end
