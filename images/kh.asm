include 'mips.inc'
include 'gs.inc'

dd GS_MASTERCODE
format_gs

;asm MasterHook
;  j OnFrame
;  addiu sp, sp, 0x40
;end asm 

V_JP = 0
V_NA = 1
V_FM = 2

CUT_MONSTRO = 0x4d
CUT_NVHOLD = 0x93
CUT_JENIE = 0x10a
CUT_URSULA1 = 0x59
CUT_URSULA2 = 0x5a

include 'config.inc'

if KHVER eq V_JP
include 'jp.inc'
else if KHVER eq V_NA
include 'na.inc'
else if KHVER eq V_FM
include 'fm.inc'
end if

SIZEOF_ITEM = 0x4b0

label wPressed:4 at wInput+4
label wGamePressed:4 at wGameInput+4
label wScene:4 at (wRoom+4)
label wWorld:4 at (wRoom+8)
label aTextFlags:4 at aWaitFlags+0x10
label aTextFlags2:4 at aTextFlags+0x1000

IGNORESKIPPABLEbit = 1 shl 0
WAITFADEbit = 1 shl 1
NOSKIPshft = 2
NOSKIPbit = 1 shl NOSKIPshft
MANUALbit = 1 shl 3
GRANDHALLbit = 1 shl 4
;SLEEPYbit = 1 shl 5
JENIEbit = 1 shl 6
;SKIPONVOICEbit = 1 shl 7
SETSKIPONFADEHBbit = 1 shl 7
;CLEARLOADbit = 1 shl 8
SETSKIPONFADEbit = 1 shl 9
CLEARSKIPON36bit = 1 shl 10
SETPERMABATTLEbit = 1 shl 11
FMSKIPshft = 12
FMSKIPbit = 1 shl FMSKIPshft

;Event Flags
SKIPPABLEbit = 1

;Status Flags
SKIPbit = 1
EVENTbit = 2

;Generic Flags
BATTLEbit = 1
PERMABATTLEbit = 0x10
NOSOUNDbit = 0x400
NORENDERITEMbit = 0x40

macro proc name
  name:
  namespace name
  macro end.proc
    purge end.proc
    end namespace 
  end macro 
end macro

if KHVER eq V_FM
asm SysTable+0x2F9*4
  dd OnOpenSkipMenu
end asm

asm 0x104380
  j OnEnterSkippable
end asm

asm 0x1dca7c
  j AfterSkipSelection
end asm

;asm 0x22e354
  ;j OnCloseSkipMenu
;end asm

;asm 0x22dc2c
;  j MyGetSkipCursor
;end asm

; Enable Skip Event
asm 0x1dc9ec
  ori v1, zero, 1
end asm
end if

asm L_EndSwapBuffers
  j AfterSwapVideoBuffers
end asm

asm L_ExitInput
  j AfterInput
end asm

if defined REDUCE_LATENCY
asm L_RenderSequence
  lua v0, wRenderVar
  jal SwapBuffers
  lw a0, wRenderVar(v0)
  jal WaitForVBlanks
  nop
end asm
end if

;asm L_EndScene
;  j OnEndScene
;end asm

;asm L_CallWaitVBlanks
;  j BeforeWaitVBlanks
;end asm

asm SysFadeIn
  j OnFadeIn
  nop
end asm

asm Sys55+0x30
  j LeaveSkip
end asm 

asm Sys8C+0x30
  j LeaveSkip
end asm

asm Sys270+0x54
  j LeaveSkip
end asm

asm Sys36+0x58
  j AfterSys36
end asm

if 0 eq 1
asm Sys270+0x24
  jal LeaveSkip
end asm
asm Sys270+0x30
  nop 
end asm
asm Sys270+0x40
  nop
end asm
end if

if 0 eq 1
asm ExitScene
  j OnExitScene
end asm
end if

asm ClearSkipVars+0x2c
  li t0, not (NOSOUNDbit or NORENDERITEMbit)
end asm
asm ClearSkipVars+0x54
  dd (0xe5200000 or (flAnimSpeed and 0xffff))
end asm

asm JalLoadAnims
  jal OnLoadAnimations
end asm 

;asm 0x1c4590
  ;j SetLoadOff
;end asm 

asm SetupRoom
  j OnSetupRoom
end asm 

