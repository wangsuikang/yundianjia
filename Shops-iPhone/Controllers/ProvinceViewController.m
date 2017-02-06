//
//  ProvinceViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-04.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "ProvinceViewController.h"

#import "AddressManager.h"
#import "CityViewController.h"
#import "AppDelegate.h"

@interface ProvinceViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ProvinceViewController


#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _provinces = [[AddressManager defaultManager] provinces];
        
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"省份";
        
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
    [button addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
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

- (void)backToPrev:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    appDelegate.province = @"";
    appDelegate.city = @"";
    appDelegate.area = @"";
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _provinces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [[_provinces objectAtIndex:indexPath.row] objectForKey:@"province_name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AppDelegate *appDelegate = kAppDelegate;
    YunLog(@"_provinces = %@", _provinces);
    
    appDelegate.province = [[_provinces objectAtIndex:indexPath.row] objectForKey:@"province_name"];
    appDelegate.address_province_no = [[_provinces objectAtIndex:indexPath.row] objectForKey:@"province_id"];
    
    CityViewController *city = [[CityViewController alloc] init];
    city.provinceID = [[_provinces objectAtIndex:indexPath.row] objectForKey:@"province_id"];
    city.addressEditing = _addressEditing;
    city.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:city animated:YES];
}

@end
