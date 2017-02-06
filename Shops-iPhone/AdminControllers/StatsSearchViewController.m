//
//  StatsSearchViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "StatsSearchViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

#import <PNChart.h>
#import "UICountingLabel.h"

#import "UIImage+UIImageColor.h"

#define kSpace 10

#define ARC4RANDOM_MAX 0x100000000

@interface StatsSearchViewController () <UITableViewDataSource, UITableViewDelegate, PNChartDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, assign) NSInteger pageNonce;

@property (nonatomic) PNLineChart * lineChart;

@property (nonatomic, strong) UIScrollView *bgScrollView;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSMutableArray *setXLabelsArray;

@property (nonatomic, strong) NSMutableArray *setYLabelsArray;

@property (nonatomic, strong) NSMutableArray *incomeArray;

@property (nonatomic, strong) NSMutableArray *saleArray;

@end

@implementation StatsSearchViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kWhiteColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.alpha = 0.0;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, kScreenWidth, 64)];
        imageView.image = [UIImage buttonImageFromColor:kWhiteColor];
        imageView.alpha = 0.15;
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list)
        {
            if ([obj isKindOfClass:[UIImageView class]])
            {
                UIImageView *imageView = (UIImageView *)obj;
                
                imageView.alpha = 1.0;
            }
            
            if ([obj isKindOfClass:[UIView class]])
            {
                UIView *bgView = (UIView *)obj;
                
                [bgView removeFromSuperview];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageNonce = 1;
    
    _dataSource = [NSMutableArray array];
    _setXLabelsArray = [NSMutableArray arrayWithCapacity:0];
    _setYLabelsArray = [NSMutableArray arrayWithCapacity:0];
    _incomeArray = [NSMutableArray arrayWithCapacity:0];
    _saleArray = [NSMutableArray arrayWithCapacity:0];
    
    _naviTitle.text = _saleStatus == 1 ? @"已结算明细" : @"未结算明细";
    
    self.view.backgroundColor = kWhiteColor;
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_image"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    //    [self createUI];
    
    [self createMJRefresh];
    
    [self getNextPageViewIsPullDown:YES withPage:@"1"];
}


- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

#pragma mark - CreateUI -

- (void)createUI
{
    /**
     整理数据
     */
    for (int i = 0; i < _dataSource.count; i++) {
        NSDictionary *dict = _dataSource[i];
        
        // X轴坐标参数
        NSString *timeString = [[[dict safeObjectForKey:@"start_time"] componentsSeparatedByString:@"T"] firstObject];
        
        [_setXLabelsArray addObject:timeString];
        
        // 销售金额
        NSNumber *totalIncome = [NSDecimalNumber decimalNumberWithString:[dict safeObjectForKey:@"total_income"]];
        [_incomeArray addObject:totalIncome];
        
        //商家应收
        NSNumber *commission = [NSDecimalNumber decimalNumberWithString:[dict safeObjectForKey:@"income"]];
        [_saleArray addObject:commission];
    }
    
    // Y轴坐标参数
    NSMutableArray *testIncomeArray = [NSMutableArray arrayWithArray:_incomeArray];
    
    NSMutableArray *testSaleArray = [NSMutableArray arrayWithArray:_saleArray];
    
        for (int j = 0; j < testIncomeArray.count; j++) {
            for (int z = 1; z < testIncomeArray.count - 1; z++) {
                if ([testIncomeArray[j] floatValue] < [testIncomeArray[z] floatValue]) {
                    [testIncomeArray exchangeObjectAtIndex:j withObjectAtIndex:z];
                }
                
                if ([testSaleArray[j] floatValue] > [testSaleArray[z] floatValue]) {
                    [testSaleArray exchangeObjectAtIndex:j withObjectAtIndex:z];
                }
            }
        }
    
    float maxY = [[NSString stringWithFormat:@"%@", [testIncomeArray firstObject]] floatValue];
    
    float minY = [[NSString stringWithFormat:@"%@", [testSaleArray firstObject]] floatValue];
    
    float avr = (maxY - minY) / 6;
    
    for (int j = 0; j < 7; j++) {
        [_setYLabelsArray addObject:[NSString stringWithFormat:@"%.2f", minY]];
        minY += avr;
    }
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bgImageView.image = [UIImage imageNamed:@"bgImage"];
    
    [self.view addSubview:bgImageView];
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, kScreenHeight - kNavTabBarHeight)];
    _bgScrollView.backgroundColor = kClearColor;
    _bgScrollView.showsHorizontalScrollIndicator = YES;
    _bgScrollView.showsVerticalScrollIndicator = YES;
    _bgScrollView.delegate = self;
    
    [self.view addSubview:_bgScrollView];
    
    // 添加表格处理像
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 200.0)];
    self.lineChart.yLabelFormat = @"%1.1f";
    self.lineChart.backgroundColor = [UIColor clearColor];
    self.lineChart.xLabelColor = kWhiteColor;
    
