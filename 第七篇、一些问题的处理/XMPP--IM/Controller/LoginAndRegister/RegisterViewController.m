//
//  RegisterViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "RegisterViewController.h"
#import "FriendsListViewController.h"

@interface RegisterViewController ()<XMPPStreamDelegate, XMPPvCardTempModuleDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) UIImage *headImage;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    
    // 设置代理
    [[ProjectXMPP sharedXMPP].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[ProjectXMPP sharedXMPP].vCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 这里移除掉代理，要不然这个界面存在的时候，别的界面做了事，这个界面也会触发回调
    [[ProjectXMPP sharedXMPP].stream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
}


#pragma mark - private methods

- (IBAction)selectHeadImageAction:(id)sender {
    
    self.headImage = [UIImage imageNamed:[NSString stringWithFormat:@"headImage_%ld", (long)(((UIButton *)sender).tag - 1000)]];
    self.headImageView.image = self.headImage;
}

- (IBAction)registerAction:(id)sender {
    
    [[ProjectXMPP sharedXMPP] registerWithAccount:self.accountTextField.text password:self.passwordTextField.text];
}


#pragma mark - XMPPStreamDelegate

// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    
    NSLog(@"===========>注册成功");
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"注册成功，上传电子名片中！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
        
        // 调用登录，在登录成功的回调里构建电子名片上传，直接在这里上传电子名片不能成功
        [[ProjectXMPP sharedXMPP] loginWithAccount:self.accountTextField.text password:self.passwordTextField.text];
    }];
}

// 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    
    NSLog(@"===========>注册失败：%@", error);
    if ([[[((DDXMLElement *)[error childAtIndex:1]) attributeForName:@"code"] stringValue] isEqualToString:@"409"]) {
        
        NSLog(@"已经注册");
    }else {
        
        [ProjectHUD showMBProgressHUDToView:kWindow withText:@"注册失败，请重试！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:nil];
    }
}

// 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    // 上线
    [[ProjectXMPP sharedXMPP] becomeAvailable];
    
    // 存储用户的一些信息
    UserModel *currentUser = [[UserModel alloc] init];
    currentUser.jid = [XMPPJID jidWithUser:self.accountTextField.text domain:kDomainName resource:kResource];
    currentUser.password = self.passwordTextField.text;
    [kNSUserDefaults yy_setComplexObject:currentUser forKey:@"currentUser"];
    
    // 切换登录状态
    [kNSUserDefaults setBool:YES forKey:@"isLogin"];
    
    // 创建一个电子名片对象，设置电子名片并上传到openfire服务器
    XMPPvCardTemp *myvCardTemp = [XMPPvCardTemp vCardTemp];
    myvCardTemp.nickname = self.nicknameTextField.text;// 昵称
    myvCardTemp.photo = UIImageJPEGRepresentation(self.headImage, 0.618);// 头像
    [[ProjectXMPP sharedXMPP] updateMyvCardTemp:myvCardTemp];
}


#pragma mark - XMPPvCardTempModuleDelegate

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"电子名片上传成功！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
        
        [[UIApplication sharedApplication].keyWindow setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[FriendsListViewController alloc] init]]];
        
        // 拉取好友列表
        [[ProjectXMPP sharedXMPP] fetchFriendsList];
    }];
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error {
    
    NSLog(@"===========>电子名片上传失败：%@", error);
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"电子名片上传失败，请重试！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