asm Sys121+0x4c
  j L_OnSys121
end asm 

asm JalSomeRender
  jal DecideRender
end asm

if defined NO_SLEEP
asm SysSleep+0x30
  j OnSleep
  nop
end asm
end if

asm AdvText1+0xa8
  j L_OnText1
end asm

asm AdvText2+0xb0
  j L_OnText2
end asm

asm AdvText3+0xb0
  j L_OnText3
  nop
end asm

if defined FIX_SORA_LIPS
asm ControlLips
  j OnControlLips
  nop
end asm
end if

;assemble into region below executable
;very sketch
asm SectionBaseText
dd 0xdeadbeef
wCutId dd 0
wPatchFlags dd 0
bEnableButtons db DefaultButtonCommands
bInsideCode db 0
bSkippingFmv db 0
bAutoSkip db DefaultAutoSkip
paBlocks dd aItems
aBlockPatches dd \
  -200.0, 0.0,\
  -200.0, 0.0,\
  -200.0, 0.0,\
  2000.0, 2500.0,\ 
  500.0, 1000.0,\
  -2500.0, -1900.0
; dd 0xdeadbeef

if KHVER eq V_FM
wAllowSkip dd 0xcafebabe
end if

if KHVER eq V_NA
acSkip db 0x3d,0x4f,0x4d,0x54,0,0,0,0
else
acSkip db 0xec,0xe6,0x19,0x30,0x19,0x25,0,0
end if 
wSkipTimer dd 0

if KHVER eq V_FM
proc OnOpenSkipMenu
  addiu sp, sp, -0x10
  sd ra, 0(sp)
  sd s0, 8(sp)

  move t0, zero

  lua at, wRoom
  lw t1, wRoom(at)
  lw t2, wWorld(at) 
  li t3, 17
  bne t3, t1, ok
  li t3, 8
  bne t3, t2, ok
  nop
  li t0, CUT_JENIE

ok:
  lua at, wEventFlags
  lw s0, wEventFlags(at)
  lua at, wAllowSkip
  sw t0, wCutId(at)
  jal LeaveSkip
  sw zero, wAllowSkip(at)
  lua at, wEventFlags
  sw s0, wEventFlags(at)

  ld s0, 8(sp)
  ld ra, 0(sp)
  j OpenSkipMenu
  addiu sp, sp, 0x10
end proc

proc OnEnterSkippable
  ;lua at, wIsSkipMenuOpen
  ;lw t0, wIsSkipMenuOpen(at)
  ;lua at, wAllowSkip
  ;slti t0, t0, 1
  ;jr ra
  ;sw t0, wAllowSkip(at)

  lua at, wAllowSkip
  jr ra
  sw ra, wAllowSkip(at)
end proc

proc AfterSkipSelection
;v1 has SkipCursor, 0 for skip event, 1 for not skip
  lua at, wAllowSkip
  jr ra
  sw v1,  wAllowSkip(at)
end proc

if 0 eq 1 
proc OnCloseSkipMenu
  lua at, wSkipCursor
  lw t0, wSkipCursor(at)
  lua at, wAllowSkip
  li v0, 4
  j 0x22e35c
  sw t0, wAllowSkip(at)
end proc

proc MyGetSkipCursor
  jal 0x1fd518
  nop
  lua at, wEventFlags
  lw at, wEventFlags(at)
  andi at, at, SKIPPABLEbit
  bz at, normal
  lua at, wFMSkip
  sw v0, wFMSkip(at)
normal:
  j 0x22dc34
  nop
end proc
end if

end if 

if 0 eq 1
aSkipPatches:
dd 0x1c8fd0, 0xa0d60000, 0x10000012
dd 0x1c9ab0, 0xa0d20000, 0x1000000a
dd 0x1c9d80, 0xa1330000, 0x1000000a
dd 0x1cdbcc, 0x14600004, 0
dd 0x1cb200, 0x46000000, 0x46000001

proc ApplySkipPatches
  sll a0, a0, 2
  la t1, aSkipPatches
  li t2, 5

again:
  lw t0, 0(t1)
  addu at,t1,a0
  lw at, 4(at)
  sw at, 0(t0)
  addiu t2,t2,-1
  bnz t2, again
  addiu t1, t1, 12

  jr ra
  nop
end proc 
end if

