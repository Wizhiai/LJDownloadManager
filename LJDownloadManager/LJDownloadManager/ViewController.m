//
//  ViewController.m
//  LJDownloadManager
//
//  Created by lijiehu on 2020/3/25.
//  Copyright © 2020 lijiehu. All rights reserved.
//

#import "ViewController.h"
//#import "LJDownloadModel.h"
#import "LJDownloadManager.h"
NSString * const downloadURLString1 = @"http://yxfile.idealsee.com/9f6f64aca98f90b91d260555d3b41b97_mp4.mp4";
NSString * const downloadURLString2 = @"http://yxfile.idealsee.com/31f9a479a9c2189bb3ee6e5c581d2026_mp4.mp4";
NSString * const downloadURLString3 = @"http://yxfile.idealsee.com/d3c0d29eb68dd384cb37f0377b52840d_mp4.mp4";

#define kDownloadURL1 [NSURL URLWithString:downloadURLString1]
#define kDownloadURL2 [NSURL URLWithString:downloadURLString2]
#define kDownloadURL3 [NSURL URLWithString:downloadURLString3]

@interface ViewController ()

@property (strong, nonatomic)  UIButton *downloadButton1;
@property (strong, nonatomic)  UIButton *downloadButton2;
@property (strong, nonatomic)  UIButton *downloadButton3;

@property (strong, nonatomic)  UIButton *deleteButton1;
@property (strong, nonatomic)  UIButton *deleteButton2;
@property (strong, nonatomic)  UIButton *deleteButton3;



@property (strong, nonatomic)  UIProgressView *progressView1;
@property (strong, nonatomic)  UIProgressView *progressView2;
@property (strong, nonatomic)  UIProgressView *progressView3;

@property (strong, nonatomic)  UILabel *progressLabel1;
@property (strong, nonatomic)  UILabel *progressLabel2;
@property (strong, nonatomic)  UILabel *progressLabel3;

@property (strong, nonatomic)  UILabel *totalSizeLabel1;
@property (strong, nonatomic)  UILabel *totalSizeLabel2;
@property (strong, nonatomic)  UILabel *totalSizeLabel3;

