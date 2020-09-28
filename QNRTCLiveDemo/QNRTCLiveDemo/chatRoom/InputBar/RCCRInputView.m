//
//  RCCRInputView.m
//  ChatRoom
//
//  Created by 罗骏 on 2018/5/11.
//  Copyright © 2018年 罗骏. All rights reserved.
//

#import "RCCRInputView.h"

@interface RCCRInputView () <UITextViewDelegate>

@end

@implementation RCCRInputView

//  初始化
- (id)initWithStatus:(RCCRBottomBarStatus)status {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self initializedSubViews];
        [self registerNotification];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_inputContainerView setFrame:self.bounds];
    [_inputTextView setFrame:CGRectMake(10, 7, self.bounds.size.width - 60, 36)];
    [_emojiButton setFrame:CGRectMake(self.bounds.size.width - 40, 10, 30, 31)];
}

#pragma mark <UITextViewDelegate>
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
        [self.delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
    }
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didTouchKeyboardReturnKey:text:)]) {
            NSString *_needToSendText = textView.text;
            NSString *_formatString =
            [_needToSendText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [_formatString length]) {
                
            } else {
                //  发送点击事件
                [self.delegate didTouchKeyboardReturnKey:self text:[_needToSendText copy]];
            }
        }
        return NO;
    }
    return YES;
}

- (void)didTouchEmojiDown:(UIButton *)sender {
    [_emojiButton setSelected:!sender.selected];
    [self.delegate didTouchEmojiButton:sender];
}

- (void)inputBarDidReceiveKeyboardWillShowNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBeginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
        UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSInteger animationCurveOption = (animationCurve << 16);
        
        double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:animationCurveOption
                         animations:^{
                             if ([self.delegate respondsToSelector:@selector(keyboardWillShowWithFrame:)]) {
                                 [self.delegate keyboardWillShowWithFrame:keyboardEndFrame];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)inputBarDidReceiveKeyboardWillHideNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardBeginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
        UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSInteger animationCurveOption = (animationCurve << 16);
        
        double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:animationCurveOption
                         animations:^{
                             if (!CGRectEqualToRect(keyboardBeginFrame, keyboardEndFrame)) {
                                 if ([self.delegate respondsToSelector:@selector(keyboardWillHide)]) {
                                     [self.delegate keyboardWillHide];
                                 }
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)clearInputText {
    dispatch_async(dispatch_get_main_queue(), ^{
       [_inputTextView setText:@""];
    });
    
}

- (void)initializedSubViews {
    [self addSubview:self.inputContainerView];
    [_inputContainerView addSubview:self.inputTextView];
    [_inputContainerView addSubview:self.emojiButton];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputBarDidReceiveKeyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputBarDidReceiveKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - UI

- (UIView *)inputContainerView {
    if (!_inputContainerView) {
        _inputContainerView = [[UIView alloc] init];
        [_inputContainerView setBackgroundColor:[UIColor clearColor]];
    }
    return _inputContainerView;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        [_inputTextView setTextColor:[UIColor blackColor]];
        [_inputTextView setFont:[UIFont systemFontOfSize:16]];
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        [_inputTextView setBackgroundColor:[UIColor colorWithRed:248 / 255.f green:248 / 255.f blue:248 / 255.f alpha:1]];
        [_inputTextView setEnablesReturnKeyAutomatically:YES];  //内容为空，返回按钮不可点击
        [_inputTextView.layer setCornerRadius:4];
        [_inputTextView.layer setMasksToBounds:YES];
        [_inputTextView.layer setBorderWidth:0.3f];
        [_inputTextView.layer setBorderColor:[UIColor grayColor].CGColor];
        [_inputTextView.layoutManager setAllowsNonContiguousLayout:YES];    //默认从顶部开始显示
        [_inputTextView setDelegate:self];
//        [_inputTextView setAccessibilityLabel:@"chat_input_textView"];
    }
    return _inputTextView;
}

- (UIButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [[UIButton alloc] init];
        [_emojiButton setImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
        [_emojiButton setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
        [_emojiButton setExclusiveTouch:YES];
        [_emojiButton addTarget:self action:@selector(didTouchEmojiDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
