//
//  RCCRUtilities.m
//  ChatRoom
//
//  Created by 孙承秀 on 2018/5/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//
#import "RCCRUtilities.h"
@interface RCCRTimerProxy : NSObject
- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    complement:(void (^)(void))complement;
- (void)invalidate;
@end
@implementation RCCRTimerProxy{
  NSTimer *_timer;
  void (^_complement)(void);
}


- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    complement:(void (^)(void))complement {
  if (self = [super init]) {
    _complement = complement;
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerDidFire:)
                                            userInfo:nil
                                             repeats:repeats];
  }
  return self;
}

- (void)invalidate {
  [_timer invalidate];
}

- (void)timerDidFire:(NSTimer *)timer {
  _complement();
}

@end

@interface RCCRUtilities(){
    RCCRTimerProxy *_timer;
}
/**
 是否封禁
 */
@property(nonatomic , assign)BOOL locked;;

/**
 roomid
 */
@property(nonatomic , copy)NSString *roomId;
@end
@implementation RCCRUtilities
+(instancetype)instance{
    static dispatch_once_t onceToken;
    static RCCRUtilities *ut = nil;
    dispatch_once(&onceToken, ^{
        ut = [[RCCRUtilities alloc] init];
    });
    return ut;
}
-(void)blockRoom:(NSString *)roomId duration:(int)duration{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _locked = YES;
    _roomId = roomId;
    __weak typeof(self)weakSelf = self;
    _timer = [[RCCRTimerProxy alloc] initWithInterval:duration*60 repeats:NO complement:^{
        weakSelf.locked= NO;
        weakSelf.roomId = nil;
    }];
}
-(BOOL)isLockedRoom:(NSString *)roomId{
    if ([roomId isEqualToString:self.roomId] && self.locked) {
        return YES;
    } else {
        return NO;
    }
}
+ (NSString *)getDemoVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2
{
    NSArray *list1 = [version1 componentsSeparatedByString:@"."];
    NSArray *list2 = [version2 componentsSeparatedByString:@"."];
    for (int i = 0; i < list1.count || i < list2.count; i++)
    {
        NSInteger a = 0, b = 0;
        if (i < list1.count) {
            a = [list1[i] integerValue];
        }
        if (i < list2.count) {
            b = [list2[i] integerValue];
        }
        if (a > b) {
            return 1;//version1大于version2
        } else if (a < b) {
            return -1;//version1小于version2
        }
    }
    return 0;//version1等于version2
    
}

@end
