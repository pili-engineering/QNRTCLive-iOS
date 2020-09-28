//
//  RCCRInputView.h
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCCRInputBarControl.h"

#define HeighInputBar 50.0f

/**
 输入工具栏的点击监听器
 */
@protocol RCCRInputViewDelegate;

/**
 输入框
 */
@interface RCCRInputView : UIView

/*!
 输入工具栏的点击回调监听
 */
@property(weak, nonatomic) id<RCCRInputViewDelegate> delegate;

/*!
 容器View
 */
@property(strong, nonatomic) UIView *inputContainerView;

/**
 文本输入框
 */
@property(strong, nonatomic) UITextView *inputTextView;

/**
 表情的按钮
 */
@property(strong, nonatomic) UIButton *emojiButton;

/**
 清空内容
 */
- (void)clearInputText;

- (id)initWithStatus:(RCCRBottomBarStatus)status;
@end


/**
 输入框的点击监听器
 */
@protocol RCCRInputViewDelegate <NSObject>

@optional

/**
 键盘即将显示的回调
 
 @param keyboardFrame 键盘最终需要显示的Frame
 */
- (void)keyboardWillShowWithFrame:(CGRect)keyboardFrame;

/**
 键盘即将隐藏的回调
 */
- (void)keyboardWillHide;

/**
 点击键盘Return按钮的回调
 
 @param inputControl 当前输入工具栏
 @param text         当前输入框中国的文本内容
 */
- (void)didTouchKeyboardReturnKey:(RCCRInputView *)inputControl text:(NSString *)text;

/**
 点击表情按钮的回调
 
 @param sender 表情按钮
 */
- (void)didTouchEmojiButton:(UIButton *)sender;


/**
 输入框中内容发生变化的回调
 
 @param inputTextView 文本输入框
 @param range         当前操作的范围
 @param text          插入的文本
 */
- (void)inputTextView:(UITextView *)inputTextView
shouldChangeTextInRange:(NSRange)range
      replacementText:(NSString *)text;

@end
