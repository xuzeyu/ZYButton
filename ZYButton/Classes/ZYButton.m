//
//  ZYButton.m
//  ReadBook
//
//  Created by xuzeyu on 2021/6/6.
//  Copyright © 2021 xuzy. All rights reserved.
//

#import "ZYButton.h"
#import "Masonry.h"

// 定义一个枚举（包含了四种类型的button）
typedef NS_ENUM(NSUInteger, ZYButtonLayoutStyle) {
    ZYButtonLayoutStyleImageAndText, //图片和文字
    ZYButtonLayoutStyleImage, //图片
    ZYButtonLayoutStyleText  //单文字
};

@interface ZYButton ()
@property (nonatomic, assign) NSUInteger zy_state;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *highlightedImage;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *highlightedTitle;
@property (nonatomic, strong) NSString *selectedTitle;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightedTitleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIColor *zy_backgroundColor;
@property (nonatomic, strong) UIColor *zy_selectedbackgroundColor;
@property (nonatomic, strong) UIColor *zy_highlightedBackgroundColor;

@property (nonatomic, strong) UIColor *zy_borderColor;
@property (nonatomic, strong) UIColor *zy_selectedBorderColor;
@property (nonatomic, strong) UIColor *zy_highlightedBorderColor;

@property (nonatomic, assign) CGFloat zy_borderWidth;
@property (nonatomic, assign) CGFloat zy_selectedBorderWidth;
@property (nonatomic, assign) CGFloat zy_highlightedBorderWidth;

@property (nonatomic, strong) UIView *zy_contentView;
@property (nonatomic, strong) UIView *zy_highlightedView; //按钮蒙版

@property (nonatomic, assign) CGSize zy_currentImageSize;
@property (nonatomic, assign) CGSize zy_imageSize;
@property (nonatomic, assign) CGSize zy_selectedImageSize;
@property (nonatomic, assign) CGSize zy_highlightedImageSize;

@property (nonatomic, assign) ZYButtonEdgeInsetsStyle zy_currentStyle;
@property (nonatomic, assign) ZYButtonEdgeInsetsStyle zy_style;
@property (nonatomic, assign) ZYButtonEdgeInsetsStyle zy_selectedStyle;
@property (nonatomic, assign) ZYButtonEdgeInsetsStyle zy_highlightedStyle;

@property (nonatomic, assign) UIEdgeInsets zy_currentImageConstraintEdge;
@property (nonatomic, assign) UIEdgeInsets zy_imageConstraintEdge;
@property (nonatomic, assign) UIEdgeInsets zy_selectedImageConstraintEdge;
@property (nonatomic, assign) UIEdgeInsets zy_highlightedImageConstraintEdge;

@property (nonatomic, assign) UIEdgeInsets zy_currentLabelConstraintEdge;
@property (nonatomic, assign) UIEdgeInsets zy_labelConstraintEdge;
@property (nonatomic, assign) UIEdgeInsets zy_selectedLabelConstraintEdge;
@property (nonatomic, assign) UIEdgeInsets zy_highlightedLabelConstraintEdge;

@property (nonatomic, assign) ZYButtonLayoutStyle zy_currentLayoutStyle;
@property (nonatomic, assign) ZYButtonLayoutStyle zy_layoutStyle;
@property (nonatomic, assign) ZYButtonLayoutStyle zy_selectedLayoutStyle;
@property (nonatomic, assign) ZYButtonLayoutStyle zy_highlightedLayoutStyle;
@property (nonatomic, assign) BOOL isExistSelectedLayoutStyle;
@property (nonatomic, assign) BOOL isExistHighlightedLayoutStyle;

@property (nonatomic, assign) BOOL isNeedLayout;
@property (nonatomic, strong) NSArray *keyValueObservingOptionNew;

@property (nonatomic, assign) ZYButtonCornerRadiusType radiusType;
@property (nonatomic, assign) CGFloat cornerRadius;
@end

@implementation ZYButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    ZYButton *button = [super buttonWithType:buttonType];
    [button initialize];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

- (void)initialize {
    if (self.zy_contentView) return;
    self.title = @"";
    self.isAutoHighlighted = NO;
    self.isNeedLayout = YES;
    self.zy_userInteractionEnabled = YES;
    
    self.zy_highlightedView = [UIView new];
    self.zy_highlightedView.hidden = YES;
    self.zy_highlightedView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2];
    self.zy_highlightedView.userInteractionEnabled = NO;
    [self addSubview:self.zy_highlightedView];
    [self.zy_highlightedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.zy_contentView = [UIView new];
    self.zy_contentView.userInteractionEnabled = NO;
    [self addSubview:self.zy_contentView];
    
    self.zy_imageView = [UIImageView new];
    [self.zy_contentView addSubview:self.zy_imageView];
    
    self.zy_titleLabel = [UILabel new];
    [self.zy_contentView addSubview:self.zy_titleLabel];

    self.keyValueObservingOptionNew = @[@"titleLabel.font", @"titleLabel.numberOfLines", @"selected", @"layer.cornerRadius"];
    for (NSInteger i = 0; i < self.keyValueObservingOptionNew.count; i++) {
        [self addObserver:self forKeyPath:self.keyValueObservingOptionNew[i] options:NSKeyValueObservingOptionNew context:nil];
    }
    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Super Function
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.title = title;
    }else if (state == UIControlStateHighlighted) {
        self.highlightedTitle = title;
    }else if (state == UIControlStateSelected) {
        self.selectedTitle = title;
    }

    self.zy_titleLabel.text = [self titleForState:self.state];
}

