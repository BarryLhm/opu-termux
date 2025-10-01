# opu-termux

在手机上运行 OpenUtau

- 许可协议/免责声明

opu-termux 是开源软件，代码托管于 Codeberg 和 Github（镜像）

许可协议为 GPL-3.0，具体内容请查看 LICENSE 文件

!!! 你应自行检查是否存在漏洞或你怀疑的恶意代码，
任何使用该软件造成的损失与开发者无关 !!!

- 使用方法（仅为参考，你可以自由发挥😎）

1. 配置 Termux（如已经做过可跳过此步）

从 F-Droid 或其他官方渠道下载最新版 Termux 和 Termux:X11（编写本文时最新版为0.119）

打开 Termux

运行 `termux-change-repo`，
用方向键和空格选中第二项 `Single Mirror`（单个镜像），换行确认；
用同样的方法选中 `mirrors.ustc.edu.cn`（由中科大提供）并确认

运行 `pkg up`，中间会问一些问题，直接换行确认或输入Y即可

运行 `pkg add zsh git` 安装 Zsh 和 Git

2. 下载并配置 opu-termux

运行 `git clone https://codeberg.org/BarryLhm/opu-termux` 下载此软件

运行 `./opu-termux/WIZARD` 进入配置向导

3. 启动

最好先使用 `exit` 退出所有 Termux 会话，然后划掉 Termux 的后台卡片
（使用类原生系统的可以在应用信息里强行停止）

打开 Termux，运行 `./opu-termux/START`

打开 Termux:X11，等待画面出现（可以提前打开一下，节省加载时间，这一步没有顺序要求，可以在任意时候进行）
