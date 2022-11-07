# ZYButton

## 介绍
原生UIButton 图片和文字布局是使用contentEdgeInsets和imageEdgeInsets参数设置，需要计算文字和图片的上下内边距，不好计算，不好维护。
ZYButton 是对 UIButton的封装库，采用UIButton上面添加UILabel和UIImagevView的方式来实现原生contentEdgeInsets和imageEdgeInsets的功能布局，使用维护简单，功能丰富。支持自定义UIImagevView和UILabel的四边间距，UIImagevView图片自定义大小，还支持设置各种按钮状态背景颜色，边框线等

## 如何导入
```
pod 'ZYButton'
```

## 如何使用
```objc
ZYButton *button = [ZYButton buttonWithType:UIButtonTypeCustom];

//设置Normal状态背景颜色
[button setBackgroundColor:[UIColor redColor] forState:UIControlStateNormal]; 

//设置Normal状态边线
[button setBorderColor:[UIColor redColor] forState:UIControlStateNormal]; 

//设置Normal状态边线厚度
[button setBorderWidth:1 forState:UIControlStateNormal]; 

//设置Normal状态下，左图片右文字布局，间距为8pt
[button layoutButtonWithEdgeInsetsStyle:ZYButtonEdgeInsetsStyleLeft imageTitleSpace:8 forState:UIControlStateNormal]; 

//设置Normal状态下，左图片右文字布局，间距为8pt，图片大小为12pt 12pt
[button layoutButtonWithEdgeInsetsStyle:ZYButtonEdgeInsetsStyleLeft imageTitleSpace:8 imageSize:CGSizeMake(12, 12) forState:UIControlStateNormal]; 

//设置Normal状态下，左图片右文字布局，图片大小为12pt 12pt,间距为8pt
[button layoutButtonWithEdgeInsetsStyle:ZYButtonEdgeInsetsStyleLeft imageSize:CGSizeMake(12, 12) imageConstraintEdge:UIEdgeInsetsMake(0, 0, 0, 8) labelConstraintEdge:UIEdgeInsetsMake(0, 0, 0, 0) forState:UIControlStateNormal]; 

//设置Normal状态下，左图片右文字布局，图片大小为12pt 12pt,间距为8pt，整体居中向左偏移8pt
[button layoutButtonWithEdgeInsetsStyle:ZYButtonEdgeInsetsStyleLeft imageSize:CGSizeMake(12, 12) imageConstraintEdge:UIEdgeInsetsMake(0, -8, 0, 0) labelConstraintEdge:UIEdgeInsetsMake(0, 8, 0, 0) forState:UIControlStateNormal]; 

//设置Normal状态下，左图片右文字布局，图片大小为12pt 12pt,间距为8pt，整体居中向右偏移8pt
[button layoutButtonWithEdgeInsetsStyle:ZYButtonEdgeInsetsStyleLeft imageSize:CGSizeMake(12, 12) imageConstraintEdge:UIEdgeInsetsMake(0, 0, 0, 8) labelConstraintEdge:UIEdgeInsetsMake(0, 0, 0, -8) forState:UIControlStateNormal]; 

//selected状态只有文字
[button layoutButtonWithLabelConstraintEdge:UIEdgeInsetsMake(0, 0, 0, 0) forState:UIControlStateSelected];

//selected状态只有图片
[button layoutButtonWithImageConstraintEdge:UIEdgeInsetsMake(0, 0, 0, 0) forState:UIControlStateSelected];

//设置圆角为8pt
[button layoutButtonWithRadiusType:ZYButtonCornerRadiusTypeAll cornerRadius:8];
 
```

## 更多
```objc
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
    ZYButtonCornerRadiusTypeBottomLeftAndBottomRight,
    ZYButtonCornerRadiusTypeAll
};

@interface ZYButton : UIButton

@property (nonatomic, strong) UIImageView *zy_imageView;
@property (nonatomic, strong) UILabel *zy_titleLabel;

@property (nonatomic, assign) BOOL isAutoHighlighted;//默认增加高亮蒙版功能
@property (nonatomic, assign) BOOL zy_userInteractionEnabled; //默认为YES，NO的话忽略当前button的触摸事件，但不忽略button上面的子view事件

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
- (void)layoutButtonWithImageConstraintEdge:(UIEdgeInsets)imageConstraintEdge forState:(UIControlState)state;
//设置圆角
- (void)layoutButtonWithRadiusType:(ZYButtonCornerRadiusType)radiusType cornerRadius:(CGFloat)cornerRadius;
//刷新圆角
- (void)layoutRadiusType;
@end
```
