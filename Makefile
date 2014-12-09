#=-> macosxbootloader OS X Makefile <-=#

### Top level directory ###
TOPDIR=$(PWD)

### Debug ###
DEBUG =# 1
ifeq ("$(DEBUG)", "")
DEBUGFLAGS=-g0 -DNDEBUG
else
DEBUGFLAGS=-g3 -DDEBUG -D_DEBUG
endif

ifeq ("$(HACKINTOSH)", "1")
HACKFLAGS=-DHACKINTOSH=1
else
HACKFLAGS=
endif

INSTALL = install

### Change to "" for no code signing or to your Apple developer certificate ###
#SIGNCERT = ""
#PKGSIGNCERT = ""
SIGNCERT = "Developer ID Application: Andy Vandijck (GSF3NR4NQ5)"
PKGSIGNCERT = "Developer ID Installer: Andy Vandijck (GSF3NR4NQ5)"

### Tools ###
ifeq ("$(CLOVERTOOLS)", "1")
ifeq ("$(TOOLPATH)", "")
TOOLPATH=$(HOME)/Downloads/CloverGrowerPro/toolchain/cross/bin/
endif
CC=$(TOOLPATH)x86_64-clover-linux-gnu-gcc
CXX=$(TOOLPATH)x86_64-clover-linux-gnu-g++
LD=$(TOOLPATH)x86_64-clover-linux-gnu-g++
AR=$(TOOLPATH)x86_64-clover-linux-gnu-ar
RANLIB=$(TOOLPATH)x86_64-clover-linux-gnu-ranlib
STRIP=$(TOOLPATH)x86_64-clover-linux-gnu-strip

### Architecture - Intel 32 bit / Intel 64 bit ###
ifeq ("$(ARCH)", "i386")
ARCHDIR=x86
ARCHFLAGS=-m32 -malign-double -fno-stack-protector -freorder-blocks -freorder-blocks-and-partition -mno-stack-arg-probe
NASMFLAGS=-f elf32 -DAPPLE
MTOC=$(TOOLPATH)x86_64-clover-linux-gnu-objcopy -I elf32-i386 -O pei-i386
else
ARCHDIR=x64
ARCHFLAGS=-m64 -fno-stack-protector -DNO_BUILTIN_VA_FUNCS -mno-red-zone -mno-stack-arg-probe
NASMFLAGS=-f elf64 -DAPPLE -DARCH64
MTOC=$(TOOLPATH)x86_64-clover-linux-gnu-objcopy -I elf64-x86-64 -O pei-x86-64
endif

CFLAGS = "$(DEBUGFLAGS) $(ARCHFLAGS) $(HACKFLAGS) -fshort-wchar -fno-strict-aliasing -ffunction-sections -fdata-sections -fPIC -Os -DEFI_SPECIFICATION_VERSION=0x0001000a -DTIANO_RELEASE_VERSION=1 -I$(TOPDIR)/include -I/usr/include -DGNU -D__declspec\(x\)= -D__APPLE__"
CXXFLAGS = $(CFLAGS)

ifeq ("$(ARCH)", "i386")
ALDFLAGS = -melf_x86_64
else
ALDFLAGS = -melf_x86_64
endif

LDFLAGS = "$(DEBUGFLAGS) $(ARCHFLAGS) -nostdlib -n -Wl,--script,$(TOPDIR)/gcc4.9-ld-script -u _Z7EfiMainPvP17_EFI_SYSTEM_TABLE -e _Z7EfiMainPvP17_EFI_SYSTEM_TABLE --entry _Z7EfiMainPvP17_EFI_SYSTEM_TABLE --pie"

ifeq ("$(ARCH)", "i386")
#AESASMDEFS=-DASM_X86_V1C=1 -D_ASM_X86_V1C=1
AESASMDEFS=-DASM_X86_V2=1 -D_ASM_X86_V2=1
#AESASMDEFS=-DASM_X86_V2C=1 -D_ASM_X86_V2C=1 -DNO_ENCRYPTION_TABLE=1 -DNO_DECRYPTION_TABLE=1
AESASMDEFS=

