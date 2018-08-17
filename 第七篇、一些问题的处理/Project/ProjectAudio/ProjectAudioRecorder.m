//
//  ProjectAudioRecorder.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/3.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "ProjectAudioRecorder.h"
#import "lame.h"

static BOOL stopRecording;

@interface ProjectAudioRecorder ()<AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;// 录音机
@property (strong, nonatomic) AVAudioSession *audioSession;// 音频回话类型

@end

@implementation ProjectAudioRecorder

#pragma mark - 单例

static ProjectAudioRecorder *audioRecorder = nil;
+ (instancetype)sharedAudioRecorder {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        audioRecorder = [[ProjectAudioRecorder alloc] init];
    });
    
    return audioRecorder;
}

- (instancetype)init {
    
    @synchronized(audioRecorder) {
        
        self = [super init];
        if (self != nil) {
            
            // 一些属性的设置
            
        }
        
        return self;
    }
}


#pragma mark - AVAudioRecorderDelegate

// 录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    self.audioRecorder = nil;
    if (stopRecording) {
        
        // 录音完成后，将音频回话类型设置为回放类型，否则音频播放的声音会变小
        [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
                
        // PCM编码转MP3编码，输出mp3文件
        if ([ProjectPCMToMP3 convertPCMToMP3WithFileSourcePath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.caf"] fileTargetPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]]) {// 转码成功
            
            
        }
    }
    
    // 删除原caf文件
    [[NSFileManager defaultManager] removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"audioFolder/myRecord.caf"] error:nil];
}


#pragma mark - public methods

- (void)startRecording {
    
    if (![self.audioRecorder isRecording]) {
        
        [self.audioRecorder record];
    }
}

- (void)pauseRecording {
    
    if ([self.audioRecorder isRecording]) {
        
        [self.audioRecorder pause];
    }
}

- (void)resumeRecording {
    
    // 恢复录音只需要再次调用开始录音事件，AVAudioSession会自动化帮你记录上次录音位置并追加录音
    [self startRecording];
}

- (void)stopRecording {
    
    stopRecording = YES;
    
    [self.audioRecorder stop];
}

- (void)cancelRecording {
    
    stopRecording = NO;

    [self.audioRecorder stop];
}


#pragma mark - setters, getters

- (AVAudioRecorder *)audioRecorder {
    
    if (_audioRecorder == nil) {
        
        // 创建音频会话
        self.audioSession = [AVAudioSession sharedInstance];
        // 设置为播放和录音状态，以便可以在录制完之后播放录音
        [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.audioSession setActive:YES error:nil];
        
        // 录音的存储路径
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *audioFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder"];
        if (![fileManager fileExistsAtPath:audioFolder]) {
            
            [fileManager createDirectoryAtPath:audioFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSURL *audioPath = [NSURL fileURLWithPath:[audioFolder stringByAppendingPathComponent:@"/myRecord.caf"]];
        
        // 录音设置
        NSMutableDictionary *settingsDict = [NSMutableDictionary dictionary];
        // 录音编码格式
        [settingsDict setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        // 录音质量
        [settingsDict setObject:@(AVAudioQualityMax) forKey:AVEncoderAudioQualityKey];
        // 录音采样频率
        [settingsDict setObject:@(44100) forKey:AVSampleRateKey];
        // 采样位数
        [settingsDict setObject:@(8) forKey:AVLinearPCMBitDepthKey];
        // 设置通道
        [settingsDict setObject:@(1) forKey:AVNumberOfChannelsKey];
        
        // 创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:audioPath settings:settingsDict error:&error];
        _audioRecorder.meteringEnabled = NO;// 是否启动声波监控
        _audioRecorder.delegate = self;
        
        if (error) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"录音出错，请重试!" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:(UIAlertActionStyleDefault) handler:nil];
            [alertController addAction:confirmAction];
            [kWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            return nil;
        }
    }
    
    return _audioRecorder;
}

@end


@implementation ProjectPCMToMP3

+ (BOOL)convertPCMToMP3WithFileSourcePath:(NSString *)sourcePath fileTargetPath:(NSString *)targetPath {
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([sourcePath cStringUsingEncoding:1], "rb");
        fseek(pcm, 4*1024, SEEK_CUR);
        FILE *mp3 = fopen([targetPath cStringUsingEncoding:1], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@", [exception description]);
        
        return NO;
    }
    @finally {
        
        return YES;
    }
}

@end
