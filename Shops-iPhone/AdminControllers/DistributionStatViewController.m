//
//  DistributionStatViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "DistributionStatViewController.h"

#import "LibraryHeadersForCommonController.h"

// Controles
#import "StatsSearchViewController.h"

#import "PointView.h"
#import "UIBezierPath+LxThroughPointsBezier.h"
#import "UIImage+UIImageColor.h"

#define kSpace 10

#define kTopButtonTag 100

#define kBgViewTag 1000

#define kDistributionWidthHeight (kScreenWidth > 375 ? 160 * 1.293 : (kScreenWidth > 320 ? 160 * 1.17 : 160))

#define kPageUserWidthHeight (kScreenWidth > 375 ? 120 * 1.293 : (kScreenWidth > 320 ? 120 * 1.17 : 120))

@interface DistributionStatViewController () <PNChartDelegate>
{
    UIBezierPath    *_curve;
    CAShapeLayer    *_shapeLayer;
    NSMutableArray  *_pointViewArray;
}

@property (nonatomic, strong) UILabel            *naviTitle;

@property (nonatomic, strong) MBProgressHUD      *hud;
/// 头部的背景视图控件
@property (nonatomic, strong) UIView             *topBgView;
/// 头部三个控件中选中的按钮
@property (nonatomic, strong) EnterButton        *topSelectButton;

/// 销售订单ImageView
@property (nonatomic, strong) UIImageView        *distributionOrderImageView;

@property (nonatomic, strong) YunLabel           *distributionOrderLabel;

@property (nonatomic, strong) YunLabel           *distributionOrderCount;

/// 页面访问量
@property (nonatomic, strong) UIImageView        *pageCallImageView;

@property (nonatomic, strong) YunLabel           *pageCallLabel;

@property (nonatomic, strong) YunLabel           *pageCallCount;

/// 用户访问量
@property (nonatomic, strong) UIImageView        *userCallImageView;

@property (nonatomic, strong) YunLabel           *userCallLabel;

@property (nonatomic, strong) YunLabel           *userCallCount;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSArray *colorArray;

@property (nonatomic, strong) NSArray *titleColorArray;

@property (nonatomic, strong) NSArray *rightImageNameArray;

@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation DistributionStatViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font            = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor       = kWhiteColor;
        _naviTitle.textAlignment   = NSTextAlignmentCenter;
        _naviTitle.text            = @"统计报表";
        
        self.navigationItem.titleView = _naviTitle;
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
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, kScreenWidth, 64)];
        imageView.image = [UIImage buttonImageFromColor:kWhiteColor];
        imageView.alpha = 0.15;
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    _titleArray = @[@"销售订单", @"页面访问量", @"用户访问量"];
    
    _colorArray = @[ColorFromRGB(0x32b16c), ColorFromRGB(0xf51e66), ColorFromRGB(0x23ade5)];
    _titleColorArray = @[ColorFromRGB(0x1d7e4a), ColorFromRGB(0xb5154a), ColorFromRGB(0x057eb4)];
    _rightImageNameArray = @[@"order_right_image", @"page_right_image", @"user_right_image"];
    
    _dataSource = [NSDictionary dictionary];
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_image"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self getDataWithtime];
    
    //    [self getPageAndUserCountData:@"day"];
    
    //    [self createNewUI];
}

#pragma mark - CreateUI -

