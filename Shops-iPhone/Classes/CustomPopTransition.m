//
//  CustomPopTransition.m
//  Shops-iPhone
//
//  Created by atyun on 15/7/3.
//  Copyright (c) 2015年 net.atyun. All rights reserved.o
//

#import "CustomPopTransition.h"
#import "CartViewController.h"
#import "CartNewViewController.h"

@implementation CustomPopTransition

#pragma mark - UIViewControllerAnimatedTransitioning -

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIViewController *fromViewController = (UIViewController*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    //    if ([toViewController isKindOfClass:[CartViewController class]] && self.reverse) {
    //        toViewController.tabBarController.tabBar.hidden = YES;
    //
    //        CartViewController *cartController = (CartViewController *) toViewController;
    //        cartController.needToHideBottomBar = NO;
    //    }
    
    if ([toViewController isKindOfClass:[CartNewViewController class]] && self.reverse) {
        toViewController.tabBarController.tabBar.hidden = YES;
        
        CartNewViewController *cartNewVC = (CartNewViewController *)toViewController;
        cartNewVC.needToHideBottomBar = NO;
    }
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    
    //[containerView bringSubviewToFront:fromViewController.view];
    
    // 配置阴影
    fromViewController.view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    fromViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    fromViewController.view.layer.shadowRadius = 5.0;
    fromViewController.view.layer.shadowOpacity = 0.5;
    [fromViewController.view.layer setShadowPath:[[UIBezierPath bezierPathWithRect:fromViewController.view.bounds] CGPath]];
    
    // Setup the initial view states
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    CGRect tabbarFrame = toViewController.tabBarController.tabBar.frame;
    CGRect tabbarFinalFrame = CGRectMake(0, tabbarFrame.origin.y, tabbarFrame.size.width, tabbarFrame.size.height)  ;
    
    if (self.reverse) {
        toViewController.view.frame = CGRectOffset(finalFrame, -kScreenWidth, 0);
    }
    else {
        toViewController.view.frame = CGRectOffset(finalFrame, kScreenWidth, 0);
    }
    
    [UIView animateWithDuration:0.3  animations:^{
        if (self.reverse) {
            toViewController.tabBarController.tabBar.frame = tabbarFinalFrame;
            
            fromViewController.view.frame = CGRectMake(toViewController.view.frame.size.width, fromViewController.view.frame.origin.y, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
            toViewController.view.frame = finalFrame;
        }
        else {
            fromViewController.view.frame = CGRectMake(-toViewController.view.frame.size.width, fromViewController.view.frame.origin.y, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
            toViewController.view.frame = finalFrame;
            toViewController.tabBarController.tabBar.frame = tabbarFinalFrame;
        }
        
    } completion:^(BOOL finished) {
        // Declare that we've finished
        //        if ([toViewController isKindOfClass:[CartViewController class]] && self.reverse) {
        //
        //            toViewController.tabBarController.tabBar.hidden = NO;
        //        }
        
        if ([toViewController isKindOfClass:[CartNewViewController class]] && self.reverse) {
            
            toViewController.tabBarController.tabBar.hidden = NO;
        }
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