macro _IsLoading d
  lua d, wLoadScreen
  lw d, wLoadScreen(d)
end macro



if 1 eq 1
proc L_OnText1
  _IsLoading at
  bz at, normal
  nop
  j AdvText1+0xf0
  nop
normal:
  j AdvText1+0xb0
  sb s6, 0(a2)
end proc

proc L_OnText2
  _IsLoading at
  bz at, normal
  nop
  j AdvText2+0xdc
  nop
normal:
  j AdvText2+0xb8
  sb s3, 0(t1)
end proc

proc L_OnText3
  _IsLoading at
  bz at, normal
  nop
  j AdvText3+0xdc
  nop
  ;addiu a2,s5,-0x70d8 ;not needed

normal:
  sb s2,0(a2)
  j AdvText3+0xb8
  AdvText3.DelayCode
  ;addiu a2,s5,-0x70d8
end proc

if 0 eq 1
proc OnExitScene
  addiu sp, sp, -0x10
  sd ra, 0(sp)
  jal LeaveSkip
  sd a0, 8(sp)
  ld a0, 8(sp)
  j ExitScene+4
  ld ra, 0(sp)
end proc
end if

proc AfterSys36
  lua at, wPatchFlags
  lw at, wPatchFlags(at)
  andi at, at, CLEARSKIPON36bit
  bz at, normal
  nop

  j LeaveSkip
  nop

normal:
  jr ra
  li v0, 2
end proc

if defined NO_SLEEP
proc OnSleep
  dd 0x46000000 ;add.s f0,f0
  _IsLoading at
  bz at, normal
  ;lua at, wPatchFlags
  ;lw at, wPatchFlags(at)
  ;andi at, at, SLEEPYbit
  ;bnz at, normal
  lua at, wCutId
  lw at, wCutId(at)
  addiu at, at, -0xee
  bz at, normal
  nop
  dd 0x46000001 ;sub.s f0,f0

normal:
  jr ra
  dd 0xe48002f4 ;swc1 f0, 0x2f4(a0)
end proc
end if

if 0 eq 1
proc OnSys13D
  addiu sp, sp, -0x10

  lua at, wCutId
  lw at, wCutId(at)
  addiu at, at, -0xae
  bnz at, normal

  lua at, wEventFlags
  lw t0, wEventFlags(at)
  ori t0, t0, SKIPPABLEbit
  sw t0, wEventFlags(at)

normal:
  j OnSys13D+8
  sd s0, 0(sp)
end proc
end if

proc OnFadeIn
  addiu sp, sp, -0x10
  lua at, wPatchFlags
  lw t0, wPatchFlags(at)
  andi t1, t0, (SETSKIPONFADEbit or SETSKIPONFADEHBbit or SETPERMABATTLEbit)
  bz t1, done
if KHVER eq V_JP
  andi t1, t0, SETPERMABATTLEbit
  bnz t1, SetPermaBattle
end if
  andi t1, t0, SETSKIPONFADEHBbit
  bz t1, SetSkip

TestHB:
  lw t1, 0x17c(a0)
  addiu t1, t1, -0x2af
  bnz t1, done

SetSkip:
  lua t1, wEventFlags
  lw t2, wEventFlags(t1)
  ori t2, t2, SKIPPABLEbit
  sw t2, wEventFlags(t1)

done:
  j SysFadeIn+8
  sd s0, 0(sp)

if KHVER eq V_JP
SetPermaBattle:
  lua t1, wFlags
  lw t2, wFlags(t1)
  ori t2, t2, (PERMABATTLEbit or BATTLEbit)
  j done
  sw t2, wFlags(t1)
end if
end proc

proc L_OnSys121
  _IsLoading t0
  bz t0, done
  lua t0, wPatchFlags
  lw t0, wPatchFlags(t0)
  andi t0, t0, GRANDHALLbit
  bz t0, done
  nop
  ;lwc f0, 0x28c(v1)
  dd 0xc460028c

done:
  j Sys121+0x50
  lui at, 0x3f00
end proc

