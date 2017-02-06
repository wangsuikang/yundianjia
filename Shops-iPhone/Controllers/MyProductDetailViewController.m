//
//  MyProductDetailViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14/11/5.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MyProductDetailViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Views
#import "LineSpaceLabel.h"

// Controllers
#import "ProductPhotoBrowserViewController.h"
#import "MyVariantDetailViewController.h"

typedef NS_ENUM(NSInteger, DetailTextFieldTag) {
    DetailTitleTag = 1001,
    DetailSubtitleTag = 1002
};

@interface MyProductDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MWPhotoBrowserDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSDictionary *product;

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *commitButton;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyProductDetailViewController

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
    naviTitle.text = _productName;
    
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
//    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _commitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - 48, kScreenWidth, 48)];
    _commitButton.backgroundColor = [UIColor orangeColor];
    [_commitButton setTitle:@"提交" forState:UIControlStateNormal];
    [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commitButton addTarget:self action:@selector(commitProduct:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_commitButton];
    
    [self getProductDetail:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _imageScrollView.delegate = nil;
    _tableView.delegate = nil;
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commitProduct:(UIButton *)button
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"修改商品...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"code"                    :   kNullToString(_productCode),
                             @"name"                    :   kNullToString(_product[@"name"]),
                             @"subtitle"                :   kNullToString(_product[@"subtitle"]),
                             @"status"                  :   kNullToString(_product[@"status_code"]),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"          :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *modifyURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kProductModifyURL params:nil];
    
    YunLog(@"modifyURL = %@", modifyURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager POST:modifyURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"modify product responseObject = %@", responseObject);
              
              [_hud addSuccessString:@"修改成功" delay:2.0];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              YunLog(@"modify product error = %@", error);
              
              [_hud addErrorString:@"修改商品失败" delay:2.0];
          }];
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
    
    [self getProductDetail:^{
        [button.layer removeAnimationForKey:@"rotationAnimation"];
    }];
}

- (void)getProductDetail:(void (^)(void))callback
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"code"                    :   kNullToString(_productCode),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *descURL = [Tool buildRequestURLHost:kRequestHost
                                       APIVersion:kAPIVersion2
                                       requestURL:kProductDetailForManagerURL
                                           params:params];
    
    YunLog(@"product detail url = %@", descURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:descURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product detail responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 _product = [[responseObject objectForKey:@"data"] objectForKey:@"product"];
                 
                 _tableView.dataSource = self;
                 
                 [_tableView reloadData];
                 
                 [_hud hide:YES];
                 
                 if (callback) {
                     callback();
                 }
             }
             
             else {
                 [_hud addErrorString:@"获取商品详情数据异常" delay:1.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"product detail error = %@", error);
             
             [_hud addErrorString:@"获取商品详情数据异常" delay:1.0];
         }];
}

- (void)pushImageDetail
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"skuid"                   :   kNullToString(_product[@"code"]),
                             @"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey)};
    
    NSString *detailURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion1 requestURL:kProductDetailURL params:params];
    
    YunLog(@"product image detail url = %@", detailURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:detailURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"product image detail responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 [_hud hide:YES];
                 
                 NSArray *images = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"images"]);
                 
                 if (images.count > 0) {
                     [_photos removeAllObjects];
                     
                     _photos = [NSMutableArray arrayWithArray:images];
                 }
                 
                 // Create browser
                 ProductPhotoBrowserViewController *browser = [[ProductPhotoBrowserViewController alloc] initWithDelegate:self];
                 
                 // 图片浏览器属性设置
                 browser.displayActionButton = NO;
                 browser.displayNavArrows = NO;
                 browser.displaySelectionButtons = NO;
                 browser.alwaysShowControls = YES;
                 browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                 browser.wantsFullScreenLayout = YES;
#endif
                 browser.enableGrid = NO;
                 browser.startOnGrid = NO;
                 browser.enableSwipeToDismiss = NO;
                 [browser setCurrentPhotoIndex:0];
                 
                 // 商品信息属性
                 browser.productName = kNullToString([_product objectForKey:@"name"]);
//                 browser.shopCode = kNullToString(_shopCode);
                 
                 [self.navigationController pushViewController:browser animated:YES];
             } else {
                 [_hud addErrorString:@"获取商品图文详情数据异常" delay:2.0];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if ([operation isCancelled]) {
                 [_hud hide:YES];
             } else {
                 YunLog(@"product desc error = %@", error);
                 
                 [_hud addErrorString:@"获取商品图文详情数据异常" delay:2.0];
             }
         }];
}

#pragma mark - MWPhotoBrowserDelegate -

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photos.count)
        return [MWPhoto photoWithURL:[NSURL URLWithString:kNullToString(_photos[index][@"icon"])]];
    
    return nil;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 5;
    }
    
    else if (section == 3) {
        NSArray *variants = kNullToArray(_product[@"product_variants"]);
        
        return variants.count;
    }
    
    else {
        return 1;
    }
