//
//  TagList.m
//  tf_ios_makefile_example
//
//  Created by ys on 2017. 5. 27..
//  Copyright © 2017년 Google. All rights reserved.
//

#import "TagList.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 10.0f
#define LABEL_MARGIN_DEFAULT 10.0f
#define BOTTOM_MARGIN_DEFAULT 10.0f
#define FONT_SIZE_DEFAULT 20.0f
#define HORIZONTAL_PADDING_DEFAULT 7.0f
#define VERTICAL_PADDING_DEFAULT 3.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:1.00] //태그 배경색 지정
#define CHANGED_BACKGROUND_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] // 바뀐 배경색 지정
#define TEXT_COLOR [UIColor blackColor]           //태그 text색 지정
#define TEXT_SHADOW_COLOR [UIColor whiteColor]    // 태그 text 그림자 색
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)// text 그림자 거리 지정
#define BORDER_COLOR [UIColor lightGrayColor]
#define BORDER_WIDTH 1.0f
#define HIGHLIGHTED_BACKGROUND_COLOR [UIColor colorWithRed:0.40 green:0.80 blue:1.00 alpha:0.5]
#define DEFAULT_AUTOMATIC_RESIZE NO
#define DEFAULT_SHOW_TAG_MENU NO

NSMutableArray *tagViews;

@interface TagList () <TagViewDelegate>

@end

@implementation TagList

@synthesize view, textArray, automaticResize;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup {
    [self addSubview:view];
    [self setClipsToBounds:YES];
    self.automaticResize = DEFAULT_AUTOMATIC_RESIZE;
    self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
    self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
    self.labelMargin = LABEL_MARGIN_DEFAULT;
    self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
    self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
    self.verticalPadding = VERTICAL_PADDING_DEFAULT;
    self.cornerRadius = CORNER_RADIUS;
    self.borderColor = BORDER_COLOR;
    self.borderWidth = BORDER_WIDTH;
    self.textColor = TEXT_COLOR;
    self.textShadowColor = TEXT_SHADOW_COLOR;
    self.textShadowOffset = TEXT_SHADOW_OFFSET;
    self.showTagMenu = DEFAULT_SHOW_TAG_MENU;
    self.touchCount = 0; // 처음 터치횟수 지정
    for (NSString *familyName in [UIFont familyNames]) {
        NSLog(@"%@ : [ %@ ]", familyName, [[UIFont fontNamesForFamilyName:familyName] description]);
    }
    
    self.font = [UIFont fontWithName:@"AppleGothic" size:18.0];


    
}

-(void)setTags:(NSArray *)array {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    textArray = [[NSArray alloc] initWithArray:array];
    app.selectedTextArray = [[NSMutableArray alloc] init];
    
    sizeFit = CGSizeZero;
    if(automaticResize) {
        [self display];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self display];
    }
}

-(void)setTagBackgroundColor:(UIColor *)color {
    BackgroundColor = color;
    [self display];
}

-(void)setTagHighlightColor:(UIColor *)color {
    self.highlightedBackgroundColor = color;
    [self display];
}

-(void)setViewOnly:(BOOL)viewOnly {
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self display];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self display];
}

-(void)display {
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if([subview isKindOfClass:[TagView class]]) {
            TagView *tagView = (TagView *)subview;
            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagView.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }
    
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    
    NSInteger tag = 0;
    for (id text in textArray) {
        TagView *tagView;
        if (tagViews.count > 0) {
            tagView = [tagViews lastObject];
            [tagViews removeLastObject];
        }
        else {
            tagView = [[TagView alloc]init];
        }
        
        
        [tagView updateWithString:text font:self.font
               constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                          padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth];
        
        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if(previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                newRect.origin = CGPointMake( 0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            }
            else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            [tagView setFrame:newRect];
        }
        
        previousFrame = tagView.frame;
        gotPreviousFrame = YES;
        
       // [tagView setBackgroundColor:[self getChangedBackgroundColor]];
        [tagView setCornerRadius:self.cornerRadius];
        [tagView setBorderColor:self.borderColor.CGColor];
        [tagView setBorderWidth:self.borderWidth];
        [tagView setTextColor:self.textColor];
        [tagView setTextShadowColor:self.textShadowColor];
        [tagView setTextShadowOffset:self.textShadowOffset];
        [tagView setTag:tag];
        [tagView setDelegate:self];
        
        tag++;
        
        [self addSubview:tagView];
        
        if(!_viewOnly) {
            [tagView.button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
            [tagView.button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [tagView.button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
            [tagView.button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
     
        }
    }
    
    sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    self.contentSize = sizeFit;
}

-(CGSize)fittedSize {
    return sizeFit;
}

-(void)scrollToBottomAnimated:(BOOL)animated {
    [self setContentOffset:CGPointMake(0.0, self.contentSize.height - self.bounds.size.height + self.contentInset.bottom) animated:animated];
}

-(void)touchDownInside:(id)sender {
    UIButton *button = (UIButton *)sender;
   // [[button superview] setBackgroundColor:self.highlightedBackgroundColor];
   
}

- (void)touchUpInside:(id)sender
{
    
    UIButton *button = (UIButton*)sender;
    TagView *tagView = (TagView *)[button superview];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    
    if ( _touchCount % 2 == 1 ) {
        [tagView setBackgroundColor:[self getChangedBackgroundColor]];
        [app.selectedTextArray addObject:tagView.label.text];
    }
    else {
        [tagView setBackgroundColor:[self getBackgroundColor]];
        [app.selectedTextArray removeObject:tagView.label.text];

    }

    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:tagIndex:)]) {
        [self.tagDelegate selectedTag:tagView.label.text tagIndex:tagView.tag];
    }
    
    
    if ([self.tagDelegate respondsToSelector:@selector(selectedTag:)]) {
        [self.tagDelegate selectedTag:tagView.label.text];
    }
    
    
    if (self.showTagMenu) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:tagView.frame inView:self];
        [menuController setMenuVisible:YES animated:YES];
        [tagView becomeFirstResponder];
    }
    _touchCount++;

}

