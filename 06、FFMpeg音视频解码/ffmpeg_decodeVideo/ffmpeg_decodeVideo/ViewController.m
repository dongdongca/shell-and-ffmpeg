//
//  ViewController.m
//  ffmpeg_decodeVideo
//
//  Created by LiDong on 2018/8/15.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import "ViewController.h"
#import "FFMpegDecodeVideo.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic, copy) NSString *outFilePath;
@property (nonatomic, copy) NSString *inFilePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *inStr= [NSString stringWithFormat:@"Video.bundle/%@",@"Test.mov"];
    self.inFilePath=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:inStr];
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *tmpPath = [path stringByAppendingPathComponent:@"temp"];
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
    self.outFilePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Test.yuv"]];
    
    
    
    [FFMpegDecodeVideo ffmpegDecodeVideoWithInFilePath:self.inFilePath outFilePath:self.outFilePath];
    
    
}
- (IBAction)player:(id)sender {
    NSData *data = [NSData dataWithContentsOfFile:self.outFilePath];
    NSLog(@"%lu",(unsigned long)data.length);
    
//    NSURL *url = [NSURL fileURLWithPath:self.inFilePath];
//    
//    //    NSURL *url = [NSURL URLWithString:@"http://dazhao.sinaapp.com/lovetosa/abc.mp4"];
//    
//    // 2.创建AVPlayerItem
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
//    // 3.创建AVPlayer
//    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
//    // 4.添加AVPlayerLayer
//    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
//    
//    layer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
//    
//    [self.view.layer addSublayer:layer];
//    //播放
//    [player play];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
