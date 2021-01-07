//
//  QNAudioUserListView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAudioUserListView : UIView

@property (nonatomic, strong, readonly) NSMutableArray *listArray;
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, readonly) NSInteger state;

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSMutableArray *)listArray state:(NSInteger)state;

- (void)updateListArray:(NSMutableArray *)array;
- (void)setAdminUserId:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
