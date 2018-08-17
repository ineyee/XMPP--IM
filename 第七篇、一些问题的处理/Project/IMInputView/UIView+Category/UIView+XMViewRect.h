//
//  UIView+XMViewRect.h
//  XMBasicProject
//
//  Created by robin on 2017/4/15.
//  Copyright © 2017年 robin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XMViewRect)

@property (nonatomic ,assign)CGPoint origin;
@property (nonatomic ,assign)CGSize size;

@property (nonatomic ,assign)CGFloat x;
@property (nonatomic ,assign)CGFloat y;

@property (nonatomic ,assign)CGFloat width;
@property (nonatomic ,assign)CGFloat height;

@property (nonatomic ,assign)CGFloat midX;
@property (nonatomic ,assign)CGFloat midY;

@property (nonatomic ,assign)CGFloat maxX;
@property (nonatomic ,assign)CGFloat maxY;

@end
