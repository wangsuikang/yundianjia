//
//  AdminIncomeViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/12.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AdminIncomeViewController.h"

#import "StatsSearchViewController.h"

#import "LibraryHeadersForCommonController.h"

#define purpleViewWidth (kIsiPhone ? kScreenWidth / 3 : 165)

@interface AdminIncomeViewController ()

/// 数据源
@property (nonatomic, strong) NSDictionary *dataSource;

/// 商家结算 未结算资金
@property (nonatomic, strong) NSDictionary *completeDataSource;

/// 未结算资金
@property (nonatomic, strong) UILabel *labelOne;

/// 累计收入
@property (nonatomic, strong) UILabel *labelTwo;

/// 累计订单
@property (nonatomic, strong) UILabel *labelThree;

/// 今日收入
@property (nonatomic, strong) UILabel *labelFour;

/// 今日订单
@property (nonatomic, strong) UILabel *labeFive;

/// 今日订单总数
@property (nonatomic, strong) UILabel *todayOrderNumLabel;

/// 今日销量
@property (nonatomic, strong) UILabel *todaySaleNum;

/// 今日应收
@property (nonatomic, strong) UILabel *todayIncomeNum;

/// 本周销量
@property (nonatomic, strong) UILabel *weekIncome;

/// 本周成交单数
@property (nonatomic, strong) UILabel *weekOrderNum;

/// 本周收入
@property (nonatomic, strong) UILabel *weekIncomeNum;

/// 本月销量
@property (nonatomic, strong) UILabel *monthIncome;

/// 本月成交单数
@property (nonatomic, strong) UILabel *monthOrderNum;

/// 本月收入
@property (nonatomic, strong) UILabel *monthIncomeNum;

/// 总计销量
@property (nonatomic, strong) UILabel *allIncome;

/// 总计成交单数
@property (nonatomic, strong) UILabel *allOrderNum;

/// 总计收入
@property (nonatomic, strong) UILabel *allIncomeNum;

/// 已结算
@property (nonatomic, strong) UILabel *alreadyIncomeNum;

/// 已结算
@property (nonatomic, strong) UILabel *alreadyOrderNum;

/// 未结算
@property (nonatomic, strong) UILabel *waitIncomeNum;

/// 未结算
@property (nonatomic, strong) UILabel *waitOrderNum;


@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AdminIncomeViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kWhiteColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"我的收入";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
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
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        
        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSArray *list = self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.alpha = 1.0;
            }];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [NSDictionary dictionary];
    
    _completeDataSource = [NSDictionary dictionary];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, kScreenWidth, kScreenHeight + 64)];
    backgroundView.image = [UIImage imageNamed:@"admin_income_back"];
    
    [self.view addSubview:backgroundView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_image"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self getData];
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

- (void)getData
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"])};
    
    NSString *mySaleURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShop_not_settlement_fund params:params];
    
    YunLog(@"mySaleURL = %@", mySaleURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:mySaleURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"mySale responseObject = %@",responseObject);
             
             NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
             
             if ([code isEqualToString:kSuccessCode]) {
                 [_hud hide:YES];
//                 NSDictionary *data = [responseObject objectForKey:@"data"];
                 
                 _dataSource = [responseObject objectForKey:@"data"];
                 
                 [self createUI];
                 
                 [self getShopCompletedData];
                 
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"mySaleURL error = %@", error);
             
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
}

- (void)getShopCompletedData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"])};
    
    NSString *myCompleteURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kSettlementCompletedAndUnCompleted params:params];
    
    YunLog(@"myCompleteURL = %@", myCompleteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:myCompleteURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"mySale responseObject = %@",responseObject);
             
             NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
             
             if ([code isEqualToString:kSuccessCode]) {
                 [_hud hide:YES];
                 _completeDataSource = [responseObject objectForKey:@"data"];
                 
                 NSDictionary *completedDict = [_completeDataSource objectForKey:@"completed"];
                 NSDictionary *unCompletedDict = [_completeDataSource objectForKey:@"uncompleted"];
                 
                 _alreadyIncomeNum.text = [NSString stringWithFormat:@"%.2f", [[completedDict safeObjectForKey:@"total_sale"] floatValue]];
                 _alreadyOrderNum.text = [NSString stringWithFormat:@"%.2f", [[completedDict safeObjectForKey:@"total_income"] floatValue]];
                 _waitIncomeNum.text = [NSString stringWithFormat:@"%.2f", [[unCompletedDict safeObjectForKey:@"total_sale"] floatValue]];
                 _waitOrderNum.text = [NSString stringWithFormat:@"%.2f", [[unCompletedDict safeObjectForKey:@"total_income"] floatValue]];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"mySaleURL error = %@", error);
             
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
    
}

