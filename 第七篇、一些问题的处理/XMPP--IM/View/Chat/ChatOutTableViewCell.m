//
//  ChatOutTableViewCell.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/29.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "ChatOutTableViewCell.h"

@implementation ChatOutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;

    // 设置图片不可被拉伸的区域
    UIImage *image = [[UIImage imageNamed:@"chat_out"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:(UIImageResizingModeStretch)];
    self.chatOutImageView.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
