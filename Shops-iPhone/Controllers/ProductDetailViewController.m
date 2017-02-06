//
//  ProductDetailViewController.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-07.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "ProductDetailViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "CartManager.h"

// Views
#import "UILabelWithLine.h"
#import "KLCPopup.h"
#import "YunShareView.h"

// Controllers
#import "LoginViewController.h"
#import "PayCenterForUserViewController.h"
#import "RightPanNavigationController.h"
#import "ShopInfoViewController.h"
#import "ShopInfoNewController.h"
#import "CartNewViewController.h"
#import "CommentListViewController.h"

// Categories
#import "NSObject+NullToString.h"
#import "UIView+AddBadge.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+LoadImageFromWeb.h"
#import "NSString+Tools.h"

// Libraries
#import "AFNetworking.h"
#import "MWPhotoBrowser.h"
#import "ProductPhotoBrowserViewController.h"

// Frameworks
#import <QuartzCore/QuartzCore.h>

#define kSpace 5

@interface ProductDetailViewController () <UIScrollViewDelegate, UIActionSheetDelegate, MWPhotoBrowserDelegate, YunShareViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) UILabel *naviTitle;
@property (nonatomic, strong) UILabel *favoriteTittle;
@property (nonatomic, strong) UIButton *favorite;

@property (nonatomic, strong) UIButton *lastSelectedButton;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) UIPageControl   *pageControl;
@property (nonatomic, strong) UIScrollView    *variantsSelectView;

@property (nonatomic, strong) NSDictionary    *product_variants;
@property (nonatomic, copy  ) NSString        *favoriteID;
@property (nonatomic, strong) UIBarButtonItem *favoriteItem;
@property (nonatomic, strong) UIButton        *bottomCart;

@property (nonatomic, strong) UILabel         *priceLabel;
@property (nonatomic, strong) UILabel         *saledLabel;
@property (nonatomic, strong) UILabel         *inventoryLabel;
@property (nonatomic, strong) UILabel         *variantName;
@property (nonatomic, strong) UILabel         *variantSubtitle;
@property (nonatomic, strong) UIImageView     *variantImageView;
@property (nonatomic, strong) UILabelWithLine *marketPriceLabel;
@property (nonatomic, strong) UILabel         *promotionsLabel;

@property (nonatomic, strong) NSMutableArray  *photos;
@property (nonatomic, strong) NSArray         *sku_categories;
@property (nonatomic, strong) NSDictionary    *sku_variants;
@property (nonatomic, strong) NSDictionary    *product_guide;
@property (nonatomic, strong) NSDictionary    *product_detail;
@property (nonatomic, strong) NSArray         *product_promotions;
@property (nonatomic, strong) NSMutableArray  *variantsIdArray;
@property (nonatomic, assign) NSInteger       selectedVariant;
@property (nonatomic, copy  ) NSString        *selectedNewVariant;
@property (nonatomic, assign) CGFloat         scrollHeight;
@property (nonatomic, assign) NSInteger       cartCount;

@property (nonatomic, strong) MBProgressHUD   *hud;

/// 记录及时高度
@property (nonatomic, assign) CGFloat         height;

/// 商品字典
@property (nonatomic, strong) NSMutableDictionary    *product;

/// 商铺字典
@property (nonatomic, strong) NSDictionary    *shop;

/// 选中规格的商品图片
@property (nonatomic, strong) UIImageView   *seletedIcon;

/// 商品详情底部工具条
@property (nonatomic, strong) UIView *bottomView;

/// 商品规格遮盖层
@property (nonatomic, strong) UIView *cover;

/// 商品规格背景层
@property (nonatomic, strong) UIView *backView;

/// 商品规格第一个属性最后一次选项
@property (nonatomic, strong) UIButton *lastSelectedType1;

/// 商品规格第二个属性最后一次选项
@property (nonatomic, strong) UIButton *lastSelectedType2;

/// 商品规格第三个属性最后一次选项
@property (nonatomic, strong) UIButton *lastSelectedType3;

/// 商品规格数量label
@property (nonatomic, strong) UILabel *countLabel;

/// 商品规格视图的会员价
@property (nonatomic, strong) UILabel *memberPrice;

/// 商品规格视图的市场价
@property (nonatomic, strong) UILabel *marketPrice;

/// 商品规格视图的库存
@property (nonatomic, strong) UILabel *inventoryQuantityLabel;

/// 当前规格的商品详情
@property (nonatomic ,strong) NSDictionary *variant;

/// 是否是查看商品规格
@property (nonatomic, assign) BOOL isEnterVariantsData;

/// 是否是加入购物车
@property (nonatomic, assign) BOOL isAddToCart;

/// 规格视图底部工具条
@property (nonatomic, strong) UIView *bottomViewDetail;

@end

@implementation ProductDetailViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kNaviTitleColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        
        self.navigationItem.titleView = _naviTitle;
        
        _photos = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
    self.tabBarController.tabBar.hidden = YES;
    
    _cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
    if (_cartCount <= 0) {
        [_bottomCart removeBadge];
    } else {
        [_bottomCart removeBadge];
        [_bottomCart addBadge:[NSString stringWithFormat:@"%ld", (long)_cartCount]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isCartEnterProductDetail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
    
    UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
    NSString *cartCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"];
    if ([cartCount intValue] == 0) {
        cartVC.tabBarItem.badgeValue = nil;
    } else {
        cartVC.tabBarItem.badgeValue = cartCount;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    _product = [NSMutableDictionary dictionary];
    _product_variants = [NSDictionary dictionary];
    _sku_categories = [NSArray array];
    _sku_variants = [NSDictionary dictionary];
    _product_guide = [NSDictionary dictionary];
    _product_detail = [NSDictionary dictionary];
    _product_promotions = [NSArray array];
    _variantsIdArray = [NSMutableArray array];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    if (!_isAdmin) {
        _bottomCart = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 32.5, 30)];
        
        [_bottomCart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
        [_bottomCart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *bottomCartItem = [[UIBarButtonItem alloc] initWithCustomView:_bottomCart];
        bottomCartItem.style = UIBarButtonItemStylePlain;

        NSMutableArray *rightItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
        [rightItems addObject:bottomCartItem];

        self.navigationItem.rightBarButtonItems = rightItems;
        
//        _cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
//        if (_cartCount <= 0) {
//            [_bottomCart removeBadge];
//        } else {
//            [_bottomCart removeBadge];
//            [_bottomCart addBadge:[NSString stringWithFormat:@"%ld", _cartCount]];
//        }
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    [self.view addSubview:_scrollView];
    
    [self getBasicData];
    
//    AppDelegate *appDelegate = kAppDelegate;
//    if (appDelegate.isLogin && !_isAdmin) {
//        [self checkFavorite];
//    }
//    [self getProductPromotions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _scrollView.delegate = nil;
    
//    _photos = nil;
//    
//    _product_guide = nil;
}

#pragma mark - Get Product Data -

/**
 获取商品的基本信息
 */
- (void)getBasicData
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    //        NSString *descURL = [Tool buildRequestURLHost:kRequestHost APIVersion:kAPIVersion2 requestURL:kProductDescURL params:params];
    //
    //        YunLog(@"product desc url = %@", descURL);
    
    NSString *descURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductBasicURL,_productCode] params:@{@"shop_code"   :   kNullToString(_shopCode)}];
    
    YunLog(@"product desc url = %@", descURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    
    [manager GET:descURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"responseProductDetail = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                 // 添加我的浏览历史
                 if (appDelegate.isLogin && !_isAdmin) {
                     [self addMyHistory];
                 }
                 
//                 _hud.hidden = YES;
                 _product = [NSMutableDictionary dictionaryWithDictionary:[[responseObject objectForKey:@"data"] objectForKey:@"product"]];
                 _shop = [[responseObject objectForKey:@"data"] objectForKey:@"shop"];
                 
//                 if (![[[_product objectForKey:@"status"] stringValue] isEqualToString:@"3"])
//                 {
//                     // right bar button item
//                     UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 30, 32)];
//                     [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
//                     [share addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
//                     
//                     UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:share];
//                     shareItem.style = UIBarButtonItemStylePlain;
//                     
//                     NSMutableArray *rightItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
//                     [rightItems addObject:shareItem];
//                     
//                     self.navigationItem.rightBarButtonItems = rightItems;
//                 }
                 _naviTitle.text = kNullToString([_product objectForKey:@"title"]);

                 if (!_isAdmin)
                 {
                     _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
                 }
                 else
                 {
                     _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                 }
                 
                 if (kDeviceOSVersion < 7.0) {
                     if (!_isAdmin)
                     {
                         _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64);
                     }
                     else
                     {
                         _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 16);
                     }
                 }
                 
                 //                 if ([[_product objectForKey:@"inventory_quantity"] integerValue] > 0) {
                 //                     _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 48);
                 //                 } else {
                 //                     if (kDeviceOSVersion < 7.0) {
                 //                         _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64);
                 //                     }
                 //                 }
                 
                 //                 NSDictionary *parameters = @{@"uuid"           :   [Tool getUniqueDeviceIdentifier],
                 //                                              @"product_name"   :   kNullToString([_product objectForKey:@"name"]),
                 //                                              @"product_id"     :   kNullToString([_product objectForKey:@"sku_id"])};
                 //
                 //                 [TalkingData trackEvent:@"查看商品" label:@"商品详情" parameters:parameters];
                 
                
//                 [self getVariantsData];
                 
                 [self getProductPromotions];
                 
//                 if (!_isAdmin) {
//                     [self checkFavorite];
//                 }
             } else {
                 [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"product desc error = %@", error);
             
             [_hud addErrorString:@"获取商品详情数据异常" delay:1.5];
         }];
}

/**
 获取商品图文详情数据
 */
- (void)getImageDetail:(UIButton *)sender
{
    if (sender) {
        _lastSelectedButton.selected = NO;
        _lastSelectedButton = sender;
        sender.selected = YES;
    }
    
    [_detailView removeFromSuperview];
    _detailView = nil;
    
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(0, _height, kScreenWidth, 0)];
    
    [_scrollView addSubview:_detailView];
    
    if (_photos.count > 0 && [_photos[0] isKindOfClass:[NSDictionary class]]) {
        [self createImageDetail];
    }
    else if (_photos.count > 0 && [_photos[0] isKindOfClass:[NSString class]])
    {
        [self createImageWebDetail];
    }
    else
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        
        //    AppDelegate *appDelegate = kAppDelegate;
        
        //    NSDictionary *params = @{@"code"                   :   kNullToString(_productCode)};
        
        NSString *detailURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductImageWapURL, _productCode] params:nil];
        
        YunLog(@"product image detail url = %@", detailURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 15;
        
        [manager GET:detailURL
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 YunLog(@"product image detail responseObject = %@", responseObject);
                 
                 if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                     NSArray *images = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"product_images"]);
                     
                     if (images.count > 0) {
                         [_hud hide:YES];
                         
                         //                     [_photos removeAllObjects];
            
                         _photos = [NSMutableArray arrayWithArray:images];
                         
                         [self createImageDetail];
                         //
                         //                     // Create browser
                         //                     ProductPhotoBrowserViewController *browser = [[ProductPhotoBrowserViewController alloc] initWithDelegate:self];
                         //
                         //                     // 图片浏览器属性设置
                         //                     browser.displayActionButton     = NO;
                         //                     browser.displayNavArrows        = NO;
                         //                     browser.displaySelectionButtons = NO;
                         //                     browser.alwaysShowControls      = YES;
                         //                     browser.zoomPhotosToFill        = YES;
                         //#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                         //                     browser.wantsFullScreenLayout   = YES;
                         //#endif
                         //                     browser.enableGrid              = NO;
                         //                     browser.startOnGrid             = NO;
                         //                     browser.enableSwipeToDismiss    = NO;
                         //                     [browser setCurrentPhotoIndex:0];
                         //
                         //                     // 商品信息属性
                         ////                     browser.productName = kNullToString([_product objectForKey:@"name"]);
                         ////                     browser.shopCode    = kNullToString(_shopCode);
                         ////                     browser.variant     = [_product objectForKey:@"product_variants"][_selectedVariant - 1000];
                         //
                         //                     [self.navigationController pushViewController:browser animated:YES];
                     } else {
                         _hud.hidden = YES;
                         [self createImageDetail];
                     }
                 } else {
                     NSString *imageURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductDescImageURL, _productCode] params:nil];
                     
                     YunLog(@"product image detail url = %@", imageURL);
                     
                     [manager GET:imageURL
                       parameters:nil
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              YunLog(@"product image detail responseObject = %@", responseObject);
                              
                              if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode]) {
                                  NSMutableString *temp = kNullToString([kNullToDictionary([[responseObject objectForKey:@"data"] objectForKey:@"product_desc"]) objectForKey:@"body_html"]);
                                  
                                  NSArray *images = [NSArray array];
                                  
                                  if (![temp isEqualToString:@""]) {
                                      NSArray *arr = [temp componentsSeparatedByString:@"src=\""];
                                      
                                      YunLog(@"arr = %@", arr);
                                      
                                      NSArray *array = [arr.lastObject componentsSeparatedByString:@"\" title"];
                                      
                                      images = [NSArray arrayWithObject:array.firstObject];
                                  }
                                  
                                  if (images.count > 0) {
                                      [_hud hide:YES];
                                      
                                      _photos = [NSMutableArray arrayWithArray:images];
                                      
                                      [self createImageWebDetail];
                                  } else {
                                      _hud.hidden = YES;
                                      [self createImageWebDetail];
                                  }
                              } else {
                                  _hud.hidden = YES;
                                  [self createImageWebDetail];
                              }
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              if ([operation isCancelled]) {
                                  [_hud hide:YES];
                              } else {
                                  YunLog(@"product desc error = %@", error);
                                  
                                  [self createImageWebDetail];
                                  
                                  _scrollView.contentSize = CGSizeMake(kScreenWidth, _height);
                              }
                          }];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if ([operation isCancelled]) {
                     [_hud hide:YES];
                     
                 } else {
                     YunLog(@"product desc error = %@", error);
                     
                     [self createImageDetail];
                     
                     //                     [_hud addErrorString:@"获取图文详情数据异常" delay:1.5];
                     
                     _scrollView.contentSize = CGSizeMake(kScreenWidth, _height);
                 }
             }];
        
    }
}

/**
 获取促销信息
 */
- (void)getProductPromotions
{
    NSString *promotionsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductPromotions,_productCode] params:nil];
    
    YunLog(@"product promotions url = %@", promotionsURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    
    [manager GET:promotionsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"pro res = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _hud.hidden = YES;
            _product_promotions = [[responseObject objectForKey:@"data"] objectForKey:@"promotion_activities"];
            
            YunLog(@"promotion_activities = %@", _product_promotions);
            
            [self createUI];
            
            [self getImageDetail:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        _hud.hidden = YES;
    }];
}

/**
 获取规格信息
 */
