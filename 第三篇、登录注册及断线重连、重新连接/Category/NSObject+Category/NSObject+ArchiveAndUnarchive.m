//
//  NSObject+ArchiveAndUnarchive.m
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/24.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import "NSObject+ArchiveAndUnarchive.h"
#import <objc/runtime.h>

@implementation NSObject (ArchiveAndUnarchive)

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    // 一个临时数据, 用来记录一个类成员变量的个数
    unsigned int ivarCount = 0;
    // 获取一个类所有的成员变量
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    
    // 变量成员变量列表
    for (int i = 0; i < ivarCount; i ++) {
        
        // 获取单个成员变量
        Ivar ivar = ivars[i];
        
        // 获取成员变量的名字并将其转换为 OC 字符串
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 获取该成员变量对应的值
        id value = [self valueForKey:ivarName];

        // 归档, 就是把对象 key-value 对一对一对的 encode
        [aCoder encodeObject:value forKey:ivarName];
    }
    
    // 释放 ivars
    free(ivars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    // 因为没有 superClass 了
    self = [self init];
    if (self != nil) {
        
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (int i = 0; i < ivarCount; i ++) {
            
            Ivar ivar = ivars[i];
            NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
            
            // 反归档, 就是把 key-value 对一对一对 decode
            id value = [aDecoder decodeObjectForKey:ivarName];
            
            // 赋值
            [self setValue:value forKey:ivarName];
        }
        
        free(ivars);
    }
    
    return self;
}

@end
