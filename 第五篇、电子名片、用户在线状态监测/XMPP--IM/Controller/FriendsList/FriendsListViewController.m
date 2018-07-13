//
//  FriendsListViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "FriendsListViewController.h"
#import "LoginViewController.h"
#import "FriendsListTableViewCell.h"
#import "NewFriendViewController.h"
#import "EditInfoViewController.h"

@interface FriendsListViewController ()<UITableViewDataSource, UITableViewDelegate, XMPPRosterDelegate, UIAlertViewDelegate, XMPPvCardTempModuleDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UIButton *pre_newFriendButton;// 新朋友按钮

@property (assign, nonatomic) BOOL isRefreshing;// 是否在刷新好友列表

@end

@implementation FriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"好友列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"我的信息" style:(UIBarButtonItemStylePlain) target:self action:@selector(editInfo)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:(UIBarButtonItemStylePlain) target:self action:@selector(logoutAction)];
    
    [self.view addSubview:self.tableView];
    
    // 设置代理
    [[ProjectXMPP sharedXMPP].roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[ProjectXMPP sharedXMPP].vCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 收到好友申请的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFriendRequest:) name:@"DidReceiveFriendRequest" object:nil];
    // 同意好友申请的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAcceptFriendRequest:) name:@"DidAcceptFriendRequest" object:nil];
    // 拒绝好友申请的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRejectFriendRequest:) name:@"DidRejectFriendRequest" object:nil];
    // 好友上下线的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendIsAvailable:) name:@"FriendIsAvailable" object:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidReceiveFriendRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidAcceptFriendRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidRejectFriendRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FriendIsAvailable" object:nil];
}

- (void)didReceiveFriendRequest:(NSNotification *)notification {
    
    [self.pre_newFriendButton setTitle:[NSString stringWithFormat:@"新朋友（%ld）", [ProjectSingleton sharedSingleton].pre_newFriendArray.count] forState:(UIControlStateNormal)];
}

- (void)didAcceptFriendRequest:(NSNotification *)notification {
    
    if ([ProjectSingleton sharedSingleton].pre_newFriendArray.count == 0) {
        
        [self.pre_newFriendButton setTitle:@"新朋友" forState:(UIControlStateNormal)];
    }else {
        
        [self.pre_newFriendButton setTitle:[NSString stringWithFormat:@"新朋友（%ld）", [ProjectSingleton sharedSingleton].pre_newFriendArray.count] forState:(UIControlStateNormal)];
    }
    
    // 拉取好友列表会走在刷新之前的
    [self.tableView reloadData];
}

- (void)didRejectFriendRequest:(NSNotification *)notification {
    
    if ([ProjectSingleton sharedSingleton].pre_newFriendArray.count == 0) {
        
        [self.pre_newFriendButton setTitle:@"新朋友" forState:(UIControlStateNormal)];
    }else {
        
        [self.pre_newFriendButton setTitle:[NSString stringWithFormat:@"新朋友（%ld）", [ProjectSingleton sharedSingleton].pre_newFriendArray.count] forState:(UIControlStateNormal)];
    }
}

- (void)friendIsAvailable:(NSNotification *)notification {
    
    [[ProjectSingleton sharedSingleton].friendsListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([((UserModel *)obj).jid.user isEqualToString:((UserModel *)notification.object).jid.user]) {
            
            [[ProjectSingleton sharedSingleton].friendsListArray replaceObjectAtIndex:idx withObject:notification.object];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
        }
    }];
}


#pragma mark - XMPPRosterDelegate

// 开始获取好友列表
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    
    NSLog(@"===========>开始获取好友列表");
}

