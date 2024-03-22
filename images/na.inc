GS_MASTERCODE equ 0x1d2278, 0x27bdffe0
MasterHook = 0x110378
label flAnimSpeed:4 at 0x2b623c
label aWaitFlags:4 at 0x383510
;label aTextFlags:4 at aWaitFlags+0x10
;label aTextFlags2:4 at aTextFlags+0x1000
label wEventFlags:4 at 0x386588
label wStatus:4 at 0x373bf8
label wFlags:4 at 0x2bfd98
label wBrightRed:4 at 0x2b64b0
label wRoom:4 at 0x2b6570
label wLoadScreen:4 at 0x2b6b80
label wContinueCommand:4 at 0x3f1128
label wGameInput:4 at 0x2bff14
label wInput:4 at 0x2b6e44
label wDisableGameInput:4 at 0x2b7550
label wOpenSave:4 at 0x2bb748
label wMenuType:4 at 0x2b7558
label hGrandHallPatch:2 at 0x1d22c0
StopFMV = 0x110eb8 
GetFmvStatus = 0x110df8
SetContinue = 0x11c210
StopSound = 0x1eae60
StopVoice = 0x1eb238
SetupRoom = 0x1c0e08
JalSomeRender = 0x100468
HeadRender = 0x1147d0
L_EndRender = 0x100528
SysTable = 0x3d3070
Sys55 = 0x1cced0
Sys8C = 0x1ce730
Sys270 = 0x1ccf08
ClearSkipVars = 0x1d65e0
LoadAnimations = 0x1200f8
JalLoadAnims = 0x1cd460
label pSora:4 at 0x2dcae0
SysSleep = 0x1cb1d0
AdvText1 = 0x1c8f28
AdvText2 = 0x1c9cd0
AdvText3 = 0x1c9a00
macro AdvText3.DelayCode
  addiu a2,s5,-0x70d8
end macro
ControlLips = 0x1cdb78
aItems = 0x2c08e0
SysPlayVoice = 0x1ddde8
Sys121 = 0x1d2278
PlayGSound = 0x11d2e0
GetTextFromId = 0x1ed9b8
DrawText = 0x1efa48
L_ExitInput = 0x11448c
L_CallWaitVBlanks = 0x109944
WaitForVBlanks = 0x110248
SysFadeIn = 0x1cbc68
Sys36 = 0x1e8188
L_EndSwapBuffers = 0x106298
SendGsPacket = 0x1069b0
