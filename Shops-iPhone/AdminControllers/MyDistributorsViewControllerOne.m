//
//  MyDistributorsViewControllerOne.m
//  Shops-iPhone
//
//  Created by xzq on 15/10/23.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

//Controller
#import "MyDistributorsViewControllerOne.h"
#import "AddNewDistributorViewController.h"
#import "DistributorDetailViewController.h"
#import "AdminDistributeGroupViewController.h"

//Common
#import "LibraryHeadersForCommonController.h"

#import "AddNewDistributorViewController.h"

@interface MyDistributorsViewControllerOne ()<UITableViewDataSource,UITableViewDelegate>

//分销商列表
@property (nonatomic,strong ) UITableView       *myTableView;

/// 三方库
@property (nonatomic, strong) MBProgressHUD     *hud;

/// 分销商数组
@property (nonatomic, strong) NSMutableArray    *distributors;

/// 是否在加载数据
@property (nonatomic, assign) BOOL              isLoading;

/// 当前页
@property (nonatomic, assign) NSInteger         pageNonce;

@end

@implementation MyDistributorsViewControllerOne

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 25, 25);
        [rightButton setImage:[UIImage imageNamed:@"plus_button"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        rightItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.distributors = [NSMutableArray array];
    
    self.view.backgroundColor = kWhiteColor;
    
    [self getNextPageViewIsPullDown:YES withPage:1];
    
    [self createUI];
    
    [self createMJRefresh];
}

- (void)dealloc
{
    _myTableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RightButtonClick -

- (void)rightButtonClick
{
    YunLog(@"rightButtonClick");
    AddNewDistributorViewController *addNewDistributor = [[AddNewDistributorViewController alloc] init];
    
    [self.navigationController pushViewController:addNewDistributor animated:YES];
}

#pragma mark - CreateUI -

- (void)createUI
{
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.tableFooterView = [[UIView alloc] init];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.backgroundColor = kWhiteColor;

    UIView *back = [[UIView alloc] initWithFrame:_myTableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无分销商";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _myTableView.backgroundView = back;
    _myTableView.backgroundView.hidden = YES;
    
    [self.view addSubview:self.myTableView];
}

#pragma mark -createMJRefresh

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh
{
    [_myTableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [_myTableView addFooterWithTarget:self action:@selector(footerRereshing)];
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

#pragma mark - GetData -
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
                _myTableView.footerHidden = YES;
            }
            else
            {
                _myTableView.footerHidden = NO;
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
            [_myTableView footerEndRefreshing];
            [_myTableView headerEndRefreshing];
            [_myTableView reloadData];
            _hud.hidden = YES;
            
            if (_distributors.count == 0)
            {
                _myTableView.backgroundView.hidden = NO;
                _myTableView.headerHidden = YES;
            }
            else
            {
                _myTableView.backgroundView.hidden = YES;
                _myTableView.headerHidden = NO;
            }
        }
        else
        {
            [_myTableView footerEndRefreshing];
            [_myTableView headerEndRefreshing];
            _myTableView.footerHidden = NO;
            
            [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
        }
        _isLoading = NO;
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
        YunLog(@"我的商品URL - error = %@", error);
        
        _myTableView.backgroundView.hidden = NO;
        
        [_myTableView footerEndRefreshing];
        [_myTableView headerEndRefreshing];
        _myTableView.footerHidden = NO;
        _isLoading = NO;
    }];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.distributors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSDictionary *distributor = _distributors[indexPath.row];
    
    // 加载cell控件
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    cell中的第一行
    UIView *backgroundOneView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 30)];
    backgroundOneView.backgroundColor = ColorFromRGB(0xfe8100);
    
    [cell.contentView addSubview:backgroundOneView];

//    cell中的第二行
    UIView *backgroundTwoView = [[UIView alloc] initWithFrame:CGRectMake(10, backgroundOneView.frame.size.height, kScreenWidth - 20, 35)];
    backgroundTwoView.backgroundColor = ColorFromRGB(0xf39900);
    
    [cell.contentView addSubview:backgroundTwoView];
    
//    cell中的第三行
    UIView *backgroundThreeView = [[UIView alloc] initWithFrame:CGRectMake(20, backgroundTwoView.frame.size.height + backgroundTwoView.frame.origin.y, kScreenWidth - 40, 60)];
    backgroundThreeView.backgroundColor = ColorFromRGB(0xf8c265);
    
//     cell右边图标按钮
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat buttonWidth = backgroundOneView.frame.size.height + backgroundTwoView.frame.size.height - 20;
    iconButton.frame = CGRectMake(kScreenWidth - 10 - 10 - buttonWidth, 10, buttonWidth, buttonWidth);
    
    if (indexPath.row % 2 == 0) {
        [iconButton setBackgroundImage:[UIImage imageNamed:@"icon_image_one"] forState:UIControlStateNormal];
    } else {
        [iconButton setBackgroundImage:[UIImage imageNamed:@"icon_image_two"] forState:UIControlStateNormal];
    }
    
    iconButton.tag = 100 + indexPath.row;
    [iconButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [iconButton addTarget:self action:@selector(iconButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:backgroundThreeView];
    
//  第一行内Label
    for (int i = 0; i < 3; i++) {
        CGFloat width = (kScreenWidth - buttonWidth - 40) / 3 ;
        CGFloat x = width * i;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, backgroundOneView.frame.size.height)];
        label.tag = 10 + i;
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:kWhiteColor];
        if (kIsiPhone) {
            [label setFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize * proprotion] ];
        } else {
            [label setFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize ] ];
        }
        if (i == 0) {
            label.text = kNullToString([distributor objectForKey:@"name"]);
        } else if (i == 1){
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
            
            label.text = [NSString stringWithFormat:@"%@", statusStr];
            CGRect frame = label.frame;
            frame.origin.x -= 10 * proprotion;
            label.frame = frame;
        } else {
            label.text = [NSString stringWithFormat:@"%@", kNullToString([[distributor objectForKey:@"created_at"] substringWithRange:NSMakeRange(0, 10)])];
        }
        
        [backgroundOneView addSubview:label];
    }
    
