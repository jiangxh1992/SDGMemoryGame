//
//  GameViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 16/2/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "GameViewController.h"
#import "SDGTransitionViewController.h"
#import "SDGImage.h"
#import "SDGButton.h"
#define SDGMargin 2     // 间隙
#define maxDelay 10     // 最大停顿时间
#define roundHeight 50  // 关卡标识高度

@interface GameViewController ()<UIAlertViewDelegate>

@property (nonatomic, assign)float delayDuration;             // 卡牌显示停顿时间(关卡越往后时间越短)
@property (nonatomic, assign)int sizeRow;                     // 宫格行数
@property (nonatomic, assign)int sizeCol;                     // 宫格列数
@property (nonatomic, assign)BOOL isTimer;                    // 是否在计时

@property (nonatomic, strong)NSMutableArray *cardArray;       // 卡片按钮数组
@property (nonatomic, strong)NSMutableArray *imageArray;      // 卡片图片数组
@property (nonatomic, strong)NSMutableArray *cardStack;       // 翻开的卡片按钮堆栈

@property (nonatomic, strong)UIButton *homeButton;            // home按钮
@property (nonatomic, strong)UILabel *timerItem;              // 计时标签
@property (nonatomic, strong)UIView *roundView;               // 关卡视图
@property (nonatomic, strong)UIImageView *roundImage;
@property (nonatomic, strong)UILabel *roundLabel;
@property (nonatomic, copy)NSString *textContent;             // 关卡文字内容
@property (nonatomic, strong)UIAlertView *backAlert;
@property (nonatomic, strong)UIAlertView *gameAlert;

@property (nonatomic, strong)NSTimer *timer;                  // 计时器
@property (nonatomic, assign)int secTimer;                    // 已用的秒数
@property (nonatomic, assign)int matchCount;                  // 匹配总数统计
@property (nonatomic, assign)int matchedCount;                // 匹配成功计数(用于判断游戏结束)
@property (nonatomic, assign)int limitTime;                   // 时间限制

@property (nonatomic, strong)dispatch_queue_t animationQueue; // 异步动画队列

@property (nonatomic, assign)BOOL isGameOver;                 // 游戏是否结束


@end

@implementation GameViewController

#pragma -mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 数据初始化
    [self initData];
    // 初始化界面UI
    [self initUI];
    // 播放背景音乐
    [SDGSoundPlayer playBackGroundMusic];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    float width = SDGScreenWidth < SDGScreenHeight ? SDGScreenWidth : SDGScreenHeight;
    float barHeight = SDGTopBarHeight;//isportrait ? SDGTopBarHeight : SDGTopBarHeight / 3 * 2;
    int maxSize = _sizeCol > _sizeRow ? _sizeCol : _sizeRow;
    if (_sizeRow == _sizeCol) ++maxSize;
    int btn_width = (width - SDGMargin * maxSize) / maxSize;
    int btn_height = btn_width;
    int gap_height = (SDGScreenHeight - barHeight -_sizeRow * (btn_height + SDGMargin) + SDGMargin) / 2;
    int gap_width = (SDGScreenWidth - _sizeCol * (btn_width + SDGMargin) + SDGMargin) / 2;
    
    // 返回按钮
    _homeButton.frame = CGRectMake(15, barHeight, barHeight, barHeight / 1.5);
    [_homeButton sizeToFit];
    // 指示视图
    _roundView.frame = CGRectMake(gap_width, barHeight + gap_height - btn_width * 2 /3, SDGScreenWidth - 2 * gap_width, gap_height);
    _roundImage.frame = CGRectMake(0, 0, btn_height / 2, btn_width / 2);
    // 关卡
    _roundLabel.frame = CGRectMake(_roundImage.frame.size.width + 5, 0, btn_width * 1.5, btn_height * 2 / 3);
    [_roundLabel adjustFontSizeToFillItsSize];
    // 计时器
    _timerItem.frame = CGRectMake(_roundView.frame.size.width - btn_width * 1.5, 0, btn_width, btn_height * 2 / 3);
    [_timerItem adjustFontSizeToFillItsSize];

    // 卡片尺寸位置
    for (int i = 0; i < _sizeRow; i++) {
        for (int j = 0; j < _sizeCol; j++) {
            int x = gap_width + j * SDGMargin + j * btn_width;
            int y = barHeight + gap_height + i * SDGMargin + i * btn_height;
            UIButton *card = _cardArray[i * _sizeCol + j];
            card.frame = CGRectMake(x, y, btn_width, btn_height);
        }
    }
}

