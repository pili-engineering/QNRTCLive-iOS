//
//  QNNetworkRequest.m
//  QNRTCLiveDemo
//
//  Created by 冯文秀 on 2020/9/8.
//  Copyright © 2020 冯文秀. All rights reserved.
//

#import "QNNetworkRequest.h"

@interface QNNetworkRequest ()
<NSURLSessionTaskDelegate>

@end

@implementation QNNetworkRequest

+ (void)requestWithUrl:(NSString *)urlString requestType:(QNRequestType)requestType dic:(NSDictionary *)dic header:(id)header success:(QNSuccess)success error:(QNError)error {
    QNNetworkRequest *request = [[QNNetworkRequest alloc]init];
    [request requestWithUrl:urlString requestType:requestType dic:dic header:header success:success error:error];
}

- (void)requestWithUrl:(NSString *)urlString requestType:(QNRequestType)requestType dic:(NSDictionary *)dic header:(id)header success:(QNSuccess)success error:(QNError)error
{
    self.success = success;
    self.error = error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSString *type;
    switch (requestType) {
        case QNRequestTypeGet:
            type = @"GET";
            break;
        case QNRequestTypePost:
            type = @"POST";
            break;
        case QNRequestTypePut:
            type = @"PUT";
            break;
        case QNRequestTypeDelete:
            type = @"DELETE";
            break;

        default:
            type = @"POST";
            break;
    }
    request.HTTPMethod = type;

    NSString *headerStr = header;
    if (headerStr.length != 0) {
        [request addValue:headerStr forHTTPHeaderField:@"Authorization"];
    }
        
    if (dic.count != 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
    }

//    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue currentQueue]];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.error(error);
            }else{
                if (data) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    self.success(dic);
                } else {
                    self.success(@{});
                }
            }
        });
    }];
    [task resume];
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler {
    NSDictionary *headers = response.allHeaderFields;
    // 获取重定向后请求地址的两种方式：headers[@"Location"] 和 [request URL]
    NSLog(@"请求重定向回调===>\nstatus Code: %ld\nHeader Fields: \n%@\n重定向【前】的请求地址: %@\n重定向【后】的请求地址: %@\n", response.statusCode, headers, [response URL], [request URL]);

//    completionHandler(request);
    completionHandler(nil);// 通过设置参数为nil，可以【禁止/拦截】重定向
}
@end
