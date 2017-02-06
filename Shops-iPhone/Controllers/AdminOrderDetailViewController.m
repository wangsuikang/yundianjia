//
//  AdminOrderDetailViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-3-31.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "AdminOrderDetailViewController.h"

// Common Headers
#import "LibraryHeadersForCommonController.h"

// Classes

// Controllers
#import "AdminOrderOperationViewController.h"
#import "WebViewController.h"

// Libraries

@interface AdminOrderDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *detail;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AdminOrderDetailViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 120) / 2, 0, 120, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"订单详情";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"oid"                     :   _oid};

    NSString *detailURL = [Tool buildRequestURLHost:kRequestHost
                                         APIVersion:kAPIVersion1
                                         requestURL:kOrderAdminDetailURL
                                             params:params];
    
    YunLog(@"admin order detailURL = %@", detailURL);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:detailURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"admin order detail responseObject = %@", responseObject);
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 _detail = [[responseObject objectForKey:@"data"] objectForKey:@"order"];
                 
                 [self generateBottomView];
                 
                 [_tableView reloadData];
                 
                 [_hud hide:YES];
                 
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 [self backToPrev];
             } else {
                 [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"])
                                delay:2.0];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"admin order detail error = %@", error);
             
             if (![operation isCancelled]) {
                 [_hud addErrorString:@"网络繁忙,请稍后再试" delay:2.0];
                 
             }
         }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

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
    
    if (kDeviceOSVersion < 7.0) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)
                                                  style:UITableViewStylePlain];
    } else {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _tableView.backgroundColor = kGrayColor;
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//    view.backgroundColor = [UIColor whiteColor];
    
//    _tableView.backgroundView = view;
    
    [self.view addSubview:_tableView];
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToExpress
{
    WebViewController *web = [[WebViewController alloc] init];
    web.url = [_detail objectForKey:@"express_url"];
    web.naviTitle = @"物流详情";
    web.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:web animated:YES];
}

- (void)dialPhone:(UIButton *)sender
{
    NSString *message;
    
    if (sender.tag == 1) {
        message = [NSString stringWithFormat:@"确认拨打 %@", kNullToString([_detail objectForKey:@"consignee_phone"])];
    } else {
        message = [NSString stringWithFormat:@"确认拨打 %@", kNullToString([_detail objectForKey:@"buyer_phone"])];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拨打电话"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.tag = sender.tag;
    [alertView show];
}

- (void)goToSend
{
    AdminOrderOperationViewController *operation = [[AdminOrderOperationViewController alloc] init];
    operation.oid = kNullToString([_detail objectForKey:@"id"]);
    operation.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:operation animated:YES];
}

- (void)generateBottomView
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSInteger status = [[_detail objectForKey:@"status_value"] integerValue];
    
    NSString *expressURL = kNullToString([_detail safeObjectForKey:@"express_url"]);
    
    UIView *bottomView;
    
    if (![expressURL isEqualToString:@""] || ((status == 2 || status == 4) && appDelegate.user.userType == 2)) {
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
        
        _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
        
        if (kDeviceOSVersion < 7.0) {
            bottomView.frame = CGRectMake(-1, kScreenHeight - 48 - 64, kScreenWidth + 2, 48);
            _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48 - 64);
        }
        
        bottomView.backgroundColor = COLOR(245, 245, 245, 1);
//        bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
//        bottomView.layer.shadowOffset = CGSizeMake(1, 5);
//        bottomView.layer.shadowOpacity = 1.0;
//        bottomView.layer.shadowRadius = 5.0;
        bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
        bottomView.layer.borderWidth = 1;
        bottomView.clipsToBounds = NO;
        
        [self.view addSubview:bottomView];
    }

