//
//  GameViewController.h
//  GeometryFighter
//
//  Created by 김혁 on 19/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface GameViewController : NSViewController

@end

@interface GameViewController (SCNSceneRendererDelegate) <SCNSceneRendererDelegate>
@end
