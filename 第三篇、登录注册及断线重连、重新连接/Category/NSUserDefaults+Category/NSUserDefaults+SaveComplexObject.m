//
//  NSUserDefaults+SaveComplexObject.m
//  BaseProject
//
//  Created by 意一yiyi on 2017/10/25.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import "NSUserDefaults+SaveComplexObject.h"

@implementation NSUserDefaults (SaveComplexObject)

- (void)yy_setComplexObject:(id)value forKey:(NSString *)defaultName {

    NSData *writeData = [NSKeyedArchiver archivedDataWithRootObject:value];
    [[NSUserDefaults standardUserDefaults] setObject:writeData forKey:defaultName];
}

- (id)yy_complexObjectForKey:(NSString *)defaultName {

    NSData *readData = [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
    return [NSKeyedUnarchiver unarchiveObjectWithData:readData];
}

@end
