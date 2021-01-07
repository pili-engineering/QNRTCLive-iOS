//
//  QNEditAlertView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/21.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNEditAlertView.h"

@interface QNEditAlertView()
<
UITextFieldDelegate
>

@property (nonatomic, strong) UIView *homeView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *genderLabel;
@property (nonatomic, strong) UIButton *maleButton;
@property (nonatomic, strong) UIButton *femaleButton;

@property (nonatomic, copy) NSString *gender;

@end


@implementation QNEditAlertView


- (instancetype)initWithFrame:(CGRect)frame person:(BOOL)person title:(nonnull NSString *)title  text:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = QN_COLOR_RGB(0, 0, 0, 0.5);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
        [self addGestureRecognizer:tap];
        
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        CGFloat homeHeight = 185;
        CGFloat space = 40;
        if (person) {
            homeHeight = 225;
            space = 70;
        }
        
        self.homeView = [[UIView alloc] initWithFrame:CGRectMake(40, height/2 - homeHeight/2 - space, width - 80, homeHeight)];
        self.homeView.backgroundColor = [UIColor whiteColor];
        self.homeView.layer.cornerRadius = 6;
        [self addSubview:_homeView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, width - 80, 41)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = QN_FONT_REGULAR(16.0);
        _titleLabel.textColor = QN_COLOR_RGB(30, 139, 255, 1);
        _titleLabel.text = title;
        [self.homeView addSubview:_titleLabel];
        
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, homeHeight - 56, 86, 32)];
        _cancelButton.titleLabel.font = QN_FONT_REGULAR(16);
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
        _cancelButton.layer.cornerRadius = 16;
        _cancelButton.clipsToBounds = YES;
        [self.homeView addSubview:_cancelButton];
        
        _sureButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 80 - 86 - 50, homeHeight - 56, 86, 32)];
        _sureButton.titleLabel.font = QN_FONT_REGULAR(16);
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        _sureButton.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
        _sureButton.layer.cornerRadius = 16;
        _sureButton.clipsToBounds = YES;
        [self.homeView addSubview:_sureButton];

        _cancelButton.tag = 100;
        [_cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _sureButton.tag = 101;
        [_sureButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 48, width - 80 - 40, 28)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = QN_FONT_REGULAR(14.0);
        _nameLabel.textColor = [UIColor blackColor];
        [self.homeView addSubview:_nameLabel];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, width - 80 - 40, 30)];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = QN_FONT_REGULAR(14);
        _textField.textColor = [UIColor blackColor];
        _textField.delegate = self;
        _textField.text = text;
        [self.homeView addSubview:_textField];

        UIView *lineTwoView = [[UIView alloc] initWithFrame:CGRectMake(20, 110, width - 80 - 40, 0.8)];
        lineTwoView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
        [self.homeView addSubview:lineTwoView];
        
        if (person) {
            _nameLabel.text = @"请输入昵称";
            
            _genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 122, 60, 28)];
            _genderLabel.textAlignment = NSTextAlignmentLeft;
            _genderLabel.font = QN_FONT_REGULAR(14.0);
            _genderLabel.textColor = [UIColor blackColor];
            _genderLabel.text = @"性别";
            [self.homeView addSubview:_genderLabel];
            
            _maleButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 120, 32, 32)];
            [_maleButton setImage:[UIImage imageNamed:@"icon_Set switch_nor"] forState:UIControlStateNormal];
            [_maleButton setImage:[UIImage imageNamed:@"icon_Set switch_sel"] forState:UIControlStateSelected];
            [self.homeView addSubview:_maleButton];
            
            UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(117, 122, 28, 28)];
            maleLabel.textAlignment = NSTextAlignmentCenter;
            maleLabel.font = QN_FONT_REGULAR(14.0);
            maleLabel.textColor = [UIColor blackColor];
            maleLabel.text = @"男";
            [self.homeView addSubview:maleLabel];
            
            _femaleButton = [[UIButton alloc] initWithFrame:CGRectMake(178, 120, 32, 32)];
            [_femaleButton setImage:[UIImage imageNamed:@"icon_Set switch_nor"] forState:UIControlStateNormal];
            [_femaleButton setImage:[UIImage imageNamed:@"icon_Set switch_sel"] forState:UIControlStateSelected];

            [self.homeView addSubview:_femaleButton];
            
            UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 122, 28, 28)];
            femaleLabel.textAlignment = NSTextAlignmentCenter;
            femaleLabel.font = QN_FONT_REGULAR(14.0);
            femaleLabel.textColor = [UIColor blackColor];
            femaleLabel.text = @"女";
            [self.homeView addSubview:femaleLabel];

            _maleButton.selected = YES;
            _femaleButton.selected = NO;
            _gender = @"male";

            _maleButton.tag = 200;
            [_maleButton addTarget:self action:@selector(genderButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            _femaleButton.tag = 201;
            [_femaleButton addTarget:self action:@selector(genderButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        } else {
            _nameLabel.text = @"请输入房间名";
            
            _gender = @"";
        }

       
    }
    return self;
}

- (void)hideAlertView {
    [self removeFromSuperview];
}

- (void)genderButtonAction:(UIButton *)button {
    NSInteger index = button.tag - 200;
    if (index == 0) {
        _gender = @"male";
        _maleButton.selected = YES;
        _femaleButton.selected = NO;
    } else{
        _gender = @"female";
        _maleButton.selected = NO;
        _femaleButton.selected = YES;
    }
}

- (void)buttonAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAlertView:didSelectedTitleIndex:text:gender:)]) {
        [self.delegate editAlertView:self didSelectedTitleIndex:index text:self.textField.text gender:_gender];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
