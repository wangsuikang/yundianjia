//
//  DistributeGroupProductViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "DistributorGroupProductViewController.h"

//  Controllers
#import "AddNewProductViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface DistributorGroupProductViewController () <UITableViewDataSource, UITableViewDelegate>

/// 分销商品组商品列表
@property (nonatomic, strong) UITableView *tableView;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 分销商商品组商品列表数组
@property (nonatomic, strong) NSMutableArray *products;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, assign) NSInteger pageNonce;

/// 商品id数组
@property (nonatomic, strong) NSMutableArray *IDArr;

@end

@implementation DistributorGroupProductViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = _distributeGroupName;
    
    self.navigationItem.titleView = naviTitle;
    
    [self headerRereshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _products = [NSMutableArray array];
    _IDArr = [NSMutableArray array];
    
    self.view.backgroundColor = kGrayColor;
    
    [self createUI];
    
    [self createMJRefresh];
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    NSString *groupProductListURL;
    if (_isDistributor == NO) {
        NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"page"                    :   kNullToString(page),
                                 @"per"                     :   @"8",
                                 @"sid"                     :   kNullToString(_sid)};
        
        groupProductListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/product_groups/%@/get_group_products.json",_pg_id] params:params];
    } else {
        NSDictionary *params = @{@"distribution_owner_id"   :   kNullToString(_distribution_owner_id),
                                 @"distribution_resource_id":   kNullToString(_pg_id),
                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"page"                    :   kNullToString(page),
                                 @"per"                     :   @"8",
                                 @"shop_id"                 :   kNullToString(_sid)};
        
        groupProductListURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:@"/distributors/get_product_in_group_from_shop.json" params:params];
    }
    
    YunLog(@"groupProductListURL = %@", groupProductListURL);
    
    [manager GET:groupProductListURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"groupProductListURL responseObject = %@", responseObject);
             NSArray *products = [NSArray array];
             NSMutableArray *newID = [NSMutableArray array];
             if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
             {
                 products = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"products"]);
//                 for (int i = 0 ; i < products.count; i++) {
//                     [newID addObject:[products[i] objectForKey:@"id"]];
//                 }
                 YunLog(@"newID = %@",newID);
                 if (products.count < 8)
                 {
                     _tableView.footerHidden = YES;
                 }
                 else
                 {
                     _tableView.footerHidden = NO;
                 }
            
                 if (pullDown == YES)
                 {
                     [_products setArray:products];
                     [_IDArr setArray:newID];
                 }
                 else
                 {
                     [_products addObjectsFromArray:products];
                     [_IDArr addObjectsFromArray:_IDArr];
                     YunLog(@"_IDArr = %@",_IDArr);
                 }
                 [_tableView footerEndRefreshing];
                 [_tableView headerEndRefreshing];
                 [_tableView reloadData];
                 _hud.hidden = YES;

                 if (_products.count == 0)
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
        
        YunLog(@"groupProductListURL - error = %@", error);
    }];
}

- (void)createUI
{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(kScreenWidth - 10 - 170, 64, 170, 44);
    [addButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [addButton setTitle:@"+添加商品到商品组" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontSize];
    [addButton addTarget:self action:@selector(addNewProduct) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:addButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 44, kScreenWidth, kScreenHeight - 64 - 44) style:UITableViewStylePlain];
    _tableView.backgroundColor = kGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsSelectionDuringEditing = YES;
    
    UIView *back = [[UIView alloc] initWithFrame:_tableView.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 230) / 2, (back.frame.size.height - 200) / 2 - 30, 230, 200)];
    imageView.image = [UIImage imageNamed:@"null"];
    
    [back addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:imageView.frame];
    label.text = @"暂无商品";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    
    [back addSubview:label];
    
    _tableView.backgroundView = back;
    _tableView.backgroundView.hidden = YES;
    
    [self.view addSubview:_tableView];
}

- (void)addNewProduct
{
    AddNewProductViewController *addNewProduct = [[AddNewProductViewController alloc] init];
    
    addNewProduct.shopCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"shopCode"];
    addNewProduct.product_group_id = kNullToString(_pg_id);
    addNewProduct.IDArr = _IDArr;
    
    [self.navigationController pushViewController:addNewProduct animated:YES];
}

- (void)delete:(UIButton *)sender
{
    NSDictionary *product = _products[sender.tag];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"删除商品中...";
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"product_id"              :   kNullToString([product objectForKey:@"id"])};
    
    NSString *deleteProductURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:@"/product_in_groups/%@/remove_product_from_group.json", _pg_id] params:params];
    
    YunLog(@"deleteProductURL = %@", deleteProductURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager DELETE:deleteProductURL
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               YunLog(@"deleteProduct responseObject = %@", responseObject);
               if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
               {
                   [_hud addSuccessString:@"成功移除商品~" delay:2.0];
                   
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [self headerRereshing];
                   });
               }
               else
               {
                   [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
               }
           }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
               YunLog(@"deleteProductURL - error = %@", error);
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

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    
    NSDictionary *product = _products[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kClearColor;
        
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    // cell的背景视图
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    UILabel *productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, kScreenWidth - 20 - 20 - 120, 25)];
    if (_isDistributor == YES)
    {
        productNameLabel.text  = [product objectForKey:@"title"];
    }
    else
    {
        productNameLabel.text  = [product objectForKey:@"name"];
    }
    productNameLabel.textColor = [UIColor darkGrayColor];
    productNameLabel.textAlignment = NSTextAlignmentLeft;
    productNameLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    
    [backView addSubview:productNameLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(productNameLabel.frame), kScreenWidth - 20 - 20 - 120, 25)];
    if (_isDistributor == YES)
    {
        moneyLabel.text  = [NSString stringWithFormat:@"￥%@",kNullToString([product objectForKey:@"price"])];
    }
    else
    {
        moneyLabel.text  = [NSString stringWithFormat:@"￥%@",kNullToString([product objectForKey:@"max_price"])];
    }
    moneyLabel.textColor = [UIColor darkGrayColor];
    moneyLabel.textAlignment = NSTextAlignmentLeft;
    moneyLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    
    [backView addSubview:moneyLabel];
    
    UILabel *payStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(moneyLabel.frame), kScreenWidth - 20 - 20 - 120, 25)];
    payStyleLabel.text  = @"提供在线购买";
    payStyleLabel.textColor = [UIColor darkGrayColor];
    payStyleLabel.textAlignment = NSTextAlignmentLeft;
    payStyleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    
    [backView addSubview:payStyleLabel];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    delete.frame = CGRectMake(kScreenWidth - 20 - 100, 25, 100, 40);
    [delete setTitle:@"移除" forState:UIControlStateNormal];
    [delete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    delete.titleLabel.textAlignment = NSTextAlignmentCenter;
    delete.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
    delete.backgroundColor = [UIColor orangeColor];
    delete.layer.masksToBounds = YES;
    delete.layer.cornerRadius = 5;
    delete.tag = indexPath.row;
    [delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:delete];
    
    return cell;
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
