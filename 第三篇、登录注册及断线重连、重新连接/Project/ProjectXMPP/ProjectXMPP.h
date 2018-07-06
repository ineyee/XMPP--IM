//
//  ProjectXMPP.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/26.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface ProjectXMPP : NSObject

/// XMPP的基础服务类，客户端和服务端的通信管道
@property (strong, nonatomic) XMPPStream *stream;


/// 断线重连
@property (strong, nonatomic) XMPPReconnect *reconnect;


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


@end