- (void)createNewUI
{
    // 背景image
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bgImageView.image = [UIImage imageNamed:@"bgImage"];
    
    [self.view addSubview:bgImageView];
    
    // 头部控件
    _topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavTabBarHeight, kScreenWidth, kNavTabBarHeight)];
    _topBgView.backgroundColor = kClearColor;
    
    [self.view addSubview:_topBgView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavTabBarHeight)];
    bgView.backgroundColor = kWhiteColor;
    bgView.alpha = 0.15;
    
    [_topBgView addSubview:bgView];
    
    NSArray *titleName = @[@"今日", @"本周", @"本月"];
    
    CGFloat buttonWidth = kScreenWidth / 3;
    CGFloat buttonHeight = kNavTabBarHeight;
    CGFloat buttonY = 0;
    
    for (int i = 0; i < titleName.count; i++) {
        CGFloat buttonX = i * buttonWidth;
        EnterButton *button = [[EnterButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
        [button setTitle:titleName[i] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
        [button setTitleColor:kWhiteColor forState:UIControlStateSelected];
        button.titleLabel.font = kBigFont;
        button.tag = i * kTopButtonTag;
        [button addTarget:self action:@selector(createButtonClickUI:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            button.selected = YES;
            _topSelectButton = button;
        }
        
        [_topBgView addSubview:button];
    }
    
    [self createButtonClickUI:_topSelectButton];
}

#pragma mark - Get Data -

- (void)getDataWithtime
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"])};
    
    NSString *saleListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kOrderCountDistribution params:params];
    
    YunLog(@"saleListURL = %@", saleListURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:saleListURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"saleList responseObject = %@",responseObject);
             
             NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
             
             if ([code isEqualToString:kSuccessCode]) {
                 
                 _dataSource = [responseObject objectForKey:@"data"];
                 
                 [_hud hide:YES];
                 
                 [self createNewUI];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"saleListURL error = %@", error);
             
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Ckick -

- (void)createButtonClickUI:(EnterButton *)sender
{
    NSNumber *dayStatistic = [_dataSource objectForKey:@"day_statistic"];
    
    _topSelectButton.selected = NO;
    
    sender.selected = YES;
    
    _topSelectButton = sender;
    
    NSInteger count = sender.tag / kTopButtonTag;
    
    if (count == 0) {
        // 移除bgView
        for (id objc in self.view.subviews) {
            if ([objc isKindOfClass:[UIView class]]) {
                UIView *bgView = (UIView *)objc;
                
                if (bgView.frame.origin.y > kNavTabBarHeight * 1.5) {
                    [bgView removeFromSuperview];
                }
            }
        }
        
        self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake((kScreenWidth - kDistributionWidthHeight) / 2, CGRectGetMaxY(_topBgView.frame) + 50, kDistributionWidthHeight, kDistributionWidthHeight)
                                                          total:dayStatistic
                                                        current:dayStatistic
                                                      clockwise:YES];
        
        self.circleChart.backgroundColor = kClearColor;
        
        [self.circleChart setStrokeColor:kClearColor];
        [self.circleChart setStrokeColorGradientStart:COLOR(0, 255, 255, 1)];
        [self.circleChart strokeChart];
        
        [self.view addSubview:self.circleChart];
        /*
         //        /// 页面访问量
         //        _pageCallImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetMinX(_distributionOrderImageView.frame) - kPageUserWidthHeight / 2), CGRectGetMaxY(_distributionOrderImageView.frame) + 10, kPageUserWidthHeight, kPageUserWidthHeight)];
         //        _pageCallImageView.image = [UIImage imageNamed:@"page_call"];
         //        _pageCallImageView.alpha = 0.0;  /// 默认是隐藏的  因为今日没有访问量的数据
         //
         //        [self.view addSubview:_pageCallImageView];
         //
         //        _pageCallLabel = [[YunLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_pageCallImageView.frame), CGRectGetMaxY(_pageCallImageView.frame) + 10, kPageUserWidthHeight, 30)];
         //        _pageCallLabel.textAlignment = NSTextAlignmentCenter;
         //        _pageCallLabel.textColor = kBlackColor;
         //        _pageCallLabel.text = @"页面访问量";
         //        _pageCallLabel.font = kNormalFont;
         //        _pageCallLabel.alpha = 0.0;  /// 默认是隐藏的  因为今日没有访问量的数据
         //
         //        [self.view addSubview:_pageCallLabel];
         //
         //        _pageCallCount = [[YunLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_pageCallImageView.frame), CGRectGetMidY(_pageCallImageView.frame) - 15, kPageUserWidthHeight, 30)];
         //        _pageCallCount.textAlignment = NSTextAlignmentCenter;
         //        _pageCallCount.textColor = kBlackColor;
         //        _pageCallCount.font = kBigBoldFont;
         //        _pageCallCount.text = @"0";
         //        _pageCallCount.alpha = 0.0;  /// 默认是隐藏的  因为今日没有访问量的数据
         //
         //        [self.view addSubview:_pageCallCount];
         //
         //        /// 用户访问量
         //        _userCallImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetMaxX(_distributionOrderImageView.frame) - kPageUserWidthHeight / 2), CGRectGetMaxY(_distributionOrderImageView.frame) + 10, kPageUserWidthHeight, kPageUserWidthHeight)];
         //        _userCallImageView.image = [UIImage imageNamed:@"user_call"];
         //        _userCallImageView.alpha = 0.0;   /// 默认是隐藏的  因为今日没有访问量的数据
         //
         //        [self.view addSubview:_userCallImageView];
         //
         //        _userCallLabel = [[YunLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_userCallImageView.frame), CGRectGetMaxY(_userCallImageView.frame) + 10, kPageUserWidthHeight, 30)];
         //        _userCallLabel.textAlignment = NSTextAlignmentCenter;
         //        _userCallLabel.textColor = kBlackColor;
         //        _userCallLabel.text = @"用户访问量";
         //        _userCallLabel.font = kNormalFont;
         //        _userCallLabel.alpha = 0.0;  /// 默认是隐藏的  因为今日没有访问量的数据
         //
         //        [self.view addSubview:_userCallLabel];
         //
         //        _userCallCount = [[YunLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_userCallImageView.frame), CGRectGetMidY(_userCallImageView.frame) - 15, kPageUserWidthHeight, 30)];
         //        _userCallCount.textAlignment = NSTextAlignmentCenter;
         //        _userCallCount.textColor = kBlackColor;
         //        _userCallCount.font = kBigBoldFont;
         //        _userCallCount.text = @"0";
         //        _userCallCount.alpha = 0.0;  /// 默认是隐藏的  因为今日没有访问量的数据
         //
         //        [self.view addSubview:_userCallCount];
         */
    }
    else if (count == 1 || count == 2)
    {
        NSArray *weekStatistic = [_dataSource objectForKey:@"week_statistic"];
        NSArray *monthStatistic = [_dataSource objectForKey:@"month_statistic"];
        
        if (weekStatistic.count > 0 && monthStatistic.count > 0)
        {
            for (id objc in self.view.subviews) {
                if ([objc isKindOfClass:[UIView class]]) {
                    UIView *bgView = (UIView *)objc;
                    
                    if (bgView.frame.origin.y > kNavTabBarHeight * 1.5) {
                        [bgView removeFromSuperview];
                    }
                }
            }
            
            NSArray *dataArray = [NSArray array];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            
            if (count == 1) {
                for (int t = 0; t < weekStatistic.count; t++) {
                    id objc = weekStatistic[t];
                    if ([objc isKindOfClass:[NSNull class]]) {
                        [tempArray addObject:@"0.0"];
                    } else {
                        [tempArray addObject:weekStatistic[t]];
                    }
                }
                dataArray = tempArray;
            }
            
            if (count == 2) {
                for (int y = 0; y < monthStatistic.count; y+=2) {
                    id objc = monthStatistic[y];
                    if ([objc isKindOfClass:[NSNull class]]) {
                        [tempArray addObject:@"0.0"];
                    } else {
                        [tempArray addObject:monthStatistic[y]];
                    }
                }
                dataArray = tempArray;
            }
            
            // 隐藏某些控件
            [UIView animateWithDuration:0.6 animations:^{
                CGFloat bgViewWidth = kScreenWidth - 2 * kSpace;
                CGFloat bgViewHeight = (kScreenHeight - CGRectGetMaxY(_topBgView.frame) - 4 * kSpace) / 3;
                
                for (int i = 0; i < 1; i++) {
                    CGFloat bgViewY = CGRectGetMaxY(_topBgView.frame) + kSpace + (i * (bgViewHeight + kSpace));
                    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kSpace, bgViewY, bgViewWidth, bgViewHeight)];
                    bgView.backgroundColor = kClearColor;
                    bgView.tag = (i+1) * kBgViewTag;
                    
                    [self.view addSubview:bgView];
                    
                    UIView *whiteBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgViewWidth, bgViewHeight)];
                    whiteBgView.backgroundColor = kWhiteColor;
                    whiteBgView.alpha = 0.15;
                    
                    [bgView addSubview:whiteBgView];
                    
                    // 添加一个uiview
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, bgViewHeight)];
                    line.backgroundColor = _colorArray[i];
                    
                    [bgView addSubview:line];
                    
                    // 添加一些控件
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, 10, kScreenWidth, 20)];
                    titleLabel.text = _titleArray[i];
                    titleLabel.font = kNormalFont;
                    titleLabel.textColor = kBlackColor;
                    
                    [bgView addSubview:titleLabel];
                    
                    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bgViewWidth - 30, kSpace, 30, 30)];
                    rightImageView.image = [UIImage imageNamed:_rightImageNameArray[i]];
                    
                    [bgView addSubview:rightImageView];
                    
                    // =========================================
                    
                    _pointViewArray = [[NSMutableArray alloc]init];
                    
                    NSMutableArray * pointValueArray = [NSMutableArray array];
                    
                    for (int j = 0; j < dataArray.count; j++)
                    {
                        PointView * pointView = [PointView aInstance:_titleColorArray[i] center:CGPointMake(bgViewWidth / 2, bgViewHeight / 2)];
                        
                        //                    int pointY = bgViewHeight * 0.2 + (arc4random() % 60 + 30);
                        float pointY = 0.0;
                        float textCount = 0.0;
                        
                        if ([dataArray[j] floatValue] > 0.0)
                        {
                            pointY = bgViewHeight * 0.75 + [dataArray[j] intValue];
                            textCount = [dataArray[j] floatValue];
                        }
                        else
                        {
                            pointY = bgViewHeight;
                            textCount = 0.0;
                        }
                        
                        pointView.center = CGPointMake(j * ((bgViewWidth - 30) / (dataArray.count - 1)) + 15, pointY);
                        
                        [bgView addSubview:pointView];
                        
                        // 添加数字
                        UILabel *countLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointMake(bgViewWidth / 2, bgViewHeight / 2), CGSizeMake(80, 20)}];
                        YunLog(@"---%@", [NSString stringWithFormat:@"%0.1f", textCount]);
                        countLabel.text = [NSString stringWithFormat:@"%.1f", textCount];
                        countLabel.font = kSmallFont;
                        countLabel.textColor = kWhiteColor;
                        countLabel.textAlignment = NSTextAlignmentCenter;
                        countLabel.center = CGPointMake(j * ((bgViewWidth - 30) / (dataArray.count - 1)) + 15, pointY - 10);
                        
                        [bgView addSubview:countLabel];
                        
                        [_pointViewArray addObject:pointView];
                        
                        [pointValueArray addObject:[NSValue valueWithCGPoint:pointView.center]];
                    }
                    
                    NSValue * firstPointValue = pointValueArray.firstObject;
                    
                    _curve = [UIBezierPath bezierPath];
                    [_curve moveToPoint:firstPointValue.CGPointValue];
                    [_curve addBezierThroughPoints:pointValueArray];
                    
                    _shapeLayer = [CAShapeLayer layer];
                    UIColor *color = _colorArray[i];
                    _shapeLayer.strokeColor = color.CGColor;
                    _shapeLayer.fillColor = nil;
                    _shapeLayer.lineWidth = 1.5;
                    _shapeLayer.path = _curve.CGPath;
                    _shapeLayer.lineCap = kCALineCapRound;
                    [bgView.layer addSublayer:_shapeLayer];
                }
            }];
        }
        else
        {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"暂无数据" delay:1.5];
            
            return;
        }
    }
}

@end
