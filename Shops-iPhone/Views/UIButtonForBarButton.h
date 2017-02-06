//
//  UIButtonForBarButton.h
//  Shops-iPhone
//
//  Created by rujax on 2013-12-03.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBarButton_2_Length 50
#define kBarButton_3_Length 68
#define kBarButton_4_Length 84
#define kBarButton_5_Length (kScreenWidth / 2)

@interface UIButtonForBarButton : UIButton

- (id)initWithTitle:(NSString *)title wordLength:(NSString *)length;
//- (id)initWithFrame:(CGRect)frame title:(NSString *)title wordLength:(NSString *)length;

@end
