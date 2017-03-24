//
//  SDGButton.h
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 27/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDGButton : UIButton

+ (SDGButton *)sdg_button;
+ (SDGButton *)sdg_buttonWithName:(NSString *)name;
+ (SDGButton *)sdg_buttonWithTitle:(NSString *)title;
+ (SDGButton *)sdg_buttonWithFrame:(CGRect)frame;

@end
