//
//  AdminDistributeProductsViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminDistributeGroupViewController.h"

//  Controllers
#import "DistributorGroupProductViewController.h"
#import "AddNewGroupViewController.h"
#import "ModifyAgreementViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Libraries
#import "LTableViewCell.h"
#import "SwipeTableView/SWTableViewCell.h"

@interface AdminDistributeGroupViewController () <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

/// 分销商品组列表
@property (nonatomic, strong) UITableView *tableView;

/// 存放cell的选中
@property (nonatomic, strong) NSMutableArray *contacts;

/// 全选按钮
@property (nonatomic, strong) UIButton *allSelectButton;

/// 编辑按钮
@property (nonatomic, strong) UIButton *editButton;

/// 底部视图
@property (nonatomic, strong) UIView *buttomView;

/// 商品组数组
@property (nonatomic, strong) NSMutableArray *product_groups;

/// 商品组相关信息数组
@property (nonatomic, strong) NSMutableArray *distributions;

/// 是否在加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) NSInteger pageNonce;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 提示标签
@property (nonatomic, strong) UILabel *label;

@end

@implementation AdminDistributeGroupViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = [kNullToString(_distributorName) isEqualToString:@""] ? @"我的商品组" : _distributorName;
    
    self.navigationItem.titleView = naviTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRereshing) name:kNotificationAddNewDistributorGroupSuccess object:nil];
    
    _product_groups = [NSMutableArray array];
    _distributions = [NSMutableArray array];
    
    self.view.backgroundColor = kGrayColor;
    
    _contacts = [NSMutableArray array];
    
//    _buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 49)];
//    _buttomView.backgroundColor = kGrayColor;
//    
//    [self.view addSubview:_buttomView];
//    
//    _allSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _allSelectButton.frame = CGRectMake(10, 0, 80, 49);
//    _allSelectButton.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [_allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
//    [_allSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    _allSelectButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
//    [_allSelectButton addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_buttomView addSubview:_allSelectButton];
//    
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(kScreenWidth - 150 - 10, 0, 150, 49);
//    addButton.titleLabel.textAlignment = NSTextAlignmentRight;
//    [addButton setTitle:@"删除商品组" forState:UIControlStateNormal];
//    [addButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//    addButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
//    
//    [_buttomView addSubview:addButton];
    
    [self getNextPageViewIsPullDown:YES withPage:1];
    
    [self createUI];
    
    [self createMJRefresh];
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
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

- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _isLoading = YES;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    NSDictionary *params = @{@"distribution_owner_id"   :   kNullToString(_distribution_owner_id),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"page"                    :   [NSString stringWithFormat:@"%ld",(long)page],
                             @"per"                     :   @"8",
                             @"shop_id"                 :   kNullToString(_shopID)};
    
    NSString *groupListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:@"/distributors/get_product_groups_from_shop.json" params:params];
    
    YunLog(@"groupListURLURL = %@", groupListURL);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:groupListURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YunLog(@"分销商商品组responseObject = %@", responseObject);
        NSArray *newGroup = [NSArray array];
        NSArray *newDistribution = [NSArray array];
        if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
        {
            newGroup = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"product_groups"]);
            newDistribution = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"distributions"]);;
            
            for (int i = 0; i < newGroup.count; i++) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:@"NO" forKey:@"checked"];
                [_contacts addObject:dic];
            }

            if (newGroup.count < 8)
            {
                _tableView.footerHidden = YES;
            }
            else
            {
                _tableView.footerHidden = NO;
            }
            
            if (pullDown == YES)
            {
                [_product_groups setArray:newGroup];
                [_distributions setArray:newDistribution];
            }
            else
            {
                [_product_groups addObjectsFromArray:newGroup];
                [_distributions addObjectsFromArray:newDistribution];
                YunLog(@"newGroup = %@",newGroup);
            }
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
            _hud.hidden = YES;
            
            if (_product_groups.count == 0)
            {
                _tableView.backgroundView.hidden = NO;
                _tableView.headerHidden = YES;
                _label.hidden = YES;
            }
            else
            {
                _tableView.backgroundView.hidden = YES;
                _tableView.headerHidden = NO;
                _label.hidden = NO;
            }
        }
        else
        {
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            _tableView.footerHidden = NO;
            
            [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
        }
        _isLoading = NO;
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
        YunLog(@"我的商品URL - error = %@", error);
        
        _tableView.backgroundView.hidden = NO;
        
        [_tableView footerEndRefreshing];
        [_tableView headerEndRefreshing];
        _tableView.footerHidden = NO;
        _isLoading = NO;
    }];
}

