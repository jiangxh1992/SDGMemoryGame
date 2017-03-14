//
//  SDGSoundPlayer.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface SDGSoundPlayer : NSObject

+ (instancetype)Ins;
+ (void)playBackGroundMusic;
+ (void)stopBackGroundMusic;
+ (void)playSoundEffect:(NSUInteger)soundID;

@end
