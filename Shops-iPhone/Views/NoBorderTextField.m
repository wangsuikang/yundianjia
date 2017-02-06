//
//  NoBorderTextField.m
//  Shops-iPhone
//
//  Created by rujax on 14-3-19.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "NoBorderTextField.h"

@implementation NoBorderTextField

- (id)initWithFrame:(CGRect)frame leftViewImage:(NSString *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
        self.leftView = imageView;
        
//        self.backgroundColor = kClearColor;
//        self.font = kBigFont;
//        self.borderStyle = UITextBorderStyleNone;
//        self.clearButtonMode = UITextFieldViewModeWhileEditing;
//        self.autocorrectionType = UITextAutocorrectionTypeNo;
//        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        self.returnKeyType = UIReturnKeyDone;
//        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        self.textColor = [UIColor orangeColor];
        
//        self.leftView.layer.cornerRadius = 6;
//        self.leftView.layer.masksToBounds = YES;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

//- (CGRect)placeholderRectForBounds:(CGRect)bounds
//{
//    CGFloat space = (bounds.size.height - self.leftView.frame.size.height) / 2;
//    
//    if (kDeviceOSVersion >= 7.0) {
//        return CGRectMake(bounds.origin.x + 30 + space + 10, bounds.origin.y + (bounds.size.height - 16) / 2, bounds.size.width, bounds.size.height);
//    } else {
//        return CGRectMake(bounds.origin.x + 30 + space + 10, bounds.origin.y + 4, bounds.size.width, bounds.size.height);
//    }
//}
//
//- (void)drawPlaceholderInRect:(CGRect)rect
//{
////    [COLOR(222, 184, 135, 1) setFill];
//    [COLOR(178, 178, 178, 1) setFill];
//    
//    [self.placeholder drawInRect:rect withFont:kSmallFont];
//}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGFloat space = (bounds.size.height - self.leftView.frame.size.height) / 2;
    
    return CGRectMake(bounds.origin.x + self.leftView.frame.size.height + space + 10, bounds.origin.y, bounds.size.width - 65 - space, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGFloat space = (bounds.size.height - self.leftView.frame.size.height) / 2;
    
    return CGRectMake(bounds.origin.x + self.leftView.frame.size.height + space + 10, bounds.origin.y - 20, bounds.size.width - 65 - space, bounds.size.height);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
//    YunLog(@"%@", NSStringFromCGRect(self.leftView.frame));
    
    CGFloat leftViewHeight = self.leftView.frame.size.height;
    CGFloat space = (bounds.size.height - leftViewHeight) / 2;
    
    return CGRectMake(space, space - 1, leftViewHeight, leftViewHeight);
}

- (UITextFieldViewMode)leftViewMode
{
    return UITextFieldViewModeAlways;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 55, 8, 40, 24);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor blueColor];
    self.borderStyle = UITextBorderStyleNone;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType = UIReturnKeyDone;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textColor = [UIColor orangeColor];
    
    CALayer *bottomLine = [CALayer layer];
    bottomLine.frame = CGRectMake(0, rect.size.height - 1, rect.size.width, 1);
    bottomLine.backgroundColor = COLOR(188, 188, 188, 1).CGColor;
    
    [self.layer addSublayer:bottomLine];
}

@end
