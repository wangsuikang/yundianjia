//  ShopStreetModel.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/24.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopStreetModel : NSObject

@property (nonatomic, copy) NSString *action_type;
@property (nonatomic, copy) NSString *action_value;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, copy) NSString *title;

@end

@interface ShopStreetProductsModel : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *image_url_200;
@property (nonatomic, copy) NSString *image_url_218;
@property (nonatomic, copy) NSString *image_url_270;
@property (nonatomic, copy) NSString *image_url_288;
@property (nonatomic, copy) NSString *inventory_quantity;
@property (nonatomic, copy) NSString *market_price;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *qq_online_customer;
@property (nonatomic, copy) NSString *sales_quantity;
@property (nonatomic, copy) NSString *shop_code;
@property (nonatomic, copy) NSString *smal_image_url;
@property (nonatomic, copy) NSString *title;

@end