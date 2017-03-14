//
//  GameRecord.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 13/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRecord : NSObject

@property (nonatomic,strong,readonly) NSMutableArray *SavedRecord;

+ (instancetype)Ins;
+ (void)saveRecords: (NSMutableArray *)newRecords;

@end
