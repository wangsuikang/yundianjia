//
//  MyPreferentialViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/7/20.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyPreferentialViewController.h"
#import "AppDelegate.h"
//Common
#import "LibraryHeadersForCommonController.h"

// Views
#import "MyPreferentialCell.h"

//cell的重用id
#define kCellReuseId (@"cellId")

@interface MyPreferentialViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSArray *preferentialArray;
@property (nonatomic, strong) UIView *bgView;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;

@property (nonatomic, strong) NSMutableArray *couponArray;
@end

@implementation MyPreferentialViewController

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
    
    self.view.backgroundColor = kBackgroundColor;
    self.couponArray = [[NSMutableArray alloc] init];
    _pageNonce = 1;
    _isLoading = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = @"我的优惠劵";

    self.navigationItem.titleView = naviTitle;
    
    [self getNextPageViewIsPullDown:NO withPage:[NSString stringWithFormat:@"%d",_pageNonce]];
    
    [self createUI];
    
    [self createMJRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _collectionView.delegate = nil;
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


#pragma mark - createUI -
    
- (void)createUI
{
        //布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //上下左右的间距
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    //横向间距
    layout.minimumInteritemSpacing = 10;
    //纵向间距
    layout.minimumLineSpacing = 10;
    //cell的大小
    layout.itemSize = CGSizeMake((kScreenWidth - kSpaceMid * 2) / 2, 100);
    
    //创建网格视图
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    //设置背景颜色
    _collectionView.backgroundColor = [UIColor whiteColor];
    //代理和数据源代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    //注册cell
    [_collectionView registerClass:[MyPreferentialCell class] forCellWithReuseIdentifier:kCellReuseId];
    
    _bgView = [[UIView alloc] initWithFrame:_collectionView.frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, (_bgView.frame.size.height - 200) / 2 - 20, 200, 200)];
    imageView.image = [UIImage imageNamed:@"no_ favourable"];
    
    [_bgView addSubview:imageView];
    
    _collectionView.backgroundView = _bgView;
    _collectionView.backgroundView.hidden = YES;
    
    [self.view addSubview:_collectionView];
    
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    AppDelegate *appDelegate = kAppDelegate;
    
    // 获取推荐商品数据
    NSDictionary *param = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                            @"page"                    :   @"0",
                            @"per"                     :   @"10"};
    
    NSString *preferentURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:KCouponsURL params:param];
    
    YunLog(@"优惠劵URL = %@", preferentURL);
    
    [manager GET:preferentURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"coupons = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            self.couponArray = [[[responseObject objectForKey:@"status"] objectForKey:@"data"] objectForKey:@"user_coupons_collection"];
            if (self.couponArray.count > 0) {
                self.collectionView.backgroundView.hidden = YES;
                
                [self.collectionView reloadData];
            } else {
                [_collectionView setHeaderHidden:YES];
                [_collectionView setFooterHidden:YES];
                self.collectionView.backgroundView.hidden = NO;
            }
        }
        else {
            [_collectionView setHeaderHidden:YES];
            [_collectionView setFooterHidden:YES];
            [_hud addErrorString:@"发生错误" delay:2.0f];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_collectionView setHeaderHidden:YES];
        [_collectionView setFooterHidden:YES];
    }];
}

#pragma mark - UICollectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.couponArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyPreferentialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseId forIndexPath:indexPath];
    cell.coupon = [self.couponArray objectAtIndex:indexPath.row];
    
    //显示数据
//    NSDictionary *dict = _dataSource[indexPath.item];
//    
//    [cell config:dict];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *dict = _dataSource[indexPath.row];
//    
//    ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
//    detail.code = [dict objectForKey:@"shopCode"];
//    detail.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) && (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0 ) {
        [self footerRereshing];
    }
}


#pragma mark - getData -

- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSString *)page
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    // 获取推荐商品数据
    NSDictionary *param = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                            @"page"                    :   page,
                            @"per"                     :   @"10"};
    
    NSString *preferentURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:KCouponsURL params:param];
    
    YunLog(@"优惠劵URL = %@", preferentURL);
    
    [manager GET:preferentURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"coupons = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            NSArray * coupons = [[[responseObject objectForKey:@"status"] objectForKey:@"data"] objectForKey:@"user_coupons_collection"];
            if (pullDown) {
                [self.couponArray removeAllObjects];
            }
            else {
                if (coupons.count > 0) {
                    [self.couponArray addObjectsFromArray:coupons];
                }
            }
            [self.collectionView reloadData];
            [_hud hide:YES];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self backToPrev];
        }else {
            [_collectionView setHeaderHidden:YES];
            [_collectionView setFooterHidden:YES];
            [_hud addErrorString:@"发生错误" delay:2.0f];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_collectionView setHeaderHidden:YES];
        [_collectionView setFooterHidden:YES];
    }];
    
}

#pragma mark - BackToPrev -

- (void)backToPrev
{
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
