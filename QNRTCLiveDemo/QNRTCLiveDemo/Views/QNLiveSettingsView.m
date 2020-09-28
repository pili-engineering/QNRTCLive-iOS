//
//  QNLiveSettingsView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNLiveSettingsView.h"
#import "QNSetTableViewCell.h"

static NSString *cellIdentifier = @"SettingsTableViewCell";

@interface QNLiveSettingsView()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *setTableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, assign) BOOL isBack;

@end

@implementation QNLiveSettingsView

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSMutableArray *)listArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self layoutCornerRadius];

        _listArray = [NSMutableArray arrayWithArray:listArray];
        
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 51)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = QN_FONT_REGULAR(16.0);
        _titleLabel.textColor = QN_COLOR_RGB(30, 139, 255, 1);
        _titleLabel.text = @"设置";
        [self addSubview:_titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 51, width, 0.5)];
        lineView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
        [self addSubview:lineView];
        
        _setTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 52, width, height - 52) style:UITableViewStylePlain];
        _setTableView.delegate = self;
        _setTableView.dataSource = self;
        [_setTableView registerClass:[QNSetTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _setTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_setTableView];
    }
    return self;
}

- (void)updateCameraBack:(BOOL)isBack {
    _isBack = isBack;
    [_setTableView reloadData];
}

- (void)layoutCornerRadius {
    UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerTopRight;

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)enableButtonAction:(UIButton *)button {
    button.selected = YES;
    NSInteger index = button.tag - 100;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    QNSetTableViewCell *cell = [_setTableView cellForRowAtIndexPath:indexPath];
    cell.falseButton.selected = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingsView:didSelectedIndex:enable:)]) {
        [self.delegate settingsView:self didSelectedIndex:index enable:YES];
    }
}

- (void)falseButtonAction:(UIButton *)button {
    button.selected = YES;
    NSInteger index = button.tag - 200;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    QNSetTableViewCell *cell = [_setTableView cellForRowAtIndexPath:indexPath];
    cell.enableButton.selected = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingsView:didSelectedIndex:enable:)]) {
        [self.delegate settingsView:self didSelectedIndex:index enable:NO];
    }
}

# pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.nameLabel.text = _listArray[indexPath.row];
    cell.enableButton.tag = 100 + indexPath.row;
    cell.falseButton.tag = 200 + indexPath.row;
    cell.nameLabel.textColor = [UIColor blackColor];

    if (indexPath.row == 3) {
        cell.enableButton.selected = NO;
        cell.falseButton.selected = YES;
        if (self.isBack) {
            cell.nameLabel.textColor = [UIColor blackColor];
            cell.enableLabel.textColor = [UIColor blackColor];
            cell.falseLabel.textColor = [UIColor blackColor];
            cell.enableButton.enabled = YES;
            cell.falseButton.enabled = YES;
        } else{
            cell.nameLabel.textColor = [UIColor grayColor];
            cell.enableLabel.textColor = [UIColor grayColor];
            cell.falseLabel.textColor = [UIColor grayColor];
            cell.enableButton.enabled = NO;
            cell.falseButton.enabled = NO;
        }
    }
    
    [cell.enableButton addTarget:self action:@selector(enableButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.falseButton addTarget:self action:@selector(falseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
