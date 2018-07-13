//
//  ProjectXMPP.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPvCardTemp.h"

@interface ProjectXMPP : NSObject

/// XMPP的基础服务类，客户端和服务端的通信管道
@property (strong, nonatomic) XMPPStream *stream;


/// 断线重连
@property (strong, nonatomic) XMPPReconnect *reconnect;


/// 好友列表类，关于好友管理的一些操作基本上都归它管
@property (strong, nonatomic) XMPPRoster *roster;
/// 好友列表本地存储的一个类
@property (strong, nonatomic) XMPPRosterCoreDataStorage *rosterCoreDataStorage;


/// 电子名片的存储、读取模组
@property (strong, nonatomic) XMPPvCardTempModule *vCardTempModule;
/// 电子名片的本地存储
@property (strong, nonatomic) XMPPvCardCoreDataStorage *vCardCoreDataStorage;
/// 电子名片的头像模组
@property (strong, nonatomic) XMPPvCardAvatarModule *vCardAvatarModule;


#pragma mark - 单例

/**
 *  单例
 */
+ (instancetype)sharedXMPP;


#pragma mark - 登录

/**
 *  登录
 *
 *  @param  account     账号
 *  @param  password    密码
 */
- (void)loginWithAccount:(NSString *)account password:(NSString *)password;

/**
 *  切换为上线状态
 */
- (void)becomeAvailable;

/**
 *  退出登录
 */
- (void)logout;


#pragma mark - 注册

/**
 *  注册
 *
 *  @param  account     账号
 *  @param  password    密码
 */
- (void)registerWithAccount:(NSString *)account password:(NSString *)password;


#pragma mark - 好友相关

/**
 *  拉取好友列表
 */
- (void)fetchFriendsList;

/**
 *  添加好友
 *
 *  @param  account 账号
 */
- (void)addFriendWithAccount:(NSString *)account;

/**
 *  删除好友
 *
 *  @param  account 账号
 */
- (void)removeFriendWithAccount:(NSString *)account;

/**
 *  接受好友请求
 *
 *  @param  account 账号
 */
- (void)acceptFriendRequestWithAccount:(NSString *)account;

/**
 *  拒绝好友请求
 *
 *  @param  account 账号
 */
- (void)rejectFriendRequestWithAccount:(NSString *)account;


#pragma mark - 电子名片相关

/**
 *  拉取指定联系人的电子名片，直接返回版
 *
 *  @param  account 账号
 *  @return 电子名片
 */
- (XMPPvCardTemp *)fetchvCardTempForAccount:(NSString *)account;

/**
 *  拉取指定联系人的电子名片，回调版
 *
 *  @param  account 账号
 */
- (void)fetchvCardTempWithCallbackForAccount:(NSString *)account;

/**
 *  更新自己的电子名片
 *
 *  @param  vCardTemp 电子名片
 */
- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp;

@end
