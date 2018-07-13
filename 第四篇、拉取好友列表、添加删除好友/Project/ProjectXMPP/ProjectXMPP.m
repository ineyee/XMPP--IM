//
//  ProjectXMPP.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "ProjectXMPP.h"

typedef NS_ENUM(NSUInteger, ConnectToServerPurpose) {
    
    ConnectToServerPurposeLogin,
    ConnectToServerPurposeRegister
};

@interface ProjectXMPP ()<XMPPStreamDelegate>

// 登录密码
@property (strong, nonatomic) NSString *loginPassword;
// 注册密码
@property (strong, nonatomic) NSString *registerPassword;
// 连接服务端的目的
@property (assign, nonatomic) ConnectToServerPurpose connectToServerPurpose;

@end

@implementation ProjectXMPP

#pragma mark - 单例

static ProjectXMPP *xmpp = nil;
+ (instancetype)sharedXMPP {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        xmpp = [[ProjectXMPP alloc] init];
    });
    
    return xmpp;
}

- (instancetype)init {
    
    @synchronized(xmpp) {
        
        self = [super init];
        if (self != nil) {
            
            // 创建stream
            self.stream = [[XMPPStream alloc] init];
            // 设置服务器IP地址
            self.stream.hostName = kHostName;
            // 设置服务器端口号
            self.stream.hostPort = kHostPort;
            // 设置stream的代理
            [self.stream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
            
            
            // 自动重连
            self.reconnect = [[XMPPReconnect alloc] init];
            [self.reconnect activate:self.stream];
            
            
            // 好友相关
            self.rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
            self.roster = [[XMPPRoster alloc] initWithRosterStorage:self.rosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
            // 将roster在stream中激活
            [self.roster activate:self.stream];
            // 关闭自动拉取好友列表功能，我们可以根据业务在适当的时机自己拉取好友列表
            self.roster.autoFetchRoster = NO;
        }
        
        return self;
    }
}


#pragma mark - 登录

- (void)loginWithAccount:(NSString *)account password:(NSString *)password {
    
    // 记录登录密码
    self.loginPassword = password;
    
    // 记录连接服务端的目的
    self.connectToServerPurpose = ConnectToServerPurposeLogin;
    
    // 连接服务器
    [self connectToServerWithAccount:account];
}

- (void)logout {
    
    // 下线
    [self becomeUnavailable];
    
    // 断开连接
    [self.stream disconnect];
}

- (void)becomeAvailable {
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"availabel"];
    [self.stream sendElement:presence];
}

- (void)becomeUnavailable {
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailabel"];
    [self.stream sendElement:presence];
}


#pragma mark - 注册

- (void)registerWithAccount:(NSString *)account password:(NSString *)password {
    
    // 记录注册密码
    self.registerPassword = password;
    
    // 记录连接服务端的目的
    self.connectToServerPurpose = ConnectToServerPurposeRegister;
    
    // 连接服务端
    [self connectToServerWithAccount:account];
}


#pragma mark - 好友

- (void)fetchFriendsList {
    
    [self.roster fetchRoster];
}

- (void)addFriendWithAccount:(NSString *)account {
    
    XMPPJID *friendJID = [XMPPJID jidWithUser:account domain:kDomainName resource:kResource];
    
    // 添加好友：根据给定的账户名，把对方用户添加到自己的好友列表中，并且申请订阅对方用户的在线状态
    [self.roster addUser:friendJID withNickname:account];
}

- (void)removeFriendWithAccount:(NSString *)account {
    
    XMPPJID *friendJID = [XMPPJID jidWithUser:account domain:kDomainName resource:kResource];
    
    // 删除好友：从好友列表中删除对方用户，并且取消订阅对方用户的在线状态，同时取消对方用户对我们自己在线状态的订阅（如果对方设置允许这样的话）
    [self.roster removeUser:friendJID];
}

- (void)acceptFriendRequestWithAccount:(NSString *)account {
    
    XMPPJID *friendJID = [XMPPJID jidWithUser:account domain:kDomainName resource:kResource];
    [self.roster subscribePresenceToUser:friendJID];
    [self.roster acceptPresenceSubscriptionRequestFrom:friendJID andAddToRoster:YES];
}

- (void)rejectFriendRequestWithAccount:(NSString *)account {
    
    XMPPJID *friendJID = [XMPPJID jidWithUser:account domain:kDomainName resource:kResource];
    [self.roster unsubscribePresenceFromUser:friendJID];
    [self.roster rejectPresenceSubscriptionRequestFrom:friendJID];
}


#pragma mark - private methods

// 连接服务端
- (void)connectToServerWithAccount:(NSString *)account {
    
    // 如果已连接到服务端，就先断开连接
    if ([self.stream isConnected]) {
        
        [self logout];
    }
    
    
    // 生成用户的jid：XMPP体系中用户的唯一标识符，由登录账号、服务器域名和资源名生成的
    XMPPJID *jid = [XMPPJID jidWithUser:account domain:kDomainName resource:kResource];
    // 把jid配置到stream中
    self.stream.myJID = jid;
    
    
    // 连接服务端
    [self.stream connectWithTimeout:30 error:nil];
}


#pragma mark - XMPPStreamDelegate

// 连接服务端超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    
    [ProjectHUD showMBProgressHUDToView:kWindow withText:@"连接服务端超时，请重试！" atPosition:(MBProgressHUDTextPositionMiddle) autohideAfter:2 completionHandlerAfterAutohide:nil];
}

// 连接服务端成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSLog(@"===========>连接服务端成功");
    
    // 连接服务端成功后，验证密码
    if (self.connectToServerPurpose == ConnectToServerPurposeLogin) {
        
        // 验证登录密码
        [self.stream authenticateWithPassword:self.loginPassword error:nil];
    }else {
        
        // 验证注册密码
        [self.stream registerWithPassword:self.registerPassword error:nil];
    }
}

@end