- (void)createUI
{
    // 编辑按钮
//    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _editButton.frame = CGRectMake(20, 69, 70, 34);
//    _editButton.backgroundColor = kBlueColor;
//    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
//    _editButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//    [_editButton addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
//    _editButton.layer.masksToBounds = YES;
//    _editButton.layer.cornerRadius = 5;
//    [self.view addSubview:_editButton];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, 200, 44)];
    _label.text = @"左划可移除商品组";
    _label.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    _label.textColor = [UIColor grayColor];
    
    [self.view addSubview:_label];
    
    // +添加 分销商品组
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(kScreenWidth - 10 - 150, 64, 150, 44);
    [addButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [addButton setTitle:@"+添加 分销商品组" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    [addButton addTarget:self action:@selector(goToAddGroup) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 44, kScreenWidth, kScreenHeight - 64 - 44) style:UITableViewStylePlain];
    _tableView.backgroundColor = kGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _tableView.allowsSelectionDuringEditing = YES;
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无分销商品组";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;
    
    [self.view addSubview:_tableView];
}

- (void)allSelect:(UIButton *)sender
{
    NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[_tableView indexPathsForVisibleRows]];
    for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
        NSIndexPath *indexPath= [anArrayOfIndexPath objectAtIndex:i];
        LTableViewCell *cell = (LTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath];
        
        NSUInteger row = [indexPath row];
        
        NSMutableDictionary *dic = [_contacts objectAtIndex:row];
        if ([[[(UIButton*)sender titleLabel] text] isEqualToString:@"全选"]) {
            [dic setObject:@"YES" forKey:@"checked"];
            [cell setChecked:YES];
        }else {
            [dic setObject:@"NO" forKey:@"checked"];
            [cell setChecked:NO];
        }
    }
    if ([[[(UIButton*)sender titleLabel] text] isEqualToString:@"全选"]) {
        for (NSDictionary *dic in _contacts) {
            [dic setValue:@"YES" forKey:@"checked"];
        }
        [(UIButton*)sender setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        for (NSDictionary *dic in _contacts) {
            [dic setValue:@"NO" forKey:@"checked"];
        }
        [(UIButton*)sender setTitle:@"全选" forState:UIControlStateNormal];
    }
}

- (void)changeView
{
    if ([_editButton.titleLabel.text isEqualToString:@"编辑"])
    {
        [UIView animateWithDuration:0.5 animations:^{
            _buttomView.frame = CGRectMake(0, kScreenHeight - 49, kScreenWidth, 64);
            _tableView.frame = CGRectMake(0, 64 + 44, kScreenWidth, kScreenHeight - 64 - 44 - 49);
            
            [_editButton setTitle:@"完成" forState:UIControlStateNormal];
        }];

    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            _buttomView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 64);
            _tableView.frame = CGRectMake(0, 64 + 44, kScreenWidth, kScreenHeight - 64 - 44);
            
            [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        }];
    }
}

- (void)goToProductsList:(UIButton *)sender
{
    DistributorGroupProductViewController *productsList = [[DistributorGroupProductViewController alloc] init];
    
    NSDictionary *group = [_product_groups[sender.tag] objectForKey:@"product_group"];
    
    productsList.isDistributor = YES;
    productsList.distributeGroupName = kNullToString([group objectForKey:@"name"]);
    productsList.pg_id = kNullToString([group objectForKey:@"id"]);
    productsList.sid = kNullToString([group objectForKey:@"shop_id"]);
    productsList.distribution_owner_id = kNullToString(_distribution_owner_id);
    
    [self.navigationController pushViewController:productsList animated:YES];
}

