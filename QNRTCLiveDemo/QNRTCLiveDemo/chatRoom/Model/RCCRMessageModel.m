//
//  RCCRMessageModel.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/10.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRMessageModel.h"

@implementation RCCRMessageModel

- (instancetype)initWithMessage:(RCMessage *)rcMessage {
    self = [super init];
    if (self) {
        self.conversationType = rcMessage.conversationType;
        self.targetId = rcMessage.targetId;
        self.messageId = rcMessage.messageId;
        self.messageDirection = rcMessage.messageDirection;
        self.senderUserId = rcMessage.senderUserId;
        self.sentTime = rcMessage.sentTime;
        self.objectName = rcMessage.objectName;
        self.content = rcMessage.content;
        self.userInfo = nil;
        self.receivedTime = rcMessage.receivedTime;
        self.extra = rcMessage.extra;
    }
    
    return self;
}

@end
