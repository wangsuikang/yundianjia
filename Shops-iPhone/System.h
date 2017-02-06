//
//  System.h
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#ifndef Shops_iPhone_System_h
#define Shops_iPhone_System_h

#pragma mark - Debug -

#ifdef DEBUG

#define YunLog(fmt, ...)                    NSLog((@"\n%s [Line %u]:\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define YunLog(fmt, ...)                    /* */

#endif

#pragma mark - Device -

#define kAppVersion                         [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]
#define kAppBuild                           [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]

#define kDeviceOSVersion                    [[[UIDevice currentDevice] systemVersion] floatValue]

#define kIsiPhone                           [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

#pragma mark - NSUserDefaults -

#define kRemoteNotification                 @"kRemoteNotification"

#pragma mark - Talking Data -

//#define kTalkingDataAppKey                  @"BA94A2886B3A0A077CF3E2E56E181B51" 
//#define kTalkingDataChannelAppStore         @"AppleAppStore"
//#define kTalkingDataChannelAtyun            @"Atyun"
//#define kTalkingDataChannelAtyunSIT         @"AtyunSIT"

#pragma mark - WeiXin -

// old wx id and key
//#define kWeiXinAppID                        @"wx316d5f293227fd4f"
//#define kWeiXinAppKey                       @"0ed2aad01e68db6eba2dace96447223c"

// new wx id and key
#define kWeiXinAppID                        @"wx6be7c972620514b2"
#define kWeiXinAppKey                       @"4762b79d990f1b672693c3d77b0596a6"

#pragma mark - WeiBo -

#define kWeiBoAppKey                        @"1259222985"
#define kWeiBoAppSecret                     @"f32ffe9cf10876284b5023ffaed3164f"
#define kWeiBoRedirectURL                   @"http://www.yundianjia.com/mobile/users/callbacks/weibo"

#pragma mark - Umeng - 
#define kUMengForIOSAppkey                  @"56248cef67e58ed3b400493e"

#pragma mark - Umpay -

#define kUmpaykSuccessCode                  @"0000"
#define kUmpayFailureCode                   @"1001"

#pragma mark - Error Code -

#define kSuccessCode                        @"20000"
#define kSignatureInvalidCode               @"40300"
#define kTerminalSessionKeyInvalidCode      @"40301"
#define kUserSessionKeyInvalidCode          @"40302"
#define kOtherErrorCode                     @"50000"

#pragma mark - System Configs -

#define kNotificationDismissModalController                  @"yun-close-view-controller"
#define kNotificationDismissModalControllerWithPaySucceed    @"yun-close-view-controller-succeed"
#define kNotificationDismissModalControllerWithClose         @"yun-close-view-controller-close"

#define kNotificationAddNewDistributorSuccess                @"AddNewDistributorSuccess"
#define kNotificationAddNewDistributorGroupSuccess           @"AddNewDistributorGroupSuccess"
#define kNotificationAddNewGroupSuccess                      @"AddNewGroupSuccess"

#define kCustomNaviHeight                   (kDeviceOSVersion >= 7.0 ? 64 : 0)
#define kNavTabBarHeight                    64

#define kNullToString(str)                  ([str isEqual:[NSNull null]] || str == nil) ? @"" : str
#define kNullToArray(arr)                   ([arr isEqual:[NSNull null]] || arr == nil) ? @[] : arr
#define kNullToDictionary(dic)              ([dic isEqual:[NSNull null]] || dic == nil) ? @{} : dic

#define kScreenBounds                       ([[UIScreen mainScreen] bounds])
#define kScreenWidth                        ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight                       ([[UIScreen mainScreen] bounds].size.height)
#define kScreenSize                         CGSizeMake(kScreenWidth, kScreenHeight)
#define kLineHeight                         (1 / [UIScreen mainScreen].scale)

#define proprotion kScreenWidth/375

#define kLetterFamily                       @"HelveticaNeue"
#define kFontFamily                         @"HelveticaNeue"
#define kFontBold                           @"HelveticaNeue-Bold"

