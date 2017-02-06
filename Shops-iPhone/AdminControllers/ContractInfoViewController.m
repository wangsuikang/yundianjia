//
//  ContractInfoViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/7.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ContractInfoViewController.h"

@interface ContractInfoViewController () <UITableViewDataSource, UITableViewDelegate>

/// 信息栏标题数组
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation ContractInfoViewController

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
        naviTitle.text = @"合同信息";
        
        self.navigationItem.titleView = naviTitle;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        backItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *sectionOne = @[@"合同有效开始时间", @"法定代表人姓名", @"法定代表证件类型"];
    NSArray *sectionTwo = @[@"身份证号", @"企业法人证件号", @"营业执照号", @"业务税务登记证"];
    NSArray *sectionThree = @[@"行业资质相关许可证"];
    
    _titleArray = @[sectionOne,sectionTwo,sectionThree];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _titleArray[section];
    
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kIsiPhone) {
        return 44;
    }
    else
    {
        return 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSArray *arr = _titleArray[indexPath.section];
    
    cell.textLabel.text = arr[indexPath.row];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    if (kIsiPhone) {
        cell.textLabel.font = kNormalBoldFont;
    } else {
        cell.textLabel.font = kBigBoldFont;
    }
    
    return cell;
}

@end
