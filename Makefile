NASM = nasm -f bin
QEMU = qemu-system-i386
JSDOS = jsdos

ASM = bfos.asm
BIN = bfos.bin
ZIP = bfos.zip
IMG = $(JSDOS)/floppy.img

.PHONY: run

test: $(BIN)
	$(QEMU) -drive file=$(BIN),format=raw,if=floppy -monitor tcp:127.0.0.1:1234,server,nowait &
	sleep 0.5
	./sendkeys "$$(cat $(FILE))" | nc -v 127.0.0.1 1234

run: $(BIN)
	$(QEMU) -drive file=$(BIN),format=raw,if=floppy

jsdos: $(BIN)
	dd if=/dev/zero of=$(IMG) bs=512 count=2880
	dd if=$(BIN) of=$(IMG) conv=notrunc
	cd $(JSDOS) && zip -r ../$(ZIP) .

$(BIN): $(ASM)
	$(NASM) -o $(BIN) $(ASM)
