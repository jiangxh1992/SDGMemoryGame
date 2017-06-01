//
//  SDGViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGViewController.h"

@interface SDGViewController ()
@property (nonatomic, strong)UIImageView *bgView;     // 背景图片
@end

@implementation SDGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    // 背景图片
    _bgView = [[UIImageView alloc] init];
    [_bgView setImage:[UIImage imageNamed:@"menu_bg"]];
    [self.view addSubview:_bgView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    float ratio = 0.72168; // 背景图片资源宽高比
    float dynamic_ratio = SDGScreenWidth/SDGScreenHeight; // 屏幕宽高比
    
    float height = 0;
    float width = 0;

    if (dynamic_ratio > ratio) {
        height = SDGScreenHeight;
        width = height * ratio;
    }else {
        width = SDGScreenWidth;
        height = width / ratio;
    }
    // 背景
    _bgView.frame = CGRectMake(0, 0, width, height);
    _bgView.layer.opacity = 0.5;
    _bgView.center = self.view.center;
}

@end
