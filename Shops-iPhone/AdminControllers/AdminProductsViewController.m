//
//  AdminProductsViewController.m
//  Shops-iPhone
//
//  Created by 席小雨 on 15/8/11.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminProductsViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Categories
#import "UIImage+Color.h"

// Controllers
#import "PopGestureRecognizerController.h"
#import "AddAdminProductViewController.h"
#import "ProductDetailViewController.h"

#define kSpace 10
#define kSpaceDouble 20
#define kBottomHeight (kScreenWidth > 375 ? 48 * 1.293 : (kScreenWidth > 320 ? 48 * 1.17 : 48))
#define kSpace5 5
#define kSpace10 10
#define kSpace15 15
#define kCellHeight 110

@interface AdminProductsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate,UISearchBarDelegate>

/// 导航栏下面的view
@property (nonatomic, strong) UIView *topView;

/// tableview
@property (nonatomic, strong) UITableView *tableView;

/// 选中的顶部按钮
@property (nonatomic, strong) UIButton *topSelectedBtn;

/// label
@property (nonatomic, strong) UILabel *naviTitle;

/// 搜索按钮
@property (nonatomic, strong) UIButton *searchBtn;

/// 搜索框
@property (nonatomic, strong) UISearchBar *searchBar;

/// 底部控件view
@property (nonatomic, strong) UIView *bottomView;

/// 添加商品按钮
@property (nonatomic, strong) UIButton *addProductBtn;

/// 是否在加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) NSInteger pageNonce;

/// 搜索框
//@property (nonatomic, strong) UISearchBar *<#name#>;

/// 三方库MBProgressHUD对象
@property (nonatomic, strong) MBProgressHUD *hud;

/// 我的商品数组（全部）
@property (nonatomic, strong) NSMutableArray *products;

/// 我的商品组数组（已上架）
@property (nonatomic, strong) NSMutableArray *saleArray;

/// 我的商品数据 （下架）
@property (nonatomic, strong) NSMutableArray *pullStakeArray;

@property (nonatomic, strong) NSArray *statusArray;

@property (nonatomic, strong) NSArray *statusTextArray;

@property (nonatomic, assign) NSInteger status;


@end

