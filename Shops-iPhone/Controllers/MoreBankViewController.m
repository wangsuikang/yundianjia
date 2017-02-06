//
//  MoreBankViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/7/6.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MoreBankViewController.h"

#import "LibraryHeadersForCommonController.h"

@interface MoreBankViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *moreBankNameArray;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation MoreBankViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *navImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 38) / 2, 11, 38, 22)];
        
        navImageView.image = [UIImage imageNamed:@"ump_nav_icon"];
        
        self.navigationItem.titleView = navImageView;
        
        self.view.backgroundColor = kBackgroundColor;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidLoad];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    [self.navigationController.navigationBar setBarTintColor:COLOR(22, 108, 175, 1)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 50, 25);
    
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _moreBankNameArray = @[@"农业银行", @"邮储银行", @"交通银行", @"中信银行", @"华夏银行", @"上海银行", @"北京银行", @"东亚银行", @"兴业银行", @"宁波银行", @"浦发银行", @"广发银行", @"平安银行", @"包商银行", @"长沙银行", @"承德银行", @"成都农商银行", @"重庆农村商业银行", @"重庆银行", @"大连银行", @"东营市商业银行", @"鄂尔多斯银行", @"福建省农村信用社", @"贵阳银行", @"广州银行", @"广州农村商业银行", @"哈尔滨银行", @"湖南省农村信用社", @"徽商银行", @"河北银行", @"杭州银行", @"锦州银行", @"江苏常熟农村商业银行", @"江苏银行", @"江阴农村商业银行", @"九江银行", @"兰州银行", @"龙江银行", @"青海银行", @"上海农商银行", @"上饶银行", @"顺德农村商业银行", @"台州银行", @"威海市商业银行", @"潍坊银行", @"温州银行", @"乌鲁木齐商业银行", @"无锡农村商业银行", @"宜昌市商业银行", @"鄞州银行", @"浙江稠州商业银行", @"浙江泰隆商业银行", @"浙江民泰商业银行", @"南京银行", @"南昌银行", @"齐鲁银行", @"尧都农村商业银行", @"吴江农村商业银行"];
    
    
    [self createTableView];
}

- (void)createTableView
{
    UITableView *bankTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    
    bankTableView.delegate = self;
    bankTableView.dataSource = self;
    
    [self.view addSubview:bankTableView];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _moreBankNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"bankID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    } else {
        if (cell.contentView.subviews.count > 0)
        {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
    
    if ([self.selectedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = _moreBankNameArray[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YunLog(@"self.selectedIndexPath = %@", self.selectedIndexPath);
    if (self.selectedIndexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedIndexPath = indexPath;
}

- (void)doBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
