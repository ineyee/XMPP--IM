//
//  ProjectAudioPlayer.h
//  GuoRanHao_Merchant
//
//  Created by 意一yiyi on 2017/12/28.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ProjectAudioPlayer : NSObject

+ (instancetype)sharedAudioPlayer;

@property (copy,   nonatomic) void(^finishPlayingBlock)(void);

/**
 *  开始播放，根据路径
 */
- (void)startPlayingFileAtPath:(NSString *)filePath;

/**
 *  开始播放，根据data
 */
- (void)startPlayingFile:(NSData *)file;

/**
 *  暂停播放
 */
- (void)pausePlaying;

/**
 *  继续播放
 */
- (void)resumePlaying;

/**
 *  结束播放
 */
- (void)stopPlaying;

@end
