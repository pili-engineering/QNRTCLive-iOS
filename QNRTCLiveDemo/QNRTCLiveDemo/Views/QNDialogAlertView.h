//
//  QNDialogAlertView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNDialogAlertView;
@protocol QNDialogAlertViewDelegate <NSObject>

- (void)alertView:(QNDialogAlertView *)alertView didSelectedTitleIndex:(NSInteger)titleIndex;

@end

@interface QNDialogAlertView : UIView

@property (nonatomic, assign) id<QNDialogAlertViewDelegate> delegate;

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) NSDictionary *requestDic;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *userId;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title request:(BOOL)request content:(NSString *)content buttonArray:(NSArray *)buttonArray;

- (void)hideAlertView;
@end

NS_ASSUME_NONNULL_END