- (nullable NSString *)titleForState:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.highlightedTitle.length >0 ? self.highlightedTitle : self.title;
    }else if (state == UIControlStateSelected) {
        return self.selectedTitle.length >0 ? self.selectedTitle : self.title;
    }else {
        return self.title;
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.image = image;
    }else if (state == UIControlStateHighlighted) {
        self.highlightedImage = image;
    }else if (state == UIControlStateSelected) {
        self.selectedImage = image;
    }

    self.zy_imageView.image = [self imageForState:self.state];
}

- (nullable UIImage *)imageForState:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.highlightedImage ? self.highlightedImage : self.image;
    }else if (state == UIControlStateSelected) {
        return self.selectedImage ? self.selectedImage : self.image;;
    }else {
        return self.image;
    }
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.titleColor = color;
    }else if (state == UIControlStateHighlighted) {
        self.highlightedTitleColor = color;
    }else if (state == UIControlStateSelected) {
        self.selectedTitleColor = color;
    }

    self.zy_titleLabel.textColor = [self titleColorForState:self.state];
}

- (nullable UIColor *)titleColorForState:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.highlightedTitleColor ? self.highlightedTitleColor : self.titleColor;
    }else if (state == UIControlStateSelected) {
        return self.selectedTitleColor ? self.selectedTitleColor : self.titleColor;
    }else {
        return self.titleColor;
    }
}

//- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:backgroundColor];
//    _zy_backgroundColor = backgroundColor;
//}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_backgroundColor = backgroundColor;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedBackgroundColor = backgroundColor;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedbackgroundColor = backgroundColor;
    }

    self.backgroundColor = [self backgroundColor:self.state];
}

- (UIColor *)backgroundColor:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.zy_highlightedBackgroundColor ? self.zy_highlightedBackgroundColor : self.zy_backgroundColor;
    }else if (state == UIControlStateSelected) {
        return self.zy_selectedbackgroundColor ? self.zy_selectedbackgroundColor : self.zy_backgroundColor;
    }else {
        return self.zy_backgroundColor;
    }
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_borderColor = borderColor;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedBorderColor = borderColor;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedBorderColor = borderColor;
    }

    self.layer.borderColor = [self borderColor:self.state].CGColor;
}

- (UIColor *)borderColor:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.zy_highlightedBorderColor ? self.zy_highlightedBorderColor : self.zy_borderColor;
    }else if (state == UIControlStateSelected) {
        return self.zy_selectedBorderColor ? self.zy_selectedBorderColor : self.zy_borderColor;
    }else {
        return self.zy_borderColor;
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_borderWidth = borderWidth;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedBorderWidth = borderWidth;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedBorderWidth = borderWidth;
    }

    self.layer.borderWidth = [self borderWidth:self.state];
}

- (CGFloat)borderWidth:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.zy_highlightedBorderWidth ? self.zy_highlightedBorderWidth : self.zy_borderWidth;
    }else if (state == UIControlStateSelected) {
        return self.zy_selectedBorderWidth ? self.zy_selectedBorderWidth : self.zy_borderWidth;
    }else {
        return self.zy_borderWidth;
    }
}

- (void)setImageSize:(CGSize)imageSize forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_imageSize = imageSize;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedImageSize = imageSize;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedImageSize = imageSize;
    }
}

- (CGSize)imageSize:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.isExistHighlightedLayoutStyle ? self.zy_highlightedImageSize : self.zy_imageSize;
    }else if (state == UIControlStateSelected) {
        return self.isExistSelectedLayoutStyle ? self.zy_selectedImageSize : self.zy_imageSize;
    }else {
        return self.zy_imageSize;
    }
}

- (void)setStyle:(ZYButtonEdgeInsetsStyle)style forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_style = style;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedStyle = style;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedStyle = style;
    }
}

- (ZYButtonEdgeInsetsStyle)style:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.isExistHighlightedLayoutStyle ? self.zy_highlightedStyle : self.zy_style;
    }else if (state == UIControlStateSelected) {
        return self.isExistSelectedLayoutStyle ? self.zy_selectedStyle : self.zy_style;
    }else {
        return self.zy_style;
    }
}

- (void)setImageConstraintEdge:(UIEdgeInsets)imageConstraintEdge forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_imageConstraintEdge = imageConstraintEdge;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedImageConstraintEdge = imageConstraintEdge;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedImageConstraintEdge = imageConstraintEdge;
    }
}

- (UIEdgeInsets)imageConstraintEdge:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.isExistHighlightedLayoutStyle ? self.zy_highlightedImageConstraintEdge : self.zy_imageConstraintEdge;
    }else if (state == UIControlStateSelected) {
        return self.isExistSelectedLayoutStyle ? self.zy_selectedImageConstraintEdge : self.zy_imageConstraintEdge;
    }else {
        return self.zy_imageConstraintEdge;
    }
}

- (void)setLabelConstraintEdge:(UIEdgeInsets)labelConstraintEdge forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_labelConstraintEdge = labelConstraintEdge;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedLabelConstraintEdge = labelConstraintEdge;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedLabelConstraintEdge = labelConstraintEdge;
    }
}

- (UIEdgeInsets)labelConstraintEdge:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.isExistHighlightedLayoutStyle ? self.zy_highlightedLabelConstraintEdge : self.zy_labelConstraintEdge;
    }else if (state == UIControlStateSelected) {
        return self.isExistSelectedLayoutStyle ? self.zy_selectedLabelConstraintEdge : self.zy_labelConstraintEdge;
    }else {
        return self.zy_labelConstraintEdge;
    }
}

- (void)setLayoutStyle:(ZYButtonLayoutStyle)layoutStyle forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.zy_layoutStyle = layoutStyle;
    }else if (state == UIControlStateHighlighted) {
        self.zy_highlightedLayoutStyle = layoutStyle;
    }else if (state == UIControlStateSelected) {
        self.zy_selectedLayoutStyle = layoutStyle;
    }
}

- (ZYButtonLayoutStyle)layoutStyle:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return self.zy_highlightedLayoutStyle;
    }else if (state == UIControlStateSelected) {
        return self.zy_selectedLayoutStyle;
    }else {
        return self.zy_layoutStyle;
    }
}

- (void)setExistLayoutStyle:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        self.isExistHighlightedLayoutStyle = YES;
    }else if (state == UIControlStateSelected) {
        self.isExistSelectedLayoutStyle = YES;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

#pragma mark - Outsize Function
- (void)layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space forState:(UIControlState)state {
    [self layoutButtonWithEdgeInsetsStyle:style imageTitleSpace:space imageSize:CGSizeZero forState:state];
}

- (void)layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space imageSize:(CGSize)imageSize forState:(UIControlState)state {
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    if (style == ZYButtonEdgeInsetsStyleTop) {
        imageEdgeInsets.bottom = space;
    }else if (style == ZYButtonEdgeInsetsStyleLeft) {
        labelEdgeInsets.left = space;
    }else if (style == ZYButtonEdgeInsetsStyleRight) {
        labelEdgeInsets.right = space;
    }else if (style == ZYButtonEdgeInsetsStyleBottom){
        imageEdgeInsets.bottom = space;
    }
    
    [self layoutButtonWithEdgeInsetsStyle:style imageSize:imageSize imageConstraintEdge:imageEdgeInsets labelConstraintEdge:labelEdgeInsets forState:state];
}

- (void)layoutButtonWithLabelConstraintEdge:(UIEdgeInsets)labelConstraintEdge forState:(UIControlState)state {
    self.isNeedLayout = YES;
    [self setLabelConstraintEdge:labelConstraintEdge forState:state];
    [self setLayoutStyle:ZYButtonLayoutStyleText forState:state];
    [self setExistLayoutStyle:state];
}

- (void)layoutButtonWithImageConstraintEdge:(UIEdgeInsets)imageConstraintEdge imageSize:(CGSize)imageSize forState:(UIControlState)state {
    self.isNeedLayout = YES;
 
    [self setImageConstraintEdge:imageConstraintEdge forState:state];
    [self setImageSize:imageSize forState:state];
    [self setLayoutStyle:ZYButtonLayoutStyleImage forState:state];
    [self setExistLayoutStyle:state];
}

- (void)zy_layoutButtonWithLabelConstraintEdge:(UIEdgeInsets)labelConstraintEdge {
    self.zy_currentLabelConstraintEdge = labelConstraintEdge;
    [self.zy_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    if (UIEdgeInsetsEqualToEdgeInsets(labelConstraintEdge, UIEdgeInsetsZero)) {
        [self.zy_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(1);
            make.left.mas_greaterThanOrEqualTo(0);
            make.right.mas_lessThanOrEqualTo(0);
        }];
    }else {
        BOOL isCenterX = NO;
        if ((labelConstraintEdge.left == 0 && labelConstraintEdge.right != 0) || (labelConstraintEdge.left != 0 && labelConstraintEdge.right == 0)) {
            isCenterX = YES;
        }
        
        BOOL isCenterY = NO;
        if ((labelConstraintEdge.top == 0 && labelConstraintEdge.bottom != 0) || (labelConstraintEdge.top != 0 && labelConstraintEdge.bottom == 0)) {
            isCenterY = YES;
        }
        
        [self.zy_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (isCenterX) {
                make.centerX.mas_equalTo(1).offset(labelConstraintEdge.left - labelConstraintEdge.right);
            }else {
                make.left.mas_equalTo(labelConstraintEdge.left);
                make.right.mas_equalTo(-labelConstraintEdge.right);
            }
            if (isCenterY) {
                make.centerY.mas_equalTo(1).offset(labelConstraintEdge.top - labelConstraintEdge.bottom);
            }else {
                make.top.mas_equalTo(labelConstraintEdge.top);
                make.bottom.mas_equalTo(-labelConstraintEdge.bottom);
            }
            make.left.mas_greaterThanOrEqualTo(0);
            make.right.mas_lessThanOrEqualTo(0);
        }];
    }
}

