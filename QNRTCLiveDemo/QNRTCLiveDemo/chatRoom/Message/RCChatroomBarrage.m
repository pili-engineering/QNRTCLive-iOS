
#import "RCChatroomBarrage.h"

@implementation RCChatroomBarrage

- (NSData *)encode {
  NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
  
      
        if (self.type) {
          
            [dataDict setObject:@(self.type) forKey:@"type"];
          
        }
      
  
      
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
      
  if (self.senderUserInfo) {
       [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
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
    
      
      
      
        self.type = [[json objectForKey:@"type"] intValue];
      
    
      
        self.content = [json objectForKey:@"content"];
      
      
      
    
      
        self.extra = [json objectForKey:@"extra"];
      
      
      NSDictionary *userinfoDic = dictionary[@"user"];
                     [self decodeUserInfo:userinfoDic];
    
  }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Barrage";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

