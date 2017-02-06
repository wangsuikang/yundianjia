//
//  KVO.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-28.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KVO : NSObject

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *area;

@property (nonatomic, copy) NSString *address_province_id;
@property (nonatomic, copy) NSString *address_city_id;
@property (nonatomic, copy) NSString *address_area_id;

@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *invoice;
@property (nonatomic, copy) NSString *contactPhone;

@end
