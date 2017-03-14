//
//  SDGAnimation.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGAnimation.h"
#import <QuartzCore/CAAnimation.h>
@interface SDGAnimation()

@property (nonatomic, strong, readonly) CAAnimation *animationFlip;
@property (nonatomic, strong, readonly) CAAnimation *animationFade;

@end

@implementation SDGAnimation
+ (instancetype)Ins {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SDGAnimation alloc] init];
    });
    return sharedInstance;
}
+ (CAAnimation *)animationFlip {
    return [SDGAnimation Ins].animationFlip;
}
+ (CAAnimation *)animationFade {
    return [SDGAnimation Ins].animationFade;
}

/**
 * 翻转动画
 */
- (CAAnimation *)animationFlip {
    CATransform3D rotationTransform = CATransform3DMakeScale(0, 1, 1);
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration = AniDuration;
    animation.repeatCount = 1;
    return animation;
}

/**
 * 消失动画
 */
- (CAAnimation *)animationFade {
    CATransform3D scaleTransform = CATransform3DMakeScale(0, 0, 1);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:scaleTransform];
    animation.duration = AniDuration * 2;
    animation.repeatCount = 1;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

@end
