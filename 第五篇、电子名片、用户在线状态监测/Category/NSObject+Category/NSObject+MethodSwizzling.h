//
//  NSObject+MethodSwizzling.h
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/18.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

//==========================================================================//
// 该分类的作用 : 为 NSObject 扩展一个交换两个方法实现的方法, 供需要使用黑魔法的子类调用 //
//=========================================================================//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzling)

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
