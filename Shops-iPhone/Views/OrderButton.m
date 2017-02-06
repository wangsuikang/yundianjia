//
//  OrderButton.m
//  Shops-iPhone
//
//  Created by cml on 15/10/14.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import "OrderButton.h"

@implementation OrderButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    if (kIsiPhone) {
        return CGRectMake((contentRect.size.width - 20) / 2, (contentRect.size.height - 40) / 2, 20, 20);
    } else
    {
        return CGRectMake((contentRect.size.width - 40) / 2, (contentRect.size.height - 60) / 2, 40, 40);
    }
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (kIsiPhone) {
        return CGRectMake(0, contentRect.size.height - (contentRect.size.height - 40) / 2 - 20, contentRect.size.width, 20);
    } else
    {
        return CGRectMake(0, contentRect.size.height - (contentRect.size.height - 60) / 2 - 20, contentRect.size.width, 20);
    }
}

@end
