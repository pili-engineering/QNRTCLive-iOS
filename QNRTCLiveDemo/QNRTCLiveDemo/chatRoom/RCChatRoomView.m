//
//  RCChatRoomView.m
//  NiuLiving
//
//  Created by liyan on 2020/4/8.
//  Copyright © 2020 PILI. All rights reserved.
//

#import "RCChatRoomView.h"
#import "RCCRRongCloudIMManager.h"
#import "RCChatroomNotification.h"
#import "RCCRMessageBaseCell.h"
#import "RCChatroomStart.h"
#import "RCChatroomLike.h"
#import "RCChatroomUserQuit.h"
#import "RCChatroomNotification.h"
#import "RCChatroomEnd.h"
#import "RCChatroomWelcome.h"
#import "RCCRTextMessageCell.h"
#import <RongIMLib/RongIMLib.h>
#import "RCChatroomBarrage.h"
#import "RCDDanmaku.h"
#import "UIView+RCDDanmaku.h"
#import "RCChatroomSignal.h"

#define SCREENSIZE [UIScreen mainScreen].bounds.size

#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]

static NSString * const ConversationMessageCollectionViewCell = @"ConversationMessageCollectionViewCell";
/**
 *  文本cell标示
 */
static NSString *const textCellIndentifier = @"textCellIndentifier";

static NSString *const startAndEndCellIndentifier = @"startAndEndCellIndentifier";

static NSString * const banNotifyContent = @"您已被管理员禁言";

//  用于记录点赞消息连续点击的次数
static int clickPraiseBtnTimes  = 0 ;

@interface RCChatRoomView ()<RCCRInputBarControlDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, RCCRGiftViewDelegate>

/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即RCDLiveMessageModel对象。
 */
@property(nonatomic, strong) NSMutableArray<RCCRMessageModel *> *conversationDataRepository;

/**
 *  是否需要滚动到底部
 */
@property(nonatomic, assign) BOOL isNeedScrollToButtom;

/**
 *  滚动条不在底部的时候，接收到消息不滚动到底部，记录未读消息数
 */
@property (nonatomic, assign) NSInteger unreadNewMsgCount;

@end

@implementation RCChatRoomView

- (instancetype)initWithFrame:(CGRect)frame model:(RCCRLiveModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        self.model = model;
        CGSize size = frame.size;
        CGFloat bottomExtraDistance  = 0;
        if (@available(iOS 11.0, *)) {
            bottomExtraDistance = [self getIPhonexExtraBottomHeight];
        }
        //  消息展示界面和输入框
        [self.messageContentView setFrame:CGRectMake(0, 0, size.width, size.height - 50)];
        [self addSubview:self.messageContentView];
        
        [self.messageContentView  addSubview:self.conversationMessageCollectionView];
        [self.conversationMessageCollectionView setFrame:CGRectMake(0, 0, size.width, self.messageContentView.frame.size.height - 50)];
        UICollectionViewFlowLayout *customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        customFlowLayout.minimumLineSpacing = 2;
        customFlowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f,5.0f, 0.0f);
        customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self.conversationMessageCollectionView setCollectionViewLayout:customFlowLayout animated:NO completion:nil];
        
        [self.messageContentView  addSubview:self.inputBar];
        [self.inputBar setBackgroundColor: [UIColor whiteColor]];
        [self.inputBar setFrame:CGRectMake(0, self.messageContentView.frame.size.height - 50, size.width , 50)];
        [self.inputBar setHidden:YES];
        
        //  底部按钮
        [self addSubview:self.bottomBtnContentView];
        [self.bottomBtnContentView setFrame:CGRectMake(0, size.height - 50, size.width-100, 50)];
        [self.bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
        
        if (self.model.liveMode != RCCRLiveModeHost) {
            [self.bottomBtnContentView addSubview:self.commentBtn];
        }
        [self.commentBtn setFrame:CGRectMake(10, 10, 35, 35)];
        if (self.model.liveMode != RCCRLiveModeHost) {
            [self.bottomBtnContentView addSubview:self.danmakuBtn];
        }
        [self.danmakuBtn setFrame:CGRectMake(self.bottomBtnContentView.frame.size.width - 35*3 - 10*4, 10, 35, 35)];
        [self.danmakuBtn setBackgroundColor:[UIColor blackColor]];
        [self.danmakuBtn.layer setCornerRadius:35/2];
        [self.danmakuBtn.layer setMasksToBounds:YES];
        
        if (self.model.liveMode != RCCRLiveModeHost) {
            [self.bottomBtnContentView addSubview:self.giftBtn];
        }
        
        [self.giftBtn setFrame:CGRectMake(self.bottomBtnContentView.frame.size.width - 35*2 - 10*3, 10, 35, 35)];
        
        if (self.model.liveMode != RCCRLiveModeHost) {
            [self.bottomBtnContentView addSubview:self.praiseBtn];
        }
        [self.praiseBtn setFrame:CGRectMake(self.bottomBtnContentView.frame.size.width - 35 - 10*2, 10, 35, 35)];
        [self addSubview:self.giftListView];
        [self.giftListView setHidden:YES];
        [self.giftListView setFrame:CGRectMake(10, size.height, size.width - 20, bottomExtraDistance > 0 ? 274 : 240)];
        
        NSMutableArray *giftArr = [[NSMutableArray alloc] init];
           for (int i = 0; i<5; i++) {
               RCCRGiftModel *giftModel = [[RCCRGiftModel alloc] init];
               giftModel.giftImageName = [NSString stringWithFormat:@"GiftId_%d",(i)%5 + 1];
               giftModel.giftId = [NSString stringWithFormat:@"GiftId_%d",(i)%5 + 1];
               giftModel.giftName = [NSString stringWithFormat:@"gift%d",i];
               giftModel.giftPrice = (i + 1)*100;
               [giftArr addObject:giftModel];
           }
           [self.giftListView setModelArray:giftArr];
        
        [self registerClass:[RCCRTextMessageCell class]forCellWithReuseIdentifier:textCellIndentifier];
        [self registerClass:[RCCRTextMessageCell class]forCellWithReuseIdentifier:startAndEndCellIndentifier];
        [self registerNotification];
        
    }
    return self;
    
}

