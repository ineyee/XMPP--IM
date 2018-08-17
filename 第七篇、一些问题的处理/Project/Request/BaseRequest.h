//
//  BaseRequest.h
//  BaseProject
//
//  Created by 意一yiyi on 2017/8/21.
//  Copyright © 2017年 意一yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BaseRequestReachabilityStatus) {
    
    BaseRequestReachabilityStatusUnknown = -1,
    BaseRequestReachabilityStatusNotReachable = 0,
    BaseRequestReachabilityStatusReachableViaWWAN = 1,
    BaseRequestReachabilityStatusReachableViaWiFi = 2,
};


@protocol BaseRequestDelegate <NSObject>

@optional

/**
 *  为子 request 中的每个请求添加共性参数
 *
 *  @param sourceParams    每个请求的个性参数
 *  @param targetParams    当我们使用 sourceParams, 经过添加共性参数之后, 我们用 *targetParams 指向新的参数就可以了
 */
- (void)handleParams:(NSDictionary *)sourceParams targetParams:(NSDictionary **)targetParams;

/**
 *  对请求回来的源数据进行预处理
 *
 *  @param rawData     源数据
 *  @param formatData  请求成功, 请求到了正确的状态码和真正要使用的数据, 我们用 *formatData = 我们对源数据进行预处理之后的数据就可以了
 *  @param error       请求成功, 但是请求到了错误的状态码和错误信息, 我们用 *error = 我们用错误状态码和错误信息自定义的 error 就可以了
 */
- (void)preHandleRawData:(id)rawData formatData:(id *)formatData error:(NSError **)error;

@end

@interface BaseRequest : NSObject<BaseRequestDelegate>

/// 当前的网络状态
@property (assign, nonatomic) BaseRequestReachabilityStatus reachabilityStatus;

+ (instancetype)sharedRequest;

/**
 *  网络状态监测
 */
- (void)startMonitoringReachabilityWithDefaultStyle:(BOOL)flag status:(void(^)(BaseRequestReachabilityStatus status))block;


- (void)get:(NSString *)urlString
     params:(NSDictionary *)params
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)post:(NSString *)urlString
      params:(NSDictionary *)params
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  以流的形式上传单个文件 : NSData 是存储 bytes 的一个对象, bytes 是 C 级别的, NSData 是面向对象的
 *
 *  @param  data            要上传文件的 data
 *  @param  mimeType        要上传文件的类型 : Image, Audio, Video
 *  @param  serverColumn    服务器上对应的处理该文件的字段
 */
- (void)upload:(NSString *)urlString
        params:(NSDictionary *)params
          data:(NSData *)data
      mimeType:(NSString *)mimeType
  serverColumn:(NSString *)serverColumn
      progress:(void (^)(NSString *progress))progress
       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  以流的形式上传多个文件
 *
 *  @param  datas       要上传的 datas
 *  @param  mimeTypes   要上传的 datas 的文件类型 : Image, Audio, Video
 */
- (void)upload:(NSString *)urlString
        params:(NSDictionary *)params
         datas:(NSArray<NSData *> *)datas
     mimeTypes:(NSArray<NSString *> *)mimeTypes
  serverColumn:(NSString *)serverColumn
      progress:(void (^)(NSString *progress))progress
       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
