#import <dlfcn.h>
#import <PSHeader/PS.h>
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import <HBLog.h>

%config(generator=MobileSubstrate)

BOOL overrideIsCoupleMultiSkinToneEmoji = NO;
Class PSEmojiUtilitiesClass;

%group UIKit

%hook UIKeyboardEmojiCategory

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass hasVariantsForEmoji:emojiString];
}

+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass professionSkinToneEmojiBaseKey:emojiString];
}

%end

%hook UIKeyboardEmojiCollectionInputView

- (NSString *)emojiBaseString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass emojiBaseString:emojiString];
}

- (BOOL)genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [PSEmojiUtilitiesClass genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
}

%end

%end

static NSString *overrideResourceNameNS(NSString *resourceName, NSString *subdirectory) {
    return [resourceName isEqualToString:@"document_index"]
        || [resourceName isEqualToString:@"term_index"]
        || [resourceName isEqualToString:@"document_index_stemmed"]
        || [resourceName isEqualToString:@"term_index_stemmed"]
        || [resourceName isEqualToString:@"vocabulary"]
        || [subdirectory isEqualToString:@"SearchEngineOverrideLists"]
        ? [resourceName stringByAppendingString:@"2"] : resourceName;
}

%group EMF

%hook NSBundle

- (NSURL *)URLForResource:(NSString *)resourceName withExtension:(NSString *)extension subdirectory:(NSString *)subdirectory {
    NSString *newResourceName = overrideResourceNameNS(resourceName, subdirectory);
    NSURL *url = %orig(newResourceName, extension, subdirectory);
    return url ?: %orig;
}

%end

%hook EMFEmojiCategory

+ (NSArray <NSString *> *)PeopleEmoji {
    return [PSEmojiUtilitiesClass PeopleEmoji];
}

+ (NSArray <NSString *> *)NatureEmoji {
    return [PSEmojiUtilitiesClass NatureEmoji];
}

+ (NSArray <NSString *> *)FoodAndDrinkEmoji {
    return [PSEmojiUtilitiesClass FoodAndDrinkEmoji];
}

+ (NSArray <NSString *> *)ActivityEmoji {
    return [PSEmojiUtilitiesClass ActivityEmoji];
}

+ (NSArray <NSString *> *)CelebrationEmoji {
    return [PSEmojiUtilitiesClass CelebrationEmoji];
}

+ (NSArray <NSString *> *)TravelAndPlacesEmoji {
    return [PSEmojiUtilitiesClass TravelAndPlacesEmoji];
}

+ (NSArray <NSString *> *)ObjectsEmoji {
    return [PSEmojiUtilitiesClass ObjectsEmoji];
}

+ (NSArray <NSString *> *)SymbolsEmoji {
    return [PSEmojiUtilitiesClass SymbolsEmoji];
}

+ (NSArray <NSString *> *)DingbatsVariantEmoji {
    return [PSEmojiUtilitiesClass DingbatVariantsEmoji];
}

+ (NSArray <NSString *> *)NoneVariantEmoji {
    return [PSEmojiUtilitiesClass NoneVariantEmoji];
}

+ (NSArray <NSString *> *)SkinToneEmoji {
    return [PSEmojiUtilitiesClass SkinToneEmoji];
}

+ (NSArray <NSString *> *)GenderEmoji {
    return [PSEmojiUtilitiesClass GenderEmoji];
}

+ (NSArray <NSString *> *)ProfessionEmoji {
    return [PSEmojiUtilitiesClass ProfessionEmoji];
}

+ (NSArray <NSString *> *)ProfessionWithoutSkinToneEmoji {
    return [PSEmojiUtilitiesClass ProfessionWithoutSkinToneEmoji];
}

+ (NSArray <NSString *> *)CoupleMultiSkinToneEmoji {
    return [PSEmojiUtilitiesClass CoupleMultiSkinToneEmoji];
}

+ (NSArray <NSString *> *)MultiPersonFamilySkinToneEmoji {
    return [PSEmojiUtilitiesClass MultiPersonFamilySkinToneEmoji];
}

+ (NSArray <NSString *> *)ExtendedCoupleMultiSkinToneEmoji {
    return [PSEmojiUtilitiesClass ExtendedCoupleMultiSkinToneEmoji];
}

+ (NSArray <NSString *> *)computeEmojiFlagsSortedByLanguage {
    return [PSEmojiUtilitiesClass FlagsEmoji];
}

