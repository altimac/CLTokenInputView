//
//  CLTokenView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenView.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat const PADDING_X = 6.0;
static CGFloat const PADDING_Y = 2.0;

static NSString *const UNSELECTED_LABEL_FORMAT = @"%@,";
static NSString *const UNSELECTED_LABEL_NO_COMMA_FORMAT = @"%@";

#define FORCE_HIDE_UNSELECTED_COMMAS 1 // AH, I want to always hide unselected commas

@interface CLTokenView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIView *selectedBackgroundView;
@property (strong, nonatomic) UILabel *selectedLabel;

@property (copy, nonatomic) NSString *displayText;

@end

@implementation CLTokenView

- (id)initWithToken:(CLToken *)token font:(nullable UIFont *)font
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundView.backgroundColor = self.backgroundColor?self.backgroundColor:[UIColor clearColor];
        self.backgroundView.layer.cornerRadius = 13.0;
        [self addSubview:self.backgroundView];
        self.backgroundView.hidden = NO;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_X, PADDING_Y, 0, 0)];
        if (font) {
            self.label.font = font;
        }
        
        UIColor *tintColor = nil;
        if ([self respondsToSelector:@selector(tintColor)]) {
            tintColor = self.tintColor;
        }
        if(tintColor == nil) {
            tintColor = [UIColor darkTextColor];
        }
        
        self.label.textColor = tintColor;
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];

        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor?self.selectedBackgroundColor:[UIColor blueColor];
        self.selectedBackgroundView.layer.cornerRadius = 13.0;
        [self addSubview:self.selectedBackgroundView];
        self.selectedBackgroundView.hidden = YES;

        self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_X, PADDING_Y, 0, 0)];
        self.selectedLabel.font = self.label.font;
        self.selectedLabel.textColor = self.selectedTintColor?self.selectedTintColor:[UIColor whiteColor];
        self.selectedLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.selectedLabel];
        self.selectedLabel.hidden = YES;

        _token = token;
        self.displayText = token.displayText;

        self.hideUnselectedComma = NO;

        [self updateLabelAttributedText];
        self.selectedLabel.text = token.displayText;

        // Listen for taps
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapRecognizer];

        [self setNeedsLayout];

    }
    return self;
}

#pragma mark - Size Measurements

- (CGSize)intrinsicContentSize
{
    CGSize labelIntrinsicSize = self.selectedLabel.intrinsicContentSize;
    return CGSizeMake(labelIntrinsicSize.width + ((CGFloat)2 * PADDING_X), labelIntrinsicSize.height + ((CGFloat)2 * PADDING_Y));
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fittingSize = CGSizeMake(size.width - ((CGFloat)2 * PADDING_X), size.height - ((CGFloat)2 * PADDING_Y));
    CGSize labelSize = [self.selectedLabel sizeThatFits:fittingSize];
    return CGSizeMake(labelSize.width + ((CGFloat)2 * PADDING_X), labelSize.height + ((CGFloat)2 * PADDING_Y));
}


#pragma mark - Tinting

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.backgroundView.backgroundColor = _backgroundColor?_backgroundColor:[UIColor clearColor];
    [self updateLabelAttributedText];
}

- (void)setTintColor:(UIColor *)tintColor
{
    if ([UIView instancesRespondToSelector:@selector(setTintColor:)]) {
        super.tintColor = tintColor;
    }
    self.label.textColor = tintColor?tintColor:[UIColor darkTextColor];
    [self updateLabelAttributedText];
}

-(void)setSelectedTintColor:(UIColor *)selectedTintColor
{
    _selectedTintColor = selectedTintColor;
    self.selectedLabel.textColor = _selectedTintColor?_selectedTintColor:[UIColor whiteColor];
    [self updateLabelAttributedText];
}

-(void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    _selectedBackgroundColor = selectedBackgroundColor;
    self.selectedBackgroundView.backgroundColor = _selectedBackgroundColor?_selectedBackgroundColor:[UIColor blueColor];
    [self updateLabelAttributedText];
}


