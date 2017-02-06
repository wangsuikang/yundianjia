//
//  AllActivityViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/6/25.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AllActivityViewController.h"

//Common
#import "LibraryHeadersForCommonController.h"

//Controllers
#import "ActivityViewController.h"

#define kShopSpace (kScreenWidth > 375 ? 10 * 1.293 : (kScreenWidth > 320 ? 10 * 1.17 : 10))

@interface AllActivityViewController ()<UITableViewDelegate,UITableViewDataSource>

/// 活动视图
@property (nonatomic, strong) UITableView *tableView;

/// 活动列表数据
@property (nonatomic, strong) NSArray *activities;

/// 加载视图（第三方库）
@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;

@end

@implementation AllActivityViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame     = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font            = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor       = kNaviTitleColor;
    naviTitle.textAlignment   = NSTextAlignmentCenter;
    naviTitle.text            = @"活动";
    
    self.navigationItem.titleView = naviTitle;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    // 添加上拉下拉控件
    [self createMJRefresh];
    
    _pageNonce = 1;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
//    NSDictionary *params = @{@"channel_id"             :   kNullToString(@"2"),
//                             @"page"                    :   [NSString stringWithFormat:@"%d", _pageNonce],
//                             @"limit"                   :   @"8",
//                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
//    
//    NSString *activityURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion3 requestURL:kShopListURL params:params];
    
    NSDictionary *params = @{@"page"                    :   [NSString stringWithFormat:@"%d", _pageNonce],
                             @"per"                     :   @"8"};
    
    NSString *activityURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAllActivitiesURL params:params];
    
    YunLog(@"shop allActivity url = %@", activityURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:activityURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"shop allactivity responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _activities = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"recommends"]);
                 
                 [_tableView reloadData];
                 
                 if (_activities.count >= 8) {
                     [_tableView setFooterHidden:YES];
                 }

                 [_hud hide:YES];
                 
             } else {
                 [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"shop activity error = %@", error);
             
             [_hud addErrorString:@"获取活动数据异常" delay:2.0];
         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

#pragma mark - Private Functions -

/**
 上拉加载数据，下拉刷新数据
 
 @param pullDown 是否是下拉
 @param page     加载数据的页数
 */
- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page
{
    _isLoading = YES;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    _hud.labelText = @"努力加载中...";
    
    NSDictionary *params = @{@"page"                    :   [NSString stringWithFormat:@"%d", _pageNonce],
                             @"per"                     :   @"8"};
    
    NSString *activityURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAllActivitiesURL params:params];
    
    YunLog(@"shop activity url = %@", activityURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:activityURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"shop activity responseObject = %@", responseObject);
        
        if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
            NSArray *newActivities = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"recommends"]);

            YunLog(@"newActivities = %@", newActivities);

            if(pullDown == YES)
            {
                _activities = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"recommends"]);
                
                [_tableView reloadData];
                
//                [_hud addSuccessString:@"数据刷新成功" delay:2.0];
                [_hud setHidden:YES];
                
                _isLoading = NO;
                
                [_tableView headerEndRefreshing];
                
                _pageNonce = 1;
            }
            else
            {
//                if (newActivities.count > 0) {
//                    _activities = [_activities arrayByAddingObjectsFromArray:newActivities];
//
//                    [_tableView reloadData];
//                    
//                    [_hud addSuccessString:@"数据刷新成功4444" delay:2.0];
//                    
//                    [_tableView footerEndRefreshing];
//
//                   // [_hud hide:YES];
//
//                } else {
                _isLoading = NO;
                
                [_tableView footerEndRefreshing];
//
//                    [_hud addErrorString:@"获取活动数据异常" delay:2.0];
                [_hud addSuccessString:@"没有更多了哟~" delay:2.0];
//                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"shop activity error = %@", error);
        
        _isLoading = NO;
        
        [_hud addErrorString:@"获取活动数据异常" delay:2.0];
    }];
}

/**
 返回上一个页面
 */
- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 点击活动商铺进入商铺详情界面
 
 @param index 商铺的索引
 */
- (void)pushVCForActivity:(NSInteger)index
{
    ActivityViewController *activity = [[ActivityViewController alloc] init];
    activity.activityCode = kNullToString([_activities[index] objectForKey:@"activity_code"]);
    activity.activityName = kNullToString([_activities[index] objectForKey:@"title"]);
    activity.isHomePage = NO;
    activity.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:activity animated:YES];
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
    
    [self getNextPageViewIsPullDown:YES withPage:_pageNonce];
}

/**
 上拉刷新响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce++;
    
    [self getNextPageViewIsPullDown:NO withPage:_pageNonce];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"activityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell.contentView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(kShopSpace, 10, kScreenWidth - 2 * kShopSpace, 190)];
    [cell.contentView addSubview:container];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, 160)];
    imageView.backgroundColor = kClearColor;
    imageView.contentMode = UIViewContentModeCenter;
    [imageView addBorderWithDirection:AddBorderDirectionLeft | AddBorderDirectionTop | AddBorderDirectionRight];
    
    __weak UIImageView *_imageView = imageView;
    _imageView.contentMode = UIViewContentModeCenter;
    
    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_activities[indexPath.row] objectForKey:@"icons"] objectForKey:@"url"]]]
                      placeholderImage:[UIImage imageNamed:@"default_image"]
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   _imageView.image = image;
                                   _imageView.contentMode = UIViewContentModeScaleToFill;
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([[[_activities[indexPath.row] objectForKey:@"activity_banners"] firstObject] objectForKey:@"thumb_640_200"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                   _imageView.contentMode = UIViewContentModeScaleToFill;
                               }];
    
//    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[[_activities[indexPath.row] objectForKey:@"activity_banners"] firstObject] objectForKey:@"thumb_640_200"]]]
//                      placeholderImage:[UIImage imageNamed:@"default_image"]
//                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                   _imageView.image = image;
//                                   _imageView.contentMode = UIViewContentModeScaleToFill;
//                               }
//                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                   [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([[[_activities[indexPath.row] objectForKey:@"activity_banners"] firstObject] objectForKey:@"url"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
//                                   _imageView.contentMode = UIViewContentModeScaleToFill;
//                               }];
    
    [container addSubview:imageView];
    
    UIImageView *rightTopView = [[UIImageView alloc] initWithFrame:CGRectMake(imageView.frame.size.width - 50, 0, 50, 50)];
    rightTopView.contentMode = UIViewContentModeScaleAspectFit;
    rightTopView.backgroundColor = kClearColor;
    rightTopView.image = [UIImage imageNamed:[NSString stringWithFormat:@"list_left_top_5"]];
    
    [imageView addSubview:rightTopView];
    
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, container.frame.size.width, 30)];
    labelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    labelView.layer.borderWidth = 1;
    
    [container addSubview:labelView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 160, container.frame.size.width - 10, 30)];
    label.backgroundColor = kClearColor;
    label.font = [UIFont fontWithName:kFontFamily size:14];
    label.text = kNullToString([_activities[indexPath.row] objectForKey:@"title"]);
    
    [container addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushVCForActivity:indexPath.row];
}

#pragma mark - UIScrollViewDelegate -

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint point = scrollView.contentOffset;
//    
//    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) ) {
//        [self footerRereshing];
//    }
//}
@end
