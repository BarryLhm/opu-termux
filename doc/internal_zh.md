
# 内部实现

## 文件和目录

+ `res/`：资源目录
  + `common.zsh`：脚本共享库
  + `pulse-config.pa`：PulseAudio 配置文件
  + `lang/`：多语言字符串
    + `<$LANG>.lang`
  + `bin/`：容器中使用的程序
    + `envfix`：一键环境修复
+ `data/`：数据目录，第一次运行时创建
  + `rootfs/`：容器根目录
  + `home/`：容器内用户主目录（/root）
  + `openutau/`：OpenUtau 程序目录，容器内挂载至 /runtime/.openutau
  + `opu.zip`：使用 DOWNLOAD 下载的 OpenUtau 包
+ `call`：调用内部功能，用于测试/手动操作
+ `START`：启动
+ `DOWNLOAD`：自动下载并安装 OpenUtau
+ `WIZARD`：配置向导
+ `doc/`：文档

##

- 脚本库（`res/common.zsh`）

一个 zsh 脚本库，包含必需的全局变量和函数定义

此阶段不应运行任何命令，除了测试类命令和全局变量设置

使用如下命令导入此库：

`. "$(dirname "$(realpath "$0")")/res/common.zsh" "$0"`
