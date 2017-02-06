//
//  RightPanNavigationController.m
//  Shops-iPhone
//
//  Created by rujax on 14-2-10.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "RightPanNavigationController.h"

#import "Tool.h"

#import <QuartzCore/QuartzCore.h>

// Controllers
#import "MyShopViewController.h"

@interface RightPanNavigationController ()

@property (nonatomic, assign) CGPoint startTouch;

@property (nonatomic, strong) UIImageView *lastScreenshotView;
@property (nonatomic, strong) UIView *blackMask;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, copy) NSString *deviceModel;

@property (nonatomic, strong) NSMutableArray *screenShotsList;

@property (nonatomic, assign) BOOL isMoving;

@end

@implementation RightPanNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
        _canDragBack = YES;
        _deviceModel = [Tool getDeviceModel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);

    [self.view addSubview:shadowImageView];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(paningGestureReceive:)];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if ([_deviceModel integerValue] >= 60) {
//        [_screenShotsList addObject:[self capture]];
//    }
    
    [super pushViewController:viewController animated:animated];
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
//    if ([_deviceModel integerValue] >= 60) {
//        [_screenShotsList removeLastObject];
//    }
    
    return [super popViewControllerAnimated:animated];
}

- (void)dealloc
{
    _screenShotsList = nil;
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
}

#pragma mark - Utility Methods -

// get the current view screen shot
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    //    NSLog(@"Move to:%f",x);
    x = x > 320 ? 320 : x;
    x = x < 0 ? 0 : x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x / 6400) + 0.95;
    float alpha = 0.4 - (x / 800);
    
//    CGFloat aa = abs(-200 / kScreenWidth);
//    CGFloat y = x * aa;
//    
//    _lastScreenshotView.frame = CGRectMake(-200 + y, 0, kScreenWidth, kScreenHeight);
    
    _lastScreenshotView.transform = CGAffineTransformMakeScale(scale, scale);
    _blackMask.alpha = alpha;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan)
    {
        _isMoving = YES;
        _startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            _blackMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            _blackMask.backgroundColor = [UIColor grayColor]; // [UIColor blackColor];
            [self.backgroundView addSubview:_blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (_lastScreenshotView) [_lastScreenshotView removeFromSuperview];
        
        UIImage *lastScreenShot = [_screenShotsList lastObject];
        
        _lastScreenshotView = [[UIImageView alloc] initWithImage:lastScreenShot];
        
        [self.backgroundView insertSubview:_lastScreenshotView belowSubview:_blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }
    else if (recoginzer.state == UIGestureRecognizerStateEnded)
    {
        if (touchPoint.x - _startTouch.x > 50)
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self moveViewWithX:320];
                             }
                             completion:^(BOOL finished){                                 
                                 if ([[self.viewControllers lastObject] isKindOfClass:[MyShopViewController class]]) {
                                     [self popToRootViewControllerAnimated:NO];
                                 } else {
                                     [self popViewControllerAnimated:NO];
                                 }
                
                                 CGRect frame = self.view.frame;
                                 frame.origin.x = 0;
                                 self.view.frame = frame;
                
                                 _isMoving = NO;
                             }];
        }
        else
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self moveViewWithX:0];
                             }
                             completion:^(BOOL finished){
                                 _isMoving = NO;
                                 _backgroundView.hidden = YES;
                             }];
        }
        
        return;
        
        // cancal panning, alway move to left side automatically
    }
    else if (recoginzer.state == UIGestureRecognizerStateCancelled)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self moveViewWithX:0];
                         }
                         completion:^(BOOL finished){
                             _isMoving = NO;
                             _backgroundView.hidden = YES;
                         }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - _startTouch.x];
    }
}

@end
