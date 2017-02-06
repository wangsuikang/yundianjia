//
//  NSFileManager+FileSize.h
//  Shops-iPhone
//
//  Created by rujax on 14-5-16.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (FileSize)

- (long long)fileSizeAtPath:(NSString *)path;

@end