@implementation AdminProductsViewController

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
        _naviTitle.text = @"我的商品";
        
        self.navigationItem.titleView = _naviTitle;
        
        self.headerHeight = 48;
        
        _selectedProdectTypeIndex = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    [pop setPopGestureEnabled:NO];
    
    // 如果是从保存商品页面跳转过来的话，这里默认保存的是 1
    NSString *jumpSaveBool = [[NSUserDefaults standardUserDefaults] objectForKey:@"jumpSave"];
    if ([jumpSaveBool isEqualToString:@"yes"]) {
        _selectedProdectTypeIndex = 2;
        
        _status = 1;  /// 获取到待发布的参数
        
        UIButton *sender = (UIButton *)[_topView viewWithTag:2];
        
        [self topBtnClick:sender];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    PopGestureRecognizerController *pop = (PopGestureRecognizerController *)self.navigationController;
    //    [pop setPopGestureEnabled:YES];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /// 当离开这个页面的时候， 设置保存并发布跳转条件为NO
    [kUserDefaults setObject:@"no" forKey:@"jumpSave"];
    [kUserDefaults synchronize];
    
    [kNotificationCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _products = [NSMutableArray array];
    _pullStakeArray = [NSMutableArray array];
    _saleArray = [NSMutableArray array];
    
    // 默认是选中 0
    _status = 0;
    
    _statusArray     = @[@"",  @"上 架", @"下 架", @"上 架", @"上 架", @"上 架", @"上 架", @"上 架"];
    _statusTextArray = @[@"0", @"待发布", @"发布", @"关闭", @"预售", @"待审核", @"审核成功", @"审核失败"];
    
    self.view.backgroundColor = kGrayColor;
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    _pageNonce = 1;
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    // 添加右边搜索图标 (一阶段屏蔽该功能)
    _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_searchBtn setImage:[UIImage imageNamed:@"sale_search"] forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBtn];
    searchItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = searchItem;
    
    [self getNextPageViewIsPullDown:NO withPage:_pageNonce status:[NSString stringWithFormat:@"%ld", (long)_status] keyWord:@""];
    
    // 创建顶部topView
    [self createTopView];
    
    // 创建tableview
    [self createTableView];
    
    // 创建底部的添加商品按钮
    // 只有供应商才可以添加商品
    AppDelegate *appDelegate = kAppDelegate;
    if (appDelegate.user.userType == 2) {
        [self createBottomView];
    }
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

#pragma mark - Gesture -

- (void)swipeGesturLeft
{
    _selectedProdectTypeIndex++;
    
    if (_selectedProdectTypeIndex > 3)
    {
        _selectedProdectTypeIndex--;
        
        return;
    }
    
    YunLog(@"swipeLeft _selectedOrderTypeIndex = %ld",(long)_selectedProdectTypeIndex);
    for (id so in _topView.subviews) {
        if ([so isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)so;
            if (button.tag == _selectedProdectTypeIndex)
            {
                [self topBtnClick:button];
            }
        }
    }
}

- (void)swipeGesturRight
{
    _selectedProdectTypeIndex--;
    
    if (_selectedProdectTypeIndex < 0)
    {
        _selectedProdectTypeIndex++;
        return;
    }
    
    YunLog(@"swipeLeft _selectedOrderTypeIndex = %ld",(long)_selectedProdectTypeIndex);
    for (id so in _topView.subviews) {
        if ([so isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)so;
            if (button.tag == _selectedProdectTypeIndex)
            {
                [self topBtnClick:button];
            }
        }
    }
}

#pragma mark - Make UI -

- (void)createTopView
{
    // 创建视图 添加顶部
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, 48)];
    _topView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_topView];
    
    NSArray *titleArray = @[@"全部", @"出售中", @"待发布", @"已下架"];
    
    CGFloat titleY = kSpace / 2;
    CGFloat titleWidth = 60;
    CGFloat titleHeight = _topView.bounds.size.height - 2 * titleY;
    CGFloat titleSpace = (kScreenWidth - 4 * titleWidth) / 5;
    // 创建三个按钮
    for (int i = 0; i < titleArray.count; i++) {
        CGFloat titleX = titleSpace + (titleWidth + titleSpace) * i;
        
        // 添加title按钮
        UIButton *title = [[UIButton alloc] initWithFrame:CGRectMake(titleX, titleY, titleWidth, titleHeight)];
        title.tag = i;
        [title setTitle:titleArray[i] forState:UIControlStateNormal];
        title.titleLabel.textAlignment = NSTextAlignmentCenter;
        title.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
        if (i == _selectedProdectTypeIndex) {
            title.selected = YES;
            _topSelectedBtn = title;
        } else {
            title.selected = NO;
        }
        [title setTitleColor:kOrangeColor forState:UIControlStateSelected];
        [title setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [title addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topView addSubview:title];
        
        
        // 底部的一条横线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(titleX, CGRectGetMaxY(title.frame) - 2, titleWidth, 2)];
        line.layer.masksToBounds = YES;
        line.layer.cornerRadius = 4;
        line.tag = i + 10;
        if (i == _selectedProdectTypeIndex) {
            line.backgroundColor = kOrangeColor;
        } else {
            line.backgroundColor = kClearColor;
        }
        
        [_topView addSubview:line];
    }
}

- (void)createBottomView
{
    // 创建底部的view
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kBottomHeight, kScreenWidth, kBottomHeight)];
    _bottomView.backgroundColor = kWhiteColor;
    
    // 添加点击按钮
    _addProductBtn = [[UIButton alloc] initWithFrame:CGRectMake(kSpaceDouble, kSpace, kScreenWidth - 2 * kSpaceDouble, _bottomView.bounds.size.height - kSpaceDouble)];
    _addProductBtn.backgroundColor = kOrangeColor;
    _addProductBtn.titleLabel.font = kBigBoldFont;
    [_addProductBtn setTitle:@"＋添加商品" forState:UIControlStateNormal];
    [_addProductBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    _addProductBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _addProductBtn.layer.masksToBounds = YES;
    _addProductBtn.layer.cornerRadius = 5;
    [_addProductBtn addTarget:self action:@selector(addProductBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomView addSubview:_addProductBtn];
    
    [self.view addSubview:_bottomView];
}

- (void)createTableView
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _tableView = [[UITableView alloc] init];
    
    if (appDelegate.user.userType == 2) {
        _tableView.frame = CGRectMake(0, CGRectGetMaxY(_topView.frame) + 5, kScreenWidth, kScreenHeight - kNavTabBarHeight - _topView.bounds.size.height - kBottomHeight);
    } else {
        _tableView.frame = CGRectMake(0, CGRectGetMaxY(_topView.frame) + 5, kScreenWidth, kScreenHeight - kNavTabBarHeight - _topView.bounds.size.height);
    }
    
    _tableView.backgroundColor = kGrayColor;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 110;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无商品";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;
    
    [self.view addSubview:_tableView];
    
    //加左划手势
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesturLeft)];
    // 设置滑动手势的方向
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [_tableView addGestureRecognizer:swipeLeft];
    
    //加右划手势
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesturRight)];
    // 设置滑动手势的方向
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [_tableView addGestureRecognizer:swipeRight];
    
    [self createMJRefresh];
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
    
    [self getNextPageViewIsPullDown:YES withPage:_pageNonce status:[NSString stringWithFormat:@"%ld", (long)_status] keyWord:@""];
}

