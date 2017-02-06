//
//  Tool.h
//  Shops-iPhone
//
//  Created by rujax on 2013-08-22.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLastAppVersion @"lastAppVersion"

@interface Tool : NSObject

// MAC地址 MD5加密 生成设备的唯一标识符
+ (NSString *)getMACAddress;
+ (NSString *)md5Digest:(NSString *)str;
+ (NSString *)getUniqueDeviceIdentifier;

// 计算字符串长度
+ (int)getToInt:(NSString *)strtemp;
+ (int)convertToInt:(NSString *)strtemp;

// UUID
+ (NSString *)uuid;

+ (BOOL)isNetworkAvailable;

// 数据缓存
+ (id)getCache:(NSString *)url;

// 将null转换成nsstring
//+ (NSString *)nullToString:(NSString *)str;

// 添加 badge
+ (void)addBadgeToView:(UIView *)view badgeValue:(NSString *)badgeValue location:(NSString *)location cgPoint:(CGPoint)point;
+ (void)removeBadge:(UIView *)view;

// 注销用户
+ (void)resetUser;

// 计算文本框高度
+(CGFloat)calculateContentLabelHeight:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)width;

// 计算文本高度
+ (int)detailLabelHeight:(NSString *)str wordLength:(int)length linePadding:(int)padding fontSize:(int)size;
+ (int)textLines:(NSString *)str lineWidth:(int)width fontSize:(int)size;

// 截屏
+ (UIImage *)getViewScreenshot:(UIView *)view;

// 分享
+ (void)shareToWeiXin:(NSInteger)scene title:(NSString *)title description:(NSString *)description thumb:(NSString *)thumb url:(NSString *)url;
+ (void)shareToWeiBo:(NSString *)imageStr description:(NSString *)description;

// 闪屏图片
+ (UIImage *)getScreenFlash;

// 硬件型号
+ (NSString *)getDeviceModel;

// 版本号
+ (NSString *)versionString;

// 生成请求 URL
+ (NSString *)buildRequestURLHost:(NSString *)host
                       APIVersion:(NSString *)APIVersion
                       requestURL:(NSString *)requestURL
                           params:(NSDictionary *)params;

@end
