#import "../PSHeader/Misc.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import <theos/IOSMacros.h>
#import <version.h>
#import <dlfcn.h>

BOOL overrideSkinTone = NO;

%hook EMFEmojiToken

- (BOOL)supportsSkinToneVariants {
    return overrideSkinTone && [PSEmojiUtilities isCoupleMultiSkinToneEmoji:self.string] ? YES : %orig;
}

- (NSArray <NSString *> *)_skinToneVariantStrings {
    NSString *emojiString = self.string;
    if (![PSEmojiUtilities isCoupleMultiSkinToneEmoji:emojiString])
        return %orig;
    NSMutableArray <NSString *> *variants = [PSEmojiUtilities skinToneVariants:emojiString];
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
    if ([PSEmojiUtilities isCoupleMultiSkinToneEmoji:key.displayString])
        return;
    %orig;
}

%end

%hook UIKBRenderFactoryiPad

- (NSInteger)rowLimitForKey:(UIKBTree *)tree {
    if ([tree.name isEqualToString:@"EmojiPopupKey"] && [PSEmojiUtilities isCoupleMultiSkinToneEmoji:tree.displayString])
        return 6;
    return %orig;
}

%end

%hook UIKBRenderFactoryiPhone

- (void)_configureTraitsForPopupStyle:(id)style withKey:(UIKBTree *)key onKeyplane:(id)keyplane {
    BOOL isEmoji = [key.name isEqualToString:@"EmojiPopupKey"] && [PSEmojiUtilities isCoupleMultiSkinToneEmoji:key.displayString];
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
    if ([PSEmojiUtilities isCoupleMultiSkinToneEmoji:tree.displayString])
        [tree.subtrees removeObjectAtIndex:1];
    return tree;
}

%end

%ctor {
    if (IS_IOS_OR_NEWER(iOS_13_2))
        return;
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    %init;
}