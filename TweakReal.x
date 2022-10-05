#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import <dlfcn.h>

%config(generator=MobileSubstrate)

BOOL overrideIsCoupleMultiSkinToneEmoji = NO;

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
    // if (IS_IOS_OR_NEWER(iOS_15_0)) {
    //     NSURL *orig = %orig;
    //     NSString *absoluteURL = [orig.absoluteString
    //         stringByReplacingOccurrencesOfString:@"/System/Library/PrivateFrameworks/CoreEmoji.framework"
    //         withString:@"/var/jb/System/Library/PrivateFrameworks/CoreEmoji.framework"];
    //     absoluteURL = [absoluteURL stringByReplacingOccurrencesOfString:resourceName withString:newResourceName];
    //     return [NSURL URLWithString:absoluteURL];
    // }
    NSURL *url = %orig(newResourceName, extension, subdirectory);
    return url ?: %orig;
}

%end

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

+ (NSArray <NSString *> *)ExtendedCoupleMultiSkinToneEmoji {
    return [PSEmojiUtilities ExtendedCoupleMultiSkinToneEmoji];
}

+ (NSArray <NSString *> *)computeEmojiFlagsSortedByLanguage {
    return [PSEmojiUtilities FlagsEmoji];
}

- (NSMutableArray <EMFEmojiToken *> *)emojiTokensForLocaleData:(EMFEmojiLocaleData *)localeData {
    NSString *identifier = self.identifier;
    NSMutableArray <EMFEmojiToken *> *tokens = [NSMutableArray array];
    NSArray <NSString *> *emojis = nil;
    if ([identifier isEqualToString:@"EMFEmojiCategoryPrepopulated"])
        emojis = [PSEmojiUtilities PrepolulatedEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryPeople"])
        emojis = [PSEmojiUtilities PeopleEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryNature"])
        emojis = [PSEmojiUtilities NatureEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryFoodAndDrink"])
        emojis = [PSEmojiUtilities FoodAndDrinkEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryActivity"])
        emojis = [PSEmojiUtilities ActivityEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryTravelAndPlaces"])
        emojis = [PSEmojiUtilities TravelAndPlacesEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategoryObjects"])
        emojis = [PSEmojiUtilities ObjectsEmoji];
    else if ([identifier isEqualToString:@"EMFEmojiCategorySymbols"])
        emojis = [PSEmojiUtilities SymbolsEmoji];
    for (NSString *emoji in emojis)
        [tokens addObject:[%c(EMFEmojiToken) emojiTokenWithString:emoji localeData:localeData]];
    return tokens;
}

+ (BOOL)_isCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    if (overrideIsCoupleMultiSkinToneEmoji) {
        overrideIsCoupleMultiSkinToneEmoji = NO;
        return [PSEmojiUtilities supportsCoupleSkinToneSelection:emojiString];
    }
    return [PSEmojiUtilities isCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_isComposedCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities isComposedCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_supportsCoupleSkinToneSelection:(NSString *)emojiString {
    return [PSEmojiUtilities supportsCoupleSkinToneSelection:emojiString];
}

%end

%hook EMFEmojiPreferences

+ (NSArray <NSString *> *)_cachedFlagCategoryEmoji:(id)arg1 {
    return [PSEmojiUtilities FlagsEmoji];
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
    return [PSEmojiUtilities emojiBaseString:emojiString];
}

+ (BOOL)_genderEmojiBaseStringNeedVariantSelector:(NSString *)emojiBaseString {
    return [PSEmojiUtilities genderEmojiBaseStringNeedVariantSelector:emojiBaseString];
}

+ (BOOL)_hasSkinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities hasSkinToneVariants:emojiString];
}

+ (NSString *)_multiPersonStringForString:(NSString *)emojiString skinToneVariantSpecifier:(NSArray <NSString *> *)specifier {
    return [PSEmojiUtilities multiPersonStringForString:emojiString skinToneVariantSpecifier:specifier];
}

+ (NSString *)_joiningStringForCoupleString:(NSString *)emojiString {
    return [PSEmojiUtilities joiningStringForCoupleString:emojiString];
}

+ (NSArray <NSString *> *)_skinToneSpecifiersForString:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneSpecifiersForString:emojiString];
}

+ (NSArray <NSString *> *)_skinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneVariants:emojiString withSelf:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneChooserVariantsForString:emojiString usesSilhouetteSpecifiers:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString usesSilhouetteSpecifiers:(BOOL)silhouette {
    return [PSEmojiUtilities skinToneChooserVariantsForString:emojiString usesSilhouetteSpecifiers:silhouette];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForHandHoldingCoupleType:(PSEmojiMultiSkinType)coupleType {
    return [PSEmojiUtilities skinToneChooserVariantsForHandHoldingCoupleType:coupleType];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserArraysForCoupleType:(PSEmojiMultiSkinType)coupleType joiner:(NSString *)joiner {
    return [PSEmojiUtilities skinToneChooserArraysForCoupleType:coupleType joiner:joiner];
}

+ (NSArray <NSString *> *)_tokenizedMultiPersonFromString:(NSString *)emojiString {
    return [PSEmojiUtilities tokenizedMultiPersonFromString:emojiString];
}

+ (PSEmojiMultiSkinType)multiPersonTypeForString:(NSString *)string {
    return [PSEmojiUtilities multiPersonTypeForString:string];
}

%end

%hook EMFEmojiToken

- (BOOL)supportsSkinToneVariants {
    return [PSEmojiUtilities hasSkinToneVariants:[self valueForKey:@"_string"]];
}

%end

%end

static BOOL freeFlag = NO;
static CFStringRef overrideResourceName(CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder) {
    CFMutableStringRef newResourceName = (CFMutableStringRef)resourceName;
    BOOL gate = resourceName && resourceType;
    BOOL byExtension = CFStringEqual(resourceType, CFSTR("dat"))
            || CFStringEqual(resourceType, CFSTR("bitmap"))
            || CFStringEqual(resourceType, CFSTR("strings"))
            || CFStringEqual(resourceType, CFSTR("stringsdict"));
    BOOL byName = CFStringEqual(resourceName, CFSTR("term_index"))
            || CFStringEqual(resourceName, CFSTR("term_index_stemmed"))
            || CFStringEqual(resourceName, CFSTR("document_index"))
            || CFStringEqual(resourceName, CFSTR("document_index_stemmed"));
    BOOL byFolder = folder && (CFStringEqual(folder, CFSTR("SearchEngineOverrideLists")) || CFStringEqual(folder, CFSTR("SearchModel-en")));
    freeFlag = NO;
    if (gate && (byName || byExtension || byFolder)) {
        if (CFStringEqual(resourceName, CFSTR("emojimeta")))
            newResourceName = (CFMutableStringRef)(IS_IOS_OR_NEWER(iOS_12_1) ? CFSTR("emojimeta_modern") : CFSTR("emojimeta_legacy"));
        else {
            newResourceName = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(resourceName), resourceName);
            CFStringAppend(newResourceName, CFSTR("2"));
            freeFlag = YES;
        }
    }
    return newResourceName;
}

// static CFURLRef getRedirectedUrl(CFURLRef url, CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder) {
//     if (!url) return url;
//     CFURLRef absoluteUrl = CFURLCopyAbsoluteURL(url);
//     if (!absoluteUrl) return url;
//     CFStringRef absoluteString_ = CFURLGetString(absoluteUrl);
//     CFMutableStringRef absoluteString = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(absoluteString_), absoluteString_);
//     CFRelease(absoluteString_);
//     CFStringFindAndReplace(
//         absoluteString,
//         CFSTR("/System/Library/PrivateFrameworks/CoreEmoji.framework"),
//         CFSTR("/var/jb/System/Library/PrivateFrameworks/CoreEmoji.framework"),
//         CFRangeMake(0, CFStringGetLength(absoluteString)),
//         0);
//     CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, folder);
//     CFStringFindAndReplace(
//         absoluteString,
//         resourceName,
//         newResourceName,
//         CFRangeMake(0, CFStringGetLength(absoluteString)),
//         0);
//     if (freeFlag && newResourceName)
//         CFRelease(newResourceName);
//     CFURLRef redirectedUrl = CFURLCreateWithString(kCFAllocatorDefault, absoluteString, NULL);
//     return redirectedUrl;
// }

%group CoreEmoji_Bundle

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle, CFStringRef const resourceName, CFStringRef const resourceType, CFLocaleRef const locale) {
    // if (IS_IOS_OR_NEWER(iOS_15_0))
    //     return getRedirectedUrl(%orig, resourceName, resourceType, NULL);
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, NULL);
    CFURLRef url = %orig(newResourceName, resourceType, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    return url ? url : %orig;
}

%end

%group CoreEmoji_Bundle2

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle2, CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder, CFStringRef const locale) {
    // if (IS_IOS_OR_NEWER(iOS_15_0))
    //     return getRedirectedUrl(%orig, resourceName, resourceType, folder);
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, folder);
    CFURLRef url = %orig(newResourceName, resourceType, folder, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    return url ? url : %orig;
}

%end

%ctor {
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