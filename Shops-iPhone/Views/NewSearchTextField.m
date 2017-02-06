//
//  NewSearchTextField.m
//  Shops-iPhone
//
//  Created by cml on 15/6/11.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "NewSearchTextField.h"

@implementation NewSearchTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
        left.backgroundColor = [UIColor orangeColor];
        left.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
        left.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
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
        self.font = [UIFont fontWithName:kLetterFamily size:14];
        //self.borderStyle = UITextBorderStyleBezel;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.returnKeyType = UIReturnKeySearch;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textColor = [UIColor orangeColor];
        
//        self.leftView = searchView;
    }
    
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    if (kDeviceOSVersion < 7.0) {
        return CGRectMake(bounds.origin.x + 65, bounds.origin.y + (bounds.size.height - 30) / 2, bounds.size.width, bounds.size.height);
    } else {
        return CGRectMake(bounds.origin.x + 65, bounds.origin.y + (bounds.size.height - 20) / 2, bounds.size.width, bounds.size.height);
    }
    
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName:kNormalBoldFont,NSForegroundColorAttributeName:[UIColor orangeColor]}];

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

- (void)pressLeft
{
    if ([self.searchDelegate respondsToSelector:@selector(searchTextFieldToggleType:)]) {
        [self.searchDelegate searchTextFieldToggleType:self];
    }
}

@end
