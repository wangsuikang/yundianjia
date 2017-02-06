//
//  AddressListViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AddressListViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "OrderManager.h"
#import "Tool.h"

// Views
#import "AddressDefaultIcon.h"
#import "UIButtonForBarButton.h"

// Controllers
#import "AddressNewViewController.h"

// Categories
#import "NSObject+NullToString.h"

@interface AddressListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *addresses;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *editbutton;
@property (nonatomic, strong) UIButton *add;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation AddressListViewController

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
        naviTitle.text = @"地址管理";
        
        self.navigationItem.titleView = naviTitle;
        
        _addressType = @"manage";
    }
    
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    // 设置透明导航栏
    //    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    //    {
    //        NSArray *list=self.navigationController.navigationBar.subviews;
    //
    //        for (id obj in list) {
    //
    //            if ([obj isKindOfClass:[UIImageView class]]) {
    //
    //                UIImageView *imageView=(UIImageView *)obj;
    //
    //                imageView.hidden=NO;
    //            }
    //        }
    //    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataSource) name:kAddressUpdate object:nil];
    
    if (_hud) {
        [_hud hide:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [TalkingData trackPageEnd:@"离开地址列表页面"];
    
    [super viewWillDisappear:animated];
    
    if (_hud) {
        [_hud hide:YES];
    }
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
    self.navigationController.navigationBar.translucent = YES;
    
    [self getDataSource];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.tableFooterView = add;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
//    _tableView.editing = YES;
    
    // 添加下面的按钮
    _add = [[UIButton alloc] init];
    _add.frame = CGRectMake(0, CGRectGetMaxY(_tableView.frame), kScreenWidth, 48);
    _add.backgroundColor = [UIColor orangeColor];
    [_add setTitle:@"新增地址" forState:UIControlStateNormal];
    [_add addTarget:self action:@selector(newAddress) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_add];
}

#pragma mark - getData -

- (void)getDataSource
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    NSDictionary *params = @{@"user_session_key"          :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"      :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *listURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kAddressQueryURL params:params];
    
    YunLog(@"address listURL = %@", listURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:listURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YunLog(@"address list responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            
            [_hud hide:YES];
            
            appDelegate.user.addresses = [[responseObject objectForKey:@"data"] objectForKey:@"addresses"];
            _addresses = [[responseObject objectForKey:@"data"] objectForKey:@"addresses"];
            
            if (_addresses.count <= 0) {
                _editbutton.hidden = YES;
            } else {
                _editbutton.hidden = NO;
            }
            
            [_tableView reloadData];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self backToPrev];
        } else {
            [_hud addErrorString:@"网路异常，请稍后再试" delay:2.0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"address list error = %@", error);
        
        [_hud addErrorString:@"网络异常，请稍后再试" delay:2.0];
    }];
}

#pragma mark - Private Functions -

- (void)newAddress
{
    AddressNewViewController *address = [[AddressNewViewController alloc] init];
    
    UINavigationController *addressNC = [[UINavigationController alloc] initWithRootViewController:address];
    
    [self.navigationController presentViewController:addressNC animated:YES completion:nil];
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editTableView:(UIButton *)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"编辑"]) {
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        
        _tableView.editing = YES;
    } else {
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        
        _tableView.editing = NO;
    }
    
    [_tableView reloadData];
}

