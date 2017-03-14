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
    float height = SDGScreenHeight > SDGScreenWidth ? SDGScreenHeight : SDGScreenWidth;
    float width = SDGScreenWidth < SDGScreenHeight ? SDGScreenWidth : SDGScreenHeight;
    // 背景
    _bgView.frame = CGRectMake(0, 0, SDGScreenHeight * (width/height), SDGScreenHeight);
    _bgView.layer.opacity = 0.5;
    _bgView.center = self.view.center;
}

@end
