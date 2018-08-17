//
//  ProjectHUD.h
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/23.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MBProgressHUDTextPosition) {
    
    MBProgressHUDTextPositionTop,
    MBProgressHUDTextPositionMiddle,
    MBProgressHUDTextPositionBottom
};

typedef NS_ENUM(NSInteger, MBProgressHUDResult) {
    
    MBProgressHUDResultSuccess,
    MBProgressHUDResultFail
};

@interface ProjectHUD : NSObject

#pragma mark - SystemHUD

+ (void)showSystemHUDToView:(UIView *)view;
+ (void)hideSystemHUDFromView:(UIView *)view;


#pragma mark - MBProgressHUD

/**
 *  显示文本, 自动隐藏
 */
+ (void)showMBProgressHUDToView:(UIView *)view withText:(NSString *)text atPosition:(MBProgressHUDTextPosition)position autohideAfter:(CGFloat)timeInterval completionHandlerAfterAutohide:(void(^)(void))completionHandler;

/**
 *  显示图片和文本, 自动隐藏
 */
+ (void)showMBProgressHUDToView:(UIView *)view withText:(NSString *)text image:(NSString *)imageName autohideAfter:(CGFloat)timeInterval completionHandlerAfterAutohide:(void(^)(void))completionHandler;

/**
 *  显示进度环, 自动隐藏
 */
// (1)步 : 请求开始前, 展示初始化进度提示
+ (void)showMBProgressHUDToView:(UIView *)view withInitProgressPrompt:(NSString *)prompt;
// (2)步 : 请求进行中, 实时更新 HUD 的进度和进度提示
+ (void)updateMBProgressHUDOnView:(UIView *)view withProgress:(CGFloat)progress progressPrompt:(NSString *)prompt;
// (3)步 : 请求结束后, 根据请求结果更新 HUD
+ (void)updateMBProgressHUDOnView:(UIView *)view withRequstResult:(MBProgressHUDResult)result progressPrompt:(NSString *)prompt autohideAfter:(CGFloat)timeInterval completionHandlerAfterAutohide:(void(^)(void))completionHandler;

/**
 *  显示 gif
 *  @param gifName  "xxx.gif"
 */
+ (void)showMBProgressHUDToView:(UIView *)view withGifName:(NSString *)gifName;

/**
 *  显示图片数组模拟 gif
 */
+ (void)showMBProgressHUDToView:(UIView *)view withImageNameArray:(NSArray<NSString *> *)imageNameArray;

/**
 *  隐藏 gif
 */
+ (void)hideMBProgressHUDFromView:(UIView *)view;

@end
