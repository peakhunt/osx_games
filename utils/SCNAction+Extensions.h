//
//  SCNAction+Extensions.h
//  GeometryFighter
//
//  Created by 김혁 on 20/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@interface SCNAction (ExtensionForGame)
+ (SCNAction*)waitForDurationThenRemoveFromParent:(NSTimeInterval)duration;
+ (SCNAction*)waitForDuration:(NSTimeInterval)duration ThenRunBlock:(void (^)(SCNNode * _Nonnull node))block;
+ (SCNAction*)rotateForeverByX:(CGFloat)x ByY:(CGFloat)y ByZ:(CGFloat)z ForDuration:(NSTimeInterval)duration;
@end
