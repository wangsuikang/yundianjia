//
//  RateProductViewController.m
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "RateProductViewController.h"
#import "RateModel.h"
#import "Tool.h"
#import "User.h"
#import "AppDelegate.h"

//library
#import "RSTapRateView.h"
#import "UIButtonForBarButton.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

//category
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+Extend.h"
//Views
#import "UIPlaceHolderTextView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface RateProductViewController () <RSTapRateViewDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

/// 评论模型
@property (nonatomic, strong) NSMutableArray *rateData;

@property (nonatomic, strong) NSDictionary *subOrders;

@property (nonatomic, copy) NSString *orderNo;

@property (nonatomic ,strong) MBProgressHUD *hud;
@end

@implementation RateProductViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    
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

- (instancetype)initWithOrderId:(NSString *)orderId
{
    if (self = [super init]) {
        self.orderID = orderId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = @"商品评价";
    self.navigationItem.titleView = naviTitle;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 25, 25);
    [backBtn setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    backItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.view.backgroundColor = kBackgroundColor;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *detailURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/orders/%@.json",_orderID] params:params];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:detailURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"order detail responseObject rate = %@", responseObject);
        self.orderNo = [[[responseObject objectForKey:@"data"] objectForKey:@"order"] objectForKey:@"no"];
        self.subOrders = [[responseObject objectForKey:@"data"] objectForKey:@"order"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"order detail error：%@", error);
    }];
    

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myResignFirstResponder)];
    [self.view addGestureRecognizer:tap];
}

- (void)myResignFirstResponder
{
    [kApplication sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 创建UI控件
 */
- (void)createUI
{
    CGFloat offset = 20;
    CGFloat width = kScreenWidth - offset * 2;
    UIScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(offset, 0, width, kScreenHeight - 64)];
    scrollView.delegate = self;
    _scrollView = scrollView;
    [scrollView setShowsVerticalScrollIndicator:NO];
    scrollView.backgroundColor = kBackgroundColor;
    
    UILabel *productTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width, 25)];
    productTitle.text = [NSString stringWithFormat:@"订单编号:%@",kNullToString(self.orderNo)];
    productTitle.font = [UIFont fontWithName:kFontBold size:kFontSmallSize];
    [_scrollView addSubview:productTitle];

    // 标记当前布局高度偏移量
    CGFloat currentYOffset = 30;
    
    for(int i = 0;i < self.rateData.count; i++){
        RateModel *model =[self.rateData objectAtIndex:i];

        UIView *wrapper = [[UIView alloc]initWithFrame:CGRectMake(0, currentYOffset, width, 0.4 * kScreenWidth + 230 + 32)];
        
        // 产品描述
        UIView *productView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0.4 * kScreenWidth)];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0.4 * kScreenWidth, 0.4 * kScreenWidth)];
        imageView.contentMode = UIViewContentModeCenter;
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.productIcon] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
        }];
        [productView addSubview:imageView];
        
        UILabel *productDesc = [[UILabel alloc]initWithFrame:CGRectMake(0.4 * kScreenWidth + 8, 0, width - 0.4 * kScreenWidth - 8, 0.4 * kScreenWidth)];
        productDesc.numberOfLines = 0;
        productDesc.text = model.productName;
        productDesc.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
        [productView addSubview:productDesc];
        
        // 分割线
        [wrapper addSubview:[self seperatorWithFrame:CGRectMake(0, 0.4 * kScreenWidth + 8, width, 1)]];
        
        // 产品评分
        UIView *productRank = [[UIView alloc] initWithFrame:CGRectMake(0, 0.4 * kScreenWidth + 17, width, 44)];
        UILabel *productRankLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        productRankLabel.text = @"商品质量:";
        productRankLabel.font = [UIFont fontWithName:kFontBold size:kFontSmallSize];
        [productRank addSubview:productRankLabel];
        
        RSTapRateView *tapRateView = [[RSTapRateView alloc] initWithFrame:CGRectMake(60, 0, width - 68, 44)];
        tapRateView.tag = i;
        tapRateView.delegate = self;
        [productRank addSubview:tapRateView];
        
        // 分割线
        [wrapper addSubview:[self seperatorWithFrame:CGRectMake(0, 0.4 * kScreenWidth + 69, width, 1)]];
        
        // 填写短评
        UIView *productComment = [[UIView alloc] initWithFrame:CGRectMake(0, 0.4 * kScreenWidth + 78, width, 184)];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        commentLabel.text = @"填写短评:";
        commentLabel.center = CGPointMake(width * 0.5, 22);
        commentLabel.font = [UIFont fontWithName:kFontBold size:kFontSmallSize];
        [productComment addSubview:commentLabel];
        
        UIPlaceHolderTextView *commentField = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(64, 44, width - 20, 140)];

        // commentField.borderStyle = UITextBorderStyleNone;
        commentField.center = CGPointMake(width * 0.5, 114);
        commentField.placeholder = @"请填写简单评论";
        commentField.tag = i;
        commentField.delegate = self;
        commentField.layer.borderWidth = 1.0f;
        commentField.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        commentField.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
        commentField.layer.cornerRadius = 2.0f;
        [productComment addSubview:commentField];
        
        [wrapper addSubview:productView];
        [wrapper addSubview:productRank];
        [wrapper addSubview:productComment];
        [scrollView addSubview:wrapper];
        
        // 分割线
        // [wrapper addSubview:[self seperatorWithFrame:CGRectMake(0, 0.4 * kScreenWidth + 186, width, 1)]];

        currentYOffset += 0.4 * kScreenWidth + 186 + 84;
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, currentYOffset, width * 0.5, 44)];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    button.center = CGPointMake(kScreenWidth * 0.5 - 20, currentYOffset +22);
    [scrollView addSubview:button];
    
    [self.view addSubview:scrollView];
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(kScreenWidth - offset * 2, currentYOffset + 44)];
    [self.view layoutSubviews];
}

