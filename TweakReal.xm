#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"

%config(generator=MobileSubstrate)

%group UIKit

%hook UIKeyboardEmojiCategory

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities hasVariantsForEmoji:emojiString];
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

+ (NSArray <NSString *> *)ProfessionWithoutSkinToneEmoji {
    return [PSEmojiUtilities ProfessionWithoutSkinToneEmoji];
}

+ (NSArray <NSString *> *)CoupleMultiSkinToneEmoji {
    return [PSEmojiUtilities CoupleMultiSkinToneEmoji];
}

+ (NSArray <NSString *> *)MultiPersonFamilySkinToneEmoji {
    return [PSEmojiUtilities MultiPersonFamilySkinToneEmoji];
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

+ (BOOL)_genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [PSEmojiUtilities genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
}

+ (BOOL)_hasSkinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities hasSkinToneVariants:emojiString];
}

+ (NSArray <NSString *> *)_skinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneVariants:emojiString withSelf:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForMultiPersonType:(NSInteger)type {
    if (type == PSEmojiMultiPersonTypeNN)
        return [PSEmojiUtilities skinToneChooserVariantsForNeutralMultiPersonType];
    return %orig;
}

+ (NSString *)_multiPersonStringForString:(NSString *)string skinToneVariantSpecifier:(NSArray <NSString *> *)specifier {
    NSString *value = %orig;
    if (value == nil && [PSEmojiUtilities multiPersonTypeForString:string] == PSEmojiMultiPersonTypeNN)
        return [PSEmojiUtilities multiPersonStringForNeutralStringWithSkinToneVariantSpecifier:specifier];
    return value;
}

+ (PSEmojiMultiPersonType)multiPersonTypeForString:(NSString *)string {
    return [PSEmojiUtilities multiPersonTypeForString:string];
}

%end

%end

%group CoreEmoji_Bundle

CFURLRef (*copyResourceURLFromFrameworkBundle)(CFStringRef const, CFStringRef const, CFLocaleRef const);
%hookf(CFURLRef, copyResourceURLFromFrameworkBundle, CFStringRef const resourceName, CFStringRef const resourceType, CFLocaleRef const locale) {
    CFURLRef url = NULL;
    if (resourceName && resourceType && (
        CFStringEqual(resourceType, CFSTR("dat"))
            || CFStringEqual(resourceType, CFSTR("bitmap"))
            || CFStringEqual(resourceType, CFSTR("strings"))
            || CFStringEqual(resourceType, CFSTR("stringsdict")))) {
        CFMutableStringRef newResourceName = NULL;
        if (!CFStringEqual(resourceName, CFSTR("emojimeta"))) {
            newResourceName = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(resourceName), resourceName);
            CFStringAppend(newResourceName, CFSTR("2"));
        }
        url = %orig(newResourceName ? newResourceName : (isiOS12_1Up ? CFSTR("emojimeta_modern") : CFSTR("emojimeta_legacy")), resourceType, locale);
        if (newResourceName)
            CFRelease(newResourceName);
    }
    return url ? url : %orig;
}

%end

%ctor {
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/PrivateFrameworks/CoreEmoji.framework/CoreEmoji"));
    copyResourceURLFromFrameworkBundle = (CFURLRef (*)(CFStringRef const, CFStringRef const, CFLocaleRef const))_PSFindSymbolCallable(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_PK10__CFLocale");
    NSString *processName = [[NSProcessInfo processInfo] processName];
    BOOL kbd = stringEqual(processName, @"kbd");
    if (!kbd) {
        %init(UIKit);
    }
    %init(EMF);
    %init(CoreEmoji_Bundle);
}