//- (void)createUI
//{
//    CGFloat spaceX = 30;
//    CGFloat spaceY = 20;
//    
//    // 未结算资金
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(spaceX, 64 + spaceY, kScreenWidth - 2 * spaceX, 70)];
//    topView.backgroundColor = kBlueColor;
//    topView.layer.masksToBounds = YES;
//    topView.layer.cornerRadius = 5;
//    
//    [self.view addSubview:topView];
//      
//    UILabel *labal1 = [[UILabel alloc] initWithFrame:CGRectMake(spaceY, 0, topView.frame.size.width / 2 - spaceY, topView.frame.size.height)];
//    labal1.text = @"未结算资金";
//    labal1.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
//    labal1.textAlignment = NSTextAlignmentLeft;
//    labal1.textColor = [UIColor whiteColor];
//    
//    [topView addSubview:labal1];
//    
//    _labelOne = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labal1.frame), 0, topView.frame.size.width / 2 - spaceY, topView.frame.size.height)];
//    _labelOne.text = @"￥0.00";
//    _labelOne.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
//    _labelOne.textAlignment = NSTextAlignmentRight;
//    _labelOne.textColor = [UIColor whiteColor];
//    
//    [topView addSubview:_labelOne];
//
//    
//    // 订单 收入
//    NSArray *incomeTittle = @[@"累计收入", @"累计订单", @"今日收入", @"今日订单"];
//    NSArray *income = @[@"￥0.00", @"0", @"￥0.00", @"0"];
//    
//    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(spaceX, CGRectGetMaxY(topView.frame) + spaceY, kScreenWidth - 2 * spaceX, 180)];
//    midView.backgroundColor = [UIColor orangeColor];
//    midView.layer.masksToBounds = YES;
//    midView.layer.cornerRadius = 5;
//    
//    [self.view addSubview:midView];
//    
//    for (int i = 0; i < 4; i ++) {
//        if (i == 0)
//        {
//            CGFloat labelX = (i % 2) * (midView.frame.size.width / 2);
//            CGFloat labelY = spaceY + (i / 2) * (midView.frame.size.height / 2);
//            
//            _labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, (midView.frame.size.width / 2), 30)];
//            _labelTwo.text = income[i];
//            _labelTwo.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            _labelTwo.textAlignment = NSTextAlignmentCenter;
//            _labelTwo.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:_labelTwo];
//            
//            UILabel *moneyTittle = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(_labelTwo.frame), (midView.frame.size.width / 2), 30)];
//            moneyTittle.text = incomeTittle[i];
//            moneyTittle.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            moneyTittle.textAlignment = NSTextAlignmentCenter;
//            moneyTittle.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:moneyTittle];
//        }
//        if (i == 1)
//        {
//            CGFloat labelX = (i % 2) * (midView.frame.size.width / 2);
//            CGFloat labelY = spaceY + (i / 2) * (midView.frame.size.height / 2);
//            
//            _labelThree = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, (midView.frame.size.width / 2), 30)];
//            _labelThree.text = income[i];
//            _labelThree.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            _labelThree.textAlignment = NSTextAlignmentCenter;
//            _labelThree.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:_labelThree];
//            
//            UILabel *moneyTittle = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(_labelThree.frame), (midView.frame.size.width / 2), 30)];
//            moneyTittle.text = incomeTittle[i];
//            moneyTittle.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            moneyTittle.textAlignment = NSTextAlignmentCenter;
//            moneyTittle.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:moneyTittle];
//        }
//        if (i == 2)
//        {
//            CGFloat labelX = (i % 2) * (midView.frame.size.width / 2);
//            CGFloat labelY = spaceY + (i / 2) * (midView.frame.size.height / 2);
//            
//            _labelFour = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, (midView.frame.size.width / 2), 30)];
//            _labelFour.text = income[i];
//            _labelFour.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            _labelFour.textAlignment = NSTextAlignmentCenter;
//            _labelFour.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:_labelFour];
//            
//            UILabel *moneyTittle = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(_labelFour.frame), (midView.frame.size.width / 2), 30)];
//            moneyTittle.text = incomeTittle[i];
//            moneyTittle.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            moneyTittle.textAlignment = NSTextAlignmentCenter;
//            moneyTittle.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:moneyTittle];
//        }
//        if (i == 3)
//        {
//            CGFloat labelX = (i % 2) * (midView.frame.size.width / 2);
//            CGFloat labelY = spaceY + (i / 2) * (midView.frame.size.height / 2);
//            
//            _labeFive = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, (midView.frame.size.width / 2), 30)];
//            _labeFive.text = income[i];
//            _labeFive.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            _labeFive.textAlignment = NSTextAlignmentCenter;
//            _labeFive.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:_labeFive];
//            
//            UILabel *moneyTittle = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(_labeFive.frame), (midView.frame.size.width / 2), 30)];
//            moneyTittle.text = incomeTittle[i];
//            moneyTittle.font = [UIFont fontWithName:kFontFamily size:kFontSize];
//            moneyTittle.textAlignment = NSTextAlignmentCenter;
//            moneyTittle.textColor = [UIColor whiteColor];
//            
//            [midView addSubview:moneyTittle];
//        }
//    }
//    
//    // 资金明细
//    UIButton *buttomView = [UIButton buttonWithType:UIButtonTypeCustom];
//    buttomView.frame = CGRectMake(spaceX, CGRectGetMaxY(midView.frame) + spaceY, kScreenWidth - 2 * spaceX, 40);
//    buttomView.backgroundColor = kLightBlackColor;
//    buttomView.layer.masksToBounds = YES;
//    buttomView.layer.cornerRadius = 5;
//    [buttomView setTitle:@"资金明细" forState:UIControlStateNormal];
//    [buttomView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    buttomView.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
//    [buttomView addTarget:self action:@selector(goToStatsSearch) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:buttomView];
//}

