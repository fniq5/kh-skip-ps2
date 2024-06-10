GS_MASTERCODE equ 0x121378, 0xdfb40070
MasterHook = 0x110610
label wGameInput:4 at 0x2c5ad4
label wInput:4 at 0x2bca04
label wDisableGameInput:4 at 0x2bd110
label wMenuType:4 at 0x2bd118
label wOpenSave:4 at 0x2c1308
label aWaitFlags:4 at 0x389c90
label hGrandHallPatch:4 at 0x1d43a0
label wLoadScreen:4 at 0x2bc740
label wRoom:4 at 0x2bc130
label wEventFlags:4 at 0x38cd08
label wStatus:4 at 0x37a378
label wFlags:4 at 0x2c5958
label wIsSkipMenuOpen:4 at 0x3f34a4
label wSkipCursor:4 at 0x3f76b8
label wRealTime:4 at 0x2bbdf4
label wFmvMode:4 at 0x2bcae0
label wPlayedSplashes:4 at 0x2bc73c
label wPlaying:4 at 0x2bbe08
SysTable = 0x3d9fe0
Sys55 = 0x1cef80
Sys8C = 0x1d07e0
Sys270 = 0x1cefb8
L_EndRender = 0x100538
HeadRender = 0x114c00
JalSomeRender = 0x100478
LoadAnimations = 0x120748
JalLoadAnims = 0x1cf510
ClearSkipVars = 0x1d87d8
SetupRoom = 0x1c2ec8
GetFmvStatus = 0x111090
StopFMV = 0x111150
SetContinue = 0x11c698
StopVoice = 0x1ed6b0
StopSound = 0x1ed2d8
OpenSkipMenu = 0x1dca00
label wContinueCommand:4 at 0x3f7778
label wBrightRed:4 at 0x2bc070
label flAnimSpeed:4 at 0x2bbdfc
pSora = 0x2e26a0
L_ExitInput = 0x1148bc
L_CallWaitVBlanks = 0x109b94
WaitForVBlanks = 0x1104e0
SysFadeIn = 0x1cdd18
Sys36 = 0x1ea5f8
Sys121 = 0x1d4358
AdvText1 = 0x1cafe8
AdvText2 = 0x1cbd80
AdvText3 = 0x1cbab0
macro AdvText3.DelayCode
  addiu a2, s5, -0x5018
end macro
aItems = 0x2c64a0
DrawText = 0x1f1ed8
GetTextFromId = 0x1efc10
PlayGSound = 0x11d768
L_EndSwapBuffers = 0x1063c0
SendGsPacket = 0x106b18 
SaveForContinue = 0x1d3e08
SetPerf = 0x1220d0
FmvCode1 = 0x111190
DestroyFmv = 0x1111b0
