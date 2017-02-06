//
//  UIImage+LoadImageFromWeb.m
//  QiuYiGua
//
//  Created by rujax on 2013-05-23.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "UIImage+LoadImageFromWeb.h"

#import "NSObject+NullToString.m"

@implementation UIImage (LoadImageFromWeb)

+ (UIImage *)loadImageFromWeb:(NSString *)imageURL
{
//    YunLog(@"load web image start");
    
    if (!imageURL || [imageURL isEqualToString:@""]) return nil;
    
    UIImage *image;
    
    NSURL *url = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        image = [UIImage imageWithData:data];
    } else {
        image = nil;
    }
    
//    YunLog(@"load web image end");
    
    return image;
}

+ (void)loadAndSaveImageFromWeb:(NSString *)imageURL
{
    YunLog(@"loadAndSaveImageFromWeb, imageURL = %@", imageURL);
    
    if (!imageURL || [imageURL isEqualToString:@""]) return;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingPathComponent:@"shops"];
    
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:documentsDirectoryPath isDirectory:&isDir]) {
        NSError *error;
        if ([fileManager createDirectoryAtPath:documentsDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            YunLog(@"create shops images directory success");
        } else {
            YunLog(@"create shops images directory error = %@", error);
        }
    }
    
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:[imageURL toMD5]];
    
    YunLog(@"filePath = %@",filePath);
    
    if ([fileManager fileExistsAtPath:filePath]) {
        YunLog(@"file exist at path = %@", filePath);
        
        return;
    }
    
    UIImage *image;
    
    NSURL *url = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data) {
        image = [UIImage imageWithData:data];
    } else {
        image = nil;
    }
    
    if (image != nil) {
        YunLog(@"save web image filePath = %@", filePath);
        
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath options:NSAtomicWrite error:nil];
    }
}

+ (UIImage *)loadWebImageFromDocument:(NSString *)imageURL
{
    YunLog(@"loadWebImageFromDocument, imageURL = %@", imageURL);
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/shops/%@", documentsDirectoryPath, [imageURL toMD5]]];
    
    return image;
}

@end
