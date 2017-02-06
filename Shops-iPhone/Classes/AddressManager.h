//
//  AddressManager.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-04.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressManager : NSObject

// 单例实例
+ (AddressManager *)defaultManager;

- (NSArray *)provinces;
- (NSArray *)citiesWithProvinceID:(NSString *)provinceID;
- (NSArray *)areasWithCityID:(NSString *)cityID;

@end