/**
 *  注册监听Notification
 */
- (void)registerNotification {
    //注册接收消息
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCCRKitDispatchMessageNotification
     object:nil];
}

#pragma mark - views init
/**
 *  注册cell
 *
 *  @param cellClass  cell类型
 *  @param identifier cell标示
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.conversationMessageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:identifier];
}


/**
 发言按钮事件
 */
- (void)commentBtnPressed:(id)sender {
    //  判断是否登录了
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
            [self.inputBar setHidden:NO];
            [self.inputBar  setInputBarStatus:RCCRBottomBarStatusKeyboard];
            self.isSendDanmaku = NO;
    } else {
        
    }
}

/**
 发送弹幕
 */
- (void)danmakuBtnPressed:(id)sender {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
            [self.inputBar  setHidden:NO];
            [self.inputBar  setInputBarStatus:RCCRBottomBarStatusKeyboard];
            self.isSendDanmaku = YES;
    } else {
        
    }
}

/**
 送礼物按钮事件
 */
- (void)giftBtnPressed:(id)sender {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        CGRect frame = self.giftListView.frame;
        frame.origin.y -= frame.size.height;
        [self.giftListView setHidden:NO];
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.giftListView setFrame:frame];
        } completion:nil];
    } else {
        __weak __typeof(&*self)weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
        } completion:^(BOOL finished) {
        }];
    }
}

/**
 点赞
 */
- (void)praiseBtnPressed:(id)sender {
    if ([[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] isLogin]) {
        NSTimeInterval currentTime =  [[NSDate date] timeIntervalSince1970];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.21 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[NSDate date] timeIntervalSince1970] - self.lastClickPraiseTime >= 0.2) {

                RCChatroomLike *praiseSendMessage = [[RCChatroomLike alloc] init];
                praiseSendMessage.counts = clickPraiseBtnTimes;
                [weakSelf sendMessage:praiseSendMessage pushContent:nil success:nil error:nil];
                clickPraiseBtnTimes = 0;
            }
        });
        RCChatroomLike *praiseMessage = [[RCChatroomLike alloc] init];
        clickPraiseBtnTimes++;
        self.lastClickPraiseTime = currentTime;
        [self presentLikeMessageAnimation:praiseMessage];
    }
}

- (void)insertNotificationMessage:(NSString *)content {
    RCChatroomNotification *notify = [RCChatroomNotification new];
    notify.content = content;
    RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_CHATROOM
                                                targetId:self.model.roomId
                                               direction:MessageDirection_SEND
                                               messageId:-1
                                                 content:notify];
    message.senderUserId = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId;
    [self appendAndDisplayMessage:message];
}

/**
 *  将消息加入本地数组
 */
- (void)appendAndDisplayMessage:(RCMessage *)rcMessage {
    if (!rcMessage) {
        return;
    }
    RCCRMessageModel *model = [[RCCRMessageModel alloc] initWithMessage:rcMessage];
    model.userInfo = rcMessage.content.senderUserInfo;
    RCMessageContent *content = rcMessage.content;
    RCUserInfo *userInfo = content.senderUserInfo;
    if ([self appendMessageModel:model]) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForItem:self.conversationDataRepository.count - 1
                            inSection:0];
        if ([self.conversationMessageCollectionView numberOfItemsInSection:0] !=
            self.conversationDataRepository.count - 1) {
            return;
        }
        //  view刷新
        [self.conversationMessageCollectionView
         insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        if ([self isAtTheBottomOfTableView] || self.isNeedScrollToButtom) {
            [self scrollToBottomAnimated:YES];
            self.isNeedScrollToButtom=NO;
        }
    }
    return;
}

/**
 *  消息滚动到底部
 *
 *  @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.conversationMessageCollectionView numberOfSections] == 0) {
        return;
    }
    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath =
    [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                           animated:animated];
}


/**
 *  如果当前会话没有这个消息id，把消息加入本地数组
 */
- (BOOL)appendMessageModel:(RCCRMessageModel *)model {

    if (!model.content) {
        return NO;
    }
    //这里可以根据消息类型来决定是否显示，如果不希望显示直接return NO
    
    //数量不可能无限制的大，这里限制收到消息过多时，就对显示消息数量进行限制。
    //用户可以手动下拉更多消息，查看更多历史消息。
    if (self.conversationDataRepository.count>100) {
        //                NSRange range = NSMakeRange(0, 1);
        RCCRMessageModel *message = self.conversationDataRepository[0];
        [[RCIMClient sharedRCIMClient]deleteMessages:@[@(message.messageId)]];
        [self.conversationDataRepository removeObjectAtIndex:0];
        [self.conversationMessageCollectionView reloadData];
    }
    
    [self.conversationDataRepository addObject:model];
    return YES;
}


/**
 *  判断消息是否在collectionView的底部
 *
 *  @return 是否在底部
 */
- (BOOL)isAtTheBottomOfTableView {
    if (self.conversationMessageCollectionView.contentSize.height <= self.conversationMessageCollectionView.frame.size.height) {
        return YES;
    }
    if(self.conversationMessageCollectionView.contentOffset.y +200 >= (self.conversationMessageCollectionView.contentSize.height - self.conversationMessageCollectionView.frame.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

/**
 *  更新底部新消息提示显示状态
 */
- (void)updateUnreadMsgCountLabel{
}

/**
 拦截加在整个背景view上的点击手势
 
 @param gestureRecognizer UIGestureRecognizer
 @param touch UITouch
 @return BOOL
 */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.giftListView]) {
        return NO;
    }
    return YES;
}

#pragma mark sendDanmaku
- (void)showDanmaku:(NSString *)text userInfo:(RCUserInfo *)userInfo {
    if(!text || text.length == 0){
        return;
    }
    RCDDanmaku *danmaku = [[RCDDanmaku alloc]init];
    danmaku.contentStr = [[NSAttributedString alloc]initWithString:text attributes:@{NSForegroundColorAttributeName : kRandomColor}];
    danmaku.model = userInfo;
    UIViewController *superController = [self viewContreoller:self];
    [superController.view sendDanmaku:danmaku];
}

- (void)sendReceivedDanmaku:(RCMessage *)message {
    if ([message.content isMemberOfClass:[RCChatroomBarrage class]]){
        RCChatroomBarrage *danmakuMessage = (RCChatroomBarrage *)message.content;
        [self showDanmaku:danmakuMessage.content userInfo:danmakuMessage.senderUserInfo];
    }
}

#pragma mark - RCCRgiftViewDelegate
//  发送礼物消息
- (void)sendGift:(RCCRGiftModel *)giftModel {
    RCChatroomGift *giftMessage = [[RCChatroomGift alloc] init];
    giftMessage.number = (int)giftModel.giftNumber;
    giftMessage.id = giftModel.giftId;
    [self sendMessage:giftMessage pushContent:nil success:nil error:nil];
    
    [self presentGiftAnimation:giftModel userInfo:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo];
}


- (void)presentGiftAnimation:(RCCRGiftModel *)giftModel userInfo:(RCUserInfo *)userInfo{
    //动画效果需要在主线程中进行（固定的动画形式）
//    CGFloat duringTime = 0.5 + 0.5 + 0.2*giftModel.giftNumber;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
        if (self.forbidGiftAinimation) {
            return;
        }
        weakSelf.showGiftView = [[UIView alloc] initWithFrame:CGRectMake(-150, 100, 160, 50)];
        weakSelf.showGiftView.layer.cornerRadius = 25;
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [headerImageView setBackgroundColor:[UIColor redColor]];
        [headerImageView.layer setCornerRadius:24];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 56, 20)];
        [nameLabel setNumberOfLines:0];
        [nameLabel setText:userInfo.name];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [weakSelf.showGiftView addSubview:nameLabel];
        UILabel *gifName = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 56, 20)];
        NSString *name = [self getGifName:giftModel.giftId];
        [gifName setText:name];
        [gifName setTextColor:[UIColor yellowColor]];
        [gifName setFont:[UIFont systemFontOfSize:12]];
        [weakSelf.showGiftView addSubview:gifName];
        [headerImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"audience%@",userInfo.portraitUri]]];
        [weakSelf.showGiftView addSubview:headerImageView];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 0, 50, 50)];
        [weakSelf.showGiftView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.4]];
        [weakSelf.showGiftView  addSubview:imageView];
        imageView.image = [UIImage imageNamed:giftModel.giftImageName];
        weakSelf.giftNumberLbl = [[RCCRGiftNumberLabel alloc] initWithFrame:CGRectMake(160, 0, 100, 50)];
        weakSelf.giftNumberLbl.outLineWidth = 5;
        weakSelf.giftNumberLbl.outLinetextColor = [UIColor grayColor];
        weakSelf.giftNumberLbl.labelTextColor = [UIColor orangeColor];
        weakSelf.giftNumberLbl.text = @"";
        weakSelf.giftNumberLbl.textAlignment = NSTextAlignmentLeft;
        weakSelf.giftNumberLbl.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:36];
        [weakSelf.showGiftView  addSubview:weakSelf.giftNumberLbl];
        UIViewController *superController = [self viewContreoller:self];
        [superController.view addSubview:self.showGiftView];
        self.forbidGiftAinimation = YES;

        //  逻辑：平移0.5秒；禁止0.2秒；变换数字，每次变换0.2秒，变换完数字，再禁止0.2秒，再移除；
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.showGiftView.center = CGPointMake(120, 200);
        } completion:^(BOOL finished) {
            //  数字动画
            for (int i = 0; i<giftModel.giftNumber+2; i++) {
                dispatch_after(dispatch_time(0, (int64_t)(i*0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!((i == 0) || (i == giftModel.giftNumber+1))) {
                        [weakSelf.giftNumberLbl setText:[NSString stringWithFormat:@"x%d",i]];
                    }
                    if (i == giftModel.giftNumber + 1) {
                        [UIView animateWithDuration:0.5 animations:^{
                            weakSelf.showGiftView.center = CGPointMake(-100,200);
                        } completion:^(BOOL finished) {
                            weakSelf.forbidGiftAinimation = NO;
                            [weakSelf.showGiftView removeFromSuperview];
                        }];
                    }
                });
            }
        }];
    });
}

- (NSString *)getGifName:(NSString *)gifId{
    if ([gifId isEqualToString:@"GiftId_1"]) {
        return @"送出蛋糕";
    }
    if ([gifId isEqualToString:@"GiftId_2"]) {
        return @"送出气球";
    }
    if ([gifId isEqualToString:@"GiftId_3"]) {
        return @"送出花儿";
    }
    if ([gifId isEqualToString:@"GiftId_4"]) {
        return @"送出项链";
    }
    if ([gifId isEqualToString:@"GiftId_5"]) {
        return @"送出戒指";
    }
    return @"";
}

#pragma mark - like

/**
 赞动画

 @param likeMessage 赞消息
 */
- (void)presentLikeMessageAnimation:(RCChatroomLike *)likeMessage {
    UIViewController *superController = [self viewContreoller:self];
    CGRect viewRect = self.superview.frame;
    CGRect praiseBtnRect = self.praiseBtn.frame;
    CGFloat bottomExtraDistance  = 0;
    if (@available(iOS 11.0, *)) {
        bottomExtraDistance = [self getIPhonexExtraBottomHeight];
    }
    CGRect startRect = CGRectMake(praiseBtnRect.origin.x, viewRect.size.height - self.bottomBtnContentView.frame.size.height - bottomExtraDistance , praiseBtnRect.size.width, praiseBtnRect.size.height);
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = startRect;
    imageView.image = [UIImage imageNamed:@"heartIcon"];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    [superController.view addSubview:imageView];
    [superController.view insertSubview:imageView atIndex:3];
    //  随机数来决定动画过程
    CGFloat startX = round(random() % 200);
    CGFloat scale = round(random() % 2) + 1.0;
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    int imageName = round(random() % 2);
    NSLog(@"%.2f - %.2f -- %d",startX,scale,imageName);
    
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    [UIView setAnimationDuration:7 * speed];
    
    imageView.image = [UIImage imageNamed:@"heartIcon"];
    imageView.frame = CGRectMake(self.bounds.size.width - startX, -100, 35 * scale, 35 * scale);
    
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
}

- (UIViewController*)viewContreoller:(UIView *)view{
    id target = view;
    while (target) {
        target = ((UIResponder*)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

#pragma mark - RCCRInputBarControlDelegate
//  根据inputBar 回调来修改页面布局
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve ifKeyboardShow:(BOOL)ifKeyboardShow {
    CGRect originFrame = self.frame;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        CGFloat bottomExtraDistance  = 0;
        if (@available(iOS 11.0, *)) {
            bottomExtraDistance = [self getIPhonexExtraBottomHeight];
        }
        if (ifKeyboardShow) {
            [weakSelf setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height + 50 , originFrame.size.width, originFrame.size.height)];
        }else {
            [weakSelf setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height - bottomExtraDistance , originFrame.size.width, originFrame.size.height)];
        }
        [UIView commitAnimations];
    }];
}

//  发送消息
- (void)onTouchSendButton:(NSString *)text {
        [self touristSendMessage:text];
}

- (void)touristSendMessage:(NSString *)text {
    if (self.isSendDanmaku) {
            RCChatroomBarrage *barrageMessage = [[RCChatroomBarrage alloc] init];
            barrageMessage.content = text;
            [self showDanmaku:text userInfo:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo];
            [self sendMessage:barrageMessage pushContent:nil success:nil error:nil];
    } else {
        RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:text];
        [self sendMessage:rcTextMessage pushContent:nil success:nil error:nil];
    }
}

#pragma mark sendMessage/showMessage
/**
 发送消息

 @param messageContent 消息
 @param pushContent pushContent
 */
- (void)sendMessage:(RCMessageContent *)messageContent
                    pushContent:(NSString *)pushContent
                    success:(void (^)(long messageId))successBlock
                    error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock {
    if (self.model.roomId == nil) {
        return;
    }
    messageContent.senderUserInfo = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo;
    if (messageContent == nil) {
        return;
    }
    
    __weak typeof(&*self) __weakself = self;
    [[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager] sendMessage:ConversationType_CHATROOM targetId:self.model.roomId content:messageContent pushContent:pushContent pushData:nil success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_CHATROOM
                                                        targetId:self.model.roomId
                                                       direction:MessageDirection_SEND
                                                       messageId:messageId
                                                         content:messageContent];
            message.content.senderUserInfo = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo;
            //  过滤礼物消息，弹幕消息,退出聊天室消息不插入数据源中；
            if ([messageContent isMemberOfClass:[RCChatroomGift class]] || [messageContent isMemberOfClass:[RCChatroomBarrage class]] || [messageContent isMemberOfClass:[RCChatroomUserQuit class]]) {
                if ([messageContent isMemberOfClass:[RCChatroomBarrage class]]) {
                    [__weakself.inputBar clearInputView];
                }
            } else {
                message.senderUserId = [RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId;
                [__weakself appendAndDisplayMessage:message];
                [__weakself.inputBar clearInputView];
            }
        });
        if (successBlock) {
            successBlock(messageId);
        }
    } error:^(RCErrorCode nErrorCode, long messageId) {
        if (nErrorCode == RC_CHATROOM_NOT_EXIST) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertErrorWithTitle:@"提示" message:@"1 小时内无人讲话，聊天已被解散，请退出后重进。" ok:@"知道了"];
            });
            
        }
        [__weakself.inputBar clearInputView];
        NSLog(@"发送失败，errorcode is: %ld",(long)nErrorCode);
        if (errorBlock) {
            errorBlock(nErrorCode, messageId);
        }
    }];
    
}

#pragma mark <UIScrollViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.conversationDataRepository.count;
}

/**
 *  接收到消息的回调
 */
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    __block RCMessage *rcMessage = notification.object;
    RCCRMessageModel *model = [[RCCRMessageModel alloc] initWithMessage:rcMessage];
    model.userInfo = rcMessage.content.senderUserInfo;
  
    if ([model.targetId isEqual:self.model.roomId]) {
        __weak typeof(&*self) __blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([model.content isMemberOfClass:[RCChatroomUserQuit class]]) {
                
                if ( [model.senderUserId isEqualToString:self.model.pubUserId]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"本次直播结束!" preferredStyle:(UIAlertControllerStyleAlert)];
                     UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
                     }];
                     [alert addAction:action];
                }
                if ([self.delegate respondsToSelector:@selector(didReceiveQuitMessageWithMessageModel:)]) {
                    [self.delegate didReceiveQuitMessageWithMessageModel:model];
                }
                
               
            }
            
            // 收到用户进入后台的回调
            if ([model.content isMemberOfClass:[RCChatroomSignal class]]) {
                RCChatroomSignal * background = (RCChatroomSignal *)rcMessage.content;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessageUserBackground:)]) {
                    [self.delegate didReceiveMessageUserBackground:background];
                }
            }
            //  对礼物消息,赞消息进行拦截，展示动画，不插入到数据源中,对封禁消息，弹出alert
            if (rcMessage) {
                if ([rcMessage.content isMemberOfClass:[RCChatroomGift class]])  {
                    RCChatroomGift *giftMessage = (RCChatroomGift *)rcMessage.content;
                    RCCRGiftModel *model = [[RCCRGiftModel alloc] initWithMessage:giftMessage];
                    [__blockSelf presentGiftAnimation:model userInfo:giftMessage.senderUserInfo];
                    return ;
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomLike class]]) {
                    RCChatroomLike *likeMessage = (RCChatroomLike *)rcMessage.content;
                    for (int i = 0;i < likeMessage.counts ; i++) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [__blockSelf presentLikeMessageAnimation:likeMessage];
                        });
                    }
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomBarrage class]]) {
                    //  处理是否发送弹幕消息
                    if([NSThread isMainThread]){
                        [__blockSelf sendReceivedDanmaku:rcMessage];
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [__blockSelf sendReceivedDanmaku:rcMessage];
                        });
                    }
                    return;
                } else if ([rcMessage.content isMemberOfClass:[RCChatroomWelcome class]]) {
                    //  过滤自己发送的欢迎消息
                    if ([rcMessage.senderUserId isEqualToString:[RCCRRongCloudIMManager sharedRCCRRongCloudIMManager].currentUserInfo.userId]) {
                        return;
                    }
                }
                
                NSDictionary *leftDic = notification.userInfo;
                if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
                    __blockSelf.isNeedScrollToButtom = YES;
                }
                [__blockSelf appendAndDisplayMessage:rcMessage];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                menu.menuVisible=NO;
                //如果消息不在最底部，收到消息之后不滚动到底部，加到列表中只记录未读数
                if (![__blockSelf isAtTheBottomOfTableView]) {
                    __blockSelf.unreadNewMsgCount ++ ;
                    [__blockSelf updateUnreadMsgCountLabel];
                }
            }
        });
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    RCCRMessageBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ConversationMessageCollectionViewCell forIndexPath:indexPath];;
    if ([messageContent isMemberOfClass:[RCTextMessage class]] || [messageContent isMemberOfClass:[RCChatroomWelcome class]] || [messageContent isMemberOfClass:[RCChatroomLike class]] ||
        [messageContent isMemberOfClass:[RCChatroomStart class]] ||
        [messageContent isMemberOfClass:[RCChatroomNotification class]] ||
        [messageContent isMemberOfClass:[RCChatroomEnd class]] ||
        [messageContent isMemberOfClass:[RCChatroomUserQuit class]]){
        RCCRTextMessageCell *__cell = nil;
        NSString *indentifier = nil;
        if ([messageContent isMemberOfClass:[RCChatroomStart class]] ||
            [messageContent isMemberOfClass:[RCChatroomEnd class]]) {
            indentifier = startAndEndCellIndentifier;
        } else {
            indentifier = textCellIndentifier;
        }
        __cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
        [__cell setDataModel:model];
        cell = __cell;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCCRMessageModel *model = self.conversationDataRepository[indexPath.row];
    if ([model.content isKindOfClass:[RCChatroomStart class]] || [model.content isKindOfClass:[RCChatroomEnd class]]) {
        return CGSizeMake(self.bounds.size.width,70);
    }
    return CGSizeMake(self.bounds.size.width,40);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -14.f;
}

#pragma mark - gesture and button action
- (void)resetBottomGesture:
(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setDefaultBottomViewStatus];
    }
}

- (void)setDefaultBottomViewStatus {
    [self.inputBar setInputBarStatus:RCCRBottomBarStatusDefault];
    [self.inputBar setHidden:YES];
    __weak __typeof(&*self)weakSelf = self;
    CGFloat height = self.bounds.size.height;
    if (!self.giftListView.hidden) {
        CGRect frame = self.giftListView.frame;
        frame.origin.y = height;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.giftListView setFrame:frame];
        } completion:^(BOOL finished) {
            [weakSelf.giftListView setHidden:YES];
        }];
    }
}

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:ok style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    
}

#pragma mark - getter setter

- (UIView *)bottomBtnContentView {
    if (!_bottomBtnContentView) {
        _bottomBtnContentView = [[UIView alloc] init];
        [_bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _bottomBtnContentView;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn addTarget:self
                        action:@selector(commentBtnPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [_commentBtn setImage:[UIImage imageNamed:@"feedback"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIButton *)danmakuBtn {
    if (!_danmakuBtn) {
        _danmakuBtn = [[UIButton alloc] init];
        [_danmakuBtn addTarget:self
                        action:@selector(danmakuBtnPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [_danmakuBtn setTitle:@"弹" forState:UIControlStateNormal];
    }
    return _danmakuBtn;
}


- (UIButton *)giftBtn {
    if (!_giftBtn) {
        _giftBtn = [[UIButton alloc] init];
        [_giftBtn addTarget:self
                     action:@selector(giftBtnPressed:)
           forControlEvents:UIControlEventTouchUpInside];
        [_giftBtn setImage:[UIImage imageNamed:@"gift0"] forState:UIControlStateNormal];
    }
    return _giftBtn;
}

- (RCCRGiftListView *)giftListView {
    if (!_giftListView) {
        _giftListView = [[RCCRGiftListView alloc] init];
        [_giftListView setDelegate:self];
    }
    return _giftListView;
}

- (UIButton *)praiseBtn {
    if (!_praiseBtn) {
        _praiseBtn = [[UIButton alloc] init];
        [_praiseBtn addTarget:self
                       action:@selector(praiseBtnPressed:)
             forControlEvents:UIControlEventTouchUpInside];
        [_praiseBtn setImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateNormal];
    }
    return _praiseBtn;
}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        [_messageContentView setBackgroundColor: [UIColor clearColor]];
    }
    return _messageContentView;
}

- (UICollectionView *)conversationMessageCollectionView {
    if (!_conversationMessageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _conversationMessageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_conversationMessageCollectionView setDelegate:self];
        [_conversationMessageCollectionView setDataSource:self];
        [_conversationMessageCollectionView setBackgroundColor: [UIColor clearColor]];
        [_conversationMessageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ConversationMessageCollectionViewCell];
    }
    return _conversationMessageCollectionView;
}

- (RCCRInputBarControl *)inputBar {
    if (!_inputBar) {
        _inputBar = [[RCCRInputBarControl alloc] initWithStatus:RCCRBottomBarStatusDefault];
        [_inputBar setDelegate:self];
    }
    return _inputBar;
}

- (NSMutableArray *)conversationDataRepository {
    if (!_conversationDataRepository) {
           _conversationDataRepository = [[NSMutableArray alloc] init];
       }
       return _conversationDataRepository;
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}

@end