- (void)zy_layoutButtonWithImageConstraintEdge:(UIEdgeInsets)imageConstraintEdge imageSize:(CGSize)imageSize {
    self.zy_currentImageConstraintEdge = imageConstraintEdge;
    self.zy_currentImageSize = imageSize;
    [self.zy_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    if (UIEdgeInsetsEqualToEdgeInsets(imageConstraintEdge, UIEdgeInsetsZero)) {
        [self.zy_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(1);
            make.size.mas_equalTo(imageSize);
        }];
    }else {
        [self.zy_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (CGSizeEqualToSize(CGSizeZero, imageSize)) {
                make.edges.mas_equalTo(imageConstraintEdge);
            }else {
                make.size.mas_equalTo(imageSize);
                make.centerX.mas_equalTo(1).offset(imageConstraintEdge.left - imageConstraintEdge.right);
                make.centerY.mas_equalTo(1).offset(imageConstraintEdge.top - imageConstraintEdge.bottom);
            }
        }];
    }
}

- (void)layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style imageSize:(CGSize)imageSize imageConstraintEdge:(UIEdgeInsets)imageConstraintEdge labelConstraintEdge:(UIEdgeInsets)labelConstraintEdge forState:(UIControlState)state {
    self.isNeedLayout = YES;
    
    [self setLayoutStyle:ZYButtonLayoutStyleImageAndText forState:state];
    [self setStyle:style forState:state];
    [self setImageSize:imageSize forState:state];
    [self setImageConstraintEdge:imageConstraintEdge forState:state];
    [self setLabelConstraintEdge:labelConstraintEdge forState:state];
    
    [self setExistLayoutStyle:state];
}

