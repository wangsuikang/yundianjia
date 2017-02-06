//
//  ProductPhotoBrowserViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-7-15.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "ProductPhotoBrowserViewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "RightPanNavigationController.h"

// Classes
#import "CartManager.h"

// Categories
#import "UIView+AddBadge.h"

@interface ProductPhotoBrowserViewController ()

@end

@implementation ProductPhotoBrowserViewController

#pragma mark - View Life Cycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //RightPanNavigationController *rightPan = (RightPanNavigationController *)self.navigationController;
    //rightPan.canDragBack = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