@property (strong, nonatomic)  UILabel *currentSizeLabel1;
@property (strong, nonatomic)  UILabel *currentSizeLabel2;
@property (strong, nonatomic)  UILabel *currentSizeLabel3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.downloadButton1 = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 90, 30)];
    self.downloadButton2 = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 90, 30)];
     self.downloadButton3 = [[UIButton alloc]initWithFrame:CGRectMake(100, 300, 90, 30)];
    
    self.deleteButton1 = [[UIButton alloc]initWithFrame:CGRectMake(300, 100, 90, 30)];
      self.deleteButton2 = [[UIButton alloc]initWithFrame:CGRectMake(300, 200, 90, 30)];
       self.deleteButton3 = [[UIButton alloc]initWithFrame:CGRectMake(300, 300, 90, 30)];
    [_deleteButton3 setTitle:@"删除" forState:UIControlStateNormal];
    
    [self.deleteButton3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [_deleteButton2 setTitle:@"删除" forState:UIControlStateNormal];
      
      
         [self.deleteButton2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [_deleteButton1 setTitle:@"删除" forState:UIControlStateNormal];

      [self.deleteButton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
      
    
    [_deleteButton1 addTarget:self action:@selector(deleteFile1:) forControlEvents:UIControlEventTouchUpInside];
    
      [_deleteButton2 addTarget:self action:@selector(deleteFile2:) forControlEvents:UIControlEventTouchUpInside];
    
      [_deleteButton3 addTarget:self action:@selector(deleteFile3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteButton1];
    [self.view addSubview:_deleteButton2];
       [self.view addSubview:_deleteButton3];
          
    
    [_downloadButton1 setTitle:@"start" forState:UIControlStateNormal];

    [self.downloadButton1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
     [_downloadButton2 setTitle:@"start" forState:UIControlStateNormal];
     
    [self.downloadButton2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
      
     [_downloadButton3 setTitle:@"start" forState:UIControlStateNormal];
    [self.downloadButton3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
      [_downloadButton3 setTintColor:[UIColor blueColor ]];
    [self.downloadButton1 addTarget:self action:@selector(downloadFile1:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.downloadButton2 addTarget:self action:@selector(downloadFile2:) forControlEvents:UIControlEventTouchUpInside];
       
       
       [self.downloadButton3 addTarget:self action:@selector(downloadFile3:) forControlEvents:UIControlEventTouchUpInside];
          
          
          
    
    self.progressView1 = [[UIProgressView alloc]initWithFrame:CGRectMake(110, 95, 200, 30)];
      self.progressView2 = [[UIProgressView alloc]initWithFrame:CGRectMake(110, 195, 200, 30)];
          self.progressView3 = [[UIProgressView alloc]initWithFrame:CGRectMake(110, 295, 200, 30)];
    
     self.progressLabel1  = [[UILabel alloc]initWithFrame:CGRectMake(120, 75, 200, 30)];
     self.progressLabel2  = [[UILabel alloc]initWithFrame:CGRectMake(120, 175, 200, 30)];
     self.progressLabel3  = [[UILabel alloc]initWithFrame:CGRectMake(120, 275, 200, 30)];
              
    self.totalSizeLabel1  = [[UILabel alloc]initWithFrame:CGRectMake(20, 75, 200, 30)];
        self.totalSizeLabel2  = [[UILabel alloc]initWithFrame:CGRectMake(20, 175, 200, 30)];
        self.totalSizeLabel3  = [[UILabel alloc]initWithFrame:CGRectMake(20, 275, 200, 30)];
    
    self.currentSizeLabel1  = [[UILabel alloc]initWithFrame:CGRectMake(420, 75, 200, 30)];
           self.currentSizeLabel2  = [[UILabel alloc]initWithFrame:CGRectMake(420, 175, 200, 30)];
           self.currentSizeLabel3  = [[UILabel alloc]initWithFrame:CGRectMake(420, 275, 200, 30)];
       
    [self.view addSubview:self.currentSizeLabel1];
    
    [self.view addSubview:self.currentSizeLabel2];
       [self.view addSubview:self.currentSizeLabel3];
          [self.view addSubview:self.totalSizeLabel1];
             [self.view addSubview:self.totalSizeLabel2];
         [self.view addSubview:self.totalSizeLabel3];
    [self.view addSubview:self.progressLabel1];
                   [self.view addSubview:self.progressLabel2];
                      [self.view addSubview:self.progressLabel3];
                         [self.view addSubview:self.progressView1];
   [self.view addSubview:self.progressView2];
    
    
    
     [self.view addSubview:self.progressView3];
    
    
    
         [self.view addSubview:self.downloadButton1];
             [self.view addSubview:self.downloadButton2];
             [self.view addSubview:self.downloadButton3];
        if ([[LJDownloadManager sharedManager] isDownloadCompletedOfURL:kDownloadURL1]) {
            NSLog(@"%@", [[LJDownloadManager sharedManager] fileFullPathOfURL:kDownloadURL1]);
        }
        if ([[LJDownloadManager sharedManager] isDownloadCompletedOfURL:kDownloadURL2]) {
            NSLog(@"%@", [[LJDownloadManager sharedManager] fileFullPathOfURL:kDownloadURL2]);
        }
        if ([[LJDownloadManager sharedManager] isDownloadCompletedOfURL:kDownloadURL3]) {
            NSLog(@"%@", [[LJDownloadManager sharedManager] fileFullPathOfURL:kDownloadURL3]);
        }
        [LJDownloadManager sharedManager].isShowTip = YES;
        // Uncomment the following line to customize the directory where the downloaded files are saved.
    //    [LJDownloadManager sharedManager].downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] \
    //                                                           stringByAppendingPathComponent:@"CustomDownloadDirectory"];
        
        // Uncomment the following line to customize the Maximum concurrent downloads
        [LJDownloadManager sharedManager].maxConcurrentDownloadCount = 1;
        
        // Uncomment the following line to customize the queue for waiting downloads.
        [LJDownloadManager sharedManager].waitingQueueMode = LJWaitingQueueFILO;
        
        CGFloat progress1 = [[LJDownloadManager sharedManager] fileHasDownloadedProgressOfURL:kDownloadURL1];
        CGFloat progress2 = [[LJDownloadManager sharedManager] fileHasDownloadedProgressOfURL:kDownloadURL2];
        CGFloat progress3 = [[LJDownloadManager sharedManager] fileHasDownloadedProgressOfURL:kDownloadURL3];
        NSLog(@"progress of downloadURL1: %.2f", progress1);
        NSLog(@"progress of downloadURL2: %.2f", progress2);
        NSLog(@"progress of downloadURL3: %.2f", progress3);
        
        self.progressView1.progress = progress1;
        self.progressLabel1.text = [NSString stringWithFormat:@"%.f%%", progress1 * 100];
        [self.downloadButton1 setTitle:@"Start" forState:UIControlStateNormal];
        
        self.progressView2.progress = progress2;
        self.progressLabel2.text = [NSString stringWithFormat:@"%.f%%", progress2 * 100];
        [self.downloadButton2 setTitle:@"Start" forState:UIControlStateNormal];
        
        self.progressView3.progress = progress3;
        self.progressLabel3.text = [NSString stringWithFormat:@"%.f%%", progress3 * 100];
        [self.downloadButton3 setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)deleteAllFiles:(UIBarButtonItem *)sender {
    
    [[LJDownloadManager sharedManager] deleteAllFiles];
    
    self.progressView1.progress = 0.0;
    self.progressView2.progress = 0.0;
    self.progressView3.progress = 0.0;
    
    self.currentSizeLabel1.text = @"0";
    self.currentSizeLabel2.text = @"0";
    self.currentSizeLabel3.text = @"0";
    
    self.totalSizeLabel1.text = @"0";
    self.totalSizeLabel2.text = @"0";
    self.totalSizeLabel3.text = @"0";
    
    self.progressLabel1.text = @"0%";
    self.progressLabel2.text = @"0%";
    self.progressLabel3.text = @"0%";
    
    [self.downloadButton1 setTitle:@"Start" forState:UIControlStateNormal];
    [self.downloadButton2 setTitle:@"Start" forState:UIControlStateNormal];
    [self.downloadButton3 setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)downloadFile1:(UIButton *)sender {
    
    [self download:kDownloadURL1
    totalSizeLabel:self.totalSizeLabel1
  currentSizeLabel:self.currentSizeLabel1
     progressLabel:self.progressLabel1
      progressView:self.progressView1
            button:sender];
}

- (void)downloadFile2:(UIButton *)sender {
    
    [self download:kDownloadURL2
    totalSizeLabel:self.totalSizeLabel2
  currentSizeLabel:self.currentSizeLabel2
     progressLabel:self.progressLabel2
      progressView:self.progressView2
            button:sender];
}

- (void)downloadFile3:(UIButton *)sender {
    
    [self download:kDownloadURL3
    totalSizeLabel:self.totalSizeLabel3
  currentSizeLabel:self.currentSizeLabel3
     progressLabel:self.progressLabel3
      progressView:self.progressView3
            button:sender];
}

- (void)download:(NSURL *)URL totalSizeLabel:(UILabel *)totalSizeLabel currentSizeLabel:(UILabel *)currentSizeLabel progressLabel:(UILabel *)progressLabel progressView:(UIProgressView *)progressView button:(UIButton *)button {
    
    if ([button.currentTitle isEqualToString:@"Start"]) {
        [[LJDownloadManager sharedManager] downloadFileOfURL:URL
                                                       state:^(LJDownloadState state) {
                                                           [button setTitle:[self titleWithDownloadState:state] forState:UIControlStateNormal];
                                                       } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                                                           currentSizeLabel.text = [NSString stringWithFormat:@"%zdMB", receivedSize / 1024 / 1024];
                                                           totalSizeLabel.text = [NSString stringWithFormat:@"%zdMB", expectedSize / 1024 / 1024];
                                                           progressLabel.text = [NSString stringWithFormat:@"%.f%%", progress * 100];
                                                           progressView.progress = progress;
                                                       } completion:^(BOOL success, NSString *filePath, NSError *error) {
                                                           if (success) {
                                                               NSLog(@"FilePath: %@", filePath);
                                                           } else {
                                                               NSLog(@"Error: %@", error);
                                                           }
                                                       }];
    } else if ([button.currentTitle isEqualToString:@"Waiting"]) {
        [[LJDownloadManager sharedManager] cancelDownloadOfURL:URL];
    } else if ([button.currentTitle isEqualToString:@"Pause"]) {
        [[LJDownloadManager sharedManager] suspendDownloadOfURL:URL];
    } else if ([button.currentTitle isEqualToString:@"Resume"]) {
        [[LJDownloadManager sharedManager] resumeDownloadOfURL:URL ljDownloadModel:nil];
    } else if ([button.currentTitle isEqualToString:@"Finish"]) {
        NSLog(@"File has been downloaded! File path: %@", [[LJDownloadManager sharedManager] fileFullPathOfURL:URL]);
    }
}

- (NSString *)titleWithDownloadState:(LJDownloadState)state {
    
    switch (state) {
        case LJDownloadStateWaiting:
            return @"Waiting";
        case LJDownloadStateRunning:
            return @"Pause";
        case LJDownloadStateSuspended:
            return @"Resume";
        case LJDownloadStateCanceled:
            return @"Start";
        case LJDownloadStateCompleted:
            return @"Finish";
        case LJDownloadStateFailed:
            return @"Start";
    }
}

- (void)deleteFile1:(UIButton *)sender {
    
    [[LJDownloadManager sharedManager] deleteFileOfURL:kDownloadURL1];
    
    self.progressView1.progress = 0.0;
    self.currentSizeLabel1.text = @"0";
    self.totalSizeLabel1.text = @"0";
    self.progressLabel1.text = @"0%";
    [self.downloadButton1 setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)deleteFile2:(UIButton *)sender {
    
    [[LJDownloadManager sharedManager] deleteFileOfURL:kDownloadURL2];
    
    self.progressView2.progress = 0.0;
    self.currentSizeLabel2.text = @"0";
    self.totalSizeLabel2.text = @"0";
    self.progressLabel2.text = @"0%";
    [self.downloadButton2 setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)deleteFile3:(UIButton *)sender {
    
    [[LJDownloadManager sharedManager] deleteFileOfURL:kDownloadURL3];
    
    self.progressView3.progress = 0.0;
    self.currentSizeLabel3.text = @"0";
    self.totalSizeLabel3.text = @"0";
    self.progressLabel3.text = @"0%";
    [self.downloadButton3 setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)suspendAllDownloads:(UIButton *)sender {
    
    [[LJDownloadManager sharedManager] suspendAllDownloads];
}

- (void)resumeAllDownloads:(UIButton *)sender {
    
    [[LJDownloadManager sharedManager] resumeAllDownloads];
}

- (void)cancelAllDownloads:(UIBarButtonItem *)sender {
    
    [[LJDownloadManager sharedManager] cancelAllDownloads];
}


@end
