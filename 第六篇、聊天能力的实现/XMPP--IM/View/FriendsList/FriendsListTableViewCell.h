//
//  FriendsListTableViewCell.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/28.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsListTableViewCell : UITableViewCell

@property (copy,   nonatomic) UserModel *myFriend;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end
