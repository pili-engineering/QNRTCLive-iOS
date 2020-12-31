//
//  QNVoiceCollectionViewCell.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNVoiceCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIButton *microphoneButtonView;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)configurateCollectionViewCell:(NSString *)name avatar:(NSString *)avatar state:(BOOL)state;

@end

NS_ASSUME_NONNULL_END
