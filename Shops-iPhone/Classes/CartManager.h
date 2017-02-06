//
//  CartManager.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartManager : NSObject

// 单例实例
+ (CartManager *)defaultCart;

- (NSArray *)allProducts;
- (NSArray *)allSelectedProducts;

- (void)clearCart;
- (void)deleteAllSelectProducts;

- (NSString *)productCount;
- (NSString *)selectedProductCount;

- (float)allMoney;
- (float)selectedAllMoney;

- (void)addProduct:(NSDictionary *)productDic success:(void(^)(void))success failure:(void(^)(int count))failure;

- (id)productAtIndex:(NSUInteger)index;

- (void)updateProduct:(NSDictionary *)product atIndex:(NSInteger)index;

- (void)removeProductAtIndex:(NSUInteger)index;
- (void)removeProductsAtIndexes:(NSIndexSet *)indexSet;

extern NSString * const CartManagerDescriptionKey;
extern NSString * const CartManagerSubtitleKey;
extern NSString * const CartManagerPriceKey;
extern NSString * const CartManagerSkuIDKey;
extern NSString * const CartManagerImageURLKey;
extern NSString * const CartManagerSmallImageURLKey;
extern NSString * const CartManagerShopCodeKey;
extern NSString * const CartManagerProductCodeKey;
extern NSString * const CartManagerCountKey;
extern NSString * const CartManagerMinCountKey;
extern NSString * const CartManagerMaxCountKey;
extern NSString * const CartManagerSelectedKey;
extern NSString * const CartManagerInventoryKey;
extern NSString * const CartManagerPromotionsKey;

@end