- (void)zy_layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style
                                 imageSize:(CGSize)imageSize imageConstraintEdge:(UIEdgeInsets)imageConstraintEdge labelConstraintEdge:(UIEdgeInsets)labelConstraintEdge {
    self.zy_currentStyle = style;
    self.zy_currentImageSize = imageSize;
    self.zy_currentImageConstraintEdge = imageConstraintEdge;
    self.zy_currentLabelConstraintEdge = labelConstraintEdge;
    
    CGFloat space = 0;
    if (style == ZYButtonEdgeInsetsStyleTop) {
        space = MAX(imageConstraintEdge.bottom, labelConstraintEdge.top);
    }else if (style == ZYButtonEdgeInsetsStyleLeft) {
        space = MAX(imageConstraintEdge.right, labelConstraintEdge.left);
    }else if (style == ZYButtonEdgeInsetsStyleRight) {
        space = MAX(imageConstraintEdge.left, labelConstraintEdge.right);
    }else if (style == ZYButtonEdgeInsetsStyleBottom){
        space = MAX(imageConstraintEdge.top, labelConstraintEdge.bottom);
    }
    
    /**
     * 知识点：titleEdgeInsets是title相对于其上下左右的inset，跟tableView的contentInset是类似的，
     * 如果只有title，那它上下左右都是相对于button的，image也是一样；
     * 如果同时有image和label，那这时候image的上左下是相对于button，右边是相对于label的；title的上右下是相对于button，左边是相对于image的。
     */
    
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.image.size.width;
    CGFloat imageHeight = self.image.size.height;
    
    if (!CGSizeEqualToSize(CGSizeZero, imageSize)) {
        if (imageSize.width == 0 && imageSize.height > 0) {
            imageHeight = imageSize.height;
            imageWith = imageSize.height/self.image.size.height * self.image.size.width;
        }else if (imageSize.height == 0 && imageSize.width > 0) {
            imageWith = imageSize.width;
            imageHeight = imageSize.width/self.image.size.width * self.image.size.height;
        }else {
            imageWith = imageSize.width;
            imageHeight = imageSize.height;
        }
    }
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    /**
     ZYButtonEdgeInsetsStyleTop, // image在上，label在下
     ZYButtonEdgeInsetsStyleLeft, // image在左，label在右
     ZYButtonEdgeInsetsStyleBottom, // image在下，label在上
     ZYButtonEdgeInsetsStyleRight // image在右，label在左
     */

    switch (style) {
        case ZYButtonEdgeInsetsStyleTop://上image 下label
        {
            [self.zy_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (imageConstraintEdge.top > 0 && labelConstraintEdge.bottom > 0) {
                    make.top.mas_equalTo(imageConstraintEdge.top);
                    make.bottom.mas_equalTo(-labelConstraintEdge.bottom);
                }else if (imageConstraintEdge.top > 0 && labelConstraintEdge.bottom == 0) {
                    make.top.mas_equalTo(imageConstraintEdge.top);
                }else if (imageConstraintEdge.top == 0 && labelConstraintEdge.bottom > 0) {
                    make.bottom.mas_equalTo(-labelConstraintEdge.bottom);
                }else {
                    if (imageConstraintEdge.top < 0 && labelConstraintEdge.bottom == 0) {
                        make.centerY.mas_equalTo(1).offset(imageConstraintEdge.top);
                    }else if (imageConstraintEdge.top == 0 && labelConstraintEdge.bottom < 0){
                        make.centerY.mas_equalTo(1).offset(-labelConstraintEdge.bottom);
                    }else {
                        make.centerY.mas_equalTo(1);
                    }
                    make.top.mas_greaterThanOrEqualTo(0);
                    make.bottom.mas_lessThanOrEqualTo(0);
                }
                make.left.right.mas_equalTo(0);
            }];
            
            if (imageConstraintEdge.top < 0 && labelConstraintEdge.bottom == 0) {
                space = labelConstraintEdge.top;
            }else if (imageConstraintEdge.top == 0 && labelConstraintEdge.bottom < 0){
                space = imageConstraintEdge.bottom;
            }else if (imageConstraintEdge.top < 0 && labelConstraintEdge.bottom < 0) {
                space = fabs(fabs(imageConstraintEdge.top) - fabs(labelConstraintEdge.bottom));
            }
            
            [self.zy_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (imageConstraintEdge.left > 0 && imageConstraintEdge.right > 0) {
                    make.left.mas_equalTo(imageConstraintEdge.left);
                    make.right.mas_equalTo(-imageConstraintEdge.right);
                    if (!CGSizeEqualToSize(CGSizeZero, imageSize)) {
                        make.height.mas_equalTo(imageHeight);
                    }
                }else {
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.centerX.mas_equalTo(1);
                }
                make.top.mas_equalTo(0);
            }];
            
            if (labelConstraintEdge.left == 0 && labelConstraintEdge.right == 0) {
                self.zy_titleLabel.textAlignment = NSTextAlignmentCenter;
            }else if(labelConstraintEdge.left == 0 && labelConstraintEdge.right > 0) {
                self.zy_titleLabel.textAlignment = NSTextAlignmentRight;
            }else {
                self.zy_titleLabel.textAlignment = NSTextAlignmentLeft;
            }
            
            [self.zy_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.zy_imageView.mas_bottom).offset(space);
                make.left.mas_equalTo(labelConstraintEdge.left);
                make.right.mas_equalTo(-labelConstraintEdge.right);
                make.bottom.mas_equalTo(0);
            }];
        }
            break;
        case ZYButtonEdgeInsetsStyleLeft://左image 右label
        {
            [self.zy_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (imageConstraintEdge.left > 0 && labelConstraintEdge.right > 0) {
                    make.left.mas_equalTo(imageConstraintEdge.left);
                    make.right.mas_equalTo(-labelConstraintEdge.right);
                }else if (imageConstraintEdge.left > 0 && labelConstraintEdge.right == 0) {
                    make.left.mas_equalTo(imageConstraintEdge.left);
                }else if (imageConstraintEdge.left == 0 && labelConstraintEdge.right > 0) {
                    make.right.mas_equalTo(-labelConstraintEdge.right);
                }else {
                    if (imageConstraintEdge.left < 0 && labelConstraintEdge.right == 0) {
                        make.centerX.mas_equalTo(1).offset(imageConstraintEdge.left);
                    }else if (imageConstraintEdge.left == 0 && labelConstraintEdge.right < 0){
                        make.centerX.mas_equalTo(1).offset(-labelConstraintEdge.right);
                    }else {
                        make.centerX.mas_equalTo(1);
                    }
                    make.left.mas_greaterThanOrEqualTo(0);
                    make.right.mas_lessThanOrEqualTo(0);
                }
                make.top.bottom.mas_equalTo(0);
            }];
            
            if (imageConstraintEdge.left < 0 && labelConstraintEdge.right == 0) {
                space = labelConstraintEdge.left;
            }else if (imageConstraintEdge.left == 0 && labelConstraintEdge.right < 0){
                space = imageConstraintEdge.right;
            }else if (imageConstraintEdge.left < 0 && labelConstraintEdge.right < 0) {
                space = fabs(fabs(imageConstraintEdge.left) - fabs(labelConstraintEdge.right));
            }
            
            [self.zy_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (imageConstraintEdge.top > 0 && imageConstraintEdge.bottom > 0) {
                    make.top.mas_equalTo(imageConstraintEdge.top);
                    make.bottom.mas_equalTo(-imageConstraintEdge.bottom);
                    if (!CGSizeEqualToSize(CGSizeZero, imageSize)) {
                        make.width.mas_equalTo(imageWith);
                    }
                }else if (imageConstraintEdge.top > 0 && imageConstraintEdge.bottom == 0){
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.top.mas_equalTo(imageConstraintEdge.top);
                }else if (imageConstraintEdge.top == 0 && imageConstraintEdge.bottom > 0){
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.bottom.mas_equalTo(-imageConstraintEdge.bottom);
                }else {
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.centerY.mas_equalTo(1).offset(imageConstraintEdge.top + imageConstraintEdge.bottom);
                }
                make.left.mas_equalTo(0);
            }];
            
            if(labelConstraintEdge.left == 0 && labelConstraintEdge.right > 0) {
                self.zy_titleLabel.textAlignment = NSTextAlignmentRight;
            }else {
                self.zy_titleLabel.textAlignment = NSTextAlignmentLeft;
            }
            
            [self.zy_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.zy_imageView.mas_right).offset(space);
                make.top.mas_equalTo(labelConstraintEdge.top);
                make.bottom.mas_equalTo(-labelConstraintEdge.bottom);
                make.right.mas_equalTo(0);
            }];
        }
            break;
        case ZYButtonEdgeInsetsStyleBottom://上label 下image
        {
            [self.zy_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (imageConstraintEdge.top > 0 && labelConstraintEdge.bottom > 0) {
                    make.top.mas_equalTo(labelConstraintEdge.top);
                    make.bottom.mas_equalTo(-imageConstraintEdge.bottom);
                }else if (labelConstraintEdge.top > 0 && imageConstraintEdge.bottom == 0) {
                    make.top.mas_equalTo(labelConstraintEdge.top);
                }else if (labelConstraintEdge.top == 0 && imageConstraintEdge.bottom > 0) {
                    make.bottom.mas_equalTo(-imageConstraintEdge.bottom);
                }else {
                    if (labelConstraintEdge.top < 0 && imageConstraintEdge.bottom == 0) {
                        make.centerY.mas_equalTo(1).offset(labelConstraintEdge.top);
                    }else if (labelConstraintEdge.top == 0 && imageConstraintEdge.bottom < 0){
                        make.centerY.mas_equalTo(1).offset(-imageConstraintEdge.bottom);
                    }else {
                        make.centerY.mas_equalTo(1);
                    }
                    make.top.mas_greaterThanOrEqualTo(0);
                    make.bottom.mas_lessThanOrEqualTo(0);
                }
                make.left.right.mas_equalTo(0);
            }];
            
            if (labelConstraintEdge.top < 0 && imageConstraintEdge.bottom == 0) {
                space = imageConstraintEdge.top;
            }else if (labelConstraintEdge.top == 0 && imageConstraintEdge.bottom < 0){
                space = labelConstraintEdge.bottom;
            }else if (labelConstraintEdge.top < 0 && imageConstraintEdge.bottom < 0) {
                space = fabs(fabs(labelConstraintEdge.top) - fabs(imageConstraintEdge.bottom));
            }
            
            if (labelConstraintEdge.left == 0 && labelConstraintEdge.right == 0) {
                self.zy_titleLabel.textAlignment = NSTextAlignmentCenter;
            }else if(labelConstraintEdge.left == 0 && labelConstraintEdge.right > 0) {
                self.zy_titleLabel.textAlignment = NSTextAlignmentRight;
            }else {
                self.zy_titleLabel.textAlignment = NSTextAlignmentLeft;
            }
            
            [self.zy_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.mas_equalTo(labelConstraintEdge.left);
                make.right.mas_equalTo(-labelConstraintEdge.right);
            }];
            
            [self.zy_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.zy_titleLabel.mas_bottom).offset(space);
                if (imageConstraintEdge.left > 0 && imageConstraintEdge.right > 0) {
                    make.left.mas_equalTo(imageConstraintEdge.left);
                    make.right.mas_equalTo(-imageConstraintEdge.right);
                    if (!CGSizeEqualToSize(CGSizeZero, imageSize)) {
                        make.height.mas_equalTo(imageHeight);
                    }
                }else {
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                }
                make.bottom.mas_equalTo(0);
            }];
        }
            break;
        case ZYButtonEdgeInsetsStyleRight://左label 右image
        {
            [self.zy_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (labelConstraintEdge.left > 0 && imageConstraintEdge.right > 0) {
                    make.left.mas_equalTo(labelConstraintEdge.left);
                    make.right.mas_equalTo(-imageConstraintEdge.right);
                }else if (labelConstraintEdge.left > 0 && imageConstraintEdge.right == 0) {
                    make.left.mas_equalTo(labelConstraintEdge.left);
                }else if (labelConstraintEdge.left == 0 && imageConstraintEdge.right > 0) {
                    make.right.mas_equalTo(-imageConstraintEdge.right);
                }else {
                    if (labelConstraintEdge.left < 0 && imageConstraintEdge.right == 0) {
                        make.centerX.mas_equalTo(1).offset(labelConstraintEdge.left);
                    }else if (labelConstraintEdge.left == 0 && imageConstraintEdge.right < 0){
                        make.centerX.mas_equalTo(1).offset(-imageConstraintEdge.right);
                    }else {
                        make.centerX.mas_equalTo(1);
                    }
                    make.left.mas_greaterThanOrEqualTo(0);
                    make.right.mas_lessThanOrEqualTo(0);
                }
                make.top.bottom.mas_equalTo(0);
            }];
            
            if (labelConstraintEdge.left < 0 && imageConstraintEdge.right == 0) {
                space = imageConstraintEdge.left;
            }else if (labelConstraintEdge.left == 0 && imageConstraintEdge.right < 0){
                space = labelConstraintEdge.right;
            }else if (labelConstraintEdge.left < 0 && imageConstraintEdge.right < 0) {
                space = fabs(fabs(labelConstraintEdge.left) - fabs(imageConstraintEdge.right));
            }
            
            [self.zy_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(labelConstraintEdge.top);
                make.bottom.mas_equalTo(-labelConstraintEdge.bottom);
            }];
            
            [self.zy_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.zy_titleLabel.mas_right).offset(space);
                if (imageConstraintEdge.top > 0 && imageConstraintEdge.bottom > 0) {
                    make.top.mas_equalTo(imageConstraintEdge.top);
                    make.bottom.mas_equalTo(-imageConstraintEdge.bottom);
                    if (!CGSizeEqualToSize(CGSizeZero, imageSize)) {
                        make.width.mas_equalTo(imageWith);
                    }
                }else if (imageConstraintEdge.top > 0 && imageConstraintEdge.bottom == 0){
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.top.mas_equalTo(imageConstraintEdge.top);
                }else if (imageConstraintEdge.top == 0 && imageConstraintEdge.bottom > 0){
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.bottom.mas_equalTo(-imageConstraintEdge.bottom);
                }else {
                    make.size.mas_equalTo(CGSizeMake(imageWith, imageHeight));
                    make.centerY.mas_equalTo(1).offset(imageConstraintEdge.top + imageConstraintEdge.bottom);
                }
                make.right.mas_equalTo(0);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)layoutButtonWithRadiusType:(ZYButtonCornerRadiusType)radiusType cornerRadius:(CGFloat)cornerRadius {
    self.radiusType = radiusType;
    self.cornerRadius = cornerRadius;
}

