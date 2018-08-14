//
//  FFmpegTest.h
//  FFmpeg_test
//
//  Created by LiDong on 2018/8/14.
//  Copyright © 2018年 LiDong. All rights reserved.
//

//注意：将编译好的库拖到FFmpeg文件夹即可运行

#import <Foundation/Foundation.h>
//核心库--->音视频编解码库
#import <libavcodec/avcodec.h>
//封装格式库
#import <libavformat/avformat.h>

@interface FFmpegTest : NSObject
//测试ffmpeg
+ (void)ffmpegTestConfig;

//测试ffmpeg打开文件
+ (void)ffmpegOpenFile:(NSString *)filePath;
@end