//    NSInteger number = 1;
//    
//    switch (section) {
//        case 0:
//        {
//            number = 1;
//            
//            break;
//        }
//            
//        case 1:
//        {
//            number = 6;
//            
//            break;
//        }
//            
//        case 2:
//        {
//            number = 1;
//            
//            break;
//        }
//            
//        default:
//            break;
//    }
//    
//    return number;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case 0:
        {
            break;
        }
            
        case 1:
        {
            title = @"基本信息";
            
            break;
        }
            
        case 2:
        {
            title = @"商品状态";
            
            break;
        }
            
        case 3:
        {
            title = @"规格列表";
            
            break;
        }
            
        case 4:
        {
            title = @"图文详情";
            
            break;
        }
            
        default:
            break;
    }
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1;
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
    if (indexPath.section == 0) {
        return 200;
    }
    else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    else {
        if (cell.contentView.subviews.count > 0) {
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
        }
    }
    
    switch (indexPath.section) {
        case 0:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((kScreenWidth - 320) / 2, 0, 320, 200)];
            _imageScrollView.showsVerticalScrollIndicator = NO;
            _imageScrollView.showsHorizontalScrollIndicator = NO;
            _imageScrollView.pagingEnabled = YES;
            _imageScrollView.delegate = self;
            
            [cell.contentView addSubview:_imageScrollView];
            
            NSArray *images = kNullToArray([_product objectForKey:@"images"]);
            
            if (images.count > 0) {
                for (int i = 0; i < images.count; i++) {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320, 0, 320, 200)];
                    imageView.contentMode = UIViewContentModeCenter;
                    
                    NSString *imageURL = kNullToString([images[i] objectForKey:@"icon"]);
                    
                    __weak UIImageView *_imageView = imageView;
                    
                    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
                                      placeholderImage:[UIImage imageNamed:@"default_image"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                                   _imageView.image = image;
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   
                                               }];
                    
                    [_imageScrollView addSubview:imageView];
                }
                
                _imageScrollView.contentSize = CGSizeMake(320 * images.count, 200);
            } else {
                _imageScrollView.frame = CGRectZero;
            }
            
            if (images.count > 1) {
                _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(320 - images.count * 20 - 10, 180, images.count * 20 + 20, 20)];
                
                _pageControl.numberOfPages = images.count;
                _pageControl.currentPage = 0;
                
                if (kDeviceOSVersion >= 6.0) {
                    _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
                    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
                }
                
                [cell.contentView addSubview:_pageControl];
            }
            
            break;
        }
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"标题";
                    cell.detailTextLabel.text = _product[@"name"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    break;
                }
                    
                case 1:
                {
                    cell.textLabel.text = @"副标题";
                    cell.detailTextLabel.text = _product[@"subtitle"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    break;
                }
                    
                case 2:
                {
                    cell.textLabel.text = @"价格";
                    cell.detailTextLabel.text = [@"￥" stringByAppendingFormat:@"%@", kNullToString(_product[@"price"])] ;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                }
                    
                case 3:
                {
                    cell.textLabel.text = @"库存";
                    cell.detailTextLabel.text = _product[@"inventory_quantity"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                }
                    
                case 4:
                {
                    cell.textLabel.text = @"销量";
                    cell.detailTextLabel.text = _product[@"sales_quantity"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 2:
        {
            cell.textLabel.text = kNullToString(_product[@"status"]);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        }
            
        case 3:
        {
            cell.textLabel.text = kNullToString(_product[@"product_variants"][indexPath.row][@"name"]);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        }
            
        case 4:
        {
            cell.textLabel.text = @"查看详情";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
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
            break;
        }
            
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改标题"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = DetailTitleTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                case 1:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改副标题"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"取消"
                                                              otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alertView.tag = DetailSubtitleTag;
                    
                    [alertView show];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case 2:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改商品状态"
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"待发布", @"发布", @"关闭", @"预售", nil];
            
            [actionSheet showInView:self.view];
            
            break;
        }
            
        case 3:
        {
            MyVariantDetailViewController *detail = [[MyVariantDetailViewController alloc] init];
            detail.code = kNullToString(_product[@"product_variants"][indexPath.row][@"sku_code"]);
            detail.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:detail animated:YES];
            
            break;
        }
            
        case 4:
        {
            break;
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    _pageControl.currentPage = page;
}

#pragma mark - UIActionSheetDelegate -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSArray *statuses = @[@"待发布（待售）", @"发布（正在销售）", @"关闭（已下架）", @"预售（正在销售）"];
        
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_product];
        
        [temp setObject:statuses[buttonIndex] forKey:@"status"];
        [temp setObject:[NSString stringWithFormat:@"%ld", (long)buttonIndex + 1] forKey:@"status_code"];
        
        _product = [NSDictionary dictionaryWithDictionary:temp];
        
        [_tableView reloadData];
    }
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case DetailTitleTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_product];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"name"];
                
                _product = [NSDictionary dictionaryWithDictionary:temp];
                
                [_tableView reloadData];
            }
            
            break;
        }
            
        case DetailSubtitleTag:
        {
            if (buttonIndex == 1) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:_product];
                
                UITextField *textField = [alertView textFieldAtIndex:0];
                
                [temp setObject:textField.text forKey:@"subtitle"];
                
                _product = [NSDictionary dictionaryWithDictionary:temp];
                
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
    switch (alertView.tag) {
        case DetailTitleTag:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            textField.text = _product[@"name"];
            
            break;
        }

        case DetailSubtitleTag:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            textField.text = _product[@"subtitle"];
            
            break;
        }
            
        default:
            break;
    }
}

@end
