//
//  BlurImage.m
//  LLPP_IOS
//
//  Created by Sonic Lin on 11/30/14.
//  Copyright (c) 2014 hengling. All rights reserved.
//

#import "BlurImage.h"


@implementation BlurImage
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *affineClampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    CGAffineTransform xform = CGAffineTransformMakeScale(1.0, 1.0);
    [affineClampFilter setValue:inputImage forKey:kCIInputImageKey];
    [affineClampFilter setValue:[NSValue valueWithBytes:&xform
                                               objCType:@encode(CGAffineTransform)]
                         forKey:@"inputTransform"];
    CIImage *extendedImage = [affineClampFilter valueForKey:kCIOutputImageKey];
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:extendedImage forKey:kCIInputImageKey];
    [blurFilter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
    CIImage *result = [blurFilter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    return returnImage;
}
- (UIImage *)blurryImagestr:(NSString *)imageStr withBlurLevel:(CGFloat)blur {
    NSURL *imageUrl=[NSURL URLWithString:imageStr];
    UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur), nil];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil]; // save it to self.context
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    return [UIImage imageWithCGImage:outImage];

}

@end