- (void)goToAddGroup
{
    AddNewGroupViewController *addGroup = [[AddNewGroupViewController alloc] init];
    
    addGroup.distribution_shop_id = kNullToString(_shopID);
    
    addGroup.distributorName = kNullToString(_distributorName);
    
    addGroup.distribution_owner_id = kNullToString(_distribution_owner_id);
    
    [self.navigationController pushViewController:addGroup animated:YES];
}

- (void)modifyAgreement:(UIButton *)sender
{
    NSDictionary *distribution = kNullToArray([_distributions[sender.tag] objectForKey:@"distribution"]);
    
    ModifyAgreementViewController *modifyAgreement = [[ModifyAgreementViewController alloc] init];
    modifyAgreement.distribution = distribution;
    
    [self.navigationController pushViewController:modifyAgreement animated:YES];
}

#pragma mark - Pull Refresh -

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh{
    
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

/**
 下拉刷新响应方法
 */
- (void)headerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce = 1;
    
    [self getNextPageViewIsPullDown:YES withPage:_pageNonce];
}

/**
 上拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce++;
    
    [self getNextPageViewIsPullDown:NO withPage:_pageNonce];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _product_groups.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    NSDictionary *group = [_product_groups[indexPath.row] objectForKey:@"product_group"];
    NSDictionary *distribution = [_distributions[indexPath.row] objectForKey:@"distribution"];
    
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID tableView:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.rightUtilityButtons = [self rightButtons];
        cell.backgroundColor = kClearColor;
        cell.delegate = self;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    // cell的背景视图
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    UILabel *productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth - 150 - 20, 20)];
    productNameLabel.text  = kNullToString([group objectForKey:@"name"]);
    productNameLabel.textColor = [UIColor darkGrayColor];
    productNameLabel.textAlignment = NSTextAlignmentLeft;
    productNameLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:productNameLabel];
    
//    UILabel *supplyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(productNameLabel.frame), 150, 20)];
//    supplyNameLabel.text  = [NSString stringWithFormat:@"上级供应商:%@", _distributorName];
//    supplyNameLabel.textColor = [UIColor darkGrayColor];
//    supplyNameLabel.textAlignment = NSTextAlignmentLeft;
//    supplyNameLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
//    
//    [backView addSubview:supplyNameLabel];
    
    UILabel *divideLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(productNameLabel.frame) + 10, 65, 20)];
    divideLabel.text  = @"分成比例:";
    divideLabel.textColor = [UIColor darkGrayColor];
    divideLabel.textAlignment = NSTextAlignmentLeft;
    divideLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:divideLabel];
    
    UILabel *divideNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(divideLabel.frame), CGRectGetMaxY(productNameLabel.frame) + 10, 80, 20)];
    if ([kNullToString([distribution objectForKey:@"percentage"]) isEqualToString:@""])
    {} else {
        divideNumberLabel.text  = [NSString stringWithFormat:@"%@％", kNullToString([distribution objectForKey:@"percentage"])];
    }
    divideNumberLabel.textColor = [UIColor redColor];
    divideNumberLabel.textAlignment = NSTextAlignmentLeft;
    divideNumberLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:divideNumberLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(divideLabel.frame) + 10, kScreenWidth - 150 - 20, 20)];
    timeLabel.text  = kNullToString([[group objectForKey:@"updated_at"]substringWithRange:NSMakeRange(0, 10)]);;
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:timeLabel];

    UIButton *goToProduct = [UIButton buttonWithType:UIButtonTypeCustom];
    goToProduct.frame = CGRectMake(kScreenWidth - 20 - 120, 10, 120, 35);
    [goToProduct setTitle:@"查看商品组商品" forState:UIControlStateNormal];
    [goToProduct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goToProduct.titleLabel.textAlignment = NSTextAlignmentCenter;
    goToProduct.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    goToProduct.backgroundColor = kOrangeColor;
    goToProduct.alpha = 0.85;
    goToProduct.layer.masksToBounds = YES;
    goToProduct.layer.cornerRadius = 5;
    goToProduct.tag = indexPath.row;
    [goToProduct addTarget:self action:@selector(goToProductsList:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:goToProduct];
    
    UIButton *goToShop = [UIButton buttonWithType:UIButtonTypeCustom];
    goToShop.frame = CGRectMake(kScreenWidth - 20 - 120, CGRectGetMaxY(goToProduct.frame) + 10, 120, 35);
    [goToShop setTitle:@"修改分销协议" forState:UIControlStateNormal];
    [goToShop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goToShop.titleLabel.textAlignment = NSTextAlignmentCenter;
    goToShop.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    goToShop.backgroundColor = kLightBlackColor;
    goToShop.alpha = 0.85;
    goToShop.layer.masksToBounds = YES;
    goToShop.layer.cornerRadius = 5;
    goToShop.tag = indexPath.row;
    [goToShop addTarget:self action:@selector(modifyAgreement:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:goToShop];
    
//    NSUInteger row = [indexPath row];
//    NSMutableDictionary *dic = [_contacts objectAtIndex:row];
//    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
//        [dic setObject:@"NO" forKey:@"checked"];
//        [cell setChecked:NO];
//        
//    }else {
//        [dic setObject:@"YES" forKey:@"checked"];
//        [cell setChecked:YES];
//    }

    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    LTableViewCell *cell = (LTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//    
//    NSUInteger row = [indexPath row];
//    NSMutableDictionary *dic = [_contacts objectAtIndex:row];
//    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
//        [dic setObject:@"YES" forKey:@"checked"];
//        [cell setChecked:YES];
//    }else {
//        [dic setObject:@"NO" forKey:@"checked"];
//        [cell setChecked:NO];
//    }
//}

#pragma mark - SWTableViewCell Utility -
/**
 *  返回UITableViewCell左滑后出现的按钮组
 *
 *  @return 按钮组
 */
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"移 除"];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewCellDelegate -
/**
 *  左滑按钮组中的按钮点击事件处理方法
 *
 *  @param cell  <#cell description#>
 *  @param index <#index description#>
 */
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index indexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *group = [_product_groups[index] objectForKey:@"product_group"];
    NSDictionary *distribution = [_distributions[index] objectForKey:@"distribution"];
    
    YunLog(@"distribution_owner_id = %@", _distribution_owner_id);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"移除中...";
    
    NSDictionary *params = @{@"father_shop_id"              :        kNullToString(_shopID),
                             @"shop2_shop_id"               :        kNullToString([distribution objectForKey:@"shop2_shop_id"]),
                             @"distribution_resource_id"    :        kNullToString([distribution objectForKey:@"distribution_resource_id"]),
                             @"user_session_key"            :        kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"        :        kNullToString(appDelegate.terminalSessionKey)};
    
    
    NSString *delegateURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1WithShops
                                           requestURL:kDismiss_distributor_group
                                               params:params];
    
    YunLog(@"delete url = %@", delegateURL);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager DELETE:delegateURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"delegate responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [_hud addSuccessString:@"删除成功" delay:1.5];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self headerRereshing];
            });
        } else {
            [_hud addErrorString:@"删除失败" delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        YunLog(@"delegete error = %@", error);
        
        [_hud addErrorString:@"删除失败" delay:1.5];
        
    }];
}
/**
 *  prevent multiple cells from showing utilty buttons simultaneously
 *
 *  @param cell 所在的cell
 *
 *  @return 如果返回YES,则不能同时处理多个左滑
 */
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}


#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    
    YunLog(@"point.y = %f,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4 = %f",point.y,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
    
    if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
        && ( scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
        [self footerRereshing];
    }
}

@end
