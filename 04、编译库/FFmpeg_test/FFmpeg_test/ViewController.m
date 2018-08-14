//
//  ViewController.m
//  FFmpeg_test
//
//  Created by LiDong on 2018/8/13.
//  Copyright © 2018年 LiDong. All rights reserved.
//

#import "ViewController.h"
#import "FFmpegTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FFmpegTest ffmpegTestConfig];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@".mov"];
    [FFmpegTest ffmpegOpenFile:path];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