//    第二行控件
    UIImageView *todayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 15, backgroundTwoView.frame.size.height)];
    todayImageView.image = [UIImage imageNamed:@"income_icon"];
    [todayImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [backgroundTwoView addSubview:todayImageView];
    
    UILabel *todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(todayImageView.frame.size.width + todayImageView.frame.origin.x, 0, 30 * proprotion, backgroundTwoView.frame.size.height)];
    todayLabel.text = @"今日";
    todayLabel.textColor = kWhiteColor;
    [todayLabel setFont:kSmallBoldFont];
    
    [backgroundTwoView addSubview:todayLabel];
    
    for (int i = 0; i < 3; i++) {
        CGFloat width = (kScreenWidth - buttonWidth - 40 - todayLabel.frame.size.width -todayLabel.frame.origin.x) / 3 ;
        CGFloat x = width * i;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(todayLabel.frame.size.width + todayLabel.frame.origin.x + x + 5, 0, 42, backgroundTwoView.frame.size.height)];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:kWhiteColor];
        [label setFont:kSmallMoreSizeFont];
        
        if (i == 0) {
            label.text = @"销量:";
            CGSize size = [label.text sizeWithFont:kSmallMoreSizeFont size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            CGRect frame = label.frame;
            frame.size.width = size.width;
            label.frame = frame;
        } else if (i == 1) {
            label.text = @"成交订单:";
            CGSize size = [label.text sizeWithFont:kSmallMoreSizeFont size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            CGRect frame = label.frame;
            frame.origin.x -= 10 * proprotion;
            frame.size.width = size.width;
            label.frame = frame;
        } else {
            label.text = @"收入:";
            CGSize size = [label.text sizeWithFont:kSmallMoreSizeFont size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            CGRect frame = label.frame;
            frame.size.width = size.width;
            label.frame = frame;
        }
        
        [backgroundTwoView addSubview:label];
        
//        参数Label
        UILabel *parameterLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.size.width + label.frame.origin.x, 0, width - label.frame.size.width + 10, backgroundTwoView.frame.size.height)];
        parameterLabel.tag = 20 + i;
        [parameterLabel setTextAlignment:NSTextAlignmentLeft];
        parameterLabel.textColor = kWhiteColor;
        parameterLabel.font = kSmallMoreSizeFont;
        
        if (i == 0) {
            parameterLabel.text = @"100元";
        } else if (i == 1) {
            parameterLabel.text = @"200个";
        } else {
            parameterLabel.text = @"100元";
        }
        
        [backgroundTwoView addSubview:parameterLabel];
    }
    
