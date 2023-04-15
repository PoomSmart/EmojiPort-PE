#import <PSHeader/iOSVersions.h>
#import <PSHeader/Misc.h>
#import <dlfcn.h>
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../EmojiLibrary/EmojiUIKit/EmojiUIKit.h"

Class PSEmojiUtilitiesClass;

%hook UIKeyboardEmojiFamilyConfigurationView

%property (retain, nonatomic) NSArray *variantDisplayRows;

%new
- (NSUInteger)_silhouetteFromCurrentSelections {
    NSMutableArray *indices = [self selectedVariantIndices];
    NSInteger first = [[indices firstObject] integerValue];
    NSInteger last = [[indices lastObject] integerValue];
    NSUInteger noFirst = first == NSNotFound;
    NSUInteger result = noFirst + 2;
    return last != NSNotFound ? noFirst : result;
}

- (void)_updatePreviewWellForCurrentSelection {
    NSArray *configuration = [self _currentlySelectedSkinToneConfiguration];
    NSUInteger silhouette = [self _silhouetteFromCurrentSelections];
    NSString *representation = [PSEmojiUtilitiesClass multiPersonStringForString:self.baseEmojiString skinToneVariantSpecifier:configuration];
    UIKeyboardEmojiWellView *wellView = self.configuredWellView;
    [wellView setStringRepresentation:representation silhouette:silhouette];
}

- (void)_configureSkinToneVariantSpecifiersForBaseString:(NSString *)baseEmojiString {
    NSArray <NSArray <NSString *> *> *rows = [PSEmojiUtilitiesClass skinToneChooserVariantsForString:baseEmojiString];
    NSMutableArray <NSMutableArray <NSString *> *> *array = [NSMutableArray array];
    for (NSArray <NSString *> *row in rows) {
        NSMutableArray *brray = [NSMutableArray array];
        for (NSString *variant in row) {
            NSArray <NSString *> *specifiers = [PSEmojiUtilitiesClass skinToneSpecifiersForString:variant];
            NSString *specifier = [specifiers firstObject];
            [brray addObject:@[specifier, specifier]];
        }
        [array addObject:brray];
    }
    self.baseEmojiString = baseEmojiString;
    self.skinToneVariantRows = array;
    self.variantDisplayRows = [PSEmojiUtilitiesClass coupleSkinToneChooserVariantsForString:baseEmojiString];
    NSMutableArray *indices = [NSMutableArray array];
    for (int i = 0; i < array.count; ++i) {
        [indices addObject:@(NSNotFound)];
    }
    [self setValue:indices forKey:@"_selectedVariantIndices"];
    [self _configureFamilyMemberWellStackViews];
}

- (void)_configureFamilyMemberWellStackViews {
    if (self.baseEmojiString) {
        NSInteger section = 0;
        Class UIKeyboardEmojiWellViewClass = %c(UIKeyboardEmojiWellView);
        for (NSArray <NSString *> *row in self.variantDisplayRows) {
            __block NSMutableArray <UIKeyboardEmojiWellView *> *subviews = [NSMutableArray array];
            [row enumerateObjectsUsingBlock:^(NSString *item, NSUInteger idx, BOOL *stop) {
                UIKeyboardEmojiWellView *wellView = [[UIKeyboardEmojiWellViewClass alloc] initWithFrame:CGRectZero];
                UIColor *color = [[self class] _selectionAndSeparatorColorForDarkMode:self.usesDarkStyle];
                wellView.selectionBackgroundColor = color;
                [wellView setStringRepresentation:item silhouette:(section == 0) + 1];
                [subviews addObject:wellView];
                wellView.associatedIndexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            }];
            UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:subviews];
            [[stack.heightAnchor constraintEqualToConstant:50.0] setActive:YES];
            [stack setContentCompressionResistancePriority:999.0 forAxis:UILayoutConstraintAxisVertical];
            stack.axis = UILayoutConstraintAxisHorizontal;
            stack.distribution = UIStackViewDistributionFillEqually;
            [[self familyMemberStackViews] addObject:stack];
            [self addSubview:stack];
            ++section;
        }
    }
    self.neutralWellView.stringRepresentation = self.baseEmojiString;
    [self _updatePreviewWellForCurrentSelection];
}

%end

%hook UIKeyboardEmojiWellView

%new
- (void)setStringRepresentation:(NSString *)representation silhouette:(NSUInteger)silhouette {
    [self setValue:representation forKey:@"_stringRepresentation"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *font = self.labelFont;
    label.font = [self fontUsingSilhouette:silhouette size:font.pointSize];
    label.text = representation;
    label.textAlignment = NSTextAlignmentCenter;
    self.wellContentView = label;
}

%new
- (UIFont *)fontUsingSilhouette:(NSUInteger)silhouette size:(CGFloat)size {
    NSArray <NSDictionary *> *arrayFontAttributes = nil;
    if (silhouette == 1) {
        arrayFontAttributes = @[
            @{
                UIFontFeatureTypeIdentifierKey: @(701),
                UIFontFeatureSelectorIdentifierKey: @(100)
            }
        ];
    } else if (silhouette == 2) {
        arrayFontAttributes = @[
            @{
                UIFontFeatureTypeIdentifierKey: @(701),
                UIFontFeatureSelectorIdentifierKey: @(200)
            }
        ];
    } else if (silhouette == 3) {
        arrayFontAttributes = @[
            @{
                UIFontFeatureTypeIdentifierKey: @(701),
                UIFontFeatureSelectorIdentifierKey: @(100)
            },
            @{
                UIFontFeatureTypeIdentifierKey: @(701),
                UIFontFeatureSelectorIdentifierKey: @(200)
            }
        ];
    }
    if (arrayFontAttributes) {
        UIFontDescriptor *descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
            UIFontDescriptorFeatureSettingsAttribute: arrayFontAttributes,
            UIFontDescriptorNameAttribute: @"AppleColorEmoji"
        }];
        return [UIFont fontWithDescriptor:descriptor size:size];
    }
    return [UIFont fontWithName:@"AppleColorEmoji" size:size];
}

%end

%ctor {
    if (!IS_IOS_BETWEEN_EEX(iOS_13_2, iOS_14_5))
        return;
    dlopen(realPath2(@"/usr/lib/libEmojiLibrary.dylib"), RTLD_NOW);
    PSEmojiUtilitiesClass = %c(PSEmojiUtilities);
    %init;
}