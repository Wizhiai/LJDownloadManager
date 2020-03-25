//
//  LJDownloadManager.m
//  LJDownloadManager
//
//  Created by lijiehu on 2020/3/24.
//  Copyright © 2020 lijiehu. All rights reserved.
//

#import "LJDownloadManager.h"

/*
 下载存储默认路径
 */
#define LJDownloadDirectory self.downloadedFilesDirectory ? : [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] \
stringByAppendingPathComponent:NSStringFromClass([self class])]

#define LJFileName(URL) [URL lastPathComponent]//选取文件名

#define LJFilePath(URL) [LJDownloadDirectory stringByAppendingPathComponent:LJFileName(URL)]


#define LJFilesTotalLengthPlistPath [LJDownloadDirectory stringByAppendingPathComponent:@"LJFilesTotalLength.plist"]


/** iPhoneX判断 */

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define Is_iPhoneX kScreenWidth >=375.0f && kScreenHeight >=812.0f

/** 状态栏高度 */
//#define LCL_StatusBar_Height ((LCLIsIphoneX) ? 44 : 20)
#define LCL_StatusBar_Height ((Is_iPhoneX) ? 24 : 0)

@interface LJDownloadManager () <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

@property (nonatomic, strong) NSMutableDictionary *downloadModelsDic; // Mutable dictionary which includes downloading and waiting models.

@property (nonatomic, strong) NSMutableArray *downloadingModels; // Models which are downloading.

@property (nonatomic, strong) NSMutableArray *waitingModels; // Models which are waiting to download.
@end
@implementation LJDownloadManager

+ (instancetype)sharedManager {

    static LJDownloadManager *downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] init];
        downloadManager.maxConcurrentDownloadCount = -1;//同时下载个数
        downloadManager.waitingQueueMode = LJWaitingQueueFIFO;
        downloadManager.isShowTip = false;
    });
    
    return downloadManager;
}

- (NSURLSession *)urlSession {
    
    if (!_urlSession) {
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _urlSession;
}

- (instancetype)init {
    
    if (self = [super init]) {
        NSString *downloadDirectory = LJDownloadDirectory;
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:downloadDirectory isDirectory:&isDirectory];
        if (!isExists || !isDirectory) {
            [fileManager createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

#pragma mark - Lazy Load

- (NSMutableDictionary *)downloadModelsDic {
    
    if (!_downloadModelsDic) {
        _downloadModelsDic = [NSMutableDictionary dictionary];
    }
    return _downloadModelsDic;
}

- (NSMutableArray *)downloadingModels {
    
    if (!_downloadingModels) {
        _downloadingModels = [NSMutableArray array];
    }
    return _downloadingModels;
}

- (NSMutableArray *)waitingModels {
    
    if (!_waitingModels) {
        _waitingModels = [NSMutableArray array];
    }
    return _waitingModels;
}

#pragma mark - Download

- (void)downloadFileOfURL:(NSURL *)URL
                    state:(void(^)(LJDownloadState state))state
                 progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
               completion:(void(^)(BOOL success, NSString *filePath, NSError *error))completion
{
    if (!URL) {
        return;
    }
    
    if ([self isDownloadCompletedOfURL:URL]) { // If this URL has been downloaded.
        if (state) {
            state(LJDownloadStateCompleted);
        }
        if (completion) {
         
            completion(YES, [self fileFullPathOfURL:URL], nil);
            
        }
        return;
    }
    
    LJDownloadModel *downloadModel = self.downloadModelsDic[LJFileName(URL)];
    if (downloadModel) { // If the download model of this URL has been added in downloadModelsDic.
        return;
    }
    
    // @"bytes=x-y" ==  x byte ~ y byte
    // @"bytes=x-"  ==  x byte ~ end
    // @"bytes=-y"  ==  head ~ y byte
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];//创建请求对象
    [requestM setValue:[NSString stringWithFormat:@"bytes=%lld-", (long long int)[self hasDownloadedLength:URL]] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:requestM];//创建task任务
    dataTask.taskDescription = LJFileName(URL);   //dataTask的taskDescription是文件地址
    
    downloadModel = [[LJDownloadModel alloc] init];//model对象用来存储下载相关信息
    downloadModel.dataTask = dataTask;
    downloadModel.outPutStream = [NSOutputStream outputStreamToFileAtPath:[self fileFullPathOfURL:URL] append:YES];
    downloadModel.url = URL;
    downloadModel.state = state;
    downloadModel.progress = progress;
    downloadModel.completion = completion;
    self.downloadModelsDic[dataTask.taskDescription] = downloadModel;
    
    LJDownloadState downloadState;
    if ([self canResumeDownload]) {
        [self.downloadingModels addObject:downloadModel];
        [dataTask resume];
        downloadState = LJDownloadStateRunning;
    } else {
        [self.waitingModels addObject:downloadModel];
        downloadState = LJDownloadStateWaiting;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(downloadState);
        }
    });
}

- (BOOL)canResumeDownload {
    
    if (self.maxConcurrentDownloadCount == -1) {
        return YES;
    }
    if (self.downloadingModels.count >= self.maxConcurrentDownloadCount) {
        return NO;
    }
    return YES;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    LJDownloadModel *downloadModel = self.downloadModelsDic[dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel openOutStream];
    
    NSInteger thisTotalLength = response.expectedContentLength; // Equals to [response.allHeaderFields[@"Content-Length"] integerValue]
    NSInteger totalLength = thisTotalLength + [self hasDownloadedLength:downloadModel.url];
    downloadModel.allBytesSize = totalLength;
    NSMutableDictionary *filesTotalLength = [NSMutableDictionary dictionaryWithContentsOfFile:LJFilesTotalLengthPlistPath] ?: [NSMutableDictionary dictionary];
    filesTotalLength[LJFileName(downloadModel.url)] = @(totalLength);
    [filesTotalLength writeToFile:LJFilesTotalLengthPlistPath atomically:YES];
    
    completionHandler(NSURLSessionResponseAllow);
}
//接收到数据的代理不停接受
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    LJDownloadModel *downloadModel = self.downloadModelsDic[dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel.outPutStream write:data.bytes maxLength:data.length];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.progress) {
            NSUInteger receivedSize = [self hasDownloadedLength:downloadModel.url];
            NSUInteger expectedSize = downloadModel.allBytesSize;
            CGFloat progress = 1.0 * receivedSize / expectedSize;
          
            downloadModel.progress(receivedSize, expectedSize, progress);
    
                       
        }
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error && error.code == -999) { // Cancelled!
        return;
    }
    
    LJDownloadModel *downloadModel = self.downloadModelsDic[task.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel closeOutputStream];
  
    [self.downloadModelsDic removeObjectForKey:task.taskDescription];
    [self.downloadingModels removeObject:downloadModel];
      __weak typeof(self) weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self isDownloadCompletedOfURL:downloadModel.url]) {
            if (downloadModel.state) {
                downloadModel.state(LJDownloadStateCompleted);
                
            }
            if (downloadModel.completion) {
                downloadModel.completion(YES, [self fileFullPathOfURL:downloadModel.url], error);
            }
         
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
          __block  UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, -30, rootViewController.view.frame.size.width, 30 )];
            label.text = @"下载任务完成！";
            [label setTextColor:[UIColor whiteColor]];
            label.tintColor = [UIColor whiteColor];
            [rootViewController.view addSubview:label];
            label.backgroundColor = [UIColor redColor];
              label.textAlignment = NSTextAlignmentCenter;
            label.alpha = 1;
           
            [UIView animateWithDuration:1.0 animations:^{
            
                label.frame = CGRectMake(0, LCL_StatusBar_Height,label.frame.size.width, label.frame.size.height  );
            }completion:^(BOOL finished){
              
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                  
                    [UIView animateWithDuration:1.0 animations:^{
                                   label.layer.cornerRadius = 30;
                        label.alpha = 0;
                                   label.frame = CGRectMake(label.frame.size.width, LCL_StatusBar_Height,label.frame.size.width, label.frame.size.height );
                      
                               }completion:^(BOOL finished){
                                   [label removeFromSuperview];
                                   label = nil;
                               }];

                    });

           
             
             } ];
           
            if(  weakSelf.isShowTip && weakSelf.downloadingModels.count == 0 ){

                                       
           
                                            }
            
        } else {
            if (downloadModel.state) {
                downloadModel.state(LJDownloadStateFailed);
            }
            if (downloadModel.completion) {
                downloadModel.completion(NO, nil, error);
            }
        }
    });
    
    [self resumeNextDowloadModel];
}

#pragma mark - Assist Methods

- (NSInteger)totalLength:(NSURL *)URL {
    
    NSDictionary *filesTotalLenth = [NSDictionary dictionaryWithContentsOfFile:LJFilesTotalLengthPlistPath];
    if (!filesTotalLenth) {
        return 0;
    }
    if (!filesTotalLenth[LJFileName(URL)]) {
        return 0;
    }
    return [filesTotalLenth[LJFileName(URL)] integerValue];
}

- (NSInteger)hasDownloadedLength:(NSURL *)URL {
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self fileFullPathOfURL:URL] error:nil];
    if (!fileAttributes) {
        return 0;
    }
    return [fileAttributes[NSFileSize] integerValue];
}

- (void)resumeNextDowloadModel {
    
    if (self.maxConcurrentDownloadCount == -1) {
        return;
    }
    if (self.waitingModels.count == 0) {
        return;
    }
    
    LJDownloadModel *downloadModel;
    switch (self.waitingQueueMode) {
        case LJWaitingQueueFIFO:
            downloadModel = self.waitingModels.firstObject;
            break;
        case LJWaitingQueueFILO:
            downloadModel = self.waitingModels.lastObject;
            break;
    }
    [self.waitingModels removeObject:downloadModel];
    
    LJDownloadState downloadState;
    if ([self canResumeDownload]) {
        [self.downloadingModels addObject:downloadModel];
        [downloadModel.dataTask resume];
        downloadState = LJDownloadStateRunning;
    } else {
        [self.waitingModels addObject:downloadModel];
        downloadState = LJDownloadStateWaiting;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(downloadState);
        }
    });
}

#pragma mark - Public Methods

#pragma mark - Files

- (BOOL)isDownloadCompletedOfURL:(NSURL *)URL {
    
    NSInteger totalLength = [self totalLength:URL];
    if (totalLength != 0) {
        if (totalLength == [self hasDownloadedLength:URL]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)fileFullPathOfURL:(NSURL *)URL {
    
    return LJFilePath(URL);
}

- (CGFloat)fileHasDownloadedProgressOfURL:(NSURL *)URL {
    
    if ([self isDownloadCompletedOfURL:URL]) {
        return 1.0;
    }
    if ([self totalLength:URL] == 0) {
        return 0.0;
    }
    return 1.0 * [self hasDownloadedLength:URL] / [self totalLength:URL];
}

- (void)deleteFileOfURL:(NSURL *)URL {
    
    [self cancelDownloadOfURL:URL];
    
    NSMutableDictionary *filesTotalLenth = [NSMutableDictionary dictionaryWithContentsOfFile:LJFilesTotalLengthPlistPath];
    [filesTotalLenth removeObjectForKey:LJFileName(URL)];
    [filesTotalLenth writeToFile:LJFilesTotalLengthPlistPath atomically:YES];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self fileFullPathOfURL:URL];
    if (![fileManager fileExistsAtPath:filePath]) {
        return;
    }
    if ([fileManager removeItemAtPath:filePath error:nil]) {
        return;
    }
    NSLog(@"removeItemAtPath Failed: %@", filePath);
}

- (void)deleteAllFiles {
    
    [self cancelAllDownloads];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//单例
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:LJDownloadDirectory error:nil];
    for (NSString *fileName in fileNames) {
        NSString *filePath = [LJDownloadDirectory stringByAppendingPathComponent:fileName];
        if ([fileManager removeItemAtPath:filePath error:nil]) {//移除
            continue;
        }
        NSLog(@"removeItemAtPath Failed: %@", filePath);
    }
}

- (void)setDownloadedFilesDirectory:(NSString *)downloadedFilesDirectory {
    
    _downloadedFilesDirectory = downloadedFilesDirectory;
    
    if (!downloadedFilesDirectory) {
        return;
    }
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:downloadedFilesDirectory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:downloadedFilesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Downloads

- (void)suspendDownloadOfURL:(NSURL *)URL {
    
    LJDownloadModel *downloadModel = self.downloadModelsDic[LJFileName(URL)];
    if (!downloadModel) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(LJDownloadStateSuspended);
        }
    });
    if ([self.waitingModels containsObject:downloadModel]) {
        [self.waitingModels removeObject:downloadModel];
    } else {
        [downloadModel.dataTask suspend];
        [self.downloadingModels removeObject:downloadModel];
    }
    
    [self resumeNextDowloadModel];
}

