//
//  CartManager.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "CartManager.h"

static CartManager *manager = nil;
static NSMutableArray *products = nil;

NSString * const CartManagerDescriptionKey      = @"CartManagerDescriptionKey";
NSString * const CartManagerSubtitleKey         = @"CartManagerSubtitleKey";
NSString * const CartManagerPriceKey            = @"CartManagerPriceKey";
NSString * const CartManagerSkuIDKey            = @"CartManagerSkuIDKey";
NSString * const CartManagerImageURLKey         = @"CartManagerImageURLKey";
NSString * const CartManagerSmallImageURLKey    = @"CartManagerSmallImageURLKey";
NSString * const CartManagerShopCodeKey         = @"CartManagerShopCodeKey";
NSString * const CartManagerProductCodeKey      = @"CartManagerProductCodeKey";
NSString * const CartManagerCountKey            = @"CartManagerCountKey";
NSString * const CartManagerMinCountKey         = @"CartManagerMinCountKey";
NSString * const CartManagerMaxCountKey         = @"CartManagerMaxCountKey";
NSString * const CartManagerSelectedKey         = @"CartManagerSelectedKey";
NSString * const CartManagerInventoryKey        = @"CartManagerInventoryKey";
NSString * const CartManagerPromotionsKey       = @"CartManagerPromotionsKey";

@interface CartManager()

@end

@implementation CartManager

#pragma mark - Singleton -

+ (CartManager *)defaultCart
{
    @synchronized(self)
    {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
        
        if (products == nil) {
            products = [[NSMutableArray alloc] init];
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

- (NSArray *)allProducts
{
    return [NSArray arrayWithArray:products];
}

- (NSArray *)allSelectedProducts
{
    NSMutableArray *selectedProducts = [[NSMutableArray alloc] init];
    
    for (NSDictionary *product in products) {
        if ([[product objectForKey:CartManagerSelectedKey] isEqualToString:@"yes"]) {
            [selectedProducts addObject:product];
        }
    }
    
    return [NSArray arrayWithArray:selectedProducts];
}

- (void)addProduct:(NSDictionary *)productDic success:(void(^)(void))success failure:(void(^)(int count))failure
{
    for (int i = 0; i < products.count; i++) {
        NSDictionary *dic = [products objectAtIndex:i];
        
        NSString *newSkuID = [NSString stringWithFormat:@"%@", [productDic objectForKey:CartManagerSkuIDKey]];
        NSString *oldSkuID = [NSString stringWithFormat:@"%@", [dic objectForKey:CartManagerSkuIDKey]];
        
        if ([newSkuID isEqualToString:oldSkuID]) {
            int count = [[dic objectForKey:CartManagerCountKey] intValue];
            
            if (count == [[productDic objectForKey:CartManagerMaxCountKey] integerValue]) {
                failure(count);
            } else {
                count += 1;
                
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:dic];
                [temp setObject:[NSString stringWithFormat:@"%d", count] forKey:CartManagerCountKey];
                [temp setObject:@"yes" forKey:CartManagerSelectedKey];
                
                [products removeObjectAtIndex:i];
                [products insertObject:temp atIndex:i];
                
                success();
            }
            
            return;
        }
    }
    
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:productDic];
    [temp setObject:@"yes" forKey:CartManagerSelectedKey];
    
    [products addObject:temp];
    
    success();
}

- (void)updateProduct:(NSDictionary *)product atIndex:(NSInteger)index
{
    [products removeObjectAtIndex:index];
    
    [products insertObject:product atIndex:index];
}

- (id)productAtIndex:(NSUInteger)index
{
    return [products objectAtIndex:index];
}

- (void)removeProductAtIndex:(NSUInteger)index
{
    [products removeObjectAtIndex:index];
}

- (void)removeProductsAtIndexes:(NSIndexSet *)indexSet
{
    [products removeObjectsAtIndexes:indexSet];
}

- (void)clearCart
{
    [products removeAllObjects];
}

- (void)deleteAllSelectProducts
{
    for (int i = 0; i < products.count; i++) {
        NSDictionary *dict = products[i];
        if ([[dict objectForKey:CartManagerSelectedKey] isEqualToString:@"yes"]) {
            [products removeObjectAtIndex:i];
        }
    }
}

- (float)allMoney
{
    float totalMoney = 0.0;
    
    for (NSDictionary *good in products) {
        totalMoney += [[good objectForKey:CartManagerPriceKey] floatValue] * [[good objectForKey:CartManagerCountKey] floatValue];
    }
    
    return totalMoney;
}

- (float)selectedAllMoney
{
    float totalMoney = 0.0;
    
    for (NSDictionary *good in products) {
        if ([[good objectForKey:CartManagerSelectedKey] isEqualToString:@"yes"]) {
            totalMoney += [[good objectForKey:CartManagerPriceKey] floatValue] * [[good objectForKey:CartManagerCountKey] floatValue];
        }
    }
    
    return totalMoney;
}

- (NSString *)productCount
{
    int count = 0;
    
    for (NSDictionary *good in products) {
        count += [[good objectForKey:CartManagerCountKey] integerValue];
    }
    
    return [NSString stringWithFormat:@"%d", count];
}

- (NSString *)selectedProductCount
{
    int count = 0;
    
    for (NSDictionary *good in products) {
        if ([[good objectForKey:CartManagerSelectedKey] isEqualToString:@"yes"]) {
            count += [[good objectForKey:CartManagerCountKey] integerValue];
        }
    }
    
    return [NSString stringWithFormat:@"%d", count];
}

@end