#pragma mark - Hide Unselected Comma


- (void)setHideUnselectedComma:(BOOL)hideUnselectedComma
{
#if FORCE_HIDE_UNSELECTED_COMMAS
    hideUnselectedComma = YES;
#endif
    
    if (_hideUnselectedComma == hideUnselectedComma) {
        return;
    }
    _hideUnselectedComma = hideUnselectedComma;
    [self updateLabelAttributedText];
}


#pragma mark - Taps

-(void)handleTapGestureRecognizer:(id)sender
{
    [self.delegate tokenViewDidRequestSelection:self];
}


#pragma mark - Selection

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

//TODO: handle color on selection / non selection on background, text and selected backgrtound and selected text !!
//
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selected == selected) {
        return;
    }
    _selected = selected;

    if (selected && !self.isFirstResponder) {
        [self becomeFirstResponder];
    } else if (!selected && self.isFirstResponder) {
        [self resignFirstResponder];
    }
    CGFloat selectedAlpha = (selected ? 1.0 : 0.0);
    if (animated) {
        if (selected) {
            self.selectedBackgroundView.alpha = 0.0;
            self.selectedBackgroundView.hidden = NO;
            self.selectedLabel.alpha = 0.0;
            self.selectedLabel.hidden = NO;
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.selectedBackgroundView.alpha = selectedAlpha;
            self.selectedLabel.alpha = selectedAlpha;
        } completion:^(BOOL finished) {
            if (!selected) {
                self.selectedBackgroundView.hidden = YES;
                self.selectedLabel.hidden = YES;
            }
        }];
    } else {
        self.selectedBackgroundView.hidden = !selected;
        self.selectedLabel.hidden = !selected;
    }
}


#pragma mark - Attributed Text


- (void)updateLabelAttributedText
{
    // Configure for the token, unselected shows "[displayText]," and selected is "[displayText]"
    NSString *labelString = [NSString stringWithFormat:self.hideUnselectedComma ? UNSELECTED_LABEL_NO_COMMA_FORMAT : UNSELECTED_LABEL_FORMAT, self.displayText];
    NSMutableAttributedString *attrString =
    [[NSMutableAttributedString alloc] initWithString:labelString
                                           attributes:@{NSFontAttributeName : self.label.font,
                                                        NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    NSRange tintRange = [labelString rangeOfString:self.displayText];
    // Make the name part the system tint color
    UIColor *tintColor = self.selectedBackgroundView.backgroundColor;
    if ([UIView instancesRespondToSelector:@selector(tintColor)]) {
        tintColor = self.tintColor;
    }
    [attrString setAttributes:@{NSForegroundColorAttributeName : tintColor}
                        range:tintRange];
    self.label.attributedText = attrString;
}


#pragma mark - Laying out

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    self.backgroundView.frame = bounds;
    self.selectedBackgroundView.frame = bounds;

    CGRect labelFrame = CGRectInset(bounds, PADDING_X, PADDING_Y);
    self.selectedLabel.frame = labelFrame;
    labelFrame.size.width += PADDING_X*2.0;
    self.label.frame = labelFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - UIKeyInput protocol

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:text];
}

- (void)deleteBackward
{
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}


#pragma mark - UITextInputTraits protocol (inherited from UIKeyInput protocol)

// Since a token isn't really meant to be "corrected" once created, disable autocorrect on it
// See: https://github.com/clusterinc/CLTokenInputView/issues/2
- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeNo;
}


#pragma mark - First Responder (needed to capture keyboard)

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


-(BOOL)resignFirstResponder
{
    BOOL didResignFirstResponder = [super resignFirstResponder];
    [self setSelected:NO animated:NO];
    return didResignFirstResponder;
}

-(BOOL)becomeFirstResponder
{
    BOOL didBecomeFirstResponder = [super becomeFirstResponder];
    [self setSelected:YES animated:NO];
    return didBecomeFirstResponder;
}


@end
