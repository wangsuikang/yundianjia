//
//  MyHistoryCell.m
//  Shops-iPhone
//
//  Created by xxy on 15/7/20.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyHistoryCell.h"

// Common
#import "LibraryHeadersForCommonController.h"

@implementation MyHistoryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 0.1;
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
    _photoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, (kScreenWidth - kTitleHeight) / 2)];
    
    [self.contentView addSubview:_photoImage];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _photoImage.bounds.size.height + 5, self.bounds.size.width, kTitleHeight)];
    if (kIsiPhone) {
        _titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    } else {
        _titleLabel.font = [UIFont systemFontOfSize:kFontBigSize];
    }
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.tag = 1;
    _titleLabel.textColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:_titleLabel];
    
    CGFloat priceLabelY = 0;
    if (kIsiPhone) {
        priceLabelY = _titleLabel.bounds.size.height + _photoImage.bounds.size.height + 5;
    } else {
        priceLabelY = _titleLabel.bounds.size.height + _photoImage.bounds.size.height + 15;
    }
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, priceLabelY, self.bounds.size.width, kTitleHeight)];
    if (kIsiPhone) {
        _priceLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    } else {
        _priceLabel.font = [UIFont systemFontOfSize:kFontBigSize];
    }
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.textColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:_priceLabel];
}

- (void)config:(NSDictionary *)dict
{
    _photoImage.backgroundColor = kClearColor;
    _photoImage.contentMode = UIViewContentModeCenter;
    YunLog(@"dict == %@", dict);
    
    __weak UIImageView *_imageView = _photoImage;
    // TODO 等正式环境需要修改
    [_photoImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([dict objectForKey:@"image_url"])]]
                       placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   _imageView.image = image;
                                   _imageView.contentMode = UIViewContentModeScaleAspectFill;
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([dict objectForKey:@"smal_image_url"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                   _imageView.contentMode = UIViewContentModeScaleAspectFill;
                               }];
    
    [self.contentView addSubview:_photoImage];
    
    _titleLabel.text = [dict objectForKey:@"title"];
    
    _priceLabel.text = [NSString stringWithFormat:@"￥%@",[dict objectForKey:@"price"]];
}

@end
