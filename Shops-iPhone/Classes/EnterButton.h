//
//  EnterButton.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/12.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterButton : UIButton

/// 商品code
@property (nonatomic, copy) NSString *productCode;

/// 店铺code
@property (nonatomic, copy) NSString *shopCode;

/// 商品规格的id
@property (nonatomic, copy) NSString *product_variantID;

/// 购物车里面使用，获取对应的indexPatch
@property (nonatomic, strong) NSIndexPath *cartIndexPatch;

@end
