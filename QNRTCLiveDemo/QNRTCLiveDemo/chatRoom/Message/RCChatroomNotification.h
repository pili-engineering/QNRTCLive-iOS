//
//  RCChatroomNotification.h
//  ChatRoom
//
//  Created by Jue on 2018/6/26.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface RCChatroomNotification : RCMessageContent

@property(nonatomic, copy) NSString *content;



@property(nonatomic, copy) NSString *extra;

@end