// 获取到一个好友
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    
    NSLog(@"===========>获取到一个好友：%@", item);
    
    // 我们这里只获取双向好友和自己的单向好友
    NSString *subscription = [[item attributeForName:@"subscription"] stringValue];
    if ([subscription isEqualToString:@"both"]) {
    
        // 获取好友的jid
        NSString *friendJidString = [[item attributeForName:@"jid"] stringValue];
        XMPPJID *friendJid = [XMPPJID jidWithString:friendJidString];
        
        if (self.isRefreshing) {// 如果是刷新好友列表，则采用不带回调的版本，在回调里处理
            
            [[ProjectXMPP sharedXMPP] fetchvCardTempWithCallbackForAccount:friendJid.user];
        }else {// 如果是刷新好友列表，通常状况，则采用不带回调的版本，优先拉取用户本地的电子名片
            
            // 构建userModel
            UserModel *tempUser = [[UserModel alloc] init];
            tempUser.jid = friendJid;
            
            XMPPvCardTemp *vCardTemp = [[ProjectXMPP sharedXMPP] fetchvCardTempForAccount:tempUser.jid.user];
            tempUser.vCardTemp = vCardTemp;
            
            // 因为这个代理方法经常会被触发，比如添加、删除好友都会触发这个代理，因此这里就可能对同一个好友拉取多次，所以为了避免好友重复，要判断一下
            for (UserModel *tempUser1 in [ProjectSingleton sharedSingleton].friendsListArray) {
                
                if ([tempUser1.jid.user isEqualToString:tempUser.jid.user]) {
                    
                    return;
                }
            }
            
            // 不存在则添加
            [[ProjectSingleton sharedSingleton].friendsListArray addObject:tempUser];
            [self.tableView reloadData];
        }
    }
    
    // 删除好友
    if ([subscription isEqualToString:@"remove"]) {
        
        // 获取好友的jid
        NSString *friendJidString = [[item attributeForName:@"jid"] stringValue];
        XMPPJID *friendJid = [XMPPJID jidWithString:friendJidString];
        
        // 构建userModel
        UserModel *tempUser = [[UserModel alloc] init];
        tempUser.jid = friendJid;
        
        [[ProjectSingleton sharedSingleton].friendsListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([((UserModel *)obj).jid.user isEqualToString:tempUser.jid.user]) {
                
                [[ProjectSingleton sharedSingleton].friendsListArray removeObjectAtIndex:idx];
                [self.tableView reloadData];
            }
        }];
    }
}

// 获取好友列表结束
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    
    NSLog(@"===========>获取好友列表结束");
    
    [self.tableView reloadData];
}


#pragma mark - XMPPvCardTempModuleDelegate

// 拉取到电子名片的回调
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid {

    NSLog(@"===========>获取电子名片成功");

    if ([jid.user isEqualToString:[UserModel currentUser].jid.user]) {// 拉取到自己的电子名片


    }else {// 拉取到好友的电子名片

        // 这里代表是刷新，直接替换掉好友的电子名片
        for (UserModel *tempModel in [ProjectSingleton sharedSingleton].friendsListArray) {

            if ([tempModel.jid.user isEqualToString:jid.user]) {

                tempModel.vCardTemp = vCardTemp;
                
                // 置位
                self.isRefreshing = NO;
                
                [self.tableView reloadData];
            }
        }
    }
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [ProjectSingleton sharedSingleton].friendsListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.myFriend = [ProjectSingleton sharedSingleton].friendsListArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.000001;
}


#pragma mark - 左滑删除好友

// 第一步 : 确定可编辑区域
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

// 第二步 : 设定编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

// 第三步 : 完成编辑
// 删除的话, 可以直接通过左滑进入, 也可以通过 self.tableView.editing = YES; 进入编辑状态, 添加的话只能通过 self.tableView.editing = YES; 进入编辑状态
// 只要实现了该方法, 向左滑动的时候就能显示出删除来, 点击删除操作就会触发该方法
// 点击添加操作也会触发该方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 删除roster的好友
    [[ProjectXMPP sharedXMPP] removeFriendWithAccount:((UserModel *)[ProjectSingleton sharedSingleton].friendsListArray[indexPath.row]).jid.user];
}


#pragma mark - action

