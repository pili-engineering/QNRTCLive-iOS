//
//  RCCRLiveModel.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>
// 移动端可做主播和观众，可进行直播和观看直播
// 复用次类，增加枚举来区分
typedef NS_ENUM(NSInteger , RCCRLiveMode) {
    /*
     观众
     */
    RCCRLiveModeAudience,
    /*
    主播
    */
    RCCRLiveModeHost
};
@interface RCCRLiveModel : NSObject

/**
 当前模式，主播或者观众
 */
@property(nonatomic , assign)RCCRLiveMode liveMode;


/**
 主播名称
 */
@property (nonatomic, copy) NSString *hostName;

/**
 主播头像
 */
@property (nonatomic, copy) NSString *hostPortrait;

/**
 封面
 */
@property(nonatomic , copy)NSString *cover;

/**
 观众数
 */
@property (nonatomic, assign) NSInteger audienceAmount;

/**
 粉丝数
 */
@property (nonatomic, assign) NSInteger fansAmount;

/**
 获赞数
 */
@property (nonatomic, assign) NSInteger praiseAmount;

/**
 获得礼物数
 */
@property (nonatomic, assign) NSInteger giftAmount;

/**
 关注数
 */
@property (nonatomic, assign) NSInteger attentionAmount;

/**
 直播观看地址
 */
@property(nonatomic , copy)NSString *liveUrl;

/**
 直播者 ID
 */
@property(nonatomic , copy)NSString *pubUserId;

/**
 房间 ID
 */
@property(nonatomic , copy)NSString *roomId;

/**
 room name
 */
@property(nonatomic , copy)NSString *roomName;

/**
 时间戳
 */
@property(nonatomic , copy)NSString *date;

@end
