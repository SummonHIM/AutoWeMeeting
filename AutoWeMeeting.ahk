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

If (CheckWeMeetLocation()) {
    TrayTip "请注意前台尽量不要打开窗口！", "程序已在后台运行！", 1
} Else {
    TrayTip ,"没有检测到腾讯会议！退出。", 2
    Exit
}

While True {
    For Index, CheckTime in LoadCSVSchedule("sDateTime") {
        If (Number(FormatTime(CheckTime, "yyyyMMddhhmmss")) = Number(FormatTime(,"yyyyMMddhhmmss"))) {
            TrayTip "正在启动会议 ID " LoadCSVSchedule("MeetID")[Index] "，尽量不要移动鼠标或键盘…", "到钟！", 1
            If (ProcessExist("wemeetapp.exe")) {
                ProcessClose "wemeetapp.exe"
                Sleep 300
                Run "C:\Program Files (x86)\Tencent\WeMeet\wemeetapp.exe"
                Sleep 3000
                WinMoveTop "ahk_exe wemeetapp.exe"
                ImageSearch &xLeaveMeet, &yLeaveMeet, 0, 0, 1000, 1000, "awm-blucancel.png"
                Click xLeaveMeet, yLeaveMeet
                Sleep 3000
            } Else {
                Run "C:\Program Files (x86)\Tencent\WeMeet\wemeetapp.exe"
                While ! WinExist("ahk_exe wemeetapp.exe") {
                    Sleep 3000
                }
            }
            WinMoveTop "ahk_exe wemeetapp.exe"
            Sleep 500
            ImageSearch &xJoinMeet, &yJoinMeet, 0, 0, 1000, 1000, "awm-joinmeet.png"
            Click xJoinMeet, yJoinMeet
            Sleep 500
            WinMoveTop "加入会议"
            Loop 6
            {
                Send "{BS}"
                Sleep 10
            }
            Send "{BS}"
            Sleep 500
            SendText LoadCSVSchedule("MeetID")[Index]
            Sleep 500
            Send "{Enter}"
            If (LoadCSVSchedule("PassWD")[Index]) {
                Sleep 500
                WinMoveTop "wemeetapp"
                SendText LoadCSVSchedule("PassWD")[Index]
                Sleep 500
                Send "{Enter}"
            }
            TrayTip "等待 10 秒后程序将隐藏后台。", "启动向导执行完毕", 1
            Sleep 5000
        }
    }
}
