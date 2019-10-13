#import "../PS.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/Header.h"
#import "../libsubstitrate/substitrate.h"

BOOL isCoupleEmoji(NSString *emojiString) {
    return [[PSEmojiUtilities CoupleMultiSkinToneEmoji] indexOfObject:emojiString] != NSNotFound;
}

%hook EMFEmojiToken

// FF, MM, FM

- (BOOL)supportsSkinToneVariants {
    return isCoupleEmoji(self.string) ? YES : %orig;
}

- (NSArray <NSString *> *)_skinToneVariantStrings {
    NSString *emojiString = self.string;
    NSUInteger type = [[PSEmojiUtilities CoupleMultiSkinToneEmoji] indexOfObject:emojiString];
    if (type != NSNotFound) {
        NSMutableArray *variants = [NSMutableArray array];
        BOOL first = YES;
        BOOL ipad = IS_IPAD;
        for (NSString *leftSkin in [PSEmojiUtilities skinModifiers]) {
            if (first || ipad)
                [variants addObject:first ? emojiString : @""];
            first = NO;
            for (NSString *rightSkin in [PSEmojiUtilities skinModifiers]) {
                switch (type) {
                    case 0:
                        [variants addObject:[NSString stringWithFormat:@"👩%@‍🤝‍👩%@", leftSkin, rightSkin]];
                        break;
                    case 1:
                        [variants addObject:[NSString stringWithFormat:@"👨%@‍🤝‍👨%@", leftSkin, rightSkin]];
                        break;
                    case 2:
                        [variants addObject:[NSString stringWithFormat:@"👩%@‍🤝‍👨%@", leftSkin, rightSkin]];
                        break;
                }
            }
        }
        if (!ipad)
            return variants;
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
    if (isCoupleEmoji(key.displayString))
        return;
    %orig;
}

%end

%hook UIKBRenderFactoryiPad

- (NSInteger)rowLimitForKey:(UIKBTree *)tree {
    if ([tree.name isEqualToString:@"EmojiPopupKey"] && isCoupleEmoji(tree.displayString))
        return 6;
    return %orig;
}

%end

%hook UIKeyboardEmojiCollectionInputView

- (UIKBTree *)subTreeHitTest:(CGPoint)point {
    UIKBTree *tree = %orig;
    if (isCoupleEmoji(tree.displayString))
        [tree.subtrees removeObjectAtIndex:1];
    return tree;
}

%end

void (*_UIKBRectsInit_Wildcat)(void *, id, UIKBTree *, id);
void UIKBRectsInit_Wildcat(void *arg0, id arg1, UIKBTree *key, id state) {
    BOOL isEmoji = [key.name isEqualToString:@"EmojiPopupKey"] && isCoupleEmoji(key.displayString);
    if (isEmoji)
        key.name = @"EmojiPopupKey2";
    _UIKBRectsInit_Wildcat(arg0, arg1, key, state);
    if (isEmoji)
        key.name = @"EmojiPopupKey";
}

%ctor {
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/EmojiFoundation.framework/EmojiFoundation"), RTLD_NOW);
    const char *path = isiOS12Up ? "/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore" : "/System/Library/Frameworks/UIKit.framework/UIKit";
    _PSHookFunctionCompat(path, "_UIKBRectsInit_Wildcat", UIKBRectsInit_Wildcat);
    %init;
}