//    if (status == 2 || status == 4) {
//        bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
//        
//        if (kDeviceOSVersion < 7.0) {
//            bottomView.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
//        }
//        
//        bottomView.backgroundColor = COLOR(245, 245, 245, 1);
//        bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
//        bottomView.layer.shadowOffset = CGSizeMake(1, 5);
//        bottomView.layer.shadowOpacity = 1.0;
//        bottomView.layer.shadowRadius = 5.0;
//        bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
//        bottomView.layer.borderWidth = 1;
//        bottomView.clipsToBounds = NO;
//        
//        [self.view addSubview:bottomView];
//        
//        _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
//    }
    
    if (bottomView) {
        switch (status) {
            case 2:
            {
                if (appDelegate.user.userType == 2) {
                    UIButton *goToSend = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
                    goToSend.layer.cornerRadius = 6;
                    goToSend.layer.masksToBounds = YES;
                    goToSend.backgroundColor = [UIColor orangeColor];
                    [goToSend setTitle:@"去发货" forState:UIControlStateNormal];
                    [goToSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [goToSend addTarget:self action:@selector(goToSend) forControlEvents:UIControlEventTouchUpInside];
                    
                    [bottomView addSubview:goToSend];
                }
                
                break;
            }
                
            case 4 :
            {
                UIButton *modifyExpress;
                
                if (appDelegate.user.userType == 2) {
                    modifyExpress = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
                    modifyExpress.layer.cornerRadius = 6;
                    modifyExpress.layer.masksToBounds = YES;
                    modifyExpress.backgroundColor = [UIColor orangeColor];
                    [modifyExpress setTitle:@"重新发货" forState:UIControlStateNormal];
                    [modifyExpress setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [modifyExpress addTarget:self action:@selector(goToSend) forControlEvents:UIControlEventTouchUpInside];
                    
                    [bottomView addSubview:modifyExpress];
                }
                
                if (![expressURL isEqualToString:@""]) {
                    UIButton *viewExpress = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
                    
                    if (modifyExpress.frame.size.width > 0) {
                        viewExpress.frame = CGRectMake(kScreenWidth - 220, 8, 100, 32);
                    }
                    
                    viewExpress.layer.cornerRadius = 6;
                    viewExpress.layer.masksToBounds = YES;
                    viewExpress.backgroundColor = [UIColor orangeColor];
                    viewExpress.alpha = 0.7;
                    [viewExpress setTitle:@"查看物流" forState:UIControlStateNormal];
                    [viewExpress setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [viewExpress addTarget:self action:@selector(goToExpress) forControlEvents:UIControlEventTouchUpInside];
                    
                    [bottomView addSubview:viewExpress];
                }
                
                break;
            }
            case 5 :
            {
                if (![expressURL isEqualToString:@""]) {
                    UIButton *viewExpress = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
                    viewExpress.layer.cornerRadius = 6;
                    viewExpress.layer.masksToBounds = YES;
                    viewExpress.backgroundColor = [UIColor orangeColor];
                    [viewExpress setTitle:@"查看物流" forState:UIControlStateNormal];
                    [viewExpress setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [viewExpress addTarget:self action:@selector(goToExpress) forControlEvents:UIControlEventTouchUpInside];
                    
                    [bottomView addSubview:viewExpress];
                }
                
                break;
            }

                
            default:
                break;
        }
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_detail objectForKey:@"distributor_shop"]) {
        return 7;
    } else {
        return 6;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    
    if (section == [tableView numberOfSections] - 1) {
        count = [[_detail objectForKey:@"items"] count];
    } else if (section == 3) {
        count = 7;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    view.backgroundColor = COLOR(245, 244, 245, 1);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 40)];
    label.backgroundColor = kClearColor;
    label.font = kNormalFont;
    
    switch (section) {
        case 0:
            label.text = @"收货人信息";
            break;
            
        case 1:
            label.text = @"购买人信息";
            break;
            
        case 2:
            label.text = @"支付时间";
            break;
            
        case 3:
            label.text = @"订单信息";
            break;
            
        case 4:
            label.text = @"快递信息";
            break;
            
        case 5:
            if (section == [tableView numberOfSections] - 1) {
                label.text = @"商品信息";
            } else {
                label.text = @"分销商信息";
            }
            
            break;
            
        case 6:
            label.text = @"商品信息";
            break;
            
        default:
            break;
    }
    
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    switch (indexPath.section) {
        case 0:
        {
            NSString *address = kNullToString([_detail objectForKey:@"consignee_address"]);
            
            CGSize size = [address sizeWithFont:[UIFont fontWithName:kFontFamily size:15] size:CGSizeMake(kScreenWidth - 20, 9999)];
            
            height = 40 + size.height + 10;
            
            break;
        }
            
        case 1: case 2: case 3: case 4:
        {
            break;
        }
            
        case 5:
        {
            if (indexPath.section == [tableView numberOfSections] - 1) {
                height = 100;
            }
            
            break;
        }
            
        case 6:
        {
            height = 100;
            
            break;
        }
            
        default:
            break;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    } else {
        if (cell.contentView.subviews.count > 0) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    NSString *status = kNullToString([_detail objectForKey:@"status"]);
    
    switch (indexPath.section) {
        case 0:
        {
            // 用户名
            UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
            accountName.backgroundColor = kClearColor;
            accountName.font = kBigFont;
            accountName.text = kNullToString([_detail objectForKey:@"consignee_name"]);
            accountName.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8];
            
            [cell.contentView addSubview:accountName];
            
            // 手机号
            UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 20 - 30 - 20 - 150, 0, 150, 40)];
            accountPhone.backgroundColor = kClearColor;
            accountPhone.font = kBigFont;
            accountPhone.text = kNullToString([_detail objectForKey:@"consignee_phone"]);
            accountPhone.textAlignment = NSTextAlignmentRight;
            accountPhone.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8];
            
            [cell.contentView addSubview:accountPhone];
            
            // 拨打电话
            UIButton *dialPhone = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 20 - 30, 5, 30, 30)];
            dialPhone.layer.cornerRadius = 6;
            dialPhone.layer.masksToBounds = YES;
            [dialPhone setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
            [dialPhone addTarget:self action:@selector(dialPhone:) forControlEvents:UIControlEventTouchUpInside];
            dialPhone.tag = 1;
            
            [cell.contentView addSubview:dialPhone];
            
            // 地址
            NSString *address = kNullToString([_detail objectForKey:@"consignee_address"]);
            
            CGSize size = [address sizeWithFont:[UIFont fontWithName:kFontFamily size:15] size:CGSizeMake(kScreenWidth - 20, 9999)];
            
            UILabel *accountAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, kScreenWidth - 20, size.height)];
            accountAddress.backgroundColor = kClearColor;
            accountAddress.numberOfLines = 0;
            accountAddress.text = address;
            accountAddress.font = [UIFont fontWithName:kFontFamily size:15];
            accountAddress.textColor = COLOR(30, 144, 255, 1);
            
            [cell.contentView addSubview:accountAddress];
            
            break;
        }
            
        case 1:
        {
            // 用户名
            UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 44)];
            accountName.backgroundColor = kClearColor;
            accountName.font = kNormalFont;
            accountName.text = kNullToString([_detail objectForKey:@"buyer_name"]);
            accountName.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8];
            
            [cell.contentView addSubview:accountName];
            
            // 手机号
            UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 20 - 30 - 20 - 110, 0, 110, 44)];
            accountPhone.backgroundColor = kClearColor;
            accountPhone.font = kNormalFont;
            accountPhone.text = kNullToString([_detail objectForKey:@"buyer_phone"]);
            accountPhone.textAlignment = NSTextAlignmentRight;
            accountPhone.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.8];
            
            [cell.contentView addSubview:accountPhone];
            
            // 拨打电话
            UIButton *dialPhone = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 20 - 30, 7, 30, 30)];
            dialPhone.layer.cornerRadius = 6;
            dialPhone.layer.masksToBounds = YES;
            [dialPhone setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
            [dialPhone addTarget:self action:@selector(dialPhone:) forControlEvents:UIControlEventTouchUpInside];
            dialPhone.tag = 2;
            
            [cell.contentView addSubview:dialPhone];
            
            break;
        }
            
        case 2:
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 44)];
            label.backgroundColor = kClearColor;
            label.font = kNormalFont;
            label.text = kNullToString([_detail objectForKey:@"payment_at"]);
            
            [cell.contentView addSubview:label];
            
            break;
        }
            
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"时间";
                    cell.detailTextLabel.text = kNullToString([_detail objectForKey:@"commit_at"]);
                    break;
                    
                case 1:
                    cell.textLabel.text = @"状态";
                    cell.detailTextLabel.text = kNullToString([_detail objectForKey:@"status"]);
                    break;
                    
                case 2:
                    cell.textLabel.text = @"发票";
                    cell.detailTextLabel.text = kNullToString([_detail objectForKey:@"invoice"]);
                    break;
                    
                case 3:
                    cell.textLabel.text = @"备注";
                    cell.detailTextLabel.text = kNullToString([_detail objectForKey:@"note"]);
                    break;
                    
