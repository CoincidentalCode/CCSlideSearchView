//
//  CCSlideSearchView.m
//  
//
//  Created by Tom Bachant on 4/8/13.
//  Copyright (c) 2013 Tom Bachant. All rights reserved.
//

#import "CCSlideSearchView.h"

#define BACKGROUND_COLOR [UIColor colorWithWhite:0.0f alpha:0.25f];

#define LETTER_FONT [UIFont boldSystemFontOfSize:10]
#define LETTER_COLOR [UIColor whiteColor];

#define HIGHLIGHTER_FONT [UIFont systemFontOfSize:18]

// Padding above and below the letters of the main search view
static const CGFloat paddingSearchView = 4.0f;

// How far the highlighter is offset to the left of the main view
static const CGFloat offsetHighlightView = 30.0f;
// Inner padding for text with respect to highlight view bounds
static const CGFloat paddingHighlightView = 10.0f;
// Height of highlight view
static const CGFloat heightHighlightView = 40.0f;

@interface CCSlideSearchView ()

@property (nonatomic, assign) CGFloat initialTouchPositionX;
@property (nonatomic, assign) CGFloat initialTouchPositionY;
@property (nonatomic, assign) CGFloat currentTouchPositionX;
@property (nonatomic, assign) CGFloat currentTouchPositionY;
@property (nonatomic, assign) CGFloat movementX;

- (void)layoutNextLetterView;
- (void)adjustFrameForNewLetterView;

- (void)addLetterToSearchTerm:(NSString *)letter atIndex:(NSInteger)index;
- (void)hoverOverLetter:(NSString *)letter atIndex:(NSInteger)index;

- (void)updateHightlighterForLetter:(NSString *)letter;

- (void)startSearch;
- (void)endSearch;

- (NSInteger)getIndexForYTouchCoord:(CGFloat)yPoint;

@end

@implementation CCSlideSearchView

@synthesize delegate;

