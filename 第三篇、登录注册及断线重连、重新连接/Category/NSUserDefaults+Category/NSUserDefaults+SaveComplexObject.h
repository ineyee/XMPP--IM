//
//  NSUserDefaults+SaveComplexObject.h
//  BaseProject
//
//  Created by 意一yiyi on 2017/10/25.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (SaveComplexObject)

- (void)yy_setComplexObject:(id)value forKey:(NSString *)defaultName;
- (id)yy_complexObjectForKey:(NSString *)defaultName;

@end
