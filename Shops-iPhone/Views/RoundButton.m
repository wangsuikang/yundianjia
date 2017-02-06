//
//  RoundButton.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-16.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "RoundButton.h"

#import <QuartzCore/QuartzCore.h>

@implementation RoundButton

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame color:[UIColor blackColor]];
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layer.borderColor = color.CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;
        self.backgroundColor = color;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.color) {
        self.backgroundColor = self.color;
        self.layer.borderColor = self.color.CGColor;
    }
}

@end
