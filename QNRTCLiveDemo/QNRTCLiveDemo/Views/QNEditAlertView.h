//
//  QNEditAlertView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/21.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNEditAlertView;
@protocol QNEditAlertViewDelegate <NSObject>

- (void)editAlertView:(QNEditAlertView *)editAlertView didSelectedTitleIndex:(NSInteger)titleIndex text:(NSString *)text gender:(NSString *)gender;

@end

@interface QNEditAlertView : UIView
@property (nonatomic, assign) id<QNEditAlertViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame person:(BOOL)person title:(NSString *)title text:(NSString *)text;

- (void)hideAlertView;
@end

NS_ASSUME_NONNULL_END
