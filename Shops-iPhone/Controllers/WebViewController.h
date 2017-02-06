//
//  WebViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-10-31.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSString *naviTitle;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSDictionary *shareParams;

@end
