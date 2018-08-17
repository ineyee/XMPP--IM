//
//  RecordingView.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/2.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecordingViewState) {
    RecordingViewStateRecording,
    RecordingViewStateCancel,
    RecordingViewStateTimeNotEnough,
    RecordingViewStateTimeCountdown
};

@interface RecordingView : UIView

@property (assign, nonatomic) NSInteger recordingViewState;

@end
