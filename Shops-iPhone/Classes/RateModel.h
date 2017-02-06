//
//  RateModel.h
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateModel : NSObject
/// 评分
@property (nonatomic,assign) NSInteger rank;
/// 文字评价
@property (nonatomic,copy) NSString *comment;

/// subOrder id
@property (nonatomic,strong) NSNumber *subOrderId;

/// 产品id
@property (nonatomic,strong) NSNumber *productId;

/// 产品名字
@property (nonatomic,copy) NSString *productName;

/// 产品缩略图
@property (nonatomic,copy) NSString *productIcon;

/// sku id
@property (nonatomic,copy) NSNumber *skuId;
@end