- (void)getVariantsData:(UIButton *)sender
{
    if (sender.tag == 100) {
        _isEnterVariantsData = YES;
        _isAddToCart = NO;
    } else if (sender.tag == 200) {
        _isEnterVariantsData = NO;
        _isAddToCart = NO;
    } else {
        _isEnterVariantsData = NO;
        _isAddToCart = YES;
    }
    
    if (_product_variants.count == 0)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"正在获取规格详情...";
        
        NSDictionary *params = @{@"code"                    :               kNullToString(_productCode)};
        
        NSString *variantsURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kProductVariants params:params];
        
        YunLog(@"product variants url = %@", variantsURL);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 15;
        
        [manager GET:variantsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"responseObject Variants = %@", responseObject);
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            
            if ([code isEqualToString:kSuccessCode]) {
                _hud.hidden = YES;
                _product_variants = [[responseObject objectForKey:@"data"] objectForKey:@"product_variants"];
                
                _sku_categories = _product_variants[@"sku_categories"];
                _sku_variants = _product_variants[@"variants"];
                
                [self createVariantUI];
            } else {
                [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"product varitant error = %@", error);
            
            [_hud addErrorString:@"获取数据失败" delay:2.0];
        }];
    }
    else
    {
        [self showVariantUI];
    }
}

/**
 获取商品购买须知
*/
- (void)getGuideData:(UIButton *)sender
{
    _lastSelectedButton.selected = NO;
    _lastSelectedButton = sender;
    sender.selected = YES;
  
    [_detailView removeFromSuperview];
    _detailView = nil;
    
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(0, _height, kScreenWidth, 0)];
    
    [_scrollView addSubview:_detailView];
    
    if (_product_guide.allKeys.count == 0) {
        NSString *guideURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductGuide, _productCode] params:nil];
        YunLog(@"product guide url = %@", guideURL);
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 15;
        
        [manager GET:guideURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"responseObject Variants = %@", responseObject);
           
            _hud.hidden = YES;
            
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                _product_guide = [[responseObject objectForKey:@"data"] objectForKey:@"product_guide"];
                
                YunLog(@"_product_guide = %@", _product_guide);
                
                [self createGuideData];
            } else {
                [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"product guide error = %@", error);
            
            [_hud addErrorString:@"获取数据失败" delay:2.0];
            
            _scrollView.contentSize = CGSizeMake(kScreenWidth, _height);
        }];
    }
    else
    {
         [self createGuideData];
    }
}

/**
 获取商品详情参数数据
 */
- (void)getAttributesData:(UIButton *)sender
{
    [_detailView removeFromSuperview];
    _detailView = nil;
    
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(0, _height, kScreenWidth, 0)];
    
    [_scrollView addSubview:_detailView];
    
    _lastSelectedButton.selected = NO;
    _lastSelectedButton = sender;
    sender.selected = YES;
    
    if (_product_detail.count == 0) {
        NSString *attributesURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:kProductAttributes, _productCode] params:nil];
        YunLog(@"product Attributes url = %@", attributesURL);
        
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer.timeoutInterval = 15;
        
        [manager GET:attributesURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            YunLog(@"responseObject Attributes = %@", responseObject);
            NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
            if ([code isEqualToString:kSuccessCode]) {
                [_hud hide:YES];
                _product_detail = [[responseObject objectForKey:@"data"] objectForKey:@"product_attributes"];
                
                YunLog(@"product_attributes = %@", _product_detail);
                
                [self createProductAttributes];
                
            } else {
                [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:2.0];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YunLog(@"product guide error = %@", error);
            
            [_hud addErrorString:@"获取数据失败" delay:2.0];
            
            _scrollView.contentSize = CGSizeMake(kScreenWidth, _height);
        }];
    }
    else
    {
        [self createProductAttributes];
    }
}

#pragma mark - Private Functions -

/**
 添加我的浏览足迹
 */
- (void)addMyHistory
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *param = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                            @"code"                    :   kNullToString(_productCode)};
    
    NSString *addHistoryURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kHistoryURL params:param];
    
    YunLog(@"add my history = %@", addHistoryURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    
    [manager POST:addHistoryURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"添加我的浏览历史返回数据 = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            YunLog(@"添加我的足迹成功");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"添加我的足迹失败error = %@",error);
    }];
}

/**
 检测是否添加到我的收藏
 */
- (void)checkFavorite
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"category"                 :   kNullToString(@"Product")};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1
                                           requestURL:[NSString stringWithFormat:kHas_ExistedURL,_productCode]
                                               params:params];
    
    YunLog(@"favoriteURL = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    
    [manager GET:favoriteURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"favorite responseObject = %@", responseObject);
             
             if ([[[responseObject objectForKey:@"status"] objectForKey:@"code"] isEqualToString:kSuccessCode])
             {
                 _favoriteID = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_id"];
                 
                 [_favorite setImage:[UIImage imageNamed:@"top_already_favorite"] forState:UIControlStateNormal];
                 
                 [_favorite removeTarget:self action:@selector(addFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [_favorite removeTarget:self action:@selector(deleteFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [_favorite addTarget:self action:@selector(deleteFavorite:)
                    forControlEvents:UIControlEventTouchUpInside];
                 
                 _favoriteTittle.text = @"已收藏";
             } else {
                 [_favorite setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
                 
                 [_favorite removeTarget:self action:@selector(addFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [_favorite removeTarget:self action:@selector(deleteFavorite:)
                       forControlEvents:UIControlEventTouchUpInside];
                 [_favorite addTarget:self action:@selector(addFavorite:)
                    forControlEvents:UIControlEventTouchUpInside];
                 
                 _favoriteTittle.text = @"收藏";
             }
             
//             UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithCustomView:favorite];
//             newItem.style = UIBarButtonItemStylePlain;
//             
//             NSMutableArray *items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
//             [items removeObject:_favoriteItem];
//             [items addObject:newItem];
//             
//             _favoriteItem = newItem;
//             
//             self.navigationItem.rightBarButtonItems = items;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"favorite error = %@", error);
         }];
}

/**
 添加到我的收藏
 */
- (void)addFavorite:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    if (!appDelegate.isLogin) {
        sender.enabled = YES;
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isBuyEnter = YES;
        loginVC.isReturnView = YES;
        
        UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];

        [self.navigationController presentViewController:loginNC animated:YES completion:nil];
        
        return;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    _hud.labelText = @"努力收藏中...";
    
    NSDictionary *params = @{@"code"                    :   kNullToString(_productCode),
                             @"category"                :   kNullToString(@"Product"),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"sid"                     :   _shop[@"id"],
                             @"shop_code"               :   _shop[@"code"]};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAddFavoriteURL params:params];
    
    YunLog(@"add favorite url = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    
    [manager POST:favoriteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"favData = %@", responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
                    _hud.detailsLabelText = @"收藏成功";
                    [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_product objectForKey:@"title"]]
                                     delay:1.5];
            
                    [sender setImage:nil forState:UIControlStateNormal];
                    [sender setImage:[UIImage imageNamed:@"top_already_favorite"] forState:UIControlStateNormal];
                    [sender removeTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
                    [sender removeTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
                    [sender addTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            _favoriteTittle.text = @"已收藏";
            
            _favoriteID = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_id"];
        } else {
            [_hud addErrorString:@"收藏失败" delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"fav error = %@", error);
        
        [_hud addErrorString:@"网络异常，添加收藏失败" delay:1.5];
    }];
}

/**
 取消我的收藏
 */
- (void)deleteFavorite:(UIButton *)sender
{
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else {
        [_hud show:YES];
    }
    
    _hud.labelText = @"删除收藏中...";
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"ids"                     :   kNullToString(_favoriteID),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *favoriteURL = [Tool buildRequestURLHost:kRequestHostWithPublic
                                           APIVersion:kAPIVersion1
                                           requestURL:kDeleteFavoriteURL
                                               params:params];
    
    YunLog(@"delete favorite url = %@", favoriteURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    
    [manager DELETE:favoriteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"res delete fav = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _hud.detailsLabelText = @"取消收藏成功";
            [_hud addSuccessString:[NSString stringWithFormat:@"%@", [_product objectForKey:@"title"]]
                             delay:1.5];
            
            [sender setImage:nil forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [sender removeTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            _favoriteTittle.text = @"收藏";
        } else {
            [_hud addErrorString:@"取消收藏失败" delay:1.5];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"fav error = %@", error);
        
        [_hud addErrorString:@"网络异常，取消收藏失败" delay:1.5];
    }];
}

#pragma mark - UI Functions -

/**
 创建商品详情的UI
 */
- (void)createUI
{
    CGFloat imageHeight = 200 * kScreenWidth / 218;
    
    _imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, imageHeight)];
    _imageScrollView.showsVerticalScrollIndicator = NO;
    _imageScrollView.showsHorizontalScrollIndicator = NO;
    _imageScrollView.pagingEnabled = YES;
    _imageScrollView.delegate = self;
    
    [_scrollView addSubview:_imageScrollView];
    
    NSArray *images = kNullToArray([_product objectForKey:@"images"]);
    
    if (images.count > 0)
    {
        for (int i = 0; i < images.count; i++)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, imageHeight)];
            imageView.contentMode = UIViewContentModeCenter;
            
            NSString *imageURL = kNullToString([images[i] objectForKey:@"origin_image"]);
            
            __weak UIImageView *_imageView = imageView;
            
            [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString(imageURL)]]
                              placeholderImage:[UIImage imageNamed:@"default_history"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           _imageView.contentMode = UIViewContentModeScaleToFill;
                                           _imageView.image = image;
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([images[i] objectForKey:@"large_image"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
                                           _imageView.contentMode = UIViewContentModeScaleToFill;
                                       }];
            
            [_imageScrollView addSubview:imageView];
        }
        
        _imageScrollView.contentSize = CGSizeMake(kScreenWidth * images.count, imageHeight);
    }
    else
    {
        _imageScrollView.frame = CGRectZero;
    }
    
    if (images.count > 1) {
        UIView *pageControlBackView = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight - 20, kScreenWidth, 20)];
        pageControlBackView.backgroundColor = kOrangeColor;
        
        [_scrollView addSubview:pageControlBackView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth - images.count * 20) / 2, 0, images.count * 20, 20)];
        _pageControl.numberOfPages = images.count;
        _pageControl.currentPage = 0;
        
        if (kDeviceOSVersion >= 6.0) {
            _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
            _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        }
        
        [pageControlBackView addSubview:_pageControl];
    }
    
    NSString *memberPriceStr = [NSString stringWithFormat:@"会员价:￥%@",kNullToString([_product objectForKey:@"price"])];
    CGSize memberPriceSize = [memberPriceStr sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];

    UILabel *memberPrice = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_imageScrollView.frame) + 10, memberPriceSize.width, memberPriceSize.height)];
    memberPrice.textColor = kLightBlackColor;
    memberPrice.text = memberPriceStr;
    memberPrice.font = kNormalFont;
    memberPrice.textAlignment = NSTextAlignmentLeft;
    
    [_scrollView addSubview:memberPrice];
    
    if (![_product[@"market_price"] isEqualToString:@"0.0"]) {
        NSString *marketPriceStr = [NSString stringWithFormat:@"市场价:￥%@",kNullToString([_product objectForKey:@"market_price"])];
        CGSize marketPriceSize = [marketPriceStr sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20 - CGRectGetMaxX(memberPrice.frame), 9999)];
        
        UILabel *marketPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(memberPrice.frame) + 10, CGRectGetMaxY(_imageScrollView.frame) + 10, marketPriceSize.width, marketPriceSize.height)];
        marketPrice.text = marketPriceStr;
        marketPrice.font = kNormalFont;
        marketPrice.textColor = [UIColor grayColor];
        marketPrice.textAlignment = NSTextAlignmentLeft;
        
        [_scrollView addSubview:marketPrice];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, marketPriceSize.height / 2, marketPriceSize.width, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        
        [marketPrice addSubview:line];
    }

    CGFloat promotionsLabelX = 10;
    CGFloat promotionsLabelWidth = kScreenWidth - 20;
    CGFloat promotionsLabelHeight = 16;
    CGFloat promotionsMaxY = CGRectGetMaxY(memberPrice.frame);
    for (int i = 0; i < _product_promotions.count; i++) {
        CGFloat promotionsLabelY = CGRectGetMaxY(memberPrice.frame) + 10 + promotionsLabelHeight * i;
        NSDictionary *dictPro = _product_promotions[i];
        
        UILabel *promotionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(promotionsLabelX, promotionsLabelY, promotionsLabelWidth, promotionsLabelHeight)];
        promotionsLabel.backgroundColor = kClearColor;
        promotionsLabel.font = kMidFont;
        promotionsLabel.textColor = [UIColor redColor];
        promotionsLabel.text = [NSString stringWithFormat:@"优惠: %@", [dictPro safeObjectForKey:@"name"]];
        promotionsLabel.textAlignment = NSTextAlignmentLeft;
        
        [_scrollView addSubview:promotionsLabel];
        
        promotionsMaxY = CGRectGetMaxY(promotionsLabel.frame);
    }
    