#define kFontLangeBigSize                   30
#define kFontLargeSize                      24
#define kFontBigSize                        20
#define kFontSize                           18
#define kFontNormalSize                     16
#define kFontMidSize                        14
#define kFontSmallSize                      12
#define kFontSmallMoreSize                  10

#define kLangeFont                          [UIFont fontWithName:kFontFamily size:kFontLangeBigSize]
#define kLargeFont                          [UIFont fontWithName:kFontFamily size:kFontLargeSize]
#define kBigFont                            [UIFont fontWithName:kFontFamily size:kFontBigSize]
#define kFont                               [UIFont fontWithName:kFontFamily size:kFontSize]
#define kNormalFont                         [UIFont fontWithName:kFontFamily size:kFontNormalSize]
#define kMidFont                            [UIFont fontWithName:kFontFamily size:kFontMidSize]
#define kSmallFont                          [UIFont fontWithName:kFontFamily size:kFontSmallSize]
#define kSizeFont                           [UIFont fontWithName:kFontFamily size:kFontSize]
#define kMidSizeFont                        [UIFont fontWithName:kFontFamily size:kFontMidSize]
#define kSmallMoreSizeFont                  [UIFont fontWithName:kFontFamily size:kFontSmallMoreSize]

#define kLargeBoldFont                      [UIFont fontWithName:kFontBold size:kFontLargeSize]
#define kBigBoldFont                        [UIFont fontWithName:kFontBold size:kFontBigSize]
#define kNormalBoldFont                     [UIFont fontWithName:kFontBold size:kFontNormalSize]
#define kMidBoldFont                        [UIFont fontWithName:kFontBold size:kFontMidSize]
#define kSmallBoldFont                      [UIFont fontWithName:kFontBold size:kFontSmallSize]
#define kSizeBoldFont                       [UIFont fontWithName:kFontBold size:kFontSize]

#define COLOR(r, g, b, a)                   [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:(a * 1.0)]

// ColorFromRGB(0x067AB5)
#define ColorFromRGB(rgbValue)              [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ColorWithAlphaFromRGB(rgbValue,a)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define kBlueColor                          COLOR(0, 183, 238, 1)
#define kGrayColor                          COLOR(235, 235, 235, 1)
#define kBackgroundColor                    COLOR(250, 250, 250, 1)
#define kRedColor                           [UIColor redColor]
#define kWhiteColor                         COLOR(250, 250, 250, 1)
#define kLightWhiteColor                    COLOR(250, 250, 250, 0.5)
#define kBlackColor                         COLOR(0, 0, 0, 1)
#define kOrangeColor                        COLOR(255, 127, 0, 1)
#define kGreenColor                         [UIColor greenColor]
#define kLineColor                          ColorFromRGB(0xb2b2b2)
#define kClearColor                         [UIColor clearColor]
#define kNaviTitleColor                     [UIColor orangeColor]
#define kLightBlackColor                    COLOR(0, 0, 0, 0.7)
#define kGrayFontColor                      ColorWithAlphaFromRGB(0x1d1d26, 0.85)
#pragma mark - App Store -

#define kAppID                              @"783464466"
#define kBundleID                           @"com.yundianjia.Shops-iPhone"

#pragma mark - API URL -Oshoplis

// base url
//#define kRequestHost                       @"http://api.shop.yundianjia.com"
#define kRequestHost                       @"http://api.shop.sit.yundianjia.net"
//#define kRequestHost                       @"http://api.shop.cjx.sitdev.tunnel.mobi"
//#define kRequestHost                       @"http://api.shop.fengbin.sitdev.tunnel.mobi"

//#define kRequestHostSit                     @"http://api.sit.yundianjia.net"
//#define kRequestHost                        @"http://api.mit.yundianjia.com"

//#define kRequestHost                        @"http://api.sit.yundianjia.net"

//#define kRequestHostShop                    @"http://api.shop.sit.yundianjia.net"
//#define kRequestHost                        @"http://api.shop.sit.yundianjia.net"
//#define kRequestHost                        @"http://api.sit.facloud.com"

