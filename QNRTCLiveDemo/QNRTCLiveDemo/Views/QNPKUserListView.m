//
//  QNPKUserListView.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/10.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNPKUserListView.h"
#import "QNPKListTableViewCell.h"

static NSString *cellIdentifier = @"PKListTableViewCell";

@interface QNPKUserListView()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong, readwrite) NSMutableArray *listArray;

@property (nonatomic, assign) NSInteger state;

@end

@implementation QNPKUserListView

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
                
        if (state == 0) {
            tableViewHeight = height - 52;
            _titleLabel.text = @"可以 PK 的主播";
        } else{
            tableViewHeight = height - 134;
            _titleLabel.text = @"连麦互动";
            
            _exitButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 150, height - 78, 300, 44)];
            _exitButton.titleLabel.font = QN_FONT_REGULAR(16.0);
            [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_exitButton setTitle:@"退出 PK" forState:UIControlStateNormal];
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

- (void)pkAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    if (self.delegate && [self.delegate respondsToSelector:@selector(listView:didSelectedIndex:)]) {
        [self.delegate listView:self didSelectedIndex:index];
    }
}

# pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNPKListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_state == 0) {
        NSDictionary *dic = _listArray[indexPath.row];
        NSDictionary *creater = dic[@"creator"];
        [cell setUser:creater[@"nickname"] state:self.state];
        if (self.state == 0) {
            cell.pkButton.tag = 100 + indexPath.row;
            [cell.pkButton addTarget:self action:@selector(pkAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else{
        [cell setUser:_listArray[indexPath.row] state:self.state];
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
