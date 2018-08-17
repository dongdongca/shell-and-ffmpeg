//
//  FFMpegDecodeAudio.m
//  ffmpeg_decodeAudio
//
//  Created by LiDong on 2018/8/16.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import "FFMpegDecodeAudio.h"

@implementation FFMpegDecodeAudio

+ (void)ffmpegDecodeAudioWithInFilePath:(NSString *)infilePath outFilePath:(NSString *)outFilePath
{
    //第一步：组册组件
    avcodec_register_all();
    
    //第二步：打开封装格式->打开文件
    //封装格式上下文
    AVFormatContext * avformat_context = avformat_alloc_context();
    //文件路径
    const char *url = [infilePath UTF8String];
    
    int avformat_open_input_result = avformat_open_input(&avformat_context, url, NULL, NULL);
    if (avformat_open_input_result != 0) {
        NSLog(@"文件打开失败");
        return;
    }
    
    //第三步：查找音频流->拿到音频信息
    //参数一:封装格式上下文
    //参数二：设为NULL，使用默认配置
    int avformat_find_stream_info_result = avformat_find_stream_info(avformat_context, NULL);
    if (avformat_find_stream_info_result < 0) {
        NSLog(@"查找音频信息失败");
    }
    
    //第四步：查找音频解码器
    //1、查找音频流的索引位置
//用来记录音频索引位置
int av_stream_index = -1;
for (int i = 0; i < avformat_context->nb_streams; i++) {
    //判断是否是音频流
    if (avformat_context->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
        av_stream_index = i;
        break;
    }
}
    
    //2、获取音频解码器上下文
    AVCodecContext *avcodec_context = avformat_context->streams[av_stream_index]->codec;
    
    //3、获取音频解码器
    AVCodec *avCodec = avcodec_find_decoder(avcodec_context->codec_id);
    if (avCodec == NULL) {
        NSLog(@"音频解码器获取失败");
        return;
    }
    
    //第五步：打开音频解码器
    int avcodec_open2_result = avcodec_open2(avcodec_context, avCodec, NULL);
    if (avcodec_open2_result != 0) {
        NSLog(@"打开音频解码器失败");
        return;
    }
    
    NSLog(@"获取音频解码器成功，解码器是：%s",avCodec->name);
    
    //第六步：读取音频压缩数据->循环读取
    //创建音频压缩数据帧
    //音频压缩数据->acc格式、mp3格式
    AVPacket *avpacket = (AVPacket *)av_malloc(sizeof(AVPacket));
    
    //创建音频采样数据帧
    AVFrame *audio_frame = av_frame_alloc();
    //记录音频采样解码结果
    int audio_decode_result = 0;
    
    //创建音频采样上下文->开辟一块内存空间->pcm格式等
    //上下文作用：保存音频信息（记录）->目录
    SwrContext *swr_context = swr_alloc();
    //音频采样上下文在初始化之前，需要使用swr_alloc_set_opts设置参数
    //参数一：音频采样数据上下文->swr_context
    //参数二：out_ch_layout -> 输出声道布局类型（立体声、环绕声、机器人等等...）
    int64_t out_ch_layout = AV_CH_LAYOUT_STEREO;
    
    //参数三：out_sample_fmt -> 输出采样精度->编码
    //例如：采样精度8位 = 1字节，采样精度16位 = 2字节
    //第一种直接指定输出采样精度
    enum AVSampleFormat out_sample_fmt = AV_SAMPLE_FMT_S16;
    //第二种使用输入采样精度
//    enum AVSampleFormat out_sample_fmt = avcodec_context->sample_fmt;
    
    //参数四：out_sample_rate -> 输出采样率（44100HZ）
    int out_sample_rate = avcodec_context->sample_rate;
    
    //参数五：in_ch_layout -> 输入声道布局类型
    int64_t in_ch_layout = av_get_default_channel_layout(avcodec_context->channels);
    
    //参数六：in_sample_fmt -> 输入采样精度
    enum AVSampleFormat in_sample_fmt = avcodec_context->sample_fmt;
    
    //参数七：in_sample_rate -> 输入采样率
    int in_sample_rate = avcodec_context->sample_rate;
    
    //参数八：log_offset -> log_offset->log日志->从那里开始统计0
    int log_offset = 0;
    
    //参数九：log_ctx -> 设为NULL，默认
    swr_alloc_set_opts(swr_context,
                       out_ch_layout,
                       out_sample_fmt,
                       out_sample_rate,
                       in_ch_layout,
                       in_sample_fmt,
                       in_sample_rate,
                       log_offset,
                       NULL);
    //初始化音频采样上下文
    swr_init(swr_context);
    
    //为输出音频采样数据开辟缓存空间
    //缓冲区大小 = 采样率（44100HZ） * 采样精度（16位 = 2字节）
    int MAX_AUDIO_SIZAE = 44100 * 2;
    uint8_t *out_buffer = (uint8_t *)av_malloc(MAX_AUDIO_SIZAE);
    
    //输出声道数量
    int out_nb_channels = av_get_channel_layout_nb_channels(out_ch_layout);
    
    //打开输出文件
    const char *coutFilePath = [outFilePath UTF8String];
    FILE *out_file_pcm = fopen(coutFilePath, "wb+");
    if (out_file_pcm == NULL) {
        NSLog(@"打开音频输出文件失败");
        return;
    }
    
    //记录音频解码帧数
    int current_index = 0;
    
    //循环读取
    while (av_read_frame(avformat_context, avpacket) >= 0) {
        //读取一帧音频压缩数据成功
        //判断读取的是否是音频压缩数据流
        if (avpacket->stream_index == av_stream_index) {
            //第七步：音频解码
            //1、发送一帧音频压缩数据包->音频压缩数据帧
            avcodec_send_packet(avcodec_context, avpacket);
            //2、解码一帧音频压缩数据包->得到->一帧音频采样数据->音频采样数据帧
            audio_decode_result = avcodec_receive_frame(avcodec_context, audio_frame);
            if (audio_decode_result == 0) {
                NSLog(@"音频压缩数据解码成功");
                //3、类型转换(音频采样数据格式有很多种类型)
                //我希望我们的音频采样数据格式->pcm格式->保证格式统一->输出PCM格式文件
                //swr_convert:表示音频采样数据类型格式转换器
                //参数一：音频采样数据上下文
                //参数二：输出音频采样数据
                //参数三：输出音频采样数据->大小
                //参数四：输入音频采样数据
                //参数五：输入音频采样数据->大小
                swr_convert(swr_context,
                            &out_buffer,
                            MAX_AUDIO_SIZAE,
                            (const uint8_t **)audio_frame->data,
                            audio_frame->nb_samples);
                
                //4、获取缓冲区实际储存大小
                //参数一：行大小可以为null
                //参数二：输出声道数量
                //参数三：输入大小
                int nb_samples = audio_frame->nb_samples;
                //参数四：输出音频采样数据个数
                //参数五：字节对其方式
                int out_buffer_size = av_samples_get_buffer_size(NULL,
                                           out_nb_channels,
                                           nb_samples,
                                           out_sample_fmt,
                                           1);
                //5、写入文件
                fwrite(out_buffer, 1, out_buffer_size, out_file_pcm);
                
                current_index++;
                NSLog(@"当前解码帧数是：%d",current_index);
            }
        }
    }
    
    //第八步：释放内存资源，关闭音频解码器
    //关闭文件
    fclose(out_file_pcm);
    //释放音频压缩数据帧
    av_packet_free(&avpacket);
    //关闭音频采样上下文
    swr_free(&swr_context);
    //释放存储音频解码数据的内存
    av_free(out_buffer);
    //释放音频采样数据帧
    av_frame_free(&audio_frame);
    //关闭音频解码器上下文
    avcodec_close(avcodec_context);
    //关闭封装格式上下文
    avformat_free_context(avformat_context);
    
    
    
    
}

@end