//#define kRequestHost                        @"http://dev.yundianjia.com"
//#define kRequestHost                        @"http://api.fengbin.dev.yundianjia.com"
//#define kRequestHost                        @"http://192.168.1.88:3000"
//#define kRequestHost                        @"http://192.168.1.27:5000"
//#define kRequestHost                        @"http://192.168.2.1:3000"

#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES

#import <systemconfiguration/SystemConfiguration.h>
#import <mobilecoreservices/MobileCoreServices.h>

#define kPublic                             @"/public"

#define kRequestHostWithPublic              [NSString stringWithFormat:@"%@%@", kRequestHost, kPublic]

#define kAPIVersion1                        @"/api/v1"
#define kAPIVersion1WithShops               @"/api/shops/v1"
#define kAPIVersion2                        @"/api/v2"
#define kAPIVersion2WithShops               @"/api/shops/v2"
#define kAPIVersion3                        @"/api/v3"

#define kIntfRevision                       @"2.2"

//banner
//#define kBannerURL                          @"/activities/17022777/banner.json"
#define kBannerURL                          @"/activities/14576483/banner.json"
#define kHomeBannerURL                      @"/home/top_banner.json"

// app
#define kAppFlashURL                        @"/apps/flash.json"
#define kAppMessageURL                      @"/apps/message.json"

// terminal
#define kTerminalSignUpURL                  @"/terminal_apps/sign_up.json"

// shop
#define kShopStreetURL                      @"/shops.json"
#define kShopListURL                        @"/shops/home_top.json"
#define kShopInfoURL                        @"/shops/info.json"
#define kShopActivityURL                    @"/shops/activity.json"

#define kRecommendProductsURL               @"/activities/%@/products.json"
#define kActivityRecommendShopsURL          @"/activities/recommend_shops.json"

#define kShopAdminShopsURL                  @"/shops.json"
#define kShopMyShopsURL                     @"/shops/my_shops.json"
#define kShopClientURL                      @"/shops/client.json"
#define kShopStreetNewURL                   @"/shops/home_shop_recommends.json"
#define kShopStreetHomeURL                  @"/home/recommend_shops.json"

// promotions
#define kPromotionsCalculateURL             @"/promotions/calculate_promotion.json"
#define kCalculateURL                       @"/order_parents/calculate.json"

// product
#define kProductListURL                     @"/shops/:code/products.json"
#define kProductDescURL                     @"/products/desc.json"
#define kProductDetailURL                   @"/products/detail.json"
#define kProductVariantDetailForManagerURL  @"/products/variant_detail_for_manager.json"
#define kProductDetailForManagerURL         @"/products/detail_for_manager.json"
#define kProductModifyURL                   @"/products/modify_product.json"
#define kProductCatefories                  @"/product_categories.json"
#define kProductComment                     @"/product_comments.json"
//#define kProductRevelationListURL           @"/product_categories/%d.json"
#define kProductRevelationListURL           @"/product_categories/query_products.json?"

// 关于店家
#define kAboutShopInfoURL                  @"/mobile/shops/about"

// 通用接口调试使用
// ------------------------------------------------------------------------------------------
// 商品详情页面顶部基本信息数据接口
#define kProductBasicURL                   @"/products/%@/basic.json"

// 商品详情界面图文介绍
#define kProductDescImageURL               @"/products/%@/desc.json"

// 商品详情界面购买历史数据接口
#define kProductBuy_History                @"/products/%@/buy_history.json"

// 商品详情介绍详情
#define kProductAttributes                 @"/products/%@/attributes.json"

// 商品详情界面购买须知数据接口
#define kProductGuide                      @"/products/%@/guide.json"

// 商品优惠信息(促销信息)
#define kProductPromotions                 @"/products/%@/promotions.json"

// 商品详情界面商品规格信息数据接口
#define kProductVariants                   @"/product_variants.json"

// 商品详情界面商品运费信息数据接口
#define kProductFreight                    @"/products/%@/freight_templates.json"

// 判断商品是否可以访问接口
#define kProductAccess                     @"/products/%@/access.json"

// 获取商品销量top5
#define kProductTop_Sales                  @"/products/top_sales.json"

