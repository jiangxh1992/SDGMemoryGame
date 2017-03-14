//
//  SDGEnum.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#ifndef SDGEnum_h
#define SDGEnum_h

// 游戏难度参数枚举
typedef NS_ENUM(NSInteger, SDGGameLevel) {
    SDGGameLevelEasy,
    SDGGameLevelMedium,
    SDGGameLevelDifficult
};
// 音效枚举
typedef NS_ENUM(NSUInteger, SDGSoundEffectID) {
    SDGSoundEffectIDOpenCard,
    SDGSoundEffectIDCloseCard,
    SDGSoundEffectIDCardMatched
};
// 游戏弹出框枚举
typedef NS_ENUM(NSUInteger, SDGGameAlertViewTag) {
    SDGAlertViewTagBack,
    SDGAlertViewTagRecord,
    SDGAlertViewTagGame
};

#endif /* SDGEnum_h */
