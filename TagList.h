//
//  TagList.h
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 27..
//  Copyright © 2017년 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@protocol TagListDelegate, TagViewDelegate;

@interface TagList : UIScrollView
{
    UIView  *view;
    NSArray *textArray;
    CGSize  sizeFit;
    UIColor *BackgroundColor;
    UIColor *ChangedBackgroundColor;
}
@property NSInteger touchCount;
@property (nonatomic) BOOL viewOnly;
@property (nonatomic) BOOL showTagMenu;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, weak) id<TagListDelegate> tagDelegate;
@property (nonatomic, strong) IBInspectable UIColor *highlightedBackgroundColor;
@property (nonatomic) IBInspectable BOOL automaticResize;
@property (nonatomic, strong) IBInspectable UIFont *font;
@property (nonatomic, assign) IBInspectable CGFloat labelMargin;
@property (nonatomic, assign) IBInspectable CGFloat bottomMargin;
@property (nonatomic, assign) IBInspectable CGFloat horizontalPadding;
@property (nonatomic, assign) IBInspectable CGFloat verticalPadding;
@property (nonatomic, assign) IBInspectable CGFloat minimumWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *textColor;
@property (nonatomic, strong) IBInspectable UIColor *textShadowColor;
@property (nonatomic, assign) IBInspectable CGSize textShadowOffset;

-(void)setTagBackgroundColor:(UIColor *)color;
-(void)setTagChangedBackgroundColor:(UIColor *)color;
-(void)setTagHighlightColor:(UIColor *)color;
-(void)setTags:(NSArray *)array;
-(void)display;
-(CGSize)fittedSize;
-(void)scrollToBottomAnimated:(BOOL)animated;
-(UIColor *)getChangedBackgroundColor;


@end

@interface TagView : UIView

@property (nonatomic, strong) UIButton          *button;
@property (nonatomic, strong) UILabel           *label;
@property (nonatomic, weak) id<TagViewDelegate> delegate;

-(void)updateWithString:(NSString*)text
                   font:(UIFont*)font
     constrainedToWidth:(CGFloat)maxWidth
                padding:(CGSize)padding
           minimumWidth:(CGFloat)minimumWidth;

-(void)setLabelText:(NSString *)text;
-(void)setCornerRadius:(CGFloat)cornerRadius;
-(void)setBorderColor:(CGColorRef)borderColor;
-(void)setBorderWidth:(CGFloat)borderWidth;
-(void)setTextColor:(UIColor*)textColor;
-(void)setTextShadowColor:(UIColor*)textShadowColor;
-(void)setTextShadowOffset:(CGSize)textShadowOffset;

@end

@protocol TagListDelegate <NSObject>

@optional

-(void)selectedTag:(NSString *)tagName tagIndex:(NSInteger)tagIndex;
-(void)selectedTag:(NSString *)tagName;
-(void)tagListTagsChanged:(TagList *)tagList;
@end

@protocol TagViewDelegate <NSObject>

@required

-(void)tagViewWantsToBeDeleted:(TagView *)tagView;

@end


