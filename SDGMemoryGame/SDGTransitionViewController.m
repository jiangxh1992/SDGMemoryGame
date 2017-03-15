//
//  SDGTransitionViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 3/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGTransitionViewController.h"
#import "GameViewController.h"
#import "PlayerRecord.h"

@interface SDGTransitionViewController ()

@property (nonatomic, strong) UIButton *homeButton;            // home按钮
@property (nonatomic, strong) UIButton *nextButton;            // 下一关
@property (nonatomic, strong) UIButton *shareButton;           // 分享按钮
@property (nonatomic, strong) UILabel *rightRateLabel;         // 正确率标签
@property (nonatomic, strong) UILabel *timeUsedLabel;          // 已用时标签
@property (nonatomic, strong) UILabel *scoreLabel;             // 积分标签

@end

@implementation SDGTransitionViewController

#pragma -mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    if (_round >= maxRound) {
        [self newRecord];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    float width = SDGScreenWidth < SDGScreenHeight ? SDGScreenWidth : SDGScreenHeight;
    // 返回按钮
    _homeButton.frame = CGRectMake(15, SDGTopBarHeight, SDGTopBarHeight, SDGTopBarHeight / 1.5);
    int labelHeight = width / 5;
    //
    _timeUsedLabel.frame = CGRectMake(0, 0, SDGScreenWidth, labelHeight);
    _timeUsedLabel.center = CGPointMake(SDGScreenWidth / 2, SDGScreenHeight / 2 - labelHeight * 3 / 2);
    [_timeUsedLabel adjustFontSizeToFillItsSize];
    //
    _rightRateLabel.frame = CGRectMake(0, 0, SDGScreenWidth, labelHeight);
    _rightRateLabel.center = CGPointMake(SDGScreenWidth / 2, SDGScreenHeight / 2 - labelHeight / 2);
    [_rightRateLabel adjustFontSizeToFillItsSize];
    //
    _scoreLabel.frame = CGRectMake(0, 0, SDGScreenWidth, labelHeight);
    _scoreLabel.center = CGPointMake(SDGScreenWidth / 2, SDGScreenHeight / 2 + labelHeight / 2);
    [_scoreLabel adjustFontSizeToFillItsSize];
    
    // 下一关按钮
    _nextButton.frame = CGRectMake(0, 0, SDGScreenWidth, labelHeight);
    _nextButton.center = CGPointMake(SDGScreenWidth / 2, SDGScreenHeight - labelHeight);
    _nextButton.titleLabel.frame = _nextButton.frame;
    [_nextButton.titleLabel adjustFontSizeToFillItsSize];
    
    // 分享按钮
    _shareButton.frame = CGRectMake(SDGScreenWidth - labelHeight, SDGScreenHeight - labelHeight, labelHeight, labelHeight);
}

# pragma -mark private instance methods
- (void)setUI {
    
    // 返回按钮
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_homeButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeButton];
    
    // 已用时间
    _timeUsedLabel = [[UILabel alloc] init];
    _timeUsedLabel.text = [NSString stringWithFormat:@"TIME USED: %d min %ds", _timeUsed / 60, _timeUsed % 60];
    _timeUsedLabel.font = SDGFont;
    _timeUsedLabel.textColor = SDGThemeColor;
    _timeUsedLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeUsedLabel];
    
    // 正确率
    _rightRateLabel = [[UILabel alloc] init];
    int rate = _rightCount >= _matchCount ? 100 : _rightCount*100 / _matchCount;
    _rightRateLabel.text = [NSString stringWithFormat:@"ACCURATE RATE: %d%%", rate];
    _rightRateLabel.font = SDGFont;
    _rightRateLabel.textColor = SDGThemeColor;
    _rightRateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_rightRateLabel];
    
    // 积分
    _scoreLabel = [[UILabel alloc] init];
    _scoreLabel.text = [NSString stringWithFormat:@"SCORE: %d", _score];
    _scoreLabel.font = SDGFont;
    _scoreLabel.textColor = SDGThemeColor;
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_scoreLabel];
    
    // 下一关按钮
    _nextButton = [[UIButton alloc] init];
    NSString *text = _round >= maxRound ? @"HOME >" : @"NEXT ROUND >";
    [_nextButton setTitle:text forState:UIControlStateNormal];
    [_nextButton setTitleColor:SDGThemeColor forState:UIControlStateNormal];
    _nextButton.titleLabel.font = SDGFont;
    [_nextButton addTarget:self action:@selector(nextGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    
    // 分享按钮
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    _shareButton.layer.opacity = 0.6;
    [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    if (_round >= maxRound) {
        [self.view addSubview:_shareButton];
    }
}

- (void)nextGame {
    // 关底
    if (_round >= maxRound) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        GameViewController *nextGame = [[GameViewController alloc] init];
        nextGame.GameLevel = _GameLevel;
        nextGame.round = _round + 1;
        nextGame.score = _score;
        [self.navigationController pushViewController:nextGame animated:YES];
    }
}

- (void)home {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GIVE UP" message:@"Are you sure you want to give up？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alert.tag = SDGAlertViewTagBack;
    [alert show];
}

/**
 * 成功进入排行榜
 */
- (void)newRecord {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NEW RECORD!" message:@"Your score will be recorded, please leave your name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = SDGAlertViewTagRecord;
    [alert show];
}

/**
 * 添加新纪录
 */
- (void)saveRecordOfUser:(NSString *)name {
    NSLog(@"Name:%@ \n Score:%d", name, _score);
    PlayerRecord *newRecord = [[PlayerRecord alloc] init];
    newRecord.name = name;
    newRecord.score = _score;
    // 取出已有记录
    NSMutableArray *savedRecords = [GameRecord Ins].SavedRecord;
    if (!savedRecords) {
        savedRecords = [[NSMutableArray alloc] init];
    }
    // 添加新纪录
    [savedRecords addObject:newRecord];
    // 保存最新记录
    [GameRecord saveRecords:savedRecords];
}

/**
 * 社交分享
 */
- (void)share {
}

#pragma mark- AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SDGAlertViewTagBack) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [self.navigationController popToRootViewControllerAnimated:YES];
            default:
                break;
        }
    }else if (alertView.tag == SDGAlertViewTagRecord) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [self saveRecordOfUser:[alertView textFieldAtIndex:0].text];
                break;
            default:
                break;
        }
    }
}

@end
