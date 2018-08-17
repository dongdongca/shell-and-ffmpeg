//
//  ViewController.m
//  ffmpeg_decodeAudio
//
//  Created by LiDong on 2018/8/16.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import "ViewController.h"
#import "FFMpegDecodeAudio.h"

@interface ViewController ()
@property (nonatomic, copy) NSString *outFilePath;
@property (nonatomic, copy) NSString *inFilePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //输入文件路径
    NSString *inStr= [NSString stringWithFormat:@"Video.bundle/%@",@"Test.mov"];
    self.inFilePath=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:inStr];
    
    //输出文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    self.outFilePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Test.pcm"]];
    
    //音频解码
    [FFMpegDecodeAudio ffmpegDecodeAudioWithInFilePath:self.inFilePath outFilePath:self.outFilePath];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
