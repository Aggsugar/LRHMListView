//
//  AppDelegate.m
//  tableViewDemo
//
//  Created by tangj on 15/11/16.
//  Copyright © 2015年 lanruiheimeng. All rights reserved.
//

#import "AppDelegate.h"
#import "LRHMListView.h"
#import "listViewCell.h"
#define LRHMMakeNSColor(r,g,b,a) [NSColor colorWithDeviceRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
@interface AppDelegate ()<LRHMListViewDatasource,LRHMListViewDelegate>
{
    IBOutlet LRHMListView    *_listView;
}
@property (assign) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self configListView];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)awakeFromNib
{
}

- (void)configListView
{
    [_listView setSelectedColor:LRHMMakeNSColor(74, 144, 226, 255)];
    [_listView setBackgroundColor:LRHMMakeNSColor(143, 147, 152, 255)];
    [_listView setUnSelectedColor:nil];
    
    [_listView reloadData];
    [_listView setSelectRowIndexs:[NSIndexSet indexSetWithIndex:0]];
}

#pragma mark datasource
- (NSInteger)numberOfRowsInListview:(LRHMListView *)aListview
{
    return 3000;
}

- (NSView *)listview:(LRHMListView *)listview viewForRow:(NSInteger)row
{
    //Test data, there is no actual calculation
    listViewCell   *viewCell = [[[listViewCell alloc] init] autorelease];
    viewCell.imageView.image = [NSImage imageNamed:@"defaultImage"];
    viewCell.nameField.stringValue = @"defaultImage";
    viewCell.sizeField.stringValue = @"1.3MB";
    return viewCell.view;
}
- (CGFloat)cellHeghtOfListview:(LRHMListView *)listview
{
    return 70;
}

#pragma mark delegate
- (void)tableViewSelectIsChanging:(LRHMListView *)listview
{
    NSLog(@"select indexs %@",[listview selectRowIndexs]);
}

#pragma mark selectAll and deSelectAll
- (IBAction)selectAll:(id)sender
{
    [_listView selectAll];
}

- (IBAction)deSelectAll:(id)sender
{
    [_listView deSelectAll];
}

@end
