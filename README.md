# opu-termux

在（安卓）手机上运行 OpenUtau

本程序是开源软件，以 GPL-3.0 协议发布，开发者不对任何使用该软件造成的损失负责

喜欢的话可以点个 star 喵~

全部文档：[English](doc/index.md) [中文](doc/index_zh.md)

## 使用方法

### 配置

- 需要安装的软件：Termux，Termux:X11

可以从 F-Droid 和官方 Github Release 下载

- 更换软件源

运行 `termux-change-repo`，
用上下方向键移动光标选中第二项 `Single Mirror`（单个镜像），按空格选择，换行确认；
用同样的方法选中 `mirrors.ustc.edu.cn`（由中科大提供）并确认

- 安装软件包

运行 `pkg up`，有询问的输入 Y 或者直接回车跳过

运行 `pkg add zsh git` 安装 Zsh 和 Git

如果要使用自动下载功能（`DOWNLOAD`），还需要安装 `curl` `wget` `jq`：
`pkg add curl wget jq`

- 克隆仓库

运行 `git clone https://codeberg.org/BarryLhm/opu-termux` 下载此软件

- 运行 `./opu-termux/WIZARD` 进入配置向导

### 启动

PS：最好先运行 `exit` 退出 Termux，
然后再点击 Termux 通知的 `Exit` 按钮
最后划掉 Termux 的后台卡片
（使用类原生系统的可以在应用信息里强行停止）

- 打开 Termux，运行 `./opu-termux/START`

- 打开 Termux:X11，等待画面出现