if defined FIX_SORA_LIPS
; This only fixes Sora's lips after the NV cutscene
proc OnControlLips
  _IsLoading at
  bz at, normal
  lua at, wCutId
  lw at, wCutId(at)
  addiu at, at, -CUT_NVHOLD
  bnz at, normal
  lw t0, 0x180(a0)
  srl t1, t0, 4
  addu t1, t1, a0
  lw t1, 0x180(t1)
  addiu t1, t1, -0x21
  bnz t1, normal
  addiu t0, t0, -3
  sw t0, 0x180(a0)
  jr ra
  li v0, 2

  normal:
  addiu sp, sp, -0x40
  j ControlLips+8
  sd s0, 0x20(sp)
end proc
end if

end if

proc LeaveSkip
  addiu sp, sp, -0x10
  sd ra, 0(sp)

  lua t0, wStatus
  lw t0, wStatus(t0)
  andi at, t0, SKIPbit
  bz at, wasnotskipping
  li v0, 2
  la t0, aTextFlags
  addiu t1, t0, 4096+32-8

more:
  sd zero, 0(t0)
  sltu at, t0, t1
  bnz at, more
  addiu t0, t0, 8

  lua t0, wCutId
  lw t0, wCutId(t0)
  li at, CUT_JENIE
  beq at, t0, SetupJenie
  li at, CUT_MONSTRO
  bne at, t0, done
  lua t0, pSora
  lw t0, pSora(t0)
  lui at, 0x4468
  sw at, 0x10(t0)
  lui at, 0xc35a
  sw at, 0x14(t0)
  lui at, 0x447d
  ori at, at, 0x8000
  b done
  sw at, 0x18(t0)

SetupJenie:
  lua at, wPatchFlags
  lw t0, wPatchFlags(at)
  la t1, aItems
  sw t1, paBlocks(at)
  ori t0, t0, JENIEbit
  sw t0, wPatchFlags(at)

done:
  jal ClearSkipVars
  nop
  li v0, 6

wasnotskipping:
  ld ra, 0(sp)
  jr ra
  addiu sp, sp, 0x10
end proc

proc DecideRender
  bnz v0, NoRender
  nop
  j HeadRender
  nop
NoRender:
  j L_EndRender
  nop
end proc 

proc AfterSwapVideoBuffers
  addiu sp, sp, -0x10
  sd ra, 0(sp)

  jal DrawSkipOnOff
  sd a0, 8(sp)

if defined ENABLE_IGT
  jal DrawIGT
  nop
end if

  ld ra, 0(sp)
  ld a0, 8(sp)
  j SendGsPacket
  addiu sp, sp, 0x10
end proc

if defined ENABLE_IGT
proc DrawIGT
  addiu sp, sp, -0x20
  sd ra, 0(sp)

  ;Set Depth?
  ;lui a0, 0x2a
  ;jal 0x106b18
  ;addiu a0, a0, 0x6540

  addiu a0, sp, 0x1f
  sb zero, 0(a0)

  lua at, wRealTime
  lw t0, wRealTime(at)

  jal PushNumber
  li t1, 60
  jal PushNumber
  li t1, 60
  jal PushNumber
  li t1, 60
  jal PushNumber
  li t1, 100

  li t0, 0xf
  addiu a3, a0, 1
  li a2, 0x10
  li a1, 0x10
  lui a0, 0x70ff
  jal DrawText
  ori a0, a0, 0x9900 

  ld ra, 0(sp)
  jr ra
  addiu sp, sp, 0x20

PushNumber:
  divu t0, t1
  li t3, 10
  mfhi t2
  mflo t0
  divu t2, t3
  addiu a0, a0, -3
  mfhi t2
  addiu t2, t2, 0x21
  sb t2, 2(a0)
  mflo t2
  addiu t2, t2, 0x21
  sb t2, 1(a0)
  li t2, 1
  jr ra
  sb t2, 0(a0)

end proc
end if

proc DrawSkipOnOff 
  addiu sp, sp, -0x10
  sd ra, 0(sp)

  lua at, wSkipTimer
  lw t0, wSkipTimer(at)
  bz t0, done
  addiu t0, t0, -1
  sw t0, wSkipTimer(at)
 
if KHVER eq V_NA
  TxSize = 0x11
else 
  TxSize = 0xa
end if

  li t0, TxSize
  la a3, acSkip
  li a2, 0x10
  li a1, 0x10
  lui a0, 0x80ff
  jal DrawText
  ori a0, a0, 0x9900 

if KHVER eq V_NA 
  li a0, 0x12d
