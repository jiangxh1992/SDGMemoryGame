//
//  SDGRankViewController.m
//  SDGMemoryGame
//
//  Created by Xinhou Jiang on 14/3/17.
//  Copyright © 2017年 Xinhou Jiang. All rights reserved.
//

#import "SDGRankViewController.h"
#import "SDGRankTableViewController.h"
#import "SDGButton.h"

@interface SDGRankViewController ()
@property (nonatomic, strong) UIButton *homeButton;            // home按钮
@property (nonatomic, strong) UIImageView *nullView;           // 没有数据界面
@end

@implementation SDGRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 请求数据
    _dataSource = [GameRecord getRecordsOfGameLevel:_level];
    if (_dataSource.count > 0) {
        // 显示排名数据
        SDGRankTableViewController *ranktable = [[SDGRankTableViewController alloc] init];
        ranktable.dataSource = _dataSource;
        [self.view addSubview:ranktable.view];
        [self addChildViewController:ranktable];
    }
    else {
        _nullView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SDGScreenWidth/2, SDGScreenWidth / 2)];
        _nullView.center = self.view.center;
        [_nullView setImage:[UIImage imageNamed:@"null"]];
        [self.view addSubview:_nullView];
    }
    
    // 返回按钮
    _homeButton = [SDGButton sdg_buttonWithName:@"back"];
    [_homeButton.layer addAnimation:[SDGAnimation animationScale] forKey:@"animationScaleback"];
    [_homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [GameRecord saveRecords:_dataSource ofGameLevel:_level];
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