//                case 4:
//                {
//                    NSString *distributor = kNullToString([_detail objectForKey:@"distributor_shop"]);
//                    if ([distributor isEqualToString:@""]) {
//                        cell.textLabel.text = @"直销";
//                    } else {
//                        cell.textLabel.text = @"分销商";
//                        cell.detailTextLabel.text = distributor;
//                    }
//                    
//                    break;
//                }
                    
                case 4:
                    cell.textLabel.text = @"小计";
                    cell.detailTextLabel.text = [@"￥" stringByAppendingString:kNullToString([_detail objectForKey:@"original_price"])];
                    break;
                    
                case 5:
                    cell.textLabel.text = @"优惠";
                    cell.detailTextLabel.text = [@"￥" stringByAppendingString:kNullToString([_detail objectForKey:@"discount_price"])];
                    break;
                    
                case 6:
                    cell.textLabel.text = @"总价";
                    cell.detailTextLabel.text = [@"￥" stringByAppendingString:kNullToString([_detail objectForKey:@"pay_price"])];
                    break;
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 4:
        {
            UILabel *company = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 28)];
            company.backgroundColor = kClearColor;
            company.font = kNormalFont;
            company.text = kNullToString([_detail objectForKey:@"tracking_company"]);
            
            [cell.contentView addSubview:company];
            
            UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, kScreenWidth - 20, 18)];
            number.backgroundColor = kClearColor;
            number.font = [UIFont fontWithName:kFontFamily size:14];
            number.text = kNullToString([_detail objectForKey:@"tracking_number"]);
            
            [cell.contentView addSubview:number];
            
            break;
        }
            
        case 5:
        {
            if ([tableView numberOfSections] - 1 == indexPath.section) {
                NSArray *items = [_detail objectForKey:@"items"];
                
                // 商品图
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 108, 80)];
                
