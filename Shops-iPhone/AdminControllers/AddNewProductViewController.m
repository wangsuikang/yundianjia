//
//  AddNewProductViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AddNewProductViewController.h"

// Libraries
#import "LTableViewCell.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface AddNewProductViewController () <UITableViewDataSource, UITableViewDelegate>

/// 可添加到商品组的商品列表
@property (nonatomic, strong) UITableView *tableView;

/// 存放cell的选中
@property (nonatomic, strong) NSMutableArray *contacts;

/// 全选按钮
@property (nonatomic, strong) UIButton *allSelectButton;

/// 编辑按钮
@property (nonatomic, strong) UIButton *editButton;

/// 底部视图
@property (nonatomic, strong) UIView *buttomView;

/// 是否在加载数据
@property (nonatomic, assign) BOOL isLoading;

/// 当前页
@property (nonatomic, assign) NSInteger pageNonce;

/// 三方库
@property (nonatomic, strong) MBProgressHUD *hud;

/// 商品列表
@property (nonatomic, strong) NSMutableArray *products;

@end

@implementation AddNewProductViewController

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
        naviTitle.text = @"添加新商品到商品组";
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _products = [NSMutableArray array];
    
    self.view.backgroundColor = kGrayColor;

    [self createUI];
    
    [self createMJRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self headerRereshing];
}

- (void)dealloc
{
    _tableView.delegate = nil; // 防止 scrollViewDidScroll deallocated error
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

- (void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, kScreenHeight - 49 - 10) style:UITableViewStylePlain];
    _tableView.backgroundColor = kGrayColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
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
    
    _contacts = [NSMutableArray array];
    
    _buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49, kScreenWidth, 49)];
    _buttomView.backgroundColor = kGrayColor;
    
    [self.view addSubview:_buttomView];
    
    _allSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allSelectButton.frame = CGRectMake(10, 0, 80, 49);
    _allSelectButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
    [_allSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _allSelectButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    [_allSelectButton addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_buttomView addSubview:_allSelectButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(kScreenWidth - 150 - 10, 0, 150, 49);
    addButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [addButton setTitle:@"添加到商品组" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontLargeSize];
    [addButton addTarget:self action:@selector(addMoreNewProduct) forControlEvents:UIControlEventTouchUpInside];
    [_buttomView addSubview:addButton];
}

- (void)allSelect:(UIButton *)sender
{
    NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[_tableView indexPathsForVisibleRows]];
    for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
        NSIndexPath *indexPath= [anArrayOfIndexPath objectAtIndex:i];
        LTableViewCell *cell = (LTableViewCell*)[_tableView cellForRowAtIndexPath:indexPath];
        
        NSUInteger row = [indexPath row];
        
        NSMutableDictionary *dic = [_contacts objectAtIndex:row];
        if ([[[(UIButton*)sender titleLabel] text] isEqualToString:@"全选"]) {
            [dic setObject:@"YES" forKey:@"checked"];
            [cell setChecked:YES];
        }else {
            [dic setObject:@"NO" forKey:@"checked"];
            [cell setChecked:NO];
        }
    }
    if ([[[(UIButton*)sender titleLabel] text] isEqualToString:@"全选"]) {
        for (NSDictionary *dic in _contacts) {
            [dic setValue:@"YES" forKey:@"checked"];
        }
        [(UIButton*)sender setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        for (NSDictionary *dic in _contacts) {
            [dic setValue:@"NO" forKey:@"checked"];
        }
        [(UIButton*)sender setTitle:@"全选" forState:UIControlStateNormal];
    }
}

/**
 创建上拉下拉刷新对象
 */
- (void)createMJRefresh{
    
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
//    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
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

#pragma mark - getData -
/**
 获取数据源
 
 @param pullDown 是否是下拉
 @param page     当前页数
 */
- (void)getNextPageViewIsPullDown:(BOOL)pullDown withPage:(NSInteger)page
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _isLoading = YES;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    // 获取浏览商品数据
    NSDictionary *params = @{@"code"                  :   kNullToString(_shopCode),
                             @"user_session_key"      :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"  :   kNullToString(appDelegate.terminalSessionKey),
                             @"pg_id"                 :   kNullToString(_product_group_id),};
    
    YunLog(@"params = %@", params);
    
    NSString *adminProductsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:@"/shops/get_products_not_in_product_group.json" params:params];
    
    YunLog(@"我的商品URL = %@", adminProductsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:adminProductsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YunLog(@"我的商品responseObject = %@", responseObject);
        NSMutableArray *newProduct = [NSMutableArray array];
//        NSMutableArray *temp = [NSMutableArray array];
        if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
        {
            if (pullDown == YES)
            {
                [_contacts removeAllObjects];
                [_allSelectButton setTitle:@"全选" forState:UIControlStateNormal];
            }
            newProduct = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"products"]);
