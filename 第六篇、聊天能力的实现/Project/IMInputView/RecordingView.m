//
//  RecordingView.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/2.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "RecordingView.h"

@interface RecordingView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *recordingImageView;
@property (strong, nonatomic) UILabel *promptLabel;

@end

@implementation RecordingView

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        [self layoutUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        
        [self layoutUI];
    }
    
    return self;
}


#pragma mark - layoutUI

- (void)layoutUI {
    
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.backgroundView];
}


#pragma mark - setter, getter

- (void)setRecordingViewState:(NSInteger)recordingViewState {
    
    switch (recordingViewState) {
        case RecordingViewStateRecording:
        {
            self.recordingImageView.image = nil;
            self.promptLabel.backgroundColor = [UIColor clearColor];
            self.promptLabel.text = @"手指上滑，取消发送";
            
            NSMutableArray *tempArray = [@[] mutableCopy];
            for (int i = 1; i <= 3; i ++) {
                
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02d", i]];
                [tempArray addObject:image];
            }
            _recordingImageView.animationImages = [tempArray copy];
            _recordingImageView.animationDuration = 2;
            [_recordingImageView startAnimating];
        }
            break;
        case RecordingViewStateCancel:
        {
            [_recordingImageView stopAnimating];
            _recordingImageView.animationImages = nil;
        
            self.recordingImageView.contentMode = UIViewContentModeScaleAspectFit;
            self.recordingImageView.image = [UIImage imageNamed:@"cancelRecord"];
            self.promptLabel.backgroundColor = [UIColor redColor];
            self.promptLabel.text = @"松开手指，取消发送";
        }
            break;
        case RecordingViewStateTimeNotEnough:
        {
            [_recordingImageView stopAnimating];
            _recordingImageView.animationImages = nil;
            
            self.recordingImageView.image = [UIImage imageNamed:@"warningRecord"];
            self.promptLabel.backgroundColor = [UIColor clearColor];
            self.promptLabel.text = @"说话时间太短";
        }
            break;
        case RecordingViewStateTimeCountdown:
        {
            [_recordingImageView stopAnimating];
            _recordingImageView.animationImages = nil;
            
            self.recordingImageView.image = [UIImage imageNamed:@"warningRecord"];
            self.promptLabel.backgroundColor = [UIColor clearColor];
            self.promptLabel.text = @"超过30秒，自动发送";
        }
            break;
    }
}

- (UIView *)backgroundView {
    
    if (_backgroundView == nil) {
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 3.0 + 40, kScreenWidth / 3.0)];
        _backgroundView.center = kWindow.center;
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.618];
        
        _backgroundView.layer.cornerRadius = 5;
        
        [_backgroundView addSubview:self.recordingImageView];
        [_backgroundView addSubview:self.promptLabel];
    }
    
    return _backgroundView;
}

- (UIImageView *)recordingImageView {
    
    if (_recordingImageView == nil) {
        
        _recordingImageView =[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth / 3.0 + 40 - 121) / 2.0, (kScreenWidth / 3.0 - 30 - 66) / 2.0, 121, 66)];
        _recordingImageView.backgroundColor = [UIColor clearColor];
        
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (int i = 1; i <= 3; i ++) {
            
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02d", i]];
            [tempArray addObject:image];
        }
        _recordingImageView.animationImages = [tempArray copy];
        _recordingImageView.animationDuration = 2;
        [_recordingImageView startAnimating];
    }
    
    return _recordingImageView;
}

- (UILabel *)promptLabel {
    
    if (_promptLabel == nil) {
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kScreenWidth / 3.0 - 40, kScreenWidth / 3.0 + 20, 30)];
        _promptLabel.backgroundColor = [UIColor clearColor];
        
        _promptLabel.text = @"手指上滑，取消发送";
        _promptLabel.font = [UIFont systemFontOfSize:14];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        
        _promptLabel.layer.cornerRadius = 5;
    }
    
    return _promptLabel;
}

@end
