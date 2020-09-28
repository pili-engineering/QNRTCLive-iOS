
#import "RCChatroomGift.h"

@implementation RCChatroomGift

- (NSData *)encode {
  NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
  
      
        if (self.id) {
          [dataDict setObject:self.id forKey:@"id"];
        } else {
           [dataDict setObject:@"" forKey:@"id"];
        }
      
  
      
        if (self.number) {
          
            [dataDict setObject:@(self.number) forKey:@"number"];
          
        }
      
  
      
        if (self.total) {
          
            [dataDict setObject:@(self.total) forKey:@"total"];
          
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
    
      
        self.id = [json objectForKey:@"id"];
      
      
      
    
      
      
      
        self.number = [[json objectForKey:@"number"] intValue];
      
    
      
      
      
        self.total = [[json objectForKey:@"total"] intValue];
      
    
      
        self.extra = [json objectForKey:@"extra"];
      
      NSDictionary *userinfoDic = dictionary[@"user"];
                      [self decodeUserInfo:userinfoDic];
      
    
  }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Gift";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

