//
//  SearchResultsViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "SearchResultsViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Views
#import "UILabelWithLine.h"
#import "SearchTextField.h"

// Classes
#import "CartManager.h"

// Contollers
#import "ProductDetailViewController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"

#define kOrderTypeAsc   @"asc"
#define kOrderTypeDesc  @"desc"

#define kOrderByPrice   @"price"
#define kOrderBySale    @"sale"
#define kOrderByOverall @"overall"
#define kOrderByHot     @"hot"

#define kScopeViewHeight 54

@interface SearchResultsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SearchTextFieldDelegate, UIScrollViewDelegate>

/// 搜索结果排列依据
@property (nonatomic, copy) NSString *orderBy;

/// 搜索类型
@property (nonatomic, copy) NSString *orderType;

/// 搜索到的店铺数组
@property (nonatomic, strong) NSMutableArray *shops;

/// 搜索到得产品数组
@property (nonatomic, strong) NSMutableArray *products;

@property (nonatomic, strong) NSArray *recommendations;

/// 搜索视图的遮盖层
@property (nonatomic, strong) UIView *searchView;

/// 搜索历史视图
@property (nonatomic, strong) UITableView *searchTableView;

/// 搜索TextField
@property (nonatomic, strong) SearchTextField *searchText;

/// 取消搜索按钮
@property (nonatomic, strong) UIButton *searchCancel;

/// 搜索结果视图
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *scopeView;

@property (nonatomic, strong) UIView *buttonContainer;

//@property (nonatomic, strong) FXLabel *searchLabel;

@property (nonatomic, strong) UIView *searchContainer;

@property (nonatomic, strong) AFHTTPRequestOperation *op;

@property (nonatomic, assign) BOOL reloading;

@property (nonatomic, assign) NSInteger refreshCount;

@property (nonatomic, assign) BOOL noMore;

/// 加载视图 （第三方库）
@property (nonatomic, strong) MBProgressHUD *hud;

/// 是否处于加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) int pageNonce;


@property (nonatomic, assign) NSInteger pageMax;

@property (nonatomic, assign) NSInteger pageLimit;

@end

@implementation SearchResultsViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
//        
//        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
//        naviTitle.backgroundColor = [UIColor clearColor];
//        naviTitle.textColor = [UIColor whiteColor];
//        naviTitle.textAlignment = NSTextAlignmentCenter;
//        naviTitle.text = @"搜索结果";
//        
//        self.navigationItem.titleView = naviTitle;
        
        _searchType = kSearchTypeProduct;
        _orderType = kOrderTypeDesc;
        _orderBy = kOrderBySale;
        
        _refreshCount = 1;
        _noMore = NO;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    self.navigationController.navigationBar.translucent = YES;
	
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchTableViewFrameChange:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchTableViewFrameChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[_searchText removeFromSuperview];
    //[_searchCancel removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
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
    
    _products = [NSMutableArray array];
    _shops = [NSMutableArray array];
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
    if (kDeviceOSVersion < 7.0) {
        _searchView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    _searchView.backgroundColor = kBackgroundColor;
    _searchView.hidden = YES;
    
    [self.view addSubview:_searchView];
    
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)
                                                    style:UITableViewStyleGrouped];
    _searchTableView.tag = kSearchTableHistory;
    
    if (kDeviceOSVersion < 7.0) {
        _searchTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    
    UIView *view = [[UIView alloc] initWithFrame:kScreenBounds];
    view.backgroundColor = kBackgroundColor;
    _searchTableView.backgroundView = view;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    
    [_searchView addSubview:_searchTableView];
    
    _scopeView = [[UIView alloc] initWithFrame:CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScopeViewHeight)];
    _scopeView.backgroundColor = COLOR(232, 232, 232, 1);
    _scopeView.hidden = YES;
    
    [self.view addSubview:_scopeView];
    
    _searchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScopeViewHeight)];
    _searchContainer.backgroundColor = kClearColor;
    _searchContainer.hidden = YES;
    
    [_scopeView addSubview:_searchContainer];
    
    UILabel *searchSorry = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, kScreenWidth, kFontNormalSize)];
    searchSorry.tag = 100;
    searchSorry.text = @"很抱歉，没有找到符合条件的商品";
    searchSorry.textAlignment = NSTextAlignmentCenter;
    searchSorry.textColor = [UIColor grayColor];
    searchSorry.font = kSmallFont;
    
