//
//  SearchTextField.h
//  Shops-iPhone
//
//  Created by rujax on 14-1-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SearchSubviewTag) {
    TitleLabel = 1000,
    ArrowImageView = 1001
};

@class SearchTextField;

@protocol SearchTextFieldDelegate <NSObject>

- (void)searchTextFieldToggleType:(SearchTextField *)searchTextField;

@end

@interface SearchTextField : UITextField

@property (nonatomic, assign) id<SearchTextFieldDelegate> searchDelegate;

@end
