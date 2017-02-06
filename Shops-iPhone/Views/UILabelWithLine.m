//
//  UILabelWithLine.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-05.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "UILabelWithLine.h"

@interface UILabelWithLine()

@property (nonatomic, assign) PositionType position;

@end

@implementation UILabelWithLine

- (id)initWithFrame:(CGRect)frame position:(PositionType)position
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _position = position;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _position = PositionCenter;
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGSize fontSize = [self.text sizeWithFont:self.font size:rect.size];
    
    CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);  // set as the text's color
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGPoint leftPoint;
    CGPoint rightPoint;
    
    switch (_position) {
        case PositionCenter:
            leftPoint = CGPointMake(0, self.frame.size.height / 2);
            rightPoint = CGPointMake(fontSize.width, self.frame.size.height / 2);
            break;
            
        case PositionBottom:
            leftPoint = CGPointMake(0, self.frame.size.height);
            rightPoint = CGPointMake(fontSize.width, self.frame.size.height);
            break;
            
        case PositionTop:
            leftPoint = CGPointMake(0, 0);
            rightPoint = CGPointMake(fontSize.width, 0);
            break;
            
        default:
            break;
    }

    CGContextMoveToPoint(ctx, leftPoint.x, leftPoint.y);
    CGContextAddLineToPoint(ctx, rightPoint.x, rightPoint.y);
    CGContextStrokePath(ctx);
}

@end
