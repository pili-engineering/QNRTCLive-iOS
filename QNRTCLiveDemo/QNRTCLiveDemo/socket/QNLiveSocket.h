//
//  QNLiveSocket.h
//  QNRTCLiveDemo
//
//  Created by 何云旗 on 2020/9/15.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveSocket;
typedef NS_ENUM(NSUInteger, QNLiveSocketStats)
{
    
    QNLiveSocketStatsIdel = 0,
    
    QNLiveSocketStatsConnected,
    
    QNLiveSocketStatsReConnecting,
    
    QNLiveSocketStatsDisConnected
};

@protocol QNLiveSocketDelegate <NSObject>

-(void)qnLiveWebsocketDidConnect:(QNLiveSocket*)socket;

-(void)qnLiveWebsocketDidDisconnect:(QNLiveSocket*)socket error:(NSError*)error;

//长连接建立结果
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveAuthResponse:(NSDictionary*)dic;

// 服务端对发起 PK 请求回应
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveStartPKResponse:(NSDictionary*)dic;

//有人发来 PK 请求
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveOnPKOffer:(NSDictionary*)dic;

//回复 PK 请求处理结果
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveAnswerPKResponse:(NSDictionary*)dic;

// PK 请求被回应推送
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveOnPKAnswer:(NSDictionary*)dic;

//结束 PK 返回
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveEndPKResponse:(NSDictionary*)dic;

//结束 PK 通知
-(void)qnLiveWebsocket:(QNLiveSocket*)socket didReceiveOnPKEnd:(NSDictionary*)dic;

@end

@interface QNLiveSocket : NSObject

@property (nonatomic, weak) id<QNLiveSocketDelegate> delegate;

@property (nonatomic, strong) dispatch_queue_t operationQueue;

@property (nonatomic, assign) QNLiveSocketStats stats;

@property (nonatomic, assign) NSInteger pongTimeout;

- (void)connectWithURL:(NSURL *)URL;

- (void)disconnect;

- (void)joinWithToken:(NSString *)token
                msgsn:(NSNumber *)msgsn;

- (void)startPK:(NSString *)pkRoomID;

- (void)replyPK:(NSString *)pkRoomID
         accept:(BOOL)accept;

- (void)endPK:(NSString *)pkRoomID;


@end

NS_ASSUME_NONNULL_END