//    UIImageView *searchSorry = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 233) / 2, 7, 233, 17)];
//    searchSorry.image = [UIImage imageNamed:@"search_sorry"];
//    searchSorry.backgroundColor = kClearColor;
    
    [_searchContainer addSubview:searchSorry];
    
    UIImageView *searchLight = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 100 - 20 ) / 2, 29, 20, 20)];
    searchLight.image = [UIImage imageNamed:@"search_light"];
    searchLight.backgroundColor = kClearColor;
    
    [_searchContainer addSubview:searchLight];
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(searchLight.frame.origin.x + searchLight.frame.size.width + 10, 24, 100, 30)];
    searchLabel.backgroundColor = kClearColor;
    searchLabel.font = [UIFont fontWithName:kFontFamily size:12];
    searchLabel.text = @"大家都在找 >>";
    searchLabel.textColor = [UIColor orangeColor];
    
    [_searchContainer addSubview:searchLabel];
    
//    _searchLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, 34)];
//    _searchLabel.numberOfLines = 0;
//    _searchLabel.lineSpacing = 0;
//    _searchLabel.font = kSmallFont;
//    _searchLabel.textColor = [UIColor grayColor];
//    _searchLabel.backgroundColor = kClearColor;
//    _searchLabel.hidden = YES;
//    
//    [_scopeView addSubview:_searchLabel];
    
    _buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 20, 34)];
    _buttonContainer.layer.cornerRadius = 6;
    _buttonContainer.layer.masksToBounds = YES;
    _buttonContainer.layer.borderColor = [UIColor orangeColor].CGColor;
    _buttonContainer.layer.borderWidth = 1;
    _buttonContainer.backgroundColor = kClearColor;
    _buttonContainer.hidden = YES;
    
    [_scopeView addSubview:_buttonContainer];
    
    NSArray *typeButtons = @[@"销量↓", @"价格↓"];
    
    for (int i = 0; i < typeButtons.count; i++) {
        CGFloat buttonWidth = (kScreenWidth - 20) / typeButtons.count;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth * i, 0, buttonWidth, 34)];
        button.titleLabel.font = kNormalFont;
        [button setTitle:typeButtons[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(changeOrderBy:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            button.backgroundColor = [UIColor orangeColor];
            button.selected = YES;
        } else {
            button.backgroundColor = [UIColor whiteColor];
            button.selected = NO;
        }
        
        [_buttonContainer addSubview:button];
    }
    
    if ([_searchType isEqualToString:kSearchTypeShop]) {
        _scopeView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, 0);
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _scopeView.frame.origin.y + _scopeView.frame.size.height, kScreenWidth, kScreenHeight - _scopeView.frame.origin.y - _scopeView.frame.size.height)
                                              style:UITableViewStylePlain];
    _tableView.tag = kSearchTableResult;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.contentInset = UIEdgeInsetsZero;
    
    YunLog(@"test_frame = %@", NSStringFromCGRect(_tableView.frame));
    
    [self.view addSubview:_tableView];
    
    [self doSearch:_keyword];
    
    [self createMJRefresh];
    
    _pageNonce = 1;
    
    //自定义titleView
    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    _searchText = [[SearchTextField alloc] initWithFrame:CGRectMake(0, 6, kScreenWidth - 60, 32)];
    _searchText.delegate = self;
    _searchText.searchDelegate = self;
    _searchText.placeholder = @"请输入搜索词";
    _searchText.text = _keyword;
    
    [wrapper addSubview:_searchText];
    
    if ([_searchType isEqualToString:kSearchTypeShop]) {
        UIButton *button = (UIButton *)_searchText.leftView;
        
        _searchType = kSearchTypeShop;
        
        UILabel *label = (UILabel *)[button viewWithTag:TitleLabel];
        label.text = @"商铺";
        
        UIImageView *imageView = (UIImageView *)[button viewWithTag:ArrowImageView];
        imageView.image = [UIImage imageNamed:@"search_up"];
    }
    
    _searchCancel = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 60, 0, 60, 44)];
    _searchCancel.backgroundColor = kClearColor;
    _searchCancel.hidden = YES;
    [_searchCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_searchCancel setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_searchCancel addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    [wrapper addSubview:_searchCancel];
    self.navigationItem.titleView = wrapper;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _tableView.delegate = nil;
}

#pragma mark - Private Functions -

/**
 搜索视图的大小变化是调用
 
 @param noti 收到的通知
 */
- (void)searchTableViewFrameChange:(NSNotification *)noti
{
    NSDictionary *info = [noti userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    YunLog(@"keyboardSize.height = %f", keyboardSize.height);
    
    if (kDeviceOSVersion < 7.0) {
        _searchTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - keyboardSize.height - 60);
    } else {
        _searchTableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - keyboardSize.height);
    }
}

/**
 取消搜索
 */
