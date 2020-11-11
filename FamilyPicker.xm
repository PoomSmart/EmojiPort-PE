#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import <theos/IOSMacros.h>

BOOL overrideSkinTone = NO;

%hook EMFEmojiToken

- (BOOL)supportsSkinToneVariants {
    return overrideSkinTone && [PSEmojiUtilities isCoupleMultiSkinToneEmoji:self.string] ? YES : %orig;
}

- (NSArray <NSString *> *)_skinToneVariantStrings {
    NSString *emojiString = self.string;
    NSMutableArray *variants = [PSEmojiUtilities coupleSkinToneVariants:emojiString];
    if (variants) {
        if (!IS_IPAD) {
            [variants insertObject:emojiString atIndex:0];
            return variants;
        }
        for (int i = 20; i > 0; i -= 5)
            [variants insertObject:@"" atIndex:i];
        [variants insertObject:emojiString atIndex:0];
        NSMutableArray *trueVariants = [NSMutableArray array];
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

%group UIKBRect

void (*UIKBRectsInit_Wildcat)(void *, id, UIKBTree *, id) = NULL;
%hookf(void, UIKBRectsInit_Wildcat, void *arg0, id arg1, UIKBTree *key, id state) {
    BOOL isEmoji = [key.name isEqualToString:@"EmojiPopupKey"] && [PSEmojiUtilities isCoupleMultiSkinToneEmoji:key.displayString];
    if (isEmoji)
        key.name = @"EmojiPopupKey2";
    %orig(arg0, arg1, key, state);
    if (isEmoji)
        key.name = @"EmojiPopupKey";
}

%end

%ctor {
    if (IS_IOS_OR_NEWER(iOS_13_2))
        return;
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    MSImageRef ref = MSGetImageByName(IS_IOS_OR_NEWER(iOS_12_0) ? "/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore" : "/System/Library/Frameworks/UIKit.framework/UIKit");
    UIKBRectsInit_Wildcat = (void (*)(void *, id, UIKBTree *, id))_PSFindSymbolCallable(ref, "_UIKBRectsInit_Wildcat");
    if (UIKBRectsInit_Wildcat) {
        %init(UIKBRect);
    }
    %init;
}