//
//  GameViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 16/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "GameViewController.h"
#import "SDGImage.h"
#import <QuartzCore/CAAnimation.h>
#define SDGMargin 5     // 间隙
#define AniDuration 0.1 // 翻转动画持续时间
#define maxRound 9       // 最大关卡
#define maxDelay 10     // 最大停顿时间

@interface GameViewController ()

@property (nonatomic, assign)int matchedCount;             // 匹配成功计数
@property (nonatomic, assign)float delayDuration;          // 卡牌显示停顿时间(关卡越往后时间越短)
@property (nonatomic, assign)int sizeN;                    // N宫格(难度越大规模越大)
@property (nonatomic, strong)NSMutableArray *cardArray;    // 卡片按钮数组
@property (nonatomic, strong)NSMutableArray *imageArray;   // 卡片图片数组
@property (nonatomic, strong)NSMutableArray *cardStack;    // 翻开的卡片按钮堆栈
@property (nonatomic, strong)UIImageView *gameBackGround;  // 背景图片

@end

@implementation GameViewController

#pragma -mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.根据游戏难度设置棋局规模
    switch (_GameLevel) {
        case SDGGameLevelEasy:
            self.title = [NSString stringWithFormat:@"Easy Round %i", _round];
            _sizeN = 4;
            break;
        case SDGGameLevelMedium:
            self.title = [NSString stringWithFormat:@"Medium Round %i", _round];
            _sizeN = 6;
            break;
        case SDGGameLevelDifficult:
            self.title = [NSString stringWithFormat:@"Difficult Round %i", _round];
            _sizeN = 8;
            break;
        default:
            break;
    }
    
    // 2. 根据关卡调整难度，卡片停顿的时间
    _delayDuration = maxDelay - _round;
    
    // 数据初始化
    [self initData];
    
    // 初始化界面UI
    [self initUI];
    
    // 注册屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma -mark instance methods
- (void)initData {
    _matchedCount = 0;
    _cardArray = [[NSMutableArray alloc] initWithCapacity:(_sizeN * _sizeN)];
    _imageArray = [[NSMutableArray alloc] initWithCapacity:(_sizeN * _sizeN)];
    _cardStack = [[NSMutableArray alloc] init];
    
    // 产生随机图片
    for (int i = 0; i <  _sizeN * _sizeN; i += 2) {
        SDGImage *image1 = [[SDGImage alloc] init];
        image1.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%i", i/2+1]];
        image1.card_id = [NSString stringWithFormat:@"card_id_%i",i];
        
        SDGImage *image2 = [[SDGImage alloc] init];
        image2.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%i", i/2+1]];
        image2.card_id = [NSString stringWithFormat:@"card_id_%i",i];
        
        [_imageArray addObject:image1];
        [_imageArray addObject:image2];
    }
    
    for (int j = 0; j <  _sizeN*_sizeN; j++) {
        // 随机交换
        int random = arc4random() % (_sizeN * _sizeN);
        if(random == j) continue;
        [_imageArray exchangeObjectAtIndex:j withObjectAtIndex:random];
    }
}

- (void)initUI {
    // 背景图片
    _gameBackGround = [[UIImageView alloc] initWithFrame:self.view.frame];
    _gameBackGround.image = [UIImage imageNamed:@"game_bg"];
    [self.view addSubview:_gameBackGround];
    
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

/**
 * 按钮点击事件
 */
- (void) cardSelected:(UIButton *)sender {
    if (sender.isSelected || _cardStack.count >=3) return;
    NSOperationQueue *aniQueue = [[NSOperationQueue alloc] init];
    [aniQueue addOperationWithBlock:^{
        // 显示卡片
        [self openCard:sender];
        // 卡片显示延迟
        [NSThread sleepForTimeInterval:_delayDuration];
        // 关闭卡片
        if (sender && sender.isSelected) {
            [self closeCard:sender];
        }
    }];
    
}

- (void)openCard: (UIButton *)sender {
    // 1. 翻转90度
    dispatch_async(dispatch_get_main_queue(), ^{
        [sender.layer addAnimation:[self animationRotate] forKey:@"animationRotate"];
    });
    // 2. 替换图片
    [NSThread sleepForTimeInterval:AniDuration];
    dispatch_async(dispatch_get_main_queue(), ^{
        SDGImage *sdgImage = [_imageArray objectAtIndex:sender.tag];
        [sender setBackgroundImage:sdgImage.image forState:UIControlStateNormal];
    });
    [NSThread sleepForTimeInterval:AniDuration];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.selected = YES;
        // 入栈
        [_cardStack addObject:sender];

        // 判断是否匹配成功
        if (_cardStack.count == 2) {
            UIButton *lastButton = [_cardStack objectAtIndex:0];
            SDGImage *lastImage = [_imageArray objectAtIndex:lastButton.tag];
            SDGImage *currentImage = [_imageArray objectAtIndex:sender.tag];
            if ([lastImage.card_id isEqualToString:currentImage.card_id]) {
                // 隐藏匹配成功的卡片按钮
                [_cardStack removeObject:lastButton];
                [lastButton.layer addAnimation:[self animationFade] forKey:@"animationFade"];
                [sender.layer addAnimation:[self animationFade] forKey:@"animationFade"];
                //[lastButton setHidden:YES];
                //[sender setHidden:YES];
                _matchedCount += 2;
                
                // 判断游戏结束
                if (_matchedCount == _sizeN * _sizeN) [self gameOver];
            }
        }
        else if (_cardStack.count == 3) {
            UIButton *card1 = [_cardStack objectAtIndex:0];
            UIButton *card2 = [_cardStack objectAtIndex:1];
            [self closeCard:card1];
            [self closeCard:card2];
        }
    });
}

/**
 * 关闭卡片
 */
- (void)closeCard: (UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        sender.selected = NO;
        // 出栈
        [_cardStack removeObject:sender];
    });
    // 1. 翻转90度
    dispatch_async(dispatch_get_main_queue(), ^{
        [sender.layer addAnimation:[self animationRotate] forKey:@"animationRotate"];
    });
    // 2. 替换图片
    [NSThread sleepForTimeInterval:AniDuration];
    dispatch_async(dispatch_get_main_queue(), ^{
        [sender setBackgroundImage:[UIImage imageNamed:@"card_empty"] forState:UIControlStateNormal];
    });

}

/**
 * 游戏结束
 */
- (void)gameOver {
    // 关底
    if (_round >= maxRound) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        GameViewController *nextGame = [[GameViewController alloc] init];
        nextGame.GameLevel = _GameLevel;
        nextGame.round = _round + 1;
        [self.navigationController pushViewController:nextGame animated:YES];
    }
}

/**
 * 屏幕旋转
 */
- (void)deviceChanged {
    _gameBackGround.frame = self.view.frame;
    
    // card size
    int width = (SDGScreenWidth - SDGMargin * (_sizeN + 1)) / _sizeN;
    int height = (SDGScreenHeight - 64 - SDGMargin * (_sizeN + 1)) / _sizeN;
    
    for (int i = 0; i < _sizeN; i++) {
        for (int j = 0; j < _sizeN; j++) {
            int x = (j + 1) * SDGMargin + j * width;
            int y = 64 + (i + 1) * SDGMargin + i * height;
            int index = i * _sizeN + j;
            UIButton *card = [_cardArray objectAtIndex:index];
            card.frame = CGRectMake(x, y, width, height);
        }
    }
    
    [self.view setNeedsLayout];
}

@end
