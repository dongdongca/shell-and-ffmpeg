//
//  FFMpegDecodeVideo.m
//  ffmpeg_decodeVideo
//
//  Created by LiDong on 2018/8/15.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import "FFMpegDecodeVideo.h"

@implementation FFMpegDecodeVideo

+ (void)ffmpegDecodeVideoWithInFilePath:(NSString *)inFilePath outFilePath:(NSString *)outFilePath
{
    //第一步：注册组件
    avcodec_register_all();
    
    //第二步：打开封装格式文件-->打开文件
    //封装格式上下文
    AVFormatContext *av_format_context = avformat_alloc_context();
    //文件路径
    const char *url = [inFilePath UTF8String];
    
    int avformat_open_input_result = avformat_open_input(&av_format_context, url, NULL, NULL);
    if (avformat_open_input_result != 0) {
        NSLog(@"文件打开失败");
        return;
    }
    
    //第三步：查找视频流->拿到视频信息
    //参数一：封装格式上下文
    //参数二：设置为NULL，使用默认配置
    int avformat_find_stream_info_result = avformat_find_stream_info(av_format_context, NULL);
    if (avformat_find_stream_info_result < 0) {
        NSLog(@"查找视频流失败");
        return;
    }
    
    //第四步：查找视频解码器
    //1、查找视频流索引位置
    //定义一个记录视频流索引位置的变量
    int av_stream_index = -1;
    //判断流的类型：视频流、音频流、字母流等等
    for (int i = 0; i < av_format_context->nb_streams; i++) {
        if (av_format_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            av_stream_index = i;
            break;
        }
    }
    
    //2、根据视频流索引，获取解码器上下文
    AVCodecContext *avcodec_context = av_format_context->streams[av_stream_index]->codec;
    
    //3、根据解码器上下文，获得解码器ID，然后查找解码器
    AVCodec *avcodec = avcodec_find_decoder(avcodec_context->codec_id);
    
    
    //第五步：打开解码器
    int avcodec_open2_result = avcodec_open2(avcodec_context, avcodec, NULL);
    if (avcodec_open2_result != 0) {
        NSLog(@"打开解码器失败:%d",avcodec_open2_result);
        return;
    }
    NSLog(@"打开解码器成功:name--->%s",avcodec->name);
    
    //第六步：读取视频压缩数据（循环读取）
    //1、av_read_frame
    //参数一：封装格式上下文
    //参数二：一帧压缩数据
    AVPacket *packet = av_malloc(sizeof(AVPacket));
    
    //3.2 开辟一块内存
    //用来存放解码一帧压缩数据->进行解码（作用：用于解码操作）
    AVFrame *avframe_in = av_frame_alloc();
    //用来接收解码一帧压缩数据的结果
    int decodec_result = 0;
    
    //4、注意：在这里我们不能够保证解码出来的一帧视频像素数据格式是yuv格式，创建像素数据上下文
    //参数一：源文件->原始视频像素数据的宽
    //参数二：源文件->原始视频像素数据的高
    //参数三：源文件->原始视频像素数据的格式类型
    //参数四：目标文件->目标文件视频像素数据的宽
    //参数五：目标文件->目标文件视频像素数据的宽
    //参数六：目标文件->目标文件视频像素数据的格式类型
    //参数七：字节对其方式
    struct SwsContext *sws_Context = sws_getContext(avcodec_context->width,
                                             avcodec_context->height,
                                             avcodec_context->pix_fmt,
                                             avcodec_context->width,
                                             avcodec_context->height,
                                             AV_PIX_FMT_YUV420P,
                                             SWS_BICUBIC,
                                             NULL,
                                             NULL,
                                             NULL);
    
    //创建一个yuv420p的视频像素数据格式缓冲区（一帧数据）
    AVFrame *avframe_yuv420p = av_frame_alloc();
    //给缓冲区设置类型->yuv420类型
    //得到YUV420P缓冲区大小
    //参数一：视频像素数据格式类型->YUV420P格式
    //参数二：一帧视频像素数据宽 = 视频宽
    //参数三：一帧视频像素数据高 = 视频高
    //参数四：字节对齐方式->默认是1
    int buffer_size = av_image_get_buffer_size(AV_PIX_FMT_YUV420P,
                             avcodec_context->width,
                             avcodec_context->height,
                             1);
    
    //为avframe_yuv420p开辟一块内存空间
    uint8_t *out_buffer = (uint8_t *)av_malloc(buffer_size);
    //向avframe_yuv420p->填充数据
    //参数一：目标->填充数据（avframe_yuv420P）
    //参数二：目标->每一行的大小
    //参数三：原始数据
    //参数四：目标->格式类型
    //参数五：宽
    //参数六：高
    //参数七：字节对齐方式
    av_image_fill_arrays(avframe_yuv420p->data,
                         avframe_yuv420p->linesize,
                         out_buffer,
                         AV_PIX_FMT_YUV420P,
                         avcodec_context->width,
                         avcodec_context->height,
                         1);
    
    int y_size, u_size, v_size;
    
    //5.2、将yuv420p数据写入.yuv文件中
    //打开写入的文件
    //文件路径
    const char *outUrl = [outFilePath UTF8String];
    FILE *file_yuv420P = fopen(outUrl, "wb+");
    if (file_yuv420P == NULL) {
        NSLog(@"输出文件打开失败");
        return;
    }
    
    int current_index = 0;
    
    while (av_read_frame(av_format_context, packet) >= 0) {
        //第七步：视频解码->得到视频像素->播放视频
        //>=0:表示读取成功  <0:表示读取失败
        //2、判断是否是视频流
        if (packet->stream_index == av_stream_index) {
            //3、解码一帧压缩数据-->得到视频像素数据-->得到YUV格式数据
            //采用新的API
            //3.1发送一帧压缩数据
            avcodec_send_packet(avcodec_context, packet);
            //3.2解码一帧压缩数据->进行解码（作用：用于解码操作）
            decodec_result = avcodec_receive_frame(avcodec_context, avframe_in);
            if (decodec_result == 0) {
                NSLog(@"解码成功");
                //4、注意：在这里我们不能保证解码出来的一帧视频像素数据是yuv格式
                //视屏的像素数据有很多类型：例如yuv420p、yuv422p、yuv444p、
                //为了保证视频解码后的视频像素数据保持一致--->统一格式为yuv420p
                //进行数据转换：将解码出来的视频像素数点数据格式-->统一类型为yuv420p
                //参数一：视频像素数据上下文
                //参数二：原来的视频像素数据格式 -> 输入数据
                //参数三：原来的视频像素数据格式 -> 输入画面每一行的大小
                //参数四：原来的视频像素数据格式 -> 输入画面每一行的开始位置
                //参数五：原来的视频像素数据格式 -> 输入数据行数
                //参数六：转换类型后视频像素数据格式 -> 输出数据
                //参数七：转换类型后视频像素数据格式 -> 输入画面每一行的大小
                sws_scale(sws_Context,
                          (const uint8_t *const *)avframe_in->data ,
                          avframe_in->linesize, 0,
                          avframe_in->height,
                          avframe_yuv420p->data,
                          avframe_yuv420p->linesize);
                //方式一：直接显示视频上面去
                //方式二：写入yuv文件格式
                //5、将yuv420p数据写入.yuv文件中
                //5.1、计算yuv大小
                //分析原理
                //Y：表示亮度
                //UV：表示色度
                //YUV420P格式规范一：Y结构表示一个像素(一个像素对应一个Y)
                //YUV420P格式规范二：4个像素点对应一个(U和V: 4Y = U = V)
                y_size = avcodec_context->width * avcodec_context->height;
                u_size = y_size / 4;
                v_size = y_size / 4;
                
                //5.2写入.yuv文件
                //首先->写入Y
                fwrite(avframe_yuv420p->data[0], 1, y_size, file_yuv420P);
                //其次->写入U
                fwrite(avframe_yuv420p->data[1], 1, u_size, file_yuv420P);
                //最后写入V数据
                fwrite(avframe_yuv420p->data[2], 1, v_size, file_yuv420P);
                
                current_index++;
                NSLog(@"当前第%d帧解码完成",current_index);
            }
        }
    }
    
    
    //第八步：关闭解码器->解码完成
    //释放一帧压缩数据内存
    av_packet_free(&packet);
    //关闭file_yuv420P文件
    fclose(file_yuv420P);
    //释放avframe_in的视频像素数据格式
    av_frame_free(&avframe_in);
    //释放yuv420p的视频像素数据格式
    av_frame_free(&avframe_yuv420p);
    //释放out_buffer内存
    free(out_buffer);
    //关闭解码器上下文
    avcodec_close(avcodec_context);
    //释放封装格式上下文
    avformat_free_context(av_format_context);
    
    
}
@end