#pragma -mark private instance methods
- (void)initData {
    // 1.根据游戏难度设置棋局规模
    switch (_GameLevel) {
        case SDGGameLevelEasy:
            _textContent = [NSString stringWithFormat:@"Easy: R%i", _round];
            _sizeRow = 3;
            _sizeCol = 4;
            _limitTime = limitTimeEasy - _round;
            break;
        case SDGGameLevelMedium:
            _textContent = [NSString stringWithFormat:@"Middle: R%i", _round];
            _sizeRow = 4;
            _sizeCol = 5;
            _limitTime = limitTimeMedium - _round;
            break;
        case SDGGameLevelDifficult:
            _textContent = [NSString stringWithFormat:@"Hard: R%i", _round];
            _sizeRow = 5;
            _sizeCol = 6;
            _limitTime = limitTimeHard - _round;
            break;
        default:
            break;
    }
    
    // 2. 根据关卡调整难度，卡片停顿的时间以及限制时间
    _delayDuration = (maxDelay - _round) / 3;

    // 3.变量初始化
    _matchCount = 0;
    _matchedCount = 0;
    _cardArray = [[NSMutableArray alloc] initWithCapacity:(_sizeRow * _sizeCol)];
    _imageArray = [[NSMutableArray alloc] initWithCapacity:(_sizeRow * _sizeCol)];
    _cardStack = [[NSMutableArray alloc] init];
    _secTimer = 0;
    _animationQueue = dispatch_queue_create("animation.memorygame.sdg", DISPATCH_QUEUE_CONCURRENT);
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    _isTimer = YES;
    _isGameOver = NO;
    
    // 4. 产生随机图片
    int randomStart = arc4random() % maxCardNumber;
    for (int i = 0; i <  _sizeRow * _sizeCol; i += 2) {
        int card_id = (randomStart + i/2) % maxCardNumber + 1;
        NSLog(@"card_id:%i",card_id);
        SDGImage *image1 = [[SDGImage alloc] init];
        image1.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%i", card_id]];
        image1.card_id = [NSString stringWithFormat:@"card_id_%i",i];
        
        SDGImage *image2 = [[SDGImage alloc] init];
        image2.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%i", card_id]];
        image2.card_id = [NSString stringWithFormat:@"card_id_%i",i];
        
        [_imageArray addObject:image1];
        [_imageArray addObject:image2];
    }
    // 打乱图片顺序
    for (int j = 0; j <  _sizeRow * _sizeCol; j++) {
        // 随机交换
        int random = arc4random() % (_sizeRow * _sizeCol);
        if(random == j) continue;
        [_imageArray exchangeObjectAtIndex:j withObjectAtIndex:random];
    }
    
    // 5. 预先初始化单例
    [SDGSoundPlayer Ins];
    [SDGAnimation Ins];
    [GameRecord Ins];
}

- (void)initUI {
    // 1. 返回按钮
    _homeButton = [SDGButton sdg_buttonWithText:@"< GIVE UP +_+" animation:YES];
    [_homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeButton];
    
    // 2. 关卡提醒视图
    _roundView = [[UIView alloc] init];
    [self.view addSubview:_roundView];
    // 2.1环图片
    _roundImage = [[UIImageView alloc] init];
    [_roundView addSubview:_roundImage];
    [_roundImage setImage:[UIImage imageNamed:@"round"]];
    // 2.2关卡
    _roundLabel = [[UILabel alloc] init];
    _roundLabel.text = _textContent;
    _roundLabel.textColor = SDGThemeColor;
    _roundLabel.font = SDGFont;
    [_roundView addSubview:_roundLabel];
    // 2.3计时标签
    _timerItem = [[UILabel alloc] init];
    _timerItem.text = @"";
    _timerItem.textAlignment = NSTextAlignmentRight;
    _timerItem.textColor = SDGThemeColor;
    _timerItem.font = SDGFont;
    [_roundView addSubview:_timerItem];
    
    // 3. 创建卡片
    [self createCards];
}

