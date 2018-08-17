# 关于底层音视频的学习笔记
**XMind文件需要XMind软件才能查看**

### 一、shell脚本语言基础知识
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_basis/shell_basis.png)
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_basis/shell_basis_01.png)
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_basis/shell_basis_02.png)


### 二、shell重定向相关
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_redirect/shell_redirect.png)
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_redirect/shell_redirect_01.png)


### 三、shell数据操作
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_mysql/shell_mysql.png)
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_mysql/shell_mysql_01.png)
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_mysql/shell_mysql_02.png)


### 四、手写编译脚本
```
先在终端执行
./ffmpeg-download.sh

注意：source="ffmpeg-4.0.2"改成对应的版本号

然后执行
./ffmpeg-build.sh arm64
```
![Image text](https://github.com/dongdongca/shell-and-ffmpeg/blob/master/image/shell_ffmpeg/shell_ffmpeg_01.png)

### 五、主要介绍FFMpeg的基础知识
1、视频播放流程

        通常看到视频格式：mp4、mov、flv、wmv等等…
        称之为：封装格式
2、视频播放器

        两种模式播放器
        第一种：可视化界面播放器（直接用户直观操作->简单易懂）
                腾讯视频、爱奇艺视频、QQ影音、暴风影音、快播、优酷等等…
        第二种：非可视化界面播放器->命令操作播放器->用户看不懂，使用起来非常麻烦
                FFmpeg->ffplay（命令）播放器（内置播放器）vlc播放器、mplayer播放器

3、播放器信息查看工具

        整个视频信息：MediaInfo工具->帮助我们查看视频完整信息
        二进制查看信息：直接查看视频二进制数据（0101010）->UItraEdit
        视频单项信息
        封装格式信息工具->Elecard Format Analyzer
        视频编码信息工具->Elecard Stream Eye
        视频像素信息工具->YUVPlayer
        音频采样数据工具->Adobe Audition

4、音视频->封装格式？

        1、封装格式：mp4、mov、flv、wmv等等…
        2、封装格式作用
                视频流+音频流按照格式进行存储在一个文件中
        3、MPEG2-TS格式？
                视频压缩数据格式：MPEG2-TS
                特定：数据排版，不包含头文件，数据大小固定（188byte）的TS-Packet

5、视频编码数据了解一下

        1、视频编码作用？
        将视频像素数据（YUV、RGB）进行压缩成为视频码流，从而降低视频数据量。（减小内存暂用）
        2、视频编码格式有哪些？
        H264、H263、wmv等等
        3、H.264视频压缩数据格式？
        非常复杂算法->压缩->占用内存那么少？（例如：帧间预测、帧内预测…）->提高压缩性能

6、音频编码数据？

        1、音频编码作用？
                将音频采样数据（PCM格式）进行压缩成为音频码流，从而降低音频数据量。（减小内存暂用）
        2、音频编码飞逝有哪些？
                AAC、MP3等等…
        3、AAC格式？
                AAC，全称Advanced Audio Coding，是一种专为声音数据设计的文件压缩格式。与MP3不同，它采用了全新的算法进行编码，更加高效，具有更高的“性价比”。利用AAC格式，可使人感觉声音质量没有明显降低的前提下，更加小巧。苹果ipod、诺基亚手机支持AAC格式的音频文件。
                优点：相对于mp3，AAC格式的音质更佳，文件更小。
                不足：AAC属于有损压缩的格式，与时下流行的APE、FLAC等无损格式相比音质存在“本质上”的差距。加之，传输速度更快的USB3.0和16G以上大容量MP3正在加速普及，也使得AAC头上“小巧”的光环不复存在。
                ①提升的压缩率：可以以更小的文件大小获得更高的音质；
                ②支持多声道：可提供最多48个全音域声道；
                ③更高的解析度：最高支持96KHz的采样频率；
                ④提升的解码效率：解码播放所占的资源更少；


7、视频像素数据？

        1、作用？
                保存了屏幕上面每一个像素点的值
        2、视频像素数据格式种类？
                常见格式：RGB24、RGB32、YUV420P、YUV422P、YUV444P等等…一般最常见：YUV420P
        3、视频像素数据文件大小计算？
                例如：RGB24高清视频体积？（1个小时时长）
                体积：3600 * 25 * 1920 * 1080 * 3 = 559GB（非常大）
                假设：帧率25HZ，采样精度8bit，3个字节
        4、YUV播放器
                人类：对色度不敏感，对亮度敏感 
                Y表示：亮度
                UV表示：色度
8、音频采样数据格式？

        1、作用？
                保存了音频中的每一个采样点值
        2、音频采样数据文件大小计算？
                例如：1分钟PCM格式歌曲
                体积：60 * 44100 * 2 * 2 = 11MB
                分析：60表示时间，44100表示采样率（一般情况下，都是这个采样率，人的耳朵能够分辨的声音），2表示声道数量，2表示采样精度16位 = 2字节 


9、FFmepg应用（重要命令学习）

        核心架构设计思想：（核心 + 插件）设计
        1、ffmpeg.exe（视频压缩->转码来完成）
        作用：用于对视频进行转码
        将mp4->mov，mov->mp4，wmv->mp4等等…
        命令格式：ffmpeg -i {指定输入文件路径} -b:v {输出视频码率} {输出文件路径}
        测试运行：将Test.mov->Test.mp4
        时间格式：如何指定？
         
        2、ffplay.exe
        作用：播放视频
        格式：ffplay {文件路径}
        例如：./ffplay Test.mov
        
        3、视频，转为高质量 GIF 动图？
        命令：./ffmpeg -ss 00:00:03 -t 3 -i Test.mov -s 640x360 -r “15” dongtu.gif
        解释：
        1、-ss 00:00:03 表示从第 00 分钟 03 秒开始制作 GIF，如果你想从第 9 秒开始，则输入 -ss 00:00:09，或者 -ss 9，支持小数点，所以也可以输入 -ss 00:00:11.3，或者 -ss 34.6 之类的，如果不加该命令，则从 0 秒开始制作；
        2、-t 3 表示把持续 3 秒的视频转换为 GIF，你可以把它改为其他数字，例如 1.5，7 等等，时间越长，GIF 体积越大，如果不加该命令，则把整个视频转为 GIF；
        3、-i 表示 invert 的意思吧，转换；
        4、Test.mov 就是你要转换的视频，名称最好不要有中文，不要留空格，支持多种视频格式；
        5、-s 640x360 是 GIF 的分辨率，视频分辨率可能是 1080p，但你制作的 GIF 可以转为 720p 等，允许自定义，分辨率越高体积越大，如果不加该命令，则保持分辨率不变；
        6、-r “15” 表示帧率，网上下载的视频帧率通常为 24，设为 15 效果挺好了，帧率越高体积越大，如果不加该命令，则保持帧率不变；
        7、dongtu.gif：就是你要输出的文件，你也可以把它命名为 hello.gif 等等。


### 六、FFMpeg音视频解码
1、视频解码

    第一步：组册组件
    av_register_all()
    例如：编码器、解码器等等…

    第二步：打开封装格式->打开文件
    例如：.mp4、.mov、.wmv文件等等...
    avformat_open_input();

    第三步：查找视频流
    如果是视频解码，那么查找视频流，如果是音频解码，那么就查找音频流
    avformat_find_stream_info();

    第四步：查找视频解码器
    1、查找视频流索引位置
    2、根据视频流索引，获取解码器上下文
    3、根据解码器上下文，获得解码器ID，然后查找解码器

    第五步：打开解码器
    avcodec_open2();

    第六步：读取视频压缩数据->循环读取
    没读取一帧数据，立马解码一帧数据

    第七步：视频解码->播放视频->得到视频像素数据

    第八步：关闭解码器->解码完成

    具体查看项目Dome
    
2、音频解码

    第一步：组册组件
    av_register_all();

    第二步：打开封装格式->打开文件
    avformat_open_input();

    第三步：查找音频流->拿到音频信息
    avformat_find_stream_info();

    第四步：查找音频解码器
    avcodec_find_decoder();
    1、查找音频流索引位置
    2、根据音频流索引，获取解码器上下文
    3、根据解码器上下文，获得解码器ID，然后查找解码器

    第五步：打开音频解码器
    avcodec_open2();

    第六步：读取音频压缩数据->循环读取
    具体查看项目Dome

    第七步：音频解码
    具体查看项目Dome

    第八步：释放内存资源，关闭音频解码器
    具体查看项目Dome

