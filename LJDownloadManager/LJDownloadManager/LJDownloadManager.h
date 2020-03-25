//
//  LJDownloadManager.h
//  LJDownloadManager
//
//  Created by lijiehu on 2020/3/24.
//  Copyright © 2020 lijiehu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJDownloadModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,LJWaitingQueueMode) {
    LJWaitingQueueFIFO = 0,
    LJWaitingQueueFILO
};

@interface LJDownloadManager : NSObject

/**
 Directory where the downloaded files are saved, default is .../Library/Caches/LJDownloadManager if not setted.
 */
@property (nonatomic, copy) NSString *downloadedFilesDirectory;

/**
 Count of max concurrent downloads, default is -1 which means no limit.
 */
@property (nonatomic, assign) NSInteger maxConcurrentDownloadCount;

/**
 Mode of waiting downloads queue, default is FIFO.
 */
@property (nonatomic, assign) LJWaitingQueueMode waitingQueueMode;

@property (nonatomic, ) BOOL isShowTip;

+ (instancetype)sharedManager;

/**
 Download a file and provide state、progress、completion callback.

 @param URL        The URL of the file which want to download.
 @param state      Callback block when the download state changed.
 @param progress   Callback block when the download progress changed.
 @param completion Callback block when the download completion.
 */
- (void)downloadFileOfURL:(NSURL *)URL
                    state:(void (^)(LJDownloadState state))state
                 progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progress
               completion:(void (^)(BOOL success, NSString *filePath, NSError *error))completion;

- (BOOL)isDownloadCompletedOfURL:(NSURL *)URL;

#pragma mark - Files

- (NSString *)fileFullPathOfURL:(NSURL *)URL;

- (CGFloat)fileHasDownloadedProgressOfURL:(NSURL *)URL;

- (void)deleteFileOfURL:(NSURL *)URL;
- (void)deleteAllFiles;

#pragma mark - Downloads

- (void)suspendDownloadOfURL:(NSURL *)URL;
- (void)suspendAllDownloads;

- (void)resumeDownloadOfURL:(NSURL * __nullable)URL ljDownloadModel:(LJDownloadModel * __nullable)ljDownloadModel;
- (void)resumeAllDownloads;

- (void)cancelDownloadOfURL:(NSURL *)URL;
- (void)cancelAllDownloads;

@end

NS_ASSUME_NONNULL_END