- (void)cancelSearch
{    
    _searchView.hidden = YES;
    _searchCancel.hidden = YES;
    _tableView.hidden = NO;
    _scopeView.hidden = NO;
    
    if([_searchType isEqualToString:kSearchTypeShop])
    {
        _tableView.hidden = YES;
    }
//    _tableView.hidden = YES;
    
    [_searchText resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    _searchText.frame = CGRectMake(0, 6, kScreenWidth - 60, 32);
    
    [UIView commitAnimations];
}

/**
 清除搜索历史
 */
- (void)cleanSearchHistory
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:nil forKey:kSearchHistory];
    
    [defaults synchronize];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [_hud addSuccessString:@"搜索历史清楚成功" delay:1.0];
    
    _searchTableView.hidden = YES;
    [_searchTableView reloadData];
    
    _searchText.text = @"";
    
    [self cancelSearch];
}

/**
 切换搜索类型
 
 @param sender 点击的按钮
 */
- (void)changeOrderBy:(UIButton *)sender
{
    [_tableView setContentOffset:CGPointZero animated:NO];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    
    UIView *scopeSub = _scopeView.subviews[1];
    for (UIView *view in scopeSub.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [buttonArray addObject:(UIButton *)view];
        }
    }
    
    YunLog(@"buttonArray = %@", buttonArray);
    
    UIButton *button = buttonArray[sender.tag];
    button.backgroundColor = [UIColor orangeColor];
    button.selected = YES;
    
    UIButton *otherButton = buttonArray[sender.tag == 0 ? 1 : 0];
    otherButton.backgroundColor = [UIColor whiteColor];
    otherButton.selected = NO;
    
    if (sender.tag == 0) {
        if ([_orderBy isEqualToString:kOrderBySale])
        {
            _orderType = [_orderType isEqualToString:kOrderTypeAsc] ? kOrderTypeDesc : kOrderTypeAsc;
            [button setTitle:[_orderType isEqualToString:kOrderTypeAsc] ? @"销量↑" : @"销量↓" forState:UIControlStateNormal];
        }
        else
        {
            _orderBy = kOrderBySale;
            if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"销量↑"]) {
                _orderType = kOrderTypeAsc;
            } else {
                _orderType = kOrderTypeDesc;
            }
        }
    } else {
        if ([_orderBy isEqualToString:kOrderByPrice])
        {
            _orderType = [_orderType isEqualToString:kOrderTypeAsc] ? kOrderTypeDesc : kOrderTypeAsc;
            [button setTitle:[_orderType isEqualToString:kOrderTypeAsc] ? @"价格↑" : @"价格↓" forState:UIControlStateNormal];
        }
        else
        {
            _orderBy = kOrderByPrice;
            if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"价格↑"]) {
                _orderType = kOrderTypeAsc;
            } else {
                _orderType = kOrderTypeDesc;
            }
        }
    }
    
    [self doSearch:_searchText.text];
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 点击店铺进入店铺详情界面
 
 @param sender 点击的按钮
 */
- (void)pushShopInfo:(UIButton *)sender
{
    ShopInfoNewController *info = [[ShopInfoNewController alloc] init];
    info.hidesBottomBarWhenPushed = YES;
    
    if (_shops.count > 0) {
        info.code = [_shops[sender.tag] objectForKey:@"code"];
    } else {
        info.code = [_recommendations[sender.tag] objectForKey:@"code"];
    }
    
    [self.navigationController pushViewController:info animated:YES];
}
/*
//- (void)addToCart:(UIButton *)sender
//{
//    NSDictionary *productDic;
//    
//    if (_products.count > 0) {
//        productDic = [_products objectAtIndex:sender.tag];
//    } else {
//        productDic = [_recommendations objectAtIndex:sender.tag];
//    }
//    
//    YunLog(@"productDic = %@", productDic);
//    
//    NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
//    
//    @try {
//        [product setObject:kNullToString([productDic objectForKey:@"name"]) forKey:CartManagerDescriptionKey];
//        [product setObject:kNullToString([productDic objectForKey:@"price"]) forKey:CartManagerPriceKey];
//        [product setObject:kNullToString([[productDic objectForKey:@"sku_id"] stringValue]) forKey:CartManagerSkuIDKey];
//        [product setObject:kNullToString([productDic objectForKey:@"icon"]) forKey:CartManagerImageURLKey];
//        
//        if ([[productDic objectForKey:@"is_limit_quantity"] integerValue] == 0) {
//            [product setObject:@"1" forKey:CartManagerCountKey];
//            [product setObject:@"1" forKey:CartManagerMinCountKey];
//            [product setObject:@"0" forKey:CartManagerMaxCountKey];
//        } else {
//            NSString *min = kNullToString([productDic objectForKey:@"minimum_quantity"]);
//            
//            if ([min integerValue] == 0) {
//                min = @"1";
//            }
//            
//            [product setObject:min forKey:CartManagerCountKey];
//            [product setObject:min forKey:CartManagerMinCountKey];
//            [product setObject:kNullToString([productDic objectForKey:@"limited_quantity"]) forKey:CartManagerMaxCountKey];
//        }
//    }
//    @catch (NSException *exception) {
//        YunLog(@"search add to cart exception = %@", exception);
//    }
//    @finally {
//        
//    }
//    
//    [[CartManager defaultCart] addProduct:product
//                                  success:^{
//                                      UIViewController *cartVC = [self.tabBarController.viewControllers objectAtIndex:1];
//                                      cartVC.tabBarItem.badgeValue = [[CartManager defaultCart] productCount];
//
//                                  }
//                                  failure:^(int count){

//                                  }
//     ];
//    
//    NSDictionary *params;
//    
//    @try {
//        params = @{
//                   @"uuid":[Tool getUniqueDeviceIdentifier],
//                   @"product_name":kNullToString([productDic objectForKey:@"name"]),
//                   @"product_id":kNullToString([productDic objectForKey:@"sku_id"])
//                   };
//    }
//    @catch (NSException *exception) {
//        YunLog(@"add to cart exception = %@", exception);
//        
//        params = @{};
//    }
//    @finally {
//        
//    };
//    
//    [TalkingData trackEvent:@"商品加入购物车" label:@"商户首页" parameters:params];
//}
*/

