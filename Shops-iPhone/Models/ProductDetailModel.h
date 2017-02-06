//
//  ProductDetailModel.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDetailModel : NSObject

@property (nonatomic, strong) NSArray *children_product_categories;
@property (nonatomic, copy) NSString *order_by;
@property (nonatomic, copy) NSString *order_type;

@end
