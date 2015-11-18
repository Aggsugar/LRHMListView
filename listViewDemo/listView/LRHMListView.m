//
//  LRHMListView.m
//  DuplicateFileDetector
//
//  Created by tangj on 15/9/21.
//  Copyright (c) 2015年 tangj. All rights reserved.
//

#import "LRHMListView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSBezierPath+NSBezierPathToCGPath.h"
#import "NSColor+toCGColor.h"
#define _cell_default_height_    20
#define _vertical_offset_        0.5
#define _horizontal_offset_      0
@interface LRHMListView()
{
    NSMutableIndexSet       *_selectIndexs;
    NSRect                   _dragRect;
    NSScrollView            *_scrollView;
    NSColor                 *_unSelectedColor;
    NSColor                 *_selectColor;
}
@property (assign)  NSRect   gradientRect;
@property (retain)  CAShapeLayer  *selectedLayer;
@property (retain)  CAGradientLayer  *moveSelectedLayer;
@property (retain)  CAShapeLayer     *unSelectedLayer;
@property (retain)  CATiledLayer     *tiledLayer;
@end
@implementation LRHMListView
@synthesize delegate;
@synthesize datasource;
@synthesize unSelectedColor = _unSelectedColor;
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
     [self drawBackground];
    
//    [self drawUnselectedArea];
//    [self drawSelectedArea];
//    [self drawMoveSelectArea];
    

//    [self sele]
//    [self removeMoveGradientLayer];
//    [self selectedLayerAnimation];
}

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (void)awakeFromNib
{
    self.wantsLayer = YES;
//    [self configTileLayer];
    [self configScrollView];
    [self addTrackArea];
    [self configUnSelectedLayer];
    [self configSelectedLayer];
//    [self configMoveGradientLayer];
    [self registNotification];
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewFrameSizeChanged:) name:NSViewFrameDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewFrameSizeChanged:) name:NSViewBoundsDidChangeNotification object:[[_scrollView subviews] objectAtIndex:0]];
}
//
- (void)tableViewFrameSizeChanged:(NSNotification *)notification
{
//    [self resetFrame];
    [self reloadData];
}

//- (void)configTileLayer
//{
//    if (!_tiledLayer) {
//        _tiledLayer = [CATiledLayer layer];
//        _tiledLayer.frame = self.bounds;
//        _tiledLayer.levelsOfDetail = 10;
//        _tiledLayer.levelsOfDetailBias = 10;
//        [self.layer addSublayer:_tiledLayer];
////        _tiledLayer 
//    }
//}

- (void)configUnSelectedLayer
{
    if (!_unSelectedLayer) {
        _unSelectedLayer = [CAShapeLayer layer];
        _unSelectedLayer.fillColor = [[NSColor whiteColor] CGColor];//CGColorCreateGenericRGB(249.0/255, 249.0/255, 249.0/255, 1.0);
        _unSelectedLayer.frame = self.bounds;
        _unSelectedLayer.strokeColor = [[NSColor colorWithDeviceRed:114/255.0 green:114/255.0 blue:114/255.0 alpha:1.0] CGColor];
//        [_unSelectedLayer setl]
        [self.layer addSublayer:self.unSelectedLayer];
    }
}

- (void)configSelectedLayer
{
    if (!self.selectedLayer) {
        self.selectedLayer = [CAShapeLayer layer];
        self.selectedLayer.borderWidth = .0f;
        self.selectedLayer.opacity = 1;
        self.selectedLayer.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMaxYMargin;
        [self.layer addSublayer:self.selectedLayer];
    }
}

- (void)setSelectedColor:(NSColor *)color
{
    self.selectedLayer.fillColor = [color CGColor];
    if (_selectColor) {
        [_selectColor release];
        _selectColor = nil;
    }
    _selectColor = [color retain];
}

- (void)removeMoveGradientLayer
{
    [self.moveSelectedLayer removeFromSuperlayer];
    self.moveSelectedLayer = nil;
}

- (void)setUnSelectedColor:(NSColor *)color
{
    self.unSelectedLayer.fillColor = [color CGColor];
//    if (_unSelectedColor) {
//        [_unSelectedColor release];
//        _unSelectedColor = nil;
//    }
//    _unSelectedColor = [color retain];
}

