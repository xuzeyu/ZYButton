//
//  ZYButton.h
//  ReadBook
//
//  Created by xuzeyu on 2021/6/6.
//  Copyright © 2021 xuzy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 定义一个枚举（包含了四种类型的button）
typedef NS_ENUM(NSUInteger, ZYButtonEdgeInsetsStyle) {
    ZYButtonEdgeInsetsStyleTop, // image在上，label在下
    ZYButtonEdgeInsetsStyleLeft, // image在左，label在右
    ZYButtonEdgeInsetsStyleBottom, // image在下，label在上
    ZYButtonEdgeInsetsStyleRight // image在右，label在左
};

typedef NS_ENUM(NSUInteger, ZYButtonCornerRadiusType) {
    ZYButtonCornerRadiusTypeNone = 0,
    ZYButtonCornerRadiusTypeTopLeft,
    ZYButtonCornerRadiusTypeTopRight,
    ZYButtonCornerRadiusTypeBottomLeft,
    ZYButtonCornerRadiusTypeBottomRight,
    ZYButtonCornerRadiusTypeTopLeftAndTopRight,
    ZYButtonCornerRadiusTypeTopLeftAndBottomLeft,
    ZYButtonCornerRadiusTypeTopRightAndBottomRight,
    ZYButtonCornerRadiusTypeBottomLeftAndBottomRight,
    ZYButtonCornerRadiusTypeAll
};

@interface ZYButton : UIButton

@property (nonatomic, strong) UIImageView *zy_imageView;
@property (nonatomic, strong) UILabel *zy_titleLabel;

@property (nonatomic, assign) BOOL isAutoHighlighted;//默认增加高亮蒙版功能
@property (nonatomic, assign) BOOL zy_userInteractionEnabled; //默认为YES，NO的话忽略当前button的触摸事件，但不忽略button上面的子view事件
@property (nonatomic, copy, nullable) void(^touchDown)(ZYButton *sender);
@property (nonatomic, copy, nullable) void(^touchUpInside)(ZYButton *sender);
@property (nonatomic, copy, nullable) void(^touchUpOutside)(ZYButton *sender);

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state;

- (void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state;

/**
 * 设置button的titleLabel和imageView的布局样式，及间距
 *
 * @param style titleLabel和imageView的布局样式
 * @param space titleLabel和imageView的间距
 * @param imageSize imageView的大小
 */
- (void)layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space forState:(UIControlState)state;

- (void)layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space imageSize:(CGSize)imageSize forState:(UIControlState)state;

- (void)layoutButtonWithEdgeInsetsStyle:(ZYButtonEdgeInsetsStyle)style imageSize:(CGSize)imageSize imageConstraintEdge:(UIEdgeInsets)imageConstraintEdge labelConstraintEdge:(UIEdgeInsets)labelConstraintEdge forState:(UIControlState)state;

//只有label
- (void)layoutButtonWithLabelConstraintEdge:(UIEdgeInsets)labelConstraintEdge forState:(UIControlState)state;

//只有image
- (void)layoutButtonWithImageConstraintEdge:(UIEdgeInsets)imageConstraintEdge imageSize:(CGSize)imageSize forState:(UIControlState)state;

//设置圆角
- (void)layoutButtonWithRadiusType:(ZYButtonCornerRadiusType)radiusType cornerRadius:(CGFloat)cornerRadius;

//刷新圆角
- (void)layoutRadiusType;
@end

NS_ASSUME_NONNULL_END
