//
//  ChatInTableViewCell.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/29.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatInTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatInImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
