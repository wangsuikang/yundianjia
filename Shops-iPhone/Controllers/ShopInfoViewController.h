//
//  ShopInfoViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define priceRowHeight 30
#define kPriceFromLowToHighNotification @"kPriceFromLowToHighNotification"
#define kPriceFromHighToLowNotification @"kPriceFromHighToLowNotification"
#define kJumpOutPriceOrderNotification  @"kJumpOutPriceOrderNotification"

@interface ShopInfoViewController : UIViewController

@property (nonatomic, copy) NSString *code;

@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger subIndexOfPriceOrder;

/**
 DKTPageViewDelegate当滑动到其他index时调用此方法

 @aram index 滑动结束后所在index
 */
- (void)swipeToControllerIndex:(NSInteger)index;
@end
