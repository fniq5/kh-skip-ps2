These only produce binary data files. You need a loader to use them.

### Features
- Skip scenes and FMV by holding Triangle
- Save Anywhere with L1 + L2 + DPadLeft
- Instant Continue with R1 + R2 + DpadLeft
- Toggle Auto Skip with SELECT on Title Screen
- Auto Skip except for final events

### Build Instructions
Tools:
- fasmg https://flatassembler.net/

Steps:
1. Edit config.inc with desired settings
2. Invoke fasmg on kh.asm
3. You can also use -i option to set the version.

Example:
```
fasmg kh.asm -i "KHVER=V_FM"
```