//            
//            for (int i = 0; i < _IDArr.count; i++) {
//                NSString *Id = _IDArr[i ];
//                for (int j = (int)temp.count - 1; j >= 0; j--) {
//                     NSString *ID = kNullToString([temp[j] objectForKey:@"id"]);
//                    if(Id != ID)
//                    {
//                        [newProduct addObject:temp[j]];
//                        [temp removeObjectAtIndex:j];
//                    }
//                    else
//                    {
//                    }
//                }
//            }
            
            for (int i = 0; i < newProduct.count; i++) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:@"NO" forKey:@"checked"];
                [_contacts addObject:dic];
            }

            if (newProduct.count < 8)
            {
                _tableView.footerHidden = YES;
            }
            else
            {
                _tableView.footerHidden = NO;
            }
            
            if (pullDown == YES)
            {
                [_products setArray:newProduct];
            }
            else
            {
                [_products addObjectsFromArray:newProduct];
                YunLog(@"_products = %@",newProduct);
            }
            [_tableView footerEndRefreshing];
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
            _hud.hidden = YES;

            if (_products.count == 0)
            {
                _tableView.backgroundView.hidden = NO;
                _tableView.headerHidden = YES;
                _buttomView.hidden = YES;
            }
            else
            {
                _tableView.backgroundView.hidden = YES;
                _tableView.headerHidden = NO;
                _buttomView.hidden = NO;
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
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
        YunLog(@"我的商品URL - error = %@", error);
        
        _tableView.backgroundView.hidden = NO;
        
        [_tableView footerEndRefreshing];
        [_tableView headerEndRefreshing];
        _tableView.footerHidden = NO;
        _isLoading = NO;
    }];
}

- (void)addNewProduct:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在添加...";
    
    NSDictionary *product = _products[sender.tag];
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"prodcut_ids"             :   kNullToString([product objectForKey:@"id"]),
                             @"product_group_id"        :   kNullToString(_product_group_id),
                             @"sid"                     :   [[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]};
    
    NSString *addNewProductURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:KAdd_GroupsProduct params:params];
    
    YunLog(@"addNewProductURL = %@", addNewProductURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:addNewProductURL
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               YunLog(@"addNewProduct responseObject = %@", responseObject);
               if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
               {
                   [_hud addSuccessString:@"添加商品成功" delay:2.0];
                   
                   [_IDArr addObject:[product objectForKey:@"id"]];
                   
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
               YunLog(@"addNewProduct - error = %@", error);
           }];
}

- (void)addMoreNewProduct
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在导入...";
    
    NSMutableString *selectedProduct = [NSMutableString string];
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < _contacts.count; i ++) {
        NSMutableDictionary *dic = [_contacts objectAtIndex:i];
        if ([[dic objectForKey:@"checked"] isEqualToString:@"YES"]) {
            NSDictionary *product = _products[i];
            NSString *str = kNullToString([product objectForKey:@"id"]);
            [selectedProduct appendString:[NSString stringWithFormat:@"%@,", str]];
            [temp addObject:str];
        }else {
        }
    }
    
    if ([selectedProduct isEqualToString:@""])
    {
        [_hud addErrorString:@"请选择商品" delay:2.0];
        
        return;
    }
    
    YunLog(@"selectedProduct = %@",selectedProduct);
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"prodcut_ids"             :   kNullToString(selectedProduct),
                             @"product_group_id"        :   kNullToString(_product_group_id),
                             @"sid"                     :   [[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]};
    
    NSString *addNewProductURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:KAdd_GroupsProduct params:params];
    
    YunLog(@"addNewProductURL = %@", addNewProductURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:addNewProductURL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"addNewProduct responseObject = %@", responseObject);
              if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
              {
                  [_hud addSuccessString:@"导入商品成功" delay:2.0];
                  
                  [_IDArr addObjectsFromArray:temp];
                  
//                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self headerRereshing];
//                  });
              }
              else
              {
                  [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
              }
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
              YunLog(@"addNewProduct - error = %@", error);
          }];
}


#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellID = @"cell";
    YunLog(@"indexPath.row%ld",(long)indexPath.row);
    
    NSDictionary *product = _products[indexPath.row];
    
    LTableViewCell *cell = [[LTableViewCell alloc] init];
        [cell creatWithImage:YES];
    NSUInteger row = [indexPath row];
    NSMutableDictionary *dic = [_contacts objectAtIndex:row];
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
        [cell setChecked:NO];
    }else {
        [cell setChecked:YES];
    }

