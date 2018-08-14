//
//  FFmpegTest.m
//  FFmpeg_test
//
//  Created by LiDong on 2018/8/14.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import "FFmpegTest.h"


@implementation FFmpegTest

//测试ffmpeg
+ (void)ffmpegTestConfig
{
    const char * configuration = avcodec_configuration();
    NSLog(@"配置信息：%s",configuration);
}

//测试ffmpeg打开文件
+ (void)ffmpegOpenFile:(NSString *)filePath
{
    //第一步：注册组件
    avcodec_register_all();
    
    //第二步：打开封装格式文件
    //参数1：封装格式上下文
    AVFormatContext *formatContext = avformat_alloc_context();
    //参数2：要打开的视频地址
    const char *url = [filePath UTF8String];
    //参数3：指定输入封装格式-->默认格式
    //参数4：指定默认配置信息-->默认配置
    //返回值是int类型，0表示成功，非0即为失败
    int avformat_open_input_reuslt = avformat_open_input(&formatContext, url, NULL, NULL);
    
    if (avformat_open_input_reuslt != 0) {
        NSLog(@"打开失败");
        return;
    }
    
    NSLog(@"打开成功");
}

@end
