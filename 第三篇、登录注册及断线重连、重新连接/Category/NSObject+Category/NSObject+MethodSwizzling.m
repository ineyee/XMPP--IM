//
//  NSObject+MethodSwizzling.m
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/18.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import "NSObject+MethodSwizzling.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzling)

+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
