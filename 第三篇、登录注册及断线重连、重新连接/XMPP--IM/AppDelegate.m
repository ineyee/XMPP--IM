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

@interface AppDelegate ()<XMPPStreamDelegate, XMPPReconnectDelegate>

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
    
    return YES;
}


#pragma mark - XMPPStreamDelegate

// 登录成功，这里的登录应该只针对自动登录这种情况，避免和登录界面的回调出现重复调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    if ([kNSUserDefaults boolForKey:@"isLogin"]) {
        
        NSLog(@"===========>自动登录成功");
        
        // 上线
        [[ProjectXMPP sharedXMPP] becomeAvailable];
    }
    
}


#pragma mark - XMPPReconnectDelegate

// 断线重连
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    
    [[ProjectXMPP sharedXMPP] loginWithAccount:[UserModel currentUser].jid.user password:[UserModel currentUser].password];
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
