//
//  FFMpegDecodeAudio.h
//  ffmpeg_decodeAudio
//
//  Created by LiDong on 2018/8/16.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import <Foundation/Foundation.h>
//注意：需要将文件夹“FFMpeg的4.0.2版本arm64静态库”内的整个复制到“项目FFMpeg中“，查看惊天库是否连接好即可运行
//核心库 音视频的编解码库
#import <libavcodec/avcodec.h>
//封装格式处理库
#import <libavformat/avformat.h>
//工具库
#import <libavutil/imgutils.h>
//视频像素数据格式库
#import <libswscale/swscale.h>
//音频采样数据格式库
#import <libswresample/swresample.h>

@interface FFMpegDecodeAudio : NSObject

+ (void)ffmpegDecodeAudioWithInFilePath:(NSString *)infilePath outFilePath:(NSString *)outFilePath;

@end
