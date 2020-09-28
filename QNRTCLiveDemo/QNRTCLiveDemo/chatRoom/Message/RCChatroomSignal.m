//
//  RCChatroomSignal.m
//  QNRTCLiveDemo
//
//  Created by 何云旗 on 2020/9/25.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "RCChatroomSignal.h"

@implementation RCChatroomSignal

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.id) {
      [dataDict setObject:self.id forKey:@"id"];
    } else {
       [dataDict setObject:@"" forKey:@"id"];
    }
    if (self.senderUserInfo) {
        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    }
    if (self.extra) {
      [dataDict setObject:self.extra forKey:@"extra"];
    } else {
       [dataDict setObject:@"" forKey:@"extra"];
    }
  
    [dataDict setObject:self.signal forKey:@"signal"];
      
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
      self.id = [json objectForKey:@"id"];
      
      self.extra = [json objectForKey:@"extra"];
      
      self.signal = [json objectForKey:@"signal"];
      
      NSDictionary *userinfoDic = dictionary[@"user"];
                 [self decodeUserInfo:userinfoDic];
  }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Signal";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end
