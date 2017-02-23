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
#define SDGMargin 2     // 间隙
#define AniDuration 0.1 // 翻转动画持续时间
#define maxRound 9      // 最大关卡
#define maxDelay 10     // 最大停顿时间

@interface GameViewController ()

@property (nonatomic, assign)int matchedCount;                // 匹配成功计数(用于判断游戏结束)
@property (nonatomic, assign)float delayDuration;             // 卡牌显示停顿时间(关卡越往后时间越短)
@property (nonatomic, assign)int sizeN;                       // N宫格(难度越大规模越大)

@property (nonatomic, strong)NSMutableArray *cardArray;       // 卡片按钮数组
@property (nonatomic, strong)NSMutableArray *imageArray;      // 卡片图片数组
@property (nonatomic, strong)NSMutableArray *cardStack;       // 翻开的卡片按钮堆栈

@property (nonatomic, strong)UIImageView *gameBackGround;     // 背景图片
@property (nonatomic, strong)UILabel *textItem;               // 导航栏标签项
@property (nonatomic, strong)UILabel *timerItem;              // 计时标签
@property (nonatomic, copy)NSString *textContent;             // 关卡文字内容

@property (nonatomic, strong)dispatch_queue_t animationQueue; // 异步动画队列

@end

@implementation GameViewController

#pragma -mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"00:00";
    
    // 1.根据游戏难度设置棋局规模
    switch (_GameLevel) {
        case SDGGameLevelEasy:
            _textContent = [NSString stringWithFormat:@"Easy: R%i", _round];
            _sizeN = 4;
            break;
        case SDGGameLevelMedium:
            _textContent = [NSString stringWithFormat:@"Medium: R%i", _round];
            _sizeN = 6;
            break;
        case SDGGameLevelDifficult:
            _textContent = [NSString stringWithFormat:@"Difficult: R%i", _round];
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma -mark instance methods
- (void)initData {
    _matchedCount = 0;
    _cardArray = [[NSMutableArray alloc] initWithCapacity:(_sizeN * _sizeN)];
    _imageArray = [[NSMutableArray alloc] initWithCapacity:(_sizeN * _sizeN)];
    _cardStack = [[NSMutableArray alloc] init];
    _animationQueue = dispatch_queue_create("animation.memorygame.sdg", DISPATCH_QUEUE_CONCURRENT);
    
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
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
    // 1. 自定义导航栏
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SDGScreenWidth, SDGTopBarHeight)];
    navBar.backgroundColor = SDGRGBColor(196, 142, 64);
    [self.view addSubview:navBar];
    // 1.1 返回按钮
    UIButton *home = [[UIButton alloc] init];
    [home setTitle:@"Home" forState:UIControlStateNormal];
    [home sizeToFit];
    home.titleLabel.textColor = SDGRGBColor(68, 149, 211);
    home.center = CGPointMake(5 + home.frame.size.width/2, SDGTopBarHeight / 3 * 2);
    [home addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:home];
    // 1.2 计时标签
    _timerItem = [[UILabel alloc] init];
    _timerItem.text = @"00:00";
    [_timerItem sizeToFit];
    _timerItem.center = CGPointMake(SDGScreenWidth/2, SDGTopBarHeight / 3 * 2);
    [navBar addSubview:_timerItem];
    
    // 1.3 关卡
    _textItem = [[UILabel alloc] init];
    _textItem.text = _textContent;
    [_textItem sizeToFit];
    _textItem.center = CGPointMake(SDGScreenWidth - 5 - _textItem.frame.size.width/2, SDGTopBarHeight / 3 * 2);
    [navBar addSubview:_textItem];
    
    // 背景图片
    _gameBackGround = [[UIImageView alloc] initWithFrame:self.view.frame];
    _gameBackGround.image = [UIImage imageNamed:@"game_bg"];
    //[self.view addSubview:_gameBackGround];
    [self.view setBackgroundColor:SDGRGBColor(34, 83, 135)];
    
    // 创建卡片
    [self createCards];
}

/**
 * 创建卡片
 */
