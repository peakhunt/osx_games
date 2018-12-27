//
//  SCNAction+Extensions.m
//  GeometryFighter
//
//  Created by 김혁 on 20/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "SCNAction+Extensions.h"

@implementation SCNAction (ExtensionForGame)

+ (SCNAction*)waitForDurationThenRemoveFromParent:(NSTimeInterval)duration {
  SCNAction* wait = [SCNAction waitForDuration:duration];
  SCNAction* remove = [SCNAction removeFromParentNode];
  
  return [SCNAction sequence:@[wait, remove]];
}

+ (SCNAction*)waitForDuration:(NSTimeInterval)duration ThenRunBlock:(void (^)(SCNNode * _Nonnull node))block {
  SCNAction* wait = [SCNAction waitForDuration:duration];
  SCNAction* run  = [SCNAction runBlock:^(SCNNode* _Nonnull node) {
    block(node);
  }];
  
  return [SCNAction sequence:@[wait, run]];
}

+ (SCNAction*)rotateForeverByX:(CGFloat)x ByY:(CGFloat)y ByZ:(CGFloat)z ForDuration:(NSTimeInterval)duration {
  SCNAction* rotate = [SCNAction rotateByX:x y:y z:z duration:duration];
  
  return [SCNAction repeatActionForever:rotate];
}
@end
