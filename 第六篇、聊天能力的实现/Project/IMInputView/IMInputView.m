//
//  IMInputView.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/30.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "IMInputView.h"
#import "RecordingView.h"

#define kSelfHeight 54
#define kTextviewDefaultHeight 34
#define kTextViewMaxHeight 99

@interface IMInputView ()<UITextViewDelegate>

@property (strong, nonatomic) RecordingView *recordingView;

@end

@implementation IMInputView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self layoutUI];
        [self configuration];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self layoutUI];
        [self configuration];
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 监听键盘的显示和隐藏

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16)
                     animations:^{

                         if ([self.delegate respondsToSelector:@selector(keyboardWillShow:)]) {
                             
                             [self.delegate keyboardWillShow:notification];
                         }
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16)
                     animations:^{
                        
                         if ([self.delegate respondsToSelector:@selector(keyboardWillHide:)]) {
                             
                             [self.delegate keyboardWillHide:notification];
                         }
                     }
                     completion:nil];
}


#pragma mark - 发送文本消息

- (void)sendButtonAction:(UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(didTapSendButton: message:)]) {
        
        [self.delegate didTapSendButton:self message:self.textView.text];
    }
    
    self.textView.text = @"";
    [self reLayoutUI];
}


#pragma mark - 更多

- (void)moreButtonAction:(UIButton *)button {
    
    [self.textView resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(didTapMoreButton:)]) {
        
        [self.delegate didTapMoreButton:self];
    }
}


#pragma mark - 录音

- (void)audioButtonAction:(UIButton *)button {
    
    self.audioButton.selected = !self.audioButton.selected;
    
    if (self.audioButton.selected) {
        
        [self.textView resignFirstResponder];
        self.textView.hidden = YES;
        self.recordButton.hidden = NO;
    }else {
        
        self.textView.hidden = NO;
        self.recordButton.hidden = YES;
    }
}

static BOOL cancelSendAudioMessage = NO;
- (void)longPressAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"===========>开始录音");
        
        [self startRecording];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"===========>录音完毕");
        
        [self recordFinished];
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {// 录音中
        
        // 这里的两个主要是用来记录到底是录音完要发送了，还是取消录音了，只要松手，都会触发上面的UIGestureRecognizerStateEnded
        if ([self.layer containsPoint:point]) {
            
            if (cancelSendAudioMessage) {// 因为UIGestureRecognizerStateChanged这个状态一直在触发，避免多次做同样的是
                
                NSLog(@"===========>在范围内");
                
                cancelSendAudioMessage = NO;
                
                [self.recordButton setTitle:@"松开 结束" forState:UIControlStateNormal];
                self.recordButton.backgroundColor = [UIColor grayColor];
    
                self.recordingView.recordingViewState = RecordingViewStateRecording;
            }
            
            // 自动发送这个有问题，和别的状态还没判断清楚，比如上滑
            [self autoSendAfter30s];
        }else {
            
            if (!cancelSendAudioMessage) {
                
                NSLog(@"===========>上滑出去了");
                
                cancelSendAudioMessage  = YES;
                
                [self.recordButton setTitle:@"松开 取消" forState:UIControlStateNormal];
                self.recordButton.backgroundColor = [UIColor grayColor];
                
                self.recordingView.recordingViewState = RecordingViewStateCancel;
            }
            
            [self autoSendAfter30s];
        }
    }
}

- (void)startRecording {
    
    [self.recordButton setTitle:@"松开 结束" forState:UIControlStateNormal];
    self.recordButton.backgroundColor = [UIColor grayColor];
    [kWindow addSubview:self.recordingView];
    
    if ([self.delegate respondsToSelector:@selector(recordDidBegin:)]) {
        
        [self.delegate recordDidBegin:self];
    }
    
    // 开始录音
    [[ProjectAudioRecorder sharedAudioRecorder] startRecording];
    
    self.recordingView.recordingViewState = RecordingViewStateRecording;
    
    
    // 禁掉在播放的cell
    // 禁掉对方
    [ProjectSingleton sharedSingleton].lastChatOutAudioCell.animateImageView.animationImages = nil;
    [[ProjectSingleton sharedSingleton].lastChatOutAudioCell.animateImageView stopAnimating];
    [ProjectSingleton sharedSingleton].lastChatOutAudioCell.animateImageView.image = [UIImage imageNamed:@"chat_out_3"];
    [ProjectSingleton sharedSingleton].lastChatOutAudioCell.isPlaying = NO;
    // 禁掉己方
    [ProjectSingleton sharedSingleton].lastChatInAudioCell.animateImageView.animationImages = nil;
    [[ProjectSingleton sharedSingleton].lastChatInAudioCell.animateImageView stopAnimating];
    [ProjectSingleton sharedSingleton].lastChatInAudioCell.animateImageView.image = [UIImage imageNamed:@"chat_in_3"];
    [ProjectSingleton sharedSingleton].lastChatInAudioCell.isPlaying = NO;    
}

