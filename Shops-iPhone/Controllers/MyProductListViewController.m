//
//  MyProductListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14/11/5.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyProductListViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Views
#import "UILabelWithLine.h"

// Controllers
#import "MyProductDetailViewController.h"

@interface MyProductListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *products;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyProductListViewController

#pragma mark - Life Cycle -

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

    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = _shopName;
    
    self.navigationItem.titleView = naviTitle;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _tableView = [[UITableView alloc] initWithFrame:kScreenBounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *listParams = @{@"sid"                     :   kNullToString(_shopCode),
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kProductListURL params:listParams];
    
    YunLog(@"product list url = %@", listURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:listURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product list responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _products = [[responseObject objectForKey:@"data"] objectForKey:@"products"];
                 
                 [_tableView reloadData];
                 
                 [_hud hide:YES];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"get product list error = %@", error);
             
             [_hud addErrorString:@"获取商品数据异常" delay:2.0];
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        if (cell.contentView.subviews.count > 0) [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    cell.backgroundColor = COLOR(245, 245, 245, 1);
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 108, 80)];
    [imageView setImageWithURL:[NSURL URLWithString:kNullToString([_products[indexPath.row] objectForKey:@"icon"])]
              placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    [cell.contentView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 12, kScreenWidth - 138, 14)];
    nameLabel.backgroundColor = kClearColor;
    nameLabel.font = [UIFont fontWithName:kFontFamily size:14];
    nameLabel.text = kNullToString([_products[indexPath.row] objectForKey:@"name"]);
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [cell.contentView addSubview:nameLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 30, kScreenWidth - 138, 14)];
    subLabel.backgroundColor = kClearColor;
    subLabel.font = kSmallFont;
    subLabel.text = kNullToString([_products[indexPath.row] objectForKey:@"subtitle"]);
    subLabel.textColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:subLabel];
    
    NSString *price = [NSString stringWithFormat:@"￥%@", kNullToString([_products[indexPath.row] objectForKey:@"price"])];
    
    CGSize priceSize = [price sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
    
    UILabel *nowPrice = [[UILabel alloc] initWithFrame:CGRectMake(128, 47, priceSize.width, 20)];
    nowPrice.backgroundColor = kClearColor;
    nowPrice.textColor = [UIColor orangeColor];
    nowPrice.font = kBigFont;
    nowPrice.text = price;
    
    [cell.contentView addSubview:nowPrice];
    
    NSString *marketPrice = [NSString stringWithFormat:@"￥%@", kNullToString([_products[indexPath.row] objectForKey:@"market_price"])];
    
    float priceFloat = [[_products[indexPath.row] objectForKey:@"price"] floatValue];
    float marketFloat = [[_products[indexPath.row] objectForKey:@"market_price"] floatValue];
    
    if (priceFloat < marketFloat) {
        CGSize size = [marketPrice sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
        
        UILabelWithLine *lastPrice = [[UILabelWithLine alloc] initWithFrame:CGRectMake(5 + nowPrice.frame.origin.x + nowPrice.frame.size.width, 47, size.width, 20)];
        lastPrice.backgroundColor = kClearColor;
        lastPrice.font = kNormalFont;
        lastPrice.text = marketPrice;
        lastPrice.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:lastPrice];
    }
    
    UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 80, 90, 10)];
    soldLabel.backgroundColor = kClearColor;
    soldLabel.textColor = [UIColor lightGrayColor];
    soldLabel.font = [UIFont fontWithName:kFontFamily size:10];
    
    if ([[_products[indexPath.row] objectForKey:@"inventory_quantity"] integerValue] > 0) {
        soldLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([_products[indexPath.row] objectForKey:@"sales_quantity"])];
    } else {
        soldLabel.text = @"已售完";
        soldLabel.textColor = [UIColor redColor];
    }
    
    [cell.contentView addSubview:soldLabel];
    
    UILabel *inventoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(228, 80, kScreenWidth - 238, 10)];
    inventoryLabel.backgroundColor = kClearColor;
    inventoryLabel.textColor = [UIColor lightGrayColor];
    inventoryLabel.font = [UIFont fontWithName:kFontFamily size:10];
    inventoryLabel.text = [NSString stringWithFormat:@"库存 %@", kNullToString(_products[indexPath.row][@"inventory_quantity"])];
    
    [cell.contentView addSubview:inventoryLabel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyProductDetailViewController *detail = [[MyProductDetailViewController alloc] init];
    detail.productCode = _products[indexPath.row][@"code"];
    detail.productName = _products[indexPath.row][@"name"];
    detail.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
