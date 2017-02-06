//
//  UIButtonForBarButton.m
//  Shops-iPhone
//
//  Created by rujax on 2013-12-03.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "UIButtonForBarButton.h"

@implementation UIButtonForBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitle:(NSString *)title wordLength:(NSString *)length;
{
    CGFloat width = 0.0;
    
    switch ([length intValue]) {
        case 5:
            width = kBarButton_5_Length;
            break;
        case 4:
            width = kBarButton_4_Length;
            break;
        case 3:
            width = kBarButton_3_Length;
            break;
        case 2:
            width = kBarButton_2_Length;
            break;
            
        default:
            width = kBarButton_2_Length;
            break;
    }
    
    CGRect frame  = CGRectMake(0, 6, width, 32);
    self = [super initWithFrame:frame];
    
    if (self) {
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.titleLabel.font = kNormalFont;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title wordLength:(NSString *)length
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.titleLabel.font = kNormalFont;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