//    第三行
    UIImageView *totalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    totalImageView.image = [UIImage imageNamed:@"all_icon"];
    [totalImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [backgroundThreeView addSubview:totalImageView];
    
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalImageView.frame.size.width + totalImageView.frame.origin.x, 10, 40, 25)];
    totalLabel.text = @"总计";
    totalLabel.textColor = kWhiteColor;
    [totalLabel setFont:kSmallBoldFont];
    
    [backgroundThreeView addSubview:totalLabel];
    
    for (int i = 0; i < 3; i++) {
        CGFloat width = (kScreenWidth - 40 - 10) / 3 ;
        CGFloat x = width * i;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( x + totalImageView.frame.origin.x, totalImageView.frame.size.height, 42, backgroundThreeView.frame.size.height - totalImageView.frame.size.height + 5)];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:kWhiteColor];
        if (kIsiPhone) {
            [label setFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize * proprotion] ];
        } else {
            [label setFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize] ];
        }
        if (i == 0) {
            label.text = @"销量:";
            CGSize size;
            if (kIsiPhone) {
                size = [label.text sizeWithFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize * proprotion] size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            } else {
                size = [label.text sizeWithFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize ] size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            }

            CGRect frame = label.frame;
            frame.size.width = size.width;
            label.frame = frame;

        } else if (i == 1) {
            label.text = @"成交订单:";
            CGSize size;
            if (kIsiPhone) {
                size = [label.text sizeWithFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize * proprotion] size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            } else {
                size = [label.text sizeWithFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize ] size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            }
            CGRect frame = label.frame;
            frame.origin.x -= 15 * proprotion;
            frame.size.width = size.width;
            label.frame = frame;
        } else {
            label.text = @"收入:";
            CGSize size;
            if (kIsiPhone) {
                size = [label.text sizeWithFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize * proprotion] size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            } else {
                size = [label.text sizeWithFont:[UIFont fontWithName:kFontFamily size:kFontNormalSize ] size:CGSizeMake(CGFLOAT_MAX, backgroundTwoView.frame.size.height)];
            }
            CGRect frame = label.frame;
            frame.size.width = size.width;
            label.frame = frame;
        }

        [backgroundThreeView addSubview:label];
        
        //        参数Label
        UILabel *parameterLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.size.width + label.frame.origin.x, label.frame.origin.y, width - label.frame.size.width + 15, label.frame.size.height)];
        parameterLabel.tag = 30 + i;
        [parameterLabel setTextAlignment:NSTextAlignmentLeft];
        parameterLabel.textColor = kWhiteColor;
        parameterLabel.font = kSmallFont;
        
        if (i == 0) {
            parameterLabel.text = @"100元";
        } else if (i == 1) {
            parameterLabel.text = @"200个";
        } else {
            parameterLabel.text = @"100元";
        }
        
        [backgroundThreeView addSubview:parameterLabel];
    }
    
    [cell.contentView addSubview:iconButton];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 135.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 15)];
    view.backgroundColor = kWhiteColor;
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    YunLog(@"第%ld行被点击",indexPath.section);
    DistributorDetailViewController *distributorDetail = [[DistributorDetailViewController alloc] init];
    
    NSDictionary *distributor = _distributors[indexPath.row];
    
    distributorDetail.distributorName = kNullToString([distributor objectForKey:@"name"]);
    distributorDetail.distributorDesc = kNullToString([distributor objectForKey:@"short_name"]);
    distributorDetail.email = kNullToString([distributor objectForKey:@"email"]);
    distributorDetail.phoneName = kNullToString([distributor objectForKey:@"contact_name"]);
    distributorDetail.phoneNumber = kNullToString([distributor objectForKey:@"mobile_phone"]);
    
    [self.navigationController pushViewController:distributorDetail animated:YES];
}

#pragma mark - CellClick -

- (void)iconButtonClick:(UIButton *)button
{
    YunLog(@"第%ld行被点击",button.tag - 100);
    NSInteger tag = button.tag - 100;
    AdminDistributeGroupViewController *distributeGroup = [[AdminDistributeGroupViewController alloc] init];
    
    NSDictionary *distributor = _distributors[tag];
    
    distributeGroup.distributorName = kNullToString([distributor objectForKey:@"name"]);
    distributeGroup.shopID = kNullToString([distributor objectForKey:@"id"]);
    distributeGroup.distribution_owner_id = kNullToArray([distributor objectForKey:@"user_id"]);
    
    [self.navigationController pushViewController:distributeGroup animated:YES];
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
