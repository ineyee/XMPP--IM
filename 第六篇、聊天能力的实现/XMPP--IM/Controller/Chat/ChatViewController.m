//
//  ChatViewController.m
//  XMPP--IM
//
//  Created by 意一yiyi on 2018/7/12.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatOutTableViewCell.h"
#import "ChatInTableViewCell.h"
#import "ChatOutImageTableViewCell.h"
#import "ChatInImageTableViewCell.h"
#import "ChatOutAudioTableViewCell.h"
#import "ChatInAudioTableViewCell.h"
#import "IMInputView.h"

@interface ChatViewController ()<XMPPStreamDelegate, UITableViewDataSource, UITableViewDelegate, IMInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *messageRecordArray;// 消息记录数组

@property (strong, nonatomic) IMInputView *imInputView;

@property (strong, nonatomic) UIImagePickerController *imgPickerController;
@property (assign, nonatomic) BOOL isPhotoAlbum;
@property (strong, nonatomic) UIImage *selectedImg;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.friendUser.vCardTemp.nickname;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.imInputView];
    self.messageRecordArray = [@[] mutableCopy];
    [self reloadMessageRecordWithAnimation:NO];
    
    // 设置代理
    [[ProjectXMPP sharedXMPP].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


#pragma mark - XMPPStreamDelegate

// 消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    
    NSLog(@"===========>消息发送成功");
    
    [self reloadMessageRecordWithAnimation:YES];
}

// 消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    
    NSLog(@"===========>消息发送失败：%@", error);
}

// 消息接收成功
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    
    NSLog(@"===========>消息接收成功");
    
    [self reloadMessageRecordWithAnimation:YES];
}


#pragma mark - IMInputViewDelegate

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.view.y = -keyboardHeight;
    
    // 但是tableView不能飞，它只需要把大小缩小就可以了，（64 + keyboardHeight）这个keyboardHeight是因为view向上移动了这么多，它得保持在界面内，所以相对来说要加这么个高度
    self.tableView.frame = CGRectMake(0, 64 + keyboardHeight, kScreenWidth, kScreenHeight - 64 - keyboardHeight - 54);
    // 滚动到最后一行
    if (self.messageRecordArray.count != 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageRecordArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionNone) animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // 恢复
    self.view.y = 0;
    self.tableView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 54);
}

- (void)textViewDidChangeHeight:(CGFloat)height {
    
    self.tableView.height -= height;
    // 滚动到最后一行
    if (self.messageRecordArray.count != 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageRecordArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionNone) animated:NO];
    }
}

- (void)didTapSendButton:(IMInputView *)imInputView message:(NSString *)message {
    
    // 发送文本消息
    [[ProjectXMPP sharedXMPP] sendTextMessage:message toFriend:self.friendUser.jid];
}