- (void)recordFinished {
    
    [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    self.recordButton.backgroundColor = [UIColor whiteColor];
    
    if (cancelSendAudioMessage) {
        
        [self.recordingView removeFromSuperview];
        
        // 取消录音
        [[ProjectAudioRecorder sharedAudioRecorder] cancelRecording];
        
        if ([self.delegate respondsToSelector:@selector(recordDidCancel:)]) {
            
            [self.delegate recordDidCancel:self];
        }
    }else {
        
        // 结束录音
        [[ProjectAudioRecorder sharedAudioRecorder] stopRecording];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            while (1) {
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]] && ![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.caf"]]) {// 表明被替换完成了
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSData *audioData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]];
                        
                        // 获取音频时长
                        AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]]];
                        CMTime audioDuration = audioAsset.duration;
                        CGFloat audioDurationSeconds = CMTimeGetSeconds(audioDuration);
                        
                        if (audioDurationSeconds < 1) {
                            
                            self.recordingView.recordingViewState = RecordingViewStateTimeNotEnough;
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                                [self.recordingView removeFromSuperview];
                            });
                        }else {
                            
                            [self.recordingView removeFromSuperview];
                            
                            if ([self.delegate respondsToSelector:@selector(recordDidEnd:audioData:audioDuration:)]) {
                                
                                if (audioDurationSeconds > 30) {// 录音不可能那么准确，总有30点零几或30点一几的情况，这里让用户看到30s就行了
                                    
                                    audioDurationSeconds = 30;
                                }
                                
                                [self.delegate recordDidEnd:self audioData:audioData audioDuration:audioDurationSeconds];
                            }
                        }
                    });
                    
                    return;
                }
            }
        });
    }
}

- (void)autoSendAfter30s {
    
    // 获取音频时长
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.caf"]]];
    CMTime audioDuration = audioAsset.duration;
    CGFloat audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    NSLog(@"===========>音频时长：%.2f", audioDurationSeconds);
    
    if (audioDurationSeconds >= 25 && audioDurationSeconds <= 30) {
        
        self.recordingView.recordingViewState = RecordingViewStateTimeCountdown;
    }
    
    if (audioDurationSeconds > 30) {

        [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        self.recordButton.backgroundColor = [UIColor whiteColor];
        [self.recordingView removeFromSuperview];

        // 结束录音
        [[ProjectAudioRecorder sharedAudioRecorder] stopRecording];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            while (1) {

                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]] && ![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.caf"]]) {// 表明被替换完成了

                    dispatch_async(dispatch_get_main_queue(), ^{

                        NSData *audioData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]];

                        // 获取音频时长
                        AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/audioFolder/myRecord.mp3"]]];
                        CMTime audioDuration = audioAsset.duration;
                        CGFloat audioDurationSeconds = CMTimeGetSeconds(audioDuration);

                        if ([self.delegate respondsToSelector:@selector(recordDidEnd:audioData:audioDuration:)]) {

                            [self.delegate recordDidEnd:self audioData:audioData audioDuration:audioDurationSeconds];
                        }
                    });

                    return;
                }
            }
        });
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    [self reLayoutUI];
}

static CGFloat lastChangeHeight;
static CGFloat totalChangeHeight;
static CGFloat singleChangeHeight;
- (void)reLayoutUI {
    
    self.sendButton.selected = self.sendButton.enabled = !(kStringIsEmpty(self.textView.text));
    
    // 设置textView的frame
    CGRect textViewFrame = self.textView.frame;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];// 获取textView自适应文本的大小
    textViewFrame.size.height = MAX(kTextviewDefaultHeight, MIN(kTextViewMaxHeight, textSize.height));
    self.textView.frame = textViewFrame;
    self.textView.scrollEnabled = (textSize.height > kTextViewMaxHeight);
    
    // 根据textView的frame设置inputView的frame
    CGRect selfFrame = self.frame;
    CGFloat maxY = CGRectGetMaxY(selfFrame);
    selfFrame.size.height = textViewFrame.size.height + 20;
    selfFrame.origin.y = maxY - selfFrame.size.height;
    self.frame = selfFrame;
    
    // 剩余三个button的frame不要动
    self.audioButton.y = self.frame.size.height - kSelfHeight;
    self.moreButton.y = self.audioButton.y;
    self.sendButton.y = self.audioButton.y;
    
    totalChangeHeight = textViewFrame.size.height - kTextviewDefaultHeight;
    if (totalChangeHeight != lastChangeHeight) {
        
        singleChangeHeight = totalChangeHeight - lastChangeHeight;
        lastChangeHeight = totalChangeHeight;
        
        if ([self.delegate respondsToSelector:@selector(textViewDidChangeHeight:)]) {
            
            [self.delegate textViewDidChangeHeight:singleChangeHeight];
        }
    }
}