//     [self.lineChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    [self.lineChart setXLabels:_setXLabelsArray];
    self.lineChart.showCoordinateAxis = YES;
    
    //Use yFixedValueMax and yFixedValueMin to Fix the Max and Min Y Value
    //Only if you needed
    self.lineChart.yFixedValueMax = [[_setYLabelsArray lastObject] floatValue];
//    self.lineChart.yFixedValueMax = 300.0;
    self.lineChart.yFixedValueMin = 0.0;
    self.lineChart.yLabelColor = kWhiteColor;
    
//    [self.lineChart setYLabels:@[
//                                 @"0",
//                                 @"50",
//                                 @"100",
//                                 @"150",
//                                 @"200",
//                                 @"250",
//                                 @"300",
//                                 ]];
    [self.lineChart setYLabels:_setYLabelsArray];
    
    // Line Chart #1
//        NSArray * data01Array = @[@50.1, @50.1, @50.4, @0.0, @186.2, @127.2, @176.2];
//    NSArray * data01Array = @[@0.04, @0.06, @0.14];
    NSArray *data01Array = _incomeArray;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"销售金额";
    data01.color = PNFreshGreen;
    data01.alpha = 1.0f;
    data01.itemCount = data01Array.count;
    data01.inflexionPointStyle = PNLineChartPointStyleTriangle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart #2
//        NSArray * data02Array = @[@0.0, @180.1, @26.4, @202.2, @126.2, @167.2, @276.2];
//    NSArray *data02Array = @[@0.04, @0.10, @0.14];
    NSArray *data02Array = _saleArray;
    PNLineChartData *data02 = [PNLineChartData new];
    data02.dataTitle = @"商家应收";
    data02.color = PNTwitterColor;
    data02.alpha = 1.0000000f;
    data02.itemCount = data02Array.count;
    data02.inflexionPointStyle = PNLineChartPointStyleCircle;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [data02Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.lineChart.chartData = @[data01, data02];
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    
    
    [_bgScrollView addSubview:self.lineChart];
    
    self.lineChart.legendStyle = PNLegendItemStyleStacked;
    self.lineChart.legendFont = kSmallMoreSizeFont;
    //    self.lineChart.legendFontColor = kRedColor;
    self.lineChart.alpha = 0.85;
    
    UIView *legend = [self.lineChart getLegendWithMaxWidth:200];
    [legend setFrame:CGRectMake(30, 220, legend.frame.size.width, legend.frame.size.width)];
    [_bgScrollView addSubview:legend];
    
    // 添加按钮
    _titleArray = [NSArray array];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.userType == 2) {
        CGFloat commissionRate = [[kUserDefaults objectForKey:@"commissionRate"] floatValue];
        if (commissionRate > 0.0) {
            _titleArray = @[@"销售金额", @"支付通道费", @"云店家佣金", @"商家应收"];
        } else {
            _titleArray = @[@"销售金额", @"支付通道费", @"商家应收"];
        }
    } else if (appDelegate.user.userType == 3) {
        _titleArray = @[@"销售金额", @"云店家佣金", @"商家应收"];
    }
    
    CGFloat topBtnY = 260;
    CGFloat topBtnWidth = kScreenWidth / _titleArray.count;
    CGFloat topBtnHeight = 50;
    for (int i = 0; i < _titleArray.count; i++) {
        CGFloat topBtnX = topBtnWidth * i;
        UIButton *topBtn = [[UIButton alloc] initWithFrame:CGRectMake(topBtnX, topBtnY, topBtnWidth, topBtnHeight)];
        [topBtn setTitle:_titleArray[i] forState:UIControlStateNormal];
        [topBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
        topBtn.titleLabel.font = _titleArray.count > 3 ? kMidFont : kNormalFont;
        topBtn.backgroundColor = kOrangeColor;
        topBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        //        [topBtn addTarget:self action:@selector(topBtnCkick:) forControlEvents:UIControlEventTouchUpInside];
        //        topBtn.tag = i * 100;
        
        [_bgScrollView addSubview:topBtn];
    }
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBtnY + topBtnHeight, kScreenWidth, kScreenHeight - kNavTabBarHeight - topBtnHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 100;
    _tableView.backgroundColor = kClearColor;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无销售统计";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = NO;
    
    [_bgScrollView addSubview:_tableView];
    
    _bgScrollView.contentSize = CGSizeMake(kScreenWidth, 200 + kScreenHeight);
}

#pragma mark - PNCLineChart Delegate -

