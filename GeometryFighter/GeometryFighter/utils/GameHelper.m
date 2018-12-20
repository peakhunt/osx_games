//
//  GameHelper.m
//  GeometryFighter
//
//  Created by 김혁 on 20/12/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//
#import "GameHelper.h"

#define GAME_HELPER_DEFAULT_LIVES     3

static GameHelper*    _shared_instance = nil;

@implementation GameHelper {
  int             _highScore;
  int             _lastScore;
  
  SKLabelNode*    _labelNode;
  NSMutableDictionary*    _sounds;
}

+ (void)initialize {
  _shared_instance = [[GameHelper alloc] init];
}

+ (GameHelper*)sharedInstance {
  return _shared_instance;
}

- (id)init {
  self = [super init];
  
  if(self)
  {
    _score      = 0;
    _highScore  = 0;
    _lastScore  = 0;
    _lives      = GAME_HELPER_DEFAULT_LIVES;
    _state      = TapToPlay;
    
    _sounds = [NSMutableDictionary dictionary];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _lastScore = (int)[defaults integerForKey:@"lastScore"];
    _highScore = (int)[defaults integerForKey:@"highScore"];
    
    [self initHUD];
  }
  return self;
}

- (void)saveState {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  [defaults setInteger:_lastScore forKey:@"lastScore"];
  [defaults setInteger:_highScore forKey:@"highScore"];
}

- (NSString*)getScoreString:(int)length {
  NSString* format = [NSString stringWithFormat:@"0%d", length];
  
  return [NSString stringWithFormat:format, _lives];
}

- (void)initHUD {
  SKScene*    skScene;
  
  skScene = [SKScene sceneWithSize:CGSizeMake(600, 100)];
  skScene.backgroundColor = [NSColor colorWithWhite:0.0 alpha:0.0];
  
  _labelNode = [SKLabelNode labelNodeWithFontNamed:@"Menlo-Bold"];
  _labelNode.fontSize = 48;
  [_labelNode setPosition:CGPointMake(300, 50)];
  
  [skScene addChild:_labelNode];
  
  SCNPlane* plane = [SCNPlane planeWithWidth:5 height:1];
  SCNMaterial*  material = [SCNMaterial material];
  
  material.lightingModelName = SCNLightingModelConstant;
  [material setDoubleSided:true];
  [[material diffuse] setContents:skScene];
  [plane setMaterials:@[material]];
  
  _hudNode = [SCNNode nodeWithGeometry:plane];
  _hudNode.name = @"HUD";
  _hudNode.rotation = SCNVector4Make(1, 0, 0, 3.14159265);
}

- (void)updateHUD {
  NSString* scoreFormatted = [NSString stringWithFormat:@"%04d", _score];
  NSString* highScoreFormatted = [NSString stringWithFormat:@"%04d", _highScore];
  
  _labelNode.text = [NSString stringWithFormat:@"❤️ %d  😎 %@ 💥 %@",
                     _lives,
                     highScoreFormatted,
                     scoreFormatted];
}

- (void)loadSoundName:(NSString*)name FileNamed:(NSString*)fileNamed {
  SCNAudioSource* sound = [SCNAudioSource audioSourceNamed:fileNamed];
  
  [sound load];
  _sounds[name] = sound;
}

- (void)playSound:(SCNNode*)node Name:(NSString*)name {
  SCNAudioSource* sound = _sounds[name];
  
  [node runAction:[SCNAction playAudioSource:sound waitForCompletion:false]];
}

- (void)reset {
  _score = 0;
  _lives = GAME_HELPER_DEFAULT_LIVES;
}

- (void)shakeNode:(SCNNode*)node {
  SCNAction* left  = [SCNAction moveBy:SCNVector3Make(-0.2, 0.0, 0.0) duration:0.05];
  SCNAction* right = [SCNAction moveBy:SCNVector3Make( 0.2, 0.0, 0.0) duration:0.05];
  SCNAction* up    = [SCNAction moveBy:SCNVector3Make( 0.0, 0.2, 0.0) duration:0.05];
  SCNAction* down  = [SCNAction moveBy:SCNVector3Make( 0.0,-0.2, 0.0) duration:0.05];
  
  [node runAction:[SCNAction sequence:@[
    left, up, down, right, left, right, down, up, right, down, left, up,
    left, up, down, right, left, right, down, up, right, down, left, up]]];
}
@end
