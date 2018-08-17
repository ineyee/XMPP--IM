//
//  NewFriendTableViewCell.h
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/27.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

@property (copy,   nonatomic) void(^acceptBlock)(void);
@property (copy,   nonatomic) void(^rejectBlock)(void);

@end