### define ASM_X86_V1C for this object ###
#EXTRAAESOBJS=aes_x86_v1.o

### define ASM_X86_V2 or ASM_X86_V2C for this object ###
EXTRAAESOBJS=aes_x86_v2.o

### define no ASM_X86_XXX at all for this ###
#EXTRAAESOBJS=

#ASMCOMPFLAGS="$(AESASMDEFS)"
ASMCOMPFLAGS=
NASMCOMPFLAGS=
else
### define ASM_AMD64_C for this object ###
EXTRAAESOBJS=aes_amd64.o

### define no ASM_AMD64_C at all for this ###
#EXTRAAESOBJS=

ASMCOMPFLAGS="-DASM_AMD64_C=1 -D_DASM_AMD64_C=1"
NASMCOMPFLAGS=
#ASMCOMPFLAGS=
endif
else
ifeq ("$(DEBUG)", "")
DEBUGFLAGS=-g0 -DNDEBUG -fno-standalone-debug
else
DEBUGFLAGS=-g3 -DDEBUG -D_DEBUG -fstandalone-debug
endif

CC=gcc
CXX=g++
LD=ld
AR=ar
STRIP = strip
RANLIB=ranlib
MTOC=mtoc -subsystem UEFI_APPLICATION -align 0x20

### Architecture - Intel 32 bit / Intel 64 bit ###
ifeq ("$(ARCH)", "i386")
ARCHDIR = x86
ARCHFLAGS = -arch i386
ARCHLDFLAGS = -u __Z7EfiMainPvP17_EFI_SYSTEM_TABLE -e __Z7EfiMainPvP17_EFI_SYSTEM_TABLE -read_only_relocs suppress
NASMFLAGS = -f macho -DAPPLEUSE
ARCHCFLAGS = -funsigned-char -fno-ms-extensions -fno-stack-protector -fno-builtin -fshort-wchar -mno-implicit-float -mms-bitfields -ftrap-function=undefined_behavior_has_been_optimized_away_by_clang -DAPPLEEXTRA -Duint_8t=unsigned\ char -Duint_16t=unsigned\ short -Duint_32t=unsigned\ int -Duint_64t=unsigned\ long\ long -DBRG_UI8=1 -DBRG_UI16=1 -DBRG_UI32=1 -DBRG_UI64=1 -D__i386__=1
EXTRAOBJS="StartKernel.o"
else
ARCHDIR = x64
ARCHFLAGS = -arch x86_64
ARCHLDFLAGS =  -u ?EfiMain@@YA_KPEAXPEAU_EFI_SYSTEM_TABLE@@@Z -e ?EfiMain@@YA_KPEAXPEAU_EFI_SYSTEM_TABLE@@@Z
NASMFLAGS = -f macho64 -DARCH64 -DAPPLEUSE
STRIP = strip
ARCHCFLAGS = -target x86_64-pc-win32-macho -funsigned-char -fno-ms-extensions -fno-stack-protector -fno-builtin -fshort-wchar -mno-implicit-float -msoft-float -mms-bitfields -ftrap-function=undefined_behavior_has_been_optimized_away_by_clang -D__x86_64__=1
EXTRAOBJS=
endif

CFLAGS = "$(DEBUGFLAGS) $(ARCHFLAGS) $(HACKFLAGS) -fborland-extensions $(ARCHCFLAGS) -fpie -std=gnu11 -I/usr/include -Oz -DEFI_SPECIFICATION_VERSION=0x0001000a -DTIANO_RELEASE_VERSION=1 -I$(TOPDIR)/include -D_MSC_EXTENSIONS=1 -fno-exceptions" 
CXXFLAGS = "$(DEBUGFLAGS) $(ARCHFLAGS) $(HACKFLAGS) -fborland-extensions $(ARCHCFLAGS) -fpie -Oz -DEFI_SPECIFICATION_VERSION=0x0001000a -DTIANO_RELEASE_VERSION=1 -I$(TOPDIR)/include -D_MSC_EXTENSIONS=1 -fno-exceptions -std=gnu++11 -I/usr/include"
LDFLAGS = "$(ARCHFLAGS) -preload -segalign 0x20 $(ARCHLDFLAGS) -pie -all_load -dead_strip -image_base 0x240 -compatibility_version 1.0 -current_version 2.1 -flat_namespace -print_statistics -map boot.map -sectalign __TEXT __text 0x20  -sectalign __TEXT __eh_frame  0x20 -sectalign __TEXT __ustring 0x20  -sectalign __TEXT __const 0x20   -sectalign __TEXT __ustring 0x20 -sectalign __DATA __data 0x20  -sectalign __DATA __bss 0x20  -sectalign __DATA __common 0x20 -final_output boot.efi"

