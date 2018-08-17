//
//  EditInfoViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/28.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController ()<XMPPvCardTempModuleDelegate>

@property (weak, nonatomic) IBOutlet UILabel *old_nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *old_headImageView;

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) UIImage *headImage;

@property (strong, nonatomic) UIAlertController *alertController;

@property (strong, nonatomic) XMPPvCardTemp *myvCardTemp;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的信息";
    
    // 拉取我的电子名片
    self.myvCardTemp = [[ProjectXMPP sharedXMPP] fetchvCardTempForAccount:[UserModel currentUser].jid.user];

    // 初始状态
    self.old_headImageView.image = [UIImage imageWithData:self.myvCardTemp.photo];
    self.old_nicknameLabel.text = self.myvCardTemp.nickname;
    
    // 设置代理
    [[ProjectXMPP sharedXMPP].vCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (IBAction)selectHeadImageAction:(id)sender {
    
    self.headImage = [UIImage imageNamed:[NSString stringWithFormat:@"headImage_%ld", ((UIButton *)sender).tag - 1000]];
    self.headImageView.image = self.headImage;
}

- (IBAction)editAction:(id)sender {
    
    self.alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"更新中，请稍候..." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:self.alertController animated:YES completion:nil];
    
    // 设置电子名片并上传到openfire服务器
    self.myvCardTemp.nickname = self.nicknameTextField.text;// 昵称
    self.myvCardTemp.photo = UIImageJPEGRepresentation(self.headImage, 0.618);// 头像
    [[ProjectXMPP sharedXMPP].vCardTempModule updateMyvCardTemp:self.myvCardTemp];
}


#pragma mark - XMPPvCardTempModuleDelegate

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    
    NSLog(@"===========>电子名片更新成功");
    
    self.alertController.message = @"修改成功!";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.alertController dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error {
    
    NSLog(@"===========>电子名片更新失败：%@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
