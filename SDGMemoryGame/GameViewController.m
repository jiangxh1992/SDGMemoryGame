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
#import "SDGSoundPlayer.h"
#import "GameRecord.h"
#import "SDGAnimation.h"
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

@property (nonatomic, strong)dispatch_queue_t animationQueue; // 异步动画队列


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
    int btn_height = btn_width;//(SDGScreenHeight - barHeight - SDGMargin * (_sizeRow + 1)) / _sizeRow;
    int gap_height = (SDGScreenHeight - barHeight -_sizeRow * (btn_height + SDGMargin) + SDGMargin) / 2;
    int gap_width = (SDGScreenWidth - _sizeCol * (btn_width + SDGMargin) + SDGMargin) / 2;
    
    // 返回按钮
    _homeButton.frame = CGRectMake(15, barHeight, barHeight, barHeight / 1.5);
    // 指示视图
    _roundView.frame = CGRectMake(gap_width, barHeight + gap_height - btn_width/2, SDGScreenWidth - 2 * gap_width, gap_height);
    _roundImage.frame = CGRectMake(0, 0, btn_height / 2, btn_width / 2);
    // 关卡
    _roundLabel.frame = CGRectMake(_roundImage.frame.size.width + 5, 0, btn_width * 1.5, btn_height / 2);
    [_roundLabel adjustFontSizeToFillItsSize];
    // 计时器
    _timerItem.frame = CGRectMake(_roundView.frame.size.width / 2, 0, btn_width * 2, btn_height / 2);
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
            break;
        case SDGGameLevelMedium:
            _textContent = [NSString stringWithFormat:@"Middle: R%i", _round];
            _sizeRow = 4;
            _sizeCol = 4;
            break;
        case SDGGameLevelDifficult:
            _textContent = [NSString stringWithFormat:@"Hard: R%i", _round];
            _sizeRow = 4;
            _sizeCol = 5;
            break;
        default:
            break;
    }
    
    // 2. 根据关卡调整难度，卡片停顿的时间
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
    
    // 4. 产生随机图片
    for (int i = 0; i <  _sizeRow * _sizeCol; i += 2) {
        SDGImage *image1 = [[SDGImage alloc] init];
        image1.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%i", i/2 + 1]];
        image1.card_id = [NSString stringWithFormat:@"card_id_%i",i];
        
        SDGImage *image2 = [[SDGImage alloc] init];
        image2.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%i", i/2 + 1]];
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
    // 0. 背景图片
    
    // 1. 返回按钮
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_homeButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
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
    _roundLabel.textColor = SDGRGBColor(71, 123, 186);
    _roundLabel.font = SDGFont;
    [_roundView addSubview:_roundLabel];
    // 2.3计时标签
    _timerItem = [[UILabel alloc] init];
    _timerItem.text = @"00:00";
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
            UIButton *card = [[UIButton alloc] initWithFrame:CGRectZero];
            [card setBackgroundImage:[UIImage imageNamed:@"card_back"] forState:UIControlStateNormal];
            card.layer.cornerRadius = 5;
            card.layer.borderWidth = 2;
            card.layer.borderColor = [UIColor whiteColor].CGColor;
            [card.layer setMasksToBounds:YES];
            card.layer.shadowOffset = CGSizeMake(1, 1);
            card.layer.shadowColor = [UIColor blackColor].CGColor;
            card.layer.shadowOpacity = 0.8;
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
- (void) cardSelected:(UIButton *)sender {
    if (sender.isSelected || _cardStack.count >= 3) return;
    // 显示卡片
    [self openCard:sender];
}

/**
 * 翻开卡片
 */
- (void)openCard: (UIButton *)sender {
    //[SDGSoundPlayer playSoundEffect:SDGSoundEffectIDOpenCard];
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
            [sender.layer addAnimation:[SDGAnimation animationFlip] forKey:@"animationRotate"];
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
    // 匹配次数
    _matchCount++;
    if (_cardStack.count < 2) return NO;
    // 判断是否匹配成功
    UIButton *lastButton = [_cardStack objectAtIndex:0];
    if (lastButton == sender) return NO;
    SDGImage *lastImage = [_imageArray objectAtIndex:lastButton.tag];
    SDGImage *currentImage = [_imageArray objectAtIndex:sender.tag];
    if ([lastImage.card_id isEqualToString:currentImage.card_id]) {
        // 匹配成功次数
        _matchedCount++;
        // 隐藏匹配成功的卡片按钮
        [_cardStack removeObject:sender];
        [_cardStack removeObject:lastButton];
        lastButton.userInteractionEnabled = NO;
        sender.userInteractionEnabled = NO;
        // 移除动画
        dispatch_async(dispatch_get_main_queue(), ^{
            [lastButton.layer addAnimation:[SDGAnimation animationFade] forKey:@"animationFade"];
            [sender.layer addAnimation:[SDGAnimation animationFade] forKey:@"animationFade"];
        });
        // 匹配成功音效
        [SDGSoundPlayer playSoundEffect:SDGSoundEffectIDCloseCard];
#warning "之类临时播放关闭音效，应该是匹配成功音效"
        // 判断游戏结束
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (_matchedCount * 2 == _sizeRow * _sizeCol) [self gameOver];
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
    if (!sender.selected) return;
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
            [sender setBackgroundImage:[UIImage imageNamed:@"card_back"] forState:UIControlStateNormal];
        });
    });
}

/**
 * 游戏结束
 */
- (void)gameOver {
    [NSThread sleepForTimeInterval:1.0];
    // 关闭背景音乐
    [SDGSoundPlayer stopBackGroundMusic];
    // 积分刷新
    _score += 100 * _matchedCount / _matchCount - _secTimer / 5;
    [NSThread sleepForTimeInterval:1.0];
    // 跳转到过度界面
    SDGTransitionViewController *transVC = [[SDGTransitionViewController alloc] init];
    transVC.GameLevel = _GameLevel;
    transVC.round = _round;
    transVC.matchCount = _matchCount - _sizeRow * _sizeCol;
    transVC.rightCount = _matchedCount;
    transVC.timeUsed = _secTimer;
    transVC.score = _score;
    [self.navigationController pushViewController:transVC animated:YES];
}

/**
 * 回到主页面
 */
- (void)home {
    _isTimer = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GIVE UP" message:@"Are you sure you want to give up the game？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alert show];
}

/**
 * 定时刷新
 */
- (void)update {
    if (!_isTimer) return;
    _secTimer ++;
    int seconds = _secTimer % 60;
    int mins = _secTimer / 60;
    _timerItem.text = [NSString stringWithFormat:@"%2d:%2d",mins,seconds];
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