// 获取商品新品上架top5
#define kProductTop_New                    @"/products/top_new.json"

// 商品评论
#define kProductCommentsURL                @"/product_comments.json"
// ------------------------------------------------------------------------------------------

// 我的商品列表
// 查询商品组
#define kProduct_groups                    @"/product_groups/get_groups.json"

// 查询没有分配给分销商的商品组
#define kProduct_group_no_in_distribution  @"/shops/get_product_group_no_in_distribution.json"

// 分配商品组给分销商
#define KAdd_distributor_product_group     @"/shops/add_distributor_product_group.json"

// 添加商品组（post上传请求）
#define add_ProductGroups                  @"/groups.json"

// 新增商品组里的商品
#define KAdd_GroupsProduct                 @"/product_in_groups.json"

// 新增分销商
#define KAdd_Distributor                   @"/shops/add_distributor.json"

// 我的商品
#define admin_Products                     @"/shops/%@/get_products.json"

// 销售统计
#define KSale_statistics                   @"/sale_statistics.json"

// 卖家版
#define kAdminDistributors                 @"/distributors.json"

// 卖家新增商品组
#define kAdminAddNewGroup                  @"/product_groups.json"

// 保存 默认有效的 促销活动
#define kAdminSaveActivities               @"/promotion_activities/save_default.json"

// 返回 默认有效的 促销活动
#define kAdminGetActivities                @"/promotion_activities/get_default.json"

// 店铺首页统计信息
#define kShop_home_statistic               @"/sale_statistics/shop_home_statistic.json"

// 结算查询(统计)
#define kGet_settlement_statistics         @"/sale_statistics/get_settlement_statistics.json"

//// 我的(店铺)收入
//#define kShop_not_settlement_fund       @"/sale_statistics/shop_not_settlement_fund.json"
// 我的(店铺)收入
#define kShop_not_settlement_fund          @"/sale_statistics/order_count_sale_income.json"

// 报表统计
#define kOrderCountDistribution            @"/sale_statistics/order_count_distribution.json"

// 商家结算未结算总计
#define kSettlementCompletedAndUnCompleted @"/sale_statistics/settlement_for_completed_and_uncompleted.json"

// 商家结算明细
#define kSettleCompletedStatistic          @"/sale_statistics/settlement_statistic.json"

// 订单分布统计数据
#define kOrderCountDistribution            @"/sale_statistics/order_count_distribution.json"

// 移除商品组
#define kDismiss_distributor_group         @"/shops/dismiss_distributor_product_group.json"

// 购物车
#define kCartListURL                       @"/cart.json"

// 购物车基本信息
#define kCartBaseURL                       @"/cart/basic.json"

// 清空购物车
#define kCartClearURL                      @"/cart/clear.json"

// 购物车新增或是修改商品数量
#define kCartChangeNumURL                  @"/cart/modify.json"

// 添加商品到购物车
#define kAddCartProductURL                 @"/cart/add.json"

// 查看商家入驻的信息
#define kApplyShopsURL                     @"/apply_shops.json"

// 获取商铺详情
#define kShopInfoNewURL                    @"/shops/%@.json"

// 在商品详情里面检测该商品是否已经收藏
#define kHas_ExistedURL                    @"/favorites/%@/has_existed.json"

// 在商品详情里面添加收藏
#define kAddFavoriteURL                    @"/favorites.json"

// 在商品详情删除收藏
#define kDeleteFavoriteURL                 @"/favorites.json"

// 移动版图文商品描述
#define kProductImageWapURL                @"/products/%@/wap_desc.json"

// 我的收藏列表信息
#define kAdminFavoritesURL                 @"/favorites.json"

// 获取商家信息
#define kGetSalerInfoURL                   @"/shops/%@/owner_shop.json"

// 获取所有的活动列表
#define kAllActivitiesURL                  @"/activities.json"

// 获取商品规格分类类型
#define kGetProductCategoryURL             @"/product_specs.json"

// 获取运费模板
#define kGetFerightURL                     @"/products/get_freight_template.json"

// 上传商品发布基本信息
#define kPostProductURL                    @"/products.json"

