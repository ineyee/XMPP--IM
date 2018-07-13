//
//  ProjectSingleton.h
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/24.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectSingleton : NSObject<NSCopying, NSMutableCopying>

+ (instancetype)sharedSingleton;

/// 好友列表数组
@property (strong, nonatomic) NSMutableArray *friendsListArray;
/// 新朋友数组
@property (strong, nonatomic) NSMutableArray *pre_newFriendArray;

@end
