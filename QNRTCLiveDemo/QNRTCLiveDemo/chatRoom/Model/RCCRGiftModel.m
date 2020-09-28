//
//  RCCEgiftModel.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/17.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRGiftModel.h"

@implementation RCCRGiftModel

- (instancetype)initWithMessage:(RCChatroomGift *)giftMessage {
    self = [super init];
    if (self) {
        self.giftId = giftMessage.id;
        self.giftNumber = giftMessage.number;
        self.giftImageName = giftMessage.id;
    }
    
    return self;
}

@end
