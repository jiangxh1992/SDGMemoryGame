//
//  MenuViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 17/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"

@interface MenuViewController ()

// 按钮
@property (nonatomic, weak) IBOutlet UIButton *easyButton;
@property (nonatomic, weak) IBOutlet UIButton *mediumButton;
@property (nonatomic, weak) IBOutlet UIButton *difficultButton;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 配置UI
    [self setUI];
}

/**
 * 配置UI
 */
- (void)setUI {
    
    self.title = @"SDG MEMORY GAME";
    
    // 注册点击事件
    [_easyButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    [_easyButton setTag:SDGGameLevelEasy];
    [_mediumButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    [_mediumButton setTag:SDGGameLevelMedium];
    [_difficultButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    [_difficultButton setTag:SDGGameLevelDifficult];
}

/**
 * 进入游戏界面
 */
- (void)enterGame:(UIButton *)sender {
    GameViewController *gameViewController = [[GameViewController alloc] init];
    gameViewController.GameLevel = sender.tag;
    gameViewController.round = 1;
    [self.navigationController pushViewController:gameViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
