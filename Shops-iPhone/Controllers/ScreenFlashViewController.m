//
//  ScreenFlashViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-14.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "ScreenFlashViewController.h"

// Classes
#import "AppDelegate.h"
#import "Tool.h"

// Controllers
#import "IndexTabViewController.h"
#import "GuideViewController.h"

NSInteger const k3_5InchScreenFlashHeight = 720;
NSInteger const k4InchScreenFlashHeight = 896;

@interface ScreenFlashViewController ()

@end

@implementation ScreenFlashViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
//    if (kScreenHeight == 480) {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"screen_flash_bg_320_480"]];
//    } else {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"screen_flash_bg_320_568"]];
//    }
	
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.backgroundColor = kClearColor;
    
    UIImage *image = [Tool getScreenFlash];
    imageView.image = image ? image : (kScreenHeight == 480 ? [UIImage imageNamed:@"screen_flash_320_480"] : [UIImage imageNamed:@"screen_flash_320_568"]);
    
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        imageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    double delayInSeconds = 3.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self goToIndex];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    if (kDeviceOSVersion >= 7.0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Private Functions -

- (void)goToIndex
{
//    GuideViewController *guide = [[GuideViewController alloc] init];
//    
//    [self presentViewController:guide animated:NO completion:nil];
//    
//    return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastAppVersion = [defaults objectForKey:kLastAppVersion];
    
    NSString *currentAppVersion = [Tool versionString];
    
    YunLog(@"currentAppVersion = %@", currentAppVersion);
    
    if (!lastAppVersion) {
        [defaults setObject:currentAppVersion forKey:kLastAppVersion];
        
        [defaults synchronize];
        
        GuideViewController *guide = [[GuideViewController alloc] init];
        
        [self presentViewController:guide animated:NO completion:nil];
    } else {
        if ([lastAppVersion integerValue] < [currentAppVersion integerValue]) {
            [defaults setObject:currentAppVersion forKey:kLastAppVersion];
            
            [defaults synchronize];
            
            GuideViewController *guide = [[GuideViewController alloc] init];
            
            [self presentViewController:guide animated:NO completion:nil];
        } else {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
//                IndexTabViewController *index = [[IndexTabViewController alloc] init];
                
                AppDelegate *appDelegate = kAppDelegate;
                appDelegate.indexTab = [[IndexTabViewController alloc] init];
                
                appDelegate.window.rootViewController = appDelegate.indexTab;
                [appDelegate.window makeKeyAndVisible];
            });
        }
    }
}

@end
