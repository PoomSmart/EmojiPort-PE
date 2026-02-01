PACKAGE_VERSION = 1.6.2

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:12.0
	ARCHS = arm64 x86_64
else
	ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
		TARGET = iphone:clang:latest:15.0
	else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
		TARGET = iphone:clang:latest:15.0
	else
		TARGET = iphone:clang:14.5:12.0
		export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
	endif
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EmojiPortPE

LIBRARY_NAME = EmojiPortPEReal
$(LIBRARY_NAME)_FILES = TweakReal.x
ifeq ($(THEOS_PACKAGE_SCHEME),)
$(LIBRARY_NAME)_FILES += FamilyPicker.x MultiSkinEmojis.x
endif
ifeq ($(INCLUDE_EML),1)
$(LIBRARY_NAME)_FILES += $(wildcard ../EmojiLibrary/PSEmojiUtilities*.m)
endif
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc -DINCLUDE_EML=$(INCLUDE_EML)
$(LIBRARY_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
$(LIBRARY_NAME)_EXTRA_FRAMEWORKS = CydiaSubstrate
$(LIBRARY_NAME)_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk

ifneq ($(SIMULATOR),1)

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
endif

ifeq ($(SIMULATOR),1)
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif
