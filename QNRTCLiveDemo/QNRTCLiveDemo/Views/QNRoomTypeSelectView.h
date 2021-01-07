//
//  QNRoomTypeSelectView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/9.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNRoomTypeSelectView;
@protocol QNRoomTypeSelectViewDelegate <NSObject>

- (void)typeSelectView:(QNRoomTypeSelectView *)typeSelectView didSelectedIndex:(NSInteger)titleIndex;

@end

@interface QNRoomTypeSelectView : UIView
@property (nonatomic, assign) id<QNRoomTypeSelectViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
