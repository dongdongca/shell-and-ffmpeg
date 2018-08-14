#!/bin/bash

#https://ffmpeg.org/releases/ffmpeg-4.0.2.tar.bz2

#库名称
source="ffmpeg-4.0.2"

#下载这个库
if [ ! -r $source ]
then
    #文件中没有库，就执行下载操作
    echo "未找到ffmpeg，开始下载操作"
#下载语法：curl 下载地址
#指定下载版本：将版本号拼接在连接中
#下载下来是压缩包，我们需要解压
#解压或压缩命令：tar
#基本语法是：tar options
#例如：tar xj
#options选项分为很多中类型
#-x 表示：解压文件选项
#-j 表示：是否需要解压bz2压缩包（压缩包格式类型有很多：zip、bz2等等…）
#执行下载命令，传入版本，并解压。如果下载或解压失败，就直接退出
curl https://ffmpeg.org/releases/${source}.tar.bz2 | tar xj || exit 1


fi
