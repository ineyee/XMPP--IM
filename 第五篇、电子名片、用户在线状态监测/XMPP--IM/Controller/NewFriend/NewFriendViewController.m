//
//  NewFriendViewController.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/27.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "NewFriendViewController.h"
#import "NewFriendTableViewCell.h"

@interface NewFriendViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation NewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"新朋友";
    
    [self.view addSubview:self.tableView];
    
    // 收到好友申请的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFriendRequest:) name:@"DidReceiveFriendRequest" object:nil];
}

- (void)didReceiveFriendRequest:(NSNotification *)notification {
    
    [self.tableView reloadData];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidReceiveFriendRequest" object:nil];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [ProjectSingleton sharedSingleton].pre_newFriendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accountLabel.text = ((UserModel *)[ProjectSingleton sharedSingleton].pre_newFriendArray[indexPath.row]).jid.user;
    cell.acceptBlock = ^{
        
        // 同意好友申请
        [[ProjectXMPP sharedXMPP] acceptFriendRequestWithAccount:((UserModel *)[ProjectSingleton sharedSingleton].pre_newFriendArray[indexPath.row]).jid.user];
        
        [ProjectHUD showMBProgressHUDToView:kWindow withText:[NSString stringWithFormat:@"%@已成为您的好友", ((UserModel *)[ProjectSingleton sharedSingleton].pre_newFriendArray[indexPath.row]).jid.user] atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
            
            // 新朋友数组删除这条数据
            [[ProjectSingleton sharedSingleton].pre_newFriendArray removeObjectAtIndex:indexPath.row];
            // 刷新界面
            [self.tableView reloadData];
            
            // 发出同意了好友申请的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidAcceptFriendRequest" object:nil];
        }];
    };
    
    cell.rejectBlock = ^{
        
        // 拒绝好友申请
        [[ProjectXMPP sharedXMPP] rejectFriendRequestWithAccount:((UserModel *)[ProjectSingleton sharedSingleton].pre_newFriendArray[indexPath.row]).jid.user];

        [ProjectHUD showMBProgressHUDToView:kWindow withText:[NSString stringWithFormat:@"您拒绝了%@的好友请求", ((UserModel *)[ProjectSingleton sharedSingleton].pre_newFriendArray[indexPath.row]).jid.user] atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:^{
            
            // roster删除这条数据
            [[ProjectXMPP sharedXMPP] removeFriendWithAccount:((UserModel *)[ProjectSingleton sharedSingleton].pre_newFriendArray[indexPath.row]).jid.user];
            
            // 新朋友数组删除这条数据
            [[ProjectSingleton sharedSingleton].pre_newFriendArray removeObjectAtIndex:indexPath.row];
            // 刷新界面
            [self.tableView reloadData];
            
            // 发出同意了好友的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRejectFriendRequest" object:nil];
        }];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.000001;
}


#pragma mark - setter, getter

static NSString * const cellReuseID = @"cellReuseID";
- (UITableView *)tableView {
    
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:(UITableViewStylePlain)];
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"NewFriendTableViewCell" bundle:nil] forCellReuseIdentifier:cellReuseID];
    }
    
    return _tableView;
}

@end
