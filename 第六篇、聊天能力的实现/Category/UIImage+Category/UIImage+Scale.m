//
//  UIImage+Scale.m
//  XMPPDemo
//
//  Created by 意一yiyi on 2018/7/2.
//  Copyright © 2018年 意一yiyi. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

// 把图片缩小到指定的宽度范围内为止
- (UIImage *)scaleImageWithWidth:(CGFloat)width {
    
    // 如果图片的宽度小于我们指定的宽度，或者我们给了个小于等于0的宽度，就返回原图片
    if (self.size.width <= width || width <= 0) {
        
        return self;
    }
    
    // 否则，把图片按比例缩放到我们指定的大小
    CGFloat scale = self.size.width / width;
    CGFloat height = self.size.height / scale;
    CGRect rect = CGRectMake(0, 0, width, height);
    // 开始上下文，目标大小是这么大
    UIGraphicsBeginImageContext(rect.size);
    // 在指定区域内绘制图像
    [self drawInRect:rect];
    // 从上下文中获得绘制结果
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭上下文返回结果
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