/**
 确认搜索时调用
 
 @param searchText 搜索关键字
 */
- (void)doSearch:(NSString *)searchText
{    
    if (!searchText || [searchText isEqualToString:@""]) {
        return;
    }
    
    [_tableView  setHidden:NO];
    
    [_tableView setFooterHidden:NO];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力搜索中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"type"                    :   kNullToString(_searchType),
                             @"keyword"                 :   kNullToString(searchText),
                             @"order_by"                :   kNullToString(_orderBy),
                             @"order_type"              :   kNullToString(_orderType),
                             @"page"                    :   @"1",
                             @"per"                     :   kIsiPhone ? @"8" : @"10"};
    
//    NSString *searchURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kSearchURL params:params];
    
    NSString *searchURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kSearchURL params:params];
    
    YunLog(@"searchURL = %@", searchURL);
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:searchURL
                                                                                parameters:nil
                                                                                     error:nil];
    request.timeoutInterval = 30;
    
    _op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    _op.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak typeof(self) weakSelf = self;
    
    [_op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject = %@", responseObject);
         
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            weakSelf.noMore = NO;
            weakSelf.refreshCount = 1;
            
            if ([weakSelf.searchType isEqualToString:kSearchTypeShop]) {
                weakSelf.shops = [NSMutableArray arrayWithArray:[[responseObject objectForKey:@"data"] objectForKey:@"shops"]];
                weakSelf.recommendations = kNullToArray([[[responseObject objectForKey:@"data"] objectForKey:@"recommendations"] objectForKey:@"shops"]);
                
                weakSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
               
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.5];

                if (weakSelf.shops.count > 0) {
                    weakSelf.scopeView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, 0);
                } else {
                    weakSelf.scopeView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScopeViewHeight);
                    weakSelf.scopeView.hidden = NO;
                    
                    weakSelf.buttonContainer.hidden = YES;
                    
                    weakSelf.searchContainer.hidden = NO;
                    
                    UILabel *searchSorry = (UILabel *)[weakSelf.searchContainer viewWithTag:100];
                    
                    searchSorry.text = @"很抱歉，没有找到符合条件的商铺";
                }

                weakSelf.tableView.frame = CGRectMake(0, kCustomNaviHeight + weakSelf.scopeView.frame.size.height, kScreenWidth, kScreenHeight - 44 - 20 - weakSelf.scopeView.frame.size.height);

                [UIView commitAnimations];
                
                [weakSelf.tableView setContentOffset:CGPointMake(0, 0)];
            } else {
                weakSelf.products = [NSMutableArray arrayWithArray:[[responseObject objectForKey:@"data"] objectForKey:@"products"]];
                weakSelf.recommendations = kNullToArray([[[responseObject objectForKey:@"data"] objectForKey:@"recommendations"] objectForKey:@"products"]);
                
                weakSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
              
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.5];

                if (weakSelf.products.count > 0) {
                    weakSelf.scopeView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScopeViewHeight);
                    weakSelf.scopeView.hidden = NO;
                    
                    weakSelf.searchContainer.hidden = YES;
                    
                    weakSelf.buttonContainer.hidden = NO;
                } else {
                    weakSelf.scopeView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScopeViewHeight);
                    weakSelf.scopeView.hidden = NO;
                    
                    weakSelf.buttonContainer.hidden = YES;
                    
                    weakSelf.searchContainer.hidden = NO;
                    
                    UILabel *searchSorry = (UILabel *)[weakSelf.searchContainer viewWithTag:100];
                    searchSorry.text = @"很抱歉，没有找到符合条件的商品";
                    
                    [weakSelf.tableView setFooterHidden:YES];
                }

                weakSelf.tableView.frame = CGRectMake(0, kCustomNaviHeight + weakSelf.scopeView.frame.size.height, kScreenWidth, kScreenHeight - 44 - 20 - weakSelf.scopeView.frame.size.height);
                [UIView commitAnimations];
            }
            
            [weakSelf.tableView reloadData];
            
            [weakSelf.tableView headerEndRefreshing];
            
            if (weakSelf.products.count >= 8 || weakSelf.shops.count >= 8) {
                
            }
            
            [weakSelf.hud hide:YES];
        } else {
            [weakSelf.hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        weakSelf.scopeView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScopeViewHeight);
        weakSelf.scopeView.hidden = NO;
        weakSelf.buttonContainer.hidden = YES;
        weakSelf.searchContainer.hidden = NO;
        
        [weakSelf.tableView headerEndRefreshing];
        
        if (![weakSelf.op isCancelled]) {
            YunLog(@"search error = %@", error);

            [weakSelf.hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            
            [weakSelf.tableView  setHidden:YES];
        }
    }];
    
    [_op start];
    
    _pageNonce = 1;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kSearchTableHistory) {
        return @"历史记录";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == kSearchTableHistory) {
        return 30;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView.tag == kSearchTableHistory) {
        return 81;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 81)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
