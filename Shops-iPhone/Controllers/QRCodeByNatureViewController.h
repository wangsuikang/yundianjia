//
//  QRCodeByNatureViewController.h
//  Shops-iPhone
//
//  Created by rujax on 14-1-17.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSInteger, QRCodeUseType) {
    QRCodeNormal = 0,
    QRCodeExpress,
    QRCodeFavorite
};

@interface QRCodeByNatureViewController : UIViewController

@property (nonatomic, assign) NSInteger useType;

@end