//    UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, promotionsMaxY + 10, kScreenWidth - 20, 16)];
//    codeLabel.font = kMidFont;
//    codeLabel.textColor = kLightBlackColor;
//    codeLabel.text = [NSString stringWithFormat:@"编码: %@", kNullToString([_product objectForKey:@"code"])];
//    codeLabel.textAlignment = NSTextAlignmentLeft;
//    
//    [_scrollView addSubview:codeLabel];
    
    UILabel *inventoryQuantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, promotionsMaxY + 10, kScreenWidth - 20, 16)];
    inventoryQuantityLabel.font = kMidFont;
    inventoryQuantityLabel.textColor = kLightBlackColor;
    inventoryQuantityLabel.text = [NSString stringWithFormat:@"库存: %@", kNullToString([_product objectForKey:@"inventory_quantity"])];
    inventoryQuantityLabel.textAlignment = NSTextAlignmentLeft;
    
    [_scrollView addSubview:inventoryQuantityLabel];
    
    UILabel *salesQuantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(inventoryQuantityLabel.frame) + 10, kScreenWidth - 20, 16)];
    salesQuantityLabel.font = kMidFont;
    salesQuantityLabel.textColor = kLightBlackColor;
    salesQuantityLabel.text = [NSString stringWithFormat:@"销量: %@", kNullToString([_product objectForKey:@"sales_quantity"])];
    salesQuantityLabel.textAlignment = NSTextAlignmentLeft;
    
    [_scrollView addSubview:salesQuantityLabel];
    
    if (! _isAdmin) {
        _favorite = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 1 - 80, CGRectGetMaxY(inventoryQuantityLabel.frame) - 22, 30, 32)];
        [_favorite setImage:[UIImage imageNamed:@"top_favorite"] forState:UIControlStateNormal];
        [_favorite removeTarget:self action:@selector(addFavorite:)
               forControlEvents:UIControlEventTouchUpInside];
        [_favorite removeTarget:self action:@selector(deleteFavorite:)
               forControlEvents:UIControlEventTouchUpInside];
        [_favorite addTarget:self action:@selector(addFavorite:)
            forControlEvents:UIControlEventTouchUpInside];

        _favoriteTittle = [[UILabel alloc] initWithFrame:CGRectMake(_favorite.frame.origin.x - 10, CGRectGetMaxY(_favorite.frame) + 5, _favorite.frame.size.width + 20, 10)];
        _favoriteTittle.font = kSmallFont;
        _favoriteTittle.textAlignment = NSTextAlignmentCenter;
        _favoriteTittle.textColor = [UIColor grayColor];
        _favoriteTittle.text = @"收藏";
        
        [_scrollView addSubview:_favoriteTittle];
        
        [_scrollView addSubview:_favorite];
        
        UIView *lineCol = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_favorite.frame) + 10, CGRectGetMaxY(inventoryQuantityLabel.frame) - 22, 1, 32)];
        lineCol.backgroundColor = [UIColor lightGrayColor];
        
        [_scrollView addSubview:lineCol];
    }
    
    if (![[[_product objectForKey:@"status"] stringValue] isEqualToString:@"3"])
    {
        // right bar button item
        UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 30, CGRectGetMaxY(inventoryQuantityLabel.frame) - 22, 30, 32)];
        [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
        [share addTarget:self action:@selector(openShare) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:share];
        
        UILabel *shareTittle = [[UILabel alloc] initWithFrame:CGRectMake(share.frame.origin.x - 10, CGRectGetMaxY(share.frame) + 5, share.frame.size.width + 20, 10)];
        shareTittle.font = kSmallFont;
        shareTittle.text = @"分享";
        shareTittle.textAlignment = NSTextAlignmentCenter;
        shareTittle.textColor = [UIColor grayColor];
        
        [_scrollView addSubview:shareTittle];
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    if (appDelegate.isLogin && !_isAdmin) {
        [self checkFavorite];
    }
    
    UIButton *variantsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    variantsButton.frame = CGRectMake(0, CGRectGetMaxY(salesQuantityLabel.frame) + 10, kScreenWidth, 44);
    variantsButton.backgroundColor = kGrayColor;
    variantsButton.tag = 100;
    [variantsButton addTarget:self action:@selector(getVariantsData:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:variantsButton];
    
    UILabel *variantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth / 2, variantsButton.frame.size.height)];
    
    variantsLabel.text = @"规格数量";
    variantsLabel.textAlignment = NSTextAlignmentLeft;
    variantsLabel.font = kMidFont;
    variantsLabel.textColor = [UIColor grayColor];
    
    [variantsButton addSubview:variantsLabel];
    
    UIImageView *arrowRightOne = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 20, 12, 20, 20)];
    
    arrowRightOne.image = [UIImage imageNamed:@"product_arrow_right"];
    
    [variantsButton addSubview:arrowRightOne];
    
    UIButton *judgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    judgeButton.frame = CGRectMake(0, CGRectGetMaxY(variantsButton.frame) + 5, kScreenWidth, 40);
    judgeButton.backgroundColor = kGrayColor;
    [judgeButton addTarget:self action:@selector(goToCommentList) forControlEvents:UIControlEventTouchUpInside];

    [_scrollView addSubview:judgeButton];
    
    UILabel *judgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth / 2, variantsButton.frame.size.height)];
    
    judgeLabel.text = @"用户评价";
    judgeLabel.textAlignment = NSTextAlignmentLeft;
    judgeLabel.font = kMidFont;
    judgeLabel.textColor = [UIColor grayColor];
    
    [judgeButton addSubview:judgeLabel];
    
    UIImageView *arrowRightTwo = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 20, 12, 20, 20)];
    
    arrowRightTwo.image = [UIImage imageNamed:@"product_arrow_right"];
    
    [judgeButton addSubview:arrowRightTwo];

    NSArray *describeArr = @[@"商品详情", @"规格参数", @"购买须知"];
    
    for (int i = 0; i < 3; i ++) {
        UIButton *describeButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth / 3) * i, CGRectGetMaxY(judgeButton.frame) + 10, (kScreenWidth / 3), 40)];
        
        [describeButton setTitle:describeArr[i] forState:UIControlStateNormal];
        [describeButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        [describeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        describeButton.titleLabel.font = kSmallFont;
        
        if (i == 0) {
            describeButton.selected = YES;
            _lastSelectedButton = describeButton;
            [describeButton addTarget:self action:@selector(getImageDetail:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i == 1) {
            [describeButton addTarget:self action:@selector(getAttributesData:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i == 2) {
            [describeButton addTarget:self action:@selector(getGuideData:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_scrollView addSubview:describeButton];
    }
    
    if (! _isAdmin) {
        // 底部工具栏
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
        
        if (kDeviceOSVersion < 7.0) {
            _bottomView.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
        }
        
        _bottomView.backgroundColor = kBackgroundColor;
        _bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
        _bottomView.layer.borderWidth = 1;
        _bottomView.clipsToBounds = NO;
        
        [self.view addSubview:_bottomView];
        
        UIButton *goToShop = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 30, 30)];
        [goToShop setImage:[UIImage imageNamed:@"shop_tab"] forState:UIControlStateNormal];
        [goToShop addTarget:self action:@selector(goToShop) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:goToShop];
        
        // 联系客服
        UIButton *contactService = [[UIButton alloc] initWithFrame:CGRectMake(60, 9, 30, 30)];
        [contactService setImage:[UIImage imageNamed:@"contact_service"] forState:UIControlStateNormal];
        [contactService addTarget:self action:@selector(contactServiceClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:contactService];

        if ([[_product objectForKey:@"inventory_quantity"] integerValue] > 0) {
            UIButton *buy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 8, 100, 32)];
            buy.tag = 200;
            buy.layer.cornerRadius = 3;
            buy.layer.masksToBounds = YES;
            buy.backgroundColor = [UIColor whiteColor];
            buy.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
            [buy setTitle:@"立即购买" forState:UIControlStateNormal];
            [buy setTitleColor:kOrangeColor forState:UIControlStateNormal];
            [buy addTarget:self action:@selector(getVariantsData:) forControlEvents:UIControlEventTouchUpInside];
            
            buy.layer.borderWidth = 1;
            buy.layer.borderColor = kOrangeColor.CGColor;
            
            [_bottomView addSubview:buy];
            
            UIButton *addToCart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
            addToCart.tag = 300;
            addToCart.layer.cornerRadius = 3;
            addToCart.layer.masksToBounds = YES;
            addToCart.backgroundColor = [UIColor orangeColor];
            addToCart.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
            [addToCart setTitle:@"加入购物车" forState:UIControlStateNormal];
            [addToCart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [addToCart addTarget:self action:@selector(getVariantsData:) forControlEvents:UIControlEventTouchUpInside];
            
            [_bottomView addSubview:addToCart];
        }
    }
    
    if (kDeviceOSVersion < 7.0) {
        if (!_isAdmin)
        {
            _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 108);
        }
        else
        {
            _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 60);
        }
    }
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, (kScreenHeight - CGRectGetMaxY(variantsButton.frame)) > 0 ?  kScreenHeight : CGRectGetMaxY(variantsButton.frame));
    
    _height = CGRectGetMaxY(judgeButton.frame) + 50;
}

/**
 创建购买须知的UI
 */
- (void)createGuideData
{
    CGFloat height = 0;
    
    NSArray *arr = [_product_guide objectForKey:@"items"];
    
    for (int i = 0; i < arr.count; i ++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        
        [_detailView addSubview:line];
    
        NSString *detailStr = kNullToString([arr[i] objectForKey:@"text"]);
        
        CGSize detailSize = [detailStr sizeWithFont:kSmallFont size:CGSizeMake(kScreenWidth - 20, 9999)];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(line.frame), detailSize.width, detailSize.height + 20)];
        
        detailLabel.text = detailStr;
        detailLabel.font = kSmallFont;
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.numberOfLines = 0;
        
        [_detailView addSubview:detailLabel];
        
        height += detailSize.height + 20;
        
        _detailView.frame = CGRectMake(0, _height, kScreenWidth, height);
    }
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, _height + height);
}

/**
 创建商品图文详情的UI
 */
- (void)createImageDetail
{
    CGFloat height = 0;
    
    if (_photos.count == 0 || !_photos) {
        UILabel *tittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, kScreenWidth - 20, 20)];
        
        tittleLabel.text = @"暂无图文详情";
        tittleLabel.font = kMidFont;
        tittleLabel.textColor = [UIColor grayColor];
        tittleLabel.numberOfLines = 0;
        
        [_detailView addSubview:tittleLabel];
        
        height += 30;
    } else {
        for (int i = 0 ; i < _photos.count; i ++) {
            if ( ![kNullToString([_photos[i] objectForKey:@"title"]) isEqualToString:@""]) {
                NSString *tittleStr = kNullToString([_photos[i] objectForKey:@"title"]);
                
                CGSize tittleSize = [tittleStr sizeWithFont:kNormalFont size:CGSizeMake(kScreenWidth - 20, 9999)];
                
                UILabel *tittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, tittleSize.width, tittleSize.height + 20)];
                
                tittleLabel.text = tittleStr;
                tittleLabel.font = kNormalFont;
                tittleLabel.textColor = kOrangeColor;
                tittleLabel.numberOfLines = 0;
                
                [_detailView addSubview:tittleLabel];
                
                height += tittleSize.height + 10;
            }
            
            if ( ![kNullToString([_photos[i] objectForKey:@"description_text"]) isEqualToString:@""]) {
                NSString *detailStr = kNullToString([_photos[i] objectForKey:@"description_text"]);
                
                CGSize detailSize = [detailStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20, 9999)];
                
                UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, detailSize.width, detailSize.height + 20)];
                
                detailLabel.text = detailStr;
                detailLabel.font = kMidFont;
                detailLabel.textColor = [UIColor grayColor];
                detailLabel.numberOfLines = 0;
                
                [_detailView addSubview:detailLabel];
                
                height += detailSize.height + 10;
            }
            
            if ( ![kNullToString([[_photos[i] objectForKey:@"image"] objectForKey:@"url"]) isEqualToString:@""]) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height + 10, kScreenWidth, kScreenWidth / 640 * 200)];
                imageView.contentMode = UIViewContentModeCenter;
                
                [_detailView addSubview:imageView];
                
                NSString *imageURL = kNullToString([[_photos[i] objectForKey:@"image"] objectForKey:@"url"]);
                
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                
//                __weak UIImageView *_imageView = imageView;
    
                CGFloat  tempHeight = 0;
                
                if (image)
                {
                    tempHeight = kScreenWidth / image.size.width * image.size.height;
                    
                    imageView.contentMode = UIViewContentModeScaleToFill;
                    
                    imageView.frame = CGRectMake(0, height + 10, kScreenWidth, tempHeight);
                    imageView.image = image;
                    
                    _scrollView.contentSize = CGSizeMake(kScreenWidth, height);
                }

//                [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString(imageURL)]]
//                                  placeholderImage:[UIImage imageNamed:@"default_history"]
//                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                               tempHeight = kScreenWidth / image.size.width * image.size.height;
//    
//                                               _imageView.contentMode = UIViewContentModeScaleToFill;
//    
//                                               _imageView.frame = CGRectMake(0, height + 10, kScreenWidth, tempHeight);
//                                               _imageView.image = image;
//    
//                                               _scrollView.contentSize = CGSizeMake(kScreenWidth, height);
//                                           }
//                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                               _imageView.image = [UIImage imageNamed:@"default_history"];
//                                               
//                                               tempHeight = 200;
//    
//                                               _imageView.contentMode = UIViewContentModeScaleToFill;
//                                           }];
                height += tempHeight + 10;
            }
        }
    }
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, _height + height);
}

/**
 创建商品图文详情web版的UI
 */
- (void)createImageWebDetail
{
    CGFloat height = 0;
    
    if (_photos.count == 0 || !_photos) {
        UILabel *tittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, kScreenWidth - 20, 20)];
        
        tittleLabel.text = @"暂无图文详情";
        tittleLabel.font = kMidFont;
        tittleLabel.textColor = [UIColor grayColor];
        tittleLabel.numberOfLines = 0;
        
        [_detailView addSubview:tittleLabel];
        
        height += 30;
    } else {
        for (int i = 0 ; i < _photos.count; i ++) {
            if ( ![kNullToString(_photos[i]) isEqualToString:@""]) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height + 10, kScreenWidth, kScreenWidth / 640 * 200)];
                imageView.contentMode = UIViewContentModeCenter;
                
                NSString *imageURL = kNullToString(_photos[i]);
                
                UIImage *image = [UIImage loadImageFromWeb:imageURL];
                
                __weak UIImageView *_imageView = imageView;
                
                CGFloat __block tempHeight = 0;
                
                if (image)
                {
                    tempHeight = kScreenWidth / image.size.width * image.size.height;
                    
                    _imageView.contentMode = UIViewContentModeScaleToFill;
                    
                    _imageView.frame = CGRectMake(0, height + 10, kScreenWidth, tempHeight);
                    _imageView.image = image;
                    
                    _scrollView.contentSize = CGSizeMake(kScreenWidth, height);
                }
                [_detailView addSubview:imageView];
                
                height += tempHeight + 10;
            }
        }
    }
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, _height + height);
}

/**
 创建规格参数的UI
 */
- (void)createProductAttributes
{
    CGFloat height = 0;
    
    NSArray *arr = [_product_detail objectForKey:@"items"];
    
    for (int i = 0; i < arr.count; i ++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, height, kScreenWidth, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        
        [_detailView addSubview:line];
       
        NSString *tittleStr = kNullToString([arr[i] objectForKey:@"attr_name"]);
        
        CGSize tittleSize = [tittleStr sizeWithFont:kMidFont size:CGSizeMake(60, 9999)];
        
        UILabel *tittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(line.frame), tittleSize.width, tittleSize.height + 20)];
        tittleLabel.text = kNullToString([arr[i] objectForKey:@"attr_name"]);
        tittleLabel.font = kMidFont;
        tittleLabel.textColor = kLightBlackColor;
        tittleLabel.numberOfLines = 0;
        
        [_detailView addSubview:tittleLabel];
        
        NSString *detailStr = kNullToString([arr[i] objectForKey:@"text"]);
        
        CGSize detailSize = [detailStr sizeWithFont:kSmallFont size:CGSizeMake(kScreenWidth - 20 - 20 - 60, 9999)];

        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake((tittleSize.width == 0) ? 10 : 80, CGRectGetMaxY(line.frame), detailSize.width, detailSize.height + 20)];
        
        detailLabel.text = detailStr;
        detailLabel.font = kSmallFont;
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.numberOfLines = 0;
        
        [_detailView addSubview:detailLabel];
        
        height += (detailSize.height > tittleSize.height ? detailSize.height : tittleSize.height) + 20;
        
        _detailView.frame = CGRectMake(0, _height, kScreenWidth, height);
    }
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth, _height + height);
}

/**
 创建商品弹出规格数量的UI
 */
