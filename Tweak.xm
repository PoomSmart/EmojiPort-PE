#define CHECK_TARGET
#define CHECK_EXCEPTIONS
#import <dlfcn.h>
#import "../PS.h"

%ctor {
    if (_isTarget(TargetTypeApps | TargetTypeGenericExtensions, @[@"com.apple.WebKit.WebContent", @"kbd"])) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortPEReal.dylib", RTLD_NOW);
    }
}
