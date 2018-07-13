//
//  ChatOutImageTableViewCell.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/2.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "ChatOutImageTableViewCell.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "ZLPhotoActionSheet.h"

@interface ChatOutImageTableViewCell()<MWPhotoBrowserDelegate>

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSMutableArray *selections;
@property (strong, nonatomic) NSMutableArray *photos;

@end

@implementation ChatOutImageTableViewCell

- (void)setMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message {
    
    _message = message;
    
    for (XMPPElement *attachment in _message.message.children) {
        
        // 取出消息的附件，解码
        NSString *base64String = attachment.stringValue;
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        self.image = [[UIImage alloc] initWithData:data];
        
        self.contentImageView.image = [self.image scaleImageWithWidth:160];// 即图片最宽可以宽到160
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;
    
    self.contentImageView.contentMode = UIViewContentModeTopRight;
    
    self.contentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.contentImageView addGestureRecognizer:tap];
}


- (void)tapAction {
    
    // mwBrowser
    self.photos = [NSMutableArray array];
    MWPhoto *photo = [MWPhoto photoWithImage:self.image];
    [self.photos addObject:photo];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.alwaysShowControls = YES;// 导航栏
    browser.displayActionButton = NO;// 分享按钮
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.viewController presentViewController:nc animated:YES completion:nil];
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
