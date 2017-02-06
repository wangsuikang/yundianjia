//
//  PopGestureRecognizerController.h
//  Shops-iPhone
//
//  Created by atyun on 14-10-31.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopGestureRecognizerController : UINavigationController

/**
 设置从屏幕中间滑动时候是否推出当前的Controller
 
 @param enabled 是否启用
 */
- (void)setPopGestureEnabled:(BOOL)enabled;

//- (void)setNarBarView:(NSString *)title leftItemTitle:(NSString *)leftTitle rectLeft:(CGRect)frame :

@end