//                imageView.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
//                imageView.layer.shadowOpacity = 1.0;
//                imageView.layer.shadowRadius = 5.0;
//                imageView.layer.shadowOffset = CGSizeMake(0, 1);
                
                imageView.clipsToBounds = NO;
                
                [cell.contentView addSubview:imageView];
                
                YunLog(@"thum_200 = %@",[[items[indexPath.row] objectForKey:@"large_icon_url"] objectForKey:@"large_icon"]);
                
                __weak UIImageView *weakImageView = imageView;
                imageView.contentMode = UIViewContentModeCenter;
                [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([[items[indexPath.row] objectForKey:@"large_icon_url"] objectForKey:@"large_icon"])]]
                                 placeholderImage:[UIImage imageNamed:@"default_history"]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              weakImageView.image = image;
                                              weakImageView.contentMode = UIViewContentModeScaleToFill;
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              
                                          }];
                
                // 名称
                NSString *text = [items[indexPath.row] objectForKey:@"name"];
                
                CGSize size = [text sizeWithFont:[UIFont fontWithName:kFontFamily size:14] size:CGSizeMake(kScreenWidth - 130, 68)];
                
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(130, 12, kScreenWidth - 140, size.height)];
                title.backgroundColor = kClearColor;
                title.font = [UIFont fontWithName:kFontFamily size:14];
                title.text = text;
                title.numberOfLines = 0;
                
                [cell.contentView addSubview:title];
                
                // 金额和数量
                UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(130, 74, kScreenWidth - 140, 14)];
                money.backgroundColor = kClearColor;
                money.font = [UIFont fontWithName:kFontFamily size:14];
                money.text = [NSString stringWithFormat:@"￥%@ x %@", [items[indexPath.row] objectForKey:@"price"], [items[indexPath.row] objectForKey:@"count"]];
                
                [cell.contentView addSubview:money];
            } else {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 44)];
                label.backgroundColor = kClearColor;
                label.font = kNormalFont;
                label.text = kNullToString([_detail objectForKey:@"distributor_shop"]);
                
                [cell.contentView addSubview:label];
            }

            break;
        }
            
        case 6:
        {
            NSArray *items = [_detail objectForKey:@"items"];
            
            // 商品图
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 108, 80)];
            