ifeq ("$(ARCH)", "i386")
#AESASMDEFS=-DASM_X86_V1C=1 -D_ASM_X86_V1C=1
AESASMDEFS=-DASM_X86_V2=1 -D_ASM_X86_V2=1
#AESASMDEFS=-DASM_X86_V2C=1 -D_ASM_X86_V2C=1 -DNO_ENCRYPTION_TABLE=1 -DNO_DECRYPTION_TABLE=1
AESASMDEFS=

### define ASM_X86_V1C for this object ###
#EXTRAAESOBJS=aes_x86_v1.o

### define ASM_X86_V2 or ASM_X86_V2C for this object ###
#EXTRAAESOBJS=aes_x86_v2.o

### define no ASM_X86_XXX at all for this ###
EXTRAAESOBJS=

#ASMCOMPFLAGS="$(AESASMDEFS)"
ASMCOMPFLAGS=
NASMCOMPFLAGS=
else
### define ASM_AMD64_C for this object ###
EXTRAAESOBJS=aes_amd64.o

### define no ASM_AMD64_C at all for this ###
#EXTRAAESOBJS=

ASMCOMPFLAGS="-DASM_AMD64_C=1 -D_DASM_AMD64_C=1"
NASMCOMPFLAGS=-Daes_encrypt=_aes_encrypt -Daes_decrypt=_aes_decrypt
#ASMCOMPFLAGS=
endif
endif

NASM=nasm

### Flags ###

all: rijndael $(ARCHDIR) boot efilipo

rijndael:
	cd src/rijndael && make -f Makefile ARCH="$(ARCH)" NASM="$(NASM)" NASMFLAGS="$(NASMFLAGS)" CC="$(CC)" CFLAGS=$(CFLAGS) AR="$(AR)" RANLIB="$(RANLIB)" ASMCOMPFLAGS=$(ASMCOMPFLAGS) NASMCOMPFLAGS="$(NASMCOMPFLAGS)" EXTRAOBJS="$(EXTRAAESOBJS)" && cd ../..

x64:
	cd src/boot/x64 && make CXX="$(CXX)" CXXFLAGS=$(CXXFLAGS) NASM="$(NASM)" NASMFLAGS="$(NASMFLAGS)" AR="$(AR)" RANLIB="$(RANLIB)" && cd ../../..

x86:
	cd src/boot/x86 && make EXTRAOBJS=$(EXTRAOBJS) CXX="$(CXX)" CXXFLAGS=$(CXXFLAGS) NASM="$(NASM)" NASMFLAGS="$(NASMFLAGS)" AR="$(AR)" RANLIB="$(RANLIB)" && cd ../../..

boot:
	cd src/boot && make CC="$(CC)" CFLAGS=$(CFLAGS) CXX="$(CXX)" ARCH=$(ARCH) CXXFLAGS=$(CXXFLAGS) LD="$(LD)" LDFLAGS=$(LDFLAGS) STRIP="$(STRIP)" MTOC="$(MTOC)" && cd ../..

efilipo:
	cd efilipo && make && cd ..

clean:
	cd src/rijndael && make clean && cd ../..
	cd src/boot && make clean && cd ../..
	cd src/boot/x64 && make clean && cd ../../..
	cd src/boot/x86 && make clean && cd ../../..

bin/boot.efi: build_universal.sh
	./$<

