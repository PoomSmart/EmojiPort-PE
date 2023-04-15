#import <PSHeader/Misc.h>
#import <theos/IOSMacros.h>
#import <version.h>
#import <dlfcn.h>
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"

BOOL overrideSkinTone = NO;

%hook EMFEmojiToken

- (BOOL)supportsSkinToneVariants {
    return overrideSkinTone && [SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:self.string] ? YES : %orig;
}

- (NSArray <NSString *> *)_skinToneVariantStrings {
    NSString *emojiString = self.string;
    if (![SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:emojiString])
        return %orig;
    NSMutableArray <NSString *> *variants = [SoftPSEmojiUtilities skinToneVariants:emojiString];
    if (variants) {
        if (!IS_IPAD) {
            [variants insertObject:emojiString atIndex:0];
            return variants;
        }
        for (int i = 20; i > 0; i -= 5)
            [variants insertObject:@"" atIndex:i];
        [variants insertObject:emojiString atIndex:0];
        NSMutableArray <NSString *> *trueVariants = [NSMutableArray array];
        for (NSInteger index = 0; index < 30; ++index) {
            NSInteger insertIndex = ((index % 5) * 6) + (index / 5);
            [trueVariants addObject:variants[insertIndex]];
        }
        return trueVariants;
    }
    return %orig;
}

%end

%hook UIKBRenderFactory

- (void)modifyTraitsForDividerVariant:(id)variant withKey:(UIKBTree *)key {
    if ([SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:key.displayString])
        return;
    %orig;
}

%end

%hook UIKBRenderFactoryiPad

- (NSInteger)rowLimitForKey:(UIKBTree *)tree {
    if ([tree.name isEqualToString:@"EmojiPopupKey"] && [SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:tree.displayString])
        return 6;
    return %orig;
}

%end

%hook UIKBRenderFactoryiPhone

- (void)_configureTraitsForPopupStyle:(id)style withKey:(UIKBTree *)key onKeyplane:(id)keyplane {
    BOOL isEmoji = [key.name isEqualToString:@"EmojiPopupKey"] && [SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:key.displayString];
    if (isEmoji)
        key.name = @"EmojiPopupKey2";
    %orig(style, key, keyplane);
    if (isEmoji)
        key.name = @"EmojiPopupKey";
}

%end

%hook UIKeyboardEmojiCollectionInputView

- (UIKBTree *)subTreeHitTest:(CGPoint)point {
    overrideSkinTone = YES;
    UIKBTree *tree = %orig;
    overrideSkinTone = NO;
    if ([SoftPSEmojiUtilities isCoupleMultiSkinToneEmoji:tree.displayString])
        [tree.subtrees removeObjectAtIndex:1];
    return tree;
}

%end

%ctor {
    if (IS_IOS_OR_NEWER(iOS_13_2))
        return;
#if TARGET_OS_SIMULATOR
    dlopen(realPath2(@"/usr/lib/libEmojiLibrary.dylib"), RTLD_NOW);
#endif
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    %init;
}