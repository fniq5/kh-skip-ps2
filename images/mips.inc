macro checkreg r
  if ~defined regs_#r 
    err 'not register'
  end if
end macro 

macro checkregs r&
  iterate i, r
    checkreg i
  end iterate 
end macro 

macro mips_r rd,rt,rs,shamt,fn
  checkregs rd,rt,rs 
  dd (regs_#rs shl 21) or (regs_#rt shl 16) or (regs_#rd shl 11) or (shamt shl 6) or fn 
end macro 

macro mips_i rt,rs,immediate,cmd
  dd (cmd shl 26) or (regs_#rs shl 21) or (regs_#rt shl 16) or ((not not (immediate)) and 0xffff)
end macro 

macro mips_j target,cmd
  dd (cmd shl 26) or (( (target) /4) and 0x3ffffff)
end macro 

macro init_regs reglist&
  local Counter
  Counter = 0
  iterate r, reglist 
    regs_#r = Counter
    Counter = 1 + Counter
  end iterate
  purge init_regs 
end macro 

init_regs zero,at,v0,v1,a0,a1,a2,a3,\
  t0,t1,t2,t3,t4,t5,t6,t7,\
  s0,s1,s2,s3,s4,s5,s6,s7,\
  t8,t9,\
  k0,k1,\
  gp,sp,fp,ra

macro def.r name, cmd
  macro name rd,rs,rt
    mips_r rd,rt,rs,0,cmd
  end macro 
end macro 

macro def.i name, cmd 
  macro name rt,rs,immediate
    mips_i rt,rs,immediate,cmd
  end macro 
end macro 

macro def.b name, cmd
  macro name rt,rs,offset
    mips_i rt,rs, (offset-($+4))/4 ,cmd 
  end macro 
end macro 

macro def.bzl  name, tiny
  macro name rs, offset
    mips_i tiny,rs, (offset-($+4))/4, 1
  end macro 
end macro 

macro def.bz name, cmd 
  macro name rs, offset
    mips_i 0,rs, (offset-($+4))/4, 000111b
  end macro 
end macro 

macro def.rs name, cmd 
  macro name rd,rt,sa
    mips_r rd,rt,zero,sa,cmd
  end macro
end macro

; shift variable flips rt/rs
macro def.rsv name, cmd
  macro name rd,rt,rs 
    mips_r rd,rt,rs,0,cmd
  end macro 
end macro 

macro def.j name, cmd 
  macro name addr
    mips_j addr, cmd
  end macro 
end macro 

macro def.r2 name, cmd 
  macro name rs,rt
    mips_r zero,rt,rs,0,cmd
  end macro 
end macro 

def.r add, 32
def.i addi, 1000b
def.i addiu, 1001b
def.r addu, 100001b
def.r and, 100100b
def.i andi, 001100b
def.b beq, 000100b
def.b beql, 010100b
;def.bzl bgez, 00001b
def.bzl bgez, at
def.bzl bgezal, 10001b
def.bzl bgezall, 10011b
def.bzl bgezl, 00011b
def.bz bgtz, 000111b
def.bz bgtzl, 010111b
def.bz blez, 000110b
def.bz blezl, 010110b
def.bzl bltz, 0
def.bzl bltzal, 10000b
def.bzl bltzall, 10010b
def.bzl bltzl, 00010b
def.b bne, 000101b
def.b bnel, 010101b

macro break code 
  dd (code shl 6) or 001101b
end macro 

def.r dadd, 101100b
def.i daddi, 011000b
def.i daddiu, 011001b
def.r daddu, 101101b
def.r2 ddiv, 011110b
def.r2 ddivu, 011111b
def.r2 div, 011010b
def.r2 divu, 011011b
def.r2 dmult, 011100b
def.r2 dmultu, 011101b
def.rs dsll, 111000b
def.rs dsll32, 111100b
def.rsv dsllv, 010100b
def.rs dsra, 111011b
def.rs dsra32, 111111b
def.rsv dsrav, 010111b
def.rs dsrl, 111010b
def.rs dsrl32, 111110b
def.rsv dsrlv, 010110b
def.r dsub, 101110b
def.r dsubu, 101111b
def.j j, 2
def.j jal, 3

macro jalr rd, rs 
  mips_r rd,zero,rs,0,001001b
end macro 

macro jalr rs
  jalr ra,rs
end macro 

macro jr rs 
  mips_r zero,zero,rs,0,001000b
end macro 

macro def.ls name, cmd
  macro name rt, rest&
    match offset(base), rest
      mips_i rt,base,offset,cmd 
    end match 
  end macro 
end macro 

def.ls lb, 100000b
def.ls lbu, 100100b
def.ls ld, 110111b
def.ls ldl, 011010b
def.ls ldr, 011011b
def.ls lh, 100001b
def.ls lhu, 100101b
def.ls ll, 110000b
def.ls lld, 110100b

macro lui rt, immediate
  mips_i rt,zero,immediate,001111b
end macro 

def.ls lw, 100011b
def.ls lwl, 100010b
def.ls lwr, 100110b
def.ls lwu, 100111b

macro def.mhl name, cmd 
  macro name rd
    mips_r rd,zero,zero,0,cmd
    ;def.r rd,0,0,0,cmd 
  end macro 
end macro 

def.mhl mfhi, 010000b
def.mhl mflo, 010010b
def.r movn, 001011b
def.r movz, 001010b
def.mhl mthi, 010001b
def.mhl mtlo, 010011b
def.r2 mult, 011000b
def.r2 multu, 011001b
def.r nor, 100111b
def.r or, 100101b
def.i ori, 001101b
def.ls pref, 110011b
def.ls sb, 101000b
def.ls sc, 111000b
def.ls scd, 111100b
def.ls sd, 111111b
def.ls sdl, 101100b
def.ls sdr, 101101b
def.ls sh, 101001b
def.rs sll, 0
def.rsv sllv, 000100b
def.r slt, 101010b
def.i slti, 001010b
def.i sltiu, 001011b
def.r sltu, 101011b
def.rs sra, 000011b
def.rsv srav, 000111b
def.rs srl, 000010b
def.rsv srlv, 000110b
def.r sub, 100010b
def.r subu, 100011b
def.ls sw, 101011b
def.ls swl, 101010b
def.ls swr, 101110b
def.r xor, 100110b
def.i xori, 001110b

macro nop
  dd 0
end macro

macro li rd, num
  if num > 0x7fff
    ori rd, zero, num
  else 
    addiu rd, zero, num 
  end if
end macro 

macro b tgt
  beq zero,zero,tgt
end macro 

macro move d,s
  or d,s,zero
end macro 

macro lua d, a
  if ((a) and 0x8000)
    lui d, ((a) shr 16) + 1
  else 
    lui d, (a) shr 16
  end if 
end macro 

macro bz s, t
  beq s,zero,t
end macro 

macro bnz s,t
  bne s,zero,t
end macro

macro la d, addr
  lui d, (addr shr 16)
  ori d, d, (addr and 0xffff)
end macro 



