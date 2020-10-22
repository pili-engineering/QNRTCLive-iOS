//
//  QNFeedbackViewController.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/10/9.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNFeedbackViewController.h"
#import "QNAddCollectionViewCell.h"
#import "ZipArchive.h"
#import "QNCircleView.h"

static NSString *cellIdentifier = @"AddCollectionViewCell";
static NSString *textPlacehodler = @"请详细描述您在使用过程中遇到的问题";

@interface QNFeedbackViewController ()
<
UITextViewDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UICollectionView *addCollectionView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSMutableArray *addArray;

@property (nonatomic, strong) NSDictionary *defaultDic;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *uploadZipFile;
@property (nonatomic, copy) NSString *dataFilePath;

@property (nonatomic, strong) QNCircleView *circleView;

@end

@implementation QNFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.defaultDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_INFOMATION"];
    self.userId = self.defaultDic[@"id"];
    
    [self layoutInterfaceView];
    
    self.circleView = [[QNCircleView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    self.circleView.center = self.view.center;
    self.circleView.progress = 0;
    [self.view addSubview:_circleView];
    self.circleView.hidden = YES;
}

- (void)layoutInterfaceView {
    CGFloat navigationHeight = 64;
    CGFloat space = 10;
    if(QN_iPhoneX || QN_iPhoneXR || QN_iPhoneXSMAX) {
        navigationHeight = 88;
        space = 20;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QN_KSCREEN_WIDTH, navigationHeight)];
    headerView.backgroundColor = QN_COLOR_RGB(30, 139, 255, 1);
    [self.view addSubview:headerView];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = QN_FONT_REGULAR(16.0);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"问题反馈";
    [titleLabel sizeToFit];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.centerY.mas_equalTo(headerView.mas_centerY).offset(space);
    }];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"get_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_left).offset(22);
        make.centerY.mas_equalTo(titleLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    [backButton addTarget:self action:@selector(getBack) forControlEvents:UIControlEventTouchUpInside];
    
    
    _textView = [[UITextView alloc] init];
    _textView.delegate = self;
    _textView.font = QN_FONT_REGULAR(15.0);
    _textView.text = textPlacehodler;
    _textView.backgroundColor = [UIColor whiteColor];
    [self adjustColor];
    [self.view addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView.mas_bottom).offset(26);
        make.left.mas_equalTo(self.view.mas_left).offset(22);
        make.right.mas_equalTo(self.view.mas_right).offset(-22);
        make.height.mas_equalTo(150);
    }];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.textAlignment = NSTextAlignmentRight;
    _numberLabel.font = QN_FONT_REGULAR(13.0);
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return QN_LINE_COLOR;
                
            } else {
                return [UIColor darkGrayColor];
            }
        }];
        _numberLabel.textColor = dyColor;
    } else{
        _numberLabel.textColor = QN_LINE_COLOR;
    }
    _numberLabel.text = @"500";
    [self.view addSubview:_numberLabel];
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).offset(6);
        make.right.mas_equalTo(self.view.mas_right).offset(-22);
        make.height.mas_equalTo(20);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = QN_COLOR_RGB(151, 151, 151, 1);
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.numberLabel.mas_bottom).offset(9);
        make.left.mas_equalTo(self.view.mas_left).offset(22);
        make.right.mas_equalTo(self.view.mas_right).offset(-22);
        make.height.mas_equalTo(0.6);
    }];
    
    _submitButton = [[UIButton alloc] init];
    [_submitButton setImage:[UIImage imageNamed:@"icon_submit"] forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(submitFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitButton];
    [_submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(290, 40));
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 8;
    flowLayout.minimumInteritemSpacing = 0.5;
    flowLayout.itemSize = CGSizeMake(90, 135);
    _addCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:flowLayout];
    _addCollectionView.backgroundColor = [UIColor whiteColor];
    _addCollectionView.delegate = self;
    _addCollectionView.dataSource = self;
    _addCollectionView.scrollEnabled = NO;
    [_addCollectionView registerClass:[QNAddCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:_addCollectionView];
    
    [_addCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(40);
        make.left.mas_equalTo(self.view.mas_left).offset(22);;
        make.right.mas_equalTo(self.view.mas_right).offset(-22);;
        make.bottom.mas_equalTo(self.submitButton.mas_top).offset(-20);
    }];

    _addArray = [NSMutableArray array];
}

