//
//  ShopListButton.h
//  Shops-iPhone
//
//  Created by rujax on 14-1-23.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LibraryHeadersForCommonController.h"

@interface ShopListButton : UIButton
{
    UIImageView *_shopImageView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
//    UIImageView *_leftTopView;
}

@property (nonatomic, copy) NSString *actionType;
@property (nonatomic, copy) NSString *actionValue;
//@property (nonatomic, copy) NSString *imageURL;
//@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImageView *shopImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *leftTopView;

@end