/*
- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"CCSlideSearchView: Invalid initializer. Please use -(id)initWithFrame:");
    }
    return self;
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        self.highlightsWhileSearching = YES;
        
        self.term = @"";
        self.backgroundColor = [UIColor clearColor];
        searchViews = [[NSMutableArray alloc] init];
        availableSearchStrings = [[UILocalizedIndexedCollation currentCollation] sectionTitles];

        // Set up the properties
        startFrame = frame;
        letterHeight = (frame.size.height - (paddingSearchView * 2)) / [availableSearchStrings count];
        letterWidth = frame.size.width;

        // Set up the highlight view for future use
        highlighterView = [[UIView alloc] initWithFrame:CGRectMake(0, -offsetHighlightView, heightHighlightView, heightHighlightView)];
        
        highlighterBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, heightHighlightView, heightHighlightView)];
        highlighterBackgroundView.image = [[UIImage imageNamed:@"highlighter.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        [highlighterView addSubview:highlighterBackgroundView];
        
        highlighterLabel = [[UILabel  alloc] initWithFrame:highlighterBackgroundView.frame];
        highlighterLabel.textColor = [UIColor whiteColor];
        highlighterLabel.backgroundColor = [UIColor clearColor];
        highlighterLabel.textAlignment = UITextAlignmentLeft;
        highlighterLabel.font = HIGHLIGHTER_FONT;
        [highlighterView addSubview:highlighterLabel];
        
        highlighterView.hidden = YES;
        [self addSubview:highlighterView];
        
        // Set up the letter view
        UIView *verticalLetterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        verticalLetterView.backgroundColor = BACKGROUND_COLOR;
        for (int i = 0; i < [availableSearchStrings count]; i++) {
            UILabel *containerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingSearchView + (letterHeight * i), letterWidth, letterHeight)];
            containerLabel.textAlignment = UITextAlignmentCenter;
            containerLabel.backgroundColor = [UIColor clearColor];
            containerLabel.font = LETTER_FONT;
            containerLabel.textColor = LETTER_COLOR;
            containerLabel.text = (NSString *)[availableSearchStrings objectAtIndex:i];
            [verticalLetterView addSubview:containerLabel];
        }
        
        [self addSubview:verticalLetterView];
        [searchViews addObject:verticalLetterView];
    }
    
    return self;
}

#pragma mark - Handing Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchCoord = [touch locationInView:self];
    
    _initialTouchPositionX = touchCoord.x;
    _initialTouchPositionY = touchCoord.y;
    
    _currentTouchPositionX = touchCoord.x;
    _currentTouchPositionY = touchCoord.y;
    
    _movementX = 0;
    
    [self startSearch];
    
    [self hoverOverLetter:[availableSearchStrings objectAtIndex:[self getIndexForYTouchCoord:touchCoord.y]] atIndex:[self getIndexForYTouchCoord:touchCoord.y]];
        
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchCoord = [touch locationInView:self];
    
    if (self.state == CCSlideSearchStateHovering) {
        
        [self hoverOverLetter:[availableSearchStrings objectAtIndex:[self getIndexForYTouchCoord:touchCoord.y]] atIndex:[self getIndexForYTouchCoord:touchCoord.y]];

        // If searched beyond the limit, enable hovering but do not allow selection or horizontal motion
        if ([self.term length] < self.characterLimit - 1) {
            CGFloat difference = _initialTouchPositionX - touchCoord.x;
            
            _movementX = self.frame.size.width + difference - startFrame.size.width;
            
            if (_movementX > letterWidth * ([searchViews count] - 1)) {
                // Selection
                [self addLetterToSearchTerm:[availableSearchStrings objectAtIndex:[self getIndexForYTouchCoord:touchCoord.y]] atIndex:[self getIndexForYTouchCoord:touchCoord.y]];
                
            }
            else if (_movementX >= letterWidth * ([searchViews count] - 2)) {
                // Moving
                self.frame = CGRectMake(self.frame.origin.x - difference, 0, self.frame.size.width + difference, startFrame.size.height);
                
            }
        }
        
    } else if (self.state == CCSlideSearchStateSelecting) {
                
        CGFloat difference = _initialTouchPositionX - touchCoord.x;

        _movementX = self.frame.size.width + difference - startFrame.size.width;
        
        if (_movementX > letterWidth * ([searchViews count] - 1)) {
            // Dampen or stop if necessary
            
            if (touchCoord.x > _currentTouchPositionX) {
                // Moving right after movement is beyond frame should not change position
                difference = 0;
            }
            else {
                // If the view has been pulled farther than one width of the view, it should be damped
                difference = difference / (_movementX * 3);
            }
            
            self.frame = CGRectMake(self.frame.origin.x - difference, 0, self.frame.size.width + difference, startFrame.size.height);
        }
        else if (touchCoord.x > letterWidth * ([searchViews count] - 1)) {
            _initialTouchPositionX = touchCoord.x;
            
            [self adjustFrameForNewLetterView];
        }

     }

    _currentTouchPositionX = touchCoord.x;
    _currentTouchPositionY = touchCoord.y;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endSearch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endSearch];
}

#pragma mark - Actions

- (void)layoutNextLetterView {
    
    UIView *nextLetterView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, startFrame.size.width, startFrame.size.height)];
    nextLetterView.backgroundColor = BACKGROUND_COLOR;
    
    // Start invisible and fade in as it approaches the side.
    nextLetterView.alpha = 1;
    
    for (int i = 0; i < [availableSearchStrings count]; i++) {
        UILabel *containerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, paddingSearchView + (letterHeight * i), letterWidth, letterHeight)];
        containerLabel.textAlignment = UITextAlignmentCenter;
        containerLabel.backgroundColor = [UIColor clearColor];
        containerLabel.font = LETTER_FONT;
        containerLabel.textColor = LETTER_COLOR;
        containerLabel.text = (NSString *)[availableSearchStrings objectAtIndex:i];
        [nextLetterView addSubview:containerLabel];
    }
    
    [self addSubview:nextLetterView];
    [searchViews addObject:nextLetterView];

}

- (void)adjustFrameForNewLetterView {

    self.state = CCSlideSearchStateHovering;

    [UIView animateWithDuration:0.1 animations:^{
        
        self.frame = CGRectMake(startFrame.origin.x - (letterWidth * ([searchViews count] - 1)), 0, letterWidth * [searchViews count], startFrame.size.height);
        [self layoutNextLetterView];
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)startSearch {
    
    self.state = CCSlideSearchStateHovering;
    
    [self layoutNextLetterView];
            
    [delegate slideSearchDidBegin:self];
}

- (void)hoverOverLetter:(NSString *)letter atIndex:(NSInteger)index {
    
    self.state = CCSlideSearchStateHovering;
    
    [self updateHightlighterForLetter:letter];
    
    [delegate slideSearch:self didHoverLetter:letter atIndex:index withSearchTerm:self.term];
}

- (void)addLetterToSearchTerm:(NSString *)letter atIndex:(NSInteger)index {
    
    if ([letter isEqualToString:@"#"]) return;
    
    self.state = CCSlideSearchStateSelecting;
    
    if ([self.term length]) letter = [letter lowercaseString];
    
    self.term = [NSString stringWithFormat:@"%@%@", self.term, letter];
    
    // Hide the letter view now that it has been selected
    if ([searchViews count] >= 2) {
        
        [UIView animateWithDuration:0.3 animations:^ {
            
            UIView *letterView = [searchViews objectAtIndex:[searchViews count] - 2];
            letterView.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    [self updateHightlighterForLetter:@""];
    
    [delegate slideSearch:self didConfirmLetter:letter atIndex:index withSearchTerm:self.term];
}


- (void)endSearch {
    
    self.state = CCSlideSearchStateInactive;
    
    [delegate slideSearch:self didFinishSearchWithTerm:self.term];
    
    self.term = @"";

    [UIView animateWithDuration:0.3 animations:^{        
        self.frame = startFrame;

        highlighterView.hidden = YES;

        for (int i = [searchViews count] - 1; i >= 0; i--) {
            UIView *v = (UIView *)[searchViews objectAtIndex:i];
            v.frame = CGRectMake(i * letterWidth, 0, letterWidth, startFrame.size.height);
            v.alpha = 1.0f;
        }
        
    } completion:^(BOOL finished) {

        for (int i = [searchViews count] - 1; i > 0; i--) {
            UIView *v = (UIView *)[searchViews objectAtIndex:i];
            [v removeFromSuperview];
            
            [searchViews removeObjectAtIndex:i];
        }
        
    }];
}

#pragma mark - Highlighter

- (void)updateHightlighterForLetter:(NSString *)letter {
    
    if (!self.highlightsWhileSearching) return;
    
    if ([searchViews count] >= 2) {
        
        BOOL animated = YES;
        
        // Only animate if already visible
        if (highlighterView.hidden) {
            animated = NO;
            highlighterView.hidden = NO;
        }
        
        // Set alignment based on length. If only one letter shown in the higlighter, center it. Otherwise, align left to make more legible
        if ([self.term length]) {
            highlighterLabel.textAlignment = UITextAlignmentLeft;
        } else {
            highlighterLabel.textAlignment = UITextAlignmentCenter;
        }
        
        highlighterLabel.text = [[NSString stringWithFormat:@"%@%@", self.term, letter] uppercaseString];
        
        // Get size of text before new letter added
        CGSize sizeOfHighlightedText = [[self.term uppercaseString] sizeWithFont:HIGHLIGHTER_FONT constrainedToSize:CGSizeMake(CGFLOAT_MAX, heightHighlightView) lineBreakMode:NSLineBreakByTruncatingTail];
        if ([letter length]) {
            sizeOfHighlightedText.width += 17.0f; // Add space for new character regardless of its size
        }
        else {
            sizeOfHighlightedText.width += 4.0f; // Add regular spacing
        }
        
        CGFloat yCenterCoord = _currentTouchPositionY;

        // If the value would put the highlighter frame out of screen, keep fully in view
        if (yCenterCoord < CGRectGetHeight(highlighterView.frame) / 2) {
            yCenterCoord = CGRectGetHeight(highlighterView.frame) / 2;
        }
        if (yCenterCoord > CGRectGetHeight(startFrame) - (CGRectGetHeight(highlighterView.frame) / 2)) {
            yCenterCoord = CGRectGetHeight(startFrame) - (CGRectGetHeight(highlighterView.frame) / 2);
        }
                        
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.25];
        }
        
        CGFloat xCoord = ([searchViews count] - 2) * letterWidth - offsetHighlightView - sizeOfHighlightedText.width;
        CGFloat yCoord = yCenterCoord - (CGRectGetHeight(highlighterView.frame) / 2);
        CGFloat width = sizeOfHighlightedText.width + paddingHighlightView*2;
        CGFloat height = heightHighlightView;
        
        highlighterView.frame = CGRectMake(xCoord, yCoord, width, height);
        highlighterBackgroundView.frame = CGRectMake(0, 0, width, height);
        highlighterLabel.frame = CGRectMake(paddingHighlightView, 0, sizeOfHighlightedText.width, height);

        if (animated) {
            [UIView commitAnimations];
        }
    }
    
}

#pragma mark - Helpers

- (NSInteger)getIndexForYTouchCoord:(CGFloat)yPoint {
    if (yPoint < 0) {
        return 0;
    }
    else if (yPoint >= startFrame.size.height) {
        return [availableSearchStrings count] - 1;
    }
    
    return floor((yPoint / self.frame.size.height) * [availableSearchStrings count]);
}

@end
