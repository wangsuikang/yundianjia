//
//  AddProductVariantsViewController.h
//  Shops-iPhone
//
//  Created by xxy on 15/9/23.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LMComBoxView.h"
#import "LMContainsLMComboxScrollView.h"

@interface AddProductVariantsViewController : UIViewController <LMComBoxViewDelegate>

/// 商品分类数组
@property (nonatomic, strong) NSMutableArray *productCategoryArray;

/// 商品规格名称数组
@property (nonatomic, strong) NSMutableArray *variantsArray;

@end
