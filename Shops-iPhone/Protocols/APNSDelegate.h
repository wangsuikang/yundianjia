//
//  APNSDelegate.h
//  Shops-iPhone
//
//  Created by rujax on 14-3-25.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APNSDelegate <NSObject>

- (void)showAPNSMessage:(NSDictionary *)message;

@end