- (void)pushToEditAddress:(UIButton *)sender
{
    NSDictionary *addressDic = _addresses[sender.tag];
    
    YunLog(@"addressDic = %@", addressDic);
    
    AddressNewViewController *address = [[AddressNewViewController alloc] init];
    address.address = addressDic;
    address.addressArray = _addresses;  //!< 用于在点击完成之后，判断该地址是否存在，存在的话就不新增只是修改内容
    
    UINavigationController *addressNC = [[UINavigationController alloc] initWithRootViewController:address];
    
    [self.navigationController presentViewController:addressNC animated:YES completion:nil];
    
    //    _tableView.editing = NO;
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    
    UIButton *button = (UIButton *)item.customView;
    
    [self editTableView:button];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _addresses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *addressDic = _addresses[indexPath.row];
    YunLog(@"addressDic = %@", addressDic);
    
    NSString *address = [[[kNullToString([addressDic objectForKey:@"address_province"])
                           stringByAppendingString:kNullToString([addressDic objectForKey:@"address_city"])]
                          stringByAppendingString:kNullToString([addressDic objectForKey:@"address_area"])]
                         stringByAppendingString:kNullToString([addressDic objectForKey:@"address_detail"])];
    
    CGSize size = [address sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20, 9999)];
    
    return 50 + size.height + 60;
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
    
    if (kDeviceOSVersion >= 7.0) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([_addressType isEqualToString:@"manage"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.backgroundColor = kBackgroundColor;
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView addSubview:backView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        NSDictionary *addressDic = _addresses[indexPath.row];
        
        // 用户姓名
        UILabel *accountName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, (kScreenWidth - 20) / 2, 40)];
        accountName.backgroundColor = kClearColor;
        accountName.font = kMidFont;
        accountName.text = [addressDic objectForKey:@"contact_name"];
        accountName.textColor = kGrayFontColor;
        
        [backView addSubview:accountName];
        
        // 用户手机号
        UILabel *accountPhone = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 20) / 2, 0, (kScreenWidth - 20) / 2, 40)];
        accountPhone.backgroundColor = kClearColor;
        accountPhone.font = kMidFont;
        accountPhone.text = [addressDic objectForKey:@"contact_phone"];
        accountPhone.textAlignment = NSTextAlignmentRight;
        accountPhone.textColor = kGrayFontColor;
        
        [backView addSubview:accountPhone];
        
        // 地址
        NSString *address = [[[kNullToString([addressDic objectForKey:@"address_province"])
                               stringByAppendingString:kNullToString([addressDic objectForKey:@"address_city"])]
                              stringByAppendingString:kNullToString([addressDic objectForKey:@"address_area"])]
                             stringByAppendingString:kNullToString([addressDic objectForKey:@"address_detail"])];
        
        CGSize size = [address sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20, 9999)];
        
        UILabel *accountAddress = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, kScreenWidth - 49, size.height)];
        accountAddress.backgroundColor = kClearColor;
        accountAddress.numberOfLines = 0;
        accountAddress.text = address;
        accountAddress.font = kMidFont;
        accountAddress.textColor = kGrayFontColor;
        
        [backView addSubview:accountAddress];
        
        // 默认地址按钮
        UIButton *defaultAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [defaultAddressButton setTitle:@"设置为默认地址" forState:UIControlStateNormal];
        [defaultAddressButton setTitle:@"默认地址" forState:UIControlStateSelected];
        [defaultAddressButton setTitleColor:kGrayFontColor forState:UIControlStateNormal];
        [defaultAddressButton setTitleColor:kNaviTitleColor forState:UIControlStateSelected];
        defaultAddressButton.titleLabel.font = kMidFont;
        [defaultAddressButton setImage:[UIImage imageNamed:@"unselect_icon"] forState:UIControlStateNormal];
        [defaultAddressButton setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateSelected];
        defaultAddressButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        defaultAddressButton.contentMode = UIViewContentModeLeft;
        [defaultAddressButton addTarget:self action:@selector(defaultButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        defaultAddressButton.tag = indexPath.row + 10;
        
        defaultAddressButton.frame = CGRectMake(10, CGRectGetMaxY(accountAddress.frame) + 30, 30 + [defaultAddressButton.titleLabel.text sizeWithFont:kMidFont size:CGSizeMake(MAXFLOAT, MAXFLOAT)].width + 1, 30);
        
        [backView addSubview:defaultAddressButton];
        
        // 删除按钮
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton setTitleColor:kGrayFontColor forState:UIControlStateNormal];
        [deleteButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
        deleteButton.titleLabel.font = kMidFont;
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        
        CGSize deleteSize = [deleteButton.titleLabel.text sizeWithFont:kMidFont size:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        deleteButton.frame = CGRectMake(kScreenWidth - 10 - deleteSize.width - 1 - 30, CGRectGetMinY(defaultAddressButton.frame), deleteSize.width + 30 + 1, 30);
        [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = indexPath.row + 20;
        
        [backView addSubview:deleteButton];
        
        // 修改按钮
        UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [changeButton setTitle:@"修改" forState:UIControlStateNormal];
        [changeButton setTitleColor:kGrayFontColor forState:UIControlStateNormal];
        changeButton.titleLabel.font = kMidFont;
        [changeButton setImage:[UIImage imageNamed:@"change_icon"] forState:UIControlStateNormal];
        changeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        
        CGSize changeSize = [changeButton.titleLabel.text sizeWithFont:kMidFont size:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        changeButton.frame = CGRectMake(CGRectGetMinX(deleteButton.frame) - 10 - changeSize.width - 30 - 1, CGRectGetMinY(defaultAddressButton.frame), 30 + changeSize.width + 1, 30);
        [changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        changeButton.tag = indexPath.row + 30;
        
        [backView addSubview:changeButton];
    
        if ([[[_addresses objectAtIndex:indexPath.row] objectForKey:@"is_default"] integerValue] == 1) {
            defaultAddressButton.selected = YES;
            defaultAddressButton.frame = CGRectMake(10, CGRectGetMaxY(accountAddress.frame) + 30, 30 + [defaultAddressButton.titleLabel.text sizeWithFont:kMidFont size:CGSizeMake(MAXFLOAT, MAXFLOAT)].width + 1, 30);
        }
    }
    
    NSDictionary *addressDic = _addresses[indexPath.row];
    YunLog(@"addressDic = %@", addressDic);
    
    NSString *address = [[[kNullToString([addressDic objectForKey:@"address_province"])
                           stringByAppendingString:kNullToString([addressDic objectForKey:@"address_city"])]
                          stringByAppendingString:kNullToString([addressDic objectForKey:@"address_area"])]
                         stringByAppendingString:kNullToString([addressDic objectForKey:@"address_detail"])];
    
    CGSize size = [address sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20, 9999)];
    
    backView.frame = CGRectMake(0, 0, kScreenWidth, size.height + 50 + 50);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isPay) {
        YunLog(@"_addresses = %@", _addresses);
        
        NSString *user_address_id = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"id"] toString];
        [[OrderManager defaultManager] addInfo:user_address_id forKey:@"user_address_id"];
        
        NSString *username = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"contact_name"] toString];
        [[OrderManager defaultManager] addInfo:username forKey:@"username"];
        
        NSString *province = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_province"] toString];
        [[OrderManager defaultManager] addInfo:province forKey:@"province"];
        
        NSString *city = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_city"] toString];
        [[OrderManager defaultManager] addInfo:city forKey:@"city"];
        
        NSString *area = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_area"] toString];
        [[OrderManager defaultManager] addInfo:area forKey:@"area"];
        
        // ------------------------------------------------------------------------------------------
        NSString *province_no = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_province_id"] toString];
        [[OrderManager defaultManager] addInfo:province_no forKey:@"address_province_no"];
        
        NSString *city_no = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_city_id"] toString];
        [[OrderManager defaultManager] addInfo:city_no forKey:@"address_city_no"];
        
        NSString *area_no = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_area_id"] toString];
        [[OrderManager defaultManager] addInfo:area_no forKey:@"address_area_no"];
        
        // ------------------------------------------------------------------------------------------
        
        NSString *detail = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"address_detail"] toString];
        [[OrderManager defaultManager] addInfo:detail forKey:@"detail"];
        
        NSString *phone = [[[_addresses objectAtIndex:indexPath.row] objectForKey:@"contact_phone"] toString];
        [[OrderManager defaultManager] addInfo:phone forKey:@"phone"];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
