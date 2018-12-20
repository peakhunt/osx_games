//
//  GameHelper.h
//  GeometryFighter
//
//  Created by 김혁 on 20/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef GameHelper_h
#define GameHelper_h

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>

typedef enum
{
  Playing,
  TapToPlay,
  GameOver,
} GameStateType;

@interface GameHelper : NSObject

@property SCNNode* hudNode;
@property int score;
@property int lives;
@property GameStateType state;

+ (GameHelper*)sharedInstance;

- (void)saveState;
- (NSString*)getScoreString:(int)length;
- (void)updateHUD;
- (void)loadSoundName:(NSString*)name FileNamed:(NSString*)fileNamed;
- (void)playSound:(SCNNode*)node Name:(NSString*)name;
- (void)reset;
- (void)shakeNode:(SCNNode*)node;

@end

#endif /* GameHelper_h */