- (void)touchDragExit:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
}

- (void)touchDragInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
}

- (UIColor *)getBackgroundColor
{
    return !BackgroundColor ? BACKGROUND_COLOR : BackgroundColor;
}

-(UIColor *)getChangedBackgroundColor
{
    return !ChangedBackgroundColor ? CHANGED_BACKGROUND_COLOR : ChangedBackgroundColor;
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self display];
}

-(void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self display];
}

-(void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self display];
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self display];
}

-(void)setTextShadowColor:(UIColor *)textShadowColor
{
    _textShadowColor = textShadowColor;
    [self display];
}

-(void)setTextShadowOffset:(CGSize)textShadowOffset
{
    _textShadowOffset = textShadowOffset;
    [self display];
}

-(void)dealloc
{
    view = nil;
    textArray = nil;
    BackgroundColor = nil;
}

#pragma mark - DWTagViewDelegate

-(void)tagViewWantsToBeDeleted:(TagView *)tagView
{
    NSMutableArray *mTextArray = [self.textArray mutableCopy];
    [mTextArray removeObject:tagView.label.text];
    [self setTags:mTextArray];
    
    if([self.tagDelegate respondsToSelector:@selector(tagListTagsChanged:)]) {
        [self.tagDelegate tagListTagsChanged:self];
    }
}
@end

@implementation TagView

-(id)init
{
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_label setTextColor:TEXT_COLOR];
        [_label setShadowColor:TEXT_SHADOW_COLOR];
        [_label setShadowOffset:TEXT_SHADOW_OFFSET];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_button setFrame:self.frame];
        [self addSubview:_button];
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:CORNER_RADIUS];
        [self.layer setBorderColor:BORDER_COLOR.CGColor];
        [self.layer setBorderWidth:BORDER_WIDTH];
    }
    
    return self;
}

- (void)updateWithString:(id)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth
{
    CGSize textSize = CGSizeZero;
    BOOL isTextAttributedString = [text isKindOfClass:[NSAttributedString class]];
    
    if (isTextAttributedString) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [attributedString addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, ((NSAttributedString *)text).string.length)];
        
        textSize = [attributedString boundingRectWithSize:CGSizeMake(maxWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _label.attributedText = [attributedString copy];
    } else {
        textSize = [text sizeWithFont:font forWidth:maxWidth lineBreakMode:NSLineBreakByTruncatingTail];
        
        _label.text = text;
    }
    
    textSize.width = MAX(textSize.width, minimumWidth);
    textSize.height += padding.height*2;
    
    self.frame = CGRectMake(10, 0, textSize.width+padding.width*2, textSize.height);
    _label.frame = CGRectMake(padding.width, 0, MIN(textSize.width, self.frame.size.width), textSize.height);
    _label.font = font;
    
    [_button setAccessibilityLabel:self.label.text];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [self.layer setCornerRadius:10];
}

- (void)setBorderColor:(CGColorRef)borderColor
{
    [self.layer setBorderColor:borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    [self.layer setBorderWidth:borderWidth];
}

- (void)setLabelText:(NSString*)text
{
    [_label setText:text];
}

- (void)setTextColor:(UIColor *)textColor
{
    [_label setTextColor:textColor];
}

- (void)setTextShadowColor:(UIColor*)textShadowColor
{
    [_label setShadowColor:textShadowColor];
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset
{
    [_label setShadowOffset:textShadowOffset];
}

- (void)dealloc
{
    _label = nil;
    _button = nil;
}

#pragma mark - UIMenuController support

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:)) || (action == @selector(delete:));
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.label.text];
}

- (void)delete:(id)sender
{
    [self.delegate tagViewWantsToBeDeleted:self];
}

@end
