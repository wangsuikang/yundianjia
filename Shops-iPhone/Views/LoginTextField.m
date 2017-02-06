//
//  LoginTextField.m
//  DoteeVideo_iPad
//
//  Created by rujax on 2013-10-10.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "LoginTextField.h"

@implementation LoginTextField

- (id)initWithFrame:(CGRect)frame leftViewImage:(NSString *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
        self.leftView = imageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        
        self.backgroundColor = kClearColor;
        self.font = kBigFont;
        self.borderStyle = UITextBorderStyleNone;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.returnKeyType = UIReturnKeyDone;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        
//        self.layer.borderColor = [UIColor orangeColor].CGColor;
//        self.layer.borderWidth = 1;
//        self.layer.cornerRadius = 6;
//        self.layer.masksToBounds = YES;
        
        self.leftView.layer.cornerRadius = 6;
        self.leftView.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)setLine
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
    line.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:line];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(40, self.bounds.size.height - 1, self.bounds.size.width - 40, 1)];
//        line.backgroundColor = [UIColor lightGrayColor];
//        
//        [self addSubview:line];
    }
    
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    if (kDeviceOSVersion >= 7.0) {
        return CGRectMake(bounds.origin.x + 40, bounds.origin.y + 4, bounds.size.width, bounds.size.height);
    } else {
        return CGRectMake(bounds.origin.x + 40, bounds.origin.y + 4, bounds.size.width, bounds.size.height);
    }
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [COLOR(222, 184, 135, 1) setFill];
//    [COLOR(147, 147, 147, 1) setFill];
    
    [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName:kNormalFont, NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 40, bounds.origin.y, bounds.size.width - 60, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 40, bounds.origin.y, bounds.size.width - 60, bounds.size.height);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(5, 0, 30, 30);
}

- (UITextFieldViewMode)leftViewMode
{
    return UITextFieldViewModeAlways;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 50, 8, 40, 24);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = kClearColor;
    self.font = kBigFont;
    self.borderStyle = UITextBorderStyleNone;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType = UIReturnKeyDone;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.leftViewMode = UITextFieldViewModeAlways;

    
//    self.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.layer.borderWidth = 1;
//    self.layer.cornerRadius = 6;
//    self.layer.masksToBounds = YES;
    
    self.leftView.layer.cornerRadius = 6;
    self.leftView.layer.masksToBounds = YES;
}

@end
