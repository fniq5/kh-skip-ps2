EE_BIN = bootstrap.elf
PACKED_BIN = khskip.elf
EE_OBJS = main.o crt0.o
IMAGE_SRC = images
IMAGE_HEADERS = img_na.h img_jp.h img_fm.h

EE_CFLAGS = -D_EE -Os -G0 -Wall -I$(PS2SDK)/ee/include -I$(PS2SDK)/common/include  -I$(PS2SDK)/ports/include

EE_LDFLAGS = -nostartfiles -nostdlib -Tlinkfile -L$(PS2SDK)/ee/lib -s -Wl,-Map,lol.map -Wl,--gc-sections -Wl,-zmax-page-size=128

EE_LIBS += -lkernel

all: $(PACKED_BIN)

img_na.h: $(IMAGE_SRC)/na.img
	bin2c $< $@ IMG_NA

img_jp.h: $(IMAGE_SRC)/jp.img
	bin2c $< $@ IMG_JP

img_fm.h: $(IMAGE_SRC)/fm.img
	bin2c $< $@ IMG_FM

main.o: main.c $(IMAGE_HEADERS)
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c main.c -o $@

%.o: %.c
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

%.o: %.S
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

$(EE_BIN): $(EE_OBJS)
	$(EE_CC) $(EE_CFLAGS) $(EE_LDFLAGS) -o $(EE_BIN) $(EE_OBJS) $(EE_LIBS)

$(PACKED_BIN): $(EE_BIN)
	ps2-packer $(EE_BIN) $(PACKED_BIN)

clean:
	rm -fv $(EE_OBJS) $(EE_BIN) $(PACKED_BIN) $(IMAGE_HEADERS) 

include $(PS2SDK)/samples/Makefile.pref