- (void)createUI
{
    NSDictionary *dayStatistic = [_dataSource objectForKey:@"day_statistic"];
    NSDictionary *weekStatistic = [_dataSource objectForKey:@"week_statistic"];
    NSDictionary *monthStatistic = [_dataSource objectForKey:@"month_statistic"];
    NSDictionary *totalStatistic = [_dataSource objectForKey:@"total_statistic"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    
    [self.view addSubview:scrollView];
    
    UIImageView *purpleView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - purpleViewWidth) / 2, 20, purpleViewWidth, purpleViewWidth)];
    purpleView.image = [UIImage imageNamed:@"purple_icon"];
    
    [scrollView addSubview:purpleView];
    
    UILabel *purpleTittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, purpleViewWidth / 4, purpleViewWidth, purpleViewWidth / 2)];
    purpleTittleLabel.text = @"今日";
    purpleTittleLabel.font = kScreenWidth >= 375 ? [UIFont fontWithName:kFontFamily size:40] : kLangeFont;;
    purpleTittleLabel.textColor = kOrangeColor;
    purpleTittleLabel.textAlignment = NSTextAlignmentCenter;
    
    [purpleView addSubview:purpleTittleLabel];
    
    _todayOrderNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3 * (purpleViewWidth / 4) - 10, purpleViewWidth, 20)];
    _todayOrderNumLabel.text = [NSString stringWithFormat:@"订单: %.2f", [[dayStatistic safeObjectForKey:@"order_count"] floatValue]];
    _todayOrderNumLabel.font = kScreenWidth >= 375 ? kMidFont : kSmallFont;;
    _todayOrderNumLabel.textColor = kLightWhiteColor;
    _todayOrderNumLabel.textAlignment = NSTextAlignmentCenter;
    
    [purpleView addSubview:_todayOrderNumLabel];
    
    UILabel *saleNumTittle = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(purpleView.frame), 45, 20)];
    saleNumTittle.text = @"销售：";
    saleNumTittle.font = kMidFont;
//    saleNumTittle.backgroundColor = [UIColor blueColor];
    saleNumTittle.textColor = [UIColor whiteColor];
    saleNumTittle.textAlignment = NSTextAlignmentLeft;
    
    [scrollView  addSubview:saleNumTittle];

    NSString *saleNum = [NSString stringWithFormat:@"%.2f", [[dayStatistic safeObjectForKey:@"total_sale"] floatValue]];
    CGSize saleNumSize = [saleNum sizeWithFont:kLargeFont size:CGSizeMake(kScreenWidth / 2 - 20 - 45 - 20, 100)];
    
    _todaySaleNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(saleNumTittle.frame),CGRectGetMaxY(saleNumTittle.frame) - saleNumSize.height, saleNumSize.width + 0.1, saleNumSize.height + 0.1)];
    _todaySaleNum.text = saleNum;
