macro format_gs
  local FinalCount
  GS_COUNT = 0
  dd FinalCount

  postpone
    FinalCount := GS_COUNT
  end postpone 
end macro

macro asm addr
  local CountWords 
  local FirstWord
  macro end.asm
    CountWords := ($-FirstWord) / 4
  end macro 

  dd addr, CountWords
  org addr
  FirstWord = $

  GS_COUNT = 1 + GS_COUNT
end macro 

macro gs 
  local BeginGS, CountGSI
  dd -1
  dd CountGSI 
  BeginGS: 

  local _cond 
  macro _cond type,test,goton,addr,value
    dd (0xd0000000) or (addr and 0xfffffff)
    dd (goton shl 24) or (test shl 20) or (type shl 16) or (value and 0xffff) 
  end macro 

  macro cond addr, value 
    local CountInstructions, begin, after 
    begin:
    _cond 1, 0, CountInstructions, addr, value 
    macro end.cond 
      after: 
      purge end.cond 
      CountInstructions := (after-begin)/8
    end macro 
  end macro 
 
  macro end.gs 
    CountGSI := ($ - BeginGS)/8
    purge end.gs
  end macro 
end macro 
