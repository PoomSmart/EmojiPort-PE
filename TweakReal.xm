#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import "../EmojiLibrary/Emojis.h"

%config(generator=MobileSubstrate)

@interface EMFEmojiToken (EmojiPort)
@property(assign) int ep_supportsSkinToneVariants;
@end

%group UIKit

%hook UIKeyboardEmojiCategory

+ (NSArray <NSString *> *)DingbatVariantsEmoji {
    return [PSEmojiUtilities DingbatVariantsEmoji];
}

+ (NSArray <NSString *> *)NoneVariantEmoji {
    return [PSEmojiUtilities NoneVariantEmoji];
}

+ (NSArray <NSString *> *)SkinToneEmoji {
    return [PSEmojiUtilities SkinToneEmoji];
}

+ (NSArray <NSString *> *)GenderEmoji {
    return [PSEmojiUtilities GenderEmoji];
}

+ (BOOL)emojiString:(NSString *)emojiString inGroup:(NSArray <NSString *> *)group {
    return [PSEmojiUtilities emojiString:emojiString inGroup:group];
}

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities hasVariantsForEmoji:emojiString];
}

+ (NSArray <NSString *> *)ProfessionEmoji {
    return [PSEmojiUtilities ProfessionEmoji];
}

+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emojiString {
    return [PSEmojiUtilities professionSkinToneEmojiBaseKey:emojiString];
}

%end

%hook UIKeyboardEmojiCollectionInputView

- (NSString *)emojiBaseString:(NSString *)emojiString {
    return [PSEmojiUtilities emojiBaseString:emojiString];
}

- (BOOL)genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [PSEmojiUtilities genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
}

%end

%end

%group EMF

%hook EMFEmojiCategory

+ (NSArray <NSString *> *)PeopleEmoji {
    return [PSEmojiUtilities PeopleEmoji];
}

+ (NSArray <NSString *> *)NatureEmoji {
    return [PSEmojiUtilities NatureEmoji];
}

+ (NSArray <NSString *> *)FoodAndDrinkEmoji {
    return [PSEmojiUtilities FoodAndDrinkEmoji];
}

+ (NSArray <NSString *> *)ActivityEmoji {
    return [PSEmojiUtilities ActivityEmoji];
}

+ (NSArray <NSString *> *)CelebrationEmoji {
    return [PSEmojiUtilities CelebrationEmoji];
}

+ (NSArray <NSString *> *)TravelAndPlacesEmoji {
    return [PSEmojiUtilities TravelAndPlacesEmoji];
}

+ (NSArray <NSString *> *)ObjectsEmoji {
    return [PSEmojiUtilities ObjectsEmoji];
}

+ (NSArray <NSString *> *)SymbolsEmoji {
    return [PSEmojiUtilities SymbolsEmoji];
}

+ (NSArray <NSString *> *)DingbatsVariantEmoji {
    return [PSEmojiUtilities DingbatVariantsEmoji];
}

+ (NSArray <NSString *> *)NoneVariantEmoji {
    return [PSEmojiUtilities NoneVariantEmoji];
}

+ (NSArray <NSString *> *)SkinToneEmoji {
    return [PSEmojiUtilities SkinToneEmoji];
}

+ (NSArray <NSString *> *)GenderEmoji {
    return [PSEmojiUtilities GenderEmoji];
}

+ (NSArray <NSString *> *)ProfessionEmoji {
    return [PSEmojiUtilities ProfessionEmoji];
}

+ (NSArray <NSString *> *)computeEmojiFlagsSortedByLanguage {
    return [PSEmojiUtilities FlagsEmoji];
}