/**
 上拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce++;
    
    [self getNextPageViewIsPullDown:NO withPage:_pageNonce status:[NSString stringWithFormat:@"%ld", (long)_status] keyWord:@""];
}

#pragma mark - getData -
/**
 获取数据源
 
 @param pullDown 是否是下拉
 @param page     当前页数
 */
- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page status:(NSString *)status keyWord:(NSString *)string
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _isLoading = YES;
    if(!_hud)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }

    // 获取浏览商品数据
    // 请求参数  status
    // 请求状态码： 0 -- 全部    2 --- 正在销售  1---待发布  3 -- 下架
    
    NSDictionary *params = [NSDictionary dictionary];
    
    if ([status isEqualToString:@"0"]) {
        params = @{@"code"                  :   kNullToString(_shopCode),
                   @"keyword"               :   kNullToString(string),
                   @"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey),
                   @"user_session_key"      :   kNullToString(appDelegate.user.userSessionKey),
                   @"page"                  :   [NSString stringWithFormat:@"%ld", (long)page],
                   @"per"                   :   @"8"};
    } else {
        params = @{@"code"                  :   kNullToString(_shopCode),
                   @"keyword"               :   kNullToString(string),
                   @"status"                :   kNullToString(status),
                   @"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey),
                   @"user_session_key"      :   kNullToString(appDelegate.user.userSessionKey),
                   @"page"                  :   [NSString stringWithFormat:@"%ld", (long)page],
                   @"per"                   :   @"8"};
    }
    
    YunLog(@"params = %@", params);
    
    NSString *adminProductsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:admin_Products,_shopCode] params:params];
    
    YunLog(@"我的商品URL = %@", adminProductsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:adminProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YunLog(@"我的商品responseObject = %@", responseObject);
        
        NSArray *newProduct = [NSArray array];
        if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
        {
            newProduct = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"products"]);
            
            if (newProduct.count < 8)
            {
                _tableView.footerHidden = YES;
            } else {
                _tableView.footerHidden = NO;
            }
            
            if (string.length > 0 && newProduct.count < 1) {
                [_hud addErrorString:@"没有您搜索的商品" delay:2.0];
            }
            
            if (pullDown == YES || string.length > 0) {
                [_products setArray:newProduct];
            } else {
                [_products addObjectsFromArray:newProduct];
                YunLog(@"_products = %@",newProduct);
            }
            
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
            [_hud hide:YES];
            
            if (_products.count == 0)
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
        
        [_tableView footerEndRefreshing];
        [_tableView headerEndRefreshing];
        _tableView.footerHidden = NO;
        _tableView.backgroundView.hidden = NO;
        _isLoading = NO;
    }];
}
#pragma mark TableViewDelegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YunLog(@"%ld",(unsigned long)_products.count);
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    NSDictionary *product = _products[indexPath.row];
    
    AppDelegate *appDelegate = kAppDelegate;
    
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
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kSpace5, kScreenWidth, kCellHeight - kSpace10)]; // 高度100
    bgView.backgroundColor = kWhiteColor;
    
    [cell.contentView addSubview:bgView];
    
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(2 * kSpace10, kSpace10, bgView.bounds.size.height - 2 * kSpace10, bgView.bounds.size.height - 2 * kSpace10)];  // 宽高  80
    //    leftImage.backgroundColor = [UIColor redColor];
    leftImage.backgroundColor = kClearColor;
    leftImage.contentMode = UIViewContentModeCenter;
    
    __weak UIImageView *weakImageView = leftImage;
    [leftImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([product safeObjectForKey:@"large_icon_200_200"])]]
                     placeholderImage:[UIImage imageNamed:@"default_history"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  weakImageView.image = image;
                                  weakImageView.contentMode = UIViewContentModeScaleAspectFill;
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  [weakImageView setImageWithURL:[NSURL URLWithString:kNullToString([product safeObjectForKey:@"large_icon_218_218"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                  weakImageView.contentMode = UIViewContentModeScaleAspectFill;
                              }];
    
    [bgView addSubview:leftImage];
    
    CGFloat labelWidth = kScreenWidth - leftImage.bounds.size.width - 2 * kSpace10;
    CGFloat labelX = CGRectGetMaxX(leftImage.frame) + 2 * kSpace10;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, kSpace5, labelWidth, 20)];
    if (kIsiPhone) {
        titleLabel.font = [UIFont boldSystemFontOfSize:kFontNormalSize];
    } else {
        titleLabel.font = [UIFont boldSystemFontOfSize:kFontBigSize];
    }
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = kNullToString([product objectForKey:@"name"]);
    
    [bgView addSubview:titleLabel];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(titleLabel.frame) + kSpace5 / 2, labelWidth, 20)];
    if (kIsiPhone) {
        priceLabel.font = [UIFont boldSystemFontOfSize:kFontMidSize];
    } else {
        priceLabel.font = [UIFont boldSystemFontOfSize:kFontNormalSize];
    }
    priceLabel.textColor = [UIColor grayColor];
    priceLabel.text = [NSString stringWithFormat:@"价格: ￥%@", kNullToString([product objectForKey:@"price"])];
    
    [bgView addSubview:priceLabel];
    
    // 添加库存
    UILabel *stockLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(priceLabel.frame) + kSpace5 / 2, labelWidth, 20)];
    if (kIsiPhone) {
        stockLabel.font = [UIFont boldSystemFontOfSize:kFontMidSize];
    } else {
        stockLabel.font = [UIFont boldSystemFontOfSize:kFontBigSize];
    }
    stockLabel.textColor = [UIColor grayColor];
    stockLabel.text = [NSString stringWithFormat:@"库存: %@", kNullToString([product objectForKey:@"inventory_quantity"])];
    
    [bgView addSubview:stockLabel];
    
    //     添加销售状态
    NSInteger stats = [[product objectForKey:@"status"] integerValue];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(stockLabel.frame) + kSpace5 / 2, labelWidth, 20)];
    if (kIsiPhone) {
        statusLabel.font = [UIFont boldSystemFontOfSize:kFontMidSize];
    } else {
        statusLabel.font = [UIFont boldSystemFontOfSize:kFontNormalSize];
    }
    statusLabel.textColor = COLOR(255, 99, 71, 1);
    statusLabel.text = [NSString stringWithFormat:@"状态: %@", _statusTextArray[stats]];
    
    [bgView addSubview:statusLabel];
    
    
    // 添加按钮状态
    UIButton *statusBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 90, (kCellHeight - 40) / 2, 80, 40)];
    statusBtn.backgroundColor = kOrangeColor;
    [statusBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
    statusBtn.titleLabel.font = kBigBoldFont;
    statusBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    statusBtn.layer.masksToBounds = YES;
    statusBtn.layer.cornerRadius = 5;
    statusBtn.tag = indexPath.row;
    statusBtn.alpha = 0.0;
    [statusBtn addTarget:self action:@selector(changStatus:) forControlEvents:UIControlEventTouchUpInside];
    [statusBtn setTitle:_statusArray[stats] forState:UIControlStateNormal];
    
    if (appDelegate.user.userType == 2) {
        statusBtn.alpha = 1.0;
    }
    
    [bgView addSubview:statusBtn];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *product = _products[indexPath.row];
    
    NSString *status = [product safeObjectForKey:@"status"];
    /// 如果当商品处于发布状态才可以查看商品详情
    if ([status intValue] == 2) {
        ProductDetailViewController *productDetail = [[ProductDetailViewController alloc] init];
        productDetail.shopCode = _shopCode;
        productDetail.productCode = [product objectForKey:@"code"];
        productDetail.isAdmin = YES;
        
        [self.navigationController pushViewController:productDetail animated:YES];
    } else {
        _hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请上架后查看..." delay:1.5];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

#pragma mark - CellDelegate -

- (void)cellOfStatusBtnClick:(UIButton *)sender index:(NSInteger)index
{
    YunLog(@"cell中得按钮被点击了");
}

#pragma mark - ScrollViewDelegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BtnClick -

- (void)topBtnClick:(UIButton *)sender
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    _hud.labelText = @"努力加载中...";
    
    if ([[sender currentTitle] isEqualToString:@"全部"]) {
        _status = 0;
    }
    
    if ([[sender currentTitle] isEqualToString:@"出售中"]) {
        _status = 2;
    }
    
    if ([[sender currentTitle] isEqualToString:@"待发布"]) {
        _status = 1;
    }
    
    if ([[sender currentTitle] isEqualToString:@"已下架"]) {
        _status = 3;
    }
    
    // 取消搜索状态
    [self searchBarCancelButtonClicked:_searchBar];
    
    [UIView animateWithDuration:0.5 animations:^{
        YunLog(@"topBtn.tag = %ld", (long)sender.tag);
        NSInteger selectTag = _topSelectedBtn.tag;
        
        _topSelectedBtn.selected = NO; // 取消选中
        _topSelectedBtn = nil;
        
        UIView *line = (UIView *)[_topView viewWithTag:(selectTag + 10)]; // 选中的底部 黄色线条 隐藏
        line.backgroundColor = kClearColor;
        //    // 设置选中的按钮
        sender.selected = YES;
        _topSelectedBtn = sender;
        _selectedProdectTypeIndex = _topSelectedBtn.tag;
        
        UIView *lineSelected = (UIView *)[_topView viewWithTag:(sender.tag + 10)];
        lineSelected.backgroundColor = kOrangeColor;
        
        YunLog(@"selectBtn.tag = %ld", (long)_topSelectedBtn.tag);
    }];
    
    [self getNextPageViewIsPullDown:YES withPage:1 status:[NSString stringWithFormat:@"%ld", (long)_status] keyWord:@""];
}

- (void)addProductBtnClick:(UIButton *)sender
{
    AddAdminProductViewController *vc = [[AddAdminProductViewController alloc] init];
    vc.shopCode = kNullToString(_shopCode);
    vc.shopID = kNullToString(_shopID);
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changStatus:(UIButton *)sender
{
    NSDictionary *product = _products[sender.tag];
    
    NSString *code;
    if ([sender.titleLabel.text isEqualToString:@"上 架"])
    {
        code = @"2";
    }
    if ([sender.titleLabel.text isEqualToString:@"下 架"])
    {
        code = @"3";
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在修改...";
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"status"                  :   kNullToString(code)};
    
    NSString *changStatusURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/products/%@/update_status.json",[product objectForKey:@"code"]] params:params];
    
    YunLog(@"changStatusURL = %@", changStatusURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager PUT:changStatusURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"changStatus responseObject = %@", responseObject);
             if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
             {
                 [_hud addSuccessString:@"修改成功" delay:2.0];
                 
                 [self headerRereshing];
             }
             else
             {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             YunLog(@"changStatusURL - error = %@", error);
         }];
}

#pragma mark - BackPerpent -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [_tableView removeHeader];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBtnClick:(UIButton *)sender
{
    [_naviTitle removeFromSuperview];
    _naviTitle = nil;
    [UIView animateWithDuration:0.5 animations:^{
        YunLog(@"搜索被点击");
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 5, 200, 34)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"请输入商品名称";
        _searchBar.backgroundColor=[UIColor clearColor];
        [_searchBar becomeFirstResponder];
        
        [_searchBar setBackgroundImage:[UIImage imageNamed:@"search_bgimage"]];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bgimage"] forState:UIControlStateNormal];// 设置搜索框中文本框的背景
        
        _searchBar.showsCancelButton = YES;
        _searchBar.tintColor = kOrangeColor;
        _searchBar.barTintColor = kOrangeColor;
        
        self.navigationItem.titleView = _searchBar;
        
        // 搜索按钮隐藏，并且不可以被点击
        //    _searchBtn.enabled = YES;
        _searchBtn.alpha = 0;
    }];
}

#pragma mark - UISearchBar Delegate -

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // 点击取消按钮
    [_searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kOrangeColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.text = @"我的商品";
        
        self.navigationItem.titleView = _naviTitle;
        
        _searchBtn.alpha = 1.0;
        
        [_searchBar removeFromSuperview];
        _searchBar = nil;
    }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 搜索被点击
    [_searchBar resignFirstResponder];
    
    [self getNextPageViewIsPullDown:NO withPage:1 status:[NSString stringWithFormat:@"%ld", (long)_status] keyWord:searchBar.text];
    
    [UIView animateWithDuration:0.5 animations:^{
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kOrangeColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.text = @"我的商品";
        
        self.navigationItem.titleView = _naviTitle;
        
        _searchBtn.alpha = 1.0;
        
        [_searchBar removeFromSuperview];
        _searchBar = nil;
    }];
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