- (void)configMoveGradientLayer
{
    if (!self.moveSelectedLayer) {
        self.moveSelectedLayer = [CAGradientLayer layer];
        self.moveSelectedLayer.opacity = 1;
//        self.moveSelectedLayer.backgroundColor = CGColorCreateGenericRGB(150.0/255, 150.0/255, 150.0/255, 1.0);
        self.moveSelectedLayer.locations = [NSArray arrayWithObjects:@0.0,@0.35,@0.65,@1.0, nil];
        
        self.moveSelectedLayer.colors = [NSArray arrayWithObjects:[[NSColor cyanColor] CGColor], [[NSColor whiteColor] CGColor], [[NSColor whiteColor] CGColor], [[NSColor cyanColor] CGColor], nil];
        self.moveSelectedLayer.startPoint = NSMakePoint(0, 0);
        self.moveSelectedLayer.endPoint = NSMakePoint(1.0, 0.0);
        [self.layer insertSublayer:self.moveSelectedLayer above:_unSelectedLayer];
    }
}

- (void)selectedLayerAnimation
{
    [self.selectedLayer setSublayers:[NSArray array]];
    NSBezierPath *selectedArea = [NSBezierPath bezierPath];
    NSArray *area = [self selectedArea];
    NSRect firstRect = [[area firstObject] rectValue];
    NSRect lastRect = [[area lastObject] rectValue];
    NSRect frame = NSZeroRect;
    frame = NSMakeRect(NSMinX(firstRect), NSMinY(firstRect), NSWidth(firstRect), NSMaxY(lastRect) - NSMinY(firstRect));
//    frame.origin.y = ([area count] > 1) ? NSMinY([self cellFrameAt:[self.datasource numberOfRowsInTableview:self]]) : NSMinY(firstRect);
    for (int i = 0; i < [area count]; i++) {
        NSRect rect = [[area objectAtIndex:i] rectValue];
        rect.origin.y = NSMinY(rect) - NSMinY(frame);
        NSBezierPath *tPath = [NSBezierPath bezierPathWithRect:rect];
        [selectedArea appendBezierPath:tPath];
    }
    
    [self addCommandKeyUnSelectLayerInSelectIndexsArea:frame];
    
    CGPathRef path = [selectedArea toCGPath];
    self.selectedLayer.path = path;
    CGPathRelease(path);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.15f];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    self.selectedLayer.frame = frame;
    [CATransaction commit];
}

- (void)addCommandKeyUnSelectLayerInSelectIndexsArea:(NSRect)selectTotalArea
{
    if ([[NSApp currentEvent] modifierFlags] & NSCommandKeyMask) {
    //间隔多选时，添加未选中layer
        for (NSInteger index = [_selectIndexs firstIndex]+1; index < [_selectIndexs lastIndex]; index++) {
            if (![_selectIndexs containsIndex:index]) {
                CALayer *layer = [CALayer layer];
                CGColorRef color = [self.unSelectedColor CGColor];
                layer.backgroundColor = color;
                NSRect rect = [self cellFrameAt:index];
                rect.origin.y = NSMinY(rect) - NSMinY(selectTotalArea);
                layer.frame = rect;
                [self.selectedLayer addSublayer:layer];
            }
        }
    }
}

- (void)moveSelectedLayerAnimationTo:(NSRect)rect
{
    [self configMoveGradientLayer];
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.15f];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    self.moveSelectedLayer.frame = rect;
    [CATransaction commit];
}

- (void)addTrackArea
{
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveInKeyWindow | NSTrackingMouseMoved owner:self userInfo:nil];
    [self addTrackingArea:area];
    [area release];
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    [self addTrackArea];
}

- (void)configScrollView
{
    if (!_scrollView) {
        _scrollView = [[NSScrollView alloc] initWithFrame:self.frame];
        NSView *superView = [self superview];
        [self removeFromSuperview];
        [_scrollView setDocumentView:self];
        [superView addSubview:_scrollView];
        
        [_scrollView setAutohidesScrollers:YES];
        [_scrollView setHasHorizontalRuler:NO];
        [_scrollView setHasVerticalScroller:YES];
        [_scrollView setBorderType:NSNoBorder];
        [_scrollView setAutoresizingMask:self.autoresizingMask];
    }
}

#pragma mark draw
- (void)drawMoveSelectArea
{
    NSGradient *gradient = [self gradientWithTargetColor:[NSColor whiteColor]];
    [gradient drawInRect:self.gradientRect angle:0];
}

- (void)drawBounds
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.bounds];
    [path stroke];
}