#pragma mark - Action
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context
{
    if (![change isKindOfClass:[NSDictionary class]]) {
        return;
    }
    if ([@"titleLabel.font" isEqualToString:keyPath]) {
        UIFont *font = [change objectForKey:NSKeyValueChangeNewKey];
        if (font && [font isKindOfClass:[UIFont class]]) {
            self.zy_titleLabel.font = font;
        }
    }else if ([@"titleLabel.numberOfLines" isEqualToString:keyPath]) {
        NSNumber *number = [change objectForKey:NSKeyValueChangeNewKey];
        if (number && [number isKindOfClass:[NSNumber class]]) {
            self.zy_titleLabel.numberOfLines = number.integerValue;
        }
    }else if([@"selected" isEqualToString:keyPath]) {
        NSNumber *number = [change objectForKey:NSKeyValueChangeNewKey];
        if (number && [number isKindOfClass:[NSNumber class]]) {
            [self refreshWithState:number.boolValue ? UIControlStateSelected : UIControlStateNormal];
        }
    }else if([@"layer.cornerRadius" isEqualToString:keyPath]) {
        NSNumber *number = [change objectForKey:NSKeyValueChangeNewKey];
        if (number && [number isKindOfClass:[NSNumber class]]) {
            self.zy_highlightedView.layer.cornerRadius = [number floatValue];
        }
    }
}

