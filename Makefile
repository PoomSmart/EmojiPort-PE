export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
PACKAGE_VERSION = 1.1.1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:12.0
	ARCHS = x86_64
else
	TARGET = iphone:clang:latest:12.0
	ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortPEReal
EmojiPortPEReal_FILES = TweakReal.x FamilyPicker.x CoupleEmojis.x
EmojiPortPEReal_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
EmojiPortPEReal_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiPortPEReal_LIBRARIES = EmojiLibrary
EmojiPortPEReal_USE_SUBSTRATE = 1
EmojiPortPEReal_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk

ifneq ($(SIMULATOR),1)

TWEAK_NAME = EmojiPortPE
EmojiPortPE_FILES = Tweak.x
EmojiPortPE_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
endif

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/EmojiPortPE.dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject/EmojiPortPE.dylib
	@cp -v $(PWD)/EmojiPortPE.plist /opt/simject
endif
