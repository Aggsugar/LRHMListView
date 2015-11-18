//
//  listViewCell.m
//  tableViewDemo
//
//  Created by tangj on 15/11/16.
//  Copyright © 2015年 lanruiheimeng. All rights reserved.
//

#import "listViewCell.h"

@interface listViewCell ()

@end

@implementation listViewCell

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (id)init
{
    if (self == [super init]) {
        [NSBundle loadNibNamed:@"listViewCell" owner:self];
    }
    return self;
}
@end
