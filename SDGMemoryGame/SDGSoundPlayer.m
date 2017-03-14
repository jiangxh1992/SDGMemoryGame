//
//  SDGSoundPlayer.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGSoundPlayer.h"

// 注册音效
// 定义sound的ID
static SystemSoundID card_open_sound_id = 0;
static SystemSoundID card_close_sound_id = 0;
static SystemSoundID card_matched_sound_id = 0;

@interface SDGSoundPlayer()

@property (nonatomic, strong)AVAudioPlayer *audioPlayer;      // 背景音乐播放器

@end
@implementation SDGSoundPlayer

- (id)init {
    if ([super init]) {
        [self registerSoundID];
    }
    return self;
}

#pragma -mark getters
- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        // 资源路径
        NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"bg" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:urlStr];
        
        // 初始化播放器，注意这里的Url参数只能为本地文件路径，不支持HTTP Url
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        
        //设置播放器属性
        _audioPlayer.numberOfLoops = -1;// 不循环
        _audioPlayer.volume = 0.5; // 音量
        [_audioPlayer prepareToPlay];// 加载音频文件到缓存【这个函数在调用play函数时会自动调用】
        
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

#pragma -mark private instance methods
- (void)registerSoundID {
    NSURL *fileUrl=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"open" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &card_open_sound_id);
    
    NSURL *fileUrl2=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"close" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl2), &card_close_sound_id);
}
/**
 * 系统声音资源注册函数
 */
- (void) registerSoundWithName: (NSString *)name andID:(SystemSoundID)sound_id {
    // 1.获取音频文件url
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    // 2.将音效文件加入到系统音频服务中并返回一个长整形ID
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &sound_id);
}


#pragma -mark public interfaces
+ (instancetype)Ins {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SDGSoundPlayer alloc] init];
    });
    return sharedInstance;
}
+ (void)playBackGroundMusic {
    [[SDGSoundPlayer Ins].audioPlayer play];
}
+ (void)stopBackGroundMusic {
    [[SDGSoundPlayer Ins].audioPlayer stop];
    [SDGSoundPlayer Ins].audioPlayer = nil;
}
+ (void)playSoundEffect:(NSUInteger)soundID {
    switch (soundID) {
        case SDGSoundEffectIDOpenCard:
            AudioServicesPlaySystemSound(card_open_sound_id);
            break;
        case SDGSoundEffectIDCloseCard:
            AudioServicesPlaySystemSound(card_close_sound_id);
        case SDGSoundEffectIDCardMatched:
            AudioServicesPlaySystemSound(card_matched_sound_id);
        default:
            break;
    }
}

@end