//    _todaySaleNum.backgroundColor = [UIColor blackColor];
    _todaySaleNum.font = kLargeFont;
    _todaySaleNum.textColor = [UIColor whiteColor];
    _todaySaleNum.textAlignment = NSTextAlignmentCenter;
    
    [scrollView  addSubview:_todaySaleNum];
    
    UILabel *unitLabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_todaySaleNum.frame), saleNumTittle.frame.origin.y, 15, saleNumTittle.frame.size.height)];
    unitLabelLeft.text = @"元";
    unitLabelLeft.font = kSmallFont;
    unitLabelLeft.textColor = [UIColor whiteColor];
//    unitLabelLeft.backgroundColor = [UIColor redColor];
    unitLabelLeft.textAlignment = NSTextAlignmentLeft;
    
    [scrollView  addSubview:unitLabelLeft];

    NSString *incomeNum = [NSString stringWithFormat:@"%.2f", [[dayStatistic safeObjectForKey:@"income"] floatValue]];
    CGSize incomeNumSize = [incomeNum sizeWithFont:kLargeFont size:CGSizeMake(kScreenWidth / 2 - 20 - 45 - 20, 50)];
    
    UILabel *incomeNumTittle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth / 2) + 10, CGRectGetMaxY(purpleView.frame), 45, 20)];
    incomeNumTittle.text = @"应收：";
    incomeNumTittle.font = kMidFont;
    incomeNumTittle.textColor = [UIColor whiteColor];
    incomeNumTittle.textAlignment = NSTextAlignmentRight;
    
    [scrollView  addSubview:incomeNumTittle];
    
    _todayIncomeNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(incomeNumTittle.frame), CGRectGetMaxY(incomeNumTittle.frame) - incomeNumSize.height, incomeNumSize.width + 0.1, incomeNumSize.height + 0.1)];
    _todayIncomeNum.text = incomeNum;
    _todayIncomeNum.font = kLargeFont;
    _todayIncomeNum.textColor = [UIColor whiteColor];
    _todayIncomeNum.textAlignment = NSTextAlignmentCenter;
    
    [scrollView  addSubview:_todayIncomeNum];
    
    UILabel *unitLabelRight = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_todayIncomeNum.frame), incomeNumTittle.frame.origin.y, 15, saleNumTittle.frame.size.height)];
    unitLabelRight.text = @"元";
    unitLabelRight.font = kSmallFont;
    unitLabelRight.textColor = [UIColor whiteColor];
    unitLabelRight.textAlignment = NSTextAlignmentLeft;
    
    [scrollView  addSubview:unitLabelRight];
    
//    NSArray *backColorArr = @[ColorFromRGB(0xf8c265), ColorFromRGB(0xff86a2), ColorFromRGB(0x62d7c7)];
    NSArray *backLeftColorArr = @[ColorFromRGB(0xfbb664), ColorFromRGB(0xff3566), ColorFromRGB(0x62d7c7)];
