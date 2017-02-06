//
//  RecommendViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/6/12.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "RecommendViewController.h"

//Common
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"

// Models
#import "recommendShopsModel.h"

// Views
#import "RecommendShopsCell.h"

@interface RecommendViewController () <UITableViewDelegate,UITableViewDataSource>

/// 商铺列表视图
@property (nonatomic, strong) UITableView *tableView;

/// 商铺列表数据源
@property (nonatomic, strong) NSMutableArray *shopListArray;

/// 当前页码
@property (nonatomic, assign) NSInteger pageNonce;

/// 最大页数
@property (nonatomic, assign) NSInteger pageMax;

/// 一页中显示商铺的数量
@property (nonatomic, assign) NSInteger pageLimit;

/// 加载状态
@property (nonatomic, assign) BOOL isLoading;

/// 加载视图（第三方库）
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation RecommendViewController

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
        naviTitle.text = @"商铺列表";
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageNonce = 1;
    _pageLimit = 8;
    _shopListArray = [NSMutableArray array];
    
    [self getShopList:_pageNonce isLoad:NO isFirst:YES];
    [self createShopList];
    
    [self createMJRefresh];
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
    [self getShopList:_pageNonce isLoad:YES isFirst:NO];
}

/**
 下拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    // 这里需要处理的
//    if (_pageNonce > 4 || _pageNonce == 4)
//    {
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [_hud addSuccessString:@"没有更多了哟~" delay:1];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView footerEndRefreshing];
//        });
//        
//        return;
//    }
    _pageNonce++;
    [self getShopList:_pageNonce isLoad:NO isFirst:NO];
}

#pragma mark - Private Functions -

/**
 popViewController方法返回上一个视图
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 创建商铺列表视图
 */
- (void)createShopList
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (kIsiPhone) {
        _tableView.rowHeight = 170;
    } else {
        _tableView.rowHeight = 300;
    }
    
    [self.view addSubview:_tableView];
    
}

/**
 获取商铺列表方法
 
 @param page       数据的页数
 @param isDownPull 判断是否下拉加载
 @param first      判断是否是第一次进入
 */
- (void)getShopList:(NSInteger)page isLoad:(BOOL)isDownPull isFirst:(BOOL)first
{
    if (first == YES)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    _isLoading = YES;
    
    NSString  *pageStr = [NSString stringWithFormat:@"%ld",(long)page];
    
    NSDictionary *params = @{@"page"                    :   pageStr,
                             @"limit"                   :   @"8"};
                             
    NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kShopListURL params:params];
    YunLog("recommendListUrl = %@",listURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:listURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"recommend list responseObject = %@", responseObject);
        
        if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
        {
            if (isDownPull == YES) {
                [self.shopListArray removeAllObjects];
            }
            
            NSArray *pageArray = [[responseObject objectForKey:@"data"] objectForKey:@"shop_list"];
            
            if (pageArray == nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isLoading = NO;
                    _tableView.footerHidden = YES;
                    [_tableView footerEndRefreshing];
                });
                _pageNonce--;
                return;
            }
            
            // 获取加载的数据
            if (page == 1)
            {
                for (int i = 3; i < pageArray.count; i++) {
                    NSDictionary *dictTemp = pageArray[i];
                    recommendShopsModel *sModel = [[recommendShopsModel alloc] init];
                    [sModel setValuesForKeysWithDictionary:dictTemp];
                    
                    [self.shopListArray addObject:sModel];
                }
            }
            else
            {
                for(NSDictionary *dict in pageArray)
                {
                    recommendShopsModel *sModel = [[recommendShopsModel alloc] init];
                    [sModel setValuesForKeysWithDictionary:dict];
                    
                    [self.shopListArray addObject:sModel];
                }
            }
        }
        else
        {
            [_hud addErrorString:@"网络数据获取失败" delay:2.0];
            _isLoading = NO;
            _tableView.footerHidden = NO;
            [self.tableView headerEndRefreshing];
            [self.tableView footerEndRefreshing];
            
            if (first == YES)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self backToPrev];
                });
            }
        }
        
        if (_tableView == nil)
        {
            [self createShopList];
        }else
        {
            [_tableView reloadData];
        }
        
        [_hud hide:YES];
        _isLoading = NO;
        _tableView.footerHidden = NO;
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"shop list error = %@", error);
        [_hud addErrorString:@"网络数据获取失败" delay:2.0];
        
        _isLoading = NO;
        _tableView.footerHidden = NO;
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backToPrev];
        });
    }];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _shopListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendShopsCell *cell = [RecommendShopsCell cellWithTableView:tableView];
    
    recommendShopsModel *sModel = self.shopListArray[indexPath.row];
    
    [cell config:sModel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    recommendShopsModel *sModel = self.shopListArray[indexPath.row];
    
    ShopInfoNewController *shopInfoVC = [[ShopInfoNewController alloc] init];
    shopInfoVC.code = sModel.action_value;
    
    [self.navigationController pushViewController:shopInfoVC animated:YES];

}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0 ) {
        [self footerRereshing];
    }
}
@end
