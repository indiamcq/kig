; this sends the string (%3) to the target windows (%1) control (%2)
; this does not wipe out the existing text ( at least in Paratext verse box)
Opt("WinTitleMatchMode", 2)
; the following line may not be needed but is there to ensure that that window is swapped to.
WinWait ( $CmdLine[1])
WinActivate ( $CmdLine[1])
WinWaitActive ( $CmdLine[1])
ControlSend ( $CmdLine[1] , "" , $CmdLine[2]  , $CmdLine[3] )