- (void)didTapMoreButton:(IMInputView *)imInputView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选取" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        self.isPhotoAlbum = YES;
        [self presentViewController:self.imgPickerController animated:YES completion:nil];
    }];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        self.isPhotoAlbum = NO;
        [self presentViewController:self.imgPickerController animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    [alertController addAction:videoAction];
    [alertController addAction:photoAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)recordDidEnd:(IMInputView *)imInputView audioData:(NSData *)data audioDuration:(CGFloat)duration {
    
    [[ProjectXMPP sharedXMPP] sendAudioMessage:data duration:duration toFriend:self.friendUser.jid];
}


#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (self.imgPickerController.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        
        if (self.imgPickerController.allowsEditing) {
            
            self.selectedImg = info[@"UIImagePickerControllerEditedImage"];
        }else {
            
            self.selectedImg = info[@"UIImagePickerControllerOriginalImage"];
        }
    }else if (self.imgPickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        if (self.imgPickerController.allowsEditing) {
            
            self.selectedImg = info[@"UIImagePickerControllerEditedImage"];
        }else {
            
            self.selectedImg = info[@"UIImagePickerControllerOriginalImage"];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[ProjectXMPP sharedXMPP] sendImageMessage:UIImageJPEGRepresentation(self.selectedImg, 0.5) toFriend:self.friendUser.jid];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messageRecordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageRecordArray[indexPath.row];
    
    if (message.isOutgoing) {// 发送

        if ([message.body isEqualToString:@"image"]) {// 图片
            
            ChatOutImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID_image_out forIndexPath:indexPath];
            cell.backgroundColor = kVCBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // 从本地拉取自己的电子名片，本地没有则会去服务端拉取，并存储在本地
            XMPPvCardTemp *myvCardTemp = [[ProjectXMPP sharedXMPP] fetchvCardTempForAccount:[UserModel currentUser].jid.user];
            cell.headImageView.image = [UIImage imageWithData:myvCardTemp.photo];
            cell.nicknameLabel.text = myvCardTemp.nickname;
            // 拿取消息的时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:message.timestamp];
            cell.timeLabel.text = dateString;
            cell.message = message;
            
            return cell;
        }else if ([message.body hasPrefix:@"audio"]) {// 音频
            
            ChatOutAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID_audio_out forIndexPath:indexPath];
            cell.backgroundColor = kVCBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // 从本地拉取自己的电子名片，本地没有则会去服务端拉取，并存储在本地
            XMPPvCardTemp *myvCardTemp = [[ProjectXMPP sharedXMPP] fetchvCardTempForAccount:[UserModel currentUser].jid.user];
            cell.headImageView.image = [UIImage imageWithData:myvCardTemp.photo];
            cell.nicknameLabel.text = myvCardTemp.nickname;
            // 拿取消息的时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:message.timestamp];
            cell.timeLabel.text = dateString;
            cell.message = message;
            
            return cell;
        }else {// 文本
            
            ChatOutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID_out forIndexPath:indexPath];
            cell.backgroundColor = kVCBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // 从本地拉取自己的电子名片，本地没有则会去服务端拉取，并存储在本地
            XMPPvCardTemp *myvCardTemp = [[ProjectXMPP sharedXMPP] fetchvCardTempForAccount:[UserModel currentUser].jid.user];
            cell.headImageView.image = [UIImage imageWithData:myvCardTemp.photo];
            cell.nicknameLabel.text = myvCardTemp.nickname;
            // 拿取消息的时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:message.timestamp];
            cell.timeLabel.text = dateString;
            // 拿取消息的内容
            cell.contentLabel.text = message.body;
            
            return cell;
        }
    }else {
        
        if ([message.body isEqualToString:@"image"]) {// 图片
            
            ChatInImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID_image_in forIndexPath:indexPath];
            cell.backgroundColor = kVCBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // 拿取好友列表界面传过来的好友电子名片
            cell.headImageView.image = [UIImage imageWithData:self.friendUser.vCardTemp.photo];
            cell.nicknameLabel.text = self.friendUser.vCardTemp.nickname;
            // 拿取消息的时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:message.timestamp];
            cell.timeLabel.text = dateString;
            cell.message = message;
            
            return cell;
        }else if ([message.body hasPrefix:@"audio"]) {// 音频
            
            ChatInAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID_audio_in forIndexPath:indexPath];
            cell.backgroundColor = kVCBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            // 拿取好友列表界面传过来的好友电子名片
            cell.headImageView.image = [UIImage imageWithData:self.friendUser.vCardTemp.photo];
            cell.nicknameLabel.text = self.friendUser.vCardTemp.nickname;
            // 拿取消息的时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:message.timestamp];
            cell.timeLabel.text = dateString;
            cell.message = message;
            
            return cell;
        }else {// 文本
            
            ChatInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID_in forIndexPath:indexPath];
            cell.backgroundColor = kVCBackgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // 拿取好友列表界面传过来的好友电子名片
            cell.headImageView.image = [UIImage imageWithData:self.friendUser.vCardTemp.photo];
            cell.nicknameLabel.text = self.friendUser.vCardTemp.nickname;
            // 拿取消息的时间
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:message.timestamp];
            cell.timeLabel.text = dateString;
            // 拿取消息的内容
            cell.contentLabel.text = message.body;
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageRecordArray[indexPath.row];
    
    if ([message.body isEqualToString:@"image"]) {// 图片
        
        return UITableViewAutomaticDimension;
    }else if ([message.body hasPrefix:@"audio"]) {// 音频
        
        return 40 + (10 + 40 + 10);
    }else {// 文本
        
        CGRect rect = [message.body boundingRectWithSize:CGSizeMake(kScreenWidth - 90, 10000) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
        CGFloat height = rect.size.height;
        
        if (height > (40 - 20)) {// 文本超过一行时，设置为文本的高度的高度
            
            return height + 20 + (10 + 40 + 10);
        }else {// 文本不足一行时，默认为一行的高度
            
            return 40 + (10 + 40 + 10);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.000001;
}


#pragma mark - action

- (void)reloadMessageRecordWithAnimation:(BOOL)flag {
    
    NSArray *fetchedObjects = [[ProjectXMPP sharedXMPP] fecthMessageRecordWithFriendJID:self.friendUser.jid];
    
    // 将聊天记录存进数组
    [self.messageRecordArray removeAllObjects];
    self.messageRecordArray = [NSMutableArray arrayWithArray:fetchedObjects];
    
    [self.tableView reloadData];
    
    if (self.messageRecordArray.count != 0) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 滚动到最后一行
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageRecordArray.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionNone) animated:flag];
        });
    }
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [self.imInputView.textView resignFirstResponder];
    }
}


#pragma mark - setter, getter

static NSString * const cellReuseID_in = @"cellReuseID_in";
static NSString * const cellReuseID_out = @"cellReuseID_out";
static NSString * const cellReuseID_image_in = @"cellReuseID_image_in";
static NSString * const cellReuseID_image_out = @"cellReuseID_image_out";
static NSString * const cellReuseID_audio_in = @"cellReuseID_audio_in";
static NSString * const cellReuseID_audio_out = @"cellReuseID_audio_out";
- (UITableView *)tableView {
    
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 54) style:(UITableViewStylePlain)];// 输入框的高度为54
        _tableView.backgroundColor = kVCBackgroundColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.dataSource = self;
        
        _tableView.delegate = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"ChatInTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID_in];
        [_tableView registerNib:[UINib nibWithNibName:@"ChatOutTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID_out];
        [_tableView registerNib:[UINib nibWithNibName:@"ChatInImageTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID_image_in];
        [_tableView registerNib:[UINib nibWithNibName:@"ChatOutImageTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID_image_out];
        [_tableView registerNib:[UINib nibWithNibName:@"ChatInAudioTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID_audio_in];
        [_tableView registerNib:[UINib nibWithNibName:@"ChatOutAudioTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID_audio_out];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        [_tableView addGestureRecognizer:tap];
    }
    
    return _tableView;
}

- (IMInputView *)imInputView {
    
    if (_imInputView == nil) {
        
        _imInputView = [[IMInputView alloc] init];
        _imInputView.delegate = self;
    }
    
    return _imInputView;
}

- (UIImagePickerController *)imgPickerController {
    
    if (_imgPickerController == nil) {
        
        _imgPickerController = [[UIImagePickerController alloc] init];
        _imgPickerController.delegate = self;
        _imgPickerController.allowsEditing = YES;// 这里有影响, 后需处理
        _imgPickerController.mediaTypes = @[@"public.image"];
    }
    
    if (self.isPhotoAlbum) {
        
        _imgPickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }else {
        
        _imgPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imgPickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        _imgPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    
    return _imgPickerController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