- (void)logoutAction {

    // 移除好友列表数据
    [[ProjectSingleton sharedSingleton].friendsListArray removeAllObjects];
    
    // 退出登录
    [[ProjectXMPP sharedXMPP] logout];

    // 切换登录状态
    [kNSUserDefaults setBool:NO forKey:@"isLogin"];

    // 退出App
    [[UIApplication sharedApplication].keyWindow setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]]];
}

- (void)editInfo {
    
    EditInfoViewController *editInfoVC = [[EditInfoViewController alloc] init];
    [self.navigationController pushViewController:editInfoVC animated:YES];
}

- (void)newFriendAction:(UIButton *)button {
    
    NewFriendViewController *newFriendVC = [[NewFriendViewController alloc] init];
    [self.navigationController pushViewController:newFriendVC animated:YES];
}

- (void)addFriendAction:(UIButton *)button {
    
    UIAlertView *alret = [[UIAlertView alloc] initWithTitle:@"添加好友"  message:@"请输入好友名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alret.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alret show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {// 添加
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if ([textField.text isEqualToString:[UserModel currentUser].jid.user]) {// 不能添加自己为好友
            
            [ProjectHUD showMBProgressHUDToView:kWindow withText:@"不能添加自己为好友！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
                
                return;
            }];
        }
        
        for (UserModel *model in [ProjectSingleton sharedSingleton].friendsListArray) {// 如果对方已经是自己的好友，不能再次添加
            
            if ([model.jid.user isEqualToString:textField.text] && [model.jid.domain isEqualToString:kDomainName]) {
                
                [ProjectHUD showMBProgressHUDToView:kWindow withText:@"对方已经是您的好友！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
                    
                    return;
                }];
            }
        }
        
        for (UserModel *model in [ProjectSingleton sharedSingleton].pre_newFriendArray) {// 对方正在向自己申请好友，则不能发起申请
            
            if ([model.jid.user isEqualToString:textField.text] && [model.jid.domain isEqualToString:kDomainName]) {
                
                [ProjectHUD showMBProgressHUDToView:kWindow withText:@"对方已发起好友申请，请确认！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
                    
                    return;
                }];
            }
        }
        
        // 添加好友
        [[ProjectXMPP sharedXMPP] addFriendWithAccount:textField.text];
    }
}

- (void)refreshDataAction:(UIButton *)button {
    
    self.isRefreshing = YES;
    [[ProjectXMPP sharedXMPP].roster fetchRoster];
}


#pragma mark - setter, getter

static NSString * const cellReuseID = @"cellReuseID";
- (UITableView *)tableView {
    
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:(UITableViewStyleGrouped)];
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"FriendsListTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID];
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    
    return _tableView;
}

- (UIView *)tableHeaderView {
    
    if (_tableHeaderView == nil) {
        
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        _tableHeaderView.backgroundColor = [UIColor grayColor];
        
        self.pre_newFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3.0, 44)];
        self.pre_newFriendButton.backgroundColor = [UIColor lightGrayColor];
        [self.pre_newFriendButton setTitle:@"新朋友" forState:(UIControlStateNormal)];
        [self.pre_newFriendButton addTarget:self action:@selector(newFriendAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_tableHeaderView addSubview:self.pre_newFriendButton];
        
        UIButton *addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 3.0 + 1, 0, [UIScreen mainScreen].bounds.size.width / 3.0, 44)];
        addFriendButton.backgroundColor = [UIColor lightGrayColor];
        [addFriendButton setTitle:@"添加好友" forState:(UIControlStateNormal)];
        [addFriendButton addTarget:self action:@selector(addFriendAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_tableHeaderView addSubview:addFriendButton];
        
        UIButton *refreshDataButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 3.0 * 2 + 2, 0, [UIScreen mainScreen].bounds.size.width / 3.0, 44)];
        refreshDataButton.backgroundColor = [UIColor lightGrayColor];
        [refreshDataButton setTitle:@"刷新列表" forState:(UIControlStateNormal)];
        [refreshDataButton addTarget:self action:@selector(refreshDataAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_tableHeaderView addSubview:refreshDataButton];
    }
    
    return _tableHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