- (void)createVariantUI
{
    _scrollView.scrollEnabled = NO;
   
    _cover = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight)];
    _cover.backgroundColor = [UIColor blackColor];
    _cover.alpha = 0.0;
    
    [self.view addSubview:_cover];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(cancel)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    
    [_cover addGestureRecognizer:tap];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight + 30 + 10, kScreenWidth, kScreenHeight / 2 + 30)];
    _backView.backgroundColor = [UIColor whiteColor];
    _backView.userInteractionEnabled = YES;
    
    [self.view addSubview:_backView];
    
    if (!_isAdmin && [[_product objectForKey:@"inventory_quantity"] integerValue] > 0) {
        // 底部工具栏
        _bottomViewDetail = [[UIView alloc] initWithFrame:CGRectMake(-1, _backView.frame.size.height - 48, kScreenWidth + 2, 48)];
        
        if (kDeviceOSVersion < 7.0) {
            _bottomViewDetail.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
        }
        
        _bottomViewDetail.backgroundColor = kBackgroundColor;
        _bottomViewDetail.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
        _bottomViewDetail.layer.borderWidth = 1;
        _bottomViewDetail.clipsToBounds = NO;
        
        [_backView addSubview:_bottomViewDetail];
        
        if (_isEnterVariantsData) {
            UIButton *buy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 105, 8, 100, 32)];
            buy.layer.cornerRadius = 3;
            buy.layer.masksToBounds = YES;
            buy.backgroundColor = [UIColor whiteColor];
            buy.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
            [buy setTitle:@"立即购买" forState:UIControlStateNormal];
            [buy setTitleColor:kOrangeColor forState:UIControlStateNormal];
            [buy addTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
            
            buy.layer.borderWidth = 1;
            buy.layer.borderColor = kOrangeColor.CGColor;
            
            [_bottomViewDetail addSubview:buy];
            
            UIButton *addToCart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2 + 5, 8, 100, 32)];
            addToCart.layer.cornerRadius = 3;
            addToCart.layer.masksToBounds = YES;
            addToCart.backgroundColor = [UIColor orangeColor];
            addToCart.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
            [addToCart setTitle:@"加入购物车" forState:UIControlStateNormal];
            [addToCart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [addToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
            
            [_bottomViewDetail addSubview:addToCart];
        } else {
            UIButton *certain = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2, 8, 100, 32)];
            certain.layer.cornerRadius = 3;
            certain.layer.masksToBounds = YES;
            certain.backgroundColor = [UIColor orangeColor];
            certain.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
            [certain setTitle:@"确定" forState:UIControlStateNormal];
            [certain setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (_isAddToCart) {
                [certain removeTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
                [certain addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [certain removeTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
                [certain addTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [_bottomViewDetail addSubview:certain];
        }
    }
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(kScreenWidth - 40, 0, 40, 40);
    cancel.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [cancel setImage:[UIImage imageNamed:@"product_cancel"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [_backView addSubview:cancel];
    
    NSArray *images = kNullToArray([_product objectForKey:@"images"]);
    
    NSString *imageURL = kNullToString([[images firstObject] objectForKey:@"origin_image"]);
    
    _seletedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, -10, 100, 100)];
    _seletedIcon.backgroundColor = [UIColor whiteColor];
    _seletedIcon.layer.masksToBounds = YES;
    _seletedIcon.layer.borderWidth = 0.5;
    _seletedIcon.layer.borderColor = [UIColor blackColor].CGColor;
    
    __weak UIImageView *_imageView = _seletedIcon;
    
    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString(imageURL)]]
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   _imageView.contentMode = UIViewContentModeScaleToFill;
                                   _imageView.image = image;
                               }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   _imageView.image = [UIImage imageNamed:@"default_history"];
                                   _imageView.contentMode = UIViewContentModeScaleToFill;
                               }];
    
    [_backView addSubview:_seletedIcon];
    
    NSString *memberPriceStr = [NSString stringWithFormat:@"会员价:￥%@",kNullToString([_product objectForKey:@"price"])];
    CGSize memberPriceSize = [memberPriceStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20 - CGRectGetMaxX(_seletedIcon.frame), 9999)];
    
    _memberPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_seletedIcon.frame) + 10, 10, kScreenWidth - CGRectGetMaxX(_seletedIcon.frame) - 10 - 50, memberPriceSize.height)];
    _memberPrice.textColor = kLightBlackColor;
    _memberPrice.text = memberPriceStr;
    _memberPrice.font = kMidFont;
    _memberPrice.textAlignment = NSTextAlignmentLeft;
    
    [_backView addSubview:_memberPrice];
    
    NSString *marketPriceStr = [NSString stringWithFormat:@"市场价:￥%@",kNullToString([_product objectForKey:@"market_price"])];
    CGSize marketPriceSize = [marketPriceStr sizeWithFont:kSmallFont size:CGSizeMake(kScreenWidth - 20 - CGRectGetMaxX(_seletedIcon.frame), 9999)];
    
    _marketPrice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_seletedIcon.frame) + 10, CGRectGetMaxY(_memberPrice.frame) + 10, kScreenWidth - CGRectGetMaxX(_seletedIcon.frame) - 10 - 50, marketPriceSize.height)];
    _marketPrice.text = marketPriceStr;
    _marketPrice.font = kSmallFont;
    _marketPrice.textColor = kLightBlackColor;
    _marketPrice.textAlignment = NSTextAlignmentLeft;
    
    [_backView addSubview:_marketPrice];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, marketPriceSize.height / 2, marketPriceSize.width, 0.5)];
    line.backgroundColor = kLightBlackColor;
    
    [_marketPrice addSubview:line];
    
    _inventoryQuantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_seletedIcon.frame) + 10, CGRectGetMaxY(_marketPrice.frame) + 10, kScreenWidth - CGRectGetMaxX(_seletedIcon.frame) - 10 - 50, 16)];
    _inventoryQuantityLabel.font = kSmallFont;
    _inventoryQuantityLabel.textColor = kLightBlackColor;
    _inventoryQuantityLabel.text = [NSString stringWithFormat:@"库存: %@", kNullToString([_product objectForKey:@"inventory_quantity"])];
    _inventoryQuantityLabel.textAlignment = NSTextAlignmentLeft;
    
    [_backView addSubview:_inventoryQuantityLabel];
    
    UIScrollView *variantView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_seletedIcon.frame) + 15, kScreenWidth, _backView.frame.size.height - 90 - 15 - 49)];
    
    if (_isAdmin)
    {
        variantView.frame = CGRectMake(0, CGRectGetMaxY(_seletedIcon.frame) + 15, kScreenWidth, _backView.frame.size.height - 90 - 15 - 10);
    }
    
    [_backView addSubview:variantView];
    
    CGFloat height = 0;
    
    for (int i = 0; i < _sku_categories.count; i++) {
        NSString *titleStr = kNullToString([_sku_categories[i] objectForKey:@"title"]);
        
        CGSize tittleSize = [titleStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20 - 20 - 60, 9999)];
        
        UILabel *tittleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, tittleSize.width, tittleSize.height)];
        
        tittleLabel.text = titleStr;
        tittleLabel.font = kMidFont;
        tittleLabel.textColor = kLightBlackColor;
        
        [variantView addSubview:tittleLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(tittleLabel.frame) + 15, kScreenWidth - 20, 0.5)];
        line.backgroundColor = [UIColor grayColor];
        
        [variantView addSubview:line];
        
        NSArray *values = kNullToArray([_sku_categories[i] objectForKey:@"values"]);
        
        CGFloat heightSub = 10;
        CGFloat widthSub = 10;
        for (int j = 0; j < values.count; j ++) {
            NSString *typeStr = kNullToString([values[j] objectForKey:@"value"]);
            
            CGSize typeSize = [typeStr sizeWithFont:kSmallFont size:CGSizeMake(kScreenWidth - 20 - 30, 9999)];
            
            UIButton *typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if (widthSub + typeSize.width + 30 + 10 > kScreenWidth) {
                heightSub += typeSize.height + 20 + 10;
                widthSub = 10;
            }
            
            typeButton.frame = CGRectMake(widthSub,CGRectGetMaxY(line.frame) + heightSub, typeSize.width + 30, typeSize.height + 20);
            [typeButton setTitleColor:kLightBlackColor forState:UIControlStateNormal];
            [typeButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
            typeButton.titleLabel.font = kSmallFont;
            typeButton.layer.masksToBounds = YES;
            typeButton.layer.borderWidth = 0.5;
            typeButton.titleLabel.numberOfLines = 0;
            typeButton.tag = [kNullToString([values[j] objectForKey:@"id"]) integerValue];
            
            if (i == 0 && j == 0) {
                typeButton.selected = YES;
                _lastSelectedType1 = typeButton;
            }
            
            typeButton.layer.borderColor = typeButton.selected ? kOrangeColor.CGColor : kLightBlackColor.CGColor;
            
            widthSub += typeSize.width + 30 + 10;
            
            [typeButton setTitle:typeStr forState:UIControlStateNormal];
            
            [variantView addSubview:typeButton];
            
            if (j == values.count - 1) {
                heightSub += typeSize.height + 20 + 10 + 30;
            }
            
            switch (i) {
                case 0:
                    [typeButton addTarget:self action:@selector(changeFristValue:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 1:
                    [typeButton addTarget:self action:@selector(changeSecondValue:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 2:
                    [typeButton addTarget:self action:@selector(changeThirdValue:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
        }
        
        height += heightSub + 10;
        
        if (_sku_categories.count == 1) {
            _variant = _sku_variants[_sku_variants.allKeys.firstObject];
        }
    }
    
    if (!_isAdmin) {
        NSString *countStr = @"数量";
        
        CGSize tittleSize = [countStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20 - 20 - 60, 9999)];
        
        UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(10, height, tittleSize.width, tittleSize.height)];
        count.text  = countStr;
        count.font = kMidFont;
        count.textColor = kLightBlackColor;
        
        [variantView addSubview:count];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(count.frame) + 15, kScreenWidth - 20, 0.5)];
        line1.backgroundColor = [UIColor grayColor];
        
        [variantView addSubview:line1];
        
        height += tittleSize.height + 25;
        
        UIButton *sub = [UIButton buttonWithType:UIButtonTypeCustom];
        
        sub.frame = CGRectMake(10, height, 40, 40);
        [sub setTitle:@"-" forState:UIControlStateNormal];
        [sub setTitleColor:kLightBlackColor forState:UIControlStateNormal];
        [sub addTarget:self action:@selector(sub) forControlEvents:UIControlEventTouchUpInside];
        
        sub.layer.masksToBounds = YES;
        sub.layer.borderColor = kLightBlackColor.CGColor;
        sub.layer.borderWidth = 0.5;
        
        [variantView addSubview:sub];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sub.frame), sub.frame.origin.y, 50, sub.frame.size.height)];
        
        if ([[_product objectForKey:@"is_limit_quantity"] integerValue] == 0) {
            _countLabel.text = @"1";
        } else {
            NSString *min = kNullToString([_product objectForKey:@"minimum_quantity"]);
            
            if ([min integerValue] == 0) {
                _countLabel.text = @"1";
            }
            _countLabel.text = min;
        }
        
        if ([[[_product objectForKey:@"inventory_quantity"] stringValue] isEqualToString:@"0"])
        {
            _countLabel.text = @"0";
        }
        _countLabel.font = kMidFont;
        _countLabel.textColor = kLightBlackColor;
        _countLabel.textAlignment = NSTextAlignmentCenter;
        
        [variantView addSubview:_countLabel];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _countLabel.frame.size.width, 0.5)];
        topLine.backgroundColor = [UIColor grayColor];
        
        [_countLabel addSubview:topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _countLabel.frame.size.height - 0.5, _countLabel.frame.size.width, 0.5)];
        bottomLine.backgroundColor = [UIColor grayColor];
        
        [_countLabel addSubview:bottomLine];
        
        
        UIButton *plus = [UIButton buttonWithType:UIButtonTypeCustom];
        
        plus.frame = CGRectMake(CGRectGetMaxX(_countLabel.frame), height, 40, 40);
        [plus setTitle:@"+" forState:UIControlStateNormal];
        [plus setTitleColor:kLightBlackColor forState:UIControlStateNormal];
        [plus addTarget:self action:@selector(plus) forControlEvents:UIControlEventTouchUpInside];

        plus.layer.masksToBounds = YES;
        plus.layer.borderColor = kLightBlackColor.CGColor;
        plus.layer.borderWidth = 0.5;
        
        [variantView addSubview:plus];
        
        height += plus.frame.size.height + 10;
    }
    
    variantView.contentSize = CGSizeMake(kScreenWidth, height);
    
    [self showVariantUI];
}

/**
 弹出规格数量的UI
 */
