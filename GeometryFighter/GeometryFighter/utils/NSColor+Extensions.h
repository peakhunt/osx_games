//
//  NSColor+Extensions.h
//  GeometryFighter
//
//  Created by 김혁 on 19/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSColor (ExtensionForGame)
+ (NSColor*)random;
+ (NSColor*)lime;
+ (NSColor*)silver;
+ (NSColor*)maroon;
+ (NSColor*)olive;
+ (NSColor*)teal;
+ (NSColor*)navy;
- (BOOL)compareWithColor:(NSColor*)color;
@end
