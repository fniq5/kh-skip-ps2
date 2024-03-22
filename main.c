#define NEWLIB_PORT_AWARE

#include <tamtypes.h>
#include <kernel.h>
#include <loadfile.h>
#include <fileio.h>
#include <sifrpc.h>
#include <stdio.h>
#include <ps2sdkapi.h>

#include "img.h"

DISABLE_PATCHED_FUNCTIONS();
DISABLE_EXTRA_TIMERS_FUNCTIONS();
PS2_DISABLE_AUTOSTART_PTHREAD();

#define RED 0x1010feu
#define GREEN 0x10fe10u
#define BLUE 0xfe1010u
#define YELLOW 0x10fefeu

#define ELF_MAGIC   0x464c457f
#define ELF_PT_LOAD 1
#define GS_BGCOLOR *((vu32*)0x120000e0)

typedef struct {
    u8  ident[16];
    u16 type;
    u16 machine;
    u32 version;
    u32 entry;
    u32 phoff;
    u32 shoff;
    u32 flags;
    u16 ehsize;
    u16 phentsize;
    u16 phnum;
    u16 shentsize;
    u16 shnum;
    u16 shstrndx;
} elf_header_t;

typedef struct {
    u32 type;
    u32 offset;
    void *vaddr;
    u32 paddr;
    u32 filesz;
    u32 memsz;
    u32 flags;
    u32 align;
} elf_pheader_t;

void LinkImage(u32 *p) {
  u32 Offset, CountWords;
  u32 CountEntries;

  if(!p) return;

  Offset = *p++;
  CountWords = *p++;
  if(*(u32*)(Offset) != CountWords) {
    GS_BGCOLOR = RED;
    SleepThread();
  }

  CountEntries = *p++;
  while(CountEntries--) {
    Offset = *p++;
    CountWords = *p++;
    for(;CountWords--;Offset+=4) {
      *(u32*)(Offset) = *p++;
    }
  }
}

static char secbuf[2048];
static char *curline = secbuf;

static __attribute__((noreturn))
void Fatal(void) {
  GS_BGCOLOR = RED;
  SleepThread();
  Exit(0);
}

static
int IsToken(int c) {
  switch(c) {
  case ' ':
  case '\t':
  case '\r':
  case '\n':
  case '=':
    return 1;
  default: return 0;
  }
}

static
char * strip_tokens(char *c) {
  while(IsToken(*c)) {
    *c++ = 0;
  }
  return c;
}


static
char *strip_until_tokens(char *c) {
  while((*c) && !IsToken(*c)) ++c;
  return c;
}

static
char *GetToken() {
  char *c = curline;
  char *ret;
  if(!c) return 0;
  c = strip_tokens(c);
  if(*c) {
    ret = c;
    c = strip_until_tokens(c);
    c = strip_tokens(c);
  } else {
    ret = 0;
    c = 0;
  }
  curline = c;
  return ret;
}

static
int streq(const char *a, const char *b) {
  char c1,c2;
  for(;;) {
    c1 = *a++;
    c2 = *b++;
    if(c1 != c2) return 0;
    if(!c1) return 1;
  }
}

static
unsigned FormId(const char *exename) {
  const char *p = exename;
  int c;
  int acc = 0;
  while((c = *p++)) {
    if(c == ';') break;
    if( (c < '0') || (c > '9') ) continue;
    acc = 0x10 * acc + (c-(int)'0');
  }
  return acc;
}

static
char *WaitForCd() {
  int fd = -1;
  int len;
  char *tok = 0;
  while((fd = fioOpen("cdrom0:\\SYSTEM.CNF;1", O_RDONLY)) < 0);
  len = fioRead(fd, secbuf, 2048);
  if((len<=0) || (len >= 2048)) {
    Fatal();
  }
  secbuf[len] = 0;
  fioClose(fd);

  while((tok = GetToken())) {
    if(streq(tok, "BOOT2")) {
      if((tok = GetToken())) {
        return tok;
      } else {
        Fatal();
      }
    }
  }

  Fatal();
  return 0;
}

