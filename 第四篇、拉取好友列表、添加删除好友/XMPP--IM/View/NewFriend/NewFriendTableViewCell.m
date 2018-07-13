//
//  NewFriendTableViewCell.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/6/27.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "NewFriendTableViewCell.h"

@implementation NewFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)acceptAction:(id)sender {
    
    if (self.acceptBlock) {
        
        self.acceptBlock();
    }
}

- (IBAction)rejectAction:(id)sender {
    
    if (self.rejectBlock) {
        
        self.rejectBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
