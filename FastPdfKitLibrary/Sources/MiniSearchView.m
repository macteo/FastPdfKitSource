//
//  MiniSearchView.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 1/17/11.
//  Copyright 2011 com.mobfarm. All rights reserved.
//

#import "MiniSearchView.h"
#import "Stuff.h"
//#import "DocumentViewController.h"
#import "SearchManager.h"
#import "FPKSearchMatchItem.h"
#import "SearchResultView.h"

#define ZOOM_LEVEL 4.0

@interface MiniSearchView()

-(void)moveToNextResult;
-(void)moveToPrevResult;

@end


@implementation MiniSearchView

@synthesize nextButton;
@synthesize prevButton;
@synthesize cancelButton;
@synthesize fullButton;

@synthesize pageLabel;
@synthesize snippetLabel;

@synthesize documentDelegate, dataSource;
@synthesize searchResultView;

-(void)updateSearchResultViewWithItem:(FPKSearchMatchItem *)item {

	self.searchResultView.page = item.textItem.page;
	self.searchResultView.text = item.textItem.text;
	self.searchResultView.boldRange = item.textItem.searchTermRange;
}

-(void)reloadData {
	
	// This method basically set the current appaerance of the view to 
	// present the content of the Search Result pointed by currentSearchResultIndex.

    FPKSearchMatchItem * item = nil;
	NSArray * searchResults = nil;
    
    searchResults = [dataSource allSearchResults];
	
    if(currentSearchResultIndex >= [searchResults count]) {
        currentSearchResultIndex = [searchResults count] - 1;
    }
    
	item = [searchResults objectAtIndex:currentSearchResultIndex];
    
    if(!item) {
		return;
    }
	
	// Update the content view.
	[self updateSearchResultViewWithItem:item];
    
}

-(void)setCurrentResultIndex:(NSUInteger)index {
	
	// This is more or less the same as the method above, just set the index
	// passed as parameter as the current index and then proceed accordingly.
	
    FPKSearchMatchItem * item = nil;
    NSArray * searchResults = nil;
    
    searchResults = [dataSource allSearchResults];
	
	if(index >= [searchResults count]) {
		index = [searchResults count] - 1;
	}
	
	currentSearchResultIndex = index;
	
	item = [searchResults objectAtIndex:currentSearchResultIndex];
	
	if(!item)
		return;
	
	[self updateSearchResultViewWithItem:item];
}

-(void)setCurrentTextItem:(FPKSearchMatchItem *)item {
	
	// Just an utility method to set the current index when just the item is know.
	
	NSUInteger index = [[dataSource allSearchResults] indexOfObject:item];
	
	[self setCurrentResultIndex:index];
}

-(void) moveToNextResult {
	
	
	// The same as the two similar methods above. It only differs in the fact that increase
	// the index by one, then proceed the same.
	NSArray * searchResults = [dataSource allSearchResults];
    FPKSearchMatchItem * item = nil;
    
	currentSearchResultIndex++;
	
	if(currentSearchResultIndex == [searchResults count])
		currentSearchResultIndex = 0;
	
	item = [searchResults objectAtIndex:currentSearchResultIndex];
	
    if(!item) {
		return;
    }
	
	[self updateSearchResultViewWithItem:item];
	
	[documentDelegate setPage:item.textItem.page withZoomOfLevel:ZOOM_LEVEL onRect:item.boundingBox];
	
}

-(void) moveToPrevResult {

	// As the above method, but it decrease the index instead.
	NSArray * searchResults = [dataSource allSearchResults];
    FPKSearchMatchItem * item = nil;
    
	currentSearchResultIndex--;
	
	if(currentSearchResultIndex < 0)
		currentSearchResultIndex = [searchResults count]-1;
	
	item = [searchResults objectAtIndex:currentSearchResultIndex];
	
    if(!item) {
		return;
    }
	
	[self updateSearchResultViewWithItem:item];
	
	[documentDelegate setPage:item.textItem.page withZoomOfLevel:ZOOM_LEVEL onRect:item.boundingBox];
}

#pragma mark - Search notification listeners

