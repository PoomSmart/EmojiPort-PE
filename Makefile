PACKAGE_VERSION = 1.0.2-1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:12.0
	ARCHS = x86_64
else
	TARGET = iphone:clang:latest:12.0
	ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Emoji10PEReal
Emoji10PEReal_FILES = TweakReal.xm
Emoji10PEReal_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/Emoji10PE
Emoji10PEReal_EXTRA_FRAMEWORKS = CydiaSubstrate
Emoji10PEReal_LIBRARIES = EmojiLibrary
Emoji10PEReal_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk

ifneq ($(SIMULATOR),1)
TWEAK_NAME = Emoji10PE
Emoji10PE_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
endif

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/Emoji10PE.dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject/Emoji10PE.dylib
	@cp -v $(PWD)/Emoji10PE.plist /opt/simject
endif