- (UIView*)seperatorWithFrame:(CGRect)frame
{
    UIView *seperator = [[UIView alloc] initWithFrame:frame];
    seperator.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    return seperator;
}

/**
 返回上一级NavigationController
 */
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

/**
 提交评价
 */
- (void)submit
{
    AppDelegate *appDelegate = kAppDelegate;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    NSString *classURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kProductComment params:@{@"user_session_key" : kNullToString(appDelegate.user.userSessionKey)}];

    NSDictionary *param = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                          @"json_data" : [NSMutableArray new]
                                                                          }
                           ];
    [self.rateData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RateModel *model = (RateModel*) obj;
        
        NSDictionary *dict = @{@"title" : @"略",
                               @"comment" : model.comment == nil ? @"无文字" : model.comment,
                               @"rank" : [NSString stringWithFormat:@"%ld",(long)model.rank],
                               @"product_id" : model.productId,
                               @"order_id" : model.subOrderId,
                               @"product_variant_id" : model.skuId};
        [[param objectForKey:@"json_data"] addObject:dict];
    }];
    
    YunLog(@"dict = %@", param);

    [manager POST:classURL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"success ::order detail responseObject = %@", responseObject);
        if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

            [_hud addSuccessString:@"评价成功" delay:2.0];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kOrderDetailNotificationReload object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@" failure:order detail error = %@", error);
    }];
}

- (void)setSubOrders:(NSDictionary *)subOrders{
    _subOrders = subOrders;
    self.rateData = [NSMutableArray new];

        NSArray *items = [subOrders objectForKey:@"items"];
        for (int i = 0; i < items.count; i++) {
            RateModel *model = [[RateModel alloc] init];
            model.productId = kNullToString([items[i] objectForKey:@"product_id"]);
            model.subOrderId = kNullToString([subOrders objectForKey:@"id"]);
            model.productIcon = kNullToString([items[i] objectForKey:@"icon_url"]);
            model.productName = kNullToString([items[i] objectForKey:@"product_name"]);
            model.skuId = kNullToString([items[i] objectForKey:@"sku_id"]);
            [self.rateData addObject:model];
        }
    
    [self createUI];
}

#pragma mark - RSTapRateViewDelegate -

/**
 打分按钮点回调事件
 
 @param view   对应的打分view
 @param rating 打的分数
 */
- (void)tapDidRateView:(RSTapRateView *)view rating:(NSInteger)rating
{
    NSInteger tag = view.tag;
    RateModel *model = self.rateData[tag];
    model.rank = rating;
}

#pragma mark - UITextViewDelegate -

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger tag = textView.tag;
    RateModel *model = self.rateData[tag];
    model.comment = textView.text;
}

#pragma mark - Keyboard Event -

- (void)keyboardWillShow:(NSNotification *)sender
{
    [self.scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y + [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height * 0.5) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    [self.scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y - [[sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height * 0.5) animated:YES];
}

#pragma mark - FocusTextView -

//- (void)focusTextView:(UITapGestureRecognizer *)sender
//{
//    UIView *view = [sender view];
//    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UITextView class]]) {
//            [obj becomeFirstResponder];
//        }
//    }];
//}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //[self myResignFirstResponder];
}

@end