//        NSDictionary *address = _addresses[indexPath.row];
//        
//        if ([[address objectForKey:@"is_default"] integerValue] == 1) {
//            [_tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            if (_hud) [_hud hide:YES];
//            
//            return;
//        }
//        
//        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        _hud.labelText = @"设置中...";
//        
//        AppDelegate *appDelegate = kAppDelegate;
//        
//        NSDictionary *params = @{@"address_id"              :   kNullToString([address objectForKey:@"id"]),
//                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
//                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
//        
//        NSString *defaultURL = [Tool buildRequestURLHost:kRequestHost
//                                              APIVersion:kAPIVersion1
//                                              requestURL:kAddressSetDefaultURL
//                                                  params:params];
//        
//        YunLog(@"address set defaultURL = %@", defaultURL);
//        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.requestSerializer.timeoutInterval = 30;
//        
//        [manager GET:defaultURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            YunLog(@"address set default responseObject = %@", responseObject);
//            
//            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
//            if ([code isEqualToString:kSuccessCode]) {
//                _addresses = [appDelegate.user setDefaultAddress:indexPath.row];
//            
//                [_tableView reloadData];
//                [_hud addSuccessString:@"设置默认地址成功" delay:2.0];
//            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
//                [Tool resetUser];
//                
//                [self backToPrev];
//            } else {
//                [_hud addErrorString:@"网络异常，请稍后再尝试设置默认地址" delay:2.0];
//            }
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            YunLog(@"address set default error = %@", error);
//            
//            [_hud addErrorString:@"网络异常，请稍后再尝试设置默认地址" delay:2.0];
//        }];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // 禁止滑动删除
        if (!_tableView.isEditing)
            return UITableViewCellEditingStyleNone;
        else {
            return UITableViewCellEditingStyleDelete;
        }
    } else {
        return UITableViewCellEditingStyleNone;
    }
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"删除中...";
        
        AppDelegate *appDelegate = kAppDelegate;
        
        NSDictionary *params = @{@"address_id"              :   kNullToString([_addresses[indexPath.row] objectForKey:@"id"]),
                                 @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                                 @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
        
        NSString *deleteURL = [Tool buildRequestURLHost:kRequestHost
                                             APIVersion:kAPIVersion1
                                             requestURL:kAddressDeleteURL
                                                 params:params];
        
        YunLog(@"deleteURL = %@", deleteURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [manager GET:deleteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"delete address responseObject = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                [_hud addSuccessString:@"删除成功" delay:2.0];
                
                NSMutableArray *temp = [NSMutableArray arrayWithArray:_addresses];
                [temp removeObjectAtIndex:indexPath.row];
                
                _addresses = [NSArray arrayWithArray:temp];
                
                appDelegate.user.addresses = [NSArray arrayWithArray:_addresses];
                
//                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                if (_addresses.count <= 0) {
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"username"];
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"province"];
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"city"];
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"area"];
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"detail"];
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"phone"];
                    [[OrderManager defaultManager] addInfo:@"" forKey:@"user_address_id"];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                        
                        _editbutton.hidden = YES;
                    });
                }
            } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                [Tool resetUser];
                
                [self backToPrev];
            } else {
                [_hud addErrorString:responseObject[@"status"][@"message"] delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"delete address error = %@", error);
            
            [_hud addErrorString:@"地址删除失败" delay:2.0];
        }];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)defaultButtonClick:(UIButton *)sender
{
    YunLog(@"sender.tag = %ld", sender.tag);
    
    NSDictionary *address = _addresses[sender.tag - 10];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"设置中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"address_id"              :   kNullToString([address objectForKey:@"id"]),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *defaultURL = [Tool buildRequestURLHost:kRequestHost
                                          APIVersion:kAPIVersion1
                                          requestURL:kAddressSetDefaultURL
                                              params:params];
    
    YunLog(@"address set defaultURL = %@", defaultURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:defaultURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        YunLog(@"address set default responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            _addresses = [appDelegate.user setDefaultAddress:sender.tag - 10];
            
            [_tableView reloadData];
            [_hud addSuccessString:@"设置默认地址成功" delay:2.0];
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self backToPrev];
        } else {
            [_hud addErrorString:@"网络异常，请稍后再尝试设置默认地址" delay:2.0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        YunLog(@"address set default error = %@", error);
        
        [_hud addErrorString:@"网络异常，请稍后再尝试设置默认地址" delay:2.0];
    }];
}

