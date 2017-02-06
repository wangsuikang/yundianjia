//
//  SearchTextField.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
        left.backgroundColor = [UIColor orangeColor];
        left.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
        left.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        [left setTitle:@"商品▼" forState:UIControlStateNormal];
//        [left setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [left addTarget:self action:@selector(pressLeft) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 34, 32)];
        label.backgroundColor = kClearColor;
        label.font = [UIFont fontWithName:kFontFamily size:16];
        label.textColor = [UIColor whiteColor];
        label.text = @"商品";
        label.tag = TitleLabel;
        
        [left addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(44, 7, 8, 18)];
        imageView.image = [UIImage imageNamed:@"search_down"];
        imageView.tag = ArrowImageView;
        
        [left addSubview:imageView];
        
        self.leftView = left;
        
        self.backgroundColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:kFontFamily size:14];
        self.borderStyle = UITextBorderStyleNone;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.returnKeyType = UIReturnKeySearch;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textColor = [UIColor orangeColor];
        
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        
        self.leftViewMode = UITextFieldViewModeAlways;
        
//        self.leftView.layer.cornerRadius = 6;
//        self.leftView.layer.masksToBounds = YES;
    }
    
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    if (kDeviceOSVersion < 7.0) {
        return CGRectMake(bounds.origin.x + 65, bounds.origin.y + (bounds.size.height - 30) / 2, bounds.size.width, bounds.size.height);
    } else {
        return CGRectMake(bounds.origin.x + 65, bounds.origin.y + (bounds.size.height - 12) / 2, bounds.size.width, bounds.size.height);
    }
    
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [[UIColor lightGrayColor] setFill];
    
//    [self.placeholder drawInRect:rect withFont:kSmallFont];
    [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName:kSmallFont}];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 65, bounds.origin.y, bounds.size.width - 80, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 65, bounds.origin.y, bounds.size.width - 80, bounds.size.height);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, 0, 60, bounds.size.height);
}

- (UITextFieldViewMode)leftViewMode
{
    return UITextFieldViewModeAlways;
}

//- (CGRect)rightViewRectForBounds:(CGRect)bounds
//{
//    return CGRectMake(bounds.size.width - 50, 8, 40, 24);
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    self.backgroundColor = kClearColor;
//    self.font = kBigFont;
//    self.borderStyle = UITextBorderStyleNone;
//    self.clearButtonMode = UITextFieldViewModeWhileEditing;
//    self.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    self.returnKeyType = UIReturnKeyDone;
//    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.textColor = [UIColor orangeColor];
//    
//    self.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.layer.borderWidth = 1;
//    self.layer.cornerRadius = 6;
//    self.layer.masksToBounds = YES;
//    
//    self.leftView.layer.cornerRadius = 6;
//    self.leftView.layer.masksToBounds = YES;
//}

- (void)pressLeft
{
    if ([self.searchDelegate respondsToSelector:@selector(searchTextFieldToggleType:)]) {
        [self.searchDelegate searchTextFieldToggleType:self];
    }
}

@end