#pragma mark - Acion
- (void)touchDown:(ZYButton *)sender {
    if (!sender.selected && self.isAutoHighlighted) {
        [self refreshWithState:UIControlStateHighlighted];
        self.zy_highlightedView.hidden = NO;
    }
    if (self.touchDown) {
        self.touchDown(sender);
    }
}

- (void)touchUpInside:(ZYButton *)sender {
    self.zy_highlightedView.hidden = YES;
    if (self.touchUpInside) {
        self.touchUpInside(sender);
    }
    if (self.touchUp) {
        self.touchUp(sender);
    }
}

- (void)touchUpOutside:(ZYButton *)sender {
    self.zy_highlightedView.hidden = YES;
    if (self.touchUpOutside) {
        self.touchUpOutside(sender);
    }
    if (self.touchUp) {
        self.touchUp(sender);
    }
}

#pragma mark - Other
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self && !self.zy_userInteractionEnabled) {
        return nil;
    }
    return hitView;
}

- (void)refreshWithState:(UIControlState)state {
    self.zy_state = state;
    self.zy_titleLabel.text = [self titleForState:state];
    self.zy_titleLabel.textColor = [self titleColorForState:state];
    self.zy_imageView.image = [self imageForState:state];
    self.backgroundColor = [self backgroundColor:state];
    self.layer.borderColor = [self borderColor:state].CGColor;
    self.layer.borderWidth = [self borderWidth:state];
    
    if ((state == UIControlStateHighlighted && !self.isExistHighlightedLayoutStyle) || (state == UIControlStateSelected && !self.isExistSelectedLayoutStyle)) {
        return;
    }
    //判断是否需要重新布局
    if (self.zy_currentLayoutStyle != [self layoutStyle:state]) {
        self.isNeedLayout = YES;
        [self layoutIfNeeded];
    }else if (self.zy_currentStyle != [self style:state] || !CGSizeEqualToSize(self.zy_imageSize, [self imageSize:state]) || !UIEdgeInsetsEqualToEdgeInsets(self.zy_currentImageConstraintEdge, [self imageConstraintEdge:state]) || !UIEdgeInsetsEqualToEdgeInsets(self.zy_currentLabelConstraintEdge, [self labelConstraintEdge:state])){
        self.isNeedLayout = YES;
        [self layoutIfNeeded];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isNeedLayout) {
        self.isNeedLayout = NO;
        
        //清除旧的约束
        [self.zy_contentView removeFromSuperview];
        [self addSubview:self.zy_contentView];
        
        //根据状态重新布局
        NSUInteger state = self.zy_state;
        ZYButtonLayoutStyle layoutStyle = [self layoutStyle:state];
        if (layoutStyle == ZYButtonLayoutStyleImage) {
            self.zy_titleLabel.hidden = YES;
            self.zy_imageView.hidden = NO;
            [self zy_layoutButtonWithImageConstraintEdge:[self imageConstraintEdge:state] imageSize:[self imageSize:state]];
        }else if (layoutStyle == ZYButtonLayoutStyleText) {
            self.zy_titleLabel.hidden = NO;
            self.zy_imageView.hidden = YES;
            [self zy_layoutButtonWithLabelConstraintEdge:[self labelConstraintEdge:state]];
        }else {
            self.zy_titleLabel.hidden = NO;
            self.zy_imageView.hidden = NO;
            [self zy_layoutButtonWithEdgeInsetsStyle:[self style:state] imageSize:[self imageSize:state] imageConstraintEdge:[self imageConstraintEdge:state] labelConstraintEdge:[self labelConstraintEdge:state]];
        }
    }
    [self layoutRadiusType];
}