else if KHVER eq V_FM
  li a0, 0x131
else if KHVER eq V_JP
  li a0, 0x136
else
  err 'unknown version'
end if
  lua at, bAutoSkip
  lbu at, bAutoSkip(at)
  jal GetTextFromId
  subu a0, a0, at

  li t0, TxSize
  move a3, v0
  li a2, 0x10
  li a1, 0x3c
  lui a0, 0x80ff
  jal DrawText
  ori a0, a0, 0x9900 

done:
  ld ra, 0(sp)
  jr ra
  addiu sp, sp, 0x10
end proc 

proc PatchBlocks
  lua at, wPatchFlags
  lw at, wPatchFlags(at)
  andi at, at, JENIEbit
  bz at, done_fast
  move t7, ra
  lua t3, paBlocks
  lw t0, paBlocks(t3)
  lw v0, 4(t0)
  lui t1, 5
  beq v0, t1, BeginPatch
  li t2, 0x60
  la t0, aItems

ScanForBlocks:
  lw v0, 4(t0)
  beq v0, t1, Found
  addiu t2, t2, -1
  bnz t2, ScanForBlocks
  addiu t0, t0, SIZEOF_ITEM

  b done
  nop

Found:
  sw t0, paBlocks(t3)

BeginPatch:
  li t2, 2
  addiu a0, t0, 0x14
  la a1, aBlockPatches
LoopY:
  jal LimitValue
  nop
  bnz t2, LoopY
  addiu t2, t2, -1

  li t2, 2
  addiu a0, a0, -4
LoopX:
  jal LimitValue
  nop
  bnz t2, LoopX
  addiu t2, t2, -1

done:
  move ra, t7
done_fast:
  jr ra
  nop

;a0 - which, a1 min/max ptr 
LimitValue:
  addiu a1, a1, 8
  ;lwc1 f0, 0(a0)
  ;lwc1 f1, -8(a1)
  dd 0xc4800000
  dd 0xc4a1fff8
  addiu a0, a0, SIZEOF_ITEM
  ;c.lt.s f0, f1
  dd 0x46010034
  ;bc1t Floored
  dd 0x45010006
  ;lwc1 f1, -4(a1)
  dd 0xc4a1fffc
  ;c.le.s f0, f1
  dd 0x46010036
  ;bc1f Floored
  dd 0x45000003
  nop
  jr ra
  nop

Floored:
  jr ra
  ;swc1 f1, -SIZEOF_ITEM(a0)
  dd 0xe481fb50

end proc 

if 0 eq 1
proc BeforeWaitVBlanks
  jal DrawSkipOnOff
  nop
  lua ra, L_CallWaitVBlanks+8
  j WaitForVBlanks
  addiu ra, ra, L_CallWaitVBlanks+8
end proc
end if

proc AfterInput
  addiu sp, sp, -0x10
  sd ra, 0(sp)

  ;Prevent re-enter
  lua at, bInsideCode
  lbu t0, bInsideCode(at)
  bnz t0, NoExecute
  li t0, 1
  sb t0, bInsideCode(at)

  lua at, bSkippingFmv
  lbu at, bSkippingFmv(at)
  bnz at, SkipFMVLoop
  nop

  jal GetFmvStatus
  nop
  li at, 3 ;PLAYING FMV
  bne at, v0, Regular
  lua at, wInput

FMV:
  lw t0, wInput(at)
  andi t0, t0, 0x1000
  bz t0, done
  li t0, 1
  lua at, bSkippingFmv
  sb t0, bSkippingFmv(at)

SkipFMVLoop:
  jal StopFMV
  nop
  li at, 1
  bne at, v0, done
  lua at, bSkippingFmv
  sb zero, bSkippingFmv(at)

Regular:
  lua at, wGameInput
  lw t0, wGamePressed(at)
  andi t0, t0, 0xffff
  bz t0, CSkip
  nop
  jal DoButtonCommands
  lw a0, wGameInput(at)
  
CSkip:
  jal ControlSkip
  nop 

  jal PatchBlocks
  nop

done:
  lua at, bInsideCode
  sb zero, bInsideCode(at)

NoExecute:
  ld ra, 0(sp)
  jr ra
  addiu sp, sp, 0x10
end proc 

