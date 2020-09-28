//
//  QNRoomUserView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/8.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNRoomUserView : UIView

@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSMutableArray *traks;

@property (nonatomic, readonly) QNVideoView *cameraView;

- (QNTrackInfo *)trackInfoWithTrackId:(NSString *)trackId;
- (void)showCameraView;

@end

NS_ASSUME_NONNULL_END
