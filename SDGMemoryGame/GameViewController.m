//
//  GameViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 16/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "GameViewController.h"
#define SDGMargin 5

@interface GameViewController ()

@property (nonatomic, assign)NSInteger sizeN; // N宫格
@property (nonatomic, strong)NSMutableArray *cardArray; // 卡片按钮数组

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 根据游戏难度设置棋局规模
    switch (_GameLevel) {
        case SDGGameLevelEasy:
            _sizeN = 4;
            break;
        case SDGGameLevelMedium:
            _sizeN = 6;
            break;
        case SDGGameLevelDifficult:
            _sizeN = 9;
            break;
        default:
            break;
    }
    
    // 数据初始化
    [self initData];
    
    // 初始化界面UI
    [self initUI];
}

- (void)initData {
    _cardArray = [[NSMutableArray alloc] initWithCapacity:(_sizeN * _sizeN)];
}

- (void)initUI {
    // 背景图片
    UIImageView *gameBackGround = [[UIImageView alloc] initWithFrame:self.view.frame];
    gameBackGround.image = [UIImage imageNamed:@"game_bg"];
    [self.view addSubview:gameBackGround];
    
    // 创建卡片
    [self createCards];
}

- (void)createCards {
    // card size
    int width = (SDGScreenWidth - SDGMargin * (_sizeN + 1)) / _sizeN;
    int height = (SDGScreenHeight - 64 - SDGMargin * (_sizeN + 1)) / _sizeN;
    
    for (int i = 0; i < _sizeN; i++) {
        for (int j = 0; j < _sizeN; j++) {
            int x = (j + 1) * SDGMargin + j * width;
            int y = 64 + (i + 1) * SDGMargin + i * height;
            UIButton *card = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [card setBackgroundImage:[UIImage imageNamed:@"card_empty"] forState:UIControlStateNormal];
            card.tag = i * _sizeN + j;
            [_cardArray addObject:card];
            [self.view addSubview:card];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
