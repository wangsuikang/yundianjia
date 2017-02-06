//
//  MyVariantDetailViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14/11/18.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyVariantDetailViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

typedef NS_ENUM(NSInteger, VariantTextFieldTag) {
    VariantTitleTag = 1001,
    VariantSubtitleTag = 1002,
    VariantPriceTag = 1003,
    VariantMarketPriceTag = 1004,
    VariantInventoryTag = 1005,
    VariantStatusTag = 1006
};

@interface MyVariantDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *commitButton;

@property (nonatomic, strong) NSDictionary *variant;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyVariantDetailViewController

#pragma mark - Life Cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = @"规格详情";
    
    self.navigationItem.titleView = naviTitle;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(0, 0, 25, 25);
    [refreshButton setImage:[UIImage imageNamed:@"refresh_button"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    refreshItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = refreshItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _commitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - 48, kScreenWidth, 48)];
    _commitButton.backgroundColor = [UIColor orangeColor];
    [_commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commitButton addTarget:self action:@selector(commitVariant:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_commitButton];

    [self getVariantDetail:nil];
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

- (void)refreshView:(UIButton *)button
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1e100;
    
    [button.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [self getVariantDetail:^{
        [button.layer removeAnimationForKey:@"rotationAnimation"];
    }];
}

- (void)getVariantDetail:(void(^)(void))callback
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"code"                    :   kNullToString(_code),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *detailURL = [Tool buildRequestURLHost:kRequestHost
                                         APIVersion:kAPIVersion2
                                         requestURL:kProductVariantDetailForManagerURL
                                             params:params];
    
    YunLog(@"variant detail url = %@", detailURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:detailURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"variant detail responseObject = %@", responseObject);
             
             if ([responseObject[@"status"][@"code"] isEqualToString:kSuccessCode]) {
                 _variant = responseObject[@"data"][@"variant"];
                 
                 _tableView.dataSource = self;
                 
                 [_tableView reloadData];
                 
                 if (callback) {
                     callback();
                 }
                 
                 [_hud hide:YES];
             }
             
             else {
                 [_hud addErrorString:@"获取商品规格数据异常" delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"variant detail error = %@", error);
             
             [_hud addErrorString:@"获取商品规格数据异常" delay:2.0];
         }];
}

- (void)commitVariant:(UIButton *)button
{
    
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35;
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return 100;
    }
    
    else {
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case 0:
        {
            title = @"基本信息";
            
            break;
        }
            
        case 1:
        {
            title = @"规格状态";
            
            break;
        }
            
        case 2:
        {
            title = @"规格图片";
            
            break;
        }
            
        default:
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"标题";
                    cell.detailTextLabel.text = kNullToString(_variant[@"name"]);
                    
                    break;
                }
                    
                case 1:
                {
                    cell.textLabel.text = @"副标题";
                    cell.detailTextLabel.text = kNullToString(_variant[@"subtitle"]);
                    
                    break;
                }
                    
                case 2:
                {
                    cell.textLabel.text = @"价格";
                    cell.detailTextLabel.text = [@"￥" stringByAppendingFormat:@"%@", kNullToString(_variant[@"price"])];
                    
                    break;
                }
                    
                case 3:
                {
                    cell.textLabel.text = @"市场价";
                    
                    if (![_variant[@"market_price"] isEqualToString:@"0"] && ![_variant[@"market_price"] isEqualToString:@"0.0"]) {
                        cell.detailTextLabel.text = [@"￥" stringByAppendingFormat:@"%@", kNullToString(_variant[@"market_price"])];
                    }
                    
                    break;
                }
                    
                case 4:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    cell.textLabel.text = @"销量";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", kNullToString(_variant[@"sales_quantity"])];
                    
                    break;
                }
                    
                case 5:
                {
                    cell.textLabel.text = @"库存";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", kNullToString(_variant[@"inventory_quantity"])];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.textLabel.text = kNullToString(_variant[@"status"]);
            
            break;
        }
            
        case 2:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 108, 80)];
            [imageView setImageWithURL:[NSURL URLWithString:kNullToString(_variant[@"small_icon"])]
                      placeholderImage:[UIImage imageNamed:@"default_image"]];
            
            [cell.contentView addSubview:imageView];
            
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改规格标题"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = VariantTitleTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                case 1:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改规格副标题"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = VariantSubtitleTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                case 2:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改规格价格"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = VariantPriceTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                case 3:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改规格市场价格"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = VariantMarketPriceTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                case 5:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改规格库存"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = VariantInventoryTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 1:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改商品状态"
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"待发布", @"发布", @"关闭", nil];
            
            [actionSheet showInView:self.view];
            
            break;
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case VariantTitleTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_variant];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"name"];
                
                _variant = [NSDictionary dictionaryWithDictionary:temp];
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        case VariantSubtitleTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_variant];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"subtitle"];
                
                _variant = [NSDictionary dictionaryWithDictionary:temp];
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        case VariantPriceTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_variant];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"price"];
                
                _variant = [NSDictionary dictionaryWithDictionary:temp];
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        case VariantMarketPriceTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_variant];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"market_price"];
                
                _variant = [NSDictionary dictionaryWithDictionary:temp];
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        case VariantInventoryTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_variant];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"inventory_quantity"];
                
                _variant = [NSDictionary dictionaryWithDictionary:temp];
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    switch (alertView.tag) {
        case VariantTitleTag:
        {
            textField.text = _variant[@"name"];
            
            break;
        }
            
        case VariantSubtitleTag:
        {
            textField.text = _variant[@"subtitle"];
            
            break;
        }
            
        case VariantPriceTag:
        {
            textField.text = kNullToString(_variant[@"price"]);
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            break;
        }
            
        case VariantMarketPriceTag:
        {
            textField.text = kNullToString(_variant[@"market_price"]);
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            break;
        }
            
        case VariantInventoryTag:
        {
            textField.text = [NSString stringWithFormat:@"%@", kNullToString(_variant[@"inventory_quantity"])];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate - 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSArray *statuses = @[@"待发布（待售）", @"发布（正在销售）", @"关闭（已下架）"];
        
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_variant];
        
        [temp setObject:statuses[buttonIndex] forKey:@"status"];
        [temp setObject:[NSString stringWithFormat:@"%ld", (long)buttonIndex + 1] forKey:@"status_code"];
        
        _variant = [NSDictionary dictionaryWithDictionary:temp];
        
        [_tableView reloadData];
    }
}

@end
