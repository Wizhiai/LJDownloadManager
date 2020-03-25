//
//  LJDownloadModel.m
//  LJDownloadManager
//
//  Created by lijiehu on 2020/3/24.
//  Copyright © 2020 lijiehu. All rights reserved.
//

#import "LJDownloadModel.h"

@implementation LJDownloadModel

-(void)openOutStream {
    if(_outPutStream) {
        [_outPutStream open];
    }
}

-(void)closeOutputStream {
    if(_outPutStream) {
        if((_outPutStream.streamStatus > NSStreamStatusNotOpen) && (_outPutStream.streamStatus < NSStreamStatusClosed) )//流状态是否可关闭
        [_outPutStream close];
        
        _outPutStream  = nil;
    }
}
@end