- (NSMutableArray <EMFEmojiToken *> *)emojiTokensForLocaleData:(EMFEmojiLocaleData *)localeData {
    NSString *identifier = self.identifier;
    NSMutableArray <EMFEmojiToken *> *tokens = [NSMutableArray array];
    NSArray <NSString *> *emojis = nil;
    if ([identifier isEqualToString:@"EMFEmojiCategoryPrepopulated"])
        emojis = [PSEmojiUtilitiesClass PrepolulatedEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryPeople"])
        emojis = [PSEmojiUtilitiesClass PeopleEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryNature"])
        emojis = [PSEmojiUtilitiesClass NatureEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryFoodAndDrink"])
        emojis = [PSEmojiUtilitiesClass FoodAndDrinkEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryActivity"])
        emojis = [PSEmojiUtilitiesClass ActivityEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryTravelAndPlaces"])
        emojis = [PSEmojiUtilitiesClass TravelAndPlacesEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryObjects"])
        emojis = [PSEmojiUtilitiesClass ObjectsEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategorySymbols"])
        emojis = [PSEmojiUtilitiesClass SymbolsEmoji];
    Class EMFEmojiTokenClass = %c(EMFEmojiToken);
    for (NSString *emoji in emojis)
        [tokens addObject:[EMFEmojiTokenClass emojiTokenWithString:emoji localeData:localeData]];
    return tokens;
}

+ (BOOL)_isCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    if (overrideIsCoupleMultiSkinToneEmoji) {
        overrideIsCoupleMultiSkinToneEmoji = NO;
        return [PSEmojiUtilitiesClass supportsCoupleSkinToneSelection:emojiString];
    }
    return [PSEmojiUtilitiesClass isCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_isComposedCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass isComposedCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_supportsCoupleSkinToneSelection:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass supportsCoupleSkinToneSelection:emojiString];
}

%end

%hook EMFEmojiPreferences

+ (NSArray <NSString *> *)_cachedFlagCategoryEmoji:(id)arg1 {
    return [PSEmojiUtilitiesClass FlagsEmoji];
}

%end

%hook EMFEmojiPreferencesClient

- (void)didUseEmoji:(NSString *)emojiString usageMode:(id)usageMode typingName:(id)typingName {
    overrideIsCoupleMultiSkinToneEmoji = YES;
    %orig;
    overrideIsCoupleMultiSkinToneEmoji = NO;
}

%end

%hook EMFStringUtilities

+ (NSString *)_baseStringForEmojiString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass emojiBaseString:emojiString];
}

+ (BOOL)_genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [PSEmojiUtilitiesClass genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
}

+ (BOOL)_hasSkinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass hasSkinToneVariants:emojiString];
}

+ (NSString *)_multiPersonStringForString:(NSString *)emojiString skinToneVariantSpecifier:(NSArray <NSString *> *)specifier {
    return [PSEmojiUtilitiesClass multiPersonStringForString:emojiString skinToneVariantSpecifier:specifier];
}

+ (NSString *)_joiningStringForCoupleString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass joiningStringForCoupleString:emojiString];
}

+ (NSArray <NSString *> *)_skinToneSpecifiersForString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass skinToneSpecifiersForString:emojiString];
}

