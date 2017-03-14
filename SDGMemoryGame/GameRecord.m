//
//  GameRecord.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 13/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "GameRecord.h"
#import "PlayerRecord.h"

@interface GameRecord()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation GameRecord

+ (instancetype)Ins {
    static dispatch_once_t once_token;
    static id sharedInstance;
    dispatch_once(&once_token, ^{
        sharedInstance = [[GameRecord alloc] init];
    });
    return sharedInstance;
}

+ (void)saveRecords:(NSMutableArray *)newRecords {
    NSMutableArray *dicRecords = [NSMutableArray mj_keyValuesArrayWithObjectArray:newRecords];
    NSString *string_record = [dicRecords mj_JSONString];
    [[GameRecord Ins].defaults setObject:string_record forKey:@"sdg_records"];
}

- (id)init {
    if ([super init]) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSMutableArray *)SavedRecord {
    NSString *string_record = [_defaults objectForKey:@"sdg_records"];
    if (!string_record) {
        return nil;
    }
    NSMutableArray *record_dics = [NSJSONSerialization JSONObjectWithData:[string_record dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *records = [PlayerRecord mj_objectArrayWithKeyValuesArray:record_dics];
    return records;
}

- (void)orderRecords: (NSMutableArray *)records {
    
}

@end
