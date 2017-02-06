//
//  ProductGroupsViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ProductGroupsViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "AddProductGroupViewController.h"
#import "ModifyProductGroupViewController.h"
#import "DistributorGroupProductViewController.h"

#define kSpace 10

@interface ProductGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) UIButton *addGroupsBtn;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) NSInteger pageNonce;



@end

@implementation ProductGroupsViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kOrangeColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.text = @"商品组管理";
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRereshing) name:kNotificationAddNewGroupSuccess object:nil];
    
    self.view.backgroundColor = kGrayColor;
    
    _isLoading = NO;
    _pageNonce = 1;
    _dataSource = [NSMutableArray array];
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self getNextPageViewIsPullDown:YES withPage:[NSString stringWithFormat:@"%ld", (long)_pageNonce]];
    
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

#pragma mark - Pull Refresh -

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh{
    
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

/**
 上拉刷新响应方法
 */
- (void)headerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce = 1;
    
    [self getNextPageViewIsPullDown:YES withPage:[NSString stringWithFormat:@"%ld",(long)_pageNonce]];
}

/**
 上拉刷新响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce++;
    
    [self getNextPageViewIsPullDown:NO withPage:[NSString stringWithFormat:@"%ld",(long)_pageNonce]];
}

#pragma mark - createUI - 

- (void)createUI
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, 40)];
    topView.backgroundColor = kGrayColor;
    
    [self.view addSubview:topView];
    
    _addGroupsBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 120, kSpace, 110, 20)];
    _addGroupsBtn.backgroundColor = kClearColor;
    [_addGroupsBtn setTitleColor:kOrangeColor forState:UIControlStateNormal];
    [_addGroupsBtn setTitle:@"+新增商品组" forState:UIControlStateNormal];
    [_addGroupsBtn addTarget:self action:@selector(addGroupsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:_addGroupsBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40 + kNavTabBarHeight, kScreenWidth, kScreenHeight - 40 - kNavTabBarHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = kGrayColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 110;
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无商品组";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;

    [self.view addSubview:_tableView];
}

#pragma mark - TableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = kGrayColor;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dict = _dataSource[indexPath.row];
    
    // 开始布局
    // 背景View
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,kSpace / 2, kScreenWidth, 100)];
    bgView.backgroundColor = kWhiteColor;
    
    [cell.contentView addSubview:bgView];
    
    // 商品组名称
    UILabel *nameGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, kSpace, kScreenWidth / 2, 20)];
    nameGroupLabel.text = [NSString stringWithFormat:@"%@",dict[@"name"]];
    nameGroupLabel.textColor = [UIColor darkGrayColor];
    nameGroupLabel.font = kNormalFont;
    
    [bgView addSubview:nameGroupLabel];
    
    // 状态码
    NSInteger statusCount = [kNullToString(dict[@"status"]) integerValue];
    
    // 状态
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(nameGroupLabel.frame) + kSpace, kScreenWidth / 2, 20)];
    if (statusCount == 1) {
        statusLabel.text = @"状态: 待发布";
    } else if (statusCount == 2) {
        statusLabel.text = @"状态: 发布";
    } else if (statusCount == 3) {
        statusLabel.text = @"状态：关闭";
    } else {
        statusLabel.text = @"状态：无";
    }
    statusLabel.textColor = [UIColor darkGrayColor];
    statusLabel.font = kNormalFont;
    
    [bgView addSubview:statusLabel];
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(statusLabel.frame) + kSpace, kScreenWidth / 2, 20)];
    NSArray *timeArray = [dict[@"created_at"] componentsSeparatedByString:@"T"];
    
    timeLabel.text = [NSString stringWithFormat:@"%@",[timeArray firstObject]];
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.font = kNormalFont;
    
    [bgView addSubview:timeLabel];
    
    // 查看商品组商品
    UIButton *seeGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 150, kSpace, 130, 35)];
    seeGroupBtn.backgroundColor = kOrangeColor;
    seeGroupBtn.tag = indexPath.row + 100;
    seeGroupBtn.layer.masksToBounds = YES;
    seeGroupBtn.layer.cornerRadius = 5;
    seeGroupBtn.titleLabel.font = kNormalFont;
    seeGroupBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [seeGroupBtn addTarget:self action:@selector(seeGroupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [seeGroupBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [seeGroupBtn setTitle:@"查看商品组商品" forState:UIControlStateNormal];
    
    
    [bgView addSubview:seeGroupBtn];
    
    // 修改商品组信息
    UIButton *modiGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 150, CGRectGetMaxY(seeGroupBtn.frame) + kSpace, 130, 35)];
    modiGroupBtn.backgroundColor = kLightBlackColor;
    modiGroupBtn.tag = indexPath.row + 1000;
    modiGroupBtn.layer.masksToBounds = YES;
    modiGroupBtn.layer.cornerRadius = 5;
    modiGroupBtn.titleLabel.font = kNormalFont;
    modiGroupBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [modiGroupBtn addTarget:self action:@selector(modiGroupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [modiGroupBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [modiGroupBtn setTitle:@"修改商品组信息" forState:UIControlStateNormal];
    
    [bgView addSubview:modiGroupBtn];
    
    return cell;
}

#pragma mark - GetData -

- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSString *)page
{
    AppDelegate *appDelegate = kAppDelegate;
    _isLoading = YES;;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    // 获取商品组数据
    NSDictionary *params = @{@"shop_id"               :   kNullToString(_shopID),
                             @"user_session_key"      :   kNullToString(appDelegate.user.userSessionKey),
                             @"page"                  :   page,
                             @"per"                   :   @"8"};
    
    NSString *productGroupsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kProduct_groups params:params];
    YunLog(@"我的商品组列表 = %@", productGroupsURL);
    
    [manager GET:productGroupsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"我的商品组列表 responseObject = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        NSArray *newgroups = [NSArray array];
        if ([code isEqualToString:kSuccessCode]) {
            newgroups = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"product_groups"]);
            if (newgroups.count < 8)
            {
                _tableView.footerHidden = YES;
            }
            else
            {
                _tableView.footerHidden = NO;
            }
            
            if (pullDown == YES)
            {
                [_dataSource setArray:newgroups];
            }
            else
            {
                [_dataSource addObjectsFromArray:newgroups];
                YunLog(@"_newgroup = %@",newgroups);
            }
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
            _hud.hidden = YES;
            
            if (_dataSource.count == 0)
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
        
        _tableView.backgroundView.hidden = NO;
        
        _isLoading = NO;
        _tableView.footerHidden = NO;
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        
        YunLog(@"我的商铺列表 - error = %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Btn Ckick - 

- (void)addGroupsBtnClick:(UIButton *)sender
{
    YunLog(@"新增商品组");
    AddProductGroupViewController *addVC = [[AddProductGroupViewController alloc] init];
    addVC.shopID = _shopID;
    
    addVC.shop_id = kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]);
    
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)seeGroupBtnClick:(UIButton *)sender
{
    NSDictionary *group = _dataSource[sender.tag - 100];
    
//    DistributorGroupProductViewController *productsList = [[DistributorGroupProductViewController alloc] init];
//    
//    productsList.distributeGroupName = tempDict[@"name"];
//    
//    [self.navigationController pushViewController:productsList animated:YES];
    
    DistributorGroupProductViewController *productsList = [[DistributorGroupProductViewController alloc] init];
    
    productsList.isDistributor = NO;
    productsList.distributeGroupName = kNullToString([group objectForKey:@"name"]);
    productsList.pg_id = kNullToString([group objectForKey:@"id"]);
    productsList.sid = kNullToString([group objectForKey:@"shop_id"]);
    
    [self.navigationController pushViewController:productsList animated:YES];
}

- (void)modiGroupBtnClick:(UIButton *)sender
{
    NSDictionary *dict = _dataSource[sender.tag - 1000];
    
    YunLog(@"dict = %@", dict);
    
    ModifyProductGroupViewController *modiVC = [[ModifyProductGroupViewController alloc] init];
    modiVC.dict = dict;
    
    [self.navigationController pushViewController:modiVC animated:YES];
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
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
