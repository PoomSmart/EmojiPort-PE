#import <dlfcn.h>
#import <PSHeader/PS.h>
#import <EmojiLibrary/PSEmojiUtilities.h>
#import <EmojiLibrary/Header.h>
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

static BOOL inNSBundleHook = NO;

%group EMF

%hook NSBundle

- (NSURL *)URLForResource:(NSString *)resourceName withExtension:(NSString *)extension subdirectory:(NSString *)subdirectory {
    if (inNSBundleHook)
        return %orig;
    NSString *newResourceName = overrideResourceNameNS(resourceName, subdirectory);
    const char *frameworkPath = "/System/Library/PrivateFrameworks/CoreEmoji.framework";
    const char *realFrameworkPath = PS_ROOT_PATH(frameworkPath);
    BOOL isRootless = strcmp(realFrameworkPath, frameworkPath) != 0;
    if (isRootless) {
        NSString *bundlePath = [self bundlePath];
        if ([bundlePath isEqualToString:@(frameworkPath)]) {
            NSBundle *coreEmojiBundle = [NSBundle bundleWithPath:@(realFrameworkPath)];
            if (coreEmojiBundle) {
                inNSBundleHook = YES;
                NSURL *url = [coreEmojiBundle URLForResource:newResourceName withExtension:extension subdirectory:subdirectory];
                if (!url)
                    url = [coreEmojiBundle URLForResource:resourceName withExtension:extension subdirectory:subdirectory];
                inNSBundleHook = NO;
                if (url)
                    return url;
            }
        }
    }
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
        emojis = [SoftPSEmojiUtilities PrepopulatedEmoji];
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
    return [SoftPSEmojiUtilities skinToneVariantsForString:emojiString];
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
            || CFStringEqual(resourceName, CFSTR("vocabulary"))
            || CFStringFind(resourceName, CFSTR("SearchEngineOverrideLists"), kCFCompareCaseInsensitive).location != kCFNotFound
            || CFStringFind(resourceName, CFSTR("FindReplace"), kCFCompareCaseInsensitive).location != kCFNotFound;
    BOOL byFolder = folder && (CFStringEqual(folder, CFSTR("SearchEngineOverrideLists")) || CFStringEqual(folder, CFSTR("SearchModel-en")));
    *freeFlag = NO;
    if (gate && (byName || byExtension || byFolder)) {
        if (CFStringEqual(resourceName, CFSTR("emojimeta"))) {
            if (IS_IOS_OR_NEWER(iOS_17_0))
                newResourceName = (CFMutableStringRef)CFSTR("emojimeta_3");
            else if (IS_IOS_OR_NEWER(iOS_12_1))
                newResourceName = (CFMutableStringRef)CFSTR("emojimeta_2");
            else
                newResourceName = (CFMutableStringRef)CFSTR("emojimeta_1");
        } else if (CFStringEqual(resourceName, CFSTR("Emoticons")))
            newResourceName = (CFMutableStringRef)(IS_IOS_OR_NEWER(iOS_17_0) ? CFSTR("Emoticons2") : resourceName);
        else {
            newResourceName = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(resourceName), resourceName);
            if (CFStringEqual(resourceName, CFSTR("FindReplace")) || CFStringEqual(resourceName, CFSTR("FindReplace-en")) || CFStringEqual(resourceName, CFSTR("CharacterPicker")))
                CFStringAppend(newResourceName, IS_IOS_OR_NEWER(iOS_17_0) ? CFSTR("2") : CFSTR("_16"));
            else
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
    const char *frameworkPath = "/System/Library/PrivateFrameworks/CoreEmoji.framework";
    const char *realFrameworkPath = PS_ROOT_PATH(frameworkPath);
    if (strcmp(realFrameworkPath, frameworkPath)) {
        CFStringRef newFrameworkPath = CFStringCreateWithCString(kCFAllocatorDefault, realFrameworkPath, kCFStringEncodingUTF8);
        CFStringFindAndReplace(
            absoluteString,
            CFSTR("/System/Library/PrivateFrameworks/CoreEmoji.framework"),
            newFrameworkPath,
            CFRangeMake(0, CFStringGetLength(absoluteString)),
            0);
        CFRelease(newFrameworkPath);
    }
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
    HBLogDebug(@"New URL: %@", redirectedUrl);
    return redirectedUrl;
}

%group CoreEmoji_Bundle

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle, CFStringRef const resourceName, CFStringRef const resourceType, CFLocaleRef const locale) {
    BOOL freeFlag = NO;
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, NULL, &freeFlag);
    CFURLRef url = %orig(newResourceName, resourceType, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    HBLogDebug(@"New URL: %@", url);
    return url ?: %orig;
}

%end

%group CoreEmoji_Bundle2

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle2, CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder, CFStringRef const locale) {
    BOOL freeFlag = NO;
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, folder, &freeFlag);
    CFURLRef url = %orig(newResourceName, resourceType, folder, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    CFURLRef newUrl = url ?: getRedirectedUrl(%orig(resourceName, resourceType, folder, locale), resourceName, resourceType, folder);
    HBLogDebug(@"copyResourceURLFromFrameworkBundle2 Final URL: %@ (%@: %@ %@ %@)", newUrl, url, resourceName, resourceType, folder);
    return newUrl;
}

%end

%ctor {
#if TARGET_OS_SIMULATOR
#if !defined(INCLUDE_EML) || INCLUDE_EML != 1
    dlopen(realPath2(@"/usr/lib/libEmojiLibrary.dylib"), RTLD_NOW);
#endif
#endif
    const char *coreEmoji = realPath2(@"/System/Library/PrivateFrameworks/CoreEmoji.framework/CoreEmoji");
    dlopen(coreEmoji, RTLD_NOW);
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    MSImageRef ref = MSGetImageByName(coreEmoji);
    CFURLRef (*copyResourceURLFromFrameworkBundle_p)(CFStringRef const, CFStringRef const, CFLocaleRef const) = NULL;
    copyResourceURLFromFrameworkBundle_p = (typeof(copyResourceURLFromFrameworkBundle_p))MSFindSymbol(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_PK10__CFLocale");
    HBLogDebug(@"copyResourceURLFromFrameworkBundle_p: %d", copyResourceURLFromFrameworkBundle_p != NULL);
    if (copyResourceURLFromFrameworkBundle_p) {
        %init(CoreEmoji_Bundle, copyResourceURLFromFrameworkBundle = (void *)copyResourceURLFromFrameworkBundle_p);
    }
    CFURLRef (*copyResourceURLFromFrameworkBundle2_p)(CFStringRef const, CFStringRef const, CFStringRef const, CFLocaleRef const) = NULL;
    copyResourceURLFromFrameworkBundle2_p = (typeof(copyResourceURLFromFrameworkBundle2_p))MSFindSymbol(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_S2_PK10__CFLocale");
    HBLogDebug(@"copyResourceURLFromFrameworkBundle2_p: %d", copyResourceURLFromFrameworkBundle2_p != NULL);
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