- (void)layoutRadiusType {
    if (self.radiusType != ZYButtonCornerRadiusTypeNone) {
        if (self.frame.size.width > 0) {
            UIRectCorner corner;
            if (self.radiusType == ZYButtonCornerRadiusTypeTopLeft) {
                corner = UIRectCornerTopLeft;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeTopRight) {
                corner = UIRectCornerTopRight;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeBottomLeft) {
                corner = UIRectCornerBottomLeft;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeBottomRight) {
                corner = UIRectCornerBottomRight;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeTopLeftAndTopRight) {
                corner = UIRectCornerTopLeft | UIRectCornerTopRight;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeTopLeftAndBottomLeft) {
                corner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeTopRightAndBottomRight) {
                corner = UIRectCornerTopRight | UIRectCornerBottomRight;
            }else if (self.radiusType == ZYButtonCornerRadiusTypeBottomLeftAndBottomRight) {
                corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }else {
                corner = UIRectCornerAllCorners;
            }
            UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
            
            CAShapeLayer * maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            self.layer.mask = maskLayer;
        }
    }else {
        self.layer.mask = nil;
    }
}

- (void)dealloc {
    for (NSInteger i = 0; i < self.keyValueObservingOptionNew.count; i++) {
        [self removeObserver:self forKeyPath:self.keyValueObservingOptionNew[i] context:nil];
    }
}

@end

