//
//  ShopInfoNewController.h
//  Shops-iPhone
//
//  Created by xxy on 15/9/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define priceRowHeight 30
#define kPriceFromLowToHighNotification @"kPriceFromLowToHighNotification"
#define kPriceFromHighToLowNotification @"kPriceFromHighToLowNotification"
#define kJumpOutPriceOrderNotification @"kJumpOutPriceOrderNotification"

@interface ShopInfoNewController : UIViewController

@property (nonatomic, copy) NSString *code;

@end
