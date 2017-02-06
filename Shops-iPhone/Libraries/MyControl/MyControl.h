//
//  MyControl.h
//  LimitFreeProjct
//
//  Created by ZhangCheng on 14/7/10.
//  Copyright (c) 2014年 张诚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MyControl : NSObject
+(float)isIOS7;
//创建button
+(UIButton*)createButtonWithFrame:(CGRect)frame imageName:(NSString*)imageName bgImageName:(NSString*)bgImageName title:(NSString*)title SEL:(SEL)sel target:(id)target;
//创建ImageView
+(UIImageView*)createImageViewWithFrame:(CGRect)frame imageName:(NSString*)imageName;
//创建Label
+(UILabel*)createLabelWithFrame:(CGRect)frame Font:(float)font Text:(NSString*)text;
@end






