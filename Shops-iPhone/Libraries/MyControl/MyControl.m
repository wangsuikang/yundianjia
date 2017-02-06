//
//  MyControl.m
//  LimitFreeProjct
//
//  Created by ZhangCheng on 14/7/10.
//  Copyright (c) 2014年 张诚. All rights reserved.
//

#import "MyControl.h"
@implementation MyControl
+(float)isIOS7{
//判断版本
    if ([[[UIDevice currentDevice]systemVersion] floatValue]>=7.0) {
        return 64;
    }else{
        return 44;
    }
}
//使用工厂模式来进行创建
+(UIButton*)createButtonWithFrame:(CGRect)frame imageName:(NSString*)imageName bgImageName:(NSString*)bgImageName title:(NSString*)title SEL:(SEL)sel target:(id)target{
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    if (imageName) {
        UIImage *image = [UIImage imageNamed:imageName];
      UIImage *imageOrl = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [button setImage:imageOrl forState:UIControlStateNormal];
    }
    if (bgImageName) {
        [button setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    }
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        //并且设置字体颜色为黑色
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    //添加点击事件
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    //设置button的点击时候的高亮
    button.showsTouchWhenHighlighted=YES;
    return button;
}
+(UIImageView*)createImageViewWithFrame:(CGRect)frame imageName:(NSString*)imageName{
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:frame];
    imageView.image=[UIImage imageNamed:imageName];
    imageView.userInteractionEnabled=YES;
    return imageView;
}
+(UILabel*)createLabelWithFrame:(CGRect)frame Font:(float)font Text:(NSString*)text
{
    //[[UILabel appearance]setTextColor:[UIColor redColor]];
    
    UILabel*label=[[UILabel alloc]initWithFrame:frame];
    //设置字体大小
    label.font=[UIFont systemFontOfSize:font];
    //设置对齐方式
    label.textAlignment=NSTextAlignmentLeft;
    //设置行数
    label.numberOfLines=0;
    //设置折行方式
    label.lineBreakMode=NSLineBreakByWordWrapping;
    //设置阴影的颜色
   // label.shadowColor=[UIColor yellowColor];
    //设置阴影的偏移
   // label.shadowOffset=CGSizeMake(2, 2);
    
    //设置文字
    if (text) {
        label.text=text;
    }
    return label;
    
}








@end
