//
//  ViewController.h
//  Mr.Pig
//
//  Created by 김혁 on 26/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : NSViewController
@end

@interface GameViewController (SCNSceneRendererDelegate) <SCNSceneRendererDelegate>
@end

@interface GameViewController (SCNPhysicsContactDelegate) <SCNPhysicsContactDelegate>
@end