/**
 * 创建卡片
 */
- (void)createCards {
    // card size
    for (int i = 0; i < _sizeRow; i++) {
        for (int j = 0; j < _sizeCol; j++) {
            SDGButton *card = [SDGButton sdg_buttonWithCardBgName:@"card_back_normal" animation:NO];
            card.isDelaying = NO;
            [card addTarget:self action:@selector(cardSelected:) forControlEvents:UIControlEventTouchUpInside];
            card.tag = i * _sizeCol + j;
            [_cardArray addObject:card];
            [self.view addSubview:card];
        }
    }
}

/**
 * 按钮点击事件
 */
- (void) cardSelected:(SDGButton *)sender {
    // 禁止重复点击以及点击三张以上卡片
    if (sender.isSelected || _cardStack.count >= 3) return;
    
    // 翻开卡片
    [SDGSoundPlayer playSoundEffect:SDGSoundEffectIDOpenCard];
    sender.selected = YES;
    // 入栈
    [_cardStack addObject:sender];
    
    SDGButton *card1, *card2;
    if(_cardStack.count >=2) {
        card1 = [_cardStack objectAtIndex:0];
        card2 = [_cardStack objectAtIndex:1];
    }
    
    // 翻开动画
    dispatch_async(_animationQueue, ^{
        bool isTwoCard = (_cardStack.count == 2);
        // 1. 翻转90度
        dispatch_sync(dispatch_get_main_queue(), ^{
            [sender.layer addAnimation:[SDGAnimation animationFlip] forKey:@"animationRotate"];
        });
        [NSThread sleepForTimeInterval:AniDuration];
        // 2. 替换图片
        dispatch_sync(dispatch_get_main_queue(), ^{
            SDGImage *sdgImage = [_imageArray objectAtIndex:sender.tag];
            [sender setBackgroundImage:sdgImage.image forState:UIControlStateNormal];
        });
        [NSThread sleepForTimeInterval:AniDuration];
        
        // 游戏结束
        if (!_isTimer) return;
        
        if (isTwoCard) {
            _matchCount++; // 匹配次数
            if ([self isMatchedCard1:card1 card2:card2]) {
                // 当前两张匹配成功
                _matchedCount++;
                // 移除匹配成功的两张卡片
                [self removeCard1:card1 card2:card2];
                // 判断游戏结束
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (_matchedCount * 2 == _sizeRow * _sizeCol) {
                        SDGGameSate state = _round >= maxRound ? SDGGameSateSuccess : SDGGameSateNextRound;
                        [self gameOver:state];
                    };
                });
            }else{
                // 延时关闭显示的两张卡片
                card1.isDelaying = YES;
                card2.isDelaying = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (card2.selected && card1.selected) {
                        if (card1.isDelaying) {
                            [self closeCard:card1];
                        }
                        if (card2.isDelaying) {
                            [self closeCard:card2];
                            
                        }
                    }
                });
            }
        }

    });
    
    if (_cardStack.count == 3) {
        if(![self isMatchedCard1:card1 card2:card2]) {
            // 关闭前两张
            [self closeCard:card1];
            [self closeCard:card2];
        }
    }
    
}

/**
 * 判断
 */
- (bool)isMatchedCard1:(SDGButton *)card1 card2:(SDGButton*)card2 {
    // 判断是否匹配成功
    SDGImage *lastImage = [_imageArray objectAtIndex:card1.tag];
    SDGImage *currentImage = [_imageArray objectAtIndex:card2.tag];
    if ([lastImage.card_id isEqualToString:currentImage.card_id]) {
        return YES;
    }
    else {
        return NO;
    }
}