- (void)createCards {
    // card size
    int width = (SDGScreenWidth - (SDGMargin / 2) * (_sizeN + 1)) / _sizeN;
    int height = (SDGScreenHeight - SDGTopBarHeight - SDGMargin * (_sizeN + 1)) / _sizeN;
    
    for (int i = 0; i < _sizeN; i++) {
        for (int j = 0; j < _sizeN; j++) {
            int x = (j + 1) * SDGMargin + j * width;
            int y = SDGTopBarHeight + (i + 1) * SDGMargin + i * height;
            UIButton *card = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [card setBackgroundImage:[UIImage imageNamed:@"card_back"] forState:UIControlStateNormal];
            card.layer.cornerRadius = 5;
            card.layer.borderWidth = 2;
            card.layer.borderColor = [UIColor orangeColor].CGColor;
            [card.layer setMasksToBounds:YES];
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
    if (sender.isSelected || _cardStack.count >= 3) return;
    // 显示卡片
    [self openCard:sender];
}

/**
 * 翻开卡片
 */
- (void)openCard: (UIButton *)sender {
    sender.selected = YES;
    
    if (_cardStack.count == 2) {
        // 关闭前两张
        UIButton *card1 = [_cardStack objectAtIndex:0];
        [self closeCard:card1];
        UIButton *card2 = [_cardStack objectAtIndex:1];
        [self closeCard:card2];
        [_cardStack removeAllObjects];
    }
    // 入栈
    [_cardStack addObject:sender];
    dispatch_async(_animationQueue, ^{
        // 1. 翻转90度
        dispatch_sync(dispatch_get_main_queue(), ^{
            [sender.layer addAnimation:[self animationRotate] forKey:@"animationRotate"];
        });
        [NSThread sleepForTimeInterval:AniDuration];
        // 2. 替换图片
        dispatch_sync(dispatch_get_main_queue(), ^{
            SDGImage *sdgImage = [_imageArray objectAtIndex:sender.tag];
            [sender setBackgroundImage:sdgImage.image forState:UIControlStateNormal];
        });
        [NSThread sleepForTimeInterval:AniDuration];
        if ([self countResultAfterSender:sender]) return;
    });
}

/**
 * 判断
 */
- (bool)countResultAfterSender:(UIButton *)sender {
    if (_cardStack.count < 2) return NO;
    // 判断是否匹配成功
    UIButton *lastButton = [_cardStack objectAtIndex:0];
    if (lastButton == sender) return NO;
    SDGImage *lastImage = [_imageArray objectAtIndex:lastButton.tag];
    SDGImage *currentImage = [_imageArray objectAtIndex:sender.tag];
    if ([lastImage.card_id isEqualToString:currentImage.card_id]) {
        // 隐藏匹配成功的卡片按钮
        [_cardStack removeObject:sender];
        [_cardStack removeObject:lastButton];
        lastButton.userInteractionEnabled = NO;
        sender.userInteractionEnabled = NO;
        _matchedCount += 2;
        // 移除动画
        dispatch_async(dispatch_get_main_queue(), ^{
            [lastButton.layer addAnimation:[self animationFade] forKey:@"animationFade"];
            [sender.layer addAnimation:[self animationFade] forKey:@"animationFade"];
        });
        
        // 判断游戏结束
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (_matchedCount == _sizeN * _sizeN) [self gameOver];
        });
        return YES;
    }
    else {
        // 延时关闭显示的两张卡片
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (sender.selected && lastButton.selected) {
                [self closeCard:lastButton];
                [self closeCard:sender];
                [_cardStack removeObject:lastButton];
                [_cardStack removeObject:sender];
            }
        });
        return NO;
    }
}

/**
 * 关闭卡片
 */
- (void)closeCard:(UIButton *)sender {
    sender.selected = NO;
    dispatch_async(_animationQueue, ^{
        // 1. 翻转90度
        dispatch_sync(dispatch_get_main_queue(), ^{
            [sender.layer addAnimation:[self animationRotate] forKey:@"animationRotate"];
        });
        [NSThread sleepForTimeInterval:AniDuration];
        // 2. 替换图片
        dispatch_sync(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[UIImage imageNamed:@"card_back"] forState:UIControlStateNormal];
        });
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
        [self.navigationController pushViewController:nextGame animated:NO];
    }
}

- (void)home {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
