//
//  LoginViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "FriendsListViewController.h"

@interface LoginViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    
    // 将当前界面也设置成stream的代理
    [[ProjectXMPP sharedXMPP].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


#pragma mark - private methods

- (IBAction)loginAction:(id)sender {
    
    [[ProjectXMPP sharedXMPP] loginWithAccount:self.accountTextField.text password:self.passwordTextField.text];
}

- (IBAction)registerAction:(id)sender {
    
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}


#pragma mark - XMPPStreamDelegate

// 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    NSLog(@"===========>登录成功");
    
    // 上线
    [[ProjectXMPP sharedXMPP] becomeAvailable];
    
    // 存储用户的一些信息
    UserModel *currentUser = [[UserModel alloc] init];
    currentUser.jid = [XMPPJID jidWithUser:self.accountTextField.text domain:kDomainName resource:kResource];
    currentUser.password = self.passwordTextField.text;
    [kNSUserDefaults yy_setComplexObject:currentUser forKey:@"currentUser"];
    
    // 切换登录状态
    [kNSUserDefaults setBool:YES forKey:@"isLogin"];
    
    // 进入App
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"恭喜你，登录成功！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
        
        [[UIApplication sharedApplication].keyWindow setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[FriendsListViewController alloc] init]]];
    }];
}

// 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"登录失败，请重试！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