- (void)changeButtonClick:(UIButton *)sender
{
    NSDictionary *addressDic = _addresses[sender.tag - 30];
    
    YunLog(@"addressDic = %@", addressDic);
    
    AddressNewViewController *address = [[AddressNewViewController alloc] init];
    address.address = addressDic;
    address.addressArray = _addresses;  //!< 用于在点击完成之后，判断该地址是否存在，存在的话就不新增只是修改内容
    
    UINavigationController *addressNC = [[UINavigationController alloc] initWithRootViewController:address];
    
    [self.navigationController presentViewController:addressNC animated:YES completion:nil];
    
    //    _tableView.editing = NO;
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    
    UIButton *button = (UIButton *)item.customView;
    
    [self editTableView:button];
}

- (void)deleteButtonClick:(UIButton *)sender
{
    YunLog(@"sender.tag = %ld", sender.tag);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"删除中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"address_id"              :   kNullToString([_addresses[sender.tag - 20] objectForKey:@"id"]),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *deleteURL = [Tool buildRequestURLHost:kRequestHost
                                         APIVersion:kAPIVersion1
                                         requestURL:kAddressDeleteURL
                                             params:params];
    
    YunLog(@"deleteURL = %@", deleteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:deleteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"delete address responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            [_hud addSuccessString:@"删除成功" delay:2.0];
            
            NSMutableArray *temp = [NSMutableArray arrayWithArray:_addresses];
            [temp removeObjectAtIndex:sender.tag - 20];
            
            _addresses = [NSArray arrayWithArray:temp];
            
            appDelegate.user.addresses = [NSArray arrayWithArray:_addresses];
            
//            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag - 20 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            if (_addresses.count <= 0) {
                [[OrderManager defaultManager] addInfo:@"" forKey:@"username"];
                [[OrderManager defaultManager] addInfo:@"" forKey:@"province"];
                [[OrderManager defaultManager] addInfo:@"" forKey:@"city"];
                [[OrderManager defaultManager] addInfo:@"" forKey:@"area"];
                [[OrderManager defaultManager] addInfo:@"" forKey:@"detail"];
                [[OrderManager defaultManager] addInfo:@"" forKey:@"phone"];
                [[OrderManager defaultManager] addInfo:@"" forKey:@"user_address_id"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    
                    _editbutton.hidden = YES;
                });
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    
                });
            }
        } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
            [Tool resetUser];
            
            [self backToPrev];
        } else {
            [_hud addErrorString:responseObject[@"status"][@"message"] delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"delete address error = %@", error);
        
        [_hud addErrorString:@"地址删除失败" delay:2.0];
    }];
}

@end
