//
//  listViewCell.h
//  tableViewDemo
//
//  Created by tangj on 15/11/16.
//  Copyright © 2015年 lanruiheimeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface listViewCell : NSViewController
@property (retain) IBOutlet  NSImageView  *imageView;
@property (retain) IBOutlet  NSTextField  *nameField;
@property (retain) IBOutlet  NSTextField  *sizeField;
@end
