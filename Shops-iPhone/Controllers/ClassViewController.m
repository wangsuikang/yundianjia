//
//  ClassViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/6/15.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ClassViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Class
#import "ClassModel.h"
#import "CategoryModel.h"
#import "CateDetailModel.h"

// Categories
#import "NSString+Tools.h"

// Controllers
#import "ProductRevelationController.h"

#define kLeftSelectViewWidth 2

#define kSpaceWidth 10
#define kClearance 7.5

#define kTopTitleLabelHeight 32

#define kLeftScrollViewWidth 90
#define kLeftScrollViewHeight 55
#define kRightBtnHeight 30

#define kRightBtnWidth (((kScreenWidth - kLeftScrollViewWidth - kClearance) - (3 * kClearance)) / 3)

@interface ClassViewController ()

/// 存放classModel模型数据数组
@property (nonatomic, strong) NSMutableArray *dataResource;

/// 存放categories模型数据
@property (nonatomic, strong) NSMutableArray *categoreResource;

/// 存放分类详情数据
@property (nonatomic, strong) NSMutableArray *cateDetailResource;

/// 左边滚动条
@property (nonatomic, strong) UIScrollView *leftScrollView;

/// 右边展示视图
@property (nonatomic, strong) UIScrollView *rightScrollView;

///  默认选中按钮
@property (nonatomic, strong) UIButton *selectedBtn;

/// 计算高度
@property (nonatomic, assign) CGFloat overHeight;

/// 右边按钮模块中高度最大的按钮的高度
@property (nonatomic, assign) CGFloat rightBtnMaxHeight;
/// 第三方库的引入
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.overHeight = 0;
    
    _dataResource = [NSMutableArray array];
    _categoreResource = [NSMutableArray array];
    _cateDetailResource = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getDataResource];
}

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
        naviTitle.text = @"分类";
        
        self.navigationItem.titleView = naviTitle;
        
        self.tabBarItem.image = [[UIImage imageNamed:@"class_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"class_tab_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem.title = @"分类";
        
    }
    return self;
}

#pragma mark - View Cycle - 

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    _leftScrollView.frame = CGRectMake(0, 0, kLeftScrollViewWidth, kScreenHeight);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

#pragma mark - getDataResource -

/**
 获取数据源
 */
- (void)getDataResource
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    NSString *classURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kProductCatefories params:nil];
    YunLog(@"classURL = %@",classURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:classURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
        
        if ([code isEqualToString:kSuccessCode]) {
            
            NSArray *dataArray = [[responseObject objectForKey:@"data"] objectForKey:@"product_categories"];
            
            for (NSDictionary *dict in dataArray)
            {
                ClassModel *classModel = [[ClassModel alloc] init];
                [classModel setValuesForKeysWithDictionary:dict];
                // 获取模型左侧总数据
                [self.dataResource addObject:classModel];
            }
            
            for (int i = 0; i < self.dataResource.count; i++)
            {
                ClassModel *classModel = self.dataResource[i];
                
                NSDictionary *classDict = classModel.children;
                NSArray *classArray = classDict[@"product_categories"];
                
                NSMutableArray *tampArray = [NSMutableArray array];
                for (NSDictionary *categoryDict in classArray)
                {
                    CategoryModel *categoryModel = [[CategoryModel alloc] init];
                    [categoryModel setValuesForKeysWithDictionary:categoryDict];
                    
                    [tampArray addObject:categoryModel];
                }
                
                [self.categoreResource addObject:tampArray];
            }
        }
        
        [self createUI];
        
        [_hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"banner list error = %@", error);
        [_hud addErrorString:@"获取数据失败，请检查网络" delay:2.0];
    }];
}

#pragma mark - Create UI -

/**
 创建leftScrollView视图，添加对应的按钮和点击事件
 */