- (NSMutableArray <EMFEmojiToken *> *)emojiTokensForLocaleData:(EMFEmojiLocaleData *)localeData {
    NSString *identifier = self.identifier;
    NSMutableArray <EMFEmojiToken *> *tokens = [NSMutableArray array];
    NSArray <NSString *> *emojis = nil;
    if (stringEqual(identifier, @"EMFEmojiCategoryPrepopulated"))
        emojis = [PSEmojiUtilities PrepolulatedEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategoryPeople"))
        emojis = [PSEmojiUtilities PeopleEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategoryNature"))
        emojis = [PSEmojiUtilities NatureEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategoryFoodAndDrink"))
        emojis = [PSEmojiUtilities FoodAndDrinkEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategoryActivity"))
        emojis = [PSEmojiUtilities ActivityEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategoryTravelAndPlaces"))
        emojis = [PSEmojiUtilities TravelAndPlacesEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategoryObjects"))
        emojis = [PSEmojiUtilities ObjectsEmoji];
    else if (stringEqual(identifier, @"EMFEmojiCategorySymbols"))
        emojis = [PSEmojiUtilities SymbolsEmoji];
    for (NSString *emoji in emojis)
        [tokens addObject:[NSClassFromString(@"EMFEmojiToken") emojiTokenWithString:emoji localeData:localeData]];
    return tokens;
}

%end

%hook EMFEmojiPreferences

+ (NSArray <NSString *> *)_cachedFlagCategoryEmoji:(id)arg1 {
    return [PSEmojiUtilities FlagsEmoji];
}

%end

%hook EMFStringUtilities

+ (NSString *)_baseStringForEmojiString:(NSString *)emojiString {
    return [PSEmojiUtilities emojiBaseString:emojiString];
}

%end

%hook EMFEmojiToken

%property(assign) int ep_supportsSkinToneVariants;

- (id)initWithCEMEmojiToken:(void *)arg0 {
    self = %orig;
    self.ep_supportsSkinToneVariants = -1;
    return self;
}

- (id)initWithString:(NSString *)string localeIdentifier:(NSString *)localeIdentifier {
    self = %orig;
    self.ep_supportsSkinToneVariants = -1;
    return self;
}

- (BOOL)supportsSkinToneVariants {
    if (self.ep_supportsSkinToneVariants == -1)
        self.ep_supportsSkinToneVariants = ![[PSEmojiUtilities NoneVariantEmoji] containsObject:self.string] && [PSEmojiUtilities emojiString:[PSEmojiUtilities emojiBaseFirstCharacterString:self.string] inGroup:[PSEmojiUtilities SkinToneEmoji]] ? 1 : 0;
    return self.ep_supportsSkinToneVariants == 1;
}

%end

%end

%group CoreEmoji

void (*EmojiData)(void *, CFURLRef const, CFURLRef const);
%hookf(void, EmojiData, void *arg0, CFURLRef const datPath, CFURLRef const metaDatPath) {
    %orig(arg0, datPath, metaDatPath);
    CFMutableArrayRef *data = (CFMutableArrayRef *)((uintptr_t)arg0 + 0x28);
    int *count = (int *)((uintptr_t)arg0 + 0x32);
    CFArrayRemoveAllValues(*data);
    for (NSString *emoji in Emoji_Data) {
        CFStringRef cfEmoji = CFStringCreateWithCString(kCFAllocatorDefault, [emoji UTF8String], kCFStringEncodingUTF8);
        if (cfEmoji != NULL) {
            CFArrayAppendValue(*data, cfEmoji);
            CFRelease(cfEmoji);
        }
    }
    [Emoji_Data autorelease];
    *count = CFArrayGetCount(*data);
}

CFURLRef (*copyResourceURLFromFrameworkBundle)(CFStringRef const, CFStringRef const, CFLocaleRef const);
%hookf(CFURLRef, copyResourceURLFromFrameworkBundle, CFStringRef const resourceName, CFStringRef const resourceType, CFLocaleRef const locale) {
    CFURLRef url = NULL;
    if (resourceName && resourceType && !CFStringEqual(resourceName, CFSTR("emojimeta")) && (CFStringEqual(resourceType, CFSTR("dat")) || CFStringEqual(resourceType, CFSTR("bitmap")) || CFStringEqual(resourceType, CFSTR("strings"))))
        url = %orig((__bridge CFStringRef)[(__bridge NSString *)resourceName stringByAppendingString:@"2"], resourceType, locale);
    return url ? url : %orig;
}

%end

%ctor {
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
#if TARGET_OS_SIMULATOR
    dlopen("/opt/simject/EmojiAttributes.dylib", RTLD_LAZY);
#endif
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/PrivateFrameworks/CoreEmoji.framework/CoreEmoji"));
    copyResourceURLFromFrameworkBundle = (CFURLRef (*)(CFStringRef const, CFStringRef const, CFLocaleRef const))_PSFindSymbolCallable(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_PK10__CFLocale");
    NSString *processName = [[NSProcessInfo processInfo] processName];
    BOOL kbd = stringEqual(processName, @"kbd");
    if (!kbd) {
        %init(UIKit);
    }
    %init(EMF);
    EmojiData = (void (*)(void *, CFURLRef const, CFURLRef const))_PSFindSymbolCallable(ref, "__ZN3CEM9EmojiDataC1EPK7__CFURLS3_");
    %init(CoreEmoji);
}