//    NSArray *iconNameArr = @[@"income_icon", @"income_icon", @"all_icon"];
    NSArray *titleArrTop = @[@"本", @"本", @"总"];
    NSArray *titleArrBottom = @[@"周", @"月", @"计"];
    NSArray *detailArr = @[@"销售", @"订单", @"收入"];

    CGFloat height = CGRectGetMaxY(saleNumTittle.frame) + 20;
    for (int i = 0; i < 3; i ++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(saleNumTittle.frame) + 20 + ((kScreenWidth - 20 * 2) / 5) * i, kScreenWidth - 20, (kScreenWidth - 20 * 2) / 5)];
        backView.backgroundColor = COLOR(255, 255, 255, 0.1);
        
        [scrollView addSubview:backView];
        
        UILabel *backLeftLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, (backView.frame.size.height - 15) / 2, (backView.frame.size.height - 15) / 2)];
        backLeftLabelTop.backgroundColor = backLeftColorArr[i];
        backLeftLabelTop.text = titleArrTop[i];
        backLeftLabelTop.textColor = [UIColor whiteColor];
        backLeftLabelTop.textAlignment = NSTextAlignmentCenter;
        backLeftLabelTop.font =  kIsiPhone ? (kScreenWidth > 375 ? kNormalFont : kMidFont) : kLargeFont;
        
        [backView addSubview:backLeftLabelTop];
        
        UILabel *backLeftLabelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backLeftLabelTop.frame) - 1, (backView.frame.size.height - 15) / 2, (backView.frame.size.height - 15) / 2 + 1)];
        backLeftLabelBottom.backgroundColor = backLeftColorArr[i];
        backLeftLabelBottom.text = titleArrBottom[i];
        backLeftLabelBottom.textColor = [UIColor whiteColor];
        backLeftLabelBottom.textAlignment = NSTextAlignmentCenter;
        backLeftLabelBottom.font =  kIsiPhone ? (kScreenWidth > 375 ? kNormalFont : kMidFont) : kLargeFont;
        
        [backView addSubview:backLeftLabelBottom];
        
        if (i == 2) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backLeftLabelTop.frame), 15, backView.frame.size.width - backLeftLabelBottom.frame.size.width, backView.frame.size.height - 15)];
            view.backgroundColor = COLOR(98, 215, 199, 0.7);
            
            [backView addSubview:view];
        }
        
        height = CGRectGetMaxY(backView.frame);
        
        CGFloat space = (backView.frame.size.width - backLeftLabelBottom.frame.size.width) / 10;
        
        for (int j = 0; j < 3; j ++) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backLeftLabelBottom.frame) + space + 3 * space * j, CGRectGetMidY(backView.bounds), 2 * space, backView.frame.size.height / 2)];
            titleLabel.text = detailArr[j];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
            titleLabel.textColor = [UIColor whiteColor];
            
            [backView addSubview:titleLabel];
            
            if (i < 2) {
                CGFloat lineHeight = kIsiPhone ? 2 : 5;
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.bounds) - lineHeight, titleLabel.frame.size.width, lineHeight)];
                line.backgroundColor = backLeftColorArr[i];
                
                [titleLabel addSubview:line];
            }
        }
        
        switch (i) {
            case 0:
            {
                _weekIncome = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backLeftLabelBottom.frame) + space / 2, 20, 3 * space, backView.frame.size.height / 2 - 20)];
//                _weekIncome.backgroundColor = [UIColor whiteColor];
                _weekIncome.text = [NSString stringWithFormat:@"%.2f元",[[weekStatistic safeObjectForKey:@"total_sale"] floatValue]];
                
                _weekIncome.textColor = [UIColor whiteColor];
                _weekIncome.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _weekIncome.textAlignment = NSTextAlignmentCenter;

                [backView addSubview:_weekIncome];
                
                NSMutableAttributedString *strOne = [[NSMutableAttributedString alloc] initWithString:_weekIncome.text];
                NSRange rangeOne = NSMakeRange(0,strOne.length - 1);
                
                [strOne addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeOne];
                
                [_weekIncome setAttributedText:strOne];
                
                _weekOrderNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_weekIncome.frame), 20, 3 * space, backView.frame.size.height / 2 - 20)];
