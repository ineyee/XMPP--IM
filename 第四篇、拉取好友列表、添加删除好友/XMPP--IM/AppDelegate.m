//
//  AppDelegate.m
//  XMPP--IM
//
//  Created by 意一yiyi on 2018/7/5.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "FriendsListViewController.h"

@interface AppDelegate ()<XMPPStreamDelegate, XMPPReconnectDelegate, XMPPRosterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    if ([kNSUserDefaults boolForKey:@"isLogin"]) {
        
        // 重新连接
        [[ProjectXMPP sharedXMPP] loginWithAccount:[UserModel currentUser].jid.user password:[UserModel currentUser].password];
        
        [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[FriendsListViewController alloc] init]]];
    }else {
        
        [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]]];
    }
    
    
    // 设置代理，重连这代理，要不要必须是登录状态才行
    [[ProjectXMPP sharedXMPP].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[ProjectXMPP sharedXMPP].reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[ProjectXMPP sharedXMPP].roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    return YES;
}


#pragma mark - XMPPStreamDelegate

// 登录成功，这里的登录应该只针对自动登录这种情况，避免和登录界面的回调出现重复调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    if ([kNSUserDefaults boolForKey:@"isLogin"]) {
        
        NSLog(@"===========>自动登录成功");
        
        // 上线
        [[ProjectXMPP sharedXMPP] becomeAvailable];
        
        // 拉取好友列表
        [[ProjectXMPP sharedXMPP] fetchFriendsList];
    }
}

// 监测好友在线状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    
    NSLog(@"===========>好友：%@，状态：%@", presence.from, presence.type);
    
    // 对方拒绝了我的好友申请时，或者对方删除了我时，我会触发这个回调
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        
        [[ProjectXMPP sharedXMPP] removeFriendWithAccount:presence.from.user];
    }
    
    if ([presence.type isEqualToString:@"available"]) {
        
//        for (UserModel *userModel in [ProjectSingleton sharedSingleton].friendsListArray) {
//
//            if ([presence.from.user isEqualToString:userModel.jid.user]) {
//
//                NSLog(@"%d", userModel.isAvailable);
//                if (!userModel.isAvailable) {
//
//                    userModel.isAvailable = YES;
//
//                    // 发送上下线通知
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendIsAvailable" object:userModel];
//                }
//            }
//        }
    }
    
    if ([presence.type isEqualToString:@"unavailable"]) {
        
//        for (UserModel *userModel in [ProjectSingleton sharedSingleton].friendsListArray) {
//
//            if ([presence.from.user isEqualToString:userModel.jid.user]) {
//
//                NSLog(@"%d", userModel.isAvailable);
//                if (userModel.isAvailable) {
//
//                    userModel.isAvailable = NO;
//
//                    // 发送上下线通知
//                    [[NSNotificationCenter defaultCenter]postNotificationName:@"FriendIsAvailable" object:userModel];
//                }
//            }
//        }
    }
}


#pragma mark - XMPPReconnectDelegate

// 断线重连
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    
    [[ProjectXMPP sharedXMPP] loginWithAccount:[UserModel currentUser].jid.user password:[UserModel currentUser].password];
}


#pragma mark - XMPPRosterDelegate

// 收到一个好友申请
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {

    // 如果这个好友请求已经发起了，是待确认的状态，那么再次收到同样的好友申请的时候就忽略掉，避免数据重复
    for (UserModel *tempUser in [ProjectSingleton sharedSingleton].pre_newFriendArray) {

        if ([presence.from.user isEqualToString:tempUser.jid.user] && [presence.from.domain isEqualToString:tempUser.jid.domain]) {

            return;
        }
    }

    // 新朋友界面的数组新增一条数据
    UserModel *tempUser = [[UserModel alloc] init];
    tempUser.jid = presence.from;
    [[ProjectSingleton sharedSingleton].pre_newFriendArray addObject:tempUser];
    // 发出通知，好友列表界面和新朋友界面会接收通知，做相应的处理
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveFriendRequest" object:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
