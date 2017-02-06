//
//  IndexTabViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-14.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "IndexTabViewController.h"

#import "LibraryHeadersForCommonController.h"

// Classes
#import "AppDelegate.h"

// Controllers
#import "ShopListViewController.h"
#import "CartViewController.h"
#import "CartNewViewController.h"
#import "MyViewController.h"
#import "AboutViewController.h"
#import "ClassViewController.h"
#import "MyIndividualViewController.h"
#import "RightPanNavigationController.h"
#import "PopGestureRecognizerController.h"

@interface IndexTabViewController () <UIGestureRecognizerDelegate>

@end

@implementation IndexTabViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //        HomePageViewController *home = [[HomePageViewController alloc] init];
        //        PopGestureRecognizerController *homeNC = [[PopGestureRecognizerController alloc] initWithRootViewController:home];
        ShopListViewController *list = [[ShopListViewController alloc] init];
        //        //RightPanNavigationController *listNC = [[RightPanNavigationController alloc] initWithRootViewController:list];
        PopGestureRecognizerController *listNC = [[PopGestureRecognizerController alloc] initWithRootViewController:list];
        
        
        //        ClassViewController *class = [[ClassViewController alloc] init];
        //        PopGestureRecognizerController *classNC = [[PopGestureRecognizerController alloc] initWithRootViewController:class];
        
        
        //        CartViewController *cart = [[CartViewController alloc] init];
        //        PopGestureRecognizerController *cartNC = [[PopGestureRecognizerController alloc] initWithRootViewController:cart];
        
        CartNewViewController *cartNewVC = [[CartNewViewController alloc] init];
        cartNewVC.isTabbarEnter = YES;
        PopGestureRecognizerController *cartNewNC = [[PopGestureRecognizerController alloc] initWithRootViewController:cartNewVC];
        
        //        MyViewController *my = [[MyViewController alloc] init];
        //        //RightPanNavigationController *myNC = [[RightPanNavigationController alloc] initWithRootViewController:my];
        //        PopGestureRecognizerController *myNC = [[PopGestureRecognizerController alloc] initWithRootViewController:my];
        //
        
        MyIndividualViewController *myIndividual = [[MyIndividualViewController alloc] init];
        PopGestureRecognizerController *myIndividualNC = [[PopGestureRecognizerController alloc] initWithRootViewController:myIndividual];
        
        
        AboutViewController *about = [[AboutViewController alloc] init];
        //RightPanNavigationController *aboutNC = [[RightPanNavigationController alloc] initWithRootViewController:about];
        PopGestureRecognizerController *aboutNC = [[PopGestureRecognizerController alloc] initWithRootViewController:about];
        
        NSArray *controllers = [NSArray arrayWithObjects:listNC, cartNewNC, myIndividualNC, aboutNC, nil];
        
        self.viewControllers = controllers;
    }
    
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.message) {
        [appDelegate handleAPNSMessage];
    }
    
    if (appDelegate.isLogin) {
        dispatch_group_t groups = dispatch_group_create();
        dispatch_group_async(groups, dispatch_get_main_queue(), ^{
            [self getCartProductsCount];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

// 获取购物车列表信息

- (void)getCartProductsCount
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"     :     kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *cartProductsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kCartBaseURL params:params];
    
    YunLog(@"cartProductsURL = %@", cartProductsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:cartProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"cartCount = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            NSInteger cartCount = [[[[responseObject objectForKey:@"data"] objectForKey:@"cart"] objectForKey:@"product_total_count"] integerValue];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)cartCount] forKey:@"cartCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
