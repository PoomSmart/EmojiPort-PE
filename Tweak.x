#define CHECK_TARGET
#define CHECK_WHITELIST
#import <rootless.h>
#import <dlfcn.h>
#import <PSHeader/PS.h>
#import <HBLog.h>

%ctor {
    if (_isTarget(TargetTypeApps | TargetTypeGenericExtensions, @[@"com.apple.WebKit.WebContent", @"kbd"], nil)) {
        dlopen(ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib"), RTLD_LAZY);
        HBLogDebug(@"EmojiAttributes.dylib loaded: %s", dlerror());
        dlopen(ROOT_PATH("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortPEReal.dylib"), RTLD_LAZY);
        HBLogDebug(@"EmojiPortPEReal.dylib loaded: %s", dlerror());
    }
}
