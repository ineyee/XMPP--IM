//
//  FriendsListTableViewCell.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/28.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "FriendsListTableViewCell.h"

@implementation FriendsListTableViewCell

- (void)setMyFriend:(UserModel *)myFriend {
    
    _myFriend = myFriend;
    
    self.headImageView.image = [UIImage imageWithData:_myFriend.vCardTemp.photo];
    self.nicknameLabel.text = _myFriend.vCardTemp.nickname;
    
    if (_myFriend.isAvailable) {

        self.stateLabel.text = @"在线";
        self.stateLabel.textColor = kColorWithRGB(56, 198, 159, 1);
    }else {

        self.stateLabel.text = @"离线";
        self.stateLabel.textColor = kColorWithRGB(253, 106, 105, 1);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
