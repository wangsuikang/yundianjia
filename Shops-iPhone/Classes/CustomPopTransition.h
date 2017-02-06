//
//  CustomPopTransition.h
//  Shops-iPhone
//
//  Created by atyun on 15/7/3.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPopTransition : NSObject <UIViewControllerAnimatedTransitioning>
/// 标记Controller之间的过渡方式
@property (nonatomic, assign) BOOL reverse;
@end