- (void)createUI
{
    // 添加左边滚动图
    _leftScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kLeftScrollViewWidth, kScreenHeight - kCustomNaviHeight - 48)];
    
    _leftScrollView.contentSize = CGSizeMake(kLeftScrollViewWidth, kLeftScrollViewHeight * self.dataResource.count);
    _leftScrollView.backgroundColor = COLOR(233, 233, 233, 1);
    _leftScrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_leftScrollView];
    
    // 添加左边分类模块视图
    CGFloat leftViewX  = 0;
    CGFloat leftViewW  = kLeftScrollViewWidth;
    CGFloat leftViewH  = kLeftScrollViewHeight;
    
    for (int i = 0; i < self.dataResource.count; i++) {
        CGFloat leftViewY  = 0 + (kLeftScrollViewHeight * i);
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(leftViewX, leftViewY, leftViewW, leftViewH)];
        leftView.backgroundColor = COLOR(233, 233, 233, 1);
        
        if (i == 0) {
            YunLog(@"_leftView.frame = %@",NSStringFromCGRect(leftView.frame));
        }
        
        [_leftScrollView addSubview:leftView];
        
        // 获取数据
        ClassModel *classModel = self.dataResource[i];
        
        // 创建左边的橘色选中标记， 选中的时候是可见的， 一般情况下隐藏
        UIView *leftSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLeftSelectViewWidth, leftViewH)];
        leftSelectView.backgroundColor = COLOR(250, 158, 68, 1);
        leftSelectView.tag = 1000 + i;
        leftSelectView.hidden = YES;
        
        [leftView addSubview:leftSelectView];
        
        // 添加点击按钮
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(kLeftSelectViewWidth, 0, leftViewW - kLeftSelectViewWidth, kLeftScrollViewHeight)];
        leftBtn.tag = 100 + i;
        leftBtn.titleLabel.contentMode = NSTextAlignmentCenter;
        [leftBtn setTitle:classModel.name forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [leftBtn setTitleColor:COLOR(40, 40, 40, 1) forState:UIControlStateNormal];
        
        [leftBtn addTarget:self action:@selector(selectedLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [leftView addSubview:leftBtn];
        
        if (i == 0)
        {
            self.selectedBtn.selected = YES;
            self.selectedBtn = leftBtn;
            
            [leftBtn setTitleColor:COLOR(250, 158, 68, 1) forState:UIControlStateNormal];
            leftSelectView.hidden = NO;
            leftView.backgroundColor = COLOR(255, 255, 255, 1);
            
            [self createRightUI:(leftBtn.tag - 100)];
        }
    }
}

/**
 根据点击左边不同的对象，创建对应的右边视图
 
 @param index 点击对象对应的标识
 */
- (void)createRightUI:(NSInteger)index
{
    // 添加右边滚动条
    _rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kLeftScrollViewWidth + kClearance, 64, kScreenWidth - kLeftScrollViewWidth - kClearance, kScreenHeight - 64 - 48)];
    _rightScrollView.backgroundColor = [UIColor whiteColor];
    _rightScrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_rightScrollView];
    
    // 获取数据
    NSArray *categoryArray = self.categoreResource[index];
    
    for (int i = 0; i < categoryArray.count; i++)
    {
        CategoryModel *categoryModel = categoryArray[i];
        
        NSDictionary *cateDetailDict = categoryModel.children;
        
        NSArray *cateDetailArray = cateDetailDict[@"product_categories"];
        
        NSMutableArray *cateTampDetailArray = [NSMutableArray array];
        
        for(NSDictionary *cateTampDetailDict in cateDetailArray)
        {
            CateDetailModel *cateDetailModel = [[CateDetailModel alloc] init];
            [cateDetailModel setValuesForKeysWithDictionary:cateTampDetailDict];
            
            [cateTampDetailArray addObject:cateDetailModel];
        }
        
        [self.cateDetailResource addObject:cateTampDetailArray];
        
        // 添加标题Label 和 分类信息视图
        CGFloat topTitleLabelY = 0 + self.overHeight;
        
        UILabel *topTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topTitleLabelY, _rightScrollView.bounds.size.width, kTopTitleLabelHeight)];
        
        topTitleLabel.text = categoryModel.name;
        topTitleLabel.textColor = [UIColor colorWithRGBHex:0xfa9e44];
        topTitleLabel.font = [UIFont systemFontOfSize:12];
        
        [_rightScrollView addSubview:topTitleLabel];
        
        // 计算单元快里面字体最多的按钮的高度
        for (int k = 0; k < cateTampDetailArray.count; k++) {
            CateDetailModel *cateDetailModel = cateTampDetailArray[k];
            _rightBtnMaxHeight = 0;
            CGFloat height = [cateDetailModel.name sizeWithFont:[UIFont systemFontOfSize:12] size:CGSizeMake(kRightBtnWidth, CGFLOAT_MAX)].height;
            
            if (height > _rightBtnMaxHeight) {
                CGFloat temp = height;
                height = _rightBtnMaxHeight;
                _rightBtnMaxHeight = temp;
            }
        }
        
        YunLog(@"max - %f",_rightBtnMaxHeight);
        // 添加分类按钮标签
        for (int j = 0; j < cateTampDetailArray.count; j++)
        {
            CateDetailModel *cateDetailModel = cateTampDetailArray[j];
            
            // 添加分类详细按钮
            CGFloat rightBtnW = kRightBtnWidth;
            CGFloat rightBtnH = _rightBtnMaxHeight + kSpaceWidth * 2;
            CGFloat rightBtnX = 0 + ((rightBtnW + kClearance) * (j % 3));
            CGFloat rightBtnY = CGRectGetMaxY(topTitleLabel.frame) + (rightBtnH + kSpaceWidth) * (j / 3);
            
            UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(rightBtnX, rightBtnY, rightBtnW, rightBtnH)];
            
            rightBtn.tag = [cateDetailModel.id integerValue];
            rightBtn.backgroundColor = COLOR(233, 233, 233, 1);
            rightBtn.titleLabel.numberOfLines = 0;
            rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            [rightBtn setTitle:cateDetailModel.name forState:UIControlStateNormal];
            [rightBtn setTitleColor:COLOR(40, 40, 40, 1) forState:UIControlStateNormal];
            
            [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [_rightScrollView addSubview:rightBtn];
            
            if (j == cateTampDetailArray.count - 1) {
                self.overHeight = CGRectGetMaxY(rightBtn.frame);
            }
            
            if (i == categoryArray.count - 1 && j == cateTampDetailArray.count - 1) {
                self.overHeight = CGRectGetMaxY(rightBtn.frame) + kSpaceWidth;
            }
        }
    }
    
    if (self.overHeight > kScreenHeight)
    {
        _rightScrollView.contentSize = CGSizeMake(_rightScrollView.bounds.size.width, self.overHeight);
    }
    else
    {
        _rightScrollView.contentSize = CGSizeMake(_rightScrollView.bounds.size.width, kScreenHeight + kSpaceWidth);
    }
}

