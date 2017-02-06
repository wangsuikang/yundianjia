//
//  TLCollectionWaterfallCell.m
//  TLCollectionWaterfallFlow
//
//  Created by andezhou on 15/8/11.
//  Copyright (c) 2015年 周安德. All rights reserved.
//

#import "TLCollectionWaterFallCell.h"

#import "LibraryHeadersForCommonController.h"

@implementation TLCollectionWaterFallCell

#pragma mark -
#pragma mark lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.contentView.backgroundColor = kWhiteColor;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    _bgView.backgroundColor = kWhiteColor;
    
    [self.contentView addSubview:_bgView];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
     _imageView.contentMode = UIViewContentModeCenter;
    _imageView.backgroundColor = kWhiteColor;
    
    [_bgView addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame), self.frame.size.width, 20)];
    _titleLabel.textColor = [UIColor lightGrayColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = kMidFont;
    _titleLabel.backgroundColor = kWhiteColor;
    
    [_bgView addSubview:_titleLabel];
    
    // 价格
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), self.frame.size.width, 20)];
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.textColor = kBlackColor;
    _priceLabel.font = kMidFont;
    _priceLabel.backgroundColor = kWhiteColor;
    
    [_bgView addSubview:_priceLabel];
}

- (void)config:(NSDictionary *)productDict
{
    __weak UIImageView *imageView = _imageView;
    
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([productDict safeObjectForKey:@"large_icon_200_200"])]]
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  // UIViewContentModeScaleAspectFit
                                  _imageView.contentMode = UIViewContentModeScaleToFill;
                                  _imageView.image = image;
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([productDict safeObjectForKey:@"large_icon"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                  _imageView.contentMode = UIViewContentModeScaleToFill;
                              }];
    
    _titleLabel.text = [productDict safeObjectForKey:@"name"];
    
    _priceLabel.text = [NSString stringWithFormat:@"￥ %@", [productDict safeObjectForKey:@"price"]];
    
}

@end
