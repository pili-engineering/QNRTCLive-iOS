//
//  RCCRMessageModel.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCCRMessageModel : NSObject

/**
 用户信息
 */
@property(nonatomic, strong) RCUserInfo *userInfo;

/**
 会话类型
 */
@property(nonatomic, assign) RCConversationType conversationType;

/**
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/**
 消息ID
 */
@property(nonatomic, assign) long messageId;

/**
 消息方向
 */
@property(nonatomic, assign) RCMessageDirection messageDirection;

/**
 发送者的用户ID
 */
@property(nonatomic, strong) NSString *senderUserId;

/**
 消息的接收时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long receivedTime;

/**
 消息的发送时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long sentTime;

/**
 消息的类型名
 */
@property(nonatomic, strong) NSString *objectName;

/**
 消息的内容
 */
@property(nonatomic, strong) RCMessageContent *content;

/**
 消息的附加字段
 */
@property(nonatomic, strong) NSString *extra;

/**
 初始化消息Cell的数据模型
 
 @param rcMessage   消息实体
 @return            消息Cell的数据模型对象
 */
- (instancetype)initWithMessage:(RCMessage *)rcMessage;

@end