//    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 41, kScreenWidth, 40)];

    if (kDeviceOSVersion < 7.0) {
        button.backgroundColor = kClearColor;
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        cancel.backgroundColor = kClearColor;
//        [cancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        button.backgroundColor = [UIColor orangeColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        cancel.backgroundColor = [UIColor orangeColor];
//        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
    [button setTitle:@"清除搜索历史" forState:UIControlStateNormal];
//    [cancel setTitle:@"取消搜索" forState:UIControlStateNormal];

    [button addTarget:self action:@selector(cleanSearchHistory) forControlEvents:UIControlEventTouchUpInside];
//    [cancel addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];

    [wrapper addSubview:button];
//    [wrapper addSubview:cancel];
    return wrapper;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kSearchTableHistory) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        return [[defaults objectForKey:kSearchHistory] count];
    } else {
        if ([_searchType isEqualToString:kSearchTypeShop]) {
            return _shops.count + _recommendations.count;
        } else {
            return _products.count + _recommendations.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kSearchTableResult) {
        if ([_searchType isEqualToString:kSearchTypeShop]) {
            return 170;
        } else {
            return 100;
        }
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (tableView.tag == kSearchTableHistory) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = [defaults objectForKey:kSearchHistory][indexPath.row];
    } else {
        if ([_searchType isEqualToString:kSearchTypeShop]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *view = [[UIView alloc] initWithFrame:cell.frame];
            view.backgroundColor = [UIColor whiteColor];
            
            cell.backgroundView = view;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 300) / 2, 10, 300, 150)];