- (void)showVariantUI
{
    if (!_cover) {
        _cover = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight)];
        _cover.backgroundColor = [UIColor blackColor];
        _cover.alpha = 0.0;
        
        [self.view addSubview:_cover];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(cancel)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        
        [_cover addGestureRecognizer:tap];
        
        [self.view bringSubviewToFront:_backView];
        
        if (!_isAdmin && [[_product objectForKey:@"inventory_quantity"] integerValue] > 0) {
            // 底部工具栏
            _bottomViewDetail = [[UIView alloc] initWithFrame:CGRectMake(-1, _backView.frame.size.height - 48, kScreenWidth + 2, 48)];
            
            if (kDeviceOSVersion < 7.0) {
                _bottomViewDetail.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
            }
            
            _bottomViewDetail.backgroundColor = kBackgroundColor;
            _bottomViewDetail.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
            _bottomViewDetail.layer.borderWidth = 1;
            _bottomViewDetail.clipsToBounds = NO;
            
            [_backView addSubview:_bottomViewDetail];
            
            if (_isEnterVariantsData) {
                UIButton *buy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 105, 8, 100, 32)];
                buy.layer.cornerRadius = 3;
                buy.layer.masksToBounds = YES;
                buy.backgroundColor = [UIColor whiteColor];
                buy.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
                [buy setTitle:@"立即购买" forState:UIControlStateNormal];
                [buy setTitleColor:kOrangeColor forState:UIControlStateNormal];
                [buy addTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
                
                buy.layer.borderWidth = 1;
                buy.layer.borderColor = kOrangeColor.CGColor;
                
                [_bottomViewDetail addSubview:buy];
                
                UIButton *addToCart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth / 2 + 5, 8, 100, 32)];
                addToCart.layer.cornerRadius = 3;
                addToCart.layer.masksToBounds = YES;
                addToCart.backgroundColor = [UIColor orangeColor];
                addToCart.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
                [addToCart setTitle:@"加入购物车" forState:UIControlStateNormal];
                [addToCart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [addToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
                
                [_bottomViewDetail addSubview:addToCart];
            } else {
                UIButton *certain = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2, 8, 100, 32)];
                certain.layer.cornerRadius = 3;
                certain.layer.masksToBounds = YES;
                certain.backgroundColor = [UIColor orangeColor];
                certain.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
                [certain setTitle:@"确定" forState:UIControlStateNormal];
                [certain setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                if (_isAddToCart) {
                    [certain removeTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
                    [certain addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    [certain removeTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
                    [certain addTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
                }
                [_bottomViewDetail addSubview:certain];
            }
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _cover.alpha = 0.7;
        [UIView animateWithDuration:0.5 animations:^{
            _backView.frame = CGRectMake(0, kScreenHeight / 2 - 30, kScreenWidth, kScreenHeight / 2 + 30);
        } completion:^(BOOL finished) {
        }];
    } completion:^(BOOL finished) {
    }];
}

/**
 规格数量的UI第一个参数选项改变
 */
- (void)changeFristValue:(UIButton *)sender
{
    _lastSelectedType1.selected = NO;
    _lastSelectedType1.layer.borderColor = kLightBlackColor.CGColor;
    _lastSelectedType1 = sender;
    sender.selected = YES;
    sender.layer.borderColor = kOrangeColor.CGColor;
    
    NSString *variantID = [self getSelectedVariantID];
    
    YunLog(@"variantID = %@", variantID);
    
    NSDictionary *variant = [NSDictionary dictionary];
    
    for (NSString *key in _sku_variants.allKeys) {
        if ([key isEqualToString:variantID]) {
            variant = _sku_variants[key];
        }
    }
    
    YunLog(@"variant = %@" , variant);
    
    if (variant.count == 0) {
        return;
    }
    else
    {
        [self changePrice:variant];
    }
}

/**
 规格数量的UI第二个参数选项改变
 */
- (void)changeSecondValue:(UIButton *)sender
{
    _lastSelectedType2.selected = NO;
    _lastSelectedType2.layer.borderColor = kLightBlackColor.CGColor;
    _lastSelectedType2 = sender;
    
    sender.selected = YES;
    sender.layer.borderColor =  kOrangeColor.CGColor;
    
    NSString *variantID = [self getSelectedVariantID];
    
    YunLog(@"variantID = %@", variantID);
    
    NSDictionary *variant = [NSDictionary dictionary];
    
    for (NSString *key in _sku_variants.allKeys) {
        if ([key isEqualToString:variantID]) {
            variant = _sku_variants[key];
        }
    }
    
    YunLog(@"variant = %@" , variant);
    
    if (variant.count == 0) {
        return;
    }
    else
    {
        [self changePrice:variant];
    }
}

/**
 规格数量的UI第三个参数选项改变
 */
- (void)changeThirdValue:(UIButton *)sender
{
    _lastSelectedType3.selected = NO;
    _lastSelectedType3.layer.borderColor = kLightBlackColor.CGColor;
    _lastSelectedType3 = sender;
    
    sender.selected = YES;
    sender.layer.borderColor = kOrangeColor.CGColor;
    
    NSString *variantID = [self getSelectedVariantID];
    
    YunLog(@"variantID = %@", variantID);
    
    NSDictionary *variant = [NSDictionary dictionary];
    
    for (NSString *key in _sku_variants.allKeys) {
        if ([key isEqualToString:variantID]) {
            variant = _sku_variants[key];
        }
    }
    
    YunLog(@"variant = %@" , variant);
    
    if (variant.count == 0) {
        return;
    }
    else
    {
        [self changePrice:variant];
    }
}

/**
 规格数量的UI根据选中的回个改变
 */
- (void)changePrice:(NSDictionary *)variant
{
    _variant = variant;
    
    _memberPrice.text = [NSString stringWithFormat:@"会员价:￥%@",kNullToString([variant objectForKey:@"price"])];
    _marketPrice.text = [NSString stringWithFormat:@"市场价:￥%@",kNullToString([variant objectForKey:@"market_price"])];
    _inventoryQuantityLabel.text = [NSString stringWithFormat:@"库存: %@",kNullToString([variant objectForKey:@"inventory"])];
}

/**
 商品数量减少
 */
- (void)sub
{
    NSInteger nowCount = [_countLabel.text integerValue];
    
    if ([[[_variant objectForKey:@"inventory"] stringValue] isEqualToString:@"0"])
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"该商品已经售完了哦~" delay:1.5];
    } else {
        if ([[_product objectForKey:@"is_limit_quantity"] integerValue] == 0) {
            if (nowCount == 1) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:[NSString stringWithFormat:@"至少购买%ld件哦~", (long)nowCount] delay:1.5];
                
                return;
            };
        } else {
            NSString *min = kNullToString([_product objectForKey:@"minimum_quantity"]);
            
            if ([min integerValue] == 0) {
                if (nowCount == 1) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [_hud addErrorString:[NSString stringWithFormat:@"至少购买%ld件哦~", (long)nowCount] delay:1.5];
                    
                    return;
                };
            }
            if (nowCount == [min integerValue]) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:[NSString stringWithFormat:@"至少购买%ld件哦~", (long)nowCount] delay:1.5];
                
                return;
            };
        }
        
        NSInteger count = [_countLabel.text integerValue] - 1;
        
        _countLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
    }
}

/**
 商品数量增加
 */
- (void)plus
{
    NSInteger nowCount = [_countLabel.text integerValue];
    
    NSInteger limited_quantity;
    if ([_product.allKeys containsObject:@"limited_quantity"]) {
        limited_quantity = [[_product safeObjectForKey:@"limited_quantity"] integerValue];  // 最大限购量
    } else {
        limited_quantity = [[_variant safeObjectForKey:@"inventory"] integerValue];  // 库存总量
    }
        
    if ([[[_variant objectForKey:@"inventory"] stringValue] isEqualToString:@"0"])
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"该商品已经售完了哦~" delay:1.5];
    } else {
        if (_variant) {
            NSInteger inventory = [[_variant safeObjectForKey:@"inventory"] integerValue];  // 库存总量
            if (limited_quantity >= inventory) {
                if (nowCount >= inventory)
                {
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [_hud addErrorString:@"库存不足了哦~" delay:1.5];
                    
                    return;
                }
            } else {
                if (nowCount >= limited_quantity) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    [_hud addErrorString:@"已经是最大购买数量了哦~" delay:1.5];
                    
                    return;
                }
            }
        }
        
        NSInteger count = [_countLabel.text integerValue] + 1;
        
        _countLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
    }
}

/**
 退出查看商品规格UI
 */
- (void)cancel
{
    [UIView animateWithDuration:0.5 animations:^{
        _cover.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            _backView.frame = CGRectMake(0, kScreenHeight + 10 + 30, kScreenWidth, kScreenHeight / 2 + 30);
        } completion:^(BOOL finished) {
        }];
    } completion:^(BOOL finished) {
        [_cover removeFromSuperview];
        _cover = nil;
        
        [_bottomViewDetail removeFromSuperview];
        _bottomViewDetail = nil;
        _scrollView.scrollEnabled = YES;
    }];
}

/**
 跳转到评论列表
 */
- (void)goToCommentList
{
    CommentListViewController *commentList = [[CommentListViewController alloc] init];
    
    commentList.code = [_product objectForKey:@"code"];
    
    [self.navigationController pushViewController:commentList animated:YES];
}