//            imageView.layer.shadowColor = COLOR(178, 178, 178, 1).CGColor;
//            imageView.layer.shadowOpacity = 1.0;
//            imageView.layer.shadowRadius = 5.0;
//            imageView.layer.shadowOffset = CGSizeMake(0, 1);
            
            imageView.clipsToBounds = NO;
            
            [cell.contentView addSubview:imageView];
            YunLog(@"thum_200 = %@",[[items[indexPath.row] objectForKey:@"large_icon_url"] objectForKey:@"thumb_200_200"]);
        
            __weak UIImageView *weakImageView = imageView;
            imageView.contentMode = UIViewContentModeCenter;
            [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([items[indexPath.row] objectForKey:@"icon_url"])]]
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          weakImageView.image = image;
                                          weakImageView.contentMode = UIViewContentModeScaleToFill;
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          [weakImageView setImageWithURL:[NSURL URLWithString:kNullToString([[items[indexPath.row] objectForKey:@"large_icon_url"] objectForKey:@"thumb_200_200"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                          weakImageView.contentMode = UIViewContentModeScaleToFill;
                                      }];
            
            // 名称
            NSString *text = kNullToString([items[indexPath.row] objectForKey:@"name"]);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:kFontFamily size:14] size:CGSizeMake(kScreenWidth - 130, 68)];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(130, 12, kScreenWidth - 140, size.height)];
            title.backgroundColor = kClearColor;
            title.font = [UIFont fontWithName:kFontFamily size:14];
            title.text = text;
            title.numberOfLines = 0;
            
            [cell.contentView addSubview:title];
            
            // 金额和数量
            UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(130, 74, kScreenWidth - 140, 14)];
            money.backgroundColor = kClearColor;
            money.font = [UIFont fontWithName:kFontFamily size:14];
            money.text = [NSString stringWithFormat:@"￥%@ x %@", [items[indexPath.row] objectForKey:@"price"], [items[indexPath.row] objectForKey:@"count"]];
            
            [cell.contentView addSubview:money];
            
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *telTo;
        
        if (alertView.tag == 1) {
            telTo = [NSString stringWithFormat:@"tel://%@", kNullToString([_detail objectForKey:@"consignee_phone"])];
        } else {
            telTo = [NSString stringWithFormat:@"tel://%@", kNullToString([_detail objectForKey:@"buyer_phone"])];
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telTo]];
    }
}

@end
