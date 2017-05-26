//
//  SDGAnimation.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDGAnimation : NSObject
+ (instancetype)Ins;
+ (CAAnimation *)animationFlip;
+ (CAAnimation *)animationFade;
+ (CAAnimation *)animationScale;
@end