//- (void)initLayout
//{
//    _scrollHeight = 0;
//    
//    CGFloat imageHeight = 200 * kScreenWidth / 218;
//    
//    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
//    imageScrollView.showsVerticalScrollIndicator = NO;
//    imageScrollView.showsHorizontalScrollIndicator = NO;
//    imageScrollView.pagingEnabled = YES;
//    imageScrollView.delegate = self;
//    
//    [_scrollView addSubview:imageScrollView];
//    
//    NSArray *images = kNullToArray([_product objectForKey:@"images"]);
//    
//    if (images.count > 0)
//    {
//        for (int i = 0; i < images.count; i++)
//        {
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, imageHeight)];
//            imageView.contentMode = UIViewContentModeCenter;
//            
//            NSString *imageURL = kNullToString([images[i] objectForKey:@"origin_image"]);
//            
//            __weak UIImageView *_imageView = imageView;
//            
//            [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString(imageURL)]]
//                              placeholderImage:nil
//                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                           _imageView.contentMode = UIViewContentModeScaleToFill;
//                                           _imageView.image = image;
//                                       }
//                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                           [_imageView setImageWithURL:[NSURL URLWithString:kNullToString([images[i] objectForKey:@"large_image"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
//                                           _imageView.contentMode = UIViewContentModeScaleToFill;
//                                       }];
//            
//            [imageScrollView addSubview:imageView];
//        }
//        
//        imageScrollView.contentSize = CGSizeMake(kScreenWidth * images.count, imageHeight);
//        
//        _scrollHeight += imageHeight;
//    }
//    else
//    {
//        imageScrollView.frame = CGRectZero;
//    }
//    
//    if (images.count > 1) {
//        UIView *pageControlBackView = [[UIView alloc] initWithFrame:CGRectMake(0, imageHeight - 20, kScreenWidth, 20)];
//        pageControlBackView.backgroundColor = kOrangeColor;
//        
//        [_scrollView addSubview:pageControlBackView];
//        
//        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((kScreenWidth - images.count * 20) / 2, 0, images.count * 20, 20)];
//        _pageControl.numberOfPages = images.count;
//        _pageControl.currentPage = 0;
//        
//        if (kDeviceOSVersion >= 6.0) {
//            _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//            _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
//        }
//        
//        [pageControlBackView addSubview:_pageControl];
//    }
//    
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollHeight, kScreenWidth, 40)];
//    titleView.backgroundColor = [UIColor orangeColor];
//    
//    [_scrollView addSubview:titleView];
//    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
//    title.font = kNormalFont;
//    title.backgroundColor = kClearColor;
//    title.textColor = [UIColor whiteColor];
//    title.text = kNullToString([_product objectForKey:@"title"]);
//    title.textAlignment = NSTextAlignmentCenter;
//    
//    [titleView addSubview:title];
//    
//    _scrollHeight += 20;
//    
//    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, _scrollHeight, kScreenWidth, 40)];
//    more.backgroundColor = kClearColor;
//    
//    // 上边框
//    CALayer *topBorder = [CALayer layer];
//    topBorder.frame = CGRectMake(0, 0, more.frame.size.width, 1.0 / [UIScreen mainScreen].scale);
//    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
//    
//    [more.layer addSublayer:topBorder];
//    
//    // 下边框
//    CALayer *bottomBorder = [CALayer layer];
//    
//    bottomBorder.frame = CGRectMake(0, more.frame.size.height, more.frame.size.width, 1.0 / [UIScreen mainScreen].scale);
//    bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
//    
//    [more.layer addSublayer:bottomBorder];
//    
//    [more addTarget:self action:@selector(getImageDetail:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_scrollView addSubview:more];
//    
//    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, more.frame.size.height)];
//    moreLabel.backgroundColor = kClearColor;
//    moreLabel.font = kNormalFont;
//    moreLabel.text = @"查看更多图文详情";
//    
//    [more addSubview:moreLabel];
//    
//    UIImageView *rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow_16"]];
//    rightArrow.frame = CGRectMake(kScreenWidth - 26, (more.frame.size.height - 16) / 2, 16, 16);
//    
//    [more addSubview:rightArrow];
//    
//    _scrollHeight += 40 + 20;
//    
//    // 商品规格 默认选中的规格是第一个规格
//    // 具体规格信息
//    NSDictionary *variants = [NSDictionary dictionary];
//    variants = [_sku_variants objectForKey:[_variantsIdArray firstObject]];
//    
//    NSString *variantName = [self getVariantName:variants];
//    
//    YunLog(@"variants = %@", variants);
//    
//    // 价格
//    UIView *priceContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(more.frame) + 20, kScreenWidth, 110)];
//    
//    [_scrollView addSubview:priceContainer];
//    
//    _scrollHeight += 110;
//    
//    // 这里 imageview的高度请设置为90
//    _variantImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 80)];
//    _variantImageView.backgroundColor = kClearColor;
//    _variantImageView.contentMode = UIViewContentModeCenter;
//    
//    __weak UIImageView *weakImageView = _variantImageView;
//    __weak NSDictionary *product = _product;
//    [_variantImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kNullToString([product objectForKey:@"image_url_200"])]]
//                             placeholderImage:nil
//                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                          weakImageView.image = image;
//                                          weakImageView.contentMode = UIViewContentModeScaleAspectFill;
//                                      }
//                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                          [weakImageView setImageWithURL:[NSURL URLWithString:kNullToString([product objectForKey:@"image_url"])] placeholderImage:[UIImage imageNamed:@"default_history"]];
//                                          weakImageView.contentMode = UIViewContentModeScaleAspectFill;
//                                      }];
//    
//    [priceContainer addSubview:_variantImageView];
//    
//    CGFloat priceHeight = 8;
//    // 规格名称
//    NSString *variantNameStr = kNullToString(variantName);
//    
//    _variantName = [[UILabel alloc] initWithFrame:CGRectMake(128, priceHeight, kScreenWidth - 138, 18)];
//    _variantName.backgroundColor = kClearColor;
//    _variantName.font = [UIFont fontWithName:kFontFamily size:14];
//    _variantName.text = variantNameStr;
//    
//    [priceContainer addSubview:_variantName];
//    
//    priceHeight += _variantName.frame.size.height + 5;
//    
//    // 规格副标题
////    _variantSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(128, 10 + _variantName.frame.size.height, kScreenWidth - 138, 16)];
////    _variantSubtitle.backgroundColor = kClearColor;
////    _variantSubtitle.font = kSmallFont;
////    _variantSubtitle.text = kNullToString([variants objectForKey:@"value1"]);
////    _variantSubtitle.textColor = [UIColor grayColor];
////    
////    [priceContainer addSubview:_variantSubtitle];
//    
//    CGFloat promotionsLabelX = 128;
//    CGFloat promotionsLabelWidth = kScreenWidth - 138;
//    CGFloat promotionsLabelHeight = 16;
//    for (int i = 0; i < _product_promotions.count; i++) {
//        CGFloat promotionsLabelY = priceHeight + promotionsLabelHeight * i;
//        NSDictionary *dictPro = _product_promotions[i];
//        
//        UILabel *promotionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(promotionsLabelX, promotionsLabelY, promotionsLabelWidth, promotionsLabelHeight)];
//        promotionsLabel.backgroundColor = kClearColor;
//        promotionsLabel.font = kSmallFont;
//        promotionsLabel.textColor = [UIColor redColor];
//        promotionsLabel.text = [NSString stringWithFormat:@"优惠: %@", [dictPro safeObjectForKey:@"name"]];
//        
//        if (i == _product_promotions.count - 1) {
//            priceHeight = CGRectGetMaxY(promotionsLabel.frame) + 5;
//        }
//        
//        [priceContainer addSubview:promotionsLabel];
//    }
//    
//    // 保存他的高度
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", priceHeight] forKey:@"priceHeight"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    // 优惠价
//    NSString *priceText = kNullToString([variants objectForKey:@"price"]);
//    
//    CGSize priceSize = [[@"￥" stringByAppendingString:priceText] sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
//    
//    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, priceHeight, priceSize.width, 20)];
//    _priceLabel.backgroundColor = kClearColor;
//    _priceLabel.textColor = [UIColor orangeColor];
//    _priceLabel.font = kBigFont;
//    _priceLabel.text = [NSString stringWithFormat:@"￥%@", priceText];
//    
//    [priceContainer addSubview:_priceLabel];
//    
//    // 市场价
//    NSString *marketPriceText = kNullToString([variants objectForKey:@"market_price"]);
//    
//    CGSize size = [[@"￥" stringByAppendingString:marketPriceText] sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
//    
//    _marketPriceLabel = [[UILabelWithLine alloc] initWithFrame:CGRectMake(_priceLabel.frame.origin.x + _priceLabel.frame.size.width, priceHeight, size.width, 20)];
//    _marketPriceLabel.backgroundColor = kClearColor;
//    _marketPriceLabel.font = kNormalFont;
//    
//    _marketPriceLabel.textColor = [UIColor lightGrayColor];
//    
//    [priceContainer addSubview:_marketPriceLabel];
//    
//    float priceFloat = [priceText floatValue];
//    float marketFloat = [marketPriceText floatValue];
//    
//    if (priceFloat < marketFloat) {
//        _marketPriceLabel.text = [NSString stringWithFormat:@"￥%@", marketPriceText];;
//    } else {
//        _marketPriceLabel.text = @"";
//    }
//    
//    // 已售出
//    _saledLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, CGRectGetMaxY(_priceLabel.frame) + 5, (kScreenWidth - 138) / 2, 10 + kSpace)]; //!< 修复小BUG  label高度太偏低， 文字会覆盖
//    _saledLabel.backgroundColor = kClearColor;
//    _saledLabel.textColor = [UIColor blackColor];
//    _saledLabel.font = [UIFont fontWithName:kFontFamily size:kFontSmallSize];
//    
//    // TODO   等待接口添加对应的属性字段  目前这里使用全部的已售出字段
//    if ([[variants objectForKey:@"inventory"] integerValue] > 0) {
//        _saledLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([_product objectForKey:@"sales_quantity"])];
//        _saledLabel.textColor = [UIColor blackColor];
//    } else {
//        _saledLabel.text = @"目前缺货";
//        _saledLabel.textColor = [UIColor redColor];
//    }
//    
//    [priceContainer addSubview:_saledLabel];
//    
//    if ([[variants objectForKey:@"inventory"] integerValue] > 0)
//    {
//        // 库存量
//        CGFloat inventoryLabelX = CGRectGetMaxX(_saledLabel.frame) - 6 * kSpace;
//        _inventoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_saledLabel.frame), CGRectGetMaxY(_priceLabel.frame) + 5, kScreenWidth - inventoryLabelX, 10 + kSpace)];
//        YunLog(@"frame = %@", NSStringFromCGRect(_inventoryLabel.frame));
//        _inventoryLabel.backgroundColor = kClearColor;
//        _inventoryLabel.textColor       = [UIColor blackColor];
//        _inventoryLabel.font            = [UIFont fontWithName:kFontFamily size:kFontSmallSize];
//        _inventoryLabel.text            = [NSString stringWithFormat:@"库存 %@",kNullToString([variants objectForKey:@"inventory"])];
//        
//        [priceContainer addSubview:_inventoryLabel];
//    }
//    
//    //    priceContainer.frame = CGRectMake(0, more.frame.origin.y + more.frame.size.height + 20, kScreenWidth, _scrollHeight - more.frame.origin.y - more.frame.size.height - 20);
//    
//    // 上边框
//    CALayer *priceTopBorder = [CALayer layer];
//    
//    priceTopBorder.frame = CGRectMake(0, 0, priceContainer.frame.size.width, 1.0 / [UIScreen mainScreen].scale);
//    priceTopBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
//    
//    [priceContainer.layer addSublayer:priceTopBorder];
//    
//    // 下边框
//    CALayer *priceBottomBorder = [CALayer layer];
//    
//    priceBottomBorder.frame = CGRectMake(0, priceContainer.frame.size.height, priceContainer.frame.size.width, 1.0 / [UIScreen mainScreen].scale);
//    priceBottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
//    
//    [priceContainer.layer addSublayer:priceBottomBorder];
//    
//    _scrollHeight += 40;
//    
//    // 规格
//    EnterButton *variantsButton = [[EnterButton alloc] initWithFrame:CGRectMake(10, _scrollHeight - 30, kScreenWidth - 20, 20)];
//    variantsButton.backgroundColor = kClearColor;
//    [variantsButton addTarget:self action:@selector(selectVariantsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    variantsButton.alpha = 0.7;
//    
//    [_scrollView addSubview:variantsButton];
//    
//    UILabel *variantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _scrollHeight - 30, kScreenWidth - 20, 20)];
//    variantsLabel.text = @"规格: 尺寸、大小、颜色";
//    variantsLabel.font = kNormalFont;
//    variantsLabel.textColor = kBlackColor;
//    variantsLabel.textAlignment = NSTextAlignmentLeft;
//    
//    [_scrollView addSubview:variantsLabel];
//    
//    UIImageView *variantsArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow_16"]];
//    variantsArrow.frame = CGRectMake(kScreenWidth - 26, variantsButton.frame.origin.y + 2, 16, 16);
//    
//    [_scrollView addSubview:variantsArrow];
//    
//    UIView *varianteLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(variantsButton.frame) + 10, kScreenWidth, 1 / [UIScreen mainScreen].scale)];
//    varianteLineView.backgroundColor = [UIColor lightGrayColor];
//    
//    [_scrollView addSubview:varianteLineView];
//    
//    // 购买须知
//    YunLog(@"dic = %@", _product_guide);
//    if (![[_product_guide objectForKey:@"title"] isEqualToString:@""] && [[_product_guide objectForKey:@"items"] count] > 0)
//    {
//        // 标题
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _scrollHeight, kScreenWidth - 20, 40)];
//        titleLabel.text = [_product_guide objectForKey:@"title"];
//        titleLabel.textColor = kOrangeColor;
//        titleLabel.textAlignment = NSTextAlignmentLeft;
//        titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
//        
//        [_scrollView addSubview:titleLabel];
//        
//        // 添加底部线条
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame), kScreenWidth - 20, 1.0 / [UIScreen mainScreen].scale)];
//        lineView.backgroundColor = [UIColor lightGrayColor];
//        
//        [_scrollView addSubview:lineView];
//        
//        // 几个须知信息
//        for (int i = 0; i< [[_product_guide objectForKey:@"items"] count]; i++) {
//            NSDictionary *itemDict = [_product_guide objectForKey:@"items"][i];
//            NSString *itemString = [NSString stringWithFormat:@"-%@", itemDict[@"text"]];
//            NSString *strUrl = [itemString stringByReplacingOccurrencesOfString:@" " withString:@""]; // 去掉空格
//            
//            CGFloat titleHeight = [Tool calculateContentLabelHeight:strUrl withFont:[UIFont fontWithName:kFontFamily size:kFontMidSize] withWidth:kScreenWidth - 20];
//            YunLog(@"titleheight = %f", titleHeight);
//            CGFloat itemLabelHeight = 0;
//            
//            if (titleHeight >= 30) {
//                itemLabelHeight = titleHeight;
//                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", itemLabelHeight] forKey:[NSString stringWithFormat:@"height%d", i]];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            } else {
//                itemLabelHeight = 30;
//               [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", itemLabelHeight] forKey:[NSString stringWithFormat:@"height%d", i]];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//            CGFloat itemLabelX = 10;
//            CGFloat itemLabelWidth = kScreenWidth - 20;
//            CGFloat itemLabelY = CGRectGetMaxY(lineView.frame) + 5;
//            
//            for (int j = 1; j <= i; j++) {
//                CGFloat height = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"height%d", j]] integerValue];
//                
//                itemLabelY += height;
//                YunLog(@"itemLableY = %f", itemLabelY);
//                
//            }
//
//            UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemLabelX, itemLabelY, itemLabelWidth, itemLabelHeight)];
//            itemLabel.text = strUrl;
//            itemLabel.textColor = [UIColor blackColor];
//            itemLabel.numberOfLines = 0;
//            itemLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
//            
//            if (i == [[_product_guide objectForKey:@"items"] count] - 1) {
//                _scrollHeight = CGRectGetMaxY(itemLabel.frame) + kSpace;
//            }
//            
//            [_scrollView addSubview:itemLabel];
//        }
//    }
//    
//    // 商品详情对应字段介绍
//    if (![[_product_detail objectForKey:@"title"] isEqualToString:@""] && [[_product_detail objectForKey:@"items"] count] > 0)
//    {
//        // 标题
//        UILabel *attributeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _scrollHeight, kScreenWidth - 20, 40)];
//        attributeLabel.text = [_product_detail objectForKey:@"title"];
//        attributeLabel.textColor = kOrangeColor;
//        attributeLabel.textAlignment = NSTextAlignmentLeft;
//        attributeLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
//        
//        [_scrollView addSubview:attributeLabel];
//        
//        // 添加底部线条
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(attributeLabel.frame), kScreenWidth - 20, 1.0 / [UIScreen mainScreen].scale)];
//        lineView.backgroundColor = [UIColor lightGrayColor];
//        
//        [_scrollView addSubview:lineView];
//        
//        // 几个商品详情属性
//        for (int i = 0; i< [[_product_detail objectForKey:@"items"] count]; i++) {
//            CGFloat labelY = CGRectGetMaxY(lineView.frame) + 10 + _height;
//            NSString *leftLabelStr = [[_product_detail objectForKey:@"items"][i] objectForKey:@"attr_name"];
//            CGSize size1 = [leftLabelStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 110, 9999)];
//            UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, labelY, 110, size1.height)];
//            leftLabel.text = leftLabelStr;
//            leftLabel.numberOfLines = 0;
//            leftLabel.textColor = [UIColor lightGrayColor];
//            leftLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
//            
//            [_scrollView addSubview:leftLabel];
//            
//            NSString *rightLabelStr = [NSString stringWithFormat:@"%@",[[_product_detail objectForKey:@"items"][i] objectForKey:@"text"]];
//            CGSize size2 = [rightLabelStr sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 130, 9999)];
//            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftLabel.frame), labelY, kScreenWidth - 130, size2.height)];
//            rightLabel.text = rightLabelStr;
//            rightLabel.numberOfLines = 0;
//            rightLabel.textColor = [UIColor blackColor];
//            rightLabel.font = [UIFont fontWithName:kFontFamily size:kFontMidSize];
//            
//            [_scrollView addSubview:rightLabel];
//            
//            _height += (size2.height + 5);
//            
//            if (i == [[_product_detail objectForKey:@"items"] count] - 1) {
//                _scrollHeight = CGRectGetMaxY(rightLabel.frame) + kSpace;
//            }
//        }
//    }
//    if (! _isAdmin) {
//        // 底部工具栏
//        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 48, kScreenWidth + 2, 48)];
//        
//        if (kDeviceOSVersion < 7.0) {
//            bottomView.frame = CGRectMake(-1, kScreenHeight - 108, kScreenWidth + 2, 48);
//        }
//        
//        bottomView.backgroundColor = kBackgroundColor;
//        //    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
//        //    bottomView.layer.shadowOffset = CGSizeMake(1, 5);
//        //    bottomView.layer.shadowOpacity = 1.0;
//        //    bottomView.layer.shadowRadius = 5.0;
//        bottomView.layer.borderColor = COLOR(178, 178, 178, 1).CGColor;
//        bottomView.layer.borderWidth = 1;
//        bottomView.clipsToBounds = NO;
//        
//        [self.view addSubview:bottomView];
//        
//        _bottomCart = [[UIButton alloc] initWithFrame:CGRectMake(15, 9, 32.5, 30)];
//        [_bottomCart setImage:[UIImage imageNamed:@"cart_tab_select"] forState:UIControlStateNormal];
//        [_bottomCart addTarget:self action:@selector(goToCart) forControlEvents:UIControlEventTouchUpInside];
//        
//        [bottomView addSubview:_bottomCart];
//        
//        _cartCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cartCount"] integerValue];
//        if (_cartCount <= 0) {
//            [_bottomCart removeBadge];
//        } else {
//            [_bottomCart removeBadge];
//            [_bottomCart addBadge:[NSString stringWithFormat:@"%ld", (long)_cartCount]];
//        }
//        
//        if ([[_product objectForKey:@"inventory_quantity"] integerValue] > 0) {
//            UIButton *addToCart = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 8, 100, 32)];
//            addToCart.layer.cornerRadius = 6;
//            addToCart.layer.masksToBounds = YES;
//            addToCart.backgroundColor = [UIColor orangeColor];
//            addToCart.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
//            [addToCart setTitle:@"加入购物车" forState:UIControlStateNormal];
//            [addToCart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [addToCart addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
//            
//            [bottomView addSubview:addToCart];
//            
//            UIButton *buy = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 8, 100, 32)];
//            buy.layer.cornerRadius = 6;
//            buy.layer.masksToBounds = YES;
//            buy.backgroundColor = [UIColor orangeColor];
//            buy.titleLabel.font = [UIFont fontWithName:kFontFamily size:14];
//            [buy setTitle:@"立即购买" forState:UIControlStateNormal];
//            [buy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [buy addTarget:self action:@selector(nowToBuy) forControlEvents:UIControlEventTouchUpInside];
//            
//            [bottomView addSubview:buy];
//        }
//    }
//    if (kDeviceOSVersion < 7.0) {
//        if (!_isAdmin)
//        {
//            _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 108);
//        }
//        else
//        {
//            _scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 60);
//        }
//    }
//    _scrollView.contentSize = CGSizeMake(kScreenWidth, _scrollHeight);
//}

//- (void)selectVariantsButtonClick:(EnterButton *)sender
//{
//    YunLog(@"来来");
//    _variantsSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 48, kScreenWidth, kScreenHeight - 48 - 64 - 156)];
//    _variantsSelectView.backgroundColor = kBlackColor;
//    _variantsSelectView.alpha = 0.8;
//    CGFloat ViewHeight = 46 * _variantsIdArray.count;
//    if (ViewHeight > kScreenHeight - 48 - 64 - 156) {
//        _variantsSelectView.contentSize = CGSizeMake(kScreenWidth, ViewHeight);
//    } else {
//        _variantsSelectView.contentSize = CGSizeMake(kScreenWidth, _variantsSelectView.bounds.size.height);
//    }
//    _variantsSelectView.showsHorizontalScrollIndicator = NO;
//    _variantsSelectView.showsVerticalScrollIndicator = NO;
//    
//    [self.view addSubview:_variantsSelectView];
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        CGRect frame = _variantsSelectView.frame;
//        
//        frame.origin.y = 156 + 64;
//        
//        _variantsSelectView.frame = frame;
//    }];
//    
//    UITapGestureRecognizer *oneGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(variantsViewHiddan)];
//    oneGesture.numberOfTouchesRequired = 1; //手指数
//    oneGesture.numberOfTapsRequired = 1; //tap次数
//    oneGesture.delegate = self;
//    
//    [_variantsSelectView addGestureRecognizer:oneGesture];
//    
//    CGFloat buttonX = 2 * kSpace;
//    CGFloat buttonWidth = kScreenWidth - 100;
//    CGFloat buttonHeight = 36;
//    // 添加所有的规格信息
//    for (int i = 0; i < _variantsIdArray.count; i++) {
//        CGFloat buttonY = 10 + (buttonHeight + 10) * i;
//        
//        NSDictionary *variantDict = [_sku_variants objectForKey:_variantsIdArray[i]];
//        
//        NSString *buttonName = [self getVariantName:variantDict];  /// 按钮名称
//        
//        EnterButton *buttonVariant = [[EnterButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
//        buttonVariant.layer.masksToBounds = YES;
//        buttonVariant.layer.cornerRadius = 6;
//        buttonVariant.layer.borderColor = kOrangeColor.CGColor;
//        buttonVariant.layer.borderWidth = 1.5;
//        YunLog(@"tag = %@", [_variantsIdArray[i] stringByReplacingOccurrencesOfString:@"_" withString:@""]);
//        buttonVariant.tag = [[_variantsIdArray[i] stringByReplacingOccurrencesOfString:@"_" withString:@""] integerValue];
//        buttonVariant.product_variantID = _variantsIdArray[i];
//        YunLog(@"buttonTag = %ld  ---  %@", (long)buttonVariant.tag, buttonVariant.product_variantID);
//
//        if (buttonVariant.product_variantID == _selectedNewVariant) {
//            _selectedNewVariant = buttonVariant.product_variantID;
//            buttonVariant.backgroundColor = [UIColor orangeColor];
//            [buttonVariant setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        } else {
//            buttonVariant.backgroundColor = kClearColor;
//            [buttonVariant setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//        }
//        [buttonVariant setTitle:buttonName forState:UIControlStateNormal];
//        
//        [buttonVariant addTarget:self action:@selector(variantsSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [_variantsSelectView addSubview:buttonVariant];
//    }
//}

