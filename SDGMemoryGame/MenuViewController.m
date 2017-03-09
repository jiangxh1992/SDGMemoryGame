//
//  MenuViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 17/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"
#import "SDGButton.h"

@interface MenuViewController ()

// 背景图片
@property (nonatomic, strong)UIImageView *bgView;
// 按钮
@property (nonatomic, strong)SDGButton *easyButton;
@property (nonatomic, strong)SDGButton *mediumButton;
@property (nonatomic, strong)SDGButton *difficultButton;

@end

@implementation MenuViewController

#pragma -marks life-cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 配置UI
    [self setUI];
    
}

- (void)viewWillLayoutSubviews {
    
    float height = SDGScreenHeight > SDGScreenWidth ? SDGScreenHeight : SDGScreenWidth;
    float width = SDGScreenWidth < SDGScreenHeight ? SDGScreenWidth : SDGScreenHeight;
    
    // 尺寸调整
    float button_width = width/2;
    float button_height = button_width/3;
    _easyButton.frame = CGRectMake(0, 0, button_width, button_height);
    _easyButton.center = self.view.center;
    _mediumButton.frame = CGRectMake(0, 0, button_width, button_height);
    _mediumButton.center = CGPointMake(_easyButton.center.x, _easyButton.center.y + button_height + 10);
    _difficultButton.frame = CGRectMake(0, 0, button_width, button_height);
    _difficultButton.center = CGPointMake(_mediumButton.center.x, _mediumButton.center.y + button_height + 10);
    
    _bgView.frame = CGRectMake(0, 0, SDGScreenHeight * (width/height), SDGScreenHeight);
    _bgView.center = self.view.center;
}

/**
 * 配置UI
 */
- (void)setUI {
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];

    // 背景图片
    _bgView = [[UIImageView alloc] init];
    [_bgView setImage:[UIImage imageNamed:@"menu_bg"]];
    [self.view addSubview:_bgView];
    // ...
    
    // 按钮
    _easyButton = [SDGButton sdg_buttonWithName:@"btn_easy"];
    _mediumButton = [SDGButton sdg_buttonWithName:@"btn_medium"];
    _difficultButton = [SDGButton sdg_buttonWithName:@"btn_difficult"];
    // 添加按钮
    [self.view addSubview:_easyButton];
    [self.view addSubview:_mediumButton];
    [self.view addSubview:_difficultButton];
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
    gameViewController.score = 0;
    [self.navigationController pushViewController:gameViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
