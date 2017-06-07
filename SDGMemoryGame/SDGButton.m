//
//  SDGButton.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 27/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGButton.h"

@implementation SDGButton

+ (SDGButton *)sdg_button:(BOOL)animation {
    SDGButton *button = [SDGButton buttonWithType:UIButtonTypeCustom];
    // 默认圆角
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    
    // 按钮阴影
    button.layer.shadowOffset = CGSizeMake(0, 0);
    button.layer.shadowColor = [UIColor grayColor].CGColor;
    button.layer.shadowOpacity = 0.8;
    
    if (animation) {
        // 按钮动画
        [button.layer addAnimation:[SDGAnimation animationScale] forKey:@"animationScaleHome"];
    }
    return button;
}

+ (SDGButton *)sdg_buttonWithPngName:(NSString *)name animation:(BOOL)animation {
    SDGButton *button = [SDGButton sdg_button:(BOOL)animation];
    // 背景图片
    UIImage *image = [UIImage imageNamed:name];
    [button setImage:image forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    return button;
}

+ (SDGButton *)sdg_buttonColorBgWithTitle:(NSString *)title animation:(BOOL)animation {
    SDGButton *button = [SDGButton sdg_button:(BOOL)animation];
    // 背景色
    button.backgroundColor = SDGRGBColor(90, 137, 199);
    // 按钮文字
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

+ (SDGButton *)sdg_buttonWithCardBgName:(NSString *)name animation:(BOOL)animation {
    SDGButton *button = [SDGButton sdg_button:(BOOL)animation];
    // 卡片背景图
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    // 卡片按钮边框
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    return button;
}

+ (SDGButton *)sdg_buttonWithText:(NSString *)text animation:(BOOL)animation {
    SDGButton *button = [SDGButton sdg_button:(BOOL)animation];
    // 按钮文字
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = SDGFont;
    [button setTitleColor:SDGThemeColor forState:UIControlStateNormal];
    [button sizeToFit];
    return button;
}

@end