//// 隐藏variantsView
//- (void)variantsViewHiddan
//{
//    [UIView animateWithDuration:0.5 animations:^{
//        CGRect frame = _variantsSelectView.frame;
//        
//        frame.origin.y = kScreenHeight;
//        
//        _variantsSelectView.frame = frame;
//    }];
//}

/**
 返回这个规格里面组合的名称
 */
- (NSString *)getVariantName:(NSDictionary *)variant
{
    NSString *VariantName;
    switch (_sku_categories.count) {
        case 1:
        {
            VariantName = [NSString stringWithFormat:@"%@",[variant safeObjectForKey:@"value1"]];
            
            break;
        }
        case 2:
        {
            VariantName = [NSString stringWithFormat:@"%@ %@",[variant safeObjectForKey:@"value1"], [variant safeObjectForKey:@"value2"]];
            break;
        }
            
        case 3:
        {
            VariantName = [NSString stringWithFormat:@"%@ %@ %@",[variant safeObjectForKey:@"value1"], [variant safeObjectForKey:@"value2"], [variant safeObjectForKey:@"value3"]];
            break;
        }
        default:
            break;
    }
    return VariantName;
}

/**
 返回最后选中的规格的ID
 */
- (NSString *)getSelectedVariantID
{
    NSString *variantID;
    switch (_sku_categories.count) {
        case 1:
        {
            variantID = [NSString stringWithFormat:@"%ld", (long)_lastSelectedType1.tag];
            
            break;
        }
        case 2:
        {
            variantID = [NSString stringWithFormat:@"%ld_%ld", (long)_lastSelectedType1.tag, (long)_lastSelectedType2.tag];
            break;
        }
            
        case 3:
        {
            variantID = [NSString stringWithFormat:@"%ld_%ld_%ld", (long)_lastSelectedType1.tag, (long)_lastSelectedType2.tag, (long)_lastSelectedType3.tag];
            break;
        }
        default:
            break;
    }
    return variantID;
}

//- (void)variantsSelectButtonClick:(EnterButton *)sender
//{
//    if (_selectedNewVariant == sender.product_variantID) {
//        [self variantsViewHiddan];
//        
//        return;
//    }
//    
//    CGFloat priceHeight = 0;
//    
//    NSDictionary *variant = [_sku_variants objectForKey:sender.product_variantID];
//    NSInteger selectButtonTag = [[_selectedNewVariant stringByReplacingOccurrencesOfString:@"_" withString:@""] integerValue];
//    EnterButton *button = (EnterButton *)[_variantsSelectView viewWithTag:selectButtonTag];
//    
//    button.backgroundColor = kClearColor;
//    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
//    
//    sender.backgroundColor = [UIColor orangeColor];
//    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    _selectedNewVariant = sender.product_variantID;
//    
//    YunLog(@"variant = %@", variant);
//    
//    NSString *buttonName = [self getVariantName:variant];
//    
//    _variantName.text = kNullToString(buttonName);
//    
//    NSString *priceText = kNullToString([variant objectForKey:@"price"]);
//    
//    CGSize priceSize = [[@"￥" stringByAppendingString:priceText] sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
//    
//    priceHeight += [[[NSUserDefaults standardUserDefaults] objectForKey:@"priceHeight"] floatValue];
//    
//    _priceLabel.text = [@"￥" stringByAppendingString:kNullToString([variant objectForKey:@"price"])];
//    _priceLabel.frame = CGRectMake(128, priceHeight, priceSize.width, 20);
//    
//    NSString *marketPriceText = kNullToString([variant objectForKey:@"market_price"]);
//    
//    if ([marketPriceText isEqualToString:@"0"]) {
//        _marketPriceLabel.text = @"";
//    } else {
//        CGSize size = [[@"￥" stringByAppendingString:marketPriceText] sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
//        
//        _marketPriceLabel.frame = CGRectMake(5 + _priceLabel.frame.origin.x + _priceLabel.frame.size.width, priceHeight, size.width, 20);
//        _marketPriceLabel.text = [@"￥" stringByAppendingString:marketPriceText];
//    }
//    
//    if ([[variant objectForKey:@"inventory"] integerValue] > 0) {
//        _inventoryLabel.hidden = NO;
//        _saledLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([_product objectForKey:@"sales_quantity"])];
//        _saledLabel.textColor = [UIColor blackColor];
//        
//        _inventoryLabel.text = [NSString stringWithFormat:@"库存 %@",kNullToString([variant objectForKey:@"inventory"])];
//        _inventoryLabel.textColor = [UIColor blackColor];
//    } else {
//        _inventoryLabel.hidden = YES;
//        
//        _saledLabel.text = @"目前缺货";
//        _saledLabel.textColor = [UIColor redColor];
//    }
//    
//    /// 收下
//    [self variantsViewHiddan];
//}

//- (void)changeVariant:(EnterButton *)sender
//{
//    if (_selectedNewVariant == sender.product_variantID) return;
//    
//    EnterButton *button = (EnterButton *)[_scrollView viewWithTag:[_selectedNewVariant intValue]];
//    button.selected = NO;
//    button.backgroundColor = [UIColor whiteColor];
//    
//    sender.backgroundColor = [UIColor orangeColor];
//    sender.selected = YES;
//    
//    _selectedNewVariant = sender.product_variantID;
//    
//    NSDictionary *variant = [[_product_variants objectForKey:@"variants"] objectForKey:sender.product_variantID];
//    
//    YunLog(@"variant = %@", variant);
//    
//    _variantName.text = kNullToString([_product objectForKey:@"title"]);
//    _variantSubtitle.text = kNullToString([variant objectForKey:@"value1"]);
//    
//    //    [_variantImageView setImageWithURL:[NSURL URLWithString:kNullToString([variant objectForKey:@"small_icon"])]
//    //                      placeholderImage:[UIImage imageNamed:@"default_image"]];
//    
//    NSString *priceText = kNullToString([variant objectForKey:@"price"]);
//    
//    CGSize priceSize = [[@"￥" stringByAppendingString:priceText] sizeWithAttributes:@{NSFontAttributeName:kBigFont}];
//    
//    _priceLabel.text = [@"￥" stringByAppendingString:kNullToString([variant objectForKey:@"price"])];
//    _priceLabel.frame = CGRectMake(128, 48, priceSize.width, 20);
//    
//    NSString *marketPriceText = kNullToString([variant objectForKey:@"market_price"]);
//    
//    if ([marketPriceText isEqualToString:@"0"]) {
//        _marketPriceLabel.text = @"";
//    } else {
//        CGSize size = [[@"￥" stringByAppendingString:marketPriceText] sizeWithAttributes:@{NSFontAttributeName:kNormalFont}];
//        
//        _marketPriceLabel.frame = CGRectMake(5 + _priceLabel.frame.origin.x + _priceLabel.frame.size.width, 48, size.width, 20);
//        _marketPriceLabel.text = [@"￥" stringByAppendingString:marketPriceText];
//    }
//    
//    if ([[variant objectForKey:@"inventory"] integerValue] > 0) {
//        _inventoryLabel.hidden = NO;
//        _saledLabel.text = [NSString stringWithFormat:@"已售出 %@", kNullToString([_product objectForKey:@"sales_quantity"])];
//        _saledLabel.textColor = [UIColor blackColor];
//        
//        _inventoryLabel.text = [NSString stringWithFormat:@"库存 %@",kNullToString([variant objectForKey:@"inventory"])];
//        _inventoryLabel.textColor = [UIColor blackColor];
//    } else {
//        _inventoryLabel.hidden = YES;
//        
//        _saledLabel.text = @"目前缺货";
//        _saledLabel.textColor = [UIColor redColor];
//    }
//}

- (void)openShare
{
    //    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"取消"
    //                                         destructiveButtonTitle:nil
    //                                              otherButtonTitles:@"分享到新浪微博", @"分享给微信好友", @"分享到微信朋友圈", nil];
    //    [sheet showInView:self.view];
    
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_weixin" , @"title" : @"微信"},
                                                                     
                                                                     @{@"icon" : @"share_weixin_friend" , @"title" : @"朋友圈"},
                                                                     
                                                                     @{@"icon" : @"share_weibo" , @"title" : @"微博"}]
                                                         bottomBar:@[]
                               ];
    
    shareView.delegate = self;
    
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
}

- (void)isWeiXinInstalled:(NSInteger)scene
{
    if ([WXApi isWXAppInstalled]) {
        NSString *thumb;
        
//        if (![[[_product objectForKey:@"share_logo"] toString] isEqualToString:@""]) {
//            thumb = [_product objectForKey:@"share_logo"];
//        } else
            if (![[[[[_product objectForKey:@"images"] firstObject] objectForKey:@"thumb_image" ] toString] isEqualToString:@""]) {
            thumb = [[[_product objectForKey:@"images"] firstObject] objectForKey:@"thumb_image" ];
        } else {
            thumb = @"";
        }
        
        NSString *desc = [[_product safeObjectForKey:@"short_desc"] toString];
        
        [Tool shareToWeiXin:scene
                      title:[_product objectForKey:@"title"]
                description:desc
                      thumb:thumb
                        url:[_product objectForKey:@"share_url"]];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"未安装微信客户端，去下载？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"现在下载", nil];
        [alert show];
    }
}

/**
 去购物车
 */
- (void)goToCart
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isCartEnterProductDetail"] isEqualToString:@"yes"]) {
        [self backToPrev];
    }
    else
    {
//        self.tabBarController.selectedIndex = 1;
//        
//        AppDelegate *appDelegate = kAppDelegate;
//        
//        self.tabBarController.tabBar.hidden = YES;
//        
//        appDelegate.lastSelectedTabIndex = 1;
        
        CartNewViewController *cart = [[CartNewViewController alloc] init];
        cart.hidesBottomBarWhenPushed = YES;
        cart.needToHideBottomBar = YES;
        
        [self.navigationController pushViewController:cart animated:YES];
    }
}

/**
 去店铺首页
 */
- (void)goToShop
{
    ShopInfoNewController *shop = [[ShopInfoNewController alloc] init];
    shop.code = _shopCode;
    
    [self.navigationController pushViewController:shop animated:YES];
}

/**
 添加商品到购物车
 */
- (void)addToCart
{
    NSString *alarmStr;
    
    AppDelegate *appDelegate = kAppDelegate;

    /// 将分类里面的数组全部存起来
    switch (_sku_categories.count) {
        case 1:
        {
            _selectedNewVariant = [NSString stringWithFormat:@"%ld", (long)_lastSelectedType1.tag];
            
            alarmStr = [NSString stringWithFormat:@"%@", [_variant objectForKey:@"value1"]];
            
            break;
        }
        case 2:
        {
            if (_lastSelectedType2.tag == 0) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                [_hud addErrorString:[NSString stringWithFormat:@"请选择%@", kNullToString([_sku_categories[1] objectForKey:@"title"])] delay:1.5];
                
                return;
            }
            
            _selectedNewVariant = [NSString stringWithFormat:@"%ld_%ld", (long)_lastSelectedType1.tag, (long)_lastSelectedType2.tag];
            
            alarmStr = [NSString stringWithFormat:@"%@ %@", [_variant objectForKey:@"value1"], [_variant objectForKey:@"value2"]];
            
            YunLog(@"_selectedNewVariant = %@", _selectedNewVariant);
            
            break;
        }
        case 3:
        {
            if (_lastSelectedType2.tag == 0) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                [_hud addErrorString:[NSString stringWithFormat:@"请选择%@", kNullToString([_sku_categories[1] objectForKey:@"title"])] delay:1.5];
                
                return;
            }
            if (_lastSelectedType3.tag == 0) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                [_hud addErrorString:[NSString stringWithFormat:@"请选择%@", kNullToString([_sku_categories[2] objectForKey:@"title"])] delay:1.5];
                
                return;
            }
            _selectedNewVariant = [NSString stringWithFormat:@"%ld_%ld_%ld", (long)_lastSelectedType1.tag, (long)_lastSelectedType2.tag, (long)_lastSelectedType3.tag];
            
            alarmStr = [NSString stringWithFormat:@"%@ %@ %@", [_variant objectForKey:@"value1"], [_variant objectForKey:@"value2"], [_variant objectForKey:@"value3"]];
            
            break;
        }
        default:
            break;
    }
    
    if ([[_variant objectForKey:@"inventory"] integerValue] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alarmStr message:@"目前缺货" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alertView show];
    } else if ([_countLabel.text integerValue] > [[_variant objectForKey:@"inventory"] integerValue]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alarmStr message:@"库存不足" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alertView show];
    } else {
        if (appDelegate.isLogin) {
            [self doAddToCartNew];
        } else {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isReturnView = YES;
            loginVC.isBuyEnter = YES;
            
            UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            
            [self.navigationController presentViewController:loginNC animated:YES completion:nil];
        }
    }
}

/**
 立即购买
 */
