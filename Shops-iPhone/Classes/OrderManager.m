//
//  OrderManager.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-13.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "OrderManager.h"

static OrderManager *manager = nil;
static NSMutableDictionary *order = nil;

@implementation OrderManager

#pragma mark - Singleton -

+ (OrderManager *)defaultManager
{
    @synchronized(self)
    {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
        
        if (order == nil) {
            order = [[NSMutableDictionary alloc] init];
        }
    }
    
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (manager == nil) {
            manager = [super allocWithZone:zone];
            
            return manager;
        }
    }
    
    return nil;
}

#pragma mark - Public Functions -

- (void)addInfo:(id)info forKey:(NSString *)key
{
    [order setObject:info forKey:key];
}

- (void)removeInfoForKey:(NSString *)key
{
    [order removeObjectForKey:key];
}

- (id)infoForKey:(NSString *)key
{
    return [order objectForKey:key];
}

- (void)displayAllInfo
{
    YunLog(@"current order = %@", order);
}

- (void)clearInfo
{
    [order removeAllObjects];
}

@end
