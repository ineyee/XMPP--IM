//
//  ProjectSingleton.m
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/24.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import "ProjectSingleton.h"

@implementation ProjectSingleton

static ProjectSingleton *singleton = nil;
+ (instancetype)sharedSingleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singleton = [[ProjectSingleton alloc] init];
    });
    
    return singleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    @synchronized(singleton) {
        
        if (singleton == nil) {
            
            singleton = [super allocWithZone:zone];
        }
        
        return singleton;
    }
}

- (instancetype)init {
    
    @synchronized(singleton) {
        
        self = [super init];
        if (self != nil) {
            
            // 一些属性的设置
            self.friendsListArray = [@[] mutableCopy];
            self.pre_newFriendArray = [@[] mutableCopy];
        }
        
        return self;
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    
    return self;
}

@end