proc ControlSplashCommands
  lua t2, wPlayedSplashes
  lw t0, wPlayedSplashes(t2)
  bnz t0, done
  andi t0, a0, 8
  bz t0, done
  li t0, 1
  sw t0, wPlayedSplashes(t2)
  lua at, wPlaying
  sw zero, wPlaying(at)

done:
  jr ra
  nop
end proc 

proc DoButtonCommands
  addiu sp, sp, -0x10
  sd ra, 0(sp)
  sd s0, 8(sp)
  move s0, a0

  lua at, bEnableButtons 
  lbu t0, bEnableButtons(at)
  bz t0, done

  lua t1, wWorld
  lw t1, wWorld(t1)
  bgez t1, SaveAnywhere
  andi t0, s0, 1
  bz t0, CheckSplash
  lbu t0, bAutoSkip(at)
  xori t0, t0, 1
  sb t0, bAutoSkip(at)
  li t0, 60
  sw t0, wSkipTimer(at)
  jal PlayGSound
  li a0, 1

CheckSplash:
  jal ControlSplashCommands
  move a0, s0

SaveAnywhere:
  li t0, 0x580
  beq t0, s0, OpenSave
  li t0, 0xa80
  bne t0, s0, done
  li a0, 2
  li a1, 0x2d
  jal StopSound
  move a2, zero
  lua at, (flAnimSpeed+4)
  lui t0, 0x3f80
  sw t0, flAnimSpeed+4(at)
  lua at, wContinueCommand
  jal SetContinue
  sw zero, wContinueCommand(at)
  b done

OpenSave:
  lua at, wMenuType
  lw at, wMenuType(at)
  li t0, 4
  beq t0, at, done 
  li t0, 3
  lua at, wOpenSave
  sw t0, wOpenSave(at)

done:
  ld s0, 8(sp)
  ld ra, 0(sp)
  jr ra
  addiu sp, sp, 0x10 
end proc 

proc OnLoadAnimations
  subu v0, a0, at
  srl v0, v0, 8

  ;Setup patch flags 
  lua t5, wPatchFlags
  lw t4, wPatchFlags(t5)
  sw v0, wCutId(t5) ;WARN: address
  li at, 0xae
  beq at, v0, SetSkippable
  li at, 0xaf
  beq at, v0, SetSkippable
  li at, 0xb3
  beq at, v0, SetSkippable
  li at, 0xb6
  beq at, v0, SetMeme
  li at, 0xb7
  beq at, v0, SetSkippable
  li at, 0xfd
  beq at, v0, SetWaitFade
  li at, 0xa8
  beq at, v0, FixGrandHall
  li at, 0xe0
  beq at, v0, SetBossSkip
  li at, 0xc
  beq at, v0, SetBossSkip
  li at, 0x2d
  beq at, v0, SetBossSkip
;  li at, 0x81
;  beq at, v0, SetClearLoad
if KHVER eq V_JP
  li at, 0xd6 
  beq at, v0, SetWaitFade
  li at, CUT_URSULA2
  beq at, v0, SetPermaBattle
end if
if KHVER eq V_NA
  ;li at, 0x4d
  ;beq at, v0, SetMonstro
end if
;  li at, 0xee
;  beq at, v0, SetSleepy
  li at, 0x13c
if KHVER eq V_FM
  beq at, v0, ClearManual
  nop
end if 
done:
  j LoadAnimations
  sw t4, wPatchFlags(t5)

SetWaitFade:
  j done
  ori t4, t4, WAITFADEbit

;Fix pre-emptive GuardArmor/Darkkside
SetBossSkip:
  j done
  ori t4, t4, CLEARSKIPON36bit

SetSkippableOnFade:
  j done
  ori t4, t4, SETSKIPONFADEbit

;SetSleepy:
;  j done
;  ori t4, t4, SLEEPYbit

SetMeme:
  j done
  ori t4, t4, SETSKIPONFADEHBbit

SetPermaBattle:
  j done
  ori t4, t4, SETPERMABATTLEbit

SetSkippable:
  lua t5, wEventFlags
  lw t4, wEventFlags(t5)
  ori t4, t4, SKIPPABLEbit
  j LoadAnimations
  sw t4, wEventFlags(t5)

if KHVER eq V_FM
ClearManual:
  ; Technically should li at, not MANUALbit
  j done
  andi t4, t4, not MANUALbit 
