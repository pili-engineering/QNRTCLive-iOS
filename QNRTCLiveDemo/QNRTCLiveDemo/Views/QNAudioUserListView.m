//
//  QNAudioUserListView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNAudioUserListView.h"
#import "QNPKListTableViewCell.h"

static NSString *cellIdentifier = @"AudioListTableViewCell";

@interface QNAudioUserListView()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong, readwrite) NSMutableArray *listArray;

@property (nonatomic, readwrite) NSInteger state;
@property (nonatomic, copy) NSString *userId;

@end

@implementation QNAudioUserListView

- (instancetype)initWithFrame:(CGRect)frame listArray:(NSMutableArray *)listArray state:(NSInteger)state {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self layoutCornerRadius];
        
        _listArray = [NSMutableArray arrayWithArray:listArray];
        _state = state;
        
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 51)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = QN_FONT_REGULAR(16.0);
        _titleLabel.textColor = QN_COLOR_RGB(30, 139, 255, 1);
        [self addSubview:_titleLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 51, width, 0.5)];
        lineView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
        [self addSubview:lineView];
        
        CGFloat tableViewHeight = height - 52;
                
        tableViewHeight = height - 134;
        _titleLabel.text = @"连麦互动";

        if (state == 1) {
            _exitButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 150, height - 78, 300, 44)];
            _exitButton.titleLabel.font = QN_FONT_REGULAR(16.0);
            [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_exitButton setTitle:@"退出语音连麦" forState:UIControlStateNormal];
            _exitButton.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
            _exitButton.layer.cornerRadius = 22;
            _exitButton.clipsToBounds = YES;
            [self addSubview:_exitButton];
        }
        
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 52, width, tableViewHeight) style:UITableViewStylePlain];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        [_listTableView registerClass:[QNPKListTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_listTableView];
    }
    return self;
}

- (void)layoutCornerRadius {
    UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerTopRight;

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)updateListArray:(NSMutableArray *)array {
    _listArray = [NSMutableArray arrayWithArray:array];
    [_listTableView reloadData];
}

- (void)setAdminUserId:(NSString *)userId {
    self.userId = userId;
}

# pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listArray.count == 0) {
        return 0;
    }
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNPKListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.pkButton.hidden = YES;
//    cell.pkButton.frame = CGRectMake(QN_KSCREEN_WIDTH - 70, 13, 26, 26);
//    [cell.pkButton setImage:[UIImage imageNamed:@"icon_voice"] forState:UIControlStateNormal];
//    [cell.pkButton setImage:[UIImage imageNamed:@"icon_voice_nor"] forState:UIControlStateSelected];
    
    NSDictionary *dic = _listArray[indexPath.row];
    cell.userLabel.text = dic[@"nickname"];
//    cell.pkButton.selected = [dic[@"audioMute"] boolValue];
    if ([dic[@"userId"] isEqualToString:self.userId]) {
        cell.tagLabel.text = @"主播";
    } else{
        cell.tagLabel.text = @"观众";
    }
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
