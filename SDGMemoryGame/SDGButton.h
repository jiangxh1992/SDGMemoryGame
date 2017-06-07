//
//  SDGButton.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 27/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDGButton : UIButton

@property(nonatomic, assign) BOOL isDelaying;

// 基础带阴影圆角按钮
+ (SDGButton *)sdg_button:(BOOL)animation;

// 带背景图片的矩形按钮
+ (SDGButton *)sdg_buttonWithPngName:(NSString *)name animation:(BOOL)animation;
// 带主题背景色的文字按钮
+ (SDGButton *)sdg_buttonColorBgWithTitle:(NSString *)title animation:(BOOL)animation;
// 游戏卡片按钮
+ (SDGButton *)sdg_buttonWithCardBgName: (NSString *)name animation:(BOOL)animation;
// 纯文字按钮
+ (SDGButton *)sdg_buttonWithText:(NSString *)text animation:(BOOL)animation;
@end