- (void)drawBackground
{
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:self.bounds];
    [[self backgroundcolor] setFill];
    [backgroundPath fill];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)resetUnselectedLayer
{
//    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *selectedArea = [NSBezierPath bezierPath];
    NSArray *area = [self unSelectedArea];
    for (int i = 0; i < [area count]; i++) {
        NSBezierPath *tPath = [NSBezierPath bezierPathWithRect:[[area objectAtIndex:i] rectValue]];
        [selectedArea appendBezierPath:tPath];
    }
    CGPathRef path = [selectedArea toCGPath];
    _unSelectedLayer.path = path;//[selectedArea toCGPath];
    CGPathRelease(path);
//    [[self unselectedColor] setFill];
//    [selectedArea fill];
//    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawUnselectedArea
{
        [NSGraphicsContext saveGraphicsState];
    NSBezierPath *selectedArea = [NSBezierPath bezierPath];
    NSArray *area = [self unSelectedArea];
    for (int i = 0; i < [area count]; i++) {
        NSBezierPath *tPath = [NSBezierPath bezierPathWithRect:[[area objectAtIndex:i] rectValue]];
        [selectedArea appendBezierPath:tPath];
    }
//    CGPathRef path = [selectedArea toCGPath];
//    _unSelectedLayer.path = path;//[selectedArea toCGPath];
//    CGPathRelease(path);
        [[self unselectedColor] setFill];
//    [self ]
    [[NSColor colorWithDeviceRed:114/255.0 green:114/255.0 blue:114/255.0 alpha:1.0] setStroke];
        [selectedArea fill];
    [selectedArea stroke];
        [NSGraphicsContext restoreGraphicsState];
}

- (void)drawSelectedArea
{
    //此处用layer替代
    if ([_selectIndexs count] > 0) {
        [NSGraphicsContext saveGraphicsState];
        NSBezierPath *selectedArea = [NSBezierPath bezierPath];
        NSArray *area = [self selectedArea];
        for (int i = 0; i < [area count]; i++) {
            NSBezierPath *tPath = [NSBezierPath bezierPathWithRect:[[area objectAtIndex:i] rectValue]];
            [selectedArea appendBezierPath:tPath];
        }
        [_selectColor setFill];
        [selectedArea fill];
        [NSGraphicsContext restoreGraphicsState];
    }
}

#pragma mark ---
- (void)ensureCreateSelectIndexs
{
    if (!_selectIndexs) {
        _selectIndexs = [[NSMutableIndexSet alloc] init];
    }
}

- (void)removeAllSelectIndexs
{
    if ([_selectIndexs count] > 0) {
        [_selectIndexs removeAllIndexes];
    }
}

- (void)reloadData
{
    [self setSubviews:[NSArray array]];
    [self resetFrame];
    NSInteger rowCount = [self cellCount];
    NSIndexSet *indexSection = [self reloadSection];
    for (NSInteger cellIndex = [indexSection firstIndex]; cellIndex <= [indexSection lastIndex]; cellIndex++) {
        NSRect cellFrame = [self cellFrameAt:cellIndex];
        if (CGRectIntersectsRect([self listViewVisibleRect], cellFrame)) {
            id cell = [self cellObjectAtRow:cellIndex];
            if (cell && [cell isKindOfClass:[NSView class]]) {
                if (!NSEqualRects(cellFrame, NSZeroRect)) {
                    [cell setFrame:cellFrame];
                    [self addSubview:cell];
                }
            }
        }
    }
    
    if (rowCount > 0){

    }else{
        CGPathRef path = [[NSBezierPath bezierPath] toCGPath];
        self.selectedLayer.path = path;//[[NSBezierPath bezierPath] toCGPath];
        CGPathRelease(path);
//        [self setSelectRowIndexs:[NSIndexSet indexSet]];
    }
    [self resetUnselectedLayer];
//    [self setNeedsDisplay:YES];
}

- (NSIndexSet *)reloadSection
{
    NSRect visibleArea = [self listViewVisibleRect];
    BOOL needCalculateIndex = ([self cellCount] * [self cellHeight] > NSHeight(visibleArea)) ? YES : NO;
    NSInteger startIndex = needCalculateIndex ? [self cellCount] -(NSMaxY(visibleArea) / [self cellHeight]) : 0;
    NSInteger endIndex =  needCalculateIndex ? [self cellCount] - ((NSMinY(visibleArea) == 0) ? 1 :(NSMinY(visibleArea) / [self cellHeight])) : [self cellCount]-1;
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if ([self isValidOfIndex:startIndex] && [self isValidOfIndex:endIndex]) {
        [indexSet addIndex:startIndex];
        [indexSet addIndex:endIndex];
    }

    return indexSet;
}

- (BOOL)isValidOfIndex:(NSInteger)index
{
    if (index >= 0 && index < [self cellCount]) {
        return YES;
    }
    return NO;
}

- (NSRect)listViewVisibleRect
{
    return [_scrollView documentVisibleRect];
}

- (void)resetFrame
{
    NSRect frame = [self frame];
    frame.size.height = [self tableViewHeight];
    frame.origin.y = [_scrollView contentSize].height - [self tableViewHeight];
    [self setFrame:frame];
//    _tiledLayer.frame = self.bounds;
}

- (NSInteger)numberOfRows
{
    return [self cellCount];
}
#pragma mark get some info
- (CGFloat)cellHeight
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(cellHeghtOfListview:)]) {
        return [self.datasource cellHeghtOfListview:self];
    }
    return _cell_default_height_;
}

