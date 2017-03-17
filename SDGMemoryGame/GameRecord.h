//
//  GameRecord.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 13/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRecord : NSObject

+ (instancetype)Ins;
+ (void)saveRecords: (NSMutableArray *)newRecords ofGameLevel:(SDGGameLevel)level;
+ (NSMutableArray *)getRecordsOfGameLevel:(SDGGameLevel)level;

@end
