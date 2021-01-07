//
//  QNRoomUserView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/8.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNRoomUserView.h"

@interface QNRoomUserView()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong, readwrite) QNVideoView *cameraView;

@end

@implementation QNRoomUserView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:random()%200/255.0 green:random()%200/255.0 blue:random()%100/255.0 alpha:1];
        
        _traks = [[NSMutableArray alloc] init];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.numberOfLines = 0;
        _nameLabel.textAlignment = NSTextAlignmentRight;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        _nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.right.mas_equalTo(self.mas_right).offset(-15);
        }];
        
        _cameraView = [[QNVideoView alloc] init];
        _cameraView.hidden = YES;
        [self insertSubview:_cameraView atIndex:0];
        
        [_cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;

    dispatch_async(dispatch_get_main_queue(), ^{
//        self.nameLabel.text = userId;
    });
}

- (void)showCameraView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cameraView.hidden = NO;
        [self.cameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [UIView animateWithDuration:.25 animations:^{
            [self layoutIfNeeded];
        }];
    });
}

- (QNTrackInfo *)trackInfoWithTrackId:(NSString *)trackId {
    for (QNTrackInfo *trackInfo in self.traks) {
        if ([trackInfo.trackId isEqualToString:trackId]) {
            return trackInfo;
        }
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
