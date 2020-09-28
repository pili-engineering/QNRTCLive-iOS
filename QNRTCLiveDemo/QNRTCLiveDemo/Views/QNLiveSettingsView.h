//
//  QNLiveSettingsView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveSettingsView;
@protocol QNLiveSettingsViewDelegate <NSObject>

- (void)settingsView:(QNLiveSettingsView *)settingsView didSelectedIndex:(NSInteger)titleIndex enable:(BOOL)enable;

@end


@interface QNLiveSettingsView : UIView

@property (nonatomic, assign) id<QNLiveSettingsViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSMutableArray *)listArray;

- (void)updateCameraBack:(BOOL)isBack;
@end

NS_ASSUME_NONNULL_END
