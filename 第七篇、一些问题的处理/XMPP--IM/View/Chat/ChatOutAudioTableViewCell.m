//
//  ChatOutAudioTableViewCell.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/3.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "ChatOutAudioTableViewCell.h"

@interface ChatOutAudioTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;

@property (strong, nonatomic) NSData *audioData;
@property (assign, nonatomic) CGFloat duration;

@end

@implementation ChatOutAudioTableViewCell

- (void)setMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message {
    
    _message = message;
    
    for (XMPPElement *attachment in _message.message.children) {
        
        // 取出消息的附件，解码
        NSString *base64String = attachment.stringValue;
        self.audioData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    }
    
    self.duration = [[_message.body substringWithRange:NSMakeRange(6, _message.body.length - 7)] floatValue];
    self.durationLabel.text = [_message.body substringFromIndex:6];
    self.constraint.constant = 100 + (200 - 100) * (self.duration / 30.0);
    
    if (self.isPlaying) {
        
        self.animateImageView.animationDuration = 2;
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (int i = 1; i <= 3; i ++) {
            
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"chat_out_%d", i]];
            [tempArray addObject:image];
        }
        self.animateImageView.animationImages = [tempArray copy];
        [self.animateImageView startAnimating];
    }else {
        
        self.animateImageView.image = [UIImage imageNamed:@"chat_out_3"];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;
    
    
    // 设置图片不可被拉伸的区域
    UIImage *image = [[UIImage imageNamed:@"chat_out"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:(UIImageResizingModeStretch)];
    self.chatOutImageView.image = image;
    
    self.animateImageView.image = [UIImage imageNamed:@"chat_out_3"];
    
    self.chatOutImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.chatOutImageView addGestureRecognizer:tap];
}

- (void)tap {
    
    self.isPlaying = YES;
    
    // 如果是对方在播的话，也禁掉
    [ProjectSingleton sharedSingleton].lastChatInAudioCell.animateImageView.animationImages = nil;
    [[ProjectSingleton sharedSingleton].lastChatInAudioCell.animateImageView stopAnimating];
    [ProjectSingleton sharedSingleton].lastChatInAudioCell.animateImageView.image = [UIImage imageNamed:@"chat_in_3"];
    [ProjectSingleton sharedSingleton].lastChatInAudioCell.isPlaying = NO;
    
    if ([ProjectSingleton sharedSingleton].lastChatOutAudioCell != self) {// 点了另外的cell。禁掉本方
    
        [ProjectSingleton sharedSingleton].lastChatOutAudioCell.animateImageView.animationImages = nil;
        [[ProjectSingleton sharedSingleton].lastChatOutAudioCell.animateImageView stopAnimating];
        [ProjectSingleton sharedSingleton].lastChatOutAudioCell.animateImageView.image = [UIImage imageNamed:@"chat_out_3"];
        [ProjectSingleton sharedSingleton].lastChatOutAudioCell.isPlaying = NO;
        
        [ProjectSingleton sharedSingleton].lastChatOutAudioCell = self;
    }
    
    [[ProjectAudioPlayer sharedAudioPlayer] startPlayingFile:self.audioData];
    [ProjectAudioPlayer sharedAudioPlayer].finishPlayingBlock = ^{
        
        self.animateImageView.animationImages = nil;
        [self.animateImageView stopAnimating];
        
        self.animateImageView.image = [UIImage imageNamed:@"chat_out_3"];
        
        self.isPlaying = NO;
    };
    
    self.animateImageView.animationDuration = 2;
    NSMutableArray *tempArray = [@[] mutableCopy];
    for (int i = 1; i <= 3; i ++) {
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"chat_out_%d", i]];
        [tempArray addObject:image];
    }
    self.animateImageView.animationImages = [tempArray copy];
    [self.animateImageView startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