end if

FixGrandHall:
  j done
  ori t4, t4, GRANDHALLbit
  ;li t0, 0x28c
  ;lua at, hGrandHallPatch
  ;j done 
  ;sh t0, hGrandHallPatch(at)
end proc 

;proc LeaveCut
;  lua at, wCutId
;  jr ra
;  sw zero, wCutId(at)
;end proc

proc OnSetupRoom
  lua at, wLoadScreen
  sw zero, wLoadScreen(at)

  ;Jenie unskip
  or t0, zero, zero

  lua at, wRoom
  lw t1, wRoom(at)
  lw t3, wWorld(at)
  lw t4, wScene(at) 

if 0 eq 1
  li t2, 17
  bne t2, t1, CheckFinalEvents
  li t2, 8
  beq t2, t3, SetNoSkip
end if

  li t2, 16
  bne t2, t1, CheckFinalEvents
  li t2, 8
  bne t2, t3, CheckFinalEvents
  li t2, 3
  beq t2, t4, SetWaitFade

CheckFinalEvents:
  li t2, 32
  bne t2, t1, StorePatch
  li t2, 16
  bne t2, t3, StorePatch
  nop
  b StorePatch
  ori t0, t0, MANUALbit

if 0 eq 1
SetNoSkip:
  ori t0, t0, JENIEbit
end if

SetWaitFade:
  ori t0, t0, WAITFADEbit

StorePatch:
  lua at, wPatchFlags
  sw t0, wPatchFlags(at)

  ;lua at, hGrandHallPatch
  ;li t0, 0x16c
  ;sh t0, hGrandHallPatch(at)

  j SetupRoom+4
  addiu sp, sp, -0x60
end proc 

proc ControlSkip
  ; First, Check if this skip has special requirements
  addiu sp, sp, -0x20
  sd ra, 0(sp)
  sd s0, 8(sp)
  sd s1, 16(sp)

  lua t0, wEventFlags
  lua s1, wStatus

  lw t0, wEventFlags(t0)
  lw s0, wStatus(s1)

  lua at, wPatchFlags
  lw t4, wPatchFlags(at)
  ;lw t5, wCutId(at)
  andi at, t4, WAITFADEbit
  bz at, CheckSkip

WaitFade:
  lua at, wBrightRed
  lw at, wBrightRed(at)
  addiu at, at, -0x80
  bnz at, NoSkip

CheckSkip:
  andi at,t0,SKIPPABLEbit
  bz at, NoSkip

IgnoreSkippable: ;because of a special skip
  andi at, t4, MANUALbit
  bnz at, ManualSkip
  lua at, bAutoSkip
  lbu at, bAutoSkip(at)
  bnz at, AutoSkip
  
ManualSkip:
  lua at, wGameInput
  lh at, wGameInput(at)
  andi at,at,0x1000
  bz at, NoSkip

AutoSkip:
  lua at, wDisableGameInput
  lw at, wDisableGameInput(at)
  bnz at, NoSkip
if KHVER eq V_FM
  lua at, wAllowSkip
  lw at, wAllowSkip(at)
  bz at, NoSkip
end if
  andi at,s0,SKIPbit
  bnz at, NoSkip
  andi at,s0,EVENTbit
  bz at, NoSkip
  ori s0, s0, SKIPbit
  lua at, wFlags
  lw t0, wFlags(at)
  ori t0, t0, NOSOUNDbit or NORENDERITEMbit
  sw t0, wFlags(at)
  lua at, aWaitFlags
  sd zero, aWaitFlags(at)
  sd zero, aWaitFlags+8(at)
  sw zero, aTextFlags(at)
  sd zero, aTextFlags2(at)
  sd zero, aTextFlags2+8(at)
  ; lui at, 0x1f
  ; sw zero, 0xa28c(at)
  ; sw zero, 0xa2a8(at)

if defined SKIP_SOUND
  jal PlayGSound
  li a0, 2
end if

  jal StopVoice
  li a0, -1

  li a0, -8
  li a1, -1
  jal StopSound
  li a2, -1

NoSkip:
  sw s0, wStatus(s1)
  ld s1, 16(sp)
  ld s0, 8(sp)
  ld ra, 0(sp)
  jr ra
  addiu sp, sp, 0x20 
end proc

end asm 

