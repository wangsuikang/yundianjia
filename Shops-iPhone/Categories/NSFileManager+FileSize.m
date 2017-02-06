//
//  NSFileManager+FileSize.m
//  Shops-iPhone
//
//  Created by rujax on 14-5-16.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "NSFileManager+FileSize.h"

#import <sys/stat.h>

@implementation NSFileManager (FileSize)

- (long long)fileSizeAtPath:(NSString *)path
{
    struct stat st;
    
    if (lstat([path cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0) {
        return st.st_size;
    }
    
    return 0;
}

@end
