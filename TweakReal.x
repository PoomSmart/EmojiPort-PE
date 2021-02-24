#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"

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

%group EMF

%hook NSBundle

- (NSURL *)URLForResource:(NSString *)resourceName withExtension:(NSString *)extension {
    if (stringEqual(resourceName, @"document_index")
        || stringEqual(resourceName, @"term_index")
        || stringEqual(resourceName, @"document_index_stemmed")
        || stringEqual(resourceName, @"term_index_stemmed")
        || stringEqual(resourceName, @"vocabulary")) {
            NSURL *url = %orig([resourceName stringByAppendingString:@"2"], extension);
            if (url) return url;
        }
    return %orig(resourceName, extension);
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

+ (BOOL)_isCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    if (overrideIsCoupleMultiSkinToneEmoji)
        return [PSEmojiUtilities supportsCoupleSkinToneSelection:emojiString];
    return [PSEmojiUtilities isCoupleMultiSkinToneEmoji:emojiString];
}

+ (BOOL)_isComposedCoupleMultiSkinToneEmoji:(NSString *)emojiString {
    return [PSEmojiUtilities isComposedCoupleMultiSkinToneEmoji:emojiString];
}

%end

%hook EMFEmojiPreferences

+ (NSArray <NSString *> *)_cachedFlagCategoryEmoji:(id)arg1 {
    return [PSEmojiUtilities FlagsEmoji];
}

// - (void)didUseEmoji:(NSString *)emojiString usageMode:(id)usageMode typingName:(id)typingName {
//     overrideIsCoupleMultiSkinToneEmoji = YES;
//     %orig;
//     overrideIsCoupleMultiSkinToneEmoji = NO;
// }

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

+ (NSArray <NSString *> *)_skinToneVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneVariants:emojiString withSelf:YES];
}

+ (NSArray <NSArray <NSString *> *> *)_skinToneChooserVariantsForString:(NSString *)emojiString {
    return [PSEmojiUtilities skinToneChooserVariantsForString:emojiString];
}

+ (NSArray <NSString *> *)_tokenizedMultiPersonFromString:(NSString *)emojiString {
    return [PSEmojiUtilities tokenizedMultiPersonFromString:emojiString];
}

+ (PSEmojiMultiPersonType)multiPersonTypeForString:(NSString *)string {
    return [PSEmojiUtilities multiPersonTypeForString:string];
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
    BOOL byName = CFStringEqual(resourceName, CFSTR("term_index"));
    BOOL byFolder = gate && folder && (CFStringEqual(folder, CFSTR("SearchEngineOverrideLists")) || CFStringEqual(folder, CFSTR("SearchModel-en")));
    freeFlag = NO;
    if (gate && (byName || byExtension || byFolder)) {
        if (!CFStringEqual(resourceName, CFSTR("emojimeta"))) {
            newResourceName = CFStringCreateMutableCopy(kCFAllocatorDefault, CFStringGetLength(resourceName), resourceName);
            CFStringAppend(newResourceName, CFSTR("2"));
            freeFlag = YES;
        } else
            newResourceName = (CFMutableStringRef)(IS_IOS_OR_NEWER(iOS_12_1) ? CFSTR("emojimeta_modern") : CFSTR("emojimeta_legacy"));
    }
    return newResourceName;
}

%group CoreEmoji_Bundle

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle, CFStringRef const resourceName, CFStringRef const resourceType, CFLocaleRef const locale) {
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, NULL);
    CFURLRef url = %orig(newResourceName, resourceType, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    return url ? url : %orig;
}

%end

%group CoreEmoji_Bundle2

%hookf(CFURLRef, copyResourceURLFromFrameworkBundle2, CFStringRef const resourceName, CFStringRef const resourceType, CFStringRef const folder, CFStringRef const locale) {
    CFStringRef newResourceName = overrideResourceName(resourceName, resourceType, folder);
    CFURLRef url = %orig(newResourceName, resourceType, folder, locale);
    if (freeFlag && newResourceName)
        CFRelease(newResourceName);
    return url ? url : %orig;
}

%end

%ctor {
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/CoreEmoji.framework/CoreEmoji"), RTLD_NOW);
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/PrivateFrameworks/CoreEmoji.framework/CoreEmoji"));
    CFURLRef (*copyResourceURLFromFrameworkBundle_p)(CFStringRef const, CFStringRef const, CFLocaleRef const) = NULL;
    copyResourceURLFromFrameworkBundle_p = (typeof(copyResourceURLFromFrameworkBundle_p))_PSFindSymbolCallable(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_PK10__CFLocale");
    if (copyResourceURLFromFrameworkBundle_p) {
        %init(CoreEmoji_Bundle, copyResourceURLFromFrameworkBundle = (void *)copyResourceURLFromFrameworkBundle_p);
    }
    CFURLRef (*copyResourceURLFromFrameworkBundle2_p)(CFStringRef const, CFStringRef const, CFStringRef const, CFLocaleRef const) = NULL;
    copyResourceURLFromFrameworkBundle2_p = (typeof(copyResourceURLFromFrameworkBundle2_p))_PSFindSymbolCallable(ref, "__ZN3CEM34copyResourceURLFromFrameworkBundleEPK10__CFStringS2_S2_PK10__CFLocale");
    if (copyResourceURLFromFrameworkBundle2_p) {
        %init(CoreEmoji_Bundle2, copyResourceURLFromFrameworkBundle2 = (void *)copyResourceURLFromFrameworkBundle2_p);
    }
    NSString *processName = [[NSProcessInfo processInfo] processName];
    BOOL kbd = stringEqual(processName, @"kbd");
    if (!kbd) {
        %init(UIKit);
    }
    %init(EMF);
}