-(void)handleSearchDidStopNotification:(NSNotification *)notification {
    
   [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

-(void)handleSearchGotCancelledNotification:(NSNotification *)notification {
    // Setup the view accordingly.
	
	[documentDelegate dismissMiniSearchView];
}

#pragma mark Actions

-(void)actionNext:(id)sender {
	
	// Tell the delegate to show the next result, eventually moving to a different page.
	
	[self moveToNextResult];
}

-(void)actionPrev:(id)sender {
	
	// Show the previous result, eventually moving to another page.
	
	[self moveToPrevResult];
}

-(void)actionCancel:(id)sender {
	
	// Tell the data source to stop the search.
	
	if(self.dataSource.running) {
		[dataSource stopSearch];
	}
}

-(void)actionFull:(id)sender {
	
	// Tell the delegate to dismiss this mini view and present the full table view.
	
	[documentDelegate revertToFullSearchView];
}


#pragma mark -
#pragma mark View lifecycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
	
    if (self) {
		
        // Initialization code
		self.autoresizesSubviews = YES;	// Yes
		self.opaque = NO;				// Otherwise background transparencies will be flat black
        
		// Layout subviews
		CGSize size = frame.size;
		UIFont *smallFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        
		// Next button
        UIButton *aButton = nil;
        aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(size.width-30-2, 24, 30, 20);
        [aButton setTitle:@"N" forState:UIControlStateNormal];
        [aButton setTitle:@"-" forState:UIControlStateDisabled];
		[aButton setBackgroundColor:[UIColor clearColor]];
		[[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchUpInside];
		self.nextButton = aButton;
		[self addSubview:aButton];
		//[aButton release];
		
		// Prev button
        aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(2, 24, 30, 20);
		[aButton setTitle:@"P" forState:UIControlStateNormal];
        [aButton setTitle:@"-" forState:UIControlStateDisabled];
        [aButton setBackgroundColor:[UIColor clearColor]];
		[[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionPrev:) forControlEvents:UIControlEventTouchUpInside];
		self.prevButton = aButton;
		[self addSubview:aButton];
		//[aButton release];
		
		// Cancel button
        aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(size.width-30-2, 0, 30, 20);
		[aButton setTitle:@"C" forState:UIControlStateNormal];
        [aButton setTitle:@"-" forState:UIControlStateDisabled];
        [aButton setBackgroundColor:[UIColor clearColor]];
        [[aButton titleLabel] setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
		self.cancelButton = aButton;
		[self addSubview:aButton];
		//[aButton release];
		
		// Full button
        aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		aButton.frame = CGRectMake(2, 0, 30, 20);
		[aButton setTitle:@"S" forState:UIControlStateNormal];
        [aButton setTitle:@"-" forState:UIControlStateDisabled];
		[aButton setBackgroundColor:[UIColor clearColor]];
        [[aButton titleLabel]setFont:smallFont];
		[aButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
		[aButton addTarget:self action:@selector(actionFull:) forControlEvents:UIControlEventTouchUpInside];
		self.fullButton = aButton;
		[self addSubview:aButton];
		//[aButton release];
		
		SearchResultView *aSRV = [[SearchResultView alloc]initWithFrame:CGRectMake(30+2,2, size.width-30*2-2*4,size.height-5)];
		[aSRV setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
		self.searchResultView = aSRV;
		[aSRV setBackgroundColor:[UIColor clearColor]];
		[self addSubview:aSRV];
        
        // Register notification listeners
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchDidStopNotification:) name:kNotificationSearchDidStop object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleSearchGotCancelledNotification:) name:kNotificationSearchGotCancelled object:nil];
	}
	
    return self;
}

-(void) drawRect:(CGRect)rect {

	// We are going to draw a white rounded rect with a middle gray stroke color (like
	// the default rounded rect button).
	
	// Get the current context.
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Set fill and stroke colors.
	
	CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
	CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
	CGContextSetAllowsAntialiasing(ctx, 1);
	
	CGFloat radius = 10;	// Radius of the corners.
	
	// Draw a path resembling a rounded rect.
	
	CGContextBeginPath(ctx);
	CGContextAddArc(ctx, radius, radius, radius, M_PI, M_PI*3*0.5, 0);
	CGContextAddArc(ctx, rect.size.width-radius, radius, radius, M_PI*3*0.5, 0,0);
	CGContextAddArc(ctx, rect.size.width-radius, rect.size.height-radius, radius, 0, M_PI*0.5, 0);
	CGContextAddArc(ctx, radius, rect.size.height-radius, radius, M_PI*0.5, M_PI, 0);
	CGContextClosePath(ctx);
	CGContextDrawPath(ctx, kCGPathFillStroke);
	
}


- (void)dealloc {
	
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
