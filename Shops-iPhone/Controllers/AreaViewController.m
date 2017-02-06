//
//  AreaViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-04.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AreaViewController.h"

// Classes
#import "AddressManager.h"
#import "AppDelegate.h"

@interface AreaViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *areas;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AreaViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"地区";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _areas = [[AddressManager defaultManager] areasWithCityID:_cityID];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.area = @"";
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _areas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [[_areas objectAtIndex:indexPath.row] objectForKey:@"county_name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AppDelegate *appDelegate = kAppDelegate;
    appDelegate.area = [[_areas objectAtIndex:indexPath.row] objectForKey:@"county_name"];
    appDelegate.address_area_no = [[_areas objectAtIndex:indexPath.row] objectForKey:@"county_id"];
    
    //    CATransition *transition = [CATransition animation];
    //    transition.duration = 0.5f;
    //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    transition.type = @"cube";
    //    transition.subtype = kCATransitionFromRight;
    //    transition.delegate = self;
    //
    //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