//                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                _weekOrderNum.text = [NSString stringWithFormat:@"%@个",[weekStatistic safeObjectForKey:@"order_count"]];
                
                _weekOrderNum.textColor = [UIColor whiteColor];
                _weekOrderNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _weekOrderNum.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_weekOrderNum];
                
                NSMutableAttributedString *strTwo = [[NSMutableAttributedString alloc] initWithString:_weekOrderNum.text];
                NSRange rangeTwo = NSMakeRange(0,strTwo.length - 1);
                
                [strTwo addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeTwo];
                
                [_weekOrderNum setAttributedText:strTwo];
                
                _weekIncomeNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_weekOrderNum.frame), 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                _weekIncomeNum.text = [NSString stringWithFormat:@"%.2f元",[[weekStatistic safeObjectForKey:@"income"] floatValue]];
                
                _weekIncomeNum.textColor = [UIColor whiteColor];
                _weekIncomeNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _weekIncomeNum.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_weekIncomeNum];
                
                NSMutableAttributedString *strThree = [[NSMutableAttributedString alloc] initWithString:_weekIncomeNum.text];
                NSRange rangeThree = NSMakeRange(0,strThree.length - 1);
                
                [strThree addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeThree];
                
                [_weekIncomeNum setAttributedText:strThree];
            }
                break;
                
            case 1:
            {
                _monthIncome = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backLeftLabelBottom.frame) + space / 2, 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekIncome.backgroundColor = [UIColor whiteColor];
                _monthIncome.text = [NSString stringWithFormat:@"%.2f元",[[monthStatistic safeObjectForKey:@"total_sale"] floatValue]];
                
                _monthIncome.textColor = [UIColor whiteColor];
                _monthIncome.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _monthIncome.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_monthIncome];
                
                NSMutableAttributedString *strOne = [[NSMutableAttributedString alloc] initWithString:_monthIncome.text];
                NSRange rangeOne = NSMakeRange(0,strOne.length - 1);
                
                [strOne addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeOne];
                
                [_monthIncome setAttributedText:strOne];
                
                _monthOrderNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_monthIncome.frame), 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                _monthOrderNum.text = [NSString stringWithFormat:@"%@个",[monthStatistic safeObjectForKey:@"order_count"]];
                
                _monthOrderNum.textColor = [UIColor whiteColor];
                _monthOrderNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _monthOrderNum.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_monthOrderNum];
                
                NSMutableAttributedString *strTwo = [[NSMutableAttributedString alloc] initWithString:_monthOrderNum.text];
                NSRange rangeTwo = NSMakeRange(0,strTwo.length - 1);
                
                [strTwo addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeTwo];
                
                [_monthOrderNum setAttributedText:strTwo];
                
                _monthIncomeNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_monthOrderNum.frame), 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                _monthIncomeNum.text = [NSString stringWithFormat:@"%.2f元",[[monthStatistic safeObjectForKey:@"income"] floatValue]];
                
                _monthIncomeNum.textColor = [UIColor whiteColor];
                _monthIncomeNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _monthIncomeNum.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_monthIncomeNum];
                
                NSMutableAttributedString *strThree = [[NSMutableAttributedString alloc] initWithString:_monthIncomeNum.text];
                NSRange rangeThree = NSMakeRange(0,strThree.length - 1);
                
                [strThree addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeThree];
                
                [_monthIncomeNum setAttributedText:strThree];
            }
                break;
            case 2:
            {
                _allIncome = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backLeftLabelBottom.frame) + space / 2, 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekIncome.backgroundColor = [UIColor whiteColor];
                _allIncome.text = [NSString stringWithFormat:@"%.2f元",[[totalStatistic safeObjectForKey:@"total_sale"] floatValue]];
                
                _allIncome.textColor = [UIColor whiteColor];
                _allIncome.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _allIncome.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_allIncome];
                
                NSMutableAttributedString *strOne = [[NSMutableAttributedString alloc] initWithString:_allIncome.text];
                NSRange rangeOne = NSMakeRange(0,strOne.length - 1);
                
                [strOne addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeOne];
                
                [_allIncome setAttributedText:strOne];
                
                _allOrderNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_allIncome.frame), 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                _allOrderNum.text = [NSString stringWithFormat:@"%@个",[totalStatistic safeObjectForKey:@"order_count"]];
                
                _allOrderNum.textColor = [UIColor whiteColor];
                _allOrderNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _allOrderNum.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_allOrderNum];
                
                NSMutableAttributedString *strTwo = [[NSMutableAttributedString alloc] initWithString:_allOrderNum.text];
                NSRange rangeTwo = NSMakeRange(0,strTwo.length - 1);
                
                [strTwo addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeTwo];
                
                [_allOrderNum setAttributedText:strTwo];
                
                _allIncomeNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_allOrderNum.frame), 20, 3 * space, backView.frame.size.height / 2 - 20)];
                //                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                _allIncomeNum.text = [NSString stringWithFormat:@"%.2f元",[[totalStatistic safeObjectForKey:@"income"] floatValue]];
                
                _allIncomeNum.textColor = [UIColor whiteColor];
                _allIncomeNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _allIncomeNum.textAlignment = NSTextAlignmentCenter;
                
                [backView addSubview:_allIncomeNum];
                
                NSMutableAttributedString *strThree = [[NSMutableAttributedString alloc] initWithString:_allIncomeNum.text];
                NSRange rangeThree = NSMakeRange(0,strThree.length - 1);
                
                [strThree addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeThree];
                
                [_allIncomeNum setAttributedText:strThree];
            }
                break;
                
            default:
                break;
        }
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.userType == 2)
    {
        for (int i = 0; i < 2; i ++) {
            UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10 + ((kScreenWidth - 30) / 2 + 10) * i, height + 20, (kScreenWidth - 30) / 2, (kScreenWidth -30) / 2 - 20)];
            backView.backgroundColor = COLOR(255, 255, 255, 0.3);
            
            [scrollView addSubview:backView];
            
            UIButton *backBottomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 2 * (backView.frame.size.height / 3) + 10, backView.frame.size.width, (backView.frame.size.height - 10) / 3)];
            backBottomButton.backgroundColor = backLeftColorArr[i];
            [backBottomButton addTarget:self action:@selector(goToStatsSearch:) forControlEvents:UIControlEventTouchUpInside];
            backBottomButton.tag = (i+1) * 100;
            
            [backView addSubview:backBottomButton];
            
            if (i == 0)
            {
                UILabel *titleOne = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                titleOne.text = @"销售";
                titleOne.textColor = [UIColor whiteColor];
                titleOne.font = kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont;
                titleOne.textAlignment = NSTextAlignmentLeft;
                
                [backView addSubview:titleOne];
                
                _alreadyIncomeNum = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(titleOne.frame), (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];

                _alreadyIncomeNum.text = @"0.0元";
                
                _alreadyIncomeNum.textColor = [UIColor whiteColor];
                _alreadyIncomeNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _alreadyIncomeNum.textAlignment = NSTextAlignmentLeft;
                
                [backView addSubview:_alreadyIncomeNum];
                
                NSMutableAttributedString *strOne = [[NSMutableAttributedString alloc] initWithString:_alreadyIncomeNum.text];
                NSRange rangeOne = NSMakeRange(0, strOne.length - 1);
                
                [strOne addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeOne];
                
                [_alreadyIncomeNum setAttributedText:strOne];
                
                UILabel *titleTwo = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleOne.frame) + 10, 10, (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                titleTwo.text = @"收入";
                titleTwo.textColor = [UIColor whiteColor];
                titleTwo.font = kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont;
                titleTwo.textAlignment = NSTextAlignmentRight;
                
                [backView addSubview:titleTwo];
                
                _alreadyOrderNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleOne.frame) + 10, CGRectGetMaxY(titleTwo.frame), (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                _alreadyOrderNum.text = @"0.0元";
                
                _alreadyOrderNum.textColor = [UIColor whiteColor];
                _alreadyOrderNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _alreadyOrderNum.textAlignment = NSTextAlignmentRight;
                
                [backView addSubview:_alreadyOrderNum];
                
                NSMutableAttributedString *strTwo = [[NSMutableAttributedString alloc] initWithString:_alreadyOrderNum.text];
                NSRange rangeTwo = NSMakeRange(0,strTwo.length - 1);
                
                [strTwo addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeTwo];
                
                [_alreadyOrderNum setAttributedText:strTwo];

                UIImageView *lineOne = [[UIImageView alloc] initWithFrame:CGRectMake(10, backView.frame.size.height / 3 + 10, backView.frame.size.width - 20, (backView.frame.size.height - 10) / 3)];
                lineOne.image = [UIImage imageNamed:@"line_two"];
                
                [backView addSubview:lineOne];
                
                CGSize rightLabelSize = [@"明细 >" sizeWithFont:kIsiPhone ? (kScreenWidth >= 375 ? kMidFont : kSmallFont) : kFont size:CGSizeMake(99, 99)];
                
                UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, backBottomButton.frame.size.width - rightLabelSize.width - 5 - 20, backBottomButton.frame.size.height)];
                leftLabel.text = @"已结算资金";
                leftLabel.textColor = [UIColor whiteColor];
                //            leftLabel.backgroundColor = [UIColor redColor];
                leftLabel.font = kIsiPhone ? (kScreenWidth >= 375 ? kFont : kMidFont) : kLargeFont;
                leftLabel.textAlignment = NSTextAlignmentLeft;
                
                [backBottomButton addSubview:leftLabel];
                
                UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(backBottomButton.frame.size.width - rightLabelSize.width - 10, 0, rightLabelSize.width, backBottomButton.frame.size.height)];
                rightLabel.text = @"明细 >";
                rightLabel.textColor = [UIColor whiteColor];
                //            rightLabel.backgroundColor = [UIColor blackColor];
                rightLabel.font = kIsiPhone ? (kScreenWidth >= 375 ? kMidFont : kSmallFont) : kFont;
                rightLabel.textAlignment = NSTextAlignmentRight;
                
                [backBottomButton addSubview:rightLabel];
            }
            
            if (i == 1)
            {
                UILabel *titleOne = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                titleOne.text = @"销售";
                titleOne.textColor = [UIColor whiteColor];
                titleOne.font = kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont;
                titleOne.textAlignment = NSTextAlignmentLeft;
                
                [backView addSubview:titleOne];
                
                _waitIncomeNum = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(titleOne.frame), (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                //                _weekOrderNum.backgroundColor = [UIColor whiteColor];
                
                _waitIncomeNum.text = @"0.0元";
                
                _waitIncomeNum.textColor = [UIColor whiteColor];
                _waitIncomeNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _waitIncomeNum.textAlignment = NSTextAlignmentLeft;
                
                [backView addSubview:_waitIncomeNum];
                
                NSMutableAttributedString *strOne = [[NSMutableAttributedString alloc] initWithString:_waitIncomeNum.text];
                NSRange rangeOne = NSMakeRange(0,strOne.length - 1);
                
                [strOne addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeOne];
                
                [_waitIncomeNum setAttributedText:strOne];
                
                UILabel *titleTwo = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleOne.frame) + 10, 10, (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                titleTwo.text = @"收入";
                titleTwo.textColor = [UIColor whiteColor];
                titleTwo.font = kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont;
                titleTwo.textAlignment = NSTextAlignmentRight;
                
                [backView addSubview:titleTwo];
                
                _waitOrderNum = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleOne.frame) + 10, CGRectGetMaxY(titleTwo.frame), (backView.frame.size.width - 20)/ 2, (backView.frame.size.height - 10) / 6)];
                _waitOrderNum.text = @"0.0元";
                
                _waitOrderNum.textColor = [UIColor whiteColor];
                _waitOrderNum.font = kIsiPhone ? (kScreenWidth > 375 ? kMidFont : kSmallFont) : kNormalFont;
                _waitOrderNum.textAlignment = NSTextAlignmentRight;
                
                [backView addSubview:_waitOrderNum];
                
                NSMutableAttributedString *strTwo = [[NSMutableAttributedString alloc] initWithString:_waitOrderNum.text];
                NSRange rangeTwo = NSMakeRange(0,strTwo.length - 1);
                
                [strTwo addAttribute:NSFontAttributeName value:kIsiPhone ? (kScreenWidth > 375 ? kBigFont : kFont) : kLargeFont range:rangeTwo];
                
                [_waitOrderNum setAttributedText:strTwo];
                
                UIImageView *lineOne = [[UIImageView alloc] initWithFrame:CGRectMake(10, backView.frame.size.height / 3 + 10, backView.frame.size.width - 20, (backView.frame.size.height - 10) / 3)];
                lineOne.image = [UIImage imageNamed:@"line_two"];
                
                [backView addSubview:lineOne];
                
                CGSize rightLabelSize = [@"明细 >" sizeWithFont:kIsiPhone ? (kScreenWidth >= 375 ? kMidFont : kSmallFont) : kFont size:CGSizeMake(99, 99)];
                
                UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, backBottomButton.frame.size.width - rightLabelSize.width - 5 - 20, backBottomButton.frame.size.height)];
                leftLabel.text = @"未结算资金";
                leftLabel.textColor = [UIColor whiteColor];
                //            leftLabel.backgroundColor = [UIColor redColor];
                leftLabel.font = kIsiPhone ? (kScreenWidth >= 375 ? kFont : kMidFont) : kLargeFont;
                leftLabel.textAlignment = NSTextAlignmentLeft;
                
                [backBottomButton addSubview:leftLabel];
                
                UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(backBottomButton.frame.size.width - rightLabelSize.width - 10, 0, rightLabelSize.width, backBottomButton.frame.size.height)];
                rightLabel.text = @"明细 >";
                rightLabel.textColor = [UIColor whiteColor];
                //            rightLabel.backgroundColor = [UIColor blackColor];
                rightLabel.font = kIsiPhone ? (kScreenWidth >= 375 ? kMidFont : kSmallFont) : kFont;
                rightLabel.textAlignment = NSTextAlignmentRight;
                
                [backBottomButton addSubview:rightLabel];
            }
        }
    }
    
    height += (kScreenWidth - 20 * 2 - 15) / 2 - 30 + 15 + 20;
    
    scrollView.contentSize = CGSizeMake(kScreenWidth, height);
}

- (void)goToStatsSearch:(UIButton *)sender
{
    StatsSearchViewController *statsSearchView = [[StatsSearchViewController alloc] init];
    statsSearchView.saleStatus = (int)sender.tag / 100;
    
    [self.navigationController pushViewController:statsSearchView animated:YES];
}
@end
