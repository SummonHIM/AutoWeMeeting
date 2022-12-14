#SingleInstance Force

GetWeMeetLocation() {
    ; 若 HKCU\SOFTWARE\Tencent\WeMeet 存在则返回注册表值
    Loop Reg, "HKCU\SOFTWARE\Tencent\WeMeet", "R V"
    {
        If A_LoopRegType = "key"
            WeMeetFolder := ""
        Else {
            try
                WeMeetFolder := RegRead()
        }
        Return WeMeetFolder
    }
}

CheckWeMeetLocation() {
    ; 若注册表值存储的文件夹内包含 wemeetapp.exe 则返回True
    WeMeetLocation := GetWeMeetLocation() "\wemeetapp.exe"
    If FileExist(WeMeetLocation)
        Return True
    Else
        Return False
}

LoadCSVSchedule(ReqParams) {
    ; 输入 ReqParams 返回 Schedule 中对应值，没有则返回 False
    sDateTime := []
    MeetID := []
    PassWD := []
    Loop read, "Schedule.csv" {
        If (A_Index > 1) {
            ; LineNumber := A_Index
            Loop parse, A_LoopReadLine, "CSV" {
                If (A_Index = 1)
                    sDateTime.Push(A_LoopField)
                Else If (A_Index = 2)
                    MeetID.Push(A_LoopField)
                Else If (A_Index = 3)
                    PassWD.Push(A_LoopField)
            }
        }
    }
    If (ReqParams = "sDateTime")
        Return sDateTime
    Else If (ReqParams = "MeetID")
        Return MeetID
    Else If (ReqParams = "PassWD")
        Return PassWD
    Else
        Return False
}

StartWeMeet(ReqIndex) {
    TrayTip "正在启动会议 ID " LoadCSVSchedule("MeetID")[ReqIndex] "，请不要移动鼠标或键盘…", FormatTime(CheckTime " R") " 到钟！", 1
    If (ProcessExist("wemeetapp.exe")) {
        ProcessClose "wemeetapp.exe"
        Sleep SleepTime
    }
    WinMinimizeAll
    Run GetWeMeetLocation() "\wemeetapp.exe"
    While !WinExist("ahk_exe wemeetapp.exe") {
        Sleep SleepTime * 10
    }
    WinMoveTop "ahk_exe wemeetapp.exe"
    Sleep SleepTime
    ImageSearch &xJoinMeet, &yJoinMeet, 0, 0, 1000, 1000, "AWM-JoinMeet.png"
    Click xJoinMeet, yJoinMeet
    Sleep SleepTime
    Loop 6
    {
        Send "{Backspace}"
        Sleep 10
    }
    Sleep SleepTime
    SendText LoadCSVSchedule("MeetID")[ReqIndex]
    Sleep SleepTime
    Send "{Enter}"
    If (LoadCSVSchedule("PassWD")[ReqIndex]) {
        Sleep SleepTime
        SendText LoadCSVSchedule("PassWD")[ReqIndex]
        Sleep SleepTime
        Send "{Enter}"
    }
    WinMinimizeAllUndo
    TrayTip "等待 " (SleepTime * 10) / 1000 " 秒后程序将隐藏后台。", "启动向导执行完毕", 1
    Sleep SleepTime * 10
}

A_TrayMenu.Delete()
A_TrayMenu.Add("关于", MenuAbout)
A_TrayMenu.Add()
A_TrayMenu.Add("重新启动", MenuReload)
A_TrayMenu.Add("退出", MenuExit)
Persistent

MenuAbout(ItemName, ItemPos, MyMenu) {
    TrayTip "版本号：脚本源代码执行`n正在为你打开项目官网！", "关于", 4
    Run "https://github.com/SummonHIM/AutoWeMeeting"
}
MenuReload(ItemName, ItemPos, MyMenu) {
    Reload
}
MenuExit(ItemName, ItemPos, MyMenu) {
    ExitApp
}

if not FileExist("Schedule.csv") {
    TrayTip "时间表文件 Schedule.csv 不存在！退出。", "缺少必要文件！", 3
    Exit
}

if not FileExist("AWM-JoinMeet.png") {
    TrayTip "图片 AWM-JoinMeet.png 不存在！退出。", "缺少必要文件！", 3
    Exit
}

If (CheckWeMeetLocation()) {
    TrayTip "请注意前台尽量不要打开窗口！", "程序已在后台运行！", 1
} Else {
    TrayTip , "没有检测到腾讯会议！退出。", 3
    Exit
}

; 读取 Configs\SleepTime.cfg 来调整 Delay。如果你的电脑越卡建议设越长的时间。单位毫秒。
if FileExist("Configs\SleepTime.cfg") {
    SleepTime := FileRead("Configs\SleepTime.cfg")
    TrayTip "设定的执行延迟为：" SleepTime "毫秒", "已读取设定好的自定义执行延迟！", 1
} Else {
    SleepTime := 1000
}

While True {
    For Index, CheckTime in LoadCSVSchedule("sDateTime") {
        If (Number(FormatTime(CheckTime, "yyyyMMddHHmmss")) = Number(FormatTime(, "yyyyMMddHHmmss"))) {
            StartWeMeet(Index)
        }
    }
}