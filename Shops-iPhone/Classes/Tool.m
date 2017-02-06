//
//  Tool.m
//  DoteeVideo_iPad
//
//  Created by rujax on 2013-08-22.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "Tool.h"

// for mac address
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>

// for md5digest
#import <CommonCrypto/CommonDigest.h>
#import "NSString+MD5Addition.h"

// for network
#import "Reachability.h"

// for uuid
#import "SSKeychain.h"

// for reset user
#import "AppDelegate.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+Extend.h"

// for device model
#import <sys/utsname.h>

// for share
#import "WXApi.h"

@implementation Tool

#pragma mark - MAC Address -

+ (NSString *)getMACAddress
{
    int              mib[6];
    size_t              len;
    char               *buf;
    unsigned char      *ptr;
    struct if_msghdr   *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    
    return [outstring uppercaseString];
}

#pragma mark - MD5 Digest -

+ (NSString *)md5Digest:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr, strlen(cStr), result);
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - UUID -

+ (NSString *)getUniqueDeviceIdentifier
{
    NSString *uuid = [SSKeychain passwordForService:@"net.atyun.Shops-iPhone" account:@"uuid"];
    YunLog(@"uuid = %@", uuid);
    
    if (!uuid) {
        CFUUIDRef puuid = CFUUIDCreate(nil);
        CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
        
        NSString *result = [NSString stringWithFormat:@"%@", uuidString];
        
        CFRelease(puuid);
        CFRelease(uuidString);
        
        [SSKeychain setPassword:result forService:@"net.atyun.Shops-iPhone" account:@"uuid"];
        
        return result;
    }
    
    return uuid;
}

+ (NSString *)uuid
{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    
    NSString *result = [NSString stringWithFormat:@"%@", uuidString];
    
    CFRelease(puuid);
    CFRelease(uuidString);
    
    return result;
}

#pragma mark - String Length -

+ (int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    
    int length = (int)[da length];
    
    if (length % 2 == 0) {
        length /= 2;
    } else {
        length = length / 2 + 1;
    }
    
    return length;
}

+ (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char *p = (char *)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0 ; i < [strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    
    if (strlength % 2 == 0) {
        strlength /= 2;
    } else {
        strlength = strlength / 2 + 1;
    }
    
     return strlength;
}

#pragma mark - Network Available -

+ (BOOL)isNetworkAvailable
{
    BOOL isExistenceNetwork = YES;
    
    Reachability *r = [Reachability reachabilityWithHostname:@"www.so.com"];
    
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            YunLog(@"没有网络");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            YunLog(@"正在使用3G网络");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            YunLog(@"正在使用wifi网络");
            break;
    }
    
    return isExistenceNetwork;
}

+ (id)getCache:(NSString *)url
{
    return nil;
}

#pragma mark - Null String -

//+ (NSString *)nullToString:(NSString *)str
//{
//    if ([str isEqual:[NSNull null]] || str == nil) {
//        str = @"";
//    }
//    
//    return str;
//}

#pragma mark - Badge -

+ (void)addBadgeToView:(UIView *)view badgeValue:(NSString *)badgeValue location:(NSString *)location cgPoint:(CGPoint)point
{
    YunLog(@"location = %@", location);
    
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = badgeValue;
    
    NSArray *array = [[NSArray alloc] initWithObjects:item, nil];
    
    tabBar.items = array;
    
    // 寻找
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] || [strClassName isEqualToString:@"_UIBadgeView"]) {
                // 从原视图上移除
                [subview removeFromSuperview];
                
                // 添加到需要的视图
                if (!location || [location isEqualToString:@""]) {
                    subview.frame = CGRectMake(view.frame.size.width - subview.frame.size.width, 0, subview.frame.size.width, subview.frame.size.height);
//                    subview.frame = CGRectMake((kScreenWidth / 3) - 50, 0, subview.frame.size.width, subview.frame.size.height);
                    
                    YunLog(@"%@",NSStringFromCGPoint(subview.center));
                    
                    [view addSubview:subview];
                    
                    return;
                } else if ([location isEqualToString:@"topRight"]) {
                    subview.center = CGPointMake(view.frame.size.width, view.frame.origin.y + subview.frame.size.height / 2);
                    
                    [view addSubview:subview];
                    
                    return;
                } else if ([location isEqualToString:@"topLeft"]) {
                    subview.center = view.frame.origin;
                    
                    [view addSubview:subview];
                    
                    return;
                }
            }
        }
    }
}