/**
 * 关闭卡片
 */
- (void)closeCard:(SDGButton *)sender {
    [_cardStack removeObject:sender];
    if (!sender.selected) return;
    sender.isDelaying = NO;
    [SDGSoundPlayer playSoundEffect:SDGSoundEffectIDCloseCard];
    sender.selected = NO;
    
    dispatch_async(_animationQueue, ^{
        // 1. 翻转90度
        dispatch_sync(dispatch_get_main_queue(), ^{
            [sender.layer addAnimation:[SDGAnimation animationFlip] forKey:@"animationRotate"];
        });
        [NSThread sleepForTimeInterval:AniDuration];
        // 2. 替换图片
        dispatch_sync(dispatch_get_main_queue(), ^{
            [sender setBackgroundImage:[UIImage imageNamed:@"card_back_normal"] forState:UIControlStateNormal];
        });
    });
}

/**
 * 匹配成功移除两张卡片
 */
- (void)removeCard1:(SDGButton *)card1 card2:(SDGButton*)card2{
    [_cardStack removeObject:card1];
    [_cardStack removeObject:card2];
    // 匹配成功音效
    [SDGSoundPlayer playSoundEffect:SDGSoundEffectIDCloseCard];
    // 隐藏匹配成功的卡片按钮
    card1.userInteractionEnabled = NO;
    card2.userInteractionEnabled = NO;
    // 移除动画
    dispatch_async(dispatch_get_main_queue(), ^{
        [card1.layer addAnimation:[SDGAnimation animationFade] forKey:@"animationFade"];
        [card2.layer addAnimation:[SDGAnimation animationFade] forKey:@"animationFade"];
    });
}

/**
 * 游戏结束
 */
- (void)gameOver:(SDGGameSate)gameState {
    _isTimer = NO;
    [_timer invalidate];
    _timer = nil;
    [NSThread sleepForTimeInterval:0.5];
    
    // 关闭背景音乐
    [SDGSoundPlayer stopBackGroundMusic];
    // 积分刷新
#warning 成绩结算
    // 去掉首次翻开的匹配次数不计
    _matchCount -= _sizeCol * _sizeRow / 2;
    // 纠正
    if (_matchCount <= _matchedCount) _matchCount = _matchedCount;
    // 本局成绩
    int curScore = (100 * _matchedCount / _matchCount) - (_secTimer / 10);
    // 最少得1分
    if (curScore <= 0) curScore = 1;
    // 成绩累加
    _score += curScore;
    
    [NSThread sleepForTimeInterval:1.0];
    // 跳转到过度界面
    SDGTransitionViewController *transVC = [[SDGTransitionViewController alloc] init];
    transVC.GameState = gameState;
    transVC.GameLevel = _GameLevel;
    transVC.round = _round;
    transVC.matchCount = _matchCount - _sizeRow * _sizeCol;
    transVC.rightCount = _matchedCount;
    transVC.timeUsed = _secTimer;
    transVC.score = _score;
    transVC.curScore = curScore;
    [self.navigationController pushViewController:transVC animated:YES];
}

/**
 * 回到主页面
 */
- (void)home {
    _isTimer = NO;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GIVE UP" message:@"Are you sure you want to give up the game？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
//    [alert show];
    [SDGSoundPlayer stopBackGroundMusic];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 * 定时刷新
 */
- (void)update {
    if (!_isTimer) return;
    _timerItem.text = [NSString stringWithFormat:@"%2d",_limitTime - _secTimer];
    _secTimer ++;
    
    // 游戏失败
    if(_isTimer && _secTimer >= _limitTime) {
        [self gameOver:SDGGameSateFailure];
    }
}

#pragma mark- AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            _isTimer = YES;
            break;
        case 1:
            [SDGSoundPlayer stopBackGroundMusic];
            [self.navigationController popToRootViewControllerAnimated:YES];
        default:
            break;
    }
}

@end
