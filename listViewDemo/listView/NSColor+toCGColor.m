//
//  NSColor+toCGColor.m
//  testSegmentCtrl
//
//  Created by tangj on 15/8/3.
//  Copyright (c) 2015年 lanruiheimeng. All rights reserved.
//

#import "NSColor+toCGColor.h"

@implementation NSColor (toCGColor)
- (CGColorRef)CGColor
{
    NSColor *rgbColor = [self colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    CGColorRef color = CGColorCreateGenericRGB(rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent, rgbColor.alphaComponent);

    return color;
}
@end
