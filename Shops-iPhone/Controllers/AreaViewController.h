//
//  AreaViewController.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-04.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaViewController : UIViewController

@property (nonatomic, copy) NSString *cityID;
@property (nonatomic, assign, getter = isAddressEditing) BOOL addressEditing;

@end