+ (void)removeBadge:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
        if ([strClassName isEqualToString:@"UITabBarButtonBadge"] || [strClassName isEqualToString:@"_UIBadgeView"]) {
            [subview removeFromSuperview];
            
            break;
        }
    }
}

#pragma mark - Reset User -

+ (void)resetUser
{
    AppDelegate *delegate = kAppDelegate;
    
    delegate.user = nil;
    delegate.user = [[User alloc] init];
    delegate.login = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:nil forKey:@"username"];
    [defaults setObject:nil forKey:@"user_session_key"];
    [defaults setObject:nil forKey:@"userType"];
    [defaults setObject:nil forKey:@"display_name"];
    
    [defaults synchronize];
    
    AppDelegate *appDelegate = kAppDelegate;
    [[MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES] addErrorString:@"身份认证已过期,请重新登录" delay:2.0];
    
}

#pragma mark 计算UILabel的高度
+(CGFloat)calculateContentLabelHeight:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)width{
    CGSize commentSize;
    commentSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:        NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    return commentSize.height;
}

#pragma mark - Detail Label -

+ (int)detailLabelHeight:(NSString *)str wordLength:(int)length linePadding:(int)padding fontSize:(int)size
{
    int detailLabelHeight;
    
    int detailLines = [self getToInt:str];
    
    if (detailLines % length == 0) {
        detailLabelHeight = (int)(detailLines / length) * (size + padding);
    } else {
        detailLabelHeight = (detailLines / length + 1) * (size + padding);
    }
    
    YunLog(@"str = %@\nword length = %d\nline padding = %d\nfont size = %d\ndetailLabelHeight = %d\n", str, length, padding, size, detailLabelHeight);
    
    return detailLabelHeight;
}

+ (int)textLines:(NSString *)str lineWidth:(int)width fontSize:(int)size;
{
    YunLog(@"str = %@", str);
    
    int wordLength = width / size;
    
    int lines = [self getToInt:str] / wordLength;
    
    if ([self getToInt:str] % wordLength != 0) {
        lines += 1;
    }
    
    return lines;
}

#pragma mark - Share -

+ (void)shareToWeiXin:(NSInteger)scene title:(NSString *)title description:(NSString *)description thumb:(NSString *)thumb url:(NSString *)url
{
    YunLog(@"share title = %@", title);
    YunLog(@"share description = %@", description);
    YunLog(@"share thumb = %@", thumb);
    YunLog(@"share url = %@", url);
    
    AppDelegate *delegate = kAppDelegate;
    
//    NSDictionary *dic = @{@"uuid":[Tool getUniqueDeviceIdentifier]};
    
    delegate.shareType = ShareToWeiXin;
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    if (scene == WXSceneTimeline) {
//        [TalkingData trackEvent:@"分享" label:@"微信朋友圈" parameters:dic];
        
        message.title = title;
        message.description = description;
    } else {
//        [TalkingData trackEvent:@"分享" label:@"微信好友" parameters:dic];
        
        message.title = title;
        message.description = description;
    }
    
    if ([thumb isEqualToString:@""] || thumb == nil) {
        [message setThumbImage:[UIImage imageNamed:@"share_logo"]];
    } else {        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]];
        
//         微信分享的缩略图不得超过32K
        if ([data length] > 31200) {
            [message setThumbImage:[UIImage imageNamed:@"share_logo"]];
        } else {
            [message setThumbData:data];
        }
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = (int)scene;
    
    [WXApi sendReq:req];
}

+ (void)shareToWeiBo:(NSString *)imageStr description:(NSString *)description
{
    YunLog(@"description = %@", description);
    
    AppDelegate *delegate = kAppDelegate;
    
//    NSDictionary *dic = @{@"uuid":[Tool getUniqueDeviceIdentifier]};
//    
//    [TalkingData trackEvent:@"分享" label:@"新浪微博" parameters:dic];
    
    delegate.shareType = ShareToWeiBo;
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = description;
    
    WBImageObject *imageObject = [WBImageObject object];
    if (imageStr == nil) {
        imageObject.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"share_logo"]);
    } else {
        imageObject.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageStr]];
    }
    
    message.imageObject = imageObject;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

#pragma mark - Screenshot -

