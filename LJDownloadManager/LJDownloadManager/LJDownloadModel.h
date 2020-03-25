//
//  LJDownloadModel.h
//  LJDownloadManager
//
//  Created by lijiehu on 2020/3/24.
//  Copyright © 2020 lijiehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,LJDownloadState) {
    LJDownloadStateWaiting,
    LJDownloadStateRunning,
    LJDownloadStateSuspended,
    LJDownloadStateCanceled,
    LJDownloadStateCompleted,
    LJDownloadStateFailed
};
@interface LJDownloadModel : NSObject

@property (nonatomic,strong) NSURLSessionDataTask *dataTask;
@property (nonatomic,strong) NSOutputStream *outPutStream;//输入输出流
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) long long allBytesSize;//现在文件的总体大小
@property (nonatomic, assign) long long alreadyBytesSize;//下载文件已下载的大小

@property (nonatomic,assign) int retryTime;//重试次数

@property (nonatomic, copy) void (^state) (LJDownloadState state);//状态

@property (nonatomic, copy) void (^progress)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);//进度回调函数


@property (nonatomic, copy) void (^completion)(BOOL isSuccess, NSString * _Nullable  filePath, NSError *error);//结果

-(void)openOutStream;
-(void)closeOutputStream;

@end

NS_ASSUME_NONNULL_END
