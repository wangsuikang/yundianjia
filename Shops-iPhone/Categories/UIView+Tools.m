//
//  UIView+Tools.m
//  Shops-iPhone
//
//  Created by rujax on 14-9-26.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "UIView+Tools.h"

@implementation UIView (Tools)

#pragma mark - Add Border With Direction

- (void)addBorderWithDirection:(AddBorderDirection)direction
{
//    if ((direction & AddBorderDirectionTop) != 0) {
//        CALayer *layer = [CALayer layer];
//        layer.frame = CGRectMake(0, 0, self.frame.size.width, 1);
//        layer.backgroundColor = [UIColor lightGrayColor].CGColor;
//        
//        [self.layer addSublayer:layer];
//    }
//    
//    if ((direction & AddBorderDirectionRight) != 0) {
//        CALayer *layer = [CALayer layer];
//        layer.frame = CGRectMake(self.frame.size.width, 0, 1, self.frame.size.height);
//        layer.backgroundColor = [UIColor lightGrayColor].CGColor;
//        
//        [self.layer addSublayer:layer];
//    }
//    
//    if ((direction & AddBorderDirectionBottom) != 0) {
//        CALayer *layer = [CALayer layer];
//        layer.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
//        layer.backgroundColor = [UIColor lightGrayColor].CGColor;
//        
//        [self.layer addSublayer:layer];
//    }
//    
//    if ((direction & AddBorderDirectionLeft) != 0) {
//        CALayer *layer = [CALayer layer];
//        layer.frame = CGRectMake(0, 0, 1, self.frame.size.height);
//        layer.backgroundColor = [UIColor lightGrayColor].CGColor;
//        
//        [self.layer addSublayer:layer];
//    }
    
    [self addBorderWithDirection:direction color:[UIColor lightGrayColor] border:1 indent:0];
}

- (void)addBorderWithDirection:(AddBorderDirection)direction color:(UIColor *)color border:(CGFloat)border indent:(CGFloat)indent
{
    if ((direction & AddBorderDirectionTop) != 0) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(indent, 0, self.frame.size.width - indent * 2, border);
        layer.backgroundColor = color.CGColor;
        
        [self.layer addSublayer:layer];
    }
    
    if ((direction & AddBorderDirectionRight) != 0) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(self.frame.size.width - border, indent, border, self.frame.size.height - indent * 2);
        layer.backgroundColor = color.CGColor;
        
        [self.layer addSublayer:layer];
    }
    
    if ((direction & AddBorderDirectionBottom) != 0) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(indent, self.frame.size.height - border, self.frame.size.width - indent * 2, border);
        layer.backgroundColor = color.CGColor;
        
        [self.layer addSublayer:layer];
    }
    
    if ((direction & AddBorderDirectionLeft) != 0) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, indent, border, self.frame.size.height - indent * 2);
        layer.backgroundColor = color.CGColor;
        
        [self.layer addSublayer:layer];
    }
}

@end
