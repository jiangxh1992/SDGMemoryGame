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

+ (void)saveRecords:(NSMutableArray *)newRecords ofGameLevel:(SDGGameLevel)level {
    [self orderRecords:newRecords]; // 按照分数排序
    NSMutableArray *dicRecords = [NSMutableArray mj_keyValuesArrayWithObjectArray:newRecords];
    NSString *string_record = [dicRecords mj_JSONString];
    NSString *key = [self getKeyOfLevel:level];
    [[GameRecord Ins].defaults setObject:string_record forKey:key];
}
+ (NSMutableArray *)getRecordsOfGameLevel:(SDGGameLevel)level {
    NSString *key = [self getKeyOfLevel:level];
    NSString *string_record = [[GameRecord Ins].defaults objectForKey:key];
    if (!string_record) {
        return nil;
    }
    NSMutableArray *record_dics = [NSJSONSerialization JSONObjectWithData:[string_record dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *records = [PlayerRecord mj_objectArrayWithKeyValuesArray:record_dics];
    return records;
}

- (id)init {
    if ([super init]) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

+ (NSString *)getKeyOfLevel:(SDGGameLevel)level {
    NSString *key;
    switch (level) {
        case SDGGameLevelEasy:
            key = @"sdg_easy_records";
            break;
        case SDGGameLevelMedium:
            key = @"sdg_medium_records";
            break;
        case SDGGameLevelDifficult:
            key = @"sdg_difficult_records";
        default:
            break;
    }
    return key;
}

// 排序
+ (void)orderRecords: (NSMutableArray *)records {
    for(NSInteger i = records.count-1 ; i > 0; i--) {
        for(NSInteger j = 0; j < i; j++) {
            PlayerRecord *cur = [records objectAtIndex:j];
            PlayerRecord *next = [records objectAtIndex:j + 1];
            if (cur.score < next.score) {
                [records exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
        }
    }
}

@end
