//
//  SaleTextField.m
//  Shops-iPhone
//
//  Created by cml on 15/9/2.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "SaleTextField.h"

@implementation SaleTextField

- (id)initWithFrame:(CGRect)frame leftViewImage:(NSString *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
    
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
//    if (kDeviceOSVersion >= 7.0) {
//        return CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width, bounds.size.height);
//    } else {
//        return CGRectMake(bounds.origin.x + 100, bounds.origin.y, bounds.size.width, bounds.size.height);
//    }
//}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
}


@end