#pragma mark - layoutUI & configuration

- (void)configuration {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutUI {
        
    self.frame = CGRectMake(0, kScreenHeight - kSelfHeight, kScreenWidth, kSelfHeight);
    self.backgroundColor = kColorWithRGB(245, 245, 245, 1);
    
    [self addSubview:self.textView];
    [self addSubview:self.recordButton];
    [self addSubview:self.audioButton];
    [self addSubview:self.moreButton];
    [self addSubview:self.sendButton];
    
    CGFloat tempFloat = kSelfHeight - 20;
    
    self.textView.frame = CGRectMake(kSelfHeight, 10, kScreenWidth - kSelfHeight * 3 + 10, tempFloat);
    self.recordButton.frame = CGRectMake(kSelfHeight, 10, kScreenWidth - kSelfHeight * 3 + 10, tempFloat);
    self.audioButton.frame = CGRectMake(10, 0, tempFloat, kSelfHeight);
    self.moreButton.frame = CGRectMake(kScreenWidth - kSelfHeight * 2 + 20, 0, tempFloat, kSelfHeight);
    self.sendButton.frame = CGRectMake(kScreenWidth - kSelfHeight + 10, 0, tempFloat, kSelfHeight);
}


#pragma mark - setter, getter

- (UITextView *)textView {
    
    if (_textView == nil) {
        
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        
        _textView.delegate = self;
        
        _textView.font = [UIFont systemFontOfSize:14];

        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.layer.borderWidth = 1;
        _textView.layer.cornerRadius = 5;
    }
    
    return _textView;
}

- (UIButton *)recordButton {
    
    if (_recordButton == nil) {
        
        _recordButton = [[UIButton alloc] init];
        _recordButton.backgroundColor = [UIColor whiteColor];
        
        _recordButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _recordButton.layer.borderWidth = 1;
        _recordButton.layer.cornerRadius = 5;
        
        [_recordButton setTitle:@"按住说话" forState:(UIControlStateNormal)];
        [_recordButton setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
        
        // 增加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        longPress.minimumPressDuration = 0;
        [_recordButton addGestureRecognizer:longPress];
        
        _recordButton.hidden = YES;
    }
    
    return _recordButton;
}

- (UIButton *)audioButton {
    
    if (_audioButton == nil) {
        
        _audioButton = [[UIButton alloc] init];
        _audioButton.backgroundColor = [UIColor clearColor];
        
        [_audioButton setImage:[UIImage imageNamed:@"audio"] forState:(UIControlStateNormal)];
        [_audioButton setImage:[UIImage imageNamed:@"keyboard"] forState:(UIControlStateSelected)];
        _audioButton.imageView.contentMode = UIViewContentModeCenter;
        
        [_audioButton addTarget:self action:@selector(audioButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    return _audioButton;
}

- (UIButton *)moreButton {
    
    if (_moreButton == nil) {
        
        _moreButton = [[UIButton alloc] init];
        _moreButton.backgroundColor = [UIColor clearColor];
        
        [_moreButton setImage:[UIImage imageNamed:@"more"] forState:(UIControlStateNormal)];
        _moreButton.imageView.contentMode = UIViewContentModeCenter;
        
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    return _moreButton;
}

- (UIButton *)sendButton {
    
    if (_sendButton == nil) {
        
        _sendButton = [[UIButton alloc] init];
        _sendButton.backgroundColor = [UIColor clearColor];
        
        [_sendButton setImage:[UIImage imageNamed:@"send"] forState:(UIControlStateNormal)];
        [_sendButton setImage:[UIImage imageNamed:@"send_sel"] forState:(UIControlStateSelected)];
        _sendButton.imageView.contentMode = UIViewContentModeCenter;
        
        _sendButton.enabled = NO;
        
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    return _sendButton;
}

- (RecordingView *)recordingView {
    
    if (_recordingView == nil) {
        
        _recordingView = [[RecordingView alloc] init];
    }
    
    return _recordingView;
}

@end
