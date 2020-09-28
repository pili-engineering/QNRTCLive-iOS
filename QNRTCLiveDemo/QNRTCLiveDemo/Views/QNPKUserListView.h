//
//  QNPKUserListView.h
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNPKUserListView;
@protocol QNPKUserListViewDelegate <NSObject>

- (void)listView:(QNPKUserListView *)listView didSelectedIndex:(NSInteger)titleIndex;

@end

@interface QNPKUserListView : UIView

@property (nonatomic, assign) id<QNPKUserListViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *listArray;
@property (nonatomic, strong) UIButton *exitButton;

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSMutableArray *)listArray state:(NSInteger)state;

- (void)updateListArray:(NSMutableArray *)array;
@end

NS_ASSUME_NONNULL_END