#pragma mark - Btn Click -

/**
 左边视图按钮点击事件处理
 
 @param btn 被点击按钮
 */
- (void)selectedLeftBtnClick:(UIButton *)btn
{
    [_rightScrollView removeFromSuperview];
    _rightScrollView = nil;
    
    [self.cateDetailResource removeAllObjects];
    self.cateDetailResource = nil;
    
    self.overHeight = 0;
    
    // 未选中的View恢复原来的样子
    UIView *leftSelView = (UIView *)[self.selectedBtn superview];
    leftSelView.backgroundColor = COLOR(233, 233, 233, 1);
    [self.selectedBtn setTitleColor:COLOR(40, 40, 40, 1) forState:UIControlStateNormal];
    UIView *leftSelectedView = (UIView *)[leftSelView viewWithTag:(1000 + (self.selectedBtn.tag - 100))];
    leftSelectedView.hidden = YES;
    
    // 原先的按钮 取消选中状态
    self.selectedBtn.selected = NO;
    
    // 设置选中的view
    btn.selected = YES;
    
    self.selectedBtn = btn;
    
    if (self.selectedBtn.selected == YES) {
        [btn setTitleColor:COLOR(250, 158, 68, 1) forState:UIControlStateNormal];
        UIView *leftView = (UIView *)btn.superview;
        
        UIView *leftSelectView = [leftView viewWithTag:(1000 + (btn.tag - 100))];
        leftSelectView.hidden = NO;
        leftView.backgroundColor = COLOR(255, 255, 255, 1);
        
        [self createRightUI:(btn.tag - 100)];
    }
}

#pragma - rightBtnClick -

/**
 右边视图点击事件处理方法，进入对应的产品展示页面     
 
 @param rightBtn 点击的按钮
 */
- (void)rightBtnClick:(UIButton *)rightBtn
{
    ProductRevelationController *productVC = [[ProductRevelationController alloc] init];
    productVC.titleName = [rightBtn currentTitle];
    productVC.productId = rightBtn.tag;
    productVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:productVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