- (CGFloat)cellWidth
{
    return NSWidth(self.frame);
}

- (NSInteger)cellCount
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(numberOfRowsInListview:)]) {
        return [self.datasource numberOfRowsInListview:self];
    }
    return 0;
}

- (id)cellObjectAtRow:(NSInteger)row
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(listview:viewForRow:)]) {
        return [self.datasource  listview:self viewForRow:row];
    }
    return nil;
}

- (CGFloat)tableViewHeight
{
    CGFloat cellTotalHeight = [self cellHeight]*[self cellCount];
    return (cellTotalHeight > [_scrollView contentSize].height) ? cellTotalHeight : [_scrollView contentSize].height;
}

- (NSRect)cellFrameAt:(NSInteger)row
{
    NSRect frame = self.bounds;
    
    frame.origin.y = [self tableViewHeight] - (row+1)*[self cellHeight];
    frame.size.height = [self cellHeight];
    return NSInsetRect(frame, _horizontal_offset_, _vertical_offset_);
}

- (NSInteger)cellRowWithPoint:(NSPoint)point
{
    NSInteger cellCount = [self cellCount];
    for (NSInteger cellIndex = 0; cellIndex < cellCount; cellIndex++) {
        NSRect cellFrame = [self cellFrameAt:cellIndex];
        if (NSPointInRect(point, cellFrame)) {
            return cellIndex;
        }
    }
    return -1;
}

- (NSIndexSet *)indexSetOfRect:(NSRect)area
{
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSet];
    NSInteger cellCount = [self cellCount];
    for (NSInteger cellIndex = 0; cellIndex < cellCount; cellIndex++) {
        NSRect cellFrame = [self cellFrameAt:cellIndex];
        if (CGRectIntersectsRect(area, cellFrame)) {
            [indexs addIndex:cellIndex];
        }
    }
    return indexs;
}

- (BOOL)isMultipleSelect
{
    if (NSEqualRects(NSZeroRect, _dragRect)) {
        return NO;
    }
    return YES;
}

- (NSIndexSet *)selectRowIndexs
{
    return _selectIndexs;
}

- (NSArray *)selectedArea
{
    NSRect selectedRect = NSZeroRect;
    NSMutableArray *area = [NSMutableArray array];
    NSIndexSet *selectedIndexs = [self selectRowIndexs];
    NSInteger firstIndex = [selectedIndexs firstIndex];
    NSInteger lastIndex = [selectedIndexs lastIndex];
    if ((firstIndex == lastIndex) && firstIndex < [self cellCount]) {
        selectedRect = [self cellFrameAt:firstIndex];
        if (CGRectIntersectsRect(selectedRect, [self listViewVisibleRect])) {
            [area addObject:[NSValue valueWithRect:selectedRect]];
        }
        
    }else if(firstIndex != lastIndex){
       [_selectIndexs enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
           if (CGRectIntersectsRect([self cellFrameAt:idx], [self listViewVisibleRect])) {
               [area addObject:[NSValue valueWithRect:[self cellFrameAt:idx]]];
           }
       }];
    }
    return area;
}

- (NSArray *)unSelectedArea
{
    NSMutableArray *area = [NSMutableArray array];
    for (int i = 0; i < [self cellCount]; i++) {
        NSRect cellFrame = [self cellFrameAt:i];
        if (CGRectIntersectsRect([self listViewVisibleRect], cellFrame)) {
            [area addObject:[NSValue valueWithRect:[self cellFrameAt:i]]];
        }
        
    }
    return area;
}

- (NSRect)moveInCellFrame
{
    return self.gradientRect;
}

//- (NSColor *)selectAreaColor
//{
//    return self.selectedColor ? self.selectedColor : [NSColor controlColor];
//}

- (NSColor *)unselectedColor
{
    return self.unSelectedColor ? self.unSelectedColor : [NSColor whiteColor];
}

- (NSColor *)backgroundcolor
{
    return self.backgroundColor ? self.backgroundColor : [NSColor grayColor];
}

