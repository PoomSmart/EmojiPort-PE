#import <dlfcn.h>
#import <PSHeader/PS.h>
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import <HBLog.h>

%config(generator=MobileSubstrate)

BOOL overrideIsCoupleMultiSkinToneEmoji = NO;

%group UIKit

%hook UIKeyboardEmojiCategory

+ (NSUInteger)hasVariantsForEmoji:(NSString *)emojiString {
    return [SoftPSEmojiUtilities hasVariantsForEmoji:emojiString];
}

+ (NSString *)professionSkinToneEmojiBaseKey:(NSString *)emojiString {
    return [SoftPSEmojiUtilities professionSkinToneEmojiBaseKey:emojiString];
}

%end

%hook UIKeyboardEmojiCollectionInputView

- (NSString *)emojiBaseString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities emojiBaseString:emojiString];
}

- (BOOL)genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [SoftPSEmojiUtilities genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
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
    return [SoftPSEmojiUtilities PeopleEmoji];
}

+ (NSArray <NSString *> *)NatureEmoji {
    return [SoftPSEmojiUtilities NatureEmoji];
}

+ (NSArray <NSString *> *)FoodAndDrinkEmoji {
    return [SoftPSEmojiUtilities FoodAndDrinkEmoji];
}

+ (NSArray <NSString *> *)ActivityEmoji {
    return [SoftPSEmojiUtilities ActivityEmoji];
}

+ (NSArray <NSString *> *)CelebrationEmoji {
    return [SoftPSEmojiUtilities CelebrationEmoji];
}

+ (NSArray <NSString *> *)TravelAndPlacesEmoji {
    return [SoftPSEmojiUtilities TravelAndPlacesEmoji];
}

+ (NSArray <NSString *> *)ObjectsEmoji {
    return [SoftPSEmojiUtilities ObjectsEmoji];
}

+ (NSArray <NSString *> *)SymbolsEmoji {
    return [SoftPSEmojiUtilities SymbolsEmoji];
}

+ (NSArray <NSString *> *)DingbatsVariantEmoji {
    return [SoftPSEmojiUtilities DingbatVariantsEmoji];
}

+ (NSArray <NSString *> *)NoneVariantEmoji {
    return [SoftPSEmojiUtilities NoneVariantEmoji];
}

+ (NSArray <NSString *> *)SkinToneEmoji {
    return [SoftPSEmojiUtilities SkinToneEmoji];
}

+ (NSArray <NSString *> *)GenderEmoji {
    return [SoftPSEmojiUtilities GenderEmoji];
}

+ (NSArray <NSString *> *)ProfessionEmoji {
    return [SoftPSEmojiUtilities ProfessionEmoji];
}

+ (NSArray <NSString *> *)ProfessionWithoutSkinToneEmoji {
    return [SoftPSEmojiUtilities ProfessionWithoutSkinToneEmoji];
}

+ (NSArray <NSString *> *)CoupleMultiSkinToneEmoji {
    return [SoftPSEmojiUtilities CoupleMultiSkinToneEmoji];
}

+ (NSArray <NSString *> *)MultiPersonFamilySkinToneEmoji {
    return [SoftPSEmojiUtilities MultiPersonFamilySkinToneEmoji];
}

+ (NSArray <NSString *> *)ExtendedCoupleMultiSkinToneEmoji {
    return [SoftPSEmojiUtilities ExtendedCoupleMultiSkinToneEmoji];
}

+ (NSArray <NSString *> *)computeEmojiFlagsSortedByLanguage {
    return [SoftPSEmojiUtilities FlagsEmoji];
}

