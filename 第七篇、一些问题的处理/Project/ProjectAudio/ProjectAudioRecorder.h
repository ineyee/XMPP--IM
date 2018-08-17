//
//  ProjectAudioRecorder.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/3.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ProjectAudioRecorder : NSObject

+ (instancetype)sharedAudioRecorder;

/**
 *  开始录音
 */
- (void)startRecording;

/**
 *  暂停录音
 */
- (void)pauseRecording;

/**
 *  继续录音，会自动追加在暂停时音频的后面
 */
- (void)resumeRecording;

/**
 *  结束录音
 */
- (void)stopRecording;

/**
 *  取消录音
 */
- (void)cancelRecording;

@end


@interface ProjectPCMToMP3 : NSObject

+ (BOOL)convertPCMToMP3WithFileSourcePath:(NSString *)sourcePath fileTargetPath:(NSString *)targetPath;

@end
