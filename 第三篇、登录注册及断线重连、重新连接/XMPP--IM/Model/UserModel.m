//
//  UserModel.m
//  XMPP--IM
//
//  Created by 意一yiyi on 2018/7/5.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (instancetype)currentUser {
    
    return (UserModel *)[kNSUserDefaults yy_complexObjectForKey:@"currentUser"];
}

@end
