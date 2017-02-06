//
//  MyShopViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-4-16.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyShopViewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "AdminOrderListViewController.h"
#import "WebViewController.h"
#import "MyQRCodeViewController.h"
#import "MyShopListViewController.h"
#import "MyClientsViewController.h"
#import "MyProductListViewController.h"

@interface MyShopViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *shop;

@property (nonatomic, assign) BOOL hasHeaderView;
@property (nonatomic, copy) NSString *headerURL;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyShopViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hasHeaderView = NO;
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

#pragma mark - UIView Functions -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    
    [self.view addSubview:_tableView];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    NSDictionary *params = @{@"shop_id"   :   kNullToString(_shopCode)};
    
    NSString *infoURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kShopInfoURL params:params];
    
    YunLog(@"shop infoURL = %@", infoURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:infoURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"shop info responseObject = %@",responseObject);
             
             NSString *code = kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]);
             
             if ([code isEqualToString:kSuccessCode]) {
                 _shop = [[responseObject objectForKey:@"data"] objectForKey:@"shop"];
                 
                 if (_shop) {
                     NSString *name = kNullToString([_shop objectForKey:@"name"]);
                     
                     UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
                     
                     naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
                     naviTitle.backgroundColor = kClearColor;
                     naviTitle.textColor = kNaviTitleColor;
                     naviTitle.textAlignment = NSTextAlignmentCenter;
                     naviTitle.text = [name isEqualToString:@""] ? @"我的商铺" : name;
                     
                     self.navigationItem.titleView = naviTitle;
                     
                     NSArray *images = [[[responseObject objectForKey:@"data"] objectForKey:@"shop"] objectForKey:@"images"];
                     for (NSDictionary *dic in images) {
                         if ([[[dic objectForKey:@"use_for"] stringValue] isEqualToString:@"2"]) {
                             _hasHeaderView = YES;
                             
                             _headerURL = dic[@"url"];
//                             UIImageView *top = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
//                             top.backgroundColor = kClearColor;
//                             top.contentMode = UIViewContentModeCenter;
//                             
//                             __weak UIImageView *_top = top;
//                             
//                             [_top setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dic objectForKey:@"url"]]]
//                                         placeholderImage:[UIImage imageNamed:@"default_image"]
//                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                      _top.image = image;
//                                                      _top.contentMode = UIViewContentModeScaleAspectFit;
//                                                  }
//                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                      
//                                                  }];
//
//                             _tableView.tableHeaderView = top;
                             
                             break;
                         }
                     }
                     
//                     _tableView.dataSource = self;

                     [_tableView reloadData];
                     
                     [_hud hide:YES];
                 } else {
                     [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
                 }
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"shop info error = %@", error);
             
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger number = 1;
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.user.shops.count > 1) number += 1;
    
    if (_hasHeaderView) number += 1;

    return number;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    
    if (_hasHeaderView) {
        if (section == 1) {
            // 商品管理暂时屏蔽
            // number = 5;
            number = 4;
        }
        else {
            number = 1;
        }
    }
    else {
        if (section == 0) {
            // 商品管理暂时屏蔽
            // number = 5;
            number = 4;
        }
        else {
            number = 1;
        }
    }
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasHeaderView) {
        if (indexPath.section == 0) {
            return 120;
        }
        else {
            return 44;
        }
    }
    else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_hasHeaderView) {
        if (section == 0) {
            return 0.1;
        }
        else {
            return  20;
        }
    }
    else {
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    } else {
        if (cell.contentView.subviews.count > 0) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [cell.contentView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.layer.cornerRadius = 6;
    cell.imageView.layer.masksToBounds = YES;
    
    if (_hasHeaderView) {
        if (indexPath.section == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = nil;
            cell.imageView.image = nil;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
            imageView.contentMode = UIViewContentModeCenter;
            
            __weak UIImageView *_imageView = imageView;
            
            [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_headerURL]]
                              placeholderImage:[UIImage imageNamed:@"default_image"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           _imageView.image = image;
                                           _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           
                                       }];
            
            [cell.contentView addSubview:imageView];
        }
    }
    
    if (indexPath.section == (_hasHeaderView ? 1 : 0)) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"我的订单";
                cell.imageView.image = [UIImage imageNamed:@"my_shop_order"];
                
                break;
            }
                
            case 1:
            {
                cell.textLabel.text = @"预览店铺";
                cell.imageView.image = [UIImage imageNamed:@"my_shop_preview"];
                
                break;
            }
                
            case 2:
            {
                cell.textLabel.text = @"我的二维码";
                cell.imageView.image = [UIImage imageNamed:@"my_shop_qrcode"];
                
                break;
            }
                
            case 3:
            {
                cell.textLabel.text = @"我的客户";
                cell.imageView.image = [UIImage imageNamed:@"my_shop_customer"];
                
                break;
            }
                
            case 4:
            {
                cell.textLabel.text = @"商品管理";
                cell.imageView.image = [UIImage imageNamed:@"my_shop_customer"];
                
                break;
            }
                
            default:
                break;
        }
    } else if (indexPath.section > (_hasHeaderView ? 1 : 0)) {
        cell.textLabel.text = @"切换商铺";
        cell.imageView.image = [UIImage imageNamed:@"my_shop_change"];
    }
    