- (void)suspendAllDownloads {
    
    if (self.downloadModelsDic.count == 0) {
        return;
    }
    
    if (self.waitingModels.count > 0) {
        for (NSInteger i = 0; i < self.waitingModels.count; i++) {
            LJDownloadModel *downloadModel = self.waitingModels[i];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (downloadModel.state) {
                    downloadModel.state(LJDownloadStateSuspended);
                }
            });
        }
        [self.waitingModels removeAllObjects];
    }
    
    if (self.downloadingModels.count > 0) {
        for (NSInteger i = 0; i < self.downloadingModels.count; i++) {
            LJDownloadModel *downloadModel = self.downloadingModels[i];
            [downloadModel.dataTask suspend];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (downloadModel.state) {
                    downloadModel.state(LJDownloadStateSuspended);
                }
            });
        }
        [self.downloadingModels removeAllObjects];
    }
}

- (void)resumeDownloadOfURL:(NSURL *)URL ljDownloadModel:(LJDownloadModel * _Nullable)ljDownloadModel{
    
    if (!ljDownloadModel) {
         ljDownloadModel = self.downloadModelsDic[LJFileName(URL)];
    }else {
         ljDownloadModel = self.downloadModelsDic[LJFileName(URL)];
    }
  
    if (!ljDownloadModel) {
        return;
    }
    
    LJDownloadState downloadState;
    if ([self canResumeDownload]) {//是否可以开始
        [self.downloadingModels addObject:ljDownloadModel];
        [ljDownloadModel.dataTask resume];
        downloadState = LJDownloadStateRunning;
    } else {      //加入等待队列
        [self.waitingModels addObject:ljDownloadModel];
        downloadState = LJDownloadStateWaiting;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ljDownloadModel.state) {
            ljDownloadModel.state(downloadState);
        }
    });
}

- (void)resumeAllDownloads {
    
    if (self.downloadModelsDic.count == 0) {
        return;
    }
    
    NSArray *downloadModels = self.downloadModelsDic.allValues;
    for (LJDownloadModel *downloadModel in downloadModels) {
        
        [self resumeDownloadOfURL:nil ljDownloadModel:downloadModel];
//        LJDownloadState downloadState;
//        if ([self canResumeDownload]) {
//            [self.downloadingModels addObject:downloadModel];
//            [downloadModel.dataTask resume];
//            downloadState = LJDownloadStateRunning;
//        } else {
//            [self.waitingModels addObject:downloadModel];
//            downloadState = LJDownloadStateWaiting;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (downloadModel.state) {
//                downloadModel.state(downloadState);
//            }
//        });
    }
}

- (void)cancelDownloadOfURL:(NSURL *)URL {
    
    LJDownloadModel *downloadModel = self.downloadModelsDic[LJFileName(URL)];
    if (!downloadModel) {
        return;
    }
    
    [downloadModel closeOutputStream];
    [downloadModel.dataTask cancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadModel.state) {
            downloadModel.state(LJDownloadStateCanceled);
        }
    });
    if ([self.waitingModels containsObject:downloadModel]) {
        [self.waitingModels removeObject:downloadModel];
    } else {
        [self.downloadingModels removeObject:downloadModel];
    }
    [self.downloadModelsDic removeObjectForKey:LJFileName(URL)];
    
    [self resumeNextDowloadModel];//开始下载下一个
}

- (void)cancelAllDownloads {
    
    if (self.downloadModelsDic.count == 0) {
        return;
    }
    NSArray *downloadModels = self.downloadModelsDic.allValues;
    for (LJDownloadModel *downloadModel in downloadModels) {
        [downloadModel closeOutputStream];
        [downloadModel.dataTask cancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloadModel.state) {
                downloadModel.state(LJDownloadStateCanceled);
            }
        });
    }
    [self.waitingModels removeAllObjects];
    [self.downloadingModels removeAllObjects];
    [self.downloadModelsDic removeAllObjects];
}
@end
