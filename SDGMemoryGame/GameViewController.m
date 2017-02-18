//
//  GameViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 16/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "GameViewController.h"
#import <QuartzCore/CAAnimation.h>
#define SDGMargin 5 // 间隙
#define AniDuration 0.2 // 翻转动画持续时间

@interface GameViewController ()<CAAnimationDelegate>

@property (nonatomic, assign)float delayDuration; // 卡牌显示停顿时间
@property (nonatomic, assign)NSInteger sizeN; // N宫格
@property (nonatomic, strong)NSMutableArray *cardArray; // 卡片按钮数组
@property (nonatomic, strong)UIButton *currentButton;

@end

@implementation GameViewController

#pragma -mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SDG MEMORY GAME";
    
    // 根据游戏难度设置棋局规模
    switch (_GameLevel) {
        case SDGGameLevelEasy:
            _sizeN = 4;
            _delayDuration = 1.0;
            break;
        case SDGGameLevelMedium:
            _sizeN = 5;
            _delayDuration = 0.6;
            break;
        case SDGGameLevelDifficult:
            _sizeN = 7;
            _delayDuration = 0.4;
            break;
        default:
            break;
    }
    
    // 数据初始化
    [self initData];
    
    // 初始化界面UI
    [self initUI];
}


#pragma -mark instance methods
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

/**
 * 创建卡片
 */
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
            [card addTarget:self action:@selector(cardSelected:) forControlEvents:UIControlEventTouchUpInside];
            card.tag = i * _sizeN + j;
            [_cardArray addObject:card];
            [self.view addSubview:card];
        }
    }
}

/**
 * 翻转动画
 */
- (CAAnimation *)animationRotate {
    CATransform3D rotationTransform = CATransform3DMakeScale(0, 1, 1);//CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration = AniDuration;
    animation.repeatCount = 1;
    animation.delegate = self;
    return animation;
}

/**
 * 按钮点击事件
 */
- (void) cardSelected:(UIButton *)sender {
    // 当前卡片按钮
    _currentButton = sender;
    
    NSOperationQueue *aniQueue = [[NSOperationQueue alloc] init];
    [aniQueue addOperationWithBlock:^{
        // 启动翻转动画
        // 1. 翻转90度
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender.layer addAnimation:[self animationRotate] forKey:@"animationRotate"];
        });
        // 2. 替换图片
        [NSThread sleepForTimeInterval:AniDuration];
        int i = arc4random()%8 + 1; // 1..8
        NSString *imageName = [NSString stringWithFormat:@"card_%i", i];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        });
        
        // 卡片显示延迟
        [NSThread sleepForTimeInterval:_delayDuration];
        
        // 1. 翻转90度
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender.layer addAnimation:[self animationRotate] forKey:@"animationRotate"];
        });
        // 2. 替换图片
        [NSThread sleepForTimeInterval:AniDuration];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[UIImage imageNamed:@"card_empty"] forState:UIControlStateNormal];
        });
    }];
    
}

#pragma -mark CAAnimation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
}

@end
