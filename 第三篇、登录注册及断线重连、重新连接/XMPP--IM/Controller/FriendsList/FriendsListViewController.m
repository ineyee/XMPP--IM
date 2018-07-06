//
//  FriendsListViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "FriendsListViewController.h"
#import "LoginViewController.h"

@interface FriendsListViewController ()

@end

@implementation FriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"好友列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:(UIBarButtonItemStylePlain) target:self action:@selector(logoutAction)];
}

- (void)logoutAction {

    // 退出登录
    [[ProjectXMPP sharedXMPP] logout];

    // 切换登录状态
    [kNSUserDefaults setBool:NO forKey:@"isLogin"];

    // 退出App
    [[UIApplication sharedApplication].keyWindow setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
