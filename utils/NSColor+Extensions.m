//
//  NSColor+Extensions.m
//  GeometryFighter
//
//  Created by 김혁 on 19/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "NSColor+Extensions.h"
#include <stdlib.h>

static NSMutableArray*    _color_list = nil;

@implementation NSColor (ExtensionForGame)

+ (NSColor*)random
{
  if(_color_list == nil)
  {
    _color_list = [NSMutableArray array];
    
    [_color_list addObject:[NSColor blackColor]];
    [_color_list addObject:[NSColor whiteColor]];
    [_color_list addObject:[NSColor redColor]];
    [_color_list addObject:[NSColor lime]];
    [_color_list addObject:[NSColor blueColor]];
    [_color_list addObject:[NSColor yellowColor]];
    [_color_list addObject:[NSColor cyanColor]];
    [_color_list addObject:[NSColor silver]];
    [_color_list addObject:[NSColor grayColor]];
    [_color_list addObject:[NSColor maroon]];
    [_color_list addObject:[NSColor olive]];
    [_color_list addObject:[NSColor brownColor]];
    [_color_list addObject:[NSColor lightGrayColor]];
    [_color_list addObject:[NSColor magentaColor]];
    [_color_list addObject:[NSColor orangeColor]];
    [_color_list addObject:[NSColor purpleColor]];
    [_color_list addObject:[NSColor teal]];
  }
  
  NSUInteger max = [_color_list count];
  uint32_t r = arc4random_uniform((uint32_t)max);
  
  return [_color_list objectAtIndex:r];
}

+ (NSColor*)lime;
{
  return [NSColor colorWithSRGBRed:0.0 green:1.0 blue:0.0 alpha:1.0];
}

+ (NSColor*)silver
{
  return [NSColor colorWithSRGBRed:(192.0/255.0) green:(192.0/255.0) blue:(192.0/255.0) alpha:1.0];
}

+ (NSColor*)maroon
{
  return [NSColor colorWithSRGBRed:0.5 green:0.0 blue:0.0 alpha:1.0];
}

+ (NSColor*)olive
{
  return [NSColor colorWithSRGBRed:0.5 green:0.5 blue:0.0 alpha:1.0];
}

+ (NSColor*)teal
{
  return [NSColor colorWithSRGBRed:0.0 green:0.5 blue:0.5 alpha:1.0];
}

+ (NSColor*)navy
{
  return [NSColor colorWithSRGBRed:0.0 green:0.0 blue:(128.0/255.0) alpha:1.0];
}

- (BOOL)compareWithColor:(NSColor*)color {
  return ([[[CIColor colorWithCGColor:self.CGColor] stringRepresentation]
           isEqualToString:[[CIColor colorWithCGColor:color.CGColor] stringRepresentation]]);
}
@end
