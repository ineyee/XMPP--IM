//
//  ProjectSingleton.h
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/24.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatOutAudioTableViewCell.h"
#import "ChatInAudioTableViewCell.h"

@interface ProjectSingleton : NSObject<NSCopying, NSMutableCopying>

+ (instancetype)sharedSingleton;

/// 好友列表数组
@property (strong, nonatomic) NSMutableArray *friendsListArray;
/// 新朋友数组
@property (strong, nonatomic) NSMutableArray *pre_newFriendArray;


@property (strong, nonatomic) ChatOutAudioTableViewCell *lastChatOutAudioCell;// 上一个播放音频的cell
@property (strong, nonatomic) ChatInAudioTableViewCell *lastChatInAudioCell;// 上一个播放音频的cell

@end
