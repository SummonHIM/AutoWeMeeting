# AutoWeMeeting
一个自动进入腾讯会议的 AutoHotKey 脚本。

## 下载
[![GitHub Release](https://img.shields.io/github/downloads/SummonHIM/AutoWeMeeting/latest/total?label=Release%20%E4%B8%8B%E8%BD%BD&style=flat-square)](https://github.com/SummonHIM/AutoWeMeeting/releases/latest)

下载速度不佳可将下载链接复制到 [GhProxy.com](http://ghproxy.com/) 下载。

## 使用说明
1. 解压下载好的压缩包。
2. 按照实际情况使用表格软件编写时间表（[Schedule.csv](https://github.com/SummonHIM/AutoWeMeeting/blob/master/Schedule.csv)）。[编写教程](#时间表编写指南)
3. 打开软件，32 位与 64 位根据实际情况选一个打开。软件将在后台运行。到点自动开启会议。

## 注意事项
- 当脚本运行中，即使编辑时间表，保存也能马上应用。可以不用重启。
- 若你的电脑启动腾讯会议较为卡顿。可在程序目录创建 Configs\SleepTime.cfg 文件（其中`Configs`为文件夹名）。并在文件内直接输入执行延迟数值。单位毫秒。

**若时间已到运行时请：**
- **不要**移动鼠标或点击键盘。
- 虽然脚本会最小化所有窗口。但还是**尽量不要**打开窗口。
- **可以**关闭电脑屏幕，但**不能**进入锁屏状态。
- 若使用 RDP（远程桌面连接），则**不能**最小化窗口。

## 时间表编写指南
- A 列 (sDateTime)：填具体运行时间，格式如下：[点击查看](https://wyagd001.github.io/v2/docs/commands/FileSetTime.htm#YYYYMMDD)，示例：202212081355 即为 2022年12月8日13点55分
- B 列 (MeetID)：填腾讯会议号
- C 列 (PassWD)：填会议密码（可选）

## License
[GPL-2.0 license](https://github.com/SummonHIM/AutoWeMeeting/blob/master/LICENSE)