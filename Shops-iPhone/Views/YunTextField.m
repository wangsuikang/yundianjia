//
//  YunTextField.m
//  Shops-iPhone
//
//  Created by xxy on 15/9/24.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import "YunTextField.h"

@implementation YunTextField

- (id)initWithFrame:(CGRect)frame leftViewImage:(NSString *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.rightViewMode = UITextFieldViewModeAlways;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.font = kMidFont;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    }
    
    return self;
}

//- (CGRect)placeholderRectForBounds:(CGRect)bounds
//{
//    if (kDeviceOSVersion >= 7.0) {
//        return CGRectMake(bounds.origin.x + 5, bounds.origin.y, bounds.size.width, bounds.size.height);
//    } else {
//        return CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width, bounds.size.height);
//    }
//}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 0, 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