+ (NSArray <NSString *> *)_skinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass skinToneVariants:emojiString withSelf:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass skinToneChooserVariantsForString:emojiString usesSilhouetteSpecifiers:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString usesSilhouetteSpecifiers:(BOOL)silhouette {
    return [PSEmojiUtilitiesClass skinToneChooserVariantsForString:emojiString usesSilhouetteSpecifiers:silhouette];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForHandHoldingCoupleType:(PSEmojiMultiSkinType)coupleType {
    return [PSEmojiUtilitiesClass skinToneChooserVariantsForHandHoldingCoupleType:coupleType];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserArraysForCoupleType:(PSEmojiMultiSkinType)coupleType joiner:(NSString *)joiner {
    return [PSEmojiUtilitiesClass skinToneChooserArraysForCoupleType:coupleType joiner:joiner];
}

+ (NSArray <NSString *> *)_tokenizedMultiPersonFromString:(NSString *)emojiString {
    return [PSEmojiUtilitiesClass tokenizedMultiPersonFromString:emojiString];
}

+ (PSEmojiMultiSkinType)multiPersonTypeForString:(NSString *)string {
    return [PSEmojiUtilitiesClass multiPersonTypeForString:string];
}

%end

%hook EMFEmojiToken

- (BOOL)supportsSkinToneVariants {
    return [PSEmojiUtilitiesClass hasSkinToneVariants:[self valueForKey:@"_string"]];
}

%end

%end

static CFStringRef overrideResourceName(CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder, BOOL *freeFlag) {
    CFMutableStringRef newResourceName = (CFMutableStringRef)resourceName;
    BOOL gate = resourceName && resourceType;
    BOOL byExtension = CFStringEqual(resourceType, CFSTR("dat"))
            || CFStringEqual(resourceType, CFSTR("bitmap"))
            || CFStringEqual(resourceType, CFSTR("strings"))
            || CFStringEqual(resourceType, CFSTR("stringsdict"));
    BOOL byName = CFStringEqual(resourceName, CFSTR("term_index"))
            || CFStringEqual(resourceName, CFSTR("term_index_stemmed"))
            || CFStringEqual(resourceName, CFSTR("document_index"))
            || CFStringEqual(resourceName, CFSTR("document_index_stemmed"))
            || CFStringEqual(resourceName, CFSTR("vocabulary"));
    BOOL byFolder = folder && (CFStringEqual(folder, CFSTR("SearchEngineOverrideLists")) || CFStringEqual(folder, CFSTR("SearchModel-en")));
    *freeFlag = NO;
    if (gate && (byName || byExtension || byFolder)) {
        if (CFStringEqual(resourceName, CFSTR("emojimeta")))
            newResourceName = (CFMutableStringRef)(IS_IOS_OR_NEWER(iOS_12_1) ? CFSTR("emojimeta_modern") : CFSTR("emojimeta_legacy"));
        else {
            newResourceName = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(resourceName), resourceName);
            CFStringAppend(newResourceName, CFSTR("2"));
            *freeFlag = YES;
        }
    }
    return newResourceName;
}

static CFURLRef getRedirectedUrl(CFURLRef url, CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder) {
    if (!url) return url;
    CFURLRef absoluteUrl = CFURLCopyAbsoluteURL(url);
    if (!absoluteUrl) return url;
    CFStringRef absoluteString_ = CFURLGetString(absoluteUrl);
    CFMutableStringRef absoluteString = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(absoluteString_), absoluteString_);
    CFRelease(absoluteString_);
    CFStringFindAndReplace(
        absoluteString,
        CFSTR("/System/Library/PrivateFrameworks/CoreEmoji.framework"),
        CFSTR("/var/jb/System/Library/PrivateFrameworks/CoreEmoji.framework"),
        CFRangeMake(0, CFStringGetLength(absoluteString)),
        0);
    BOOL freeFlag = NO;
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, folder, &freeFlag);
    CFStringFindAndReplace(
        absoluteString,
        resourceName,
        newResourceName,
        CFRangeMake(0, CFStringGetLength(absoluteString)),
        0);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    CFURLRef redirectedUrl = CFURLCreateWithString(kCFAllocatorDefault, absoluteString, NULL);
    return redirectedUrl;
}

%group CoreEmoji_Bundle

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle, CFStringRef const resourceName, CFStringRef const resourceType, CFLocaleRef const locale) {
    BOOL freeFlag = NO;
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, NULL, &freeFlag);
    CFURLRef url = %orig(newResourceName, resourceType, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    return url ? url : %orig;
}

%end

%group CoreEmoji_Bundle2

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle2, CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder, CFStringRef const locale) {
    BOOL freeFlag = NO;
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, folder, &freeFlag);
    CFURLRef url = %orig(newResourceName, resourceType, folder, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    CFURLRef newUrl = url ?: getRedirectedUrl(%orig, resourceName, resourceType, folder);
    return newUrl;
}

%end

%ctor {
    dlopen(realPath2(@"/usr/lib/libEmojiLibrary.dylib"), RTLD_NOW);
    PSEmojiUtilitiesClass = %c(PSEmojiUtilities);
    const char *coreEmoji = realPath2(@"/System/Library/PrivateFrameworks/CoreEmoji.framework/CoreEmoji");
    dlopen(coreEmoji, RTLD_NOW);
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    MSImageRef ref = MSGetImageByName(coreEmoji);
    CFURLRef (*copyResourceURLFromFrameworkBundle_p)(CFStringRef const, CFStringRef const, CFLocaleRef const) = NULL;
    copyResourceURLFromFrameworkBundle_p = (typeof(copyResourceURLFromFrameworkBundle_p))MSFindSymbol(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_PK10__CFLocale");
    if (copyResourceURLFromFrameworkBundle_p) {
        %init(CoreEmoji_Bundle, copyResourceURLFromFrameworkBundle = (void *)copyResourceURLFromFrameworkBundle_p);
    }
    CFURLRef (*copyResourceURLFromFrameworkBundle2_p)(CFStringRef const, CFStringRef const, CFStringRef const, CFLocaleRef const) = NULL;
    copyResourceURLFromFrameworkBundle2_p = (typeof(copyResourceURLFromFrameworkBundle2_p))MSFindSymbol(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_S2_PK10__CFLocale");
    if (copyResourceURLFromFrameworkBundle2_p) {
        %init(CoreEmoji_Bundle2, copyResourceURLFromFrameworkBundle2 = (void *)copyResourceURLFromFrameworkBundle2_p);
    }
    NSString *processName = [[NSProcessInfo processInfo] processName];
    BOOL kbd = [processName isEqualToString:@"kbd"];
    if (!kbd) {
        %init(UIKit);
    }
    %init(EMF);
}