typedef struct {
  unsigned Id;
  u32 *Image;
} IMAGE_ENTRY;

static 
const IMAGE_ENTRY Entries[] = {
  {0x20370, (u32*)IMG_NA},
  {0x25105, (u32*)IMG_JP},
  {0x25198, (u32*)IMG_FM}
};

#define countof(x) (sizeof(x)/sizeof(*x))

static 
u32 *FindImage(u32 Code) {
  for(int i = 0; i < countof(Entries); ++i) {
    const IMAGE_ENTRY *e = Entries + i;
    if(e->Id == Code) {
      return e->Image;
    }
  }
  return 0;
}

static 
int ps2LoadElf(const char *path, t_ExecData *out) {
  return (!SifLoadElf(path, out)) && out->epc;
}

static 
int manLoadElf(const char *path, t_ExecData *out) {
  elf_header_t hdr;
  elf_pheader_t phdr;
  int fd = -1;
  int of;
  int err = 0;

  fd = fioOpen(path, O_RDONLY);
  if(fd < 0) goto fail;

  if(fioRead(fd, &hdr, sizeof(hdr)) != sizeof(hdr)) goto fail;
  if(*(u32*)(hdr.ident) != ELF_MAGIC) goto fail;

  for(int i = 0; i < hdr.phnum; ++i) {
    fioLseek(fd, hdr.phoff+(i*sizeof(phdr)), SEEK_SET);
    fioRead(fd, &phdr, sizeof(phdr));
    if(phdr.type != ELF_PT_LOAD) continue;

    fioLseek(fd, phdr.offset, SEEK_SET);
    fioRead(fd, phdr.vaddr, phdr.filesz);

    of = phdr.memsz-phdr.filesz;
    if(of > 0) {
      u8 *p = ((u8*)phdr.vaddr) + phdr.filesz;
      do {
        *p++ = 0;
      } while (--of);
    }
  }

  out->epc = hdr.entry;
  out->gp = 0;
  goto done;

fail:
  err = -1;

done:
  if(fd >= 0) fioClose(fd);
  return err;
}

static
void WipeUserMemory() {
  unsigned i;
  for (i = 0x00100000; i < 0x02000000; i += 64) {
    __asm__ (
      "\tsq $0, 0(%0) \n"
      "\tsq $0, 16(%0) \n"
      "\tsq $0, 32(%0) \n"
      "\tsq $0, 48(%0) \n"
      :: "r" (i)
    );
  }
}

static
void WipeSpad() {
  u64 *p = (u64*)0x70000000;
  u64 *spad_end = (u64*)(p + (16*1024/8));
  for(; p<spad_end; ++p) {
    *p = 0;
  }
}

static
void MyLoadExecElf(const char *path) {
  t_ExecData ed;
  char *args[1] = {(char*)path};
  ResetEE(0x7f);
  WipeUserMemory();
  WipeSpad();

  if(ps2LoadElf(path, &ed)) {
    if(manLoadElf(path, &ed)) {
      Fatal();
    }
  }

  GS_BGCOLOR = GREEN;

  FlushCache(0);
  FlushCache(2);
  LinkImage(FindImage(FormId(path)));
  SifExitRpc();
  ExecPS2((void*)ed.epc, (void*)ed.gp, 1, args); 
}

int main(int argc, char *argv[])
{
    GS_BGCOLOR = YELLOW;
    MyLoadExecElf(WaitForCd());
    Fatal();
    return 0;
}

extern char _end[];
extern void _init() __attribute__((weak));
extern void _fini() __attribute__((weak));

static
void DoCons() {
  void (*i)() = _init;
  if(i) i();
}

void CStart(void) {
  SetupHeap(_end, ~0u);

  DoCons();

  asm("ei\n");
  Exit(main(0,0));
}
