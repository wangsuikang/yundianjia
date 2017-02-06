//
//  ProductDetailViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-07.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : UIViewController

//@property (nonatomic, copy) NSString *productID;
//@property (nonatomic, copy) NSString *shopID;

@property (nonatomic, copy) NSString *shopCode;
@property (nonatomic, copy) NSString *productCode;


/// 是否是商户
@property (nonatomic, assign) BOOL isAdmin;

@end