#pragma mark select
- (void)selectAll
{
//    [self ensureCreateSelectIndexs];
//    [self removeAllSelectIndexs];
//    for (NSInteger i = 0; i < [self cellCount]; i++) {
//        [_selectIndexs addIndex:i];
//    }
//    [self postSelectionDidChangedNotification];
    [self selectedIndexsWith:self.bounds];
//    [self setNeedsDisplay:YES];
    
}
- (void)deSelectAll
{
    [self selectedIndexsWith:NSZeroRect];
    [self setSelectRowIndexs:[NSIndexSet indexSetWithIndex:0]];
//    [self setNeedsDisplay:YES];
}

- (void)setSelectRowIndexs:(NSIndexSet *)selectRowIndexs
{
    [self ensureCreateSelectIndexs];
    [_selectIndexs removeAllIndexes];
    [_selectIndexs addIndexes:selectRowIndexs];
    [self selectedAction];
    [self postSelectionDidChangedNotification];
}

- (void)postSelectionDidChangedNotification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tableViewSelectIsChanging:)]) {
        [self.delegate tableViewSelectIsChanging:self];
    }
}
#pragma mark mouse action
static NSPoint gDownPoint;
- (void)mouseDown:(NSEvent *)theEvent
{
    //获取当前信息
    gDownPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _dragRect = NSZeroRect;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    _dragRect = [self rectFrom:gDownPoint to:dragPoint];
    if (!([theEvent modifierFlags] & NSCommandKeyMask)) {
         [self selectedIndexsWith:_dragRect];
    }
}

- (void)selectedIndexsWith:(NSRect)area
{
    [self ensureCreateSelectIndexs];
    [self removeAllSelectIndexs];
    [_selectIndexs addIndexes:[self indexSetOfRect:area]];
    [self postSelectionDidChangedNotification];
    [self selectedAction];
//    [self resetUnselectedLayer];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self ensureCreateSelectIndexs];
    if (![self disposeMultipleEvent:theEvent]) {
        NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSInteger cellRow = [self cellRowWithPoint:point];
        NSRect area = [self cellFrameAt:cellRow];
        if (NSPointInRect(point, area) && NSPointInRect(gDownPoint, area)) {
            [self selectedIndexsWith:area];
        }
    }
//    [self setNeedsDisplay:YES];
}

- (BOOL)disposeMultipleEvent:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSCommandKeyMask) {
        NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSInteger cellRow = [self cellRowWithPoint:point];
        if ([_selectIndexs containsIndex:cellRow]) {
            [_selectIndexs removeIndex:cellRow];
        }else if(cellRow != -1){
            [_selectIndexs addIndex:cellRow];
        }
        [self postSelectionDidChangedNotification];
        [self selectedAction];
        return YES;
    }
    return NO;
}

- (void)selectedAction
{
    [self selectedLayerAnimation];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger cellRow = [self cellRowWithPoint:point];
    if ((cellRow != -1) && !NSEqualRects(self.gradientRect, [self cellFrameAt:cellRow])) {
        self.gradientRect = [self cellFrameAt:cellRow];
//        [self moveSelectedLayerAnimationTo:self.gradientRect];
//        [self setNeedsDisplay:YES];
    }
}

#pragma mark assistant(辅助的)
- (NSRect)rectFrom:(NSPoint)fromPoint to:(NSPoint)toPoint
{
    NSRect rect = NSZeroRect;
    rect.origin.x = MIN(fromPoint.x, toPoint.x);
    rect.origin.y = MIN(fromPoint.y, toPoint.y);
    rect.size.width = MAX(fromPoint.x, toPoint.x) - MIN(fromPoint.x, toPoint.x);
    rect.size.height = MAX(fromPoint.y, toPoint.y) - MIN(fromPoint.y, toPoint.y);
    return rect;
}

- (NSGradient *)gradientWithTargetColor:(NSColor *)targetColor {
    NSArray *colors = [NSArray arrayWithObjects:[targetColor colorWithAlphaComponent:0], targetColor, targetColor, [targetColor colorWithAlphaComponent:0], nil];
    const CGFloat locations[4] = { 0.0, 0.35, 0.65, 1.0 };
    return [[[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]] autorelease];
}

- (void)dealloc
{
    if (_selectIndexs) {
        [_selectIndexs release];
        _selectIndexs = nil;
    }
    
    if (_scrollView) {
        [_scrollView release];
        _scrollView = nil;
    }
    
    if (_unSelectedColor) {
        [_unSelectedColor release];
        _unSelectedColor = nil;
    }
    
    self.selectedLayer = nil;
    self.moveSelectedLayer = nil;
    self.unSelectedLayer = nil;
    [super dealloc];
}
@end
