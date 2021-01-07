//
//  QNAudioUserModel.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/12/11.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNAudioUserModel.h"

@implementation QNAudioUserModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.roomID forKey:@"roomID"];
    [aCoder encodeObject:self.roomid forKey:@"id"];
    [aCoder encodeObject:self.reqUserID forKey:@"reqUserID"];
    [aCoder encodeObject:self.audioMute forKey:@"audioMute"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.roomID = [aDecoder decodeObjectForKey:@"roomID"];
        self.roomid = [aDecoder decodeObjectForKey:@"id"];
        self.reqUserID = [aDecoder decodeObjectForKey:@"reqUserID"];
        self.audioMute = [aDecoder decodeObjectForKey:@"audioMute"];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.roomid = value;
    }
}

+ (QNAudioUserModel *)configureAudioUserModelWithDic:(NSDictionary *)dic {
    QNAudioUserModel *model = [[QNAudioUserModel alloc]init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}

+ (NSMutableArray *)configureAudioUserModelWithArray:(NSArray *)array {
    NSMutableArray *notifiArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        QNAudioUserModel *model = [QNAudioUserModel configureAudioUserModelWithDic:dic];
        [notifiArray addObject:model];
    }
    return notifiArray;
}

@end
