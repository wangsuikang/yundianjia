//
//  LoginButton.m
//  Shops-iPhone
//
//  Created by cml on 15/10/10.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import "LoginButton.h"

@implementation LoginButton
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(10, 0, contentRect.size.width - 20, contentRect.size.height - 20);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, contentRect.size.height - 15, contentRect.size.width, 10);
}

@end
