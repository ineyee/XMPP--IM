//
//  RegisterViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    
    // 将当前界面也设置成stream的代理
    [[ProjectXMPP sharedXMPP].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


#pragma mark - private methods

- (IBAction)registerAction:(id)sender {
    
    [[ProjectXMPP sharedXMPP] registerWithAccount:self.accountTextField.text password:self.passwordTextField.text];
}


#pragma mark - XMPPStreamDelegate

// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    
    NSLog(@"===========>注册成功");
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"恭喜你，注册成功！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

// 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"注册失败，请重试！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