- (void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex pointIndex:(NSInteger)pointIndex{
    NSLog(@"Click Key on line %f, %f line index is %d and point index is %d",point.x, point.y,(int)lineIndex, (int)pointIndex);
}

- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex{
    NSLog(@"Click on line %f, %f, line index is %d",point.x, point.y, (int)lineIndex);
}

- (void)changeValue:(UIButton *)sender {
    // Line Chart #1
    NSArray * data01Array = @[@(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300)];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = data01Array.count;
    data01.inflexionPointStyle = PNLineChartPointStyleTriangle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    // Line Chart #2
    NSArray * data02Array = @[@(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300), @(arc4random() % 300)];
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = data02Array.count;
    data02.inflexionPointStyle = PNLineChartPointStyleSquare;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [data02Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    [self.lineChart setXLabels:@[@"DEC 1",@"DEC 2",@"DEC 3",@"DEC 4",@"DEC 5",@"DEC 6",@"DEC 7"]];
    [self.lineChart updateChartData:@[data01, data02]];
}

#pragma mark - UITableViewDelegate -

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
    NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    cell.backgroundColor = kClearColor;
    
    NSMutableDictionary *dict = _dataSource[indexPath.row];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, 2 * kSpace, kScreenWidth - 4 * kSpace, 20)];
    timeLabel.text = [[[dict safeObjectForKey:@"start_time"] componentsSeparatedByString:@"T"] firstObject];
    timeLabel.textColor = kOrangeColor;
    timeLabel.font = kNormalFont;
    
    [cell.contentView addSubview:timeLabel];
    
    CGFloat statsTitleLabelY = CGRectGetMaxY(timeLabel.frame) + 2 * kSpace;
    CGFloat statsTitleLabelWidth = kScreenWidth / _titleArray.count;
    CGFloat statsTitleLabelHeight = 20;
    
    for (int i = 0; i < _titleArray.count; i++) {
        // 合计标题
        CGFloat statsTitleLabelX = statsTitleLabelWidth * i;
        //        UILabel *statsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(statsTitleLabelX, statsTitleLabelY, statsTitleLabelWidth, statsTitleLabelHeight)];
        //        statsTitleLabel.text = @"合计";
        //        statsTitleLabel.font = kNormalFont;
        //        statsTitleLabel.textColor = kLightBlackColor;
        //        statsTitleLabel.textAlignment = NSTextAlignmentCenter;
        //        [cell.contentView addSubview:statsTitleLabel];
        
        // 订单、金额
        //        CGFloat orderMoneyLabelY = CGRectGetMaxY(statsTitleLabel.frame) + kSpace;
        UILabel *orderMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(statsTitleLabelX, statsTitleLabelY, statsTitleLabelWidth, statsTitleLabelHeight)];
        orderMoneyLabel.font = kNormalFont;
        orderMoneyLabel.textColor = kWhiteColor;
        orderMoneyLabel.textAlignment = NSTextAlignmentCenter;
        if (_titleArray.count == 3) {
            if (i == 0) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"total_income"]];
            } else if (i == 1) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"pay_commission"]];;
            } else if (i == 2) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"income"]];
            }
        } else if (_titleArray.count == 4) {
            if (i == 0) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"total_income"]];
            } else if (i == 1) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"pay_commission"]];;
            } else if (i == 2) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"platform_commission"]];
            } else if (i == 3) {
                orderMoneyLabel.text = [NSString stringWithFormat:@"￥%@", dict[@"income"]];
            }
        }
        
        
        [cell.contentView addSubview:orderMoneyLabel];
    }
    
    return cell;
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
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                             @"per"                     :   @"10",
                             @"page"                    :   kNullToString(page)};
    
    NSString *saleListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kSettleCompletedStatistic params:params];
    
    YunLog(@"saleListURL = %@", saleListURL);
    
    [manager GET:saleListURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"saleList responseObject = %@", responseObject);
             NSArray *newData = [NSArray array];
             if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
             {
                 _hud.hidden = YES;
                 newData = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"settlements"]);
                 if (newData.count < 8)
                 {
                     _tableView.footerHidden = YES;
                 }
                 else
                 {
                     _tableView.footerHidden = NO;
                 }
                 
                 if (pullDown == YES)
                 {
                     if (newData.count > 0) {
                         [_dataSource removeAllObjects];
                         [_dataSource setArray:newData];
                     } else {
                         _tableView.backgroundView.hidden = NO;
                         _tableView.headerHidden = YES;
                     }
                 }
                 else
                 {
                     [_dataSource addObjectsFromArray:newData];
                     YunLog(@"newData = %@",newData);
                 }
//                 static dispatch_once_t onceToken;
//                 dispatch_once(&onceToken, ^{
                     [self createUI];
//                 });
                 
                 [_tableView footerEndRefreshing];
                 [_tableView headerEndRefreshing];
                 [_tableView reloadData];
                 
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
             
             YunLog(@"saleListURL - error = %@", error);
         }];
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

#pragma mark - Btn Ckick -

- (void)topBtnCkick:(UIButton *)sender
{
    YunLog(@"切换头部按钮");
    //    [self changeValue:sender];
}

#pragma UIScrollView Delegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
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
