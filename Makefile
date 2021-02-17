PACKAGE_VERSION = 1.1~b1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:12.0
	ARCHS = x86_64
else
	TARGET = iphone:clang:latest:12.0
	ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortPEReal
EmojiPortPEReal_FILES = TweakReal.xm FamilyPicker.xm
EmojiPortPEReal_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
EmojiPortPEReal_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiPortPEReal_LIBRARIES = EmojiLibrary
EmojiPortPEReal_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk

ifneq ($(SIMULATOR),1)

TWEAK_NAME = EmojiPortPE
EmojiPortPE_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
endif

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/EmojiPortPE.dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject/EmojiPortPE.dylib
	@cp -v $(PWD)/EmojiPortPE.plist /opt/simject
endif
