//
//  UIPlaceHolderTextView.h
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/14.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
