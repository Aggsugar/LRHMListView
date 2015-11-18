//
//  LRHMListView.h
//  DuplicateFileDetector
//
//  Created by tangj on 15/9/21.
//  Copyright (c) 2015年 tangj. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class LRHMListView;
@protocol LRHMListViewDatasource<NSObject>
@required
- (NSInteger)numberOfRowsInListview:(LRHMListView *)aListview;
- (NSView *)listview:(LRHMListView *)listview viewForRow:(NSInteger)row;
@optional
- (CGFloat)cellHeghtOfListview:(LRHMListView *)listview;
@end

@protocol LRHMListViewDelegate <NSObject>
- (void)tableViewSelectIsChanging:(LRHMListView *)listview;
@end
@interface LRHMListView : NSView
@property (assign) IBOutlet id<LRHMListViewDelegate>delegate;
@property (assign) IBOutlet id<LRHMListViewDatasource>datasource;
@property (readonly) NSIndexSet *selectRowIndexs;
@property (retain,nonatomic) NSColor  *backgroundColor;
@property (retain,nonatomic) NSColor  *unSelectedColor;
@property (readonly) NSInteger        numberOfRows;
- (void)setSelectRowIndexs:(NSIndexSet *)selectRowIndexs;
- (void)setSelectedColor:(NSColor *)color;
- (void)selectAll;
- (void)deSelectAll;
- (void)reloadData;
@end
