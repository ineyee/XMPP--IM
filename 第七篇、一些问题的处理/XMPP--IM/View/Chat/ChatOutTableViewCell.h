//
//  ChatOutTableViewCell.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/29.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatOutTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatOutImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
