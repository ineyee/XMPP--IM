//
//  UIView+ViewController.m
//  GuoRanHao_Merchant
//
//  Created by 意一yiyi on 2017/12/19.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import "UIView+ViewController.h"

@implementation UIView (ViewController)

- (UIViewController *)viewController {
    
    UIResponder *next = self.nextResponder;
    
    while (next != nil) {
        
        if ([next isKindOfClass:[UIViewController class]]) {
            
            return (UIViewController *)next;
        }
        
        next = next.nextResponder;
    }
    
    return nil;
}

@end
