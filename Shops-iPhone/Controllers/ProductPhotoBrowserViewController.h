//
//  ProductPhotoBrowserViewController.h
//  Shops-iPhone
//
//  Created by rujax on 14-7-15.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "MWPhotoBrowser.h"

@class FXLabel;

@interface ProductPhotoBrowserViewController : MWPhotoBrowser

@property (nonatomic, copy) NSString *productName;
@property (nonatomic, copy) NSString *shopCode;
@property (nonatomic, strong) NSDictionary *variant;

@end
