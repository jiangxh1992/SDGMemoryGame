//
//  SDGTransitionViewController.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 3/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDGViewController.h"
@interface SDGTransitionViewController : SDGViewController

@property (nonatomic, assign)SDGGameSate GameState;
@property (nonatomic, assign)SDGGameLevel GameLevel; // 游戏难度
@property (nonatomic, assign)int round;              // 第几关
@property (nonatomic, assign)int matchCount;         // 匹配总数统计
@property (nonatomic, assign)int rightCount;         // 匹配成功统计
@property (nonatomic, assign)int timeUsed;           // 已用的秒数
@property (nonatomic, assign)int curScore;           // 本局得分
@property (nonatomic, assign)int score;              // 积分累计

@end
