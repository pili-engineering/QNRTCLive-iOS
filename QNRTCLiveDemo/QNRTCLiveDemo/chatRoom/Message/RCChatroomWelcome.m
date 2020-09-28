
#import "RCChatroomWelcome.h"

@implementation RCChatroomWelcome

- (NSData *)encode {
  NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
  
      
        if (self.id) {
          [dataDict setObject:self.id forKey:@"id"];
        } else {
           [dataDict setObject:@"" forKey:@"id"];
        }
      
  
      
        if (self.counts) {
          
            [dataDict setObject:@(self.counts) forKey:@"counts"];
          
        }
      
  
      
        if (self.rank) {
          
            [dataDict setObject:@(self.rank) forKey:@"rank"];
          
        }
      
  
      
        if (self.level) {
          
            [dataDict setObject:@(self.level) forKey:@"level"];
          
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
      
      
      
    
      
      
      
        self.counts = [[json objectForKey:@"counts"] intValue];
      
    
      
      
      
        self.rank = [[json objectForKey:@"rank"] intValue];
      
    
      
      
      
        self.level = [[json objectForKey:@"level"] intValue];
      
    
      
        self.extra = [json objectForKey:@"extra"];
      
      NSDictionary *userinfoDic = dictionary[@"user"];
                    [self decodeUserInfo:userinfoDic];
      
    
  }
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Welcome";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

