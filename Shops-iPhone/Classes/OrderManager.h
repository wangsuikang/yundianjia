//
//  OrderManager.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-13.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderManager : NSObject

// 单例实例
+ (OrderManager *)defaultManager;

- (void)addInfo:(id)info forKey:(NSString *)key;
- (void)removeInfoForKey:(NSString *)key;
- (id)infoForKey:(NSString *)key;
- (void)displayAllInfo;
- (void)clearInfo;

@end
