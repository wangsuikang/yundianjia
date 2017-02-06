//
//  MyDistributorsViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/11.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyDistributorsViewController.h"

//  Controllers
#import "AdminDistributeGroupViewController.h"
#import "AddNewDistributorViewController.h"
#import "DistributorDetailViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface MyDistributorsViewController () <UITableViewDataSource, UITableViewDelegate>

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 分销商数组
@property (nonatomic, strong) NSMutableArray *distributors;

/// 分销商列表
@property (nonatomic, strong) UITableView *tableView;

/// 是否在加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) NSInteger pageNonce;

@end

@implementation MyDistributorsViewController

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
        naviTitle.text = @"我的分销商";
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRereshing) name:kNotificationAddNewDistributorSuccess object:nil];
    
    _distributors = [NSMutableArray array];
    
    self.view.backgroundColor = kGrayColor;
    
    [self getNextPageViewIsPullDown:YES withPage:1];
    
    [self createUI];
    
    [self createMJRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Functions -
- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 44)];
    topView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:topView];
    
    // 搜索按钮
    
//    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 34, 34)];
//    searchIcon.image = [UIImage imageNamed:@"admin_search"];
//    
//    [topView addSubview:searchIcon];
//    
//    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchIcon.frame) + 5, 15, 34, 34)];
//    searchLabel.text = @"查";
//    searchLabel.textColor = [UIColor orangeColor];
//    searchLabel.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
//    
//    [topView addSubview:searchLabel];
//    
//    
//    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchButton.frame = CGRectMake(10, 10, 93, 44);
//    
//    searchButton.layer.borderColor = [UIColor orangeColor].CGColor;
//    searchButton.layer.borderWidth = 1;
//    searchButton.layer.cornerRadius = 5;
//    searchButton.layer.masksToBounds = YES;
//    
//    [topView addSubview:searchButton];
    
    // 新增分销商按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(kScreenWidth - 20 - 110, 0, 110, 44);
    [addButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
    [addButton setTitle:@"+新增分销商" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    [addButton addTarget:self action:@selector(addNewDistributor) forControlEvents:UIControlEventTouchUpInside];
    addButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [topView addSubview:addButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), kScreenWidth, kScreenHeight - 64 - 44) style:UITableViewStylePlain];
    _tableView.backgroundColor = kGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无分销商";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;
    
    [self.view addSubview:_tableView];
}

- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _isLoading = YES;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"page"                    :   [NSString stringWithFormat:@"%ld",(long)page],
                             @"per"                     :   @"8",
                             @"code"                    :   _shopCode};
    
    NSString *distributorsListURLURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kAdminDistributors params:params];
    
    YunLog(@"distributorsListURL = %@", distributorsListURLURL);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:distributorsListURLURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YunLog(@"我的分销商responseObject = %@", responseObject);
        NSArray *newDistributor = [NSArray array];
        if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
        {
            newDistributor = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"distributors"]);;
            if (newDistributor.count < 8)
            {
                _tableView.footerHidden = YES;
            }
            else
            {
                _tableView.footerHidden = NO;
            }
            
            if (pullDown == YES)
            {
                [_distributors setArray:newDistributor];
            }
            else
            {
                [_distributors addObjectsFromArray:newDistributor];
                YunLog(@"newDistributor = %@",newDistributor);
            }
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
            _hud.hidden = YES;

            if (_distributors.count == 0)
            {
                _tableView.backgroundView.hidden = NO;
                _tableView.headerHidden = YES;
            }
            else
            {
                _tableView.backgroundView.hidden = YES;
                _tableView.headerHidden = NO;
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

- (void)goToDistributeGroups:(UIButton *)sender
{
    AdminDistributeGroupViewController *distributeGroup = [[AdminDistributeGroupViewController alloc] init];
    
    NSDictionary *distributor = _distributors[sender.tag];
    
    distributeGroup.distributorName = kNullToString([distributor objectForKey:@"name"]);
    distributeGroup.shopID = kNullToString([distributor objectForKey:@"id"]);
    distributeGroup.distribution_owner_id = kNullToArray([distributor objectForKey:@"user_id"]);
    
    [self.navigationController pushViewController:distributeGroup animated:YES];
}

- (void)addNewDistributor
{
    AddNewDistributorViewController *addNewDistributor = [[AddNewDistributorViewController alloc] init];
    
    [self.navigationController pushViewController:addNewDistributor animated:YES];
}

- (void)goToDistributorDetail:(UIButton *)sender
{
    DistributorDetailViewController *distributorDetail = [[DistributorDetailViewController alloc] init];
    
    NSDictionary *distributor = _distributors[sender.tag];
    
    distributorDetail.distributorName = kNullToString([distributor objectForKey:@"name"]);
    distributorDetail.distributorDesc = kNullToString([distributor objectForKey:@"short_name"]);
    distributorDetail.email = kNullToString([distributor objectForKey:@"email"]);
    distributorDetail.phoneName = kNullToString([distributor objectForKey:@"contact_name"]);
    distributorDetail.phoneNumber = kNullToString([distributor objectForKey:@"mobile_phone"]);
    
    [self.navigationController pushViewController:distributorDetail animated:YES];
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
    return _distributors.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    NSDictionary *distributor = _distributors[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kClearColor;

    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    // cell的背景视图
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 90)];
    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    UIButton *icon = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 70, 70)];
    [icon setImage:[UIImage imageNamed:@"admin_shopIcon"] forState:UIControlStateNormal];
    icon.tag = indexPath.row;
    [icon addTarget:self action:@selector(goToDistributorDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:icon];
    
    UILabel *shopNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 10, 10, kScreenWidth - CGRectGetMaxX(icon.frame) - 10 - 120 - 10, 23)];
    shopNameLabel.text  = kNullToString([distributor objectForKey:@"name"]);
    shopNameLabel.textColor = [UIColor darkGrayColor];
    shopNameLabel.textAlignment = NSTextAlignmentLeft;
    shopNameLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:shopNameLabel];
    
    NSInteger status = [[distributor objectForKey:@"status"] integerValue];

    NSString *statusStr;
    switch (status) {
        case 1:
            statusStr = @"新增";
            break;
            
        case 2:
            statusStr = @"待审核";
            break;
            
        case 3:
            statusStr = @"审核通过";
            break;
            
        case 4:
            statusStr = @"审核失败";
            break;
            
        case 5:
            statusStr = @"上线（公开)";
            break;
            
        case 6:
            statusStr = @"关闭";
            break;
            
        case 7:
            statusStr = @"非公开上线";
            break;
            
        default:
            break;
    }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 10, CGRectGetMaxY(shopNameLabel.frame), kScreenWidth - CGRectGetMaxX(icon.frame) - 10 - 120 - 10, 23)];
    nameLabel.text  = [NSString stringWithFormat:@"%@  (%@)", kNullToString([distributor objectForKey:@"contact_name"]), statusStr];
    nameLabel.textColor = [UIColor darkGrayColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:nameLabel];
   
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 10,  CGRectGetMaxY(nameLabel.frame), kScreenWidth - CGRectGetMaxX(icon.frame) - 10 - 120 - 10, 23)];
    timeLabel.text  = [NSString stringWithFormat:@"%@", kNullToString([[distributor objectForKey:@"created_at"] substringWithRange:NSMakeRange(0, 10)])];
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:timeLabel];
    
    UIButton *goToProduct = [UIButton buttonWithType:UIButtonTypeCustom];
    goToProduct.frame = CGRectMake(kScreenWidth - 20 - 100, 27.5, 100, 35);
    [goToProduct setTitle:@"查看分销组" forState:UIControlStateNormal];
    [goToProduct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    goToProduct.titleLabel.textAlignment = NSTextAlignmentCenter;
    goToProduct.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    goToProduct.backgroundColor = kOrangeColor;
    goToProduct.alpha = 0.85;
    goToProduct.layer.masksToBounds = YES;
    goToProduct.layer.cornerRadius = 5;
    goToProduct.tag = indexPath.row;
    [goToProduct addTarget:self action:@selector(goToDistributeGroups:) forControlEvents:UIControlEventTouchUpInside];

    
    [backView addSubview:goToProduct];
    
//    UIButton *goToShop = [UIButton buttonWithType:UIButtonTypeCustom];
//    goToShop.frame = CGRectMake(kScreenWidth - 20 - 100, CGRectGetMaxY(goToProduct.frame) + 10, 100, 30);
//    [goToShop setTitle:@"预览店铺" forState:UIControlStateNormal];
//    [goToShop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    goToShop.titleLabel.textAlignment = NSTextAlignmentCenter;
//    goToShop.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
//    goToShop.backgroundColor = kLightBlackColor;
//    goToShop.alpha = 0.85;
//    goToShop.layer.masksToBounds = YES;
//    goToShop.layer.cornerRadius = 5;
//    
//    [backView addSubview:goToShop];

    return cell;
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
