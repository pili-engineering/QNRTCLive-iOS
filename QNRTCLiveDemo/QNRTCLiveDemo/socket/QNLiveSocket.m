//
//  QNLiveSocket.m
//  QNRTCLiveDemo
//
//  Created by 何云旗 on 2020/9/15.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNLiveSocket.h"
#import "JFRWebSocket.h"

#define kQNLiveSocketURL @"ws://10.200.20.28:8082/qlive"


const static NSInteger kQNLiveWebSocketTimeout = 10;
const static NSTimeInterval kQNLiveWebSocketPingInterval = 5;

NSString *const QNLiveWebSocketErrorDomain = @"QNLiveWebSocketErrorDomain";

@interface QNLiveSocket()<JFRWebSocketDelegate>

@property (nonatomic, strong) JFRWebSocket *webSocket;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) NSDate *lastSendTime;

@property (nonatomic, strong) NSDate *lastReceiveTime;

@end

@implementation QNLiveSocket

- (instancetype)init {
    if (self = [super init]) {
        self.stats = QNLiveSocketStatsIdel;
    }
    return self;
}

- (void)connectWithURL:(NSURL *)URL {
    dispatch_async(self.operationQueue, ^{
        [self innerDisconnectWithReason:@"Signal connect with URL"];
        
        self.webSocket = [[JFRWebSocket alloc]initWithURL:URL protocols:@[@"chat",@"superchat"]];

        self.webSocket.delegate = self;
        self.webSocket.queue = self.operationQueue;
        [self.webSocket connect];
        [self startTimer];
    });
    
}

- (void)disconnect {
    dispatch_async(self.operationQueue, ^{
        self.stats = QNLiveSocketStatsDisConnected;
        NSDictionary *dic = @{@"rpcID": @"3",
                              };
        [self sendDictionary:dic withCommandType:@"disconnect"];
        [self innerDisconnectWithReason:nil];
       
    });
}

- (void)joinWithToken:(NSString *)token
                msgsn:(NSNumber *)msgsn {
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"token": token,
                              @"rpcID": @"0",
                              };
        [self sendDictionary:dic withCommandType:@"auth"];
    });
}

- (void)startPK:(NSString *)pkRoomID {
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"pkRoomID": pkRoomID,
                              @"rpcID": @"1",
                              };
        [self sendDictionary:dic withCommandType:@"start-pk"];
    });
}

- (void)replyPK:(NSString *)pkRoomID
         accept:(BOOL)accept {
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"pkRoomID": pkRoomID,
                              @"rpcID": @"3",
                              @"accept":@(accept)
                              };
        [self sendDictionary:dic withCommandType:@"answer-pk"];
    });
}

- (void)endPK:(NSString *)pkRoomID {
    dispatch_async(self.operationQueue, ^{
        NSDictionary *dic = @{@"pkRoomID": pkRoomID,
                              @"rpcID": @"7",
                              };
        [self sendDictionary:dic withCommandType:@"end-pk"];
    });
}


#pragma mark - Private

- (void)innerDisconnectWithReason:(NSString *)reason {
    [self stopTimer];
    if (self.webSocket.isConnected) {
         [self.webSocket disconnect];
    }
    self.webSocket.delegate = nil;
    self.webSocket = nil;
}

- (void)sendPong {
    dispatch_async(self.operationQueue, ^{
        [self sendDictionary:nil withCommandType:@"pong"];
    });
}

- (void)sendPing {
    dispatch_async(self.operationQueue, ^{
        [self sendDictionary:nil withCommandType:@"ping"];
    });
}

- (void)sendDictionary:(NSDictionary *)dic withCommandType:(NSString *)type {
    NSString *dicString = @"{}";
    if (dic) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        if (error) {
            return;
        }

        dicString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!dicString) {
            return;
        }
    }

    NSString *sendString = [NSString stringWithFormat:@"%@=%@", type, dicString];
    [self.webSocket writeString:sendString];
}

