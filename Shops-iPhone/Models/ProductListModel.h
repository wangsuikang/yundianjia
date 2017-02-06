//
//  ProductListModel.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductListModel : NSObject

@property (nonatomic, strong) NSArray *children_product_categories;
@property (nonatomic, copy) NSString *order_by;
@property (nonatomic, copy) NSString *order_type;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, copy) NSString *page_count;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, copy) NSString *per;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *total_count;

@end

@interface ProductListDetailModel : NSObject

@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *inventory_quantity;
@property (nonatomic, copy) NSString *is_discount;
@property (nonatomic, copy) NSString *is_kjg;
@property (nonatomic, copy) NSString *is_limit_quantity;
@property (nonatomic, copy) NSString *large_icon;
@property (nonatomic, copy) NSString *large_icon_200_200;
@property (nonatomic, copy) NSString *large_icon_218_218;
@property (nonatomic, copy) NSString *large_icon_270_270;
@property (nonatomic, copy) NSString *large_icon_288_288;
@property (nonatomic, copy) NSString *large_icon_400_400;
@property (nonatomic, copy) NSString *limited_quantity;
@property (nonatomic, copy) NSString *market_price;
@property (nonatomic, copy) NSString *minimum_quantity;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, strong) NSDictionary *product_variant;
@property (nonatomic, copy) NSString *sales_quantity;
@property (nonatomic, copy) NSString *shop_code;
@property (nonatomic, copy) NSString *shop_id;
@property (nonatomic, copy) NSString *shop_name;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *tax;

@end