//
//  SearchResultsViewController.h
//  Shops-iPhone
//
//  Created by rujax on 14-1-21.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSearchTypeShop @"shop"
#define kSearchTypeProduct @"product"

typedef NS_ENUM(NSInteger, SearchTableTag) {
    kSearchTableHistory = 1001,
    kSearchTableResult  = 1002
};

@interface SearchResultsViewController : UIViewController

@property (nonatomic, copy) NSString *searchType;
@property (nonatomic, copy) NSString *keyword;

@end
