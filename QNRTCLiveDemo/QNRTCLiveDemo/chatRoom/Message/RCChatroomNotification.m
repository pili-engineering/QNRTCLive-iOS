//
//  RCChatroomNotification.m
//  ChatRoom
//
//  Created by Jue on 2018/6/26.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCChatroomNotification.h"

@implementation RCChatroomNotification

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    
    
    if (self.content) {
        [dataDict setObject:self.content forKey:@"content"];
    } else {
        [dataDict setObject:@"" forKey:@"content"];
    }
    
    
    
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    } else {
        [dataDict setObject:@"" forKey:@"extra"];
    }
    
    
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json) {
        
        
        
        self.content = [json objectForKey:@"content"];
        
        
        
        
        
        self.extra = [json objectForKey:@"extra"];
        
        
        
        
    }
}

+ (NSString *)getObjectName {
    return @"RC:Chatroom:Notification";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return 0;
}

@end