+ (UIImage *)getViewScreenshot:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]] || [view isKindOfClass:[UITableView class]] || [view isKindOfClass:[UIWebView class]]) {
        BOOL isWebView = [view isKindOfClass:[UIWebView class]];
        
        UIScrollView *scrollView;
        
        if (isWebView) {
            scrollView = [(UIWebView *)view scrollView];
        } else {
            scrollView = (UIScrollView *)view;
        }
        
        // 整个 view
        CGSize size = CGSizeMake(kScreenWidth, scrollView.contentSize.height);
        
        if (&UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0); // retina 屏幕
        } else {
            UIGraphicsBeginImageContext(size); // 非 retina 屏幕
        }
        
        YunLog(@"scrollView size = %@", NSStringFromCGSize(size));
        
        NSString *scrollViewFrame = NSStringFromCGRect(scrollView.frame);
        
        scrollView.frame = CGRectMake(0, 0, kScreenWidth, size.height + kCustomNaviHeight);
        [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        scrollView.frame = CGRectFromString(scrollViewFrame);
        
        // 底部图
        UIImage *bottomImage = [self getBottomImage];
        
        CGSize resultSize = CGSizeMake(kScreenWidth, image.size.height + bottomImage.size.height);
        
        UIGraphicsBeginImageContext(resultSize);
        
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [bottomImage drawInRect:CGRectMake(0, image.size.height, bottomImage.size.width, bottomImage.size.height)];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
//        UIImageWriteToSavedPhotosAlbum(result, self, nil, nil);

        return result;
    }
    
    else {
        CGSize size = view.frame.size;
        UIImage *image; //获取view的尺寸
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f); //配置参数
        [view drawViewHierarchyInRect: [view bounds] afterScreenUpdates: YES]; //截图
        image = UIGraphicsGetImageFromCurrentImageContext(); //获取UIImage
        return image;
    }
}

+ (UIImage *)getBottomImage
{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = COLOR(228, 229, 229, 1);
    
    UIImage *image = [UIImage imageNamed:@"share_bottom"];
    
    UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:image];
    bottomImageView.frame = CGRectMake(kScreenWidth - image.size.width, 0, image.size.width, image.size.height);
    
    bottomView.frame = CGRectMake(0, 0, kScreenWidth, image.size.height);
    [bottomView addSubview:bottomImageView];
    
    UIGraphicsBeginImageContext(CGSizeMake(kScreenWidth, image.size.height));
    
    [bottomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *bottomImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return bottomImage;
}

#pragma mark - Screen Flash -

+ (UIImage *)getScreenFlash
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastAppVersion = [defaults objectForKey:kLastAppVersion];
    
    YunLog(@"lastAppVersion = %@", lastAppVersion);
    
    if ([lastAppVersion length] == 7) {
        lastAppVersion = [lastAppVersion substringToIndex:3];
        
        [defaults setObject:lastAppVersion forKey:kLastAppVersion];
        
        [defaults synchronize];
    }
    
    NSString *currentAppVersion = [self versionString];
    
    YunLog(@"currentAppVersion = %@", currentAppVersion);
    
    if (!lastAppVersion) {
//        [defaults setObject:currentAppVersion forKey:kLastAppVersion];
//        
//        [defaults synchronize];
        
        return nil;
    } else {
        if ([lastAppVersion integerValue] < [currentAppVersion integerValue]) {
//            [defaults setObject:currentAppVersion forKey:kLastAppVersion];
//            
//            [defaults synchronize];
            
            return nil;
        }
    }
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath = [documentsDirectoryPath stringByAppendingPathComponent:@"screen_flash"];
    YunLog(@"screen flash dirPath = %@", dirPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *images = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
    YunLog(@"images = %@", images);
    
    if (images.count > 0) {
        return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", dirPath, images[0]]];
    }
    
    return nil;
}

+ (NSString *)versionString
{
    NSString *version  = @"";
    
    NSArray *temp = [kAppVersion componentsSeparatedByString:@"."];
    
    for (NSString *str in temp) {
        version = [version stringByAppendingString:str];
    }
    
    YunLog(@"version = %@", version);
    YunLog(@"kAppBuild = %@", kAppBuild);
    
//    version = [version stringByAppendingString:kAppBuild];
//    version = [NSString stringWithFormat:@"%d", [version integerValue] * 10000 + [kAppBuild integerValue]];
    
    return version;
}

#pragma mark - Device Model -

/**
 *	@brief	获取设备型号
 *
 *	@return	设备型号：设备型号对照如下：
 *  iPhone1,1  ->   iPhone (Original/EDGE)
 *  iPhone1,2  ->   iPhone 3G
 *  iPhone1,2* ->   iPhone 3G (China/No Wi-Fi)
 *  iPhone2,1  ->   iPhone 3GS
 *  iPhone2,1* ->   iPhone 3GS (China/No Wi-Fi)
 *  iPhone3,1  ->   iPhone 4 (GSM)
 *  iPhone3,3  ->   iPhone 4 (CDMA/Verizon/Sprint)
 *  iPhone4,1  ->   iPhone 4S
 *  iPhone4,1* ->   iPhone 4S (GSM China/WAPI)
 *  iPhone5,1  ->   iPhone 5 (GSM/LTE 4, 17/North America), iPhone 5 (GSM/LTE 1, 3, 5/International), iPhone 5 (GSM/LTE/AWS/North America)
 *  iPhone5,2  ->   iPhone 5 (CDMA/LTE, Sprint/Verizon/KDDI)
 *  iPhone5,2* ->   iPhone 5 (CDMA China/UIM/WAPI)
 *
 *  iPod1,1   -> iPod touch (Original)
 *  iPod2,1   -> iPod touch (2nd Gen)
 *  iPod2,2   -> iPod touch 2.5G
 *  iPod3,1   -> iPod touch (3rd Gen/8 GB), iPod touch (3rd Gen/32 & 64 GB)
 *  iPod4,1   -> iPod touch (4th Gen/FaceTime), iPod touch (4th Gen, 2011), iPod touch (4th Gen, 2012)
 *  iPod5,1   -> iPod touch (5th Gen)
 *
 *  iPad1,1   -> iPad Wi-Fi (Original), iPad Wi-Fi/3G/GPS (Original)
 *  iPad2,1   -> iPad 2 (Wi-Fi Only)
 *  iPad2,2   -> iPad 2 (Wi-Fi/GSM/GPS)
 *  iPad2,3   -> iPad 2 (Wi-Fi/CDMA/GPS)
 *  iPad2,4   -> iPad 2 (Wi-Fi Only, iPad2,4)
 *  iPad3,1   -> iPad 3rd Gen (Wi-Fi Only)
 *  iPad3,3   -> iPad 3rd Gen (Wi-Fi/Cellular AT&T/GPS)
 *  iPad3,2   -> iPad 3rd Gen (Wi-Fi/Cellular Verizon/GPS)
 *  iPad3,4   -> iPad 4th Gen (Wi-Fi Only)
 *  iPad3,5   -> iPad 4th Gen (Wi-Fi/AT&T/GPS)
 *  iPad3,6   -> iPad 4th Gen (Wi-Fi/Verizon & Sprint/GPS)
 *  iPad2,5   -> iPad mini (Wi-Fi Only)
 *  iPad2,6   -> iPad mini (Wi-Fi/AT&T/GPS)
 *  iPad2,7   -> iPad mini (Wi-Fi/Verizon & Sprint/GPS)
 */

+ (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);

    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

//    YunLog(@"deviceString = %@", deviceString);
    
    NSArray *temp = [deviceString componentsSeparatedByString:@","];
    
    if ([temp[0] hasPrefix:@"iPhone"]) {
        NSString *version = [[temp[0] substringFromIndex:6] stringByAppendingString:temp[1]];
        
        YunLog(@"device type = iPhone, version = %@", version);
        
        return version;
    } else {
        return @"other";
    }
}

#pragma mark - URL Builder

+ (NSString *)buildRequestURLHost:(NSString *)host
                       APIVersion:(NSString *)APIVersion
                       requestURL:(NSString *)requestURL
                           params:(NSDictionary *)params
{
    YunLog(@"host = %@, APIVersion = %@, requestURL = %@, params = %@", host, APIVersion, requestURL, params);
    
    NSString *string = [NSString stringWithFormat:@"%@%@%@?", host, APIVersion, requestURL];
    
    NSEnumerator *keyEnumerator = [params keyEnumerator];
    
    NSEnumerator *objectEnumerator = [params objectEnumerator];
    
    id key;
    
    while (key = [keyEnumerator nextObject]) {
        NSString *obj = [NSString stringWithFormat:@"%@", [objectEnumerator nextObject]];
//        obj = [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        obj = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)obj, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
        
        string = [string stringByAppendingFormat:@"%@=%@&", key, obj];
    }
    
    string = [string stringByAppendingFormat:@"platform=iphone&intf_revision=%@&app_revision=%@", kIntfRevision, kAppVersion];
    
    return string;
}

@end
