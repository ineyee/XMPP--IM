//
//  ProjectAudioPlayer.m
//  GuoRanHao_Merchant
//
//  Created by 意一yiyi on 2017/12/28.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import "ProjectAudioPlayer.h"

@interface ProjectAudioPlayer ()<AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation ProjectAudioPlayer

#pragma mark - 单例

static ProjectAudioPlayer *audioPlayer = nil;
+ (instancetype)sharedAudioPlayer {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        audioPlayer = [[ProjectAudioPlayer alloc] init];
    });
    
    return audioPlayer;
}

- (instancetype)init {
    
    @synchronized(audioPlayer) {
        
        self = [super init];
        if (self != nil) {
            
            // 一些属性的设置
        }
        
        return self;
    }
}


#pragma mark - public methods

- (void)startPlayingFileAtPath:(NSString *)filePath {
    
    if (self.player.isPlaying) {
        
        [self.player stop];
    }
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    if (![self.player isPlaying]) {
        
        [self.player play];
    }
}

- (void)startPlayingFile:(NSData *)file {
    
    if (self.player.isPlaying) {
        
        [self.player stop];
    }
    
    self.player = [[AVAudioPlayer alloc] initWithData:file error:nil];
    self.player.delegate = self;
    
    if (![self.player isPlaying]) {
        
        [self.player play];
    }
}

- (void)pausePlaying {
    
    if ([self.player isPlaying]) {
        
        [self.player pause];
    }
}

- (void)resumePlaying {
    
    if (![self.player isPlaying]) {
        
        [self.player play];
    }
}

- (void)stopPlaying {
    
    [self.player stop];
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self.player stop];
    self.player = nil;
    
    if (self.finishPlayingBlock) {
        
        self.finishPlayingBlock();
    }
}

@end