//    if (_hasHeaderView) {
//        if (indexPath.section == 0) {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
//            imageView.contentMode = UIViewContentModeCenter;
//            
//            __weak UIImageView *_imageView = imageView;
//            
//            [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_headerURL]]
//                              placeholderImage:[UIImage imageNamed:@"default_image"]
//                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                           _imageView.image = image;
//                                           _imageView.contentMode = UIViewContentModeScaleAspectFit;
//                                       }
//                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                     
//                                       }];
//            
//            [cell.contentView addSubview:imageView];
//        }
//        else if (indexPath.section == 1) {
//            switch (indexPath.row) {
//                case 0:
//                {
//                    cell.textLabel.text = @"我的订单";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_order"];
//                    
//                    break;
//                }
//                    
//                case 1:
//                {
//                    cell.textLabel.text = @"预览店铺";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_preview"];
//                    
//                    break;
//                }
//                    
//                case 2:
//                {
//                    cell.textLabel.text = @"我的二维码";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_qrcode"];
//                    
//                    break;
//                }
//                    
//                case 3:
//                {
//                    cell.textLabel.text = @"我的客户";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_customer"];
//                    
//                    break;
//                }
//                    
//                case 4:
//                {
//                    cell.textLabel.text = @"商品管理";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_product"];
//                    
//                    break;
//                }
//                    
//                default:
//                    break;
//            }
//        } else {
//            cell.textLabel.text = @"切换商铺";
//            cell.imageView.image = [UIImage imageNamed:@"my_shop_change"];
//        }
//    }
//    else {
//        if (indexPath.section == 0) {
//            switch (indexPath.row) {
//                case 0:
//                {
//                    cell.textLabel.text = @"我的订单";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_order"];
//                    
//                    break;
//                }
//                    
//                case 1:
//                {
//                    cell.textLabel.text = @"预览店铺";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_preview"];
//                    
//                    break;
//                }
//                    
//                case 2:
//                {
//                    cell.textLabel.text = @"我的二维码";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_qrcode"];
//                    
//                    break;
//                }
//                    
//                case 3:
//                {
//                    cell.textLabel.text = @"我的客户";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_customer"];
//                    
//                    break;
//                }
//                    
//                case 4:
//                {
//                    cell.textLabel.text = @"商品管理";
//                    cell.imageView.image = [UIImage imageNamed:@"my_shop_customer"];
//                    
//                    break;
//                }
//                    
//                default:
//                    break;
//            }
//        } else {
//            cell.textLabel.text = @"切换商铺";
//            cell.imageView.image = [UIImage imageNamed:@"my_shop_change"];
//        }
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == (_hasHeaderView ? 1 : 0)) {
        switch (indexPath.row) {
            case 0:
            {
                AdminOrderListViewController *list = [[AdminOrderListViewController alloc] init];
                list.shopID = kNullToString([_shop objectForKey:@"id"]);
                list.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:list animated:YES];
                
                break;
            }
                
            case 1:
            {
                WebViewController *web = [[WebViewController alloc] init];
                web.naviTitle = kNullToString([_shop objectForKey:@"name"]);
                web.url = kNullToString([_shop objectForKey:@"shop_home_url"]);
                web.shareParams = @{@"title":_shop[@"share_title"], @"desc":_shop[@"share_desc"], @"logo":_shop[@"share_logo"]};
                web.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:web animated:YES];
                
                break;
            }
                
            case 2:
            {
                MyQRCodeViewController *qrcode = [[MyQRCodeViewController alloc] init];
                qrcode.shopName = kNullToString([_shop objectForKey:@"name"]);
                qrcode.shopURL = kNullToString([_shop objectForKey:@"shop_home_url"]);
                YunLog(@"qrcode = %@", qrcode.shopURL);
                qrcode.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:qrcode animated:YES];
                
                break;
            }
                
            case 3:
            {
                MyClientsViewController *client = [[MyClientsViewController alloc] init];
                client.shopID = kNullToString([_shop objectForKey:@"id"]);
                client.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:client animated:YES];
                
                break;
            }
                
            case 4:
            {
                MyProductListViewController *list = [[MyProductListViewController alloc] init];
                list.shopName = kNullToString(_shop[@"name"]);
                list.shopCode = kNullToString(_shop[@"code"]);
                list.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:list animated:YES];
                
                break;
            }
                
            default:
                break;
        }
    } else if (indexPath.section > (_hasHeaderView ? 1 : 0)) {
        MyShopListViewController *list = [[MyShopListViewController alloc] init];
        
        [self.navigationController pushViewController:list animated:YES];
    }
    
