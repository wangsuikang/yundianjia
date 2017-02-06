//
//  AddressDefaultIcon.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-27.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AddressDefaultIcon.h"

@interface AddressDefaultIcon()

@property (nonatomic, strong) UILabel *label;

@end

@implementation AddressDefaultIcon

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = kClearColor;
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.font = kSmallFont;
        _label.backgroundColor = kClearColor;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor orangeColor];
        _label.text = @"默认";
        
        [self addSubview:_label];
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