- (void)uploadFilePath:(NSString *)filePath token:(NSString *)token key:(NSString *)key {
    //国内https上传
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.useHttps = YES;
    }];
    
    QNUploadOption *option = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.circleView.progress = percent;
            self.circleView.hidden = NO;
        });
    }];

    QNUploadManager *upManager = [QNUploadManager sharedInstanceWithConfiguration:config];
    [upManager putFile:filePath key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.circleView.hidden = YES;
            if(info.ok){
                NSLog(@"请求成功 - resp: %@", resp);
                self.fileName = resp[@"key"];
                [self sendFeedbackInfomationToServer];
                // 删除压缩文件及图片文件
            } else{
                NSLog(@"失败 - info: %@", info);
                // 如果失败，这里可以把info信息上报自己的服务器，便于后面分析上传错误原因
            }
        });
    } option:option];
}

#pragma mark - addCollectionView delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_addArray.count != 0) {
        return _addArray.count + 1;
    } else{
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QNAddCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row == _addArray.count) {
        cell.imageView.image = [UIImage imageNamed:@"icon_Picture selection"];
        cell.deleteButton.hidden = YES;
    } else{
        cell.imageView.image = _addArray[indexPath.row];
        cell.deleteButton.hidden = NO;
        cell.deleteButton.tag = 100 + indexPath.row;
        [cell.deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _addArray.count) {
        if (self.addArray.count >= 3) {
            QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
            [sigleView showAlertViewTitle:@"图片最多可上传 3 张，已达上限！" bgView:self.view];
        } else{
            UIImagePickerController *imgPickerVc = [[UIImagePickerController alloc]init];
            imgPickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imgPickerVc.delegate = self;
            [self presentViewController:imgPickerVc animated:YES completion:nil];
        }
    }
}

#pragma mark --- 拍好照 或 选完照片 ---
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.6);

    [picker dismissViewControllerAnimated:YES completion:^{
        [self.addArray addObject:[UIImage imageWithData:imgData]];
        [self.addCollectionView reloadData];
    }];
}

#pragma mark - 压缩文件夹
- (void)doZipAtPath:(NSString *)sourceAppPath sourceRTCPath:(NSString *)sourceRTCPath to:(NSString*)destZipFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZipArchive * zipArchive = [ZipArchive new];
    [zipArchive CreateZipFile2:destZipFile];
    
    NSArray *subAppPaths = [fileManager subpathsAtPath:sourceAppPath];
    for(NSString *subPath in subAppPaths){
        NSString *fullPath = [sourceAppPath stringByAppendingPathComponent:subPath];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir) {
            [zipArchive addFileToZip:fullPath newname:subPath];
        }
    }
    
    NSArray *subRTCPaths = [fileManager subpathsAtPath:sourceRTCPath];
    for(NSString *subPath in subRTCPaths){
        NSString *fullPath = [sourceRTCPath stringByAppendingPathComponent:subPath];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir){
            [zipArchive addFileToZip:fullPath newname:subPath];
        }
    }
    
    [zipArchive CloseZipFile2];
}

