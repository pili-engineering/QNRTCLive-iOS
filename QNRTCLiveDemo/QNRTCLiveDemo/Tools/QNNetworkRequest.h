//
//  QNNetworkRequest.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/8.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QNRequestType) {
    QNRequestTypePost,
    QNRequestTypeGet,
    QNRequestTypeDelete,
    QNRequestTypePut
};

typedef void(^QNSuccess)(NSDictionary *resultDic);
typedef void(^QNError)(NSError *error);

@interface QNNetworkRequest : NSObject

@property (nonatomic, copy) QNSuccess success;
@property (nonatomic, copy) QNError error;

+ (void)requestWithUrl:(NSString *)urlString requestType:(QNRequestType)requestType dic:(nullable NSDictionary *)dic header:(nullable id)header success:(QNSuccess)success error:(QNError)error;

@end

NS_ASSUME_NONNULL_END
