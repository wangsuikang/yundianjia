//
//  User.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

// 用户基本信息
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *display_name;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic ,copy) NSString *gender;

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *area;

@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, strong) UIImage *avatar;

@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *thumb_small;

@property (nonatomic, assign) NSInteger userType;

// 用户身份认证
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *uid_secret;
@property (nonatomic, copy) NSString *userSessionKey;
@property (nonatomic, copy) NSString *userSessionKey2;

// 用户本地信息存储
@property (nonatomic, strong) NSArray *addresses;
@property (nonatomic, strong) NSArray *invoices;
@property (nonatomic, strong) NSArray *completedOrders;
@property (nonatomic, strong) NSArray *receivingOrders;
@property (nonatomic, strong) NSArray *payingOrders;
@property (nonatomic, strong) NSArray *payedOrders;
@property (nonatomic, strong) NSArray *cancelOrders;
@property (nonatomic, strong) NSArray *allOrders;
@property (nonatomic, strong) NSArray *coupons;
@property (nonatomic, strong) NSArray *shops;

- (void)addAddress:(NSDictionary *)dic;
- (void)removeAddressAtIndex:(NSInteger)index;
- (NSArray *)setDefaultAddress:(NSInteger)index;

@end