// 上传商品的图片
#define kPostProductImageURL               @"/products/upload_image.json"

// 首页推荐里面的活动 根据活动的code获取列表
#define kHomeRecommendListURL              @"/activities/%@/products.json"
#define kHomeRecommendProductsListURL      @"/home/recommend_products_with_tags.json"

// favorite
#define kFavoriteAddURL                     @"/favorites/add.json"
#define kFavoriteDeleteURL                  @"/favorites/delete.json"
#define kFavoriteQueryURL                   @"/favorites/query.json"
#define kFavoriteIsFavoriteURL              @"/favorites/is_favorite.json"
#define kFavoriteURLCheckURL                @"/favorites/url_check.json"

// order
#define kOrderCommitURL                     @"/orders/commit.json"
#define kOrderCommitURLNew                  @"/order_parents.json"
#define kOrderQueryURL                      @"/orders/query.json"
#define kOrderDetailURL                     @"/orders/detail.json"
#define kParentsOrderDetailURL              @"/order_parents/%@.json"
#define kSubOrderDetailURL                  @"/orders/%@.json"
#define kOrderAdminSearchURL                @"/orders/admin_search.json"
#define kOrderAdminListURL                  @"/orders/admin_list.json"
#define kOrderAdminDetailURL                @"/orders/admin_detail.json"
#define kOrderSetExpressURL                 @"/orders/set_express.json"
#define kOrderSetStatusURL                  @"/orders/set_status.json"
#define kOrderExpressCompanyURL             @"/orders/express_companies.json"

// address
#define kAddressQueryURL                    @"/addresses/query.json"
#define kAddressDeleteURL                   @"/addresses/delete.json"
#define kAddressAddURL                      @"/addresses/add.json"
#define kAddressModifyURL                   @"/addresses/modify.json"
#define kAddressSetDefaultURL               @"/addresses/set_default.json"

// invoice
#define kInvoiceQueryURL                    @"/invoices/query.json"

// coupon
#define kCouponQueryURL                     @"/coupons/query.json"

// pay
#define kPayPageURL                         @"/pays/page_pay.json"

// search
#define kSearchURL                          @"/search.json"

// /user_coupons
#define KCouponsURL                         @"/user_coupons.json"

// histories
#define kHistoryURL                         @"/browse_histories.json"

// create phone code
#define kCreatePhoneCodeURL                 @"/users/create_phone_code.json"

// user
#define kSignInURL                          @"/users/sign_in.json"
#define kSignUpURL                          @"/users/sign_up.json"
#define kUpdatePasswordURL                  @"/users/update_password.json"
// 用户第三方直接登陆
#define kThirdPartyLoginURL                 @"/users/bind_user_by_provider.json"

// yundianjia
#define kYundianjiaURL                      @"http://www.yundianjia.com"
//#define kYundianjiaURL                      @"http://www.sit.yundianjia.net"
//#define kYundianjiaURL                      @"http://www.sit.yundianjia.com"

// feedback 意见反馈
#define kFeedbackURL                        [NSString stringWithFormat:@"%@/mobile/feedbacks/new?platform=iphone", kRequestHost]

// clause 服务条款
#define kClauseURL                          [NSString stringWithFormat:@"%@/mobile/users/agreement?platform=iphone", kYundianjiaURL]

// about
#define kAboutShopListURL                   [NSString stringWithFormat:@"%@/mobile/shops/about?platform=iphone", kYundianjiaURL]
#define kAboutShopURL                       [NSString stringWithFormat:@"%@/mobile/about?platform=iphone", kRequestHost]

#define kApplication                        [UIApplication sharedApplication]
#define kAppDelegate                        (AppDelegate *)[UIApplication sharedApplication].delegate
#define kUserDefaults                       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter                 [NSNotificationCenter defaultCenter]

// NSNotificationCenter
#define kOrderDetailNotificationReload      @"kOrderDetailNotificationReload"
#define kOrderPaySucceedNotification        @"OrderPaySucceed"
#define kCartNotificationReload             @"kCartNotificationReload"
#define kAddressUpdate                      @"kAddressUpdate"


#endif