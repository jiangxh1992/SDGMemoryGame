//
//  SDGRankViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGRankViewController.h"
#import "SDGRankTableViewController.h"

@interface SDGRankViewController ()
@property (nonatomic, strong)UIButton *homeButton;            // home按钮
@end

@implementation SDGRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SDGRankTableViewController *ranktable = [[SDGRankTableViewController alloc] init];
    ranktable.dataSource = [GameRecord getRecordsOfGameLevel:_level];
    [self.view addSubview:ranktable.view];
    [self addChildViewController:ranktable];
    
    // 返回按钮
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_homeButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // 返回按钮
    _homeButton.frame = CGRectMake(15, SDGTopBarHeight / 2, SDGTopBarHeight, SDGTopBarHeight / 1.5);
}

/**
 * 回到主页面
 */
- (void)home {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