//            button.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
//            button.layer.shadowOpacity = 1.0;
//            button.layer.shadowRadius = 5.0;
//            button.layer.shadowOffset = CGSizeMake(0, 1);
//            button.clipsToBounds = NO;
//            button.backgroundColor = COLOR(245, 245, 245, 1);
            button.tag = indexPath.row;
            [button addTarget:self action:@selector(pushShopInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:button];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
            imageView.contentMode = UIViewContentModeCenter;
            [imageView addBorderWithDirection:AddBorderDirectionLeft | AddBorderDirectionTop | AddBorderDirectionRight];
            
            @try {
                __weak UIImageView *_imageView = imageView;
				_imageView.contentMode = UIViewContentModeCenter;
                
                NSURLRequest *request;
                
                if (_shops.count > 0) {
                    request = [NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([_shops[indexPath.row] objectForKey:@"image_url"])]];
                } else {
                    request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_recommendations[indexPath.row] objectForKey:@"image_url"]]];
                }
                
                [_imageView setImageWithURLRequest:request
                                 placeholderImage:[UIImage imageNamed:@"default_image"]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                              _imageView.image = image;
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    
                                          }];
            }
            @catch (NSException *exception) {
                imageView.image = [UIImage imageNamed:@"default_image"];
                
                YunLog(@"load search shop exception%@", exception);
            }
            @finally {
                
            }
            
            [button addSubview:imageView];
            
            UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, button.frame.size.width, 30)];
            labelView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            labelView.layer.borderWidth = 1;
            
            [button addSubview:labelView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 120, button.frame.size.width - 10, 30)];
            label.backgroundColor = kClearColor;
            label.font = [UIFont fontWithName:kFontFamily size:14];
            
            @try {
                if (_shops.count > 0) {
                    label.text = kNullToString([_shops[indexPath.row] objectForKey:@"name"]);
                } else {
                    label.text = kNullToString([_recommendations[indexPath.row] objectForKey:@"name"]);
                }
                
            }
            @catch (NSException *exception) {
                label.text = @"";
            }
            @finally {
                
            }
            
            [button addSubview:label];
        } else {
            if (kDeviceOSVersion >= 7.0) {
                cell.separatorInset = UIEdgeInsetsZero;
            }
            
            cell.backgroundColor = COLOR(245, 245, 245, 1);
            
            NSArray *products;
            
            if (_products.count > 0) {
                products = [NSArray arrayWithArray:_products];
            } else {
                products = [NSArray arrayWithArray:_recommendations];
            }
            
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 108, 80)];
//            [imageView setImageWithURL:[NSURL URLWithString:[[products objectAtIndex:indexPath.row] objectForKey:@"icon"]]
//                      placeholderImage:[UIImage imageNamed:@"default_image"]];
//            
//            [cell.contentView addSubview:imageView];
            
            
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 108, 80)];
            
            imageView.contentMode = UIViewContentModeCenter;
            
            __weak UIImageView *_imageView = imageView;
            
            [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"large_icon_200_200"])]]
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                          _imageView.image = image;
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"large_icon_218_218"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                          _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                      }];
            
            [cell.contentView addSubview:imageView];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 12, kScreenWidth - 138, 14)];
            nameLabel.backgroundColor = kClearColor;
            nameLabel.font = [UIFont fontWithName:kFontFamily size:14];
            nameLabel.text = kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"name"]);
            nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            [cell.contentView addSubview:nameLabel];
            
            UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 30, kScreenWidth - 138, 14)];
            subLabel.backgroundColor = kClearColor;
            subLabel.font = kSmallFont;
            subLabel.text = kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"subtitle"]);
            subLabel.textColor = [UIColor lightGrayColor];
            
            [cell.contentView addSubview:subLabel];
            
            NSString *price = [NSString stringWithFormat:@"￥%@", kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"price"])];
            
            CGSize priceSize = [price sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
            
            UILabel *nowPrice = [[UILabel alloc] initWithFrame:CGRectMake(128, 47, priceSize.width, 20)];
            nowPrice.backgroundColor = kClearColor;
            nowPrice.textColor = [UIColor orangeColor];
            nowPrice.font = kBigFont;
            nowPrice.text = price;
            
            [cell.contentView addSubview:nowPrice];
            
            NSString *marketPrice = [NSString stringWithFormat:@"￥%@", kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"market_price"])];
            
            float priceFloat = [[[products objectAtIndex:indexPath.row] objectForKey:@"price"] floatValue];
            float marketFloat = [[[products objectAtIndex:indexPath.row] objectForKey:@"market_price"] floatValue];
            
            if (priceFloat < marketFloat) {
                CGSize size = [marketPrice sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
                
                UILabelWithLine *lastPrice = [[UILabelWithLine alloc] initWithFrame:CGRectMake(5 + nowPrice.frame.origin.x + nowPrice.frame.size.width, 47, size.width, 20)];
                lastPrice.backgroundColor = kClearColor;
                lastPrice.font = kNormalFont;
                lastPrice.text = marketPrice;
                lastPrice.textColor = [UIColor lightGrayColor];
                
                [cell.contentView addSubview:lastPrice];
            }
            
            UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 75, 150, 15)];
            soldLabel.backgroundColor = kClearColor;
            soldLabel.textColor = [UIColor lightGrayColor];
            soldLabel.font = [UIFont fontWithName:kFontFamily size:14];
            
            if ([[products[indexPath.row] objectForKey:@"inventory_quantity"] integerValue] > 0) {
                soldLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([[products objectAtIndex:indexPath.row] objectForKey:@"sales_quantity"])];
            } else {
                soldLabel.text = @"已售完";
                soldLabel.textColor = [UIColor redColor];
            }
            
            [cell.contentView addSubview:soldLabel];
            
