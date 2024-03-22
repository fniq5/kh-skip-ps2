IMAGES ?= na.img jp.img fm.img

all: $(IMAGES)

na.img: kh.asm
	fasmg kh.asm -i "KHVER=V_NA" na.img

jp.img: kh.asm
	fasmg kh.asm -i "KHVER=V_JP" jp.img

fm.img: kh.asm
	fasmg kh.asm -i "KHVER=V_FM" fm.img

clean:
	rm $(IMAGES) -v
