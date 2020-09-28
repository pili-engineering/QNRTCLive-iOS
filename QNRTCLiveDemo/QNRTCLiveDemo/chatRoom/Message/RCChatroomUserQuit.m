
#import "RCChatroomUserQuit.h"

@implementation RCChatroomUserQuit

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
      
      NSDictionary *userinfoDic = dictionary[@"user"];
                 [self decodeUserInfo:userinfoDic];
      
    
  }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:User:Quit";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

