//
//  IMInputView.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/30.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IMInputView;

@protocol IMInputViewDelegate<NSObject>

@optional

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)textViewDidChangeHeight:(CGFloat)height;

- (void)didTapSendButton:(IMInputView *)imInputView message:(NSString *)message;
- (void)didTapMoreButton:(IMInputView *)imInputView;
- (void)didTapAudioButton:(IMInputView *)imInputView;

// 音频
- (void)recordDidBegin:(IMInputView *)imInputView;
- (void)recordDidEnd:(IMInputView *)imInputView audioData:(NSData *)data audioDuration:(CGFloat)duration;
- (void)recordDidCancel:(IMInputView *)imInputView;

@end

@interface IMInputView : UIView

@property (weak,   nonatomic) id<IMInputViewDelegate> delegate;

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIButton *recordButton;// 录音button
@property (strong, nonatomic) UIButton *audioButton;

@end
