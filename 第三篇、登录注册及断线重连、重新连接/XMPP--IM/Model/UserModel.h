//
//  UserModel.h
//  XMPP--IM
//
//  Created by 意一yiyi on 2018/7/5.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

+ (instancetype)currentUser;

@property (strong, nonatomic) XMPPJID *jid;
@property (strong, nonatomic) NSString *password;

@end
