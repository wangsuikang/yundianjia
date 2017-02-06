//
//  EditProductViewController.h
//  Shops-iPhone
//
//  Created by xxy on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProductViewController : UIViewController

/// 保存用户的一些信息
@property (nonatomic, strong) NSDictionary *saleUserInfoDict;

/// 保存选中的分类的ID
@property (nonatomic, strong) NSMutableDictionary *optionCateDict;

/// 商品一级分类ID
@property (nonatomic, copy) NSString *productFirstId;

/// 商铺Code
@property (nonatomic, copy) NSString *shopCode;

/// 商铺ID
@property (nonatomic, copy) NSString *shopID;

@end