newinstaller: bin/boot.efi
	sudo mkdir -p macosxbootloaderinst/System/Library/CoreServices
	mkdir -p macosxbootloaderpkg
	mkdir -p macosxbootloadercombopkg
	sudo $(INSTALL) $< macosxbootloaderinst/System/Library/CoreServices/boot.efi
	sudo chown -R root:wheel macosxbootloaderinst
	cd macosxbootloaderinst && sudo rm -f .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store && sudo cpio -o < ../macosxbootloader_pkg.txt > ../macosxbootloaderpkg/Payload && sudo rm -f .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store && sudo mkbom . ../macosxbootloaderpkg/Bom && cd ..
	sudo cp -Rf Scripts macosxbootloaderpkg/Scripts
	sudo rm -Rf macosxbootloaderinst
	sudo cp -Rf Installer/PackageInfo macosxbootloaderpkg/PackageInfo
	cd macosxbootloaderpkg && sudo rm -Rf .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store && sudo xar -cjf ../macosxbootloadercombopkg/macosxbootloader-1.0.pkg . && cd ..
	sudo rm  -Rf macosxbootloaderpkg Payload Bom
	if [ $(PKGSIGNCERT) != "" ]; then sudo productsign --sign $(PKGSIGNCERT) macosxbootloadercombopkg/macosxbootloader-1.0.pkg macosxbootloadercombopkg/macosxbootloader-1.0-apple.pkg && sudo rm -Rf macosxbootloadercombopkg/macosxbootloader-1.0.pkg; else mv macosxbootloadercombopkg/macosxbootloader-1.0.pkg macosxbootloadercombopkg/macosxbootloader-1.0-apple.pkg; fi
	sudo cp -Rf Installer/Resources macosxbootloadercombopkg/Resources
	sudo cp -f Installer/Distribution macosxbootloadercombopkg/Distribution
	cd macosxbootloadercombopkg &&  sudo rm -Rf .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store && sudo productbuild --distribution Distribution --resources Resources --package-path $(PWD) ../macosxbootloader-apple.pkg && cd ..
	sudo rm -Rf macosxbootloadercombopkg
	if [ $(PKGSIGNCERT) != "" ]; then sudo productsign --sign $(PKGSIGNCERT) macosxbootloader-apple.pkg macosxbootloader.pkg && sudo rm -Rf macosxbootloader-apple.pkg; else mv macosxbootloader-apple.pkg macosxbootloader.pkg; fi

legacy-installer: bin/boot.efi
	sudo mkdir -p macosxbootloaderinst/System/Library/CoreServices
	mkdir -p macosxbootloaderpkg/Contents
	sudo $(INSTALL) $< macosxbootloaderinst/System/Library/CoreServices/boot.efi
	sudo chown -R root:wheel macosxbootloaderinst
	cd macosxbootloaderinst && sudo rm -f .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store && sudo cpio -o < ../macosxbootloader_pkg.txt > ../macosxbootloaderpkg/Contents/Archive.pax && gzip -v9 ../macosxbootloaderpkg/Contents/Archive.pax && sudo rm -f .DS_Store */.DS_Store */*/.DS_Store */*/*/.DS_Store && sudo mkbom . ../macosxbootloaderpkg/Contents/Archive.bom && cd ..
	sudo rm -Rf macosxbootloaderinst
	sudo cp -Rf LegacyInstaller/* macosxbootloaderpkg/Contents/
	sudo cp -Rf Scripts macosxbootloaderpkg/Contents/Scripts
	sudo rm -Rf macosxbootloaderpkg/.DS_Store macosxbootloaderpkg/*/.DS_Store macosxbootloaderpkg/*/*/.DS_Store
	sudo sudo rm -Rf macosxbootloader-1.0.pkg
	sudo mv -f macosxbootloaderpkg macosxbootloader-1.0.pkg
	sudo chown -R $(USER):staff macosxbootloader-1.0.pkg
	if [ $(SIGNCERT) != "" ]; then productsign --sign $(SIGNCERT) macosxbootloader-1.0.pkg macosxbootloader-legacy.pkg; else mv macosxbootloader-1.0.pkg macosxbootloader-legacy.pkg; fi
	rm -Rf macosxbootloader-1.0.pkg