//    if (cell == nil) {
//        cell = [[LTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kClearColor;
//        [cell creatWithImage:YES];
//        
//    } else {
//        // 解决重用cell的重影问题
//        if (cell.contentView.subviews.count > 0)
//            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    }
    
    // cell的背景视图
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 110)];
    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 90, 90)];  // 宽高  70
    leftImage.backgroundColor = kClearColor;
    leftImage.contentMode = UIViewContentModeCenter;
    
    __weak UIImageView *weakImageView = leftImage;
    [leftImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([product safeObjectForKey:@"large_icon"])]]
                     placeholderImage:[UIImage imageNamed:@"default_history"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  weakImageView.image = image;
                                  weakImageView.contentMode = UIViewContentModeScaleAspectFit;
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  
                              }];
    
    [backView addSubview:leftImage];

    
    UILabel *productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftImage.frame) + 10, 15, kScreenWidth - CGRectGetMaxX(leftImage.frame) - 20 - 120, 25)];
    productNameLabel.text  = [product objectForKey:@"name"];
    productNameLabel.textColor = [UIColor darkGrayColor];
    productNameLabel.textAlignment = NSTextAlignmentLeft;
    productNameLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:productNameLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftImage.frame) + 10, CGRectGetMaxY(productNameLabel.frame), kScreenWidth - CGRectGetMaxX(leftImage.frame) - 20 - 120, 25)];
    moneyLabel.text  = [NSString stringWithFormat:@"￥%@", kNullToString([product objectForKey:@"price"])];
    moneyLabel.textColor = [UIColor darkGrayColor];
    moneyLabel.textAlignment = NSTextAlignmentLeft;
    moneyLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:moneyLabel];
    
    UILabel *payStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftImage.frame) + 10, CGRectGetMaxY(moneyLabel.frame), kScreenWidth - CGRectGetMaxX(leftImage.frame) - 20 - 120, 25)];
    payStyleLabel.text  = @"提供在线购买";
    payStyleLabel.textColor = [UIColor darkGrayColor];
    payStyleLabel.textAlignment = NSTextAlignmentLeft;
    payStyleLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
    
    [backView addSubview:payStyleLabel];
    
//    for (int i = 0;i <_IDArr.count ;i ++)
//    {
//        if ([[_IDArr[i] stringValue] isEqualToString:[[_products[indexPath.row] objectForKey:@"id"] stringValue]])
//        {
//            [cell creatWithImage:NO];
//            
//            return cell;
//        }
//    }
    
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.frame = CGRectMake(kScreenWidth - 20 - 100, 35, 100, 40);
    [add setTitle:@"添加" forState:UIControlStateNormal];
    [add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    add.titleLabel.textAlignment = NSTextAlignmentCenter;
    add.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
    add.backgroundColor = [UIColor orangeColor];
    add.layer.masksToBounds = YES;
    add.layer.cornerRadius = 5;
    add.tag = indexPath.row;
    [add addTarget:self action:@selector(addNewProduct:) forControlEvents:UIControlEventTouchUpInside];
    
    [backView addSubview:add];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LTableViewCell *cell = (LTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
//    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    
//    YunLog(@"[[_products[indexPath.row] objectForKey:] stringValue] = %@    %@",[[_products[indexPath.row] objectForKey:@"id"] stringValue],_IDArr);
//    
//    for (int i = 0;i <_IDArr.count ;i ++)
//    {
//        if ([[_IDArr[i] stringValue] isEqualToString:[[_products[indexPath.row] objectForKey:@"id"] stringValue]])
//        {
//            [_hud addErrorString:@"该商品已存在" delay:1.0];
//            return;
//        }
//    }
//    
//    _hud.hidden = YES;
    
    NSUInteger row = [indexPath row];
    NSMutableDictionary *dic = [_contacts objectAtIndex:row];
    if ([[dic objectForKey:@"checked"] isEqualToString:@"NO"]) {
        [dic setObject:@"YES" forKey:@"checked"];
        [cell setChecked:YES];
    }else {
        [dic setObject:@"NO" forKey:@"checked"];
        [cell setChecked:NO];
    }
}

//#pragma mark - UIScrollViewDelegate -
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint point = scrollView.contentOffset;
//    
//    
//    YunLog(@"point.y = %f,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4 = %f",point.y,scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4);
//    
//    if (point.y > (scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4)
//        && ( scrollView.contentSize.height - scrollView.bounds.size.height - self.view.frame.size.height / 4) > 0) {
//        [self footerRereshing];
//    }
//}

@end
