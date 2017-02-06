//
//  ClassModel.h
//  Shops-iPhone
//
//  Created by xxy on 15/6/15.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassModel : NSObject

@property (nonatomic, strong) NSDictionary *children;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *grade;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *initial_image_url;
@property (nonatomic, copy) NSString *initial_image_url_size_1600_900;
@property (nonatomic, copy) NSString *initial_image_url_size_3200_1800;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parnet_id;
@property (nonatomic, copy) NSString *small_icon_url;
@property (nonatomic, copy) NSString *small_icon_url_size_100;
@property (nonatomic, copy) NSString *value;

@end