//            if ([[products[indexPath.row] objectForKey:@"inventory_quantity"] integerValue] > 0) {
//                UIButton *cart = [[UIButton alloc] initWithFrame:CGRectMake(228, 68, 82, 22)];
//                cart.tag = indexPath.row;
//                cart.layer.borderWidth = 1;
//                cart.layer.borderColor = [UIColor orangeColor].CGColor;
//                cart.layer.cornerRadius = 6;
//                cart.layer.masksToBounds = YES;
//                cart.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//                [cart setTitle:@"加入购物车" forState:UIControlStateNormal];
//                [cart setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//                cart.titleLabel.font = kSmallFont;
//                
//                [cart addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
//                
//                [cell.contentView addSubview:cart];
//            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kSearchTableResult) {
        if (_shops.count > 0) {

        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            ProductDetailViewController *detail = [[ProductDetailViewController alloc] init];
            detail.hidesBottomBarWhenPushed = YES;
            
            if (_products.count > 0) {
                detail.productCode = kNullToString([_products[indexPath.row] objectForKey:@"code"]);
                detail.shopCode = kNullToString([_products[indexPath.row] objectForKey:@"shop_code"]);
//                detail.productID = [[_products objectAtIndex:indexPath.row] objectForKey:@"sku_id"];
            } else {
                detail.productCode = kNullToString([_recommendations[indexPath.row] objectForKey:@"code"]);
                detail.shopCode = kNullToString([_recommendations[indexPath.row] objectForKey:@"shop_code"]);
//                detail.productID = [[_recommendations objectAtIndex:indexPath.row] objectForKey:@"sku_id"];
            }
            
            [self.navigationController pushViewController:detail animated:YES];
        }
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        _searchText.text = [defaults objectForKey:kSearchHistory][indexPath.row];
        [self textFieldShouldReturn:_searchText];
//        [self pushToSearchVC:[defaults objectForKey:kSearchHistory][indexPath.row]];
    }
}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    //textField.frame = CGRectMake(10, 6, kScreenWidth - 70, 32);
    [UIView commitAnimations];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *histories = [defaults objectForKey:kSearchHistory];
    
    if (histories.count > 0) {
        _searchTableView.hidden = NO;
    } else {
        _searchTableView.hidden = YES;
    }
    
    [_searchTableView reloadData];
    
    _searchCancel.hidden = NO;
    _tableView.hidden = YES;
    _searchView.hidden = NO;
    _scopeView.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    YunLog(@"textField = %@", textField.text);
    
    [textField resignFirstResponder];
    
    [self cancelSearch];
    
    if ([textField.text isEqualToString:@""]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"请输入搜索词" delay:2.0];
        
        return NO;
    }
    
    _keyword = textField.text;
    
    [_products removeAllObjects];
    [_shops removeAllObjects];
    
    _refreshCount = 1;
    _noMore = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *searchHistory = [NSMutableArray arrayWithArray:[defaults objectForKey:kSearchHistory]];
    
    for (NSString *history in searchHistory) {
        if ([textField.text isEqualToString:history]) {
            [searchHistory removeObject:history];
            
            break;
        }
    }
    
    [searchHistory insertObject:textField.text atIndex:0];
    
    [defaults setObject:searchHistory forKey:kSearchHistory];
    
    [defaults synchronize];
    
    YunLog(@"kSearchHistory = %@", [defaults objectForKey:kSearchHistory]);
    
    [self doSearch:textField.text];
    
    return YES;
}

#pragma mark - SearchTextFieldDelegate -

- (void)searchTextFieldToggleType:(SearchTextField *)searchTextField
{
    UIButton *button = (UIButton *)searchTextField.leftView;
    
    if ([_searchType isEqualToString:kSearchTypeProduct]) {
        _searchType = kSearchTypeShop;
        
        UILabel *label = (UILabel *)[button viewWithTag:TitleLabel];
        label.text = @"商铺";
        _scopeView.hidden = YES;
        _searchContainer.hidden = YES;
        
        YunLog(@"_searchtableView.framr = %@", NSStringFromCGRect(_searchTableView.frame));
        YunLog(@"_tableView.framr = %@", NSStringFromCGRect(_tableView.frame));
        
        UIImageView *imageView = (UIImageView *)[button viewWithTag:ArrowImageView];
        imageView.image = [UIImage imageNamed:@"search_up"];
    } else {
        _searchType = kSearchTypeProduct;
        
        UILabel *label = (UILabel *)[button viewWithTag:TitleLabel];
        label.text = @"商品";
        _scopeView.hidden = NO;
        _searchContainer.hidden = NO;
        
        YunLog(@"_searchtableView.framr = %@", NSStringFromCGRect(_searchTableView.frame));
        YunLog(@"_tableView.framr = %@", NSStringFromCGRect(_tableView.frame));
        
        UIImageView *imageView = (UIImageView *)[button viewWithTag:ArrowImageView];
        imageView.image = [UIImage imageNamed:@"search_down"];
    }
    
    YunLog(@"searchTextField.text = %@", searchTextField.text);
    
    _keyword = searchTextField.text;
    
    [_products removeAllObjects];
    [_shops removeAllObjects];
    
    _refreshCount = 1;
    _noMore = NO;
    _reloading = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *searchHistory = [NSMutableArray arrayWithArray:[defaults objectForKey:kSearchHistory]];
    
    for (NSString *history in searchHistory) {
        if ([searchTextField.text isEqualToString:history]) {
            [searchHistory removeObject:history];
            
            break;
        }
    }
    
    [searchHistory insertObject:searchTextField.text atIndex:0];
    
    [defaults setObject:searchHistory forKey:kSearchHistory];
    
    [defaults synchronize];
    
    YunLog(@"kSearchHistory = %@", [defaults objectForKey:kSearchHistory]);
    
    [self doSearch:searchTextField.text];
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
    
    [self doSearch:_keyword];
}

