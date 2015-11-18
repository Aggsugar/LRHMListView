//
//  NSBezierPath+NSBezierPathToCGPath.h
//  testSegmentCtrl
//
//  Created by 蓝锐黑梦 on 15/8/2.
//  Copyright (c) 2015年 lanruiheimeng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (NSBezierPathToCGPath)
- (CGPathRef)toCGPath;
@end
