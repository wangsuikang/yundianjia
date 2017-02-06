//
//  ProductRevelationController.m
//  Shops-iPhone
//
//  Created by xxy on 15/6/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ProductRevelationController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Models
#import "ProductListModel.h"

// Views
#import "ProductListCell.h"

// Controllers
#import "ProductDetailViewController.h"

#define kCellHeight 100
#define kNavHeight 64
#define kTabHeight 48

@interface ProductRevelationController () <UITableViewDataSource, UITableViewDelegate>

/// 第三方库的引用
@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;

/// 后台数据接口返回总页数
@property (nonatomic, assign) int pageCount;

@end

@implementation ProductRevelationController

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = self.titleName;
    
    self.navigationItem.titleView = naviTitle;
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 最开始设置
    _pageNonce = 1;
    _isLoading = NO;
    _dataScource = [NSMutableArray array];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self getDataProductSource:NO page:1];
    
    [self createUI];
    
    // 添加上拉下拉控件
    [self createMJRefresh];
}

#pragma mark - 创建上拉下拉刷新
/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh{
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

/**
 上拉刷新响应方法
 */
- (void)headerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce = 1;
    [self getDataProductSource:YES page:_pageNonce];
}

/**
 下拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    if (_pageNonce > _pageCount)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addSuccessString:@"没有更多了哟~" delay:1.0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView footerEndRefreshing];
        });
        return;
    }
    _pageNonce++;
    [self getDataProductSource:NO page:_pageNonce];
}

#pragma mark - getDataScource -
/**
 根据不同的条件获取数据
 
 @param isDownPull 是否下拉
 @param pageNonce  当前页
 */
- (void)getDataProductSource:(BOOL)isDownPull page:(int)pageNonce

{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    _isLoading = YES;
    
    _page = [NSString stringWithFormat:@"%d",pageNonce];
    
    NSDictionary *params = @{@"product_category_id" :   @(self.productId),
                             @"page"                :   kNullToString(_page),
                             @"per"                 :   kNullToString(_per)};
    
    NSString *productURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kProductRevelationListURL params:params];
    
    YunLog(@"productURL  -- %@",productURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:productURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
        _pageCount = [[[responseObject objectForKey:@"date"] objectForKey:@"page_count"] intValue];
        
        if ([code isEqualToString:kSuccessCode])
        {
            NSArray *dataArr = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
            
            if (isDownPull == YES) {
                [self.dataScource removeAllObjects];
            }
            
            for (NSDictionary *dataDict in dataArr )
            {
                ProductListDetailModel *productListDetailModel = [[ProductListDetailModel alloc] init];
                
                [productListDetailModel setValuesForKeysWithDictionary:dataDict];
                
                [self.dataScource addObject:productListDetailModel];
            }
            
            YunLog(@"self.dataSource - %lu", (unsigned long)self.dataScource.count);
            
            if (_tableView == nil)
            {
                [self createUI];
            }
            else
            {
                [_tableView reloadData];
            }
            
            [_hud hide:YES];
            _isLoading = NO;
            
            [self.tableView headerEndRefreshing];
            [self.tableView footerEndRefreshing];
        }
        else
        {
            _isLoading = NO;
            [_hud addErrorString:@"该分类查询结果为空" delay:2.0];
            
            [self.tableView headerEndRefreshing];
            [self.tableView footerEndRefreshing];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self backToPrev];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        _isLoading = NO;
        [_hud addErrorString:@"获取数据失败，请检查网络" delay:2.0];
        
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backToPrev];
        });
    }];
}

#pragma mark - Create UI -
/**
 创建tableView
 */
- (void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    
    _tableView.rowHeight       = kCellHeight;
    _tableView.dataSource      = self;
    _tableView.delegate        = self;
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
}

#pragma mark - UITableView - Scource - Degelate -
/**
 UITableView数据源代理方法
 
 @param tableView 当前tableview
 
 @return 总组数
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 UITableView数据源代理方法
 
 @param tableView 当前tableView
 @param section   组数对应的cell成员个数
 
 @return 每组中cell的个数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataScource.count;
}

/**
 UITableView数据源代理方法
 
 @param tableView 当前tableView
 @param indexPath 组数对应的cell成员个数
 
 @return cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListCell *cell = [ProductListCell cellWithTableView:tableView];
    
    ProductListDetailModel *productDetailModel = self.dataScource[indexPath.item];
    
    [cell config:productDetailModel];
    
    return cell;
}

/**
 UITableView 代理方法
 
 @param tableView 当前tableView
 @param indexPath 选中的cell对应的位置信息
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListDetailModel *productListDetailModel = self.dataScource[indexPath.item];
    
    ProductDetailViewController *productDetailVC = [[ProductDetailViewController alloc] init];
    
    productDetailVC.shopCode = productListDetailModel.shop_code;
    productDetailVC.productCode     = productListDetailModel.code;
    productDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:productDetailVC animated:YES];
    
}

#pragma mark - BackToPrev Click -
/**
 返回上一个控制器
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    if (_hud) {
        [_hud hide:YES];
    }
    _tableView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0 ) {
        [self footerRereshing];
    }
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
