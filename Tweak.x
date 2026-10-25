#define CHECK_TARGET
#define CHECK_WHITELIST
#import <dlfcn.h>
#import <PSHeader/PS.h>
#import <HBLog.h>

%ctor {
    if (_isTarget(TargetTypeApps | TargetTypeGenericExtensions, @[@"com.apple.WebKit.WebContent", @"chronod", @"kbd"], nil)) {
        dlopen(PS_ROOT_PATH("/usr/lib/libEmojiLibrary.dylib"), RTLD_NOW);
        dlopen(PS_ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib"), RTLD_LAZY);
        HBLogDebug(@"EmojiAttributes.dylib loaded: %s", dlerror());
        dlopen(PS_ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiResources.dylib"), RTLD_LAZY);
        HBLogDebug(@"EmojiResources.dylib loaded: %s", dlerror());
        dlopen(PS_ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortPEReal.dylib"), RTLD_LAZY);
        HBLogDebug(@"EmojiPortPEReal.dylib loaded: %s", dlerror());
    }
}
