//
//  BlurImage.h
//  LLPP_IOS
//
//  Created by Sonic Lin on 11/30/14.
//  Copyright (c) 2014 hengling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BlurImage : NSObject
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
@end