#pragma mark JFRWebSocketDelegate

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    self.stats = QNLiveSocketStatsConnected;
    if ([self.delegate respondsToSelector:@selector(qnLiveWebsocketDidConnect:)]) {
           [self.delegate qnLiveWebsocketDidConnect:self];
    }
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    if (self.stats != QNLiveSocketStatsDisConnected) {
        self.stats = QNLiveSocketStatsReConnecting;
        
    }else {
        self.stats = QNLiveSocketStatsDisConnected;
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocketDidDisconnect:error:)]) {
               [self.delegate qnLiveWebsocketDidDisconnect:self error:error];
        }
        [self stopTimer];
    }
    
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    if (![string isKindOfClass:[NSString class]]) {
        NSLog(@"invaild message: %@", string);
        return;
    }

    NSRange range = [string rangeOfString:@"="];
    if (range.location == NSNotFound) {
        NSLog(@"invalid res message, can't find '='");
        return;
    }

    NSString *type = [string substringToIndex:range.location];
    NSString *body = [string substringFromIndex:range.location + 1];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        NSLog(@"convert body: %@ to NSData failed", body);
        return;
    }

    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"convert data NSDictionary failed, error: %@", error);
        return;
    }
    
    self.lastReceiveTime = [NSDate date];
    
    if ([type isEqualToString:@"ping"]) {
        [self sendPong];
        return;
    }
    
    if ([type isEqualToString:@"auth-res"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveAuthResponse:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveAuthResponse:dic];
        }
        return;
    }
    
    if ([type isEqualToString:@"start-pk-res"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveStartPKResponse:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveStartPKResponse:dic];
        }
        return;
    }
    
    if ([type isEqualToString:@"on-pk-offer"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveOnPKOffer:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveOnPKOffer:dic];
        }
        return;
    }
    
    if ([type isEqualToString:@"answer-pk-res"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveAnswerPKResponse:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveAnswerPKResponse:dic];
        }
        return;
    }
    
    if ([type isEqualToString:@"on-pk-answer"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveOnPKAnswer:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveOnPKAnswer:dic];
        }
        return;
    }
    
    if ([type isEqualToString:@"end-pk-res"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveEndPKResponse:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveEndPKResponse:dic];
        }
        return;
    }
    
    if ([type isEqualToString:@"on-pk-end"]) {
        if ([self.delegate respondsToSelector:@selector(qnLiveWebsocket:didReceiveOnPKEnd:)]) {
            [self.delegate qnLiveWebsocket:self didReceiveOnPKEnd:dic];
        }
        return;
    }
    
}

- (void)startTimer {
    NSLog(@"startTimer");

    if (self.timer) {
        return;
    }
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.operationQueue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC, 0.3 * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        if (weakSelf.lastReceiveTime) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:weakSelf.lastReceiveTime];
            if (interval > self.pongTimeout) {
                NSError *error = [NSError errorWithDomain:QNLiveWebSocketErrorDomain
                                                     code:1006
                                                 userInfo:@{NSLocalizedDescriptionKey : @"ping time out"}];
                if ([weakSelf.delegate respondsToSelector:@selector(qnLiveWebsocketDidDisconnect:error:)]) {
                    [weakSelf.delegate qnLiveWebsocketDidDisconnect:weakSelf error:error];
                }

                [weakSelf stopTimer];
                return ;
            }else {
                if (self.stats == QNLiveSocketStatsReConnecting) {
                    [self.webSocket connect];
                }
            }
        }

        if (weakSelf.lastSendTime) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:weakSelf.lastSendTime];
            if (interval > kQNLiveWebSocketPingInterval) {
                [weakSelf.webSocket writePing:nil];
                NSLog(@"sendPing");
                weakSelf.lastSendTime = [NSDate date];
            }
        }
        else {
            [weakSelf.webSocket writePing:nil];
            NSLog(@"sendPing");
            weakSelf.lastSendTime = [NSDate date];
        }
    });
    dispatch_resume(self.timer);
}

- (void)stopTimer {
    NSLog(@"stopTimer");

    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }

    self.lastReceiveTime = nil;
    self.lastSendTime = nil;
}

@end
