//
//  WXPayDelegate.h
//  Shops-iPhone
//
//  Created by rujax on 14-10-11.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXPayResult) {
    WXPayResultSuccess = 0,
    WXPayResultFailure
};

@protocol WXPayDelegate <NSObject>

- (void)showPayResult:(WXPayResult)result message:(NSString *)message;

@end
