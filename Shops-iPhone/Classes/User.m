//
//  User.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-01.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "User.h"

@implementation User

- (id)init
{
    self = [super init];
    
    if (self) {        
        _username = @"";
        _userSessionKey = @"";
    }
    
    return self;
}

- (void)addAddress:(NSDictionary *)dic
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_addresses];
    [temp addObject:dic];
    
    _addresses = [NSArray arrayWithArray:temp];
}

- (void)removeAddressAtIndex:(NSInteger)index
{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_addresses];
    [temp removeObjectAtIndex:index];
    
    _addresses = [NSArray arrayWithArray:temp];
}

- (NSArray *)setDefaultAddress:(NSInteger)index
{
    YunLog(@"_addresses = %@", _addresses);
    
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_addresses];
    
    for (int i = 0; i < temp.count; i++) {
        NSMutableDictionary *address = [NSMutableDictionary dictionaryWithDictionary:[temp objectAtIndex:i]];
        
        if (i == index) {
            [address setObject:@"1" forKey:@"is_default"];
        } else {
            [address setObject:@"0" forKey:@"is_default"];
        }
        
        [temp removeObjectAtIndex:i];
        [temp insertObject:address atIndex:i];
    }
    
    _addresses = [NSArray arrayWithArray:temp];
    
    return _addresses;
}

@end
