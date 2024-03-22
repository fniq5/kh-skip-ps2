GS_MASTERCODE equ 0x100410, 0x0c041044
MasterHook = 0x110404
label wLoadScreen:4 at 0x2b8c90
label wRoom:4 at 0x2b8680
label wEventFlags:4 at 0x388558
label wStatus:4 at 0x375bc0
label wFlags:4 at 0x2c1ea8
label wBrightRed:4 at 0x2b85c0

label wGameInput:4 at 0x2c2024
label wInput:4 at 0x2b8f54
label wDisableGameInput:4 at 0x2b9660

label L_RenderSequence:4 at 0x10989c
label wRenderVar:4 at 0x2b834c
WaitForVBlanks = 0x1102c0
L_CallWaitVBlanks = 0x10989c
SwapBuffers = 0x105e10
SwapBuffersTail = 0x106948
L_EndScene = 0x1061d0

label wMenuType:4 at 0x2b9668
label wOpenSave:4 at 0x2bd858
label wCurrentState:4 at 0x2b8330
label hGrandHallPatch:2 at 0x1d5cb0
label wInFMV:4 at 0x2b9030
label aWaitFlags:4 at 0x3854e0 ;16 bytes long
;label aTextFlags:4 at 0x3854f0 ;0x1000 bytes long?
;label aTextFlags2:4 at 0x3864f0 ;32 bytes long?
label wContinueCommand:4 at 0x3f1518
ClearSkipVars = 0x1da000
SetContinue = 0x11c4b0
StopFMV = 0x110f68
GetFmvStatus = 0x110ea8
StopVoice = 0x1ee768
StopSound = 0x11c680
SetupRoom = 0x1c4740
JalLoadAnims = 0x1d0fa8
LoadAnimations = 0x120590
JalSomeRender = 0x100358
HeadRender = 0x114800
L_EndRender = 0x100418
SysTable = 0x3d4a20
SysFadeIn = 0x1cf788 ;Sys1b
Sys36 = 0x1eb840
Sys55 = 0x1d0a08
Sys8C = 0x1d2280
Sys13D = 0x1d68d8
Sys270 = 0x1d0a40
label flAnimSpeed:4 at 0x2b8344
SysPlayVoice = 0x1e1538
Sys121 = 0x1d5c68
SysSleep = 0x1cece0
AdvText1 = 0x1ccb18-8
AdvText2 = 0x1cd8e8-8
AdvText3 = 0x1cd620-8
macro AdvText3.DelayCode
  addiu a2,s5,-0x34e8
end macro
ControlLips = 0x1d16c0
aItems = 0x2c2a00
PlayGSound = 0x11d598
GetTextFromId = 0x1f0ef0
DrawText = 0x1f2ef8
pSora = 0x2dec00
L_ExitInput = 0x1144bc
L_EndSwapBuffers = 0x1061d0
SendGsPacket = 0x106948