- (void)nowToBuy
{
    NSString *alarmStr;
    
    /// 将分类里面的数组全部存起来
    switch (_sku_categories.count) {
        case 1:
        {
            _selectedNewVariant = [NSString stringWithFormat:@"%ld",(long)_lastSelectedType1.tag];
            
            alarmStr = [NSString stringWithFormat:@"%@", [_variant objectForKey:@"value1"]];
            
            break;
        }
        case 2:
        {
            if (_lastSelectedType2.tag == 0) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                [_hud addErrorString:[NSString stringWithFormat:@"请选择%@", kNullToString([_sku_categories[1] objectForKey:@"title"])] delay:1.5];
                
                return;
            }

            _selectedNewVariant = [NSString stringWithFormat:@"%ld_%ld", (long)_lastSelectedType1.tag, (long)_lastSelectedType2.tag];
            
            alarmStr = [NSString stringWithFormat:@"%@ %@", [_variant objectForKey:@"value1"], [_variant objectForKey:@"value2"]];
            
            break;
        }
        case 3:
        {
            if (_lastSelectedType2.tag == 0) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                [_hud addErrorString:[NSString stringWithFormat:@"请选择%@", kNullToString([_sku_categories[1] objectForKey:@"title"])] delay:1.5];
                
                return;
            }
            if (_lastSelectedType3.tag == 0) {
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                
                [_hud addErrorString:[NSString stringWithFormat:@"请选择%@", kNullToString([_sku_categories[2] objectForKey:@"title"])] delay:1.5];
                
                return;
            }

            _selectedNewVariant = [NSString stringWithFormat:@"%ld_%ld_%ld", (long)_lastSelectedType1.tag, (long)_lastSelectedType2.tag, (long)_lastSelectedType3.tag];
            
            alarmStr = [NSString stringWithFormat:@"%@ %@ %@", [_variant objectForKey:@"value1"], [_variant objectForKey:@"value2"], [_variant objectForKey:@"value3"]];
            
            break;
        }
        default:
            break;
    }
    
    YunLog(@"_sku = %@", _sku_categories);
    
    NSDictionary *variant = [NSDictionary dictionary];
    
    for (NSString *key in _sku_variants.allKeys) {
        if ([key isEqualToString:_selectedNewVariant]) {
            variant = _sku_variants[key];
        }
    }
    
    if ([[variant objectForKey:@"inventory"] integerValue] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alarmStr message:@"目前缺货" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alertView show];
    } else if ([_countLabel.text integerValue] > [[_variant objectForKey:@"inventory"] integerValue]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alarmStr message:@"库存不足" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alertView show];
    } else {
//        NSString *name = kNullToString([_product objectForKey:@"title"]);
        
//        NSDictionary *variant = [[_product_variants objectForKey:@"variants"] objectForKey:_selectedNewVariant];
//        
//        NSString *variantName = [self getVariantName:variant];
//        
//        NSString *subtitle  = kNullToString(variantName);
//        NSString *price     = kNullToString([variant objectForKey:@"price"]);
//        NSString *skuid     = kNullToString([variant objectForKey:@"sku_id"]);
//        NSString *inventory = kNullToString([variant objectForKey:@"inventory"]);
//        NSString *imageURL  = kNullToString([_product objectForKey:@"image_url"]);
//        NSString *smal_imageURL = kNullToString([_product objectForKey:@"smal_image_url"]);
//        
//        NSMutableDictionary *order = [[NSMutableDictionary alloc] init];
//        
//        [order setObject:name forKey:CartManagerDescriptionKey];
//        [order setObject:subtitle forKey:CartManagerSubtitleKey];
//        [order setObject:price forKey:CartManagerPriceKey];
//        [order setObject:skuid forKey:CartManagerSkuIDKey];
//        [order setObject:imageURL forKey:CartManagerImageURLKey];
//        [order setObject:smal_imageURL forKey:CartManagerSmallImageURLKey];
//        [order setObject:inventory forKey:CartManagerInventoryKey];
//        [order setObject:kNullToString(_shopCode) forKey:CartManagerShopCodeKey];
//       
//        [order setObject:kNullToString(_productCode) forKey:CartManagerProductCodeKey];
//        
//         YunLog(@"sss %@ %@ %@", [order objectForKey:CartManagerShopCodeKey],_shopCode,[order objectForKey:CartManagerProductCodeKey]);
//        
//        if ([[_product objectForKey:@"is_limit_quantity"] integerValue] == 0) {
//            [order setObject:@"1" forKey:CartManagerCountKey];
//            [order setObject:@"1" forKey:CartManagerMinCountKey];
//            [order setObject:@"0" forKey:CartManagerMaxCountKey];
//        } else {
//            NSString *min = kNullToString([_product objectForKey:@"minimum_quantity"]);
//            
//            if ([min integerValue] == 0) {
//                min = @"1";
//            }
//            
//            [order setObject:min forKey:CartManagerCountKey];
//            [order setObject:min forKey:CartManagerMinCountKey];
//            [order setObject:kNullToString([_product objectForKey:@"limited_quantity"]) forKey:CartManagerMaxCountKey];
//        }
        AppDelegate *appDelegate = kAppDelegate;
        
        if (appDelegate.isLogin) {
            PayCenterForUserViewController *pay = [[PayCenterForUserViewController alloc] init];
//            pay.promotionArray = _product_promotions;
            pay.order = variant;
            pay.shopNowPayDict = _product;
            [pay.shopNowPayDict setObject:_shop[@"code"] forKey:@"shop_code"];
            [pay.shopNowPayDict setObject:_shop[@"short_name"] forKey:@"shop_name"];
            pay.buyCount = _countLabel.text;
            pay.nowToBuy = YES;
            
            UINavigationController *payNC = [[UINavigationController alloc] initWithRootViewController:pay];
            
            [self.navigationController presentViewController:payNC animated:YES completion:nil];
        } else {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isReturnView = YES;
            loginVC.isBuyEnter = YES;
            
            UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            
            [self.navigationController presentViewController:loginNC animated:YES completion:nil];
        }
        
        //        appDelegate.indexTab.selectedIndex = 1;
        
        //        [self doAddToCart];
        
        //        self.tabBarController.selectedIndex = 1;
        //
        //        AppDelegate *appDelegate = kAppDelegate;
        //
        //        appDelegate.lastSelectedTabIndex = 1;
        
    }
    
    //    NSDictionary *variant = [_product objectForKey:@"product_variants"][_selectedVariant - 1000];
    //
    //    NSDictionary *params = @{@"uuid"            :   [Tool getUniqueDeviceIdentifier],
    //                             @"product_name"    :   kNullToString([_product objectForKey:@"name"]),
    //                             @"product_id"      :   kNullToString([variant objectForKey:@"sku_id"])};
    //
    //    [TalkingData trackEvent:@"立即购物" label:@"商品详情" parameters:params];
}

/**
 已添加商品到购物车
 */
- (void)doAddToCartNew
{
    NSDictionary *variant = [[_product_variants objectForKey:@"variants"] objectForKey:_selectedNewVariant];
    YunLog(@"variant select = %@", variant);
    NSString *subtitle  = kNullToString([variant objectForKey:@"value1"]);
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"正在添加...";
    
    // TODO  在详情页面添加商品到购物车  默认选中的数量是1
    NSDictionary *params = @{@"user_session_key"    :   kNullToString(appDelegate.user.userSessionKey),
                             @"pv_id"               :   kNullToString([variant objectForKey:@"sku_id"]),
                             @"number"              :   kNullToString(_countLabel.text),
                             @"shop_code"           :   _shop[@"code"]};
    
    NSString *addCartURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAddCartProductURL params:nil];
    
    YunLog(@"addCartURL = %@", addCartURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:addCartURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"add responseObject = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
//            dispatch_once_t cartOnce;
//            dispatch_once(&cartOnce, ^{
//                _cartCount += 1;
//                [_bottomCart addBadge:[NSString stringWithFormat:@"%ld", _cartCount]];
//            });
            
            _hud.detailsLabelText = @"已添加到购物车";
            [_hud addSuccessString:[NSString stringWithFormat:@"%@", subtitle] delay:1.0];

            [self cancel];

            [_bottomCart removeBadge];
            _cartCount += [_countLabel.text integerValue];

            NSString *cartNowCount = [NSString stringWithFormat:@"%ld", (long)_cartCount];
            [_bottomCart addBadge:cartNowCount];
            
            [[NSUserDefaults standardUserDefaults] setObject:cartNowCount forKey:@"cartCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            YunLog(@"CartManager");
        } else {
            [_hud addErrorString:[[responseObject objectForKey:@"status"] objectForKey:@"message"] delay:1.5];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"add to cart exception = %@", error);
        [_hud addErrorString:@"添加到购物车失败" delay:1.5];
    }];
}

- (void)doAddToCart
{
    NSString *name = kNullToString([_product objectForKey:@"title"]);
    YunLog(@"_product = %@", _product);
    
    NSDictionary *variant = [_sku_variants objectForKey:_selectedNewVariant];
    YunLog(@"variant select = %@", variant);
    NSString *variantName = [self getVariantName:variant];
    
    NSString *subtitle  = kNullToString(variantName);
    NSString *price     = kNullToString([variant objectForKey:@"price"]);
    NSString *skuid     = kNullToString([variant objectForKey:@"sku_id"]);
    NSString *inventory = kNullToString([variant objectForKey:@"inventory"]);
    NSString *imageURL  = kNullToString([_product objectForKey:@"image_url_200"]);
    NSString *smal_image_url = kNullToString([_product objectForKey:@"image_url"]);
    NSArray *promotinsArray = [NSArray array];
    promotinsArray = _product_promotions;
    
    @try {
        NSMutableDictionary *product = [[NSMutableDictionary alloc] init];
        
        [product setObject:name forKey:CartManagerDescriptionKey];
        [product setObject:subtitle forKey:CartManagerSubtitleKey];
        [product setObject:price forKey:CartManagerPriceKey];
        [product setObject:skuid forKey:CartManagerSkuIDKey];
        [product setObject:imageURL forKey:CartManagerImageURLKey];
        [product setObject:smal_image_url forKey:CartManagerSmallImageURLKey];
        [product setObject:inventory forKey:CartManagerInventoryKey];
        [product setObject:kNullToString(_productCode) forKey:CartManagerProductCodeKey];
        [product setObject:kNullToString(_shopCode) forKey:CartManagerShopCodeKey];
        [product setObject:promotinsArray forKey:CartManagerPromotionsKey];
        
        if ([[_product objectForKey:@"is_limit_quantity"] integerValue] == 0) {
            [product setObject:@"1" forKey:CartManagerCountKey];
            [product setObject:@"1" forKey:CartManagerMinCountKey];
            [product setObject:@"0" forKey:CartManagerMaxCountKey];
        } else {
            NSString *min = kNullToString([_product objectForKey:@"minimum_quantity"]);
            
            if ([min integerValue] == 0) {
                min = @"1";
            }
            
            [product setObject:min forKey:CartManagerCountKey];
            [product setObject:min forKey:CartManagerMinCountKey];
            [product setObject:kNullToString([_product objectForKey:@"limited_quantity"]) forKey:CartManagerMaxCountKey];
        }
        
        [[CartManager defaultCart] addProduct:product
                                      success:^{
                                          UIViewController *cartVC     = [self.tabBarController.viewControllers objectAtIndex:1];
                                          cartVC.tabBarItem.badgeValue = [[CartManager defaultCart] productCount];
                                          
                                          [_bottomCart addBadge:[[CartManager defaultCart] productCount]];
                                          
                                          _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                          _hud.detailsLabelText = @"已添加到购物车";
                                          [_hud addSuccessString:[NSString stringWithFormat:@"%@", subtitle] delay:1.0];
                                          
                                          YunLog(@"CartManager");
                                      }
                                      failure:^(int count) {
                                          _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                          [_hud addErrorString:[NSString stringWithFormat:@"本商品限购%d件", count] delay:1.5];
                                      }];
    }
    @catch (NSException *exception) {
        YunLog(@"add to cart exception = %@", exception);
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"添加到购物车失效" delay:1.5];
    }
    @finally {
        
    }
}

- (void)backToPrev
{
    if (_hud) [_hud hide:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MWPhotoBrowserDelegate -

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _photos.count)
        return [MWPhoto photoWithURL:[NSURL URLWithString:kNullToString([[_photos[index] objectForKey:@"image"] objectForKey:@"url"])]];
    
    return nil;
}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser bottomButtonPressAtIndex:(NSUInteger)index
//{
//    switch (index) {
//        case 0:
//        {
//            self.tabBarController.selectedIndex = 1;
//
//            AppDelegate *appDelegate = kAppDelegate;
//
//            appDelegate.lastSelectedTabIndex = 1;
//
//            break;
//        }
//
//        case 1:
//        {
//            [self addToCart];
//
//            break;
//        }
//
//        case 2:
//        {
//            break;
//        }
//
//        default:
//            break;
//    }
//}

- (NSDictionary *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleAndDescriptionAtIndex:(NSUInteger)index
{
    NSDictionary *dict = _photos[index];
    
    NSDictionary *content = @{@"title"  :   kNullToString([dict safeObjectForKey:@"title"]),
                              @"text"   :   kNullToString([dict safeObjectForKey:@"description_text"])};
    
    return content;
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    _pageControl.currentPage = page;
}

#pragma mark - UIActionSheetDelegate -

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (id so in actionSheet.subviews) {
        if ([so isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)so;
            button.titleLabel.font = [UIFont fontWithName:kFontBold size:kFontNormalSize];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 微博分享内容
    NSString *title = [[_product safeObjectForKey:@"title"] toString];
    NSString *desc  = [[_product safeObjectForKey:@"title"] toString];
    NSString *url   = [[_product safeObjectForKey:@"share_url"] toString];
    
    NSUInteger titleLength = title.length;
    NSUInteger descLength  = desc.length;
    NSUInteger urlLength   = url.length;
    
    if (titleLength + descLength + urlLength > 136) {
        desc = [desc substringWithRange:NSMakeRange(0, 136 - titleLength - urlLength)];
    }
    
    NSString *description = [NSString stringWithFormat:@"#%@# %@ %@", title, desc, url];
    
    switch (buttonIndex) {
        case 0:
            [self isWeiXinInstalled:WXSceneSession];
            
            break;
            
        case 1:
            [self isWeiXinInstalled:WXSceneTimeline];
            break;
            
        case 2:
        {
            NSString *thumb;
            
            if (![[[_product objectForKey:@"share_logo"] toString] isEqualToString:@""]) {
                thumb = [_product objectForKey:@"share_logo"];
            } else if (![[[[[_product objectForKey:@"images"] firstObject] objectForKey:@"thumb_image" ] toString] isEqualToString:@""]) {
                thumb = [[[_product objectForKey:@"images"] firstObject] objectForKey:@"thumb_image" ];
            } else {
                thumb = @"";
            }
            
            [Tool shareToWeiBo:thumb description:description];
        }
           
            break;
            
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate -

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    for (id so in alertView.subviews) {
        if ([so isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)so;
            label.font = [UIFont fontWithName:kFontBold size:kFontNormalSize];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 20) {
        if (buttonIndex == 1) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", alertView.message]];
            YunLog(@"url = %@", url);
            [[UIApplication sharedApplication] openURL:url];
        }
        return;
    }
    
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
    }
}

#pragma mark - YunSharedelegate -

- (void)shareViewDidSelectView:(YunShareView *)shareView inSection:(NSUInteger)section index:(NSUInteger)index
{
    // 微博分享内容
    NSString *title = [[_product safeObjectForKey:@"title"] toString];
    NSString *desc  = [[_product safeObjectForKey:@"short_desc"] toString];
    NSString *url   = [[_product safeObjectForKey:@"share_url"] toString];
    
    NSUInteger titleLength = title.length;
    NSUInteger descLength  = desc.length;
    NSUInteger urlLength   = url.length;
    
    if (titleLength + descLength + urlLength > 136) {
        desc = [desc substringWithRange:NSMakeRange(0, 136 - titleLength - urlLength)];
    }
    
    NSString *description = [NSString stringWithFormat:@"#%@# %@ %@", title, desc, url];
    
    switch (index) {
        case 0:
            [self isWeiXinInstalled:WXSceneSession];
            
            break;
            
        case 1:
            [self isWeiXinInstalled:WXSceneTimeline];
            
            break;
            
        case 2:
        {
            NSString *thumb;
            
//            if (![[[_product objectForKey:@"share_logo"] toString] isEqualToString:@""]) {
//                thumb = [_product objectForKey:@"share_logo"];
//            } else
            if (![[[[[_product objectForKey:@"images"] firstObject] objectForKey:@"thumb_image" ] toString] isEqualToString:@""]) {
                thumb = [[[_product objectForKey:@"images"] firstObject] objectForKey:@"thumb_image" ];
            } else {
                thumb = @"";
            }

            [Tool shareToWeiBo:thumb description:description];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -contactServiceClick-

- (void)contactServiceClick
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"联系客服" message:_shop[@"phone"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"联系TA", nil];
    alertView.tag = 20;
    
    [alertView show];
}

@end
