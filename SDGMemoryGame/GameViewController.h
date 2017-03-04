//
//  GameViewController.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 16/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController

@property (nonatomic, assign)SDGGameLevel GameLevel; // 游戏难度
@property (nonatomic, assign)int round;              // 第几关
@property (nonatomic, assign)int matchCount;         // 匹配总数统计
@property (nonatomic, assign)int rightCount;         // 匹配成功统计

@end
