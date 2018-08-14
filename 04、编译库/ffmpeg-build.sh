#!/bin/bash

#1、定义下载库的名称
source="ffmpeg-4.0.2"

#2、定义“.h/.m/.c”文件编译的结果存放的文件
#目录作用：用于保存.h/.m.c编译后的.o文件
cache="cache"

#3、定义.a静态库的存放目录
#`pwd`命令：获取当前文件的目录
staticdir=`pwd`/"lidong-ffmpeg-ios"


#4、添加ffmpeg配置选项--->默认配置
#Toolchain options选项：工具链选项（指定我么需要编译平台CPU架构类型，例如：arm64、x86等等…）
#--enable-cross-compile:采用交叉编译
#--enable-pic：允许建立与位置无关代码

#Developer options:开发者选项
#--disable-debug：禁止使用调试模式

#Program options选项
#--disable-programs:禁用程序(不允许建立命令行程序)

#Documentation options:文档选项
#--disable-doc：不需要编译文档

configure_flags="--enable-cross-compile --disable-debug --disable-programs --disable-doc --enable-pic"
#核心库(编解码->最重要的库)：avcodec
configure_flags="$configure_flags --enable-avdevice --enable-avcodec --enable-avformat"
configure_flags="$configure_flags --enable-swresample --enable-swscale --disable-postproc"
configure_flags="$configure_flags --enable-avfilter --enable-avutil --enable-avresample "

#5、定义默认CPU平台架构类型
#arm64 armv7-->真机的CPU架构类型
#x86_64 i386-->模拟器的CPU架构类型
archs="arm64 armv7 x86_64 i386"

#6、指定我们这个库编译的系统版本->iOS系统下的7.0以及以上版本使用这个静态库
targetversion="8.0"

#7、接受命令后的输入参数
#我们动态的接受命令行输入CPU平台架构类型(输入参数：编译指定的CPU库)
if [ "$*" ]
then
    #存在输入参数，也就是说命令行指定了CPU平台架构类型，我们就是用外部指定的CPU平台架构类型
    archs="$*"

fi

#8、安装汇编器--->yasm
#判断一下是否存在这个汇编器
#注意
#错误：`which` yasm
#正确：`which yasm`

if [ !`which yasm` ]
then
    #如果没有安装就下载，安装汇编器
    #通过Homebrew:软件管理器来安装
    #目的：通过软件管理器(Homebrew)，然后下载安装（或者更新）我的汇编器，因为使用Homebrew能一个命令完成我们需要的操作
    if [ !`which brew` ]
    then
        echo "install Homebrew..."
        #通过ruby来安装homebrew，如果安装成功，往下继续执行，如果失败，就执行exit退出
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
    fi

    #homebrew安装成功后，安装yasm
    echo "yasm开始安装"

    #开始安装yasm
    #exit 1 --> 如果安装失败退出
    brew install yasm || exit 1

fi

echo "循环编译开始"

#9、for循环编译ffmpeg静态库
#记录一下当前文件路径
currentdir=`pwd`

for arch in $archs
do
    echo "开始编译..."
    #9.1、创建目录
    #在编译结果目录下创建对应的平台架构类型
    mkdir -p "$cache/$arch"

    #9.2、进入这个目录
    cd "$cache/$arch"

    #9.3、配置编译CPU架构类型-->指定当前编译CPU架构类型
    #错误："--arch $arch"
    #正确："-arch $arch"
    archflags="-arch $arch"

    #9.4、判断一下当前要编译事模拟器.a静态库。还是真机的.a静态库
    if [ "$arch" = "i386" -o "$arch" = "x86_64" ]
    then
        #是模拟器
        platfrom="iPhoneSimulator"
        #设置支持最小系统版本--->iOS系统
        archflags="$archflags -mios-simulator-version-min=$targetversion"
    else
        #是真机
        platform="iPhoneOS"
        #设置支持最小的系统版本
        archflags="$archflags -mios-version-min=$targetversion -fembed-bitcode"
        #注意：优化处理（可有可无）
        #如果CPU架构类型是“arm64”，在XCode5下需要最如下优化
        if [ "$arch" = "arm64" ]
        then
            #GNU汇编器（GUN Assembler），简称GAS
            #GASPP->汇编器预处理程序
            #解决问题：分段错误
            #通俗一点：就是程序运行时，变量访问越界一类的问题
            EXPORT="GASPP_FIX_XCODE5=1"
        fi
    fi

    #10、正式编译
    #tr命令：可以对来自标准输入的字符进行替换、压缩和删除
    #'[:upper:]'->将小写转换成大写
    #'[:lower:]'->将大写转换成小写
    #将platform--->转成大写或者小写
    XCRUN_SDK=`echo $platform | tr '[:upper:]' '[:lower:]'`

    #设置编译器--->编译平台
    CC="xcrun -sdk $XCRUN_SDK clang"

    #架构类型-->arm64
    if [ "$arch" = "arm64" ]
    then
        #音视频默认一个编译命令
        #perprocessor.pl 帮助我们编译ffmpeg--->arm64位的静态库
        #此处注意使用对应版本的"gas-preprocessor.pl"文件
        AS="gas-preprocessor.pl -arch aarch64 -- $CC"
    else
        AS="$CC"
    fi

    echo "执行到这了"
    #目录找到FFmepg编译源代码目录->设置编译配置->编译FFmpeg源码
    #--target-os:目标系统->darwin(mac系统早起版本名字)
    #darwin:是mac系统、iOS系统祖宗
    #--arch:CPU平台架构类型
    #--cc：指定编译器类型选项
    #--as:汇编程序
    #$configure_flags最初配置
    #--extra-cflags
    #--prefix：静态库输出目录
    TMPDIR=${TMPDIR/%\/} $currentdir/$source/configure \
    --target-os=darwin \
    --arch=$arch \
    --cc="$CC" \
    --as="$AS" \
    $configure_flags \
    --extra-cflags="$archflags" \
    --extra-ldflags="$archflags" \
    --prefix="$staticdir/$arch" \
    || exit 1

    echo "执行了"

    #解决问题->分段错误问题
    #安装->导出静态库(编译.a静态库)
    #执行命令
    make -j3 install $EXPORT || exit 1
    #回到了我们的脚本文件目录
    cd $currentdir

done