/**
 下拉加载更多响应方法
 */
- (void)footerRereshing
{
    if (_isLoading == YES) return;
    
    _pageNonce ++;
    
    [self getNextPageView];
}

/**
 下拉加载更多搜索结果
 */
- (void)getNextPageView
{
    [_tableView  setHidden:NO];
    
    _isLoading = YES;
    
    if (_products.count >= 8 && !_noMore) {        
//        NSInteger rc = _refreshCount;
//        rc += 1;
        
        AppDelegate *appDelegate = kAppDelegate;
        
        NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                                 @"type"                    :   kNullToString(_searchType),
                                 @"keyword"                 :   kNullToString(_keyword),
                                 @"order_by"                :   kNullToString(_orderBy),
                                 @"order_type"              :   kNullToString(_orderType),
                                 @"page"                    :   [NSString stringWithFormat:@"%ld", (long)_pageNonce],
                                 @"per"                     :   kIsiPhone ? @"8" : @"10"};
        
        NSString *searchURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kSearchURL params:params];
        
        YunLog(@"refresh searchURL = %@", searchURL);
        
        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                     URLString:searchURL
                                                                                    parameters:nil
                                                                                         error:nil];
        
        _op = nil;
        _op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        _op.responseSerializer = [AFJSONResponseSerializer serializer];
        
        __weak typeof(self) weakSelf = self;
        
        [_op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            weakSelf.reloading = NO;
            
            YunLog(@"responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                NSArray *newProducts = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                if (newProducts.count > 0) {
                    weakSelf.products = [NSMutableArray arrayWithArray:[weakSelf.products arrayByAddingObjectsFromArray:newProducts]];
                    
                    [weakSelf.tableView reloadData];
                    
                    weakSelf.refreshCount += 1;
                    
                    if (newProducts.count < 8) {
                        weakSelf.noMore = YES;
                        weakSelf.isLoading = NO;
                        weakSelf.tableView.footerHidden = NO;
                        
                        [weakSelf.tableView footerEndRefreshing];
                    } else {
                        weakSelf.isLoading = NO;
                        weakSelf.tableView.footerHidden = NO;

                        [weakSelf.tableView footerEndRefreshing];
                    }
                } else {
                    weakSelf.noMore = YES;
                    weakSelf.isLoading = NO;
                    weakSelf.tableView.footerHidden = YES;
                    
                    [weakSelf.tableView footerEndRefreshing];

                }
            } else {
                weakSelf.isLoading = NO;
                weakSelf.tableView.footerHidden = NO;

                weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view.window animated:YES];
                [weakSelf.hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            weakSelf.reloading = NO;
            weakSelf.isLoading = NO;
            
            if (![weakSelf.op isCancelled]) {
                YunLog(@"search error = %@", error);
                weakSelf.isLoading = NO;
                weakSelf.tableView.footerHidden = NO;
                
                weakSelf.hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view.window animated:YES];
                [weakSelf.hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
            }
        }];
        
        [_op start];
    } else {
        _reloading = NO;
        _isLoading = NO;
        _tableView.footerHidden = YES;
        
        [_tableView footerEndRefreshing];
        
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [_hud addSuccessString:@"没有更多了哟~" delay:1];
    }
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    
    YunLog(@"%f,%f, %f",point.y ,(scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 3),(scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 3));
    
    if ( point.y > (scrollView.contentSize.height - scrollView.bounds.size.height) && (scrollView.contentSize.height - scrollView.bounds.size.height) > 0) {
        [self footerRereshing];
    }
}
@end
