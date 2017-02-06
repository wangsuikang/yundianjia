//
//  CommentListViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/9/18.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "CommentListViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface CommentListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否在加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) NSInteger pageNonce;

@end

@implementation CommentListViewController

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
        naviTitle.text = @"用户评价";
        
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
    
    self.view.backgroundColor = kGrayColor;
    
    _dataSource = [NSMutableArray array];
    
    [self getNextPageViewIsPullDown:YES withPage:1];
    
    [self createUI];
    
    [self createMJRefresh];
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
    _isLoading = YES;;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    // 获取商品组数据
    NSDictionary *params = @{@"code"                  :   _code,
                             @"page"                  :   [NSString stringWithFormat:@"%ld",page],
                             @"per"                   :   @"8"};
    
    NSString *commitListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kProductCommentsURL params:params];
    YunLog(@"用户评论列表 = %@", commitListURL);
    
    [manager GET:commitListURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"用户评论列表 responseObject = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        NSArray *newgroups = [NSArray array];
        if ([code isEqualToString:kSuccessCode]) {
            newgroups = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"product_comments"]);
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
                _tableView.headerHidden = YES;
                
                UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
                emptyLabel.text = @"还没有评论哟~";
                emptyLabel.font = kMidFont;
                emptyLabel.textColor = [UIColor lightGrayColor];
                
                [_tableView addSubview:emptyLabel];
                
                _tableView.scrollEnabled = NO;
            }
            else
            {
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
        
        YunLog(@"用户评论列表 - error = %@", error);
    }];
}

- (void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = kGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _tableView.allowsSelectionDuringEditing = YES;
    
    [self.view addSubview:_tableView];
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
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *comment = _dataSource[indexPath.row];

    NSString *commentStr = kNullToString([comment objectForKey:@"content"]);
    
    CGSize commentStrSize = [commentStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 10, 9999)];
    
    return 95 + commentStrSize.height + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    NSDictionary *comment = _dataSource[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    NSString *commentStr = kNullToString([comment objectForKey:@"content"]);
    
    CGSize commentStrSize = [commentStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 10, 9999)];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 95 + commentStrSize.height)];
    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    userIcon.image = [UIImage imageNamed:@"user_comment_icon"];
    
    [backView addSubview:userIcon];
    
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userIcon.frame) + 10, 5, 80, 30)];
    userLabel.text = kNullToString([comment objectForKey:@"user"]);
    userLabel.font = kMidFont;
    userLabel.textColor = ColorFromRGB(0x282828);
    userLabel.textAlignment = NSTextAlignmentLeft;
    
    [backView addSubview:userLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 150, 5, 150, 30)];
    timeLabel.text = kNullToString([comment objectForKey:@"created_at"]);
    timeLabel.font = kMidFont;
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.textAlignment = NSTextAlignmentRight;
    
    [backView addSubview:timeLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 0.5)];
    line.backgroundColor = kLineColor;
    
    [backView addSubview:line];
    
    NSInteger rank = [kNullToString([comment objectForKey:@"rank"]) integerValue];
    
    CGFloat starX;
    
    for (int i = 0; i < rank; i ++) {
        UIImageView *starView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + (20 + 1) * i, CGRectGetMaxY(line.frame) + 5, 20, 20)];
        starView.image = [UIImage imageNamed:@"user_comment_star_selected"];
        
        [backView addSubview:starView];
        
        starX = CGRectGetMaxX(starView.frame) + 1;
    }
    
    for (int i = 0; i < 5 - rank; i ++) {
        UIImageView *starView = [[UIImageView alloc] initWithFrame:CGRectMake(starX + (20 + 1) * i, CGRectGetMaxY(line.frame) + 5, 20, 20)];
        starView.image = [UIImage imageNamed:@"user_comment_star_unselected"];
        
        [backView addSubview:starView];
    }
    
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(line.frame) + 35, commentStrSize.width, commentStrSize.height + 5)];
    commentLabel.text = kNullToString([comment objectForKey:@"content"]);
    commentLabel.font = kMidFont;
    commentLabel.textColor = kLightBlackColor;
    commentLabel.textAlignment = NSTextAlignmentLeft;
    
    [backView addSubview:commentLabel];
    
    return cell;
}
@end
