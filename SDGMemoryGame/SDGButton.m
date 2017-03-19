//
//  SDGButton.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 27/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGButton.h"

@implementation SDGButton

+ (SDGButton *)sdg_button {
    SDGButton *button = [SDGButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    
    button.layer.shadowOffset = CGSizeMake(1, 1);
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 1.0;
    
    return button;
}

+ (SDGButton *)sdg_buttonWithName:(NSString *)name {
    SDGButton *button = [SDGButton sdg_button];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",name]] forState:UIControlStateNormal];
    return button;
}

+ (SDGButton *)sdg_buttonWithTitle:(NSString *)title {
    SDGButton *button = [SDGButton sdg_button];
    button.backgroundColor = SDGRGBColor(90, 137, 199);
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

@end