//    if (_hasHeaderView) {
//        if (indexPath.section == 0) {
//            
//        }
//        else if (indexPath.section == 1) {
//            switch (indexPath.row) {
//                case 0:
//                {
//                    AdminOrderListViewController *list = [[AdminOrderListViewController alloc] init];
//                    list.shopID = kNullToString([_shop objectForKey:@"id"]);
//                    list.hidesBottomBarWhenPushed = YES;
//                    
//                    [self.navigationController pushViewController:list animated:YES];
//                    
//                    break;
//                }
//                    
//                case 1:
//                {
//                    WebViewController *web = [[WebViewController alloc] init];
//                    web.naviTitle = kNullToString([_shop objectForKey:@"name"]);
//                    web.url = kNullToString([_shop objectForKey:@"shop_home_url"]);
//                    web.hidesBottomBarWhenPushed = YES;
//                    
//                    [self.navigationController pushViewController:web animated:YES];
//                    
//                    break;
//                }
//                    
//                case 2:
//                {
//                    MyQRCodeViewController *qrcode = [[MyQRCodeViewController alloc] init];
//                    qrcode.shopName = kNullToString([_shop objectForKey:@"name"]);
//                    qrcode.shopURL = kNullToString([_shop objectForKey:@"shop_home_url"]);
//                    qrcode.hidesBottomBarWhenPushed = YES;
//                    
//                    [self.navigationController pushViewController:qrcode animated:YES];
//                    
//                    break;
//                }
//                    
//                case 3:
//                {
//                    MyClientsViewController *client = [[MyClientsViewController alloc] init];
//                    client.shopID = kNullToString([_shop objectForKey:@"id"]);
//                    client.hidesBottomBarWhenPushed = YES;
//                    
//                    [self.navigationController pushViewController:client animated:YES];
//                    
//                    break;
//                }
//                    
//                case 4:
//                {
//                    MyProductListViewController *list = [[MyProductListViewController alloc] init];
//                    list.shopName = kNullToString(_shop[@"name"]);
//                    list.shopCode = kNullToString(_shop[@"code"]);
//                    list.hidesBottomBarWhenPushed = YES;
//                    
//                    [self.navigationController pushViewController:list animated:YES];
//                    
//                    break;
//                }
//                    
//                default:
//                    break;
//            }
//        } else {
//            MyShopListViewController *list = [[MyShopListViewController alloc] init];
//            
//            [self.navigationController pushViewController:list animated:YES];
//        }
//    }
//    else {
//        
//    }
}

@end
