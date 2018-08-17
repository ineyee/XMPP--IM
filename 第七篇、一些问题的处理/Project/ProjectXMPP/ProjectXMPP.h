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
#import "XMPPMessageDeliveryReceipts.h"
#import "XMPPMessage+XEP_0184.h"
#import "NSXMLElement+XMPP.h"

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


// 聊天记录的本地存储
@property (strong, nonatomic) XMPPMessageArchiving *messageArchiving;
@property (strong, nonatomic) XMPPMessageArchivingCoreDataStorage *messageArchivingCoreDataStorage;
@property (strong, nonatomic) NSManagedObjectContext *messageContext;


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


#pragma mark - 聊天相关

/**
 *  拉取和某位好友的聊天记录
 *
 *  @param  friendJID 好友的jid
 *
 *  @return 聊天记录
 */
- (NSArray *)fecthMessageRecordWithFriendJID:(XMPPJID *)friendJID;

/**
 *  发送文本消息给指定的好友
 *
 *  @param  text        要发送的消息
 *  @param  friendJID   指定好友的jid
 */
- (void)sendTextMessage:(NSString *)text toFriend:(XMPPJID *)friendJID;

/**
 *  发送图片消息给指定的好友
 *
 *  @param  image       要发送的图片
 *  @param  friendJID   指定好友的jid
 */
- (void)sendImageMessage:(NSData *)image toFriend:(XMPPJID *)friendJID;

/**
 *  发送音频消息给指定的好友
 *
 *  @param  audio       要发送的音频
 *  @param  duration    音频的时长
 *  @param  friendJID   指定好友的jid
 */
- (void)sendAudioMessage:(NSData *)audio duration:(CGFloat)duration toFriend:(XMPPJID *)friendJID;

/**
 *  拉取离线消息的配置
 */
- (void)getOfflineMessageConfiguration;

@end
