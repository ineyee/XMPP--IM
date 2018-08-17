//
//  Macro_NotChange.h
//  BaseProject
//
//  Created by zhangshuo on 2017/10/18.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#ifndef Macro_NotChange_h
#define Macro_NotChange_h

//##################################################################//
//  可变动宏，开始
//##################################################################//

//=========== 颜色配置 ===========//
#define kThemeColor kColorWithRGB(99, 156, 210, 1)
#define kSecondThemeColor kColorWithRGB(240, 179, 62, 1)

//##################################################################//
//  可变动宏，结束
//##################################################################//


//##################################################################//
//  不可变动宏，开始
//##################################################################//

//=========== 系统版本 ===========//
#define kSystemVersion [[UIDevice currentDevice].systemVersion floatValue]
#define kSystemVersion_is_iOS8OrLater (kSystemVersion >= 8.0)
#define kSystemVersion_is_iOS9OrLater (kSystemVersion >= 9.0)
#define kSystemVersion_is_iOS10OrLater (kSystemVersion >= 10.0)
#define kSystemVersion_is_iOS11OrLater (kSystemVersion >= 11.0)


//=========== 机型 ===========//
#define kScreenSize [UIScreen mainScreen].bounds.size
#define kDevice_is_iPhone5 CGSizeEqualToSize(kScreenSize, CGSizeMake(320, 568))
#define kDevice_is_iPhone6 CGSizeEqualToSize(kScreenSize, CGSizeMake(375, 667))
#define kDevice_is_iPhone6Plus CGSizeEqualToSize(kScreenSize, CGSizeMake(414, 736))
#define kDevice_is_iPhoneX CGSizeEqualToSize(kScreenSize, CGSizeMake(375, 812))


//=========== 宽度和高度适配 ===========//

// 以 iPhone5 作原型图的适配参数
//#define kWidthSuitParameter (kDevice_Is_iPhone6Plus ? (414.0/320.0) : (kDevice_is_iPhone5 ? 1 : (375.0/320.0)))
//#define kHeightSuitParameter (kDevice_is_iPhone6Plus ? (736.0/568.0) : (kDevice_is_iPhone5 ? 1 : (kDevice_is_iPhoneX ? (734.0/568.0) : (667.0/568.0))))

// 以 iPhone6 作原型图的适配参数
#define kWidthSuitParameter (kDevice_is_iPhone6Plus ? (414.0/375.0) : (kDevice_is_iPhone5 ? (320.0/375.0) : 1))
#define kHeightSuitParameter (kDevice_is_iPhone6Plus ? (736.0/667.0) : (kDevice_is_iPhone5 ? (568.0/667.0) : (kDevice_is_iPhoneX ? (734.0/667.0) : 1)))// iPhoneX 竖向的安全域是 812 - 44 - 34 = 734

// 宽高适配
#define kSuitedWidth(width) ((width) * kWidthSuitParameter)
#define kSuitedHeight(height) ((height) * kHeightSuitParameter)


//=========== 字体适配 ===========//
#define kSuitedFontSize(fontSize) (kDevice_is_iPhone6Plus ? (fontSize + 1.0) : (fontSize))// 这里暂时选用 plus 比其它机型的字体大一号的做法

#define kFirstLevelFont [UIFont systemFontOfSize:16.0]
#define kSecondLevelFont [UIFont systemFontOfSize:14.0]
#define kThirdLevelFont [UIFont systemFontOfSize:12.0]

#define kFirstLevelTextColor kColorWithRGB(54, 54, 54, 1)
#define kSecondLevelTextColor kColorWithRGB(81, 81, 81, 1)
#define kThirdLevelTextColor kColorWithRGB(108, 108, 108, 1)


//=========== 常用屏幕参数 ===========//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight (kDevice_is_iPhoneX ? 44.0 : 20.0)
#define kNavigationBarHeight (kStatusBarHeight + 44.0)
#define kTabBarHeight (kDevice_is_iPhoneX ? 83.0 : 49.0)


//=========== 常用颜色 ===========//
#define kColorWithHex(hex, α) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:α]
#define kColorWithRGB(r, g, b, α) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:α]

#define kVCBackgroundColor kColorWithRGB(234, 234, 234, 1)

#define kDefaultNavigationBarTintColor kThemeColor
#define kDefaultNavigationBarTitleColor [UIColor whiteColor]
#define kDefaultNavigationBarBarButtonItemColor [UIColor whiteColor]

#define kDefaultTabBarTintColor [UIColor whiteColor]
#define kDefaultTabBarSelectedItemTintColor kThemeColor
#define kDefaultTabBarUnselectedItemTintColor kColorWithRGB(150, 150, 150, 1)


//=========== 其它常用宏 ===========//
#define kWindow [UIApplication sharedApplication].keyWindow
#define kNSUserDefaults [NSUserDefaults standardUserDefaults]
#define kNSNotificationCenter [NSNotificationCenter defaultCenter]


//=========== 判断字符串是否为空 ===========//
// 注意 : 之所以不通过给 NSString 添加分类的方法来显示, 而采用此处的宏, 是因为如果 str == nil 或者 str == NULL, 它根本就不是一个 NSString 类型, 所以就不会走 NSString 的分类方法, 会判断失败. 所以使用 NSString 正则表达式判断那个分类, 应该先判断是否为空之后再使用
#define kStringIsEmpty(string) ([string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"NULL"] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || ((NSString *)string).length == 0)

//##################################################################//
//  不可变动宏，结束
//##################################################################//

#endif /* Macro_NotChange_h */
