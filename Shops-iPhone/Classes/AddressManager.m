//
//  AddressManager.m
//  Shops-iPhone
//
//  Created by rujax on 2013-11-04.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "AddressManager.h"

#import "FMDatabase.h"

static AddressManager *manager = nil;
static FMDatabase *db = nil;

@interface AddressManager()

@end

@implementation AddressManager

+ (AddressManager *)defaultManager
{
    @synchronized(self)
    {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
        
        if (db == nil) {
            NSString *dbFilePath = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"sqlite"];
            db = [FMDatabase databaseWithPath:dbFilePath];
            
            if (![db open]) {
                YunLog(@"can't open db");
            }
        }
    }
    
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (manager == nil) {
            manager = [super allocWithZone:zone];
            
            return manager;
        }
    }
    
    return nil;
}

- (NSArray *)provinces
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from province"]];
    
    while ([rs next]) {
        [result addObject:[rs resultDictionary]];
    }
    
    return [NSArray arrayWithArray:result];
}

- (NSArray *)citiesWithProvinceID:(NSString *)provinceID
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from city where parent_id = %@", provinceID]];
    
    while ([rs next]) {
        [result addObject:[rs resultDictionary]];
    }
    
    return [NSArray arrayWithArray:result];
}

- (NSArray *)areasWithCityID:(NSString *)cityID
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from county where parent_id = %@", cityID]];
    
    while ([rs next]) {
        [result addObject:[rs resultDictionary]];
    }
    
    return [NSArray arrayWithArray:result];
}

@end