- (NSMutableArray <EMFEmojiToken *> *)emojiTokensForLocaleData:(EMFEmojiLocaleData *)localeData {
    NSString *identifier = self.identifier;
    NSMutableArray <EMFEmojiToken *> *tokens = [NSMutableArray array];
    NSArray <NSString *> *emojis = nil;
    if ([identifier isEqualToString:@"EMFEmojiCategoryPrepopulated"])
        emojis = [SoftPSEmojiUtilities PrepolulatedEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryPeople"])
        emojis = [SoftPSEmojiUtilities PeopleEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryNature"])
        emojis = [SoftPSEmojiUtilities NatureEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryFoodAndDrink"])
        emojis = [SoftPSEmojiUtilities FoodAndDrinkEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryActivity"])
        emojis = [SoftPSEmojiUtilities ActivityEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryTravelAndPlaces"])
        emojis = [SoftPSEmojiUtilities TravelAndPlacesEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryObjects"])
        emojis = [SoftPSEmojiUtilities ObjectsEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategorySymbols"])
        emojis = [SoftPSEmojiUtilities SymbolsEmoji];
    Class EMFEmojiTokenClass = %c(EMFEmojiToken);
    for (NSString *emoji in emojis)
        [tokens addObject:[EMFEmojiTokenClass emojiTokenWithString:emoji localeData:localeData]];
    return tokens;
}

+ (BOOL)_isCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    if (overrideIsCoupleMultiSkinToneEmoji) {
        overrideIsCoupleMultiSkinToneEmoji = NO;
        return [SoftPSEmojiUtilities supportsCoupleSkinToneSelection:emojiString];
    }
    return [SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_isComposedCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    return [SoftPSEmojiUtilities isComposedCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_supportsCoupleSkinToneSelection:(NSString *)emojiString {
    return [SoftPSEmojiUtilities supportsCoupleSkinToneSelection:emojiString];
}

%end

%hook EMFEmojiPreferences

+ (NSArray <NSString *> *)_cachedFlagCategoryEmoji:(id)arg1 {
    return [SoftPSEmojiUtilities FlagsEmoji];
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
    return [SoftPSEmojiUtilities emojiBaseString:emojiString];
}

+ (BOOL)_genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [SoftPSEmojiUtilities genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
}

+ (BOOL)_hasSkinToneVariantsForString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities hasSkinToneVariants:emojiString];
}

+ (NSString *)_multiPersonStringForString:(NSString *)emojiString skinToneVariantSpecifier:(NSArray <NSString *> *)specifier {
    return [SoftPSEmojiUtilities multiPersonStringForString:emojiString skinToneVariantSpecifier:specifier];
}

+ (NSString *)_joiningStringForCoupleString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities joiningStringForCoupleString:emojiString];
}

+ (NSArray <NSString *> *)_skinToneSpecifiersForString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities skinToneSpecifiersForString:emojiString];
}

+ (NSArray <NSString *> *)_skinToneVariantsForString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities skinToneVariants:emojiString withSelf:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities skinToneChooserVariantsForString:emojiString usesSilhouetteSpecifiers:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString usesSilhouetteSpecifiers:(BOOL)silhouette {
    return [SoftPSEmojiUtilities skinToneChooserVariantsForString:emojiString usesSilhouetteSpecifiers:silhouette];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForHandHoldingCoupleType:(PSEmojiMultiSkinType)coupleType {
    return [SoftPSEmojiUtilities skinToneChooserVariantsForHandHoldingCoupleType:coupleType];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserArraysForCoupleType:(PSEmojiMultiSkinType)coupleType joiner:(NSString *)joiner {
    return [SoftPSEmojiUtilities skinToneChooserArraysForCoupleType:coupleType joiner:joiner];
}

+ (NSArray <NSString *> *)_tokenizedMultiPersonFromString:(NSString *)emojiString {
    return [SoftPSEmojiUtilities tokenizedMultiPersonFromString:emojiString];
}

+ (PSEmojiMultiSkinType)multiPersonTypeForString:(NSString *)string {
    return [SoftPSEmojiUtilities multiPersonTypeForString:string];
}

%end

%hook EMFEmojiToken

- (BOOL)supportsSkinToneVariants {
    return [SoftPSEmojiUtilities hasSkinToneVariants:[self valueForKey:@"_string"]];
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
            newResourceName = (CFMutableStringRef)(IS_IOS_OR_NEWER(iOS_12_1) ? CFSTR("emojimeta_2") : CFSTR("emojimeta_1"));
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
#if TARGET_OS_SIMULATOR
    dlopen(realPath2(@"/usr/lib/libEmojiLibrary.dylib"), RTLD_NOW);
#endif
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
