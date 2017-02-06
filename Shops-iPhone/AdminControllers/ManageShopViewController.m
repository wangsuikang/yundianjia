//
//  ManageShopViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/7.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ManageShopViewController.h"

//  Controllers
#import "AdminShopDetailViewController.h"
#import "AdminCompanyInfoViewController.h"
#import "OrganizationInfoViewController.h"
#import "ContractInfoViewController.h"
#import "InvoiceInfoViewController.h"
#import "AccountInfoViewController.h"
#import "AccountNumberInfoViewController.h"

@interface ManageShopViewController () <UITableViewDataSource, UITableViewDelegate>

/// 信息栏标题数组
@property (nonatomic, strong) NSArray *titleArray;
@end

@implementation ManageShopViewController

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
        naviTitle.text = @"管理店铺";
        
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
    
    NSArray *sectionOne = @[@"店铺详情", @"店面装修", @"供应商账号信息"];
    NSArray *sectionTwo = @[@"店铺联系人信息", @"供应商企业信息", @"组织机构代码信息", @"合同信息"];
    NSArray *sectionThree = @[@"账户结算信息", @"税务发票信息"];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    AdminShopDetailViewController *adminShopDetail = [[AdminShopDetailViewController alloc] init];
                    
                    [self.navigationController pushViewController:adminShopDetail animated:YES];
                    
                    break;
                }
                    
                case 1:
                {
                    break;
                }
                    
                case 2:
                {
                    AccountNumberInfoViewController *accountNumberInfo = [[AccountNumberInfoViewController alloc] init];
                    
                    [self.navigationController pushViewController:accountNumberInfo animated:YES];
                    
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    break;
                }
                    
                case 1:
                {
                    AdminCompanyInfoViewController *adminCompanyInfo = [[AdminCompanyInfoViewController alloc] init];
                    
                    [self.navigationController pushViewController:adminCompanyInfo animated:YES];
                    
                    break;
                }
                    
                case 2:
                {
                    OrganizationInfoViewController *organizationInfo = [[OrganizationInfoViewController alloc] init];
                    
                    [self.navigationController pushViewController:organizationInfo animated:YES];
                    
                    break;
                }
                    
                case 3:
                {
                    ContractInfoViewController *contractInfo = [[ContractInfoViewController alloc] init];
                    
                    [self.navigationController pushViewController:contractInfo animated:YES];
                    
                    break;
                }
                    
                default:
                    break;
            }

            break;
        }
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    AccountInfoViewController *accountInfo = [[AccountInfoViewController alloc] init];
                    
                    [self.navigationController pushViewController:accountInfo animated:YES];
                    
                    break;
                }
                    
                case 1:
                {
                    InvoiceInfoViewController *invoiceInfo = [[InvoiceInfoViewController alloc] init];
                    
                    [self.navigationController pushViewController:invoiceInfo animated:YES];
                    
                    break;
                }
                    
                default:
                    break;
            }

            break;
        }
            
        default:
            break;
    }
}
@end
