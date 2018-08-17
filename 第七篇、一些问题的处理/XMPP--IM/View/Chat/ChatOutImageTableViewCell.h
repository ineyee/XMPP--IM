//
//  ChatOutImageTableViewCell.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/2.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatOutImageTableViewCell : UITableViewCell

@property (strong, nonatomic) XMPPMessageArchiving_Message_CoreDataObject *message;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end
