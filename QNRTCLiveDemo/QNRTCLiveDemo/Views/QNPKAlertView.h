//
//  QNPKAlertView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNPKAlertView;
@protocol QNPKAlertViewDelegate <NSObject>

- (void)alertView:(QNPKAlertView *)alertView didSelectedTitleIndex:(NSInteger)titleIndex;

@end

@interface QNPKAlertView : UIView

@property (nonatomic, assign) id<QNPKAlertViewDelegate> delegate;

@property (nonatomic, copy) NSString *roomId;

- (instancetype)initWithFrame:(CGRect)frame request:(BOOL)request content:(NSString *)content;

- (void)hideAlertView;
@end

NS_ASSUME_NONNULL_END
