//
//  WXLoginDelegate.h
//  Shops-iPhone
//
//  Created by 席小雨 on 15/9/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXLoginResult) {
    WXLoginResultSuccess = 0,
    WXLoginResultFailure
};

@protocol WXLoginDelegate <NSObject>

- (void)showLoginResult:(WXLoginResult)result SendauthResp:(SendAuthResp *)resp message:(NSString *)message;

@end
