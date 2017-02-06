//
//  Umpay.h
//  UmpaySDK
//
//  Created by Wang Haijun on 13-5-19.
//  Copyright (c) 2013年 Umpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UmpayDelegate <NSObject>

@required

- (void)onPayResult:(NSString*)orderId resultCode:(NSString*)resultCode resultMessage:(NSString*)resultMessage;

@end

@interface Umpay : NSObject

//tradeNo :由服务器下单返回的13位数字组成的订单号
//cardType:@"0"-----借记卡支付类型；@"1"----信用卡支付类型
//bankName:用户选择支付的银行名称
//rootViewController:根视图控制器
//delegate:用于支付回调协议实现类

+ (BOOL)pay:(NSString *)tradeNo cardType:(NSString*)_cardType bankName:(NSString*)_bankName rootViewController:(UIViewController*)rootViewController delegate:(id<UmpayDelegate>)delegate;

@end