- (NSString *)closeZipFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = ([cachesPaths count] > 0) ? [cachesPaths objectAtIndex:0] : nil;
    NSString *logs = [cachesPath stringByAppendingString:@"/Pili/Logs"];

    NSString *tmpPath = NSTemporaryDirectory();
    self.dataFilePath = [tmpPath stringByAppendingPathComponent:@"APPZipFile"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:self.dataFilePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:self.dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.fileName = [NSString stringWithFormat:@"%@_%@.zip", self.userId, [self currentDateStr]];
    NSString *zipFile = [self.dataFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@", self.fileName]];
  
    [self doZipAtPath:documentPath sourceRTCPath:logs to:zipFile];
    
    QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
    [sigleView showAlertViewTitle:@"文件压缩成功！" bgView:self.view];

    return zipFile;
}

- (void)removeFiles {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *images = [documentPath stringByAppendingString:@"/APPImages"];
    [defaultManager removeItemAtPath:images error:nil];
    [defaultManager removeItemAtPath:self.dataFilePath error:nil];
}

- (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}


#pragma mark - textView delegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length < 1){
        textView.font = QN_FONT_REGULAR(15.0);
        textView.text = textPlacehodler;
        [self adjustColor];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:textPlacehodler]){
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
        textView.font = QN_FONT_REGULAR(16.0);
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", 500 - textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length > 500) {
        self.numberLabel.text = @"0";
        return NO;
    } else {
        return YES;
    }
}

- (void)sendFeedbackInfomationToServer {
    NSString *text = @"";
    if (![self.textView.text isEqualToString:textPlacehodler]) {
        text = self.textView.text;
    }
    [QNNetworkRequest requestWithUrl:QN_FEEDBACK_POST requestType:QNRequestTypePost dic:@{@"content":text, @"attachement":self.fileName} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_FEEDBACK_POST resultDic --- %@", resultDic);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:@"反馈成功！" bgView:self.view];
        [self removeFiles];
        [self dismissViewControllerAnimated:YES completion:nil];
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_FEEDBACK_POST error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"问题反馈失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)adjustColor {
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return QN_LINE_COLOR;
                
            } else {
                return [UIColor darkGrayColor];
            }
        }];
        _textView.textColor = dyColor;
    } else{
        _textView.textColor = QN_LINE_COLOR;
    }
}

- (BOOL)clearCacheWithFilePath:(NSString *)path{
    NSArray *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSString *filePath = nil;
    NSError *error = nil;
    
    for (NSString *subPath in subPathArr) {
        filePath = [path stringByAppendingPathComponent:subPath];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

- (void)saveImages {
    NSString *tmpPath = NSTemporaryDirectory();
    [self clearCacheWithFilePath:tmpPath];
    
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataFilePath = [docsdir stringByAppendingPathComponent:@"APPImages"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    for (NSInteger i = 0; i < _addArray.count; i++) {
        UIImage *imgsave = _addArray[i];
        NSString *Pathimg = [dataFilePath stringByAppendingString:[NSString stringWithFormat:@"/%@-%ld.jpg", [self currentDateStr], i]];
        [UIImagePNGRepresentation(imgsave) writeToFile:Pathimg atomically:YES];
    }
}
#pragma mark - button actions

- (void)submitFeedback:(UIButton *)button {
    [self saveImages];
    self.uploadZipFile = [self closeZipFile];
    [QNNetworkRequest requestWithUrl:QN_UPLOAD_TOKEN requestType:QNRequestTypePost dic:@{@"filename":self.fileName, @"expireSeconds":@3600} header:[NSString stringWithFormat:@"Bearer %@", self.defaultDic[@"token"]] success:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"QN_UPLOAD_TOKEN resultDic --- %@", resultDic);
        if ([resultDic.allKeys containsObject:@"token"]) {
            [self uploadFilePath:self.uploadZipFile token:resultDic[@"token"] key:self.fileName];
        }
    } error:^(NSError * _Nonnull error) {
        NSLog(@"QN_UPLOAD_TOKEN error --- %@", error);
        QNSigleAlertView *sigleView = [[QNSigleAlertView alloc]init];
        [sigleView showAlertViewTitle:[NSString stringWithFormat:@"获取上传 token 失败 %ld", (long)error.code] bgView:self.view];
    }];
}

- (void)deleteImage:(UIButton *)button {
    NSInteger index = button.tag - 100;
    [self.addArray removeObjectAtIndex:index];
    [self.addCollectionView reloadData];
}

- (void)getBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
