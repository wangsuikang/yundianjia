//
//  MyHistoryViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/7/20.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyHistoryViewController.h"

//Common
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "ProductDetailViewController.h"

// Views
#import "MyHistoryCell.h"

//cell的重用id
#define kCellReuseId (@"cellId")
#define kBgViewWidth ((kScreenWidth - kTitleHeight) / 2)
#define kBgViewHeight (kBgViewWidth + 50)

@interface MyHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;

@end

@implementation MyHistoryViewController

#define mark - Function -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"我的浏览足迹";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    // 设置透明导航栏
    //    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    //    {
    //        NSArray *list=self.navigationController.navigationBar.subviews;
    //
    //        for (id obj in list) {
    //
    //            if ([obj isKindOfClass:[UIImageView class]]) {
    //
    //                UIImageView *imageView=(UIImageView *)obj;
    //
    //                imageView.hidden=NO;
    //            }
    //        }
    //    }
    _collectionView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    //    UIView *statuView = [[UIView alloc] initWithFrame:CGRectMake(0, -21, kScreenWidth, 21)];
    //    statuView.backgroundColor = [UIColor whiteColor];
    //    statuView.tag = 1001;
    //
    //    [self.navigationController.navigationBar addSubview:statuView];
    //    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    //
    //    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createMJRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
    
    [_collectionView removeHeader];
    [_collectionView removeFooter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageNonce = 1;
    _isLoading = NO;
    _dataSource = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self createUI];
    
    [self getNextPageViewIsPullDown:NO withPage:[NSString stringWithFormat:@"%ld",(long)_pageNonce]];
    
    //    [self createMJRefresh];
}

- (void)dealloc
{
    _collectionView.delegate = nil;
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
    
    // 获取浏览商品数据
    NSDictionary *param = @{@"user_session_key"       :   kNullToString(appDelegate.user.userSessionKey),
                            @"page"                   :   page,
                            @"per"                    :   @"8"};
    
    NSString *historyURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kHistoryURL params:param];
    YunLog(@"我的足迹URL = %@", historyURL);
    
    [manager GET:historyURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (pullDown == YES) {
            [_dataSource removeAllObjects];
        }
        YunLog(@"coupons = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            
            NSArray *browse_histories = [[responseObject objectForKey:@"data"] objectForKey:@"browse_histories"];
            YunLog(@"ceshi - %@", browse_histories);
            // 计算时间进行排序
            for (NSDictionary *timeDict in browse_histories) {
                NSString *timeStr = timeDict[@"created_at"];
                NSLog(@"time = %@", timeStr);
                
            }
            
            if (browse_histories.count > 0) {
                _collectionView.backgroundView.hidden = YES;
                
                for (NSDictionary *dict in browse_histories) {
                    [_dataSource addObject:dict];
                }
                _isLoading = NO;
                [_hud hide:YES];
                
                [_collectionView footerEndRefreshing];
                [_collectionView headerEndRefreshing];
                
                _collectionView.footerHidden = NO;
                [_collectionView reloadData];
                
            } else {
                if (_collectionView.contentOffset.y == 0) {
                    _collectionView.backgroundView.hidden = NO;
                }
                
                [_hud hide:YES];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isLoading = NO;
                    _collectionView.footerHidden = YES;
                    [_collectionView footerEndRefreshing];
                    [_collectionView headerEndRefreshing];
                });
            }
        }else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self backToPrev];
        } else {
            [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                           delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
        
        _isLoading = NO;
        [_hud hide:YES];
        _collectionView.footerHidden = NO;
        [_collectionView headerEndRefreshing];
        [_collectionView footerEndRefreshing];
    }];
}

#pragma mark - CreateUI -

- (void)createUI
{
    //布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //上下左右的间距
    layout.sectionInset = UIEdgeInsetsMake(10, 5, 5, 5);
    //横向间距
    layout.minimumInteritemSpacing = 5;
    //纵向间距
    layout.minimumLineSpacing = 5;
    //cell的大小
    CGFloat space = 0;
    CGFloat titleHeight = 0;
    if (kIsiPhone) {
        space = 20;
        titleHeight = 50;
    } else {
        space = 40;
        titleHeight = 80;
    }
    layout.itemSize = CGSizeMake((kScreenWidth - space) / 2, (kScreenWidth - space) / 2 + titleHeight);
    
    //创建网格视图
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, kScreenHeight - kNavTabBarHeight) collectionViewLayout:layout];
    //设置背景颜色
    _collectionView.backgroundColor = [UIColor colorWithRed:238 green:238 blue:238 alpha:1];
    //代理和数据源代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = YES;
    
    //注册cell
    [_collectionView registerClass:[MyHistoryCell class] forCellWithReuseIdentifier:kCellReuseId];
    
    [self.view addSubview:_collectionView];
    
    _bgView = [[UIView alloc] initWithFrame:_collectionView.frame];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, (_bgView.frame.size.height - 150) / 2 - 20, 120, 150)];
    imageView.image = [UIImage imageNamed:@"no_history"];

    [_bgView addSubview:imageView];

    _collectionView.backgroundView = _bgView;
    _collectionView.backgroundView.hidden = YES;
    
//    [self createMJRefresh];
}

#pragma mark - Pull Refresh -

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh{
    
    [_collectionView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [_collectionView addFooterWithTarget:self action:@selector(footerRereshing)];
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

#pragma mark - UICollectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseId forIndexPath:indexPath];
    
    //显示数据
    NSDictionary *dict = _dataSource[indexPath.item];
    
    [cell config:dict];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _dataSource[indexPath.row];
    
    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
    detail.productCode = [dict objectForKey:@"code"];
    detail.shopCode = [dict objectForKey:@"shop_code"];
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
        _collectionView.backgroundView.hidden = YES;
        [self footerRereshing];
    }
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [_collectionView setHeaderHidden:NO];
//    [_collectionView setFooterHidden:NO];
//    
//    [_collectionView addHeaderWithTarget:self action:@selector(headerRereshing)];
//    
//    [_collectionView addFooterWithTarget:self action:@selector(footerRereshing)];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_collectionView setHeaderHidden:YES];
//        [_collectionView setFooterHidden:YES];
//    });
//}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [_collectionView setHeaderHidden:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
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
