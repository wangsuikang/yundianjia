//
//  YUNSegmentButton.m
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "YUNSegmentButton.h"

@implementation YUNSegmentButton
- (instancetype)initWithFrame:(CGRect)frame icon:(NSString *)iconName
{
    if (self = [super initWithFrame:frame]) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.5, frame.size.height * 0.4)];
        iconView.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.3);
        [self addSubview:iconView];
        iconView.image = [UIImage imageNamed:iconName];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView = iconView;
        self.iconName = iconName;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(0, self.frame.size.height * 0.5, self.frame.size.width, self.frame.size.height * 0.5);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setSelected:(BOOL)selected
{

    [super setSelected:selected];
    if (selected) {
        self.iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active",self.iconName]];
        YunLog(@"Selected");

    }
    else {
        self.iconView.image = [UIImage imageNamed:self.iconName];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
