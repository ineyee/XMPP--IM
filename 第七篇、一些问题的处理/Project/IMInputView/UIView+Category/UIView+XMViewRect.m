//
//  UIView+XMViewRect.m
//  XMBasicProject
//
//  Created by robin on 2017/4/15.
//  Copyright © 2017年 robin. All rights reserved.
//

#import "UIView+XMViewRect.h"

@implementation UIView (XMViewRect)


@dynamic midY,midX,maxY,maxX;

- (CGFloat)x{
    return CGRectGetMinX(self.frame);
}
- (void)setX:(CGFloat)x{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat)y{
    return CGRectGetMinY(self.frame);
}
- (void)setY:(CGFloat)y{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (CGFloat)midX{
    return CGRectGetMidX(self.frame);
}

- (CGFloat)midY{
    return CGRectGetMidY(self.frame);
}

- (CGFloat)maxX{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)maxY{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)width{
    return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (CGFloat)height{
    return CGRectGetHeight(self.frame);
}
- (void)setHeight:(CGFloat)height{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

- (CGSize)size{
    return CGSizeMake(self.width, self.height);
}
- (void)setSize:(CGSize)size{
    self.frame = CGRectMake(self.x, self.y, size.width, size.height);
}

- (CGPoint)origin{
    return CGPointMake(self.x, self.y);
}

- (void)setOrigin:(CGPoint)origin{
    self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}


@end
