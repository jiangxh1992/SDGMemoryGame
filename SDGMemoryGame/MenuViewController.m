//
//  MenuViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 17/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"
#import "SDGRankViewController.h"
#import "SDGButton.h"

@interface MenuViewController ()

// 按钮
@property (nonatomic, strong) SDGButton *rankButton;

@property (nonatomic, strong) SDGButton *easyButton;
@property (nonatomic, strong) SDGButton *mediumButton;
@property (nonatomic, strong) SDGButton *difficultButton;

@property (nonatomic, strong) SDGButton *easyRankButton;
@property (nonatomic, strong) SDGButton *mediumRankButton;
@property (nonatomic, strong) SDGButton *difficultRankButton;

@end

@implementation MenuViewController

#pragma -marks life-cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 1. 配置UI
    [self setUI];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    float width = SDGScreenWidth < SDGScreenHeight ? SDGScreenWidth : SDGScreenHeight;
    // 尺寸调整
    float button_width = width/2;
    float button_height = button_width/3;
    float centerX = self.view.center.x;
    float centerY = self.view.center.y;
    //_rankButton.frame = CGRectMake(0, 0, button_width, button_height);
    //_rankButton.center = CGPointMake(centerX, centerY - button_height - 20);
    // 进入游戏按钮
    
    _easyButton.frame = CGRectMake(0, 0, button_width, button_height);
    _easyButton.center = CGPointMake(centerX - button_height / 2, centerY);
    _mediumButton.frame = CGRectMake(0, 0, button_width, button_height);
    _mediumButton.center = CGPointMake(centerX - button_height / 2, _easyButton.center.y + button_height + 10);
    _difficultButton.frame = CGRectMake(0, 0, button_width, button_height);
    _difficultButton.center = CGPointMake(centerX - button_height / 2, _mediumButton.center.y + button_height + 10);
    // 排名按钮
    _easyRankButton.frame = CGRectMake(CGRectGetMaxX(_easyButton.frame), CGRectGetMinY(_easyButton.frame), button_height, button_height);
    _mediumRankButton.frame = CGRectMake(CGRectGetMaxX(_mediumButton.frame), CGRectGetMinY(_mediumButton.frame), button_height, button_height);
    _difficultRankButton.frame = CGRectMake(CGRectGetMaxX(_difficultButton.frame), CGRectGetMinY(_difficultButton.frame), button_height, button_height);
}

/**
 * 配置UI
 */
- (void)setUI {
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 按钮
    //_rankButton = [SDGButton sdg_buttonWithName:@"btn_ranking"];
    _easyButton = [SDGButton sdg_buttonWithName:@"btn_easy"];
    [_easyButton setTag:SDGGameLevelEasy];
    _mediumButton = [SDGButton sdg_buttonWithName:@"btn_medium"];
    [_mediumButton setTag:SDGGameLevelMedium];
    _difficultButton = [SDGButton sdg_buttonWithName:@"btn_difficult"];
    [_difficultButton setTag:SDGGameLevelDifficult];
    
    _easyRankButton = [SDGButton sdg_buttonWithName:@"btn_rank"];
    [_easyRankButton setTag:SDGGameLevelEasy];
    _mediumRankButton = [SDGButton sdg_buttonWithName:@"btn_rank"];
    [_mediumRankButton setTag:SDGGameLevelMedium];
    _difficultRankButton = [SDGButton sdg_buttonWithName:@"btn_rank"];
    [_difficultButton setTag:SDGGameLevelDifficult];
    // 添加按钮
    //[self.view addSubview:_rankButton];
    [self.view addSubview:_easyButton];
    [self.view addSubview:_mediumButton];
    [self.view addSubview:_difficultButton];
    [self.view addSubview:_easyRankButton];
    [self.view addSubview:_mediumRankButton];
    [self.view addSubview:_difficultButton];
    // 注册点击事件
    //[_rankButton addTarget:self action:@selector(enterRanking:) forControlEvents:UIControlEventTouchUpInside];
    
    [_easyButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    [_mediumButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    [_difficultButton addTarget:self action:@selector(enterGame:) forControlEvents:UIControlEventTouchUpInside];
    
    [_easyRankButton addTarget:self action:@selector(enterRanking:) forControlEvents:UIControlEventTouchUpInside];
    [_mediumRankButton addTarget:self action:@selector(enterRanking:) forControlEvents:UIControlEventTouchUpInside];
    [_difficultRankButton addTarget:self action:@selector(enterRanking:) forControlEvents:UIControlEventTouchUpInside];
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
- (void)enterRanking:(UIButton *)sender {
    SDGRankViewController *rankVC = [[SDGRankViewController alloc] init];
    rankVC.level = sender.tag;
    [self.navigationController pushViewController